@isTest
public class HelpHotfixControllerTest {

    @isTest
    public static void getDownloadsTest(){
        Map<String,List<String>> filterMap = new Map<String,List<String>>{'product' => new List<String>{'Active'},
            															  'operatingSystem' => new List<String>{'Windows'},
                                                                          'processor' => new List<String>{'x86'}};
        String filterString = JSON.serialize(filterMap);
        Test.startTest();
        HelpHotfixController.getDownloads(filterString,'active','ASC', 'Current','10');
        Test.stopTest();
    }
    
    @isTest
    public static void getMetadataRecordFromCustomLabelTest(){
        Test.startTest();
        HelpHotfixController.getMetadataRecordFromCustomLabel('test');
        HelpHotfixController.getMetadataRecordFromCustomLabel('');
        Test.stopTest();
    }
}