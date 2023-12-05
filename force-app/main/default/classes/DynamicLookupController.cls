/*
Class:          DynamicLookupController 
@Author:        Anil Solanki 
@Created Date:  10/4/2018
@Description:   Controller class for DynamicLookup Lighting component
                This controller holds method for dynamically quering contacts/account product based on the record id from the where the lighting component is called.
*/
public with sharing class DynamicLookupController {
    
    public static globalApexManager GAM = new globalApexManager();
    public final static String CONTACTOBJECTTYPE = 'Contact';
    public final static String CONTACTOBJECTFIELDSET = 'Add_LOB_Contacts';
    public final static string CSMCUSTOMPERMISSION ='CSMUser';

    @AuraEnabled
    public static boolean hasCSMPermission()
    {
    
     CustomPermissionsReader csm = new CustomPermissionsReader();// to check the user has CSM user permission
     
     system.debug(csm.hasPermission(CSMCUSTOMPERMISSION) );
       return csm.hasPermission(CSMCUSTOMPERMISSION) ;
       
       
    }
    

    /* this method fetches record in Contact/Account Product search bar based on keyword
    * @param parameter-String searchKeyWord,String pillsList, String fieldQry, Id recordId, String objectType
    * @return return- List<sObject>
    * @throws exception-n/a
    */
    @AuraEnabled 
    public static List<sObject> contactSearchBar(String searchKeyWord,String pillsList, String fieldQry,Id recordId, String objectType){
        String searchKey = '%' + String.escapeSingleQuotes(searchKeyWord) + '%';
        String fields=String.escapeSingleQuotes(fieldQry);
        List<Contact> contactList = new List<Contact>();
        List<Account_Product__c> accProductList = new List<Account_Product__c>();
        //List<Success_Contact__c> existingLObContacts = new List<Success_Contact__c>();
        List<sObject> objList = new List<sObject>();
        String SOQL1 = '';
                Id accountId = [Select Account__r.Id from Account_LOB__c where Id =: recordId].Account__r.Id;
                List<Success_Contact__c> existingLObContacts = [Select Id,Name,Contact__r.Id from Success_Contact__c where Line_of_Business__c =: recordId];
                Set<Id> contactIds = new Set<Id>();
                
                for(Success_Contact__c existingLObCont : existingLObContacts){
                    contactIds.add(existingLObCont.Contact__r.Id);
                }
            
            if(searchKeyWord == NULL || String.ISBLANK(searchKeyWord)){

                SOQL1 = 'Select ' + fields + ' from Contact where AccountId =: accountId AND Id NOT IN:contactIds order by Name';
            }
            
            
            else{
               
               SOQL1 = 'Select ' + fields + ' from Contact Where Name LIKE :searchKey AND AccountId =: accountId  AND Id NOT IN:contactIds order by Name';
            }
            
            GAM.CreateLogs('contactSearchBar','SOQL1:','contact SOQL',SOQL1);
            contactList = Database.query(SOQL1); 
            
           //@26-06 Added this part to avoid user to select same pills again.
            GAM.CreateLogs('opportunityUpdate','pillsList: '+pillsList);
            updateSelected(pillsList,contactList,null,objectType);
            
            try {
                GAM.InsertDebugLogs();  
            } catch(Exception e){
                for(Contact contact : contactList){
                    GAM.CreateExceptionRecords('contactSearchBar', e.GetMessage(), contact.Id);
                }
            }
            objList = contactList;
        return objList;
        
    }
    
   /** 
    * Get Fields in specified FieldSet
    * @param typeName - SObject Name (i.e. Account, Contact, Opportunity, etc.)
    * @param fsName - FieldSet Name 
    * @return List of FieldSetMember Object 
    */
    @AuraEnabled
    public static List<FieldSetMember> getFields(String recordId) {
        Schema.SObjectType targetType;
        Schema.FieldSet fs;
        targetType = Schema.getGlobalDescribe().get(CONTACTOBJECTTYPE); 
        
        
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        fs = fsMap.get(CONTACTOBJECTFIELDSET);

        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
        
        return fset;
    }
    
    /* this method will Update the selected Contacts/AccoutProducts 
    * @param parameter- String pillsList,List<Contact> lstContactRecords, List<Account_Product__c> lstAccountProductRecords
    * @return return- void
    * @throws exception-n/a
    */
    
    public static void updateSelected(String pillsList,List<Contact> lstContactRecords,List<Account_Product__c> lstAccountProductRecords,String objectType){
        List<Contact> pillsListSelected = (List<Contact>)System.JSON.deserialize(pillsList,List<Contact>.class);
        for(Contact objlstContactRecords:  lstContactRecords){
                for(Contact pill:pillsListSelected){
                    if(objlstContactRecords.Id == pill.Id){
                        objlstContactRecords.Is_Selected__c = true;
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
    
     /** 
* Method will return role for  selected contacts
* @param Name - n/a
* @throws exception -n/a
* @return list<Picklist Option>
*/
    @AuraEnabled
    public static List<PicklistOptions> getRoleSelect () {
        List<PicklistOptions> lobContactRoles = new List<PicklistOptions>(); 
        
        // Add empty option 
        PicklistOptions emptyOption = new PicklistOptions ('--None--', '--None--'); 
        lobContactRoles .add(emptyOption); 
        
        // Add actual piclist entries 
        Schema.DescribeFieldResult fieldResult = Success_Contact__c.Role__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        
        for (Schema.PicklistEntry f : ple) {
            lobContactRoles.add(new PicklistOptions(f)); 
        }
        
        return lobContactRoles; 
    }
    
    
    public class PicklistOptions {
        
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}
        
        public PicklistOptions (Schema.PicklistEntry p) {
            this.value = p.getValue(); 
            this.label = p.getLabel(); 
        }
        
        public PicklistOptions (String v, String l) {
            this.value = v; 
            this.label = l; 
        }
    }
    
    /*Method to save LOB contacts/Related Account Product Records.
    * @param Name - String LOBrecords, String recordId, String role, String ObjType
    * @throws exception -n/a
    * @return list<Picklist Option>
    */
    @AuraEnabled
    public static void saveSelectedLOBContacts(string lobContactRecords,String lobId, String role, String objType) {
        List<Success_Contact__c> lobContactLst;              
        List<Contact> lstlobContactRecords = (List<Contact>)System.JSON.deserialize(lobContactRecords,List<Contact>.class);
            Map<String, String> roleMap = (Map<String, String>)System.JSON.deserialize(role,Map<String,String>.class); 
            
            //Perform Operation with records 
            lobContactLst = new List<Success_Contact__c>();
            GAM.CreateLogs('saveSelectedLOBContacts',lobContactLst,'LOBContacts');
            for(Contact objlobContactRecords : lstlobContactRecords ) {          
                Success_Contact__c  lobContactRec = new Success_Contact__c();
                lobContactRec.Line_of_Business__c  = lobId;
                lobContactRec.Contact__c  = objlobContactRecords.Id;
                
                // Assign value toRole
                String roleValue = roleMap.get(objlobContactRecords.Id); 
                if (roleValue != '--None--') 
                    lobContactRec.Role__c  = roleValue; 
                else 
                    lobContactRec.Role__c  = ''; 
                
                    lobContactLst.add(lobContactRec);
            }
            
            GAM.CreateLogs('saveSelectedLOBContacts',lobContactLst,'LOBContacts');
            try {
                insert lobContactLst;
            } catch (System.DmlException e) {
                GAM.CreateExceptionRecords('saveSelectedLOBContacts', e.GetMessage(),'error while inserting lobContactLst');
            }
    }
    
    @AuraEnabled
    public static String getObjectType(string recordId) {
    
        String objectName = '';
        try{
            SObjectType objType  = Id.valueOf(recordId).getSobjectType();
            objectName = objType.getDescribe().getName();
        }catch(Exception e){
            GAM.CreateExceptionRecords('getObjectType', e.GetMessage(), objectName);
        }
    
    return objectName;
     }
    
}