@isTest(seeAllData = true)
public class createNavigationalTopicsTest {
    
    @isTest(seeAllData = true)
    static void navigationalTopicsScriptTestDebugMode() {
        String jsonData = '[{"topic":"Test Parent 1","child":[{"topic":"Test Child 1","child":[{"topic":"Test Child 1.1"}]},{"topic":"Test Child 2","child":[{"topic":"Test Child 2.1"}]}]}]';
        createNavigationalTopics.navTopics navTopicsListChild = new createNavigationalTopics.navTopics('test Topic', null);
        //List<createNavigationalTopics.navTopics> navTopicsList = new List<createNavigationalTopics.navTopics>('test Topic Parent', navTopicsListChild);
        //debugmode
        createNavigationalTopics obj1 = new createNavigationalTopics('', true);
        
    }
    @isTest(seeAllData = true)
    static void navigationalTopicsScriptTestNonDebugMode() {
        String jsonData = '[{"topic":"Test Parent 1","child":[{"topic":"Test Child 1","child":[{"topic":"Test Child 1.1"}]},{"topic":"Test Child 2","child":[{"topic":"Test Child 2.1"}]}]}]';
        
        createNavigationalTopics obj2 = new createNavigationalTopics(jsonData, false);
    }
}