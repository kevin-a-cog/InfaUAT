/*
Class:              PayGoEinsteinBotAnswer
@Author:            Madhu Shanthappa & Sandeep Duggi
@Created Date:      11-Sep-2023
@Description:       I2RT-8961:To get the answer data dynamically from custom metadata.
@TestClass:         PayGoEinsteinBotTest
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************

*/
public class PayGoEinsteinBotAnswer {
    /*  
	 Class Name  : AnswerOutput
	 Description : Create a wrapper class for answer output
	*/
    public class AnswerOutput {
    @InvocableVariable(required=true)
    public String answer;

    @InvocableVariable(required=true)
    public Boolean isQuestion;
  }
    /*  
	 Method Name : getAnswer
	 Description : This method returns answer data based on the selected menu
                   Called as Invocable from Einstein bot for Paygo
	 Parameters	 : String Menu
	 Return Type : wrapper class of answer data
	*/  
    @InvocableMethod(label='Get PayGo Einstein Answer')
    public static List<AnswerOutput> getAnswer(List<String> selectedMenu) {

        List<AnswerOutput> answerDetails = new List<AnswerOutput>();

        for(PayGo_EinsteinBot_Configurations__mdt objRecord : [SELECT Answer__c, Is_Question_Answer__c 
                                                          FROM PayGo_EinsteinBot_Configurations__mdt
                                                          WHERE Menu_Item__c =: selectedMenu
                                                          LIMIT 1]){
            AnswerOutput answerData = new AnswerOutput();
            answerData.answer = objRecord.Answer__c;
            answerData.isQuestion = objRecord.Is_Question_Answer__c;
            answerDetails.add(answerData);
        }
        
        return answerDetails;
    }
}