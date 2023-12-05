@isTest(seeAlldata=false)
private class BatchExecutorhelperTest {
    @isTest
    private static void testhelper(){
        Test.startTest();
        List<String> slist = BatchExecutorhelper.getApexClasses();
        String bid = BatchExecutorhelper.executeclass(slist[0]);
        BatchExecutorhelper.getStatus(bid);
        Test.stopTest();
    }
}