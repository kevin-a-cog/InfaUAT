/*
    @created by       : Isha Bansal
    @created on       : 03/29/2023
    @Purpose          : Controller class for change owner component
    @Testclass        : ChangeRecordOwnerTest
    @JIRA             : I2RT - 6727    
 Change History
 ****************************************************************************************************************
 ModifiedBy         Date        Jira No.    Tag                         Description										Tag no 
 */
public with sharing class ChangeRecordOwner {
   

    @AuraEnabled
    public static SobjectWrapper getObjectSpecificLabel(String recordId){
        String label = 'Change Record Owner';//default value;
        Id myRecordId = Id.valueOf(recordId);
        String sObjName = myRecordId.getSObjectType().getDescribe().getLabel(); 
        String sObjAPIName = myRecordId.getSObjectType().getDescribe().getName(); 
        if(String.isNotBlank(sObjName)) {     
        label='Change '+sObjName + ' Owner';
        }
        return new SobjectWrapper(label,sObjAPIName);
       // return wrapobj;
    }
    
    public class SobjectWrapper{
        @AuraEnabled
        public String changeOwnerLabel{get;set;}
        @AuraEnabled
        public String objAPIName{get;set;}
        public SobjectWrapper(String changeOwnerLabel,String objAPIName)
        {
            this.changeOwnerLabel=changeOwnerLabel;
            this.objAPIName=objAPIName;
        }
        
    }
}