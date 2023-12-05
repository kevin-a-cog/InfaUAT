/***************************************************************************************************************************************************************
 *  @Class Name: AnnualizeIPUQuantitiesCls
 *  @Author: VENKATESH BALLA
 *  @Date: 07 DEC 2022
 *  @Description: SALESRT-SALESRT-14435: Logic to create Annualized IPU commitment records
 **********************************************************************************************************************
    ModifiedBy          Date          Requested By          Description                                                
    VENKATESH BALLA    03-02-2023     SALESRT-15147         Round off issue in amend an incorrect 
                                                            number of units is displayed during downsell                
 **********************************************************************************************************************/
public without sharing class AnnualizeIPUQuantitiesCls {
    public static globalApexManager gam = new globalApexManager();
    PRIVATE FINAL STATIC STRING PRODUCT_GOTOMARKET_MODEL = System.Label.IPU_Product_GTM_Value;//'Flex IPU';
    private Set<Id> subScriptionQLIds = new Set<Id>();//to eliminate duplicate aggregation of quantity
    @TestVisible private static Double prorateMultiplierVal;
    /*Method Name : createAnnualCommitments
    * @description - handles the logic to create annualized commitment record for IPU configurations quote. 
                   - handles New, Renewal and Amendment quotes.
    */
    public void createAnnualCommitments(Id quoteId){
        try
        {
            List<SBQQ__QuoteLine__c> flexQuoteLines = [SELECT Id,SBQQ__Product__r.Option_Scale__c,SBQQ__EffectiveStartDate__c, End_Date_Output_QL__c,SBQQ__ProrateMultiplier__c,SBQQ__Quote__c,
                                                  SBQQ__RequiredBy__c,SBQQ__UpgradedSubscription__c,SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c,SBQQ__RequiredBy__r.SBQQ__EffectiveStartDate__c, 
                                                  SBQQ__Quote__r.SBQQ__Type__c,SBQQ__EffectiveQuantity__c,SBQQ__PriorQuantity__c,SBQQ__Quote__r.SBQQ__StartDate__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c = :quoteId AND SBQQ__Product__r.GTM_Model__c = :PRODUCT_GOTOMARKET_MODEL 
                                                  AND SBQQ__Product__r.Option_Scale__c = 'Base Product' AND Product_Category__c = 'Add-ons'
                                                  ORDER BY SBQQ__RequiredBy__c,SBQQ__EffectiveStartDate__c, SBQQ__UpgradedSubscription__c DESC NULLS LAST];
            if(!flexQuoteLines.isEmpty()){
                Set<Id> amendedConfigs = new Set<Id>();
                //to identify if Flex IPU configs are modified or not on amended quote. 
                if(flexQuoteLines[0].SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                        for (AggregateResult ar : [select count(id) cnt,SBQQ__RequiredBy__c  from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId and 
                                                SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c <> NULL AND
                                                SBQQ__Product__r.GTM_Model__c = :PRODUCT_GOTOMARKET_MODEL AND (SBQQ__EffectiveQuantity__c  < 0 OR SBQQ__EffectiveQuantity__c  > 0)
                                                group by SBQQ__RequiredBy__c  having count(Id) > 0]){
                        amendedConfigs.add(((Id)ar.get('SBQQ__RequiredBy__c')));
                    }
                }
                deleteExistingAnnualCommitments(quoteId); //calls method to delete existing IPU annualized records.
                Map<Id,List<SBQQ__QuoteLine__c>> mapFlexBundle = new Map<Id,List<SBQQ__QuoteLine__c>>();
                Map<Id,List<SBQQ__QuoteLine__c>> mapFlexBundleAmend = new Map<Id,List<SBQQ__QuoteLine__c>>();
                Map<Id,Id> mapSubscriptionParentQLId = new Map<Id,Id>();
                Map<Id,Date> mapParentQLDate = new Map<Id,Date>();
                for(SBQQ__QuoteLine__c quoteLine : flexQuoteLines){
                    if(!mapParentQLDate.containsKey(quoteLine.SBQQ__RequiredBy__c) && quoteLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c <> null){
                        mapParentQLDate.put(quoteLine.SBQQ__RequiredBy__c, quoteLine.SBQQ__RequiredBy__r.SBQQ__EffectiveStartDate__c);
                    }
                }
                Set<Id> oldestDateFound = new Set<Id>();
                for(SBQQ__QuoteLine__c quoteLine : flexQuoteLines){

                    if(quoteLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c == null){ //for new line configurations/NNB/Renewals
                        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>();
                        if(mapFlexBundle.containsKey(quoteLine.SBQQ__RequiredBy__c)){
                            lstquoteLines = mapFlexBundle.get(quoteLine.SBQQ__RequiredBy__c);
                        }
                        lstquoteLines.add(quoteLine);
                        mapFlexBundle.put(quoteLine.SBQQ__RequiredBy__c,lstquoteLines);
                    }else{
                        if(amendedConfigs.contains(quoteLine.SBQQ__RequiredBy__c)){
                            if(quoteLine.SBQQ__EffectiveQuantity__c <> 0){
                            List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>();
                            if(mapFlexBundleAmend.containsKey(quoteLine.SBQQ__RequiredBy__c)){
                                lstquoteLines = mapFlexBundleAmend.get(quoteLine.SBQQ__RequiredBy__c);
                            }
                            lstquoteLines.add(quoteLine);
                            mapFlexBundleAmend.put(quoteLine.SBQQ__RequiredBy__c,lstquoteLines);
                            }
                            //to get start date for each wrapper
                            if(quoteLine.SBQQ__UpgradedSubscription__c == null && mapParentQLDate.get(quoteLine.SBQQ__RequiredBy__c) < quoteLine.SBQQ__EffectiveStartDate__c && !oldestDateFound.contains(quoteLine.SBQQ__RequiredBy__c)){
                                mapParentQLDate.put(quoteLine.SBQQ__RequiredBy__c,quoteLine.SBQQ__EffectiveStartDate__c);
                                //oldestDateFound.add(quoteLine.SBQQ__RequiredBy__c); - commented to fix the bug SALESRT-15064: Issues with Amend Quote in the IPU Entitlement Section
                            }
                            //added this check as the above block was skipping the oldest line to check date - added for SALESRT-15064: Issues with Amend Quote in the IPU Entitlement Section
                            if(quoteLine.SBQQ__UpgradedSubscription__c == NULL){
                                oldestDateFound.add(quoteLine.SBQQ__RequiredBy__c);
                            }
                            mapSubscriptionParentQLId.put(quoteLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c,quoteLine.SBQQ__RequiredBy__c);
                        }
                    }
                }

                List<IPU_Annual_Commitment__c> lstIpuCommitmentToInsert = new List<IPU_Annual_Commitment__c>();

                if(!mapFlexBundle.isEmpty()){
                    lstIpuCommitmentToInsert.addAll(getAnnualCommitmentsForNewAndRenewal(mapFlexBundle));
                }

                if(!mapSubscriptionParentQLId.isEmpty()){
                    lstIpuCommitmentToInsert.addAll(getAnnualCommitmentsForAmend(mapSubscriptionParentQLId,quoteId,mapFlexBundleAmend,mapParentQLDate));
                }

                insert lstIpuCommitmentToInsert;
            }
        }catch(Exception ex){
            GAM.CreateExceptionRecords('AnnualizeIPUQuantitiesCls', 'Exception in createAnnualCommitments',ex.getMessage());
        } 
        GAM.InsertDebugLogs();
    }

    /*Method Name : deleteExistingAnnualCommitments
    * @description - to regenerate the annual commitments delete existing records if there are any. 
    */
    private void deleteExistingAnnualCommitments(Id quoteID){
        delete [select Id from IPU_Annual_Commitment__c where Quote__c = :quoteID];
    }

    /*Method Name : deleteExistingAnnualCommitments
    * @description - to regenerate the annual commitments delete existing records if there are any. 
    */
    private List<IPU_Annual_Commitment__c> getAnnualCommitmentsForNewAndRenewal(Map<Id,List<SBQQ__QuoteLine__c>> mapFlexBundle){
        
        List<IPU_Annual_Commitment__c> lstIpuCommitmentToInsert = new List<IPU_Annual_Commitment__c>();
        Map<Id,List<IPU_Annual_Commitment__c>> mapFlexWrapperCommitment = new Map<Id,List<IPU_Annual_Commitment__c>>();
        Map<Id,Date> mapFlexWrapperEndDate = new Map<Id,Date>();
        
        for(Id flexWrapper:mapFlexBundle.keySet()){

            Integer multiLineCount = 0;
            for(SBQQ__QuoteLine__c commitmentLine:mapFlexBundle.get(flexWrapper)){
                Date endDate = commitmentLine.End_Date_Output_QL__c;
                
                List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = new List<IPU_Annual_Commitment__c>();
                if(mapFlexWrapperCommitment.containsKey(commitmentLine.SBQQ__RequiredBy__c)){
                    lstIpuAnnualCommitment = mapFlexWrapperCommitment.get(commitmentLine.SBQQ__RequiredBy__c);
                }
                multiLineCount++;
                lstIpuAnnualCommitment = getAnnualCommitmentRec(commitmentLine,lstIpuAnnualCommitment, mapFlexBundle.get(flexWrapper).size() == multiLineCount);//add checkpoint for containskey method
                mapFlexWrapperCommitment.put(commitmentLine.SBQQ__RequiredBy__c,lstIpuAnnualCommitment);

                if(!mapFlexWrapperEndDate.containsKey(commitmentLine.SBQQ__RequiredBy__c)){
                    mapFlexWrapperEndDate.put(commitmentLine.SBQQ__RequiredBy__c,endDate);
                }else if(mapFlexWrapperEndDate.get(commitmentLine.SBQQ__RequiredBy__c) < endDate){
                    mapFlexWrapperEndDate.put(commitmentLine.SBQQ__RequiredBy__c,endDate);
                }
            }
        }

        for(Id flexWrapper:mapFlexWrapperCommitment.keySet()){
            Date endDate = mapFlexWrapperEndDate.get(flexWrapper);
            for(IPU_Annual_Commitment__c commitmentRec:mapFlexWrapperCommitment.get(flexWrapper)){
                if(commitmentRec.Annual_Term_End_Date__c == endDate){
                    commitmentRec.Last_Term__c = true;
                }
            }

            lstIpuCommitmentToInsert.addAll(mapFlexWrapperCommitment.get(flexWrapper));
        }
        return lstIpuCommitmentToInsert;
    }

    private List<IPU_Annual_Commitment__c> getAnnualCommitmentRec(SBQQ__QuoteLine__c commitmentLine, List<IPU_Annual_Commitment__c> lstExistingIpuAnnualCommitment, 
    Boolean isLastLine){
        List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = new List<IPU_Annual_Commitment__c>();
        
        if(!lstExistingIpuAnnualCommitment.isEmpty()){
            Decimal prorateMultiplier = Test.isRunningTest() ? prorateMultiplierVal : commitmentLine.SBQQ__ProrateMultiplier__c;
            Decimal period;
            Decimal termEndMonth;
            Date lineStartDate;
            while (prorateMultiplier > 0) {
                Boolean recordExists = false;
                Integer i = 1;
                Integer totalQtyPerWrapper = 0;
                for(IPU_Annual_Commitment__c ipuacExistingRec:lstExistingIpuAnnualCommitment){
                    if(ipuacExistingRec.Annual_Term_Start_Date__c >= commitmentLine.SBQQ__EffectiveStartDate__c){
                        recordExists = true;
                        if(prorateMultiplier >=1){
                            if(!subScriptionQLIds.contains(commitmentLine.Id)){
                                ipuacExistingRec.Annual_Commitment__c = ipuacExistingRec.Annual_Commitment__c + commitmentLine.SBQQ__EffectiveQuantity__c;
                            }
                            if(commitmentLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c != null){
                                ipuacExistingRec.Incremental_Quantity__c = ipuacExistingRec.Incremental_Quantity__c + commitmentLine.SBQQ__EffectiveQuantity__c;
                            }
                        }else if(prorateMultiplier >= 0 && prorateMultiplier <  1) {
                            if(!subScriptionQLIds.contains(commitmentLine.Id)){
                                if(isLastLine){
                                    //if(ipuacExistingRec.Annual_Commitment__c < 0 || commitmentLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c != null){ -- commented as the below two blocks have same statement.
                                    ipuacExistingRec.Annual_Commitment__c = (prorateMultiplier * commitmentLine.SBQQ__EffectiveQuantity__c + ipuacExistingRec.Annual_Commitment__c).round(System.RoundingMode.CEILING);
                                    /*}
                                    else{
                                        ipuacExistingRec.Annual_Commitment__c = (prorateMultiplier * commitmentLine.SBQQ__EffectiveQuantity__c + ipuacExistingRec.Annual_Commitment__c).round(System.RoundingMode.CEILING);
                                    }*/
                                }
                                else{
                                    //if(commitmentLine.SBQQ__EffectiveQuantity__c < 0 || commitmentLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c != null){-- commented as the below two blocks have same statement.
                                        ipuacExistingRec.Annual_Commitment__c = ipuacExistingRec.Annual_Commitment__c + commitmentLine.SBQQ__EffectiveQuantity__c * prorateMultiplier;//.round(System.RoundingMode.CEILING);-- commented SALESRT-15147 rounding issue
                                    //}
                                    //else
                                    //    ipuacExistingRec.Annual_Commitment__c = ipuacExistingRec.Annual_Commitment__c + commitmentLine.SBQQ__EffectiveQuantity__c * prorateMultiplier;//).round(System.RoundingMode.CEILING);
                                }
                            }
                            if(commitmentLine.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c != null){
                                if(commitmentLine.SBQQ__EffectiveQuantity__c < 0 || !isLastLine){//SALESRT-15147 added - to apply rounding method only for last IPU entitlement line.
                                    ipuacExistingRec.Incremental_Quantity__c = ipuacExistingRec.Incremental_Quantity__c + commitmentLine.SBQQ__EffectiveQuantity__c * prorateMultiplier;
                                }
                                else{
                                    ipuacExistingRec.Incremental_Quantity__c = (ipuacExistingRec.Incremental_Quantity__c + commitmentLine.SBQQ__EffectiveQuantity__c * prorateMultiplier);
                                    if(ipuacExistingRec.Incremental_Quantity__c < 0) //Added logic to fix - SALESRT-15147 rounding issue
                                    {
                                        ipuacExistingRec.Incremental_Quantity__c = ipuacExistingRec.Incremental_Quantity__c.round(System.RoundingMode.FLOOR);
                                    }
                                    else{
                                        ipuacExistingRec.Incremental_Quantity__c = ipuacExistingRec.Incremental_Quantity__c.round(System.RoundingMode.CEILING);
                                    }
                                }
                            }                                                      
                        }
                        prorateMultiplier--;
                    }
                }
            }
            return lstExistingIpuAnnualCommitment;
        }
        else{
            Decimal prorateMultiplier = Test.isRunningTest() ? prorateMultiplierVal : commitmentLine.SBQQ__ProrateMultiplier__c;
            Integer noOfYears = Integer.valueOf(commitmentLine.SBQQ__Quote__r.SBQQ__StartDate__c.monthsBetween(commitmentLine.SBQQ__EffectiveStartDate__c)/12);
            Decimal period = 1 + noOfYears;
            Decimal termStartMonth = 1 + (noOfYears*12);
            Date lineStartDate = commitmentLine.SBQQ__EffectiveStartDate__c;
            while (prorateMultiplier > 0) {
                IPU_Annual_Commitment__c ipuac = new IPU_Annual_Commitment__c();
                ipuac.Quote__c = commitmentLine.SBQQ__Quote__c;
                ipuac.Quote_Line__c = commitmentLine.SBQQ__RequiredBy__c;
                ipuac.Term_Period__c = period;
                ipuac.Annual_Term_Start_Date__c = lineStartDate;
                ipuac.Annual_Term_Start_Date__c = lineStartDate;
                if(prorateMultiplier >=1){
                    ipuac.Annual_Term_End_Date__c = lineStartDate.addYears(1).addDays(-1);
                    lineStartDate = lineStartDate.addYears(1);
                    ipuac.Annual_Term_Start_Month__c = String.valueOf(termStartMonth);
                    termStartMonth = termStartMonth + 11;
                    ipuac.Annual_Term_End_Month__c = String.valueOf(termStartMonth);
                    ipuac.Annual_Commitment__c = commitmentLine.SBQQ__EffectiveQuantity__c;
                }else{
                    ipuac.Annual_Term_End_Date__c = commitmentLine.End_Date_Output_QL__c;
                    ipuac.Annual_Term_Start_Month__c = String.valueOf(termStartMonth);
                    termStartMonth = termStartMonth + lineStartDate.monthsBetween(commitmentLine.End_Date_Output_QL__c);
                    ipuac.Annual_Term_End_Month__c = String.valueOf(termStartMonth);
                    if(isLastLine){
                        ipuac.Annual_Commitment__c = (prorateMultiplier * commitmentLine.SBQQ__EffectiveQuantity__c ).round(System.RoundingMode.CEILING);
                    }
                    else{
                        ipuac.Annual_Commitment__c = (commitmentLine.SBQQ__EffectiveQuantity__c * prorateMultiplier);//.round(System.RoundingMode.CEILING);
                    }
                }
                prorateMultiplier--;
                period++;
                termStartMonth++;
                lstIpuAnnualCommitment.add(ipuac);
            }
        }
        return lstIpuAnnualCommitment;
    }

    private List<IPU_Annual_Commitment__c> getAnnualCommitmentsForAmend(Map<Id,Id> mapSubscriptionParentQLId,Id quoteId,Map<Id,List<SBQQ__QuoteLine__c>> mapFlexBundleAmend,Map<Id,Date> mapParentQLDate){
        List<IPU_Annual_Commitment__c> lstIpuCommitmentToInsert = new List<IPU_Annual_Commitment__c>();
        List<SBQQ__Subscription__c> lstSubscription = [SELECT Id,SBQQ__RequiredById__c,SBQQ__ProrateMultiplier__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c, SBQQ__QuoteLine__r.End_Date_Output_QL__c 
                                                       FROM SBQQ__Subscription__c 
                                                       WHERE SBQQ__RequiredById__c IN :mapSubscriptionParentQLId.keySet() AND SBQQ__Product__r.GTM_Model__c = :PRODUCT_GOTOMARKET_MODEL 
                                                       AND SBQQ__Product__r.Option_Scale__c = 'Base Product' AND SBQQ__Product__r.Product_Category__c = 'Add-ons'
                                                       ORDER BY SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c, createdDate];
        Map<Id,List<SBQQ__Subscription__c>> mapFlexBundle = new Map<Id,List<SBQQ__Subscription__c>>();
        for(SBQQ__Subscription__c subrec:lstSubscription){            
            List<SBQQ__Subscription__c> lstSubscriptionLines = new List<SBQQ__Subscription__c>();
            if(mapFlexBundle.containsKey(subrec.SBQQ__RequiredById__c)){
                lstSubscriptionLines = mapFlexBundle.get(subrec.SBQQ__RequiredById__c);
            }
            lstSubscriptionLines.add(subrec);
            mapFlexBundle.put(subrec.SBQQ__RequiredById__c,lstSubscriptionLines);
            subScriptionQLIds.add(subrec.SBQQ__QuoteLine__c);
        }
        Map<Id,List<IPU_Annual_Commitment__c>> mapFlexWrapperCommitment = new Map<Id,List<IPU_Annual_Commitment__c>>();
        for(Id flexWrapper:mapFlexBundle.keySet()){
            Integer multiLineCount = 0;
            for(SBQQ__Subscription__c commitmentLine:mapFlexBundle.get(flexWrapper)){                
                List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = new List<IPU_Annual_Commitment__c>();
                if(mapFlexWrapperCommitment.containsKey(mapSubscriptionParentQLId.get(commitmentLine.SBQQ__RequiredById__c))){
                    lstIpuAnnualCommitment = mapFlexWrapperCommitment.get(mapSubscriptionParentQLId.get(commitmentLine.SBQQ__RequiredById__c));
                }
                multiLineCount++;
                lstIpuAnnualCommitment = getAnnualCommitmentRec(commitmentLine,lstIpuAnnualCommitment,mapSubscriptionParentQLId,quoteId, mapFlexBundle.get(flexWrapper).size() == multiLineCount);
                mapFlexWrapperCommitment.put(mapSubscriptionParentQLId.get(commitmentLine.SBQQ__RequiredById__c),lstIpuAnnualCommitment);
            }
        }
        for(Id flexWrapper:mapFlexWrapperCommitment.keySet()){
            List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = mapFlexWrapperCommitment.get(flexWrapper);
            Integer i =0;
            while(i<lstIpuAnnualCommitment.size()){
                System.debug('mapParentQLDate----:::'+mapParentQLDate);
                if(lstIpuAnnualCommitment.get(i).Annual_Term_Start_Date__c < mapParentQLDate.get(flexWrapper)){
                    lstIpuAnnualCommitment.remove(i);
                }else{
                    i++;
                }
            }
            mapFlexWrapperCommitment.put(flexWrapper,lstIpuAnnualCommitment);
        }        
        Map<Id,Date> mapFlexWrapperEndDate = new Map<Id,Date>();
        for(Id flexWrapper:mapFlexBundleAmend.keySet()){
            Integer multiLineCount = 0;
            for(SBQQ__QuoteLine__c commitmentLine:mapFlexBundleAmend.get(flexWrapper)){
                Date endDate = commitmentLine.End_Date_Output_QL__c;                
                List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = new List<IPU_Annual_Commitment__c>();
                if(mapFlexWrapperCommitment.containsKey(commitmentLine.SBQQ__RequiredBy__c)){
                    lstIpuAnnualCommitment = mapFlexWrapperCommitment.get(commitmentLine.SBQQ__RequiredBy__c);
                }
                multiLineCount++;
                lstIpuAnnualCommitment = getAnnualCommitmentRec(commitmentLine,lstIpuAnnualCommitment, mapFlexBundleAmend.get(flexWrapper).size() == multiLineCount);
                mapFlexWrapperCommitment.put(commitmentLine.SBQQ__RequiredBy__c,lstIpuAnnualCommitment);
        
                if(!mapFlexWrapperEndDate.containsKey(commitmentLine.SBQQ__RequiredBy__c)){
                    mapFlexWrapperEndDate.put(commitmentLine.SBQQ__RequiredBy__c,endDate);
                }else if(mapFlexWrapperEndDate.get(commitmentLine.SBQQ__RequiredBy__c) < endDate){
                    mapFlexWrapperEndDate.put(commitmentLine.SBQQ__RequiredBy__c,endDate);
                }
            }
        }        
        for(Id flexWrapper:mapFlexWrapperCommitment.keySet()){
            Date endDate = mapFlexWrapperEndDate.get(flexWrapper);
            for(IPU_Annual_Commitment__c commitmentRec:mapFlexWrapperCommitment.get(flexWrapper)){
                if(commitmentRec.Annual_Term_End_Date__c == endDate){
                    commitmentRec.Last_Term__c = true;
                }
            }
            lstIpuCommitmentToInsert.addAll(mapFlexWrapperCommitment.get(flexWrapper));
        }
        return lstIpuCommitmentToInsert;
    }

    private List<IPU_Annual_Commitment__c> getAnnualCommitmentRec(SBQQ__Subscription__c commitmentLine, List<IPU_Annual_Commitment__c> lstExistingIpuAnnualCommitment, Map<Id,Id> mapSubscriptionParentQLId,Id quoteId,
    Boolean isLastLine){
        List<IPU_Annual_Commitment__c> lstIpuAnnualCommitment = new List<IPU_Annual_Commitment__c>();        
        if(!lstExistingIpuAnnualCommitment.isEmpty()){
            Decimal prorateMultiplier = Test.isRunningTest() ? prorateMultiplierVal : commitmentLine.SBQQ__ProrateMultiplier__c;
            Decimal period;
            Decimal termEndMonth;
            Date lineStartDate;
            while (prorateMultiplier > 0) {
                Boolean recordExists = false;
                for(IPU_Annual_Commitment__c ipuacExistingRec:lstExistingIpuAnnualCommitment){
                    if(ipuacExistingRec.Annual_Term_Start_Date__c >= commitmentLine.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c){                        
                        recordExists = true;                
                        if(prorateMultiplier >=1){
                            ipuacExistingRec.Annual_Commitment__c = ipuacExistingRec.Annual_Commitment__c + commitmentLine.SBQQ__Quantity__c;        
                        }else{        
                            if(isLastLine){
                                ipuacExistingRec.Annual_Commitment__c = (prorateMultiplier * (commitmentLine.SBQQ__Quantity__c + ipuacExistingRec.Annual_Commitment__c) );//.round(System.RoundingMode.CEILING);-- commented SALESRT-15147 rounding issue
                            }
                            else{
                                ipuacExistingRec.Annual_Commitment__c = ipuacExistingRec.Annual_Commitment__c + (commitmentLine.SBQQ__Quantity__c);// * prorateMultiplier).round(System.RoundingMode.CEILING);
                            }
                        }
                        prorateMultiplier--;
                    }
                    period = ipuacExistingRec.Term_Period__c;
                    termEndMonth = Decimal.valueof(ipuacExistingRec.Annual_Term_End_Month__c);
                    lineStartDate = ipuacExistingRec.Annual_Term_End_Date__c.addDays(1);
                }
                if(!recordExists){
                    IPU_Annual_Commitment__c ipuac = new IPU_Annual_Commitment__c();
                    ipuac.Quote__c = quoteId;
                    ipuac.Quote_Line__c = mapSubscriptionParentQLId.get(commitmentLine.SBQQ__RequiredById__c);
                    ipuac.Term_Period__c = period;
                    ipuac.Incremental_Quantity__c = 0;
                    ipuac.Annual_Term_Start_Date__c = lineStartDate;                    
                    if(prorateMultiplier >=1){
                        ipuac.Annual_Term_End_Date__c = lineStartDate.addYears(1).addDays(-1);
                        lineStartDate = lineStartDate.addYears(1);    
                        ipuac.Annual_Term_Start_Month__c = String.valueOf(termEndMonth);
                        termEndMonth = termEndMonth + 11;
                        ipuac.Annual_Term_End_Month__c = String.valueOf(termEndMonth);    
                        ipuac.Annual_Commitment__c = commitmentLine.SBQQ__Quantity__c;    
                    }else{
                        ipuac.Annual_Term_End_Date__c = commitmentLine.SBQQ__QuoteLine__r.End_Date_Output_QL__c;    
                        ipuac.Annual_Term_Start_Month__c = String.valueOf(termEndMonth);
                        termEndMonth = termEndMonth + lineStartDate.monthsBetween(commitmentLine.SBQQ__QuoteLine__r.End_Date_Output_QL__c);
                        ipuac.Annual_Term_End_Month__c = String.valueOf(termEndMonth);    
                        ipuac.Annual_Commitment__c = (commitmentLine.SBQQ__Quantity__c * prorateMultiplier);//.round(System.RoundingMode.CEILING);-- commented SALESRT-15147 rounding issue
                    }    
                    prorateMultiplier--;
                    period++;
                    termEndMonth++;                    
                    lstExistingIpuAnnualCommitment.add(ipuac);
                }
            }
            return lstExistingIpuAnnualCommitment;
        }
        
        else{
            Decimal prorateMultiplier = Test.isRunningTest() ? prorateMultiplierVal : commitmentLine.SBQQ__ProrateMultiplier__c;
            Decimal period = 1;
            Decimal termStartMonth = 1;
            Date lineStartDate = commitmentLine.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c;

            while (prorateMultiplier > 0) {
                IPU_Annual_Commitment__c ipuac = new IPU_Annual_Commitment__c();
                ipuac.Quote__c = quoteId;
                ipuac.Quote_Line__c = mapSubscriptionParentQLId.get(commitmentLine.SBQQ__RequiredById__c);
                ipuac.Term_Period__c = period;
                ipuac.Incremental_Quantity__c = 0;
                ipuac.Annual_Term_Start_Date__c = lineStartDate;
                
                if(prorateMultiplier >=1){
                    ipuac.Annual_Term_End_Date__c = lineStartDate.addYears(1).addDays(-1);
                    lineStartDate = lineStartDate.addYears(1);
                    ipuac.Annual_Term_Start_Month__c = String.valueOf(termStartMonth);
                    termStartMonth = termStartMonth + 11;
                    ipuac.Annual_Term_End_Month__c = String.valueOf(termStartMonth);
                    ipuac.Annual_Commitment__c = commitmentLine.SBQQ__Quantity__c;

                }else{
                    ipuac.Annual_Term_End_Date__c = commitmentLine.SBQQ__QuoteLine__r.End_Date_Output_QL__c;
                    ipuac.Annual_Term_Start_Month__c = String.valueOf(termStartMonth);
                    termStartMonth = termStartMonth + lineStartDate.monthsBetween(commitmentLine.SBQQ__QuoteLine__r.End_Date_Output_QL__c);
                    ipuac.Annual_Term_End_Month__c = String.valueOf(termStartMonth);
                    if(isLastLine){
                        ipuac.Annual_Commitment__c = ( prorateMultiplier * commitmentLine.SBQQ__Quantity__c );//.round(System.RoundingMode.CEILING);-- commented SALESRT-15147 rounding issue
                    }
                    else{
                        ipuac.Annual_Commitment__c =  (commitmentLine.SBQQ__Quantity__c);
                    }
                }
                prorateMultiplier--;
                period++;
                termStartMonth++;                
                lstIpuAnnualCommitment.add(ipuac);
            }
        }
        return lstIpuAnnualCommitment;
    }    
}