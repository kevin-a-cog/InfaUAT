/****************************************************************************************************************************
 *  @Class Name: PRMProductHandlerUtility
 *  @Author: Deloitte
 *  @Date: 2017-12-06 
 *  @Description:This is a utility class which helps in method inheritance concept of programming while Adding/Removing Products in PRM. 
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public class PRMProductHandlerUtility
{
    @AuraEnabled public String productrefId;
    @AuraEnabled public String productrefName;       
    @AuraEnabled public string orgID;
    @AuraEnabled public string ipAddress;
    @AuraEnabled public string hostName;
    @AuraEnabled public string reqType;
    @AuraEnabled public string Comments;
    @AuraEnabled public string LicenseKeyOrgID;
    @AuraEnabled public string requestupdatedkey;
    @AuraEnabled public Boolean reqFieldsYes;
    @AuraEnabled public string statusMsg;
        
    public PRMProductHandlerUtility(){
    	orgID = '';
        ipAddress = '';
        hostName = '';
        reqType = '';
        Comments = '';
        LicenseKeyOrgID = '';
        requestupdatedkey = '';
        reqFieldsYes = false;
        statusMsg = '';
    }
    
    /** 
    * Get Fields in specified FieldSet
    * @Method Name- getFieldDetails
    * @param typeName - SObject Name (i.e. Account, Contact, Opportunity, etc.)
    * @param fsName - FieldSet Name 
    * @return List of FieldSetMember Object 
    */
    
    public static List<FieldSetMember> getFieldDetails(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
        
        return fset;
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
    
    /* this method helps in returning the Controlling field values(as Key) and Dependent field Values(as Values) of dependent picklists
    * @Method Name- getDependentOptionsImpl
    * @param parameter- string objApiName,contrfieldApiName,depfieldApiName
    * @return return- Map<String, List<String>>
    * @throws exception-n/a
    */
    
    public String validFor;    
    public static Map<String, List<String>> getDependentPicklistValues(String objApiName, String contrfieldApiName, String depfieldApiName)
    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult contrfieldApiNameInfo = describeResult.fields.getMap().get(contrfieldApiName).getDescribe();
        Schema.DescribeFieldResult depfieldApiNameInfo = describeResult.fields.getMap().get(depfieldApiName).getDescribe();

        List<Schema.PicklistEntry> controllingValues = contrfieldApiNameInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = depfieldApiNameInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            PRMProductHandlerUtility info = (PRMProductHandlerUtility) JSON.deserialize(jsonString, PRMProductHandlerUtility.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            Integer baseCount = 0;

        for(Integer curr : hexString.getChars())
        {
            Integer val = 0;

            if(curr >= 65)
            {
                val = curr - 65 + 10;
            }
            else
            {
                val = curr - 48;
            }

            if((val & 8) == 8)
            {                
                controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
            }
            if((val & 4) == 4)
            {               
                controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 2) == 2)
            {               
                controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 1) == 1)
            {               
                controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
            }

            baseCount += 4;
        }            
    } 

    //System.debug('ControllingInfo: ' + JSON.serializePretty(controllingInfo));
    return controllingInfo;
    }
	
    /** 
    * Get picklist values
    * @Method Name- getPicklistValues
    * @param objApi - SObject Name (i.e. Account, Contact, Opportunity, etc.)
    * @param fieldApi - picklist field API name 
    * @return List of picklist values 
    */
    public static List<SelectOption> getPicklistValues(String obj, String fld) 
    {
        list<SelectOption> options = new list<SelectOption>();

        // Get the object type of the SObject.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   

        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 

        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();

        for (Schema.PicklistEntry f: values) 
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
      return options;
    }
    
    public class SelectOption 
    {
        public SelectOption(String value, String label) 
        {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        public SelectOption(String value, String label, Boolean isDisabled) 
        {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }

        @AuraEnabled public String label { get;set; }
        @AuraEnabled public String value { get;set; }
        @AuraEnabled public Boolean disabled { get;set; }
        @AuraEnabled public Boolean escapeItem { get;set; }

    }
    
    /** 
    * Get prm product family values
    * @Method Name- prmProductFamilySet
    * @return Set of prm product family values 
    */
    public static Set<String> prmProductFamilySet()
    {
        Set<String> prodFamilySet = new Set<String>();
        
        for(PRM_Custom_Data_Settings__mdt metadata : [SELECT PRM_Product_Families__c from PRM_Custom_Data_Settings__mdt limit 1])
        {
          if(metadata.PRM_Product_Families__c != null && metadata.PRM_Product_Families__c != ''){
              prodFamilySet.addAll(((metadata.PRM_Product_Families__c).deleteWhitespace()).split(','));
          }
        }
        
        return prodFamilySet;
    }
}