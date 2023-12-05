@IsTest
public class FlowSwitchControllerTest {
    
    @IsTest
    private static void recursionCheckTest(){

        List<String> flowName = new List<String>{'AutoCloseCase'};

        Test.startTest();
            List<Boolean> resultList = FlowSwitchController.recursionCheck(flowName);
            System.assertEquals(false, resultList[0],'recursionCheckTest Failed : Recursion Found');
        Test.stopTest();
    }
}