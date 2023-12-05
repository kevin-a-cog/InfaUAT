/*
 * Name         :   HelpLearningPathDisplayTest
 * Author       :   Prashanth Bhat
 * Created Date :   15 SEP 2023
 * Description  :   Test Class for HelpLearningPathDisplay

 Change History
 **********************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                                   Tag
 **********************************************************************************************************************************************
 Prashanth Bhat         15 SEP 2023     I2RT-6205           Product Community: Bringing Learning Path in the Product detail Page          N/A
 
*/

@isTest
public class HelpLearningPathDisplayTest {
    
    Static testmethod void testGetLearningPathURL(){
        Test.startTest();
        String learningPathURL1 = HelpLearningPathDisplay.getLearningPathURL('0TO6S000000JAAOWA4'); //Existing metadata value
        String learningPathURL2 = HelpLearningPathDisplay.getLearningPathURL('0TO6S000000JAAOWA5'); //Data does not exists to return null
        Test.stopTest();
        Assert.isNotNull(learningPathURL1);
        Assert.isNull(learningPathURL2);
    }
}