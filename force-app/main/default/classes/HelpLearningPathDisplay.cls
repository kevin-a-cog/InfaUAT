/*
Class             : HelpLearningPathDisplay
@Author           : Prashanth Bhat
@Created Date     : 15 SEP 2023
@Description      : Bringing Learning Path in the Product detail Page 
@Test Coverage by : HelpLearningPathDisplayTest

 Change History
 **********************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                                   Tag
 **********************************************************************************************************************************************
 Prashanth Bhat         15 SEP 2023     I2RT-6205           Product Community: Bringing Learning Path in the Product detail Page          N/A

*/
public class HelpLearningPathDisplay {
   
    /*
    I2RT-6205   : Product Community: Bringing Learning Path in the Product detail Page
    Method Name : getLearningPathURL
    Description : This method is used to get the Learning Path URL of success portal stored in CM for the specific community.
    Parameters	: String (Community/Topic Id)
    Return Type : String (Learning Path URL for mapped Community)
    */
    @AuraEnabled(cacheable=true)
    public static String getLearningPathURL(String commId){
        try{      
            String developerName = 'X'+commId;
            helpLearningPathDisplay__mdt helpLearningPath = helpLearningPathDisplay__mdt.getInstance(developerName);
            if(helpLearningPath != null && helpLearningPath.LearningPathURL__c != null){
                String learningPathURL = helpLearningPath.LearningPathURL__c;
                return learningPathURL;
            }
            else{
                return null;
            }
        }
        catch(Exception exp){
             System.debug('Error occured in HelpLearningPathDisplay.getLearningPathURL'+exp.getMessage());
             return null;
        }
    }
}