/*
 * Name         :   InfaSalesUtility
 * Author       :   Puneet Lohia
 * Created Date :   3/3/2023
 * Description  :   This is an Utility Class for Sales.

 Change History
 *************************************************************************************************************
 Modified By            Date            Jira No.        Description                                     Tag
 *************************************************************************************************************
 Puneet Lohia           3/3/2023        SALESRT-14838   Validate IPUs between Quote and IPU Estimator   <SALESRT-14838>
 Nishant Bansal         21/6/2023       SALESRT-15212   Validate IPU Estimators -- Generalize SKU & Update Criteria
 Puneet                 23/08/2023      SALESRT-17084   IPU Validation for all oppty & quote types
 */
public without sharing class InfaSalesUtility {
    //<SALESRT-14838> Starts here
    /**
     * @description : this method recalculates the ipu warning for given opportunities
     * 
     * @param : opportunityIds - List of opportunity Ids
     * 
     * @return : void
     */
    @future
    public static void recalculateIpuWarnings(List<Id> opportunityIds){

        Map<String,String> ipuTypeToProductId = new Map<String,String>();

        Decimal variancePercent = Decimal.valueOf(System.Label.IpuWarningVariancePercent);

        Map<Id,Estimation_Summary__c> opportunityToPrimaryEstimationMap = new Map<Id,Estimation_Summary__c>();

        for(Estimation_Summary__c es : [SELECT Id,Total_Required_IPUs__c,Opportunity__c,Opportunity__r.RecordType.Name, Opportunity__r.SBQQ__AmendedContract__c, Opportunity__r.SBQQ__RenewedContract__c,Name,
                                        Form__c,Form__r.Name, IPU_Type__c, Form__r.IPU_Type__c
                                        FROM Estimation_Summary__c 
                                        WHERE Opportunity__c IN :opportunityIds AND Primary__c = true
                                        AND Opportunity__r.Type != 'Renewal' AND Opportunity__r.SBQQ__RenewedContract__c = null]){
            if(!opportunityToPrimaryEstimationMap.containsKey(es.Opportunity__c)){
                opportunityToPrimaryEstimationMap.put(es.Opportunity__c, es);
            }
        }

        Map<Id,SBQQ__Quote__c> opportunityToQuoteMap = new Map<Id,SBQQ__Quote__c>();

        for(SBQQ__Quote__c quot : [SELECT Id,SBQQ__Opportunity2__c,SBQQ__Primary__c,Price_Holds__c,
                                   (SELECT Id,SBQQ__Quantity__c,SBQQ__Product__c,SBQQ__Product__r.External_Id__c, SBQQ__EffectiveQuantity__c, SBQQ__Product__r.GTM_Model__c
                                    FROM SBQQ__LineItems__r 
                                    WHERE (SBQQ__DiscountSchedule__c != null AND (SBQQ__Product__r.GTM_Model__c = 'Flex IPU' OR SBQQ__Product__r.GTM_Model__c = 'IPU')) OR
                                    (SBQQ__RequiredBy__c != null AND SBQQ__RequiredBy__r.SBQQ__Product__r.GTM_Model__c = 'IPU' AND Product_External_Id__c =: System.Label.IpuWarningProductMap))
                                   FROM SBQQ__Quote__c 
                                   WHERE SBQQ__Opportunity2__c IN :opportunityIds AND Amend_Type__c != 'Early Renewal - Extend End Date' AND (SBQQ__Primary__c = true OR Price_Holds__c = true)]){

            if(quot.SBQQ__Primary__c){
                opportunityToQuoteMap.put(quot.SBQQ__Opportunity2__c, quot);
            }
            else if(quot.Price_Holds__c){
                
                if(!opportunityToQuoteMap.containsKey(quot.SBQQ__Opportunity2__c)){
                    opportunityToQuoteMap.put(quot.SBQQ__Opportunity2__c, quot);
                }
            }
        }

        Map<Id,Decimal> opportunityToIPUCountMap = new Map<Id,Decimal>();
        Map<Id,String> opportunityToIPUFormName = new Map<Id,String>();

        for(Id oppId : opportunityToQuoteMap.keySet()){

            Decimal cnt = 0;
            String formType = '';

            for(SBQQ__QuoteLine__c quoteLine : opportunityToQuoteMap.get(oppId).SBQQ__LineItems__r){
                if(opportunityToPrimaryEstimationMap != null) {
                    cnt += quoteLine.SBQQ__EffectiveQuantity__c;
                    formType = quoteLine.SBQQ__Product__r.GTM_Model__c;
                }
            }

            if(!opportunityToIPUCountMap.containsKey(oppId)){
                opportunityToIPUCountMap.put(oppId,cnt);
            }

            if(!opportunityToIPUFormName.containsKey(oppId) && formType != ''){
                opportunityToIPUFormName.put(oppId,formType);
            }
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Id oppId : opportunityIds){

            if(opportunityToPrimaryEstimationMap != null && opportunityToPrimaryEstimationMap.containsKey(oppId) && opportunityToQuoteMap != null && opportunityToQuoteMap.containsKey(oppId)){

                String formNameFromQuote = opportunityToIPUFormName.containsKey(oppId) ? opportunityToIPUFormName.get(oppId) : '';
                String formNameFromEstimationSummary = opportunityToPrimaryEstimationMap.get(oppId).IPU_Type__c != null ? opportunityToPrimaryEstimationMap.get(oppId).IPU_Type__c : '';

                if(formNameFromQuote != '' && formNameFromEstimationSummary != '' && formNameFromQuote != formNameFromEstimationSummary ){
                    Opportunity opp = new Opportunity();
                    opp.Id = oppId;
                    opp.IPU_Warnings__c = 'IPU Type Difference';
                    oppsToUpdate.add(opp);
                }
                else if(opportunityToIPUCountMap != null && opportunityToIPUCountMap.containsKey(oppId) && opportunityToIPUCountMap.get(oppId) != 0 && 
                    opportunityToPrimaryEstimationMap != null && opportunityToPrimaryEstimationMap.containsKey(oppId) && 
                    opportunityToPrimaryEstimationMap.get(oppId).Total_Required_IPUs__c != null){

                    Decimal a = opportunityToPrimaryEstimationMap.get(oppId).Total_Required_IPUs__c == null ? 0 : opportunityToPrimaryEstimationMap.get(oppId).Total_Required_IPUs__c;
                    Decimal b = opportunityToIPUCountMap.get(oppId);

                    Decimal num = Math.abs(a-b);
                    Decimal denum = a < b ? a : b;

                    Decimal finalPercent = 0;
                    
                    if(denum != 0 && num != 0) {
                        finalPercent = (num / denum) * 100;
                    } 
                    else if(denum == 0){
                        finalPercent = num * 100;
                    }

                    if(finalPercent >= variancePercent){
                    
                        Opportunity opp = new Opportunity();
                        opp.Id = oppId;
                        opp.IPU_Warnings__c = 'Variance for Estimator Higher than Threshold';
                        oppsToUpdate.add(opp);
                    }
                    else{
                        Opportunity opp = new Opportunity();
                        opp.Id = oppId;
                        opp.IPU_Warnings__c = '';
                        oppsToUpdate.add(opp);
                    }
                }
                else{
                    Opportunity opp = new Opportunity();
                    opp.Id = oppId;
                    opp.IPU_Warnings__c = '';
                    oppsToUpdate.add(opp);
                }
            }
            else{
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.IPU_Warnings__c = '';
                oppsToUpdate.add(opp);
            }
        }

        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }
    //<SALESRT-14838> Ends here
}