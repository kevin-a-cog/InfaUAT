/*
Trigger:        RiskAssessmentController 
@Author:        Anusha Akella
@Created Date:  Sep 27 2022
@Description:   
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.                      Description                                                 Tag

********************************************************************************************************************************************
*/ 
public without sharing class RiskAssessmentController {

    
    public static GlobalDataTableWrapperClass getTableStructure(Risk_Assessment__c pafRec) {

        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

        GlobalDataTableWrapperClass.ColumnWrapperClass objColumn;
		GlobalDataTableWrapperClass.PicklistWrapperClass objPicklist;
        fieldWrapper objRecord;
        objDataTable.lstRecordsCustomStructure = new List<Object>();
		objDataTable.lstRecords = new List<sObject>();
        //Map<Map<String, String>, String> mapParentChildRelationship = new Map<Map<String, String>, String>();
        Map<String,String> mapParentChildRelationship = new Map<String,String>();

        List<String> lstColumnFields = new List<String>();

        Map< String, String> mapIcons = new Map< String, String>();
        mapIcons.put('DetailsOn', '');
        mapIcons.put('DetailsOff','');

        for(StaticResource objStaticResource : [SELECT Name, SystemModStamp FROM StaticResource WHERE Name IN :mapIcons.keySet() LIMIT 1000]) {
            mapIcons.put(objStaticResource.Name, '/resource/' + objStaticResource.SystemModStamp.getTime() + '/' + objStaticResource.Name);
        }

        //We define the Coulmn field API names
        
        lstColumnFields.add('Id');
        //lstColumnFields.add('Category__c');
        lstColumnFields.add('MasterLabel');
        lstColumnFields.add('GREEN_1_POINTS__c');
        lstColumnFields.add('YELLOW_2_POINTS__c');
        lstColumnFields.add('RED_3_POINTS__c');

        List<Risk_Assessment_SubCategory__mdt> RA_subCategory_MDT = [SELECT ID,MasterLabel,Risk_Assessment_Category__c,isSubcategory__c FROM Risk_Assessment_SubCategory__mdt];

        List<Risk_Assessment_Category__mdt> RA_Category_MDT = [SELECT ID,MasterLabel FROM Risk_Assessment_Category__mdt];

        map<String,String> mapPaerntChildLvl1 = new map<String,String>();
        map<String,String> mapCatSubCategory = new map<String,String>();

       for(Risk_Assessment_Category__mdt categoryRec: RA_Category_MDT) {
            //mapPaerntChildLvl1.put(categoryRec.MasterLabel,categoryRec.Id);

            objDataTable.lstRecords.add(categoryRec);
            
            objRecord = new fieldWrapper();
            objRecord.Id = categoryRec.Id;
            objRecord.Area = categoryRec.MasterLabel; 

            map<string,string> mapSt = new map<string,string>();

            mapSt.put('strName', 'font-size: 14px; min-width: 240px;');
            objRecord.mapStyles = mapSt;
                
            objDataTable.lstRecordsCustomStructure.add(objRecord);
        }
        
        List<Risk_Assessment_Mapping__mdt> PFA_Custom_MDT = getMDTquery();
        //Parent Record
        map<String,String> mapPaerntChildRec = new map<String,String>();

        for(Risk_Assessment_SubCategory__mdt subcategoryRec: RA_subCategory_MDT) {
            
            mapParentChildRelationship.put(subcategoryRec.Id,subcategoryRec.Risk_Assessment_Category__c);
            
            //mapCatSubCategory.put(subcategoryRec.Id,mapPaerntChildLvl1.Id);
            objDataTable.lstRecords.add(subcategoryRec);
            objRecord = new fieldWrapper();

            objRecord.Id = subcategoryRec.Id;
            objRecord.Area = subcategoryRec.MasterLabel;
            objRecord.isSecondLevelParent = subcategoryRec.isSubcategory__c;
            objRecord.categoryParentId = subcategoryRec.Risk_Assessment_Category__c;

            map<string,string> mapSt = new map<string,string>();

            mapSt.put('strName', 'font-size: 14px; min-width: 240px;');
            objRecord.mapStyles = mapSt;

                
            objDataTable.lstRecordsCustomStructure.add(objRecord);
        }
        
            for(Risk_Assessment_Mapping__mdt  objMdtRec : PFA_Custom_MDT) {
                mapParentChildRelationship.put(objMdtRec.Id,objMdtRec.Risk_Assessment_SubCategory__c);

                objDataTable.lstRecords.add(objMdtRec);
                objRecord = new fieldWrapper();
                
                //objRecord = new CSMObjectivesAndMilestonesWrapper();
                
                objRecord.Id = objMdtRec.Id;
                objRecord.Category = objMdtRec.Risk_Assessment_SubCategory__r.Risk_Assessment_Category__r.MasterLabel;
                objRecord.SubCategory = objMdtRec.Risk_Assessment_SubCategory__r.MasterLabel;
                objRecord.SubCategoryId = objMdtRec.Risk_Assessment_SubCategory__c;
                objRecord.Area = objMdtRec.Area__c;
                objRecord.Green = objMdtRec.GREEN_1_POINTS__c;
                objRecord.Yellow = objMdtRec.YELLOW_2_POINTS__c;
                objRecord.Red = objMdtRec.RED_3_POINTS__c;
                objRecord.ipuServices = objMdtRec.IPU_Services__c;
                if(pafRec == null){
                    objRecord.Score = '1';
                }
                    
                if(pafRec != null){
                    objRecord.Score = (string)pafRec.get(objMdtRec.Score_Field_API_Name__c);
                    objRecord.Comment = (string)pafRec.get(objMdtRec.Comment_Field_API_Name__c);
                    //objRecord.Action = (string)pafRec.get(objMdtRec.Action_Field_API_Name__c);
                    system.debug('Comments 181'+
                    objRecord.Comment+'Action'+
                    (string)pafRec.get(objMdtRec.Comment_Field_API_Name__c)
                    );
                }

                map<string,string> mapSt = new map<string,string>();

                mapSt.put('strName', 'font-size: 14px; min-width: 240px;');
                objRecord.mapStyles = mapSt;

                ActionWrapper objAction = new ActionWrapper(); 

				objAction.intAction = 1;
				objAction.boolIsStaticResource = true;
				objAction.intWidth = 20;
				objAction.strURL = mapIcons.get('DetailsOn');
				objAction.strInverseURL = mapIcons.get('DetailsOff');
                objRecord.lstActions = objAction;

                //Now we save the additional information.
                fieldWrapper objAdditionalInformation = new fieldWrapper();
                objAdditionalInformation.boolHasValidId = false;
                objAdditionalInformation.boolCustomLayout = true;
                objAdditionalInformation.intRecordLayoutType = 1;
                objAdditionalInformation.intColumnsConfiguration = 1;
                objAdditionalInformation.intMapLabelContentPairsNumberOfColumns = 1;
                
                Map<String, String> mapLabelContent = new Map<String, String>();
				mapLabelContent.put('Green', objMdtRec.GREEN_1_POINTS__c);
				mapLabelContent.put('Yellow', objMdtRec.YELLOW_2_POINTS__c);
                mapLabelContent.put('Red', objMdtRec.RED_3_POINTS__c);

                objAdditionalInformation.mapLabelContentPairs = mapLabelContent;

                objRecord.objAdditionalInformation = objAdditionalInformation;

					
				objDataTable.lstRecordsCustomStructure.add(objRecord);

            }
            //We set the parent-child final mapping.
            objDataTable.mapParentChildRelationship = mapParentChildRelationship;

            system.debug('objDataTable return values'+objDataTable);
       // }
    
        return objDataTable;
    }

    //Input to the Risk assessment container to load the data in connectedcallback
    @AuraEnabled(cacheable = true)
    public static boolean getEngagementId(Id engagementId) {
        
        
        Engagement__c eng = [SELECT ID,Primary_IPU_Estimator_ID__c,Opportunity__r.Primary_IPU_Estimator__c FROM Engagement__c WHERE Id =: engagementId LIMIT 1];
        if(eng.Primary_IPU_Estimator_ID__c != null) {
            List<Estimation_Summary_Line__c> eslLst = [SELECT ID,Service_Name__c,Required_IPUs__c,Estimated_Quantity__c FROM Estimation_Summary_Line__c 
                                                        WHERE (Estimation_Summary__c =: eng.Primary_IPU_Estimator_ID__c OR Estimation_Summary__c =: eng.Opportunity__r.Primary_IPU_Estimator__c)
                                                        AND Service_Name__c LIKE '%Data Governance%' 
                                                        AND (Required_IPUs__c > 0 OR Estimated_Quantity__c >0)];

            if(!eslLst.isEmpty()) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    /**
    * Name: getEstimatorRec
    * Description: this method returns boolean based on the DG liness availability at ESL
    * Parameters: primartEstimatorId
    * returns boolean
    */

    @AuraEnabled(cacheable = true)
    public static boolean getEstimatorRec(Id primartEstimatorId, Id oppId){


        list<Opportunity> Oppty = [SELECT ID,Primary_IPU_Estimator__c FROM Opportunity WHERE Id =:oppId];

        List<Estimation_Summary_Line__c> eslLst = [SELECT ID,Service_Name__c,Required_IPUs__c,Estimated_Quantity__c FROM Estimation_Summary_Line__c 
                                                        WHERE (Estimation_Summary__c =: primartEstimatorId OR Estimation_Summary__c =: Oppty[0].Primary_IPU_Estimator__c) 
                                                        AND Service_Name__c LIKE '%Data Governance%' 
                                                        AND (Required_IPUs__c > 0 OR Estimated_Quantity__c >0)];

        if(!eslLst.isEmpty()) {
            return true;
        } else {
            return false;
        }
    }

    /**
    * Name: getParentRecValues
    * Description: this method returns Enagagement record Risk Assessment related to the plan
    * Parameters: parentId, planId
    * returns GlobalDataTableWrapperClass
    */
    @AuraEnabled
    public static GlobalDataTableWrapperClass getParentRecValues(Id parentId, Id planId) {
        String sobjectType;
        returnRecWrapper pafWrap = new returnRecWrapper();
        List<Risk_Assessment__c> pafRec = new List<Risk_Assessment__c>();
        List<string> fieldAPINames = new List<string>();
        GlobalDataTableWrapperClass objDataTable ;

        if (parentId != null) {
            pafWrap = getMdtRecords(parentId, planId);
            fieldAPINames = pafWrap.fieldAPIs;
            sobjectType = pafWrap.sobjectType;
        }

        if (parentId != null && sobjectType == 'Adoption_Factor__c' && planId != null) {
            pafRec = Database.query('SELECT ' + String.join(fieldAPINames, ',') + ' FROM Risk_Assessment__c WHERE (Engagement__c != null AND Engagement__r.Plan__c = :planId) ORDER BY Createddate DESC LIMIT 1');
        }

        if(pafRec != null && pafRec.size() > 0) {
            objDataTable = getTableStructure(pafRec[0]);
        } 

        return objDataTable;
    }

   /**
    * Name: getMdtRecords
    * Description: this method returns API names for score,comment and action from custom metadata values
    * Parameters: parentId, planId
    * returns:  wrapper class with fieldAPIs and SObject Type
    */
    static returnRecWrapper getMdtRecords(Id parentId,Id planId) {
        
        List<Risk_Assessment_Mapping__mdt> PFA_Custom_MDT = getMDTquery();
        
      

        String sobjectType;

        returnRecWrapper recWrap = new returnRecWrapper();
        
        if (parentId != null) {
            sobjectType = parentId.getSObjectType().getDescribe().getName();
        }

        //Risk_Assessment__c pafRec = new Risk_Assessment__c();
        List<Risk_Assessment__c> pafRec = new List<Risk_Assessment__c>();
        List<string> fieldAPINames = new List<string>();

        for (Risk_Assessment_Mapping__mdt recApiName: PFA_Custom_MDT) {
            fieldAPINames.add(recApiName.Score_Field_API_Name__c);
            fieldAPINames.add(recApiName.Comment_Field_API_Name__c);
            //fieldAPINames.add(recApiName.Action_Field_API_Name__c);
        }
        system.debug('parentId 273****'+parentId);
        if (sobjectType == 'Engagement__c' && parentId != null) {
            pafRec = Database.query('SELECT ' + String.join(fieldAPINames, ',') + ' FROM Risk_Assessment__c WHERE Engagement__c = :parentId ORDER BY Createddate DESC LIMIT 1');
        } else if (sobjectType == 'Adoption_Factor__c' && parentId != null) { 
            pafRec = Database.query('SELECT ' + String.join(fieldAPINames, ',') + ' FROM Risk_Assessment__c WHERE Adoption_Factor__c = :parentId ORDER BY Createddate DESC LIMIT 1');
        } 
        if(!pafRec.isEmpty() && pafRec != null) {
            recWrap.paf = pafRec[0];
        } else {
            recWrap.paf = null;
        }
            recWrap.fieldAPIs = fieldAPINames;
            recWrap.sobjectType = sobjectType;
        
        return recWrap;
    }

    /**
    * Name: getMDTquery
    * Description: this method return list of custom metadata records
    * Parameters: none
    * returns:  list of Risk_Assessment_Mapping__mdt;
    */
    public static List<Risk_Assessment_Mapping__mdt> getMDTquery() {

        return [SELECT Id,Area__c,IPU_Services__c,Risk_Assessment_SubCategory__c,Risk_Assessment_SubCategory__r.Risk_Assessment_Category__r.MasterLabel, Risk_Assessment_SubCategory__r.MasterLabel, Score_Field_API_Name__c, Comment_Field_API_Name__c ,Sort_Order__c,GREEN_1_POINTS__c,YELLOW_2_POINTS__c,RED_3_POINTS__c FROM Risk_Assessment_Mapping__mdt WHERE InActive__c = false Order By Sort_Order__c ASC];
    }

    /**
    * Name: generatePAFRecordData
    * Description: this method returns New Table with from custom metadata Records
    * Parameters: parentId, planId
    * returns:  GlobalDataTableWrapperClass
    */
    @AuraEnabled
    public static GlobalDataTableWrapperClass generatePAFRecordData(Id parentId, Id planId) {

        returnRecWrapper pafWrap = new returnRecWrapper();
        Risk_Assessment__c pafRec;
        system.debug('parent id controller'+parentId);
        if (parentId != null) {
            pafWrap = getMdtRecords(parentId, planId);
            pafRec = pafWrap.paf; 
        }
        
        List<Risk_Assessment_Mapping__mdt> PFA_Custom_MDT = getMDTquery();
        
       
            GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

            if(pafRec != null) {
                objDataTable = getTableStructure(pafRec);
            } else {
                objDataTable = getTableStructure(null);
            }
            

            system.debug('objDataTable return values'+objDataTable);
        return objDataTable;
    }
	
    /**
    * Name: saveRecords
    * Description: this method inserts/updates the values to the Risk Assessment Object as a record
    * Parameters: JSONString, parentId, isNewRec planId
    * returns:  none
    */
    @AuraEnabled
    public static void saveRecords(List<Map<string,string>> JSONString, Id parentId, Boolean isNewRec,Id planId) {
        system.debug('JSONString'+JSONString);
        if(JSONString == null) return;
        List<Map<string,string>> fieldWrapList = new List<Map<string,string>>();

        returnRecWrapper pafWrap = new returnRecWrapper();
        Risk_Assessment__c pafRec = new Risk_Assessment__c();

        /* if (parentId != null && !isNewRec) {
            pafWrap = getMdtRecords(parentId);
            pafRec = pafWrap.paf;
        } */

        String sobjectType;
        fieldWrapList = JSONString;

        if(parentId != null) {
            sobjectType = parentId.getSObjectType().getDescribe().getName();
        }
        
        if (parentId != null && !isNewRec) {
            pafWrap = getMdtRecords(parentId, planId);
            pafRec = pafWrap.paf;
        } else {
            pafRec = null;
        }
        
        Map<String,Risk_Assessment_Mapping__mdt> PFA_Custom_Map = new Map<String,Risk_Assessment_Mapping__mdt> (Risk_Assessment_Mapping__mdt.getall().values());
        Risk_Assessment__c pafnew;
        
        //Update Scenario
        if(pafRec != null && !isNewRec) {
            for(Map<string,string> fld : fieldWrapList) {
                
                List<String> idList = new List<String>(fld.keySet());
                //for(Integer i=0; i < idList.size(); i++) {

                    if(fld.containsKey('Score')) {
                        if(fld.get('Score') != null) {
                            pafRec.put(PFA_Custom_Map.get(fld.get('Id').left(15))?.Score_Field_API_Name__c,fld.get('Score'));
                        } 
                    }
                    if(fld.containsKey('Text_Area_Comment__c')) {
                        pafRec.put(PFA_Custom_Map.get(fld.get('Id').left(15))?.Comment_Field_API_Name__c,fld.get('Text_Area_Comment__c'));
                    }
                //}            
            }

            if (sobjectType == 'Engagement__c' && parentId != null){
                pafRec.Engagement__c = parentId;
            } else if (sobjectType == 'Adoption_Factor__c' && parentId != null) {
                pafRec.Adoption_Factor__c = parentId;
            }
        } else if(isNewRec || (!isNewRec && pafRec == null)) {
            pafnew = new Risk_Assessment__c();
            set<Id> fldIds = new set<Id>();
            for(Map<string,string> fld : fieldWrapList) {
                
                if(fld.containsKey('Score')) {
                    fldIds.add(fld.get('Id'));
                    if(fld.get('Score') != null) {
                        pafnew.put(PFA_Custom_Map.get(fld.get('Id').left(15))?.Score_Field_API_Name__c,fld.get('Score'));
                    } 
                } /* else {
                    pafnew.put(PFA_Custom_Map.get(fld.get('Id').left(15))?.Score_Field_API_Name__c,'1');
                } */
                if(fld.containsKey('Text_Area_Comment__c')) {
                    pafnew.put(PFA_Custom_Map.get(fld.get('Id').left(15))?.Comment_Field_API_Name__c,fld.get('Text_Area_Comment__c'));
                }
               
            }
            for(string mdtIds: PFA_Custom_Map.keySet()){
              
                if(!fldIds.contains(mdtIds)){
                   
                    pafnew.put(PFA_Custom_Map.get(mdtIds)?.Score_Field_API_Name__c,'1');
                }
            }
            if (sobjectType == 'Engagement__c' && parentId != null){
                pafnew.Engagement__c = parentId;
            } else if (sobjectType == 'Adoption_Factor__c' && parentId != null) {
                pafnew.Adoption_Factor__c = parentId;
            }
        }

        if(pafnew != null) {
            insert pafnew;
        }
        
 
        if(pafRec != null) {
            update pafRec;
        }
                
    }

    
    public class fieldWrapper {
        @AuraEnabled public IconWrapper icons;
        @AuraEnabled public ActionWrapper lstActions;
        @AuraEnabled public CellWrapper cells;
        @AuraEnabled public Id Id;//strRecordId
        @auraEnabled public boolean isSecondLevelParent;
        @AuraEnabled public String Category;
        @AuraEnabled public String SubCategory;
        @AuraEnabled public String SubCategoryId;
        @AuraEnabled public String Area;
        @auraEnabled public String categoryParentId;
        @AuraEnabled public String Comment;
        @AuraEnabled public String Action;
        @AuraEnabled public String Score;
        @AuraEnabled public map<string,string> mapScoreValueSTR;
        @AuraEnabled public map<string,string> mapScoreValueIMP;
        @AuraEnabled public String ipuServices;
       // @AuraEnabled public String DetailsOff;
        @AuraEnabled public String Green;
        @AuraEnabled public String Yellow;
        @AuraEnabled public String Red;
        @AuraEnabled public Map<String, String> mapStyles;
        @AuraEnabled public Boolean boolHasValidId;
        @AuraEnabled public Boolean boolCustomLayout;
        @AuraEnabled public Integer intRecordLayoutType;
        @AuraEnabled public Integer intColumnsConfiguration;
        @AuraEnabled public Integer intMapLabelContentPairsNumberOfColumns;
        @AuraEnabled public Map<String, String> mapLabelContentPairs; 
        @AuraEnabled public fieldWrapper objAdditionalInformation;
        @AuraEnabled public String categoryLabel;
    }
        //Icons wrapper class.
        public class IconWrapper {

            //Public variables.
            @AuraEnabled
            public Boolean boolIsStaticResource {get; set;}
            @AuraEnabled
            public Integer intWidth {get; set;}
            @AuraEnabled
            public String strIcon {get; set;}
            @AuraEnabled
            public String strURL {get; set;}
            //added for 2177
            @AuraEnabled
            public String strTitle {get; set;}
        }

        //Actions wrapper class.
	    public class ActionWrapper {

		    //Public variables.
            @AuraEnabled
            public Boolean boolHasSubactions {
                get {
                    Boolean boolResult = false;
                    if(lstSubactions != null && !lstSubactions.isEmpty()) {
                        boolResult = true;
                    }
                    return boolResult;
                }
            }
            @AuraEnabled
            public Boolean boolIsStaticResource {get; set;}
            @AuraEnabled
            public Integer intAction {get; set;}
            @AuraEnabled
            public Integer intWidth {get; set;}
            @AuraEnabled
            public String strIcon {get; set;}
            @AuraEnabled
            public String strInverseIcon {get; set;}
            @AuraEnabled
            public String strLabel {get; set;}
            @AuraEnabled
            public String strURL {get; set;}
            @AuraEnabled
            public String strInverseURL {get; set;}
            @AuraEnabled
            public List<ActionWrapper> lstSubactions {get; set;}
        }
        //Cell wrapper class.
        public class CellWrapper {

            //Public variables.
            @AuraEnabled
            public String strValue {get; set;}
            @AuraEnabled
            public String strStyle {get; set;}
            
            /*
            Method Name : CellWrapper
            Description : Constructor of the class.
            Parameters	 : String, called from getRecords, strRecordId Record Id.
            Return Type : None
            */
            public CellWrapper(String strValue) {
                this.strValue = strValue;
                strStyle = 'width: 50%';
            }
        }

        public class returnRecWrapper {
            @AuraEnabled public Risk_Assessment__c paf;
            @AuraEnabled public List<string> fieldAPIs;
            @auraEnabled public String sobjectType;
        }
}