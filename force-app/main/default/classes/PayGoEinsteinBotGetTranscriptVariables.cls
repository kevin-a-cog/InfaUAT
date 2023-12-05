/*
Class:              PayGoEinsteinBotGetTranscriptVariables
@Author:            Madhu Shanthappa
@Created Date:      9-Sep-2023
@Description:       I2RT-8961:To search save the exits contact record based on email id from transcript record
@TestClass:         PayGoEinsteinBotTest
Change History:
******************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                    Tag
******************************************************************************************************************************
*/
public class PayGoEinsteinBotGetTranscriptVariables {
    public static globalApexManager GAM = new globalApexManager();
    /*  
    Class Name  : TranscriptInput
    Description : Create a wrapper class for Transcript record Input
    */
    public class TranscriptInput{
        @InvocableVariable(required=true)
        public ID routableID;
    }
    /*  
    Class Name  : CustomerDetailOutput
    Description : Create a wrapper class for Customer Detail Output
    */
    public class CustomerDetailOutput{
        @InvocableVariable(required=true)
        public String firstName;
        @InvocableVariable(required=true)
        public String lastName;
        @InvocableVariable
        public String customerJourney;
    }
    /*  
    Method Name : getUserDetails
    Description : To search save the exits contact record based on email id from transcript record
    Parameters   : String Menu
    Return Type : CustomerDetailOutput
    */ 
    @InvocableMethod(label='Get PayGo Einstein Transcript Variables')
    public static List<CustomerDetailOutput> getUserDetails(List<TranscriptInput> transcripts){
        
        String emailId;
        Id recId;
        List<CustomerDetailOutput> details = new List<CustomerDetailOutput>();
        List<Contact> contactList = new List<Contact>();
        
        for (TranscriptInput transcript : transcripts) {
            LiveChatTranscript transcriptRecord = [SELECT Id, First_Name__c, Email__c, Last_Name__c, Customer_Journey__c
                                            FROM LiveChatTranscript 
                                            WHERE Id = :transcript.routableID 
                                            LIMIT 1];
            
            CustomerDetailOutput customerData = new CustomerDetailOutput();
            customerData.firstName = transcriptRecord.First_Name__c;
            customerData.lastName = transcriptRecord.Last_Name__c;
            customerData.customerJourney = transcriptRecord.Customer_Journey__c;
            details.add(customerData);
            emailId = transcriptRecord.Email__c;
            recId = transcriptRecord.Id;
        }
        If(!String.isBlank(emailId)){
            contactList = [SELECT Id FROM Contact WHERE Email =:emailId LIMIT 1];
            if(!contactList.isEmpty()){
                LiveChatTranscript transcriptRec = new LiveChatTranscript();
                transcriptRec.Id = recId;
                transcriptRec.ContactId = contactList[0].Id;
                try{
                    update transcriptRec;
                }catch(Exception e){
                    GAM.CreateExceptionRecords('PayGoEinsteinBotGetTranscriptVariables.getUserDetails',e.getMessage(), 'recordFailed'); 
                }  
            }
        }
        return details;
    }
}