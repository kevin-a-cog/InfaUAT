/*
Class:          DynamicLookupController 
@Author:        Anil Solanki 
@Created Date:  10/4/2018
@Description:   Controller class for DynamicLookup Lighting component
                This controller holds method for dynamically quering contacts/account product based on the record id from the where the lighting component is called.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
 Chandana Gowda			17-Apr-2019                        Made the class generic to use the same component on
														   multiple objects
 Chandana Gowda			10-Oct-2019       AR-970		   Added the  callmethod to check for has permission 	 T1
														   given the list of custom permissions		
 Chandana Gowda         30-Oct-2019       AR-1016          Modified the method contactSearchBar to include the
                                                           filter criteria for the records queried               T2
 Chandana Gowda         20-Jan-2019       AR-1016          Using the List variable in Dynamic SOQL instead of    T3
                                                           expanding as a String                                                                                                             
*************************************************************************************************************************************
*/
public with sharing class genericLookupChildController {
    
    public static globalApexManager GAM = new globalApexManager();
    public final static string CSMCUSTOMPERMISSION ='CSMUser';

    /*Method to check the user has CSM user permission.
    * @param Name - n/a
    * @throws exception -n/a
    * @return boolean
    
    @AuraEnabled
    public static boolean hasCSMPermission(){
        System.debug('In without Parameter.....');
        customPermissionsReader csm = new customPermissionsReader();// to check the user has CSM user permission
        return csm.hasPermission(CSMCUSTOMPERMISSION) ;       
    }    */ 
    @AuraEnabled
    public static boolean hasCSMPermission(List<String> lstCustomPermissions){
        customPermissionsReader csm = new customPermissionsReader();// to check the user has CSM user permission
        //------------------------------------------------------------------------------<T1> 
        //Checking if the user has permission given the list of custom permission
        if(!lstCustomPermissions.isEmpty())
        	return csm.hasPermission(lstCustomPermissions) ;
        //Checking if the user has CSMUser Custom permission assigned
        else
           return csm.hasPermission(CSMCUSTOMPERMISSION) ;
        //------------------------------------------------------------------------------<T1>
    }    
    /*Method to fetch data from the custom metadaa record.
    * @param Name - mdtRecord
    * @throws exception -n/a
    * @return Generic_Lookup__mdt---metadata record
    */
    @AuraEnabled
    public static Generic_Lookup__mdt getParams(String mdtRecord){        
        
        Generic_Lookup__mdt Rec=Database.query('Select Child1Object__c,Child1ParentField__c,Child2ParentField__c,Child1JunctionSourceObjField__c,fieldSetName__c,JunctionField1__c,JunctionField1SourceObj__c,JunctionField2__c,JunctionObject__c,ParentObj__c,searchFieldName__c,Filter_Criteria__c from Generic_Lookup__mdt where Label =\''+String.escapeSingleQuotes(mdtRecord)+'\'');
        //System.debug(Rec);
        return Rec;
            
    }

    /*Method to get the relationship name of the field given the lookup field Api name.
    * @param Name - String Child2Object,String Child2ParentField
    * @throws exception -n/a
    * @return list<String>
    */ 
    @AuraEnabled
    public static String getRelationshipNames(String Child2Object,String Child2ParentField){
        
        String relatonshipNames; 
        relatonshipNames=Schema.getGlobalDescribe().get(Child2Object).getDescribe().fields.getMap().get(Child2ParentField).getDescribe().getRelationshipName();
        return relatonshipNames;
    }       

    /* this method fetches record in the object based on the keyword in the search keyword
    * @param parameter-String searchKeyWord,String pillsList, String fieldQry, Id recordId, String objectType
    * @return return- List<sObject>
    * @throws exception-n/a
    */
    @AuraEnabled 
    public static List<sObject> contactSearchBar(String searchKeyWord,List<sObject> pillsList, String fieldQry,Id Child2Id, String Child2Object,String Child2ParentRelationship,String Child1JunctionSourceObjField,String JunctionObject,String Child1Object,String Child1ParentField,String searchFieldName,String JunctionField2,String JunctionField1,String Child2ParentField,String JunctionField1SourceObj,String filterCriteria){
        System.debug(filterCriteria);
        
        String searchKey = '%' + searchKeyWord + '%';
        List<sObject> objList = new List<sObject>();
        String SOQL1 = '';
		
		//fetching the Id of the parent record
        SOQL1 = 'Select '+String.escapeSingleQuotes(Child2ParentRelationship)+'.Id from '+String.escapeSingleQuotes(Child2Object)+' where Id = \''+String.escapeSingleQuotes(Child2Id)+'\'';
		SObject parentSobj=Database.query(SOQL1);
		String parentId= (String)parentSobj.get(Child2ParentField);
		
		//fetching the existing JunctionField1SourceObj records 
        SOQL1 = 'Select '+String.escapeSingleQuotes(JunctionField1)+' from '+String.escapeSingleQuotes(JunctionObject)+' where '+String.escapeSingleQuotes(JunctionField2)+' = \''+String.escapeSingleQuotes(Child2Id)+'\'';
		List<SObject> existingChildRecs= Database.query(SOQL1);
		
		List<ID> childIds = new List<ID>();
		for(SObject existingChild : existingChildRecs){
			childIds.add((ID)existingChild.get(JunctionField1));
		}		
		//when the JunctionField1SourceObj does not exists
        //-----------------------------------------------------------------------------<T2>
       if(JunctionField1SourceObj == NULL || String.ISBLANK(JunctionField1SourceObj)){
            SOQL1='Select '+String.escapeSingleQuotes(fieldQry)+' from '+String.escapeSingleQuotes(Child1Object)+' WHERE ';
            
            if(filterCriteria != NULL || !String.ISBLANK(filterCriteria)){
                SOQL1+=filterCriteria+' AND ';
            }

            SOQL1+=String.escapeSingleQuotes(Child1ParentField)+' = \''+String.escapeSingleQuotes(parentId)+'\' AND Id NOT IN :childIds'; //<T3/>

            if(searchKeyWord != NULL || !String.ISBLANK(searchKeyWord)){
                SOQL1+=' AND '+String.escapeSingleQuotes(searchFieldName)+' LIKE \''+String.escapeSingleQuotes(searchKey)+'\'';
            }

            SOQL1+=' order by '+String.escapeSingleQuotes(searchFieldName);          
        }

		else{
            //fetching the Ids of JunctionField1SourceObj records related to Child1Object
            SOQL1 = 'Select '+String.escapeSingleQuotes(Child1JunctionSourceObjField)+' from '+String.escapeSingleQuotes(Child1Object)+' where '+String.escapeSingleQuotes(Child1ParentField)+' = \''+String.escapeSingleQuotes(parentId)+'\'AND '+String.escapeSingleQuotes(Child1JunctionSourceObjField)+' NOT IN :childIds';
            List<SObject> JunObjRec= Database.query(SOQL1);
		    system.debug('value of JunObjRec>'+JunObjRec);
			List<ID> JunctionField1SourceObjIds = new List<Id>();
			for(SObject existingChild : JunObjRec){
				JunctionField1SourceObjIds.add((ID)existingChild.get(JunctionField1));
			}

            SOQL1='Select '+String.escapeSingleQuotes(fieldQry)+' from '+String.escapeSingleQuotes(JunctionField1SourceObj)+' WHERE ';            
            if(filterCriteria != NULL || !String.ISBLANK(filterCriteria)){
                SOQL1+=filterCriteria+' AND ';
            }
            SOQL1+='Id IN :JunctionField1SourceObjIds';
            if(searchKeyWord != NULL || !String.ISBLANK(searchKeyWord)){
                SOQL1+=' AND '+String.escapeSingleQuotes(searchFieldName)+' LIKE \''+String.escapeSingleQuotes(searchKey)+'\'';
            }
            SOQL1+=' order by '+String.escapeSingleQuotes(searchFieldName);            
        }
        //-----------------------------------------------------------------------------</T2>
        GAM.CreateLogs('contactSearchBar','SOQL1:','contact SOQL',SOQL1);
         objList = Database.query(SOQL1); 
         GAM.CreateLogs('opportunityUpdate','pillsList: '+pillsList);
        updateSelected(pillsList,objList,Child2Object);
           
        try {
            GAM.InsertDebugLogs();  
        } 
		catch(Exception e){
            for(sObject contact : objList){
                GAM.CreateExceptionRecords('contactSearchBar', e.GetMessage(), contact.Id);
            }
        }			
		
        return objList;
    }
    
   /** 
    * Get Fields in specified FieldSet
    * @param typeName - String Child1Object,String fieldSetName,String JunctionField1SourceObj
    * @param fsName - FieldSet Name 
    * @return List of FieldSetMember Object 
    */
    @AuraEnabled
    public static Map<String,List<String>> getFields(String Child1Object,String fieldSetName,String JunctionField1SourceObj) {
        Schema.SObjectType targetType;
        Schema.FieldSet fs;
        Map<String,List<String>> mapTypefields=new Map<String,List<String>>();
        
        //fetching the fieldset of JunctionField1SourceObj if it exists
        if(JunctionField1SourceObj == NULL || String.ISBLANK(JunctionField1SourceObj))
        	targetType = Schema.getGlobalDescribe().get(Child1Object); 
        else
        	targetType = Schema.getGlobalDescribe().get(JunctionField1SourceObj);
        
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
		
        fs = fsMap.get(fieldSetName);
        
		
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        if(fieldSet != NULL){
            for(Schema.FieldSetMember fsMember:fieldSet){
                List<String> lst= new List<String>();
                lst.add(fsMember.getLabel());
                lst.add(String.valueOf(fsMember.getType()));
                mapTypefields.put(fsMember.getFieldPath(),lst);
            }
        }
        
        return mapTypefields;
    }
    
    /* this method will Update the selected records 
    * @param parameter- String pillsList,List<sObject> lstContactRecords,String objectType
    * @return return- void
    * @throws exception-n/a
    */
    
    public static void updateSelected(List<sObject> pillsList,List<sObject> lstContactRecords,String objectType){
        //List<sObject> pillsListSelected = (List<sObject>)System.JSON.deserialize(pillsList,List<sObject>.class);
            for(sObject objlstContactRecords:  lstContactRecords){
                for(sObject pill:pillsList){
                    if(objlstContactRecords.Id == pill.Id){
                        objlstContactRecords.put('Is_Selected__c' ,true);
                    }
                }
            }
    }
    
    public class FieldSetMember {
        
        @AuraEnabled public Boolean DBRequired {get; set;}
        @AuraEnabled public String fieldPath {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public Boolean required {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String productFieldName {get; set; }
        
        public FieldSetMember(Schema.FieldSetMember f){
            this.DBRequired = f.getDbRequired(); 
            this.fieldPath = f.getFieldPath(); 
            this.label = f.getLabel(); 
            this.required = f.getRequired(); 
            this.type = '' + f.getType(); 
        }
    }

    
    /*Method to save the selected records.
    * @param Name - List<sObject> lobContactRecords,String Child2Id, String Child2Object,String JunctionField2,String JunctionField1,String JunctionObjec
    * @throws exception -n/a
    * @return list<Picklist Option>
    */
       @AuraEnabled
    public static void saveSelectedLOBContacts(List<sObject> lobContactRecords,String Child2Id, String Child2Object,
												String JunctionField2,String JunctionField1,String JunctionObject) {
		List<Sobject> gpRelatedRecLst;
		
           
            //Perform Operation with records 
            gpRelatedRecLst = new List<sObject>();
            GAM.CreateLogs('saveSelectedLOBContacts',gpRelatedRecLst,'gpRelatedRecLst');
            for(sObject gpRelatedRec : lobContactRecords ) {          
                sObject  childRec = Schema.getGlobalDescribe().get(JunctionObject).newSObject();
                childRec.put(JunctionField2,Child2Id);
                childRec.put(JunctionField1,gpRelatedRec.Id);
                                
				gpRelatedRecLst.add(childRec);
            }
            
            GAM.CreateLogs('saveSelectedLOBContacts',gpRelatedRecLst,'gpRelatedRecLst');
            try {
                insert gpRelatedRecLst;
            } catch (System.DmlException e) {
                GAM.CreateExceptionRecords('saveSelectedLOBContacts', e.GetMessage(),'error while inserting gpRelatedRecLst');
            }			
     
    }
}