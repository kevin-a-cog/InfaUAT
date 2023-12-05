@isTest
public class IPUE_IntegrationResponseParserTest {

    private static final String jsonResponse = '{ "API_A": 5, "API_B": "b", "API_C": "hooray!", "API_PARENT": {"API_CHILD": "nested value", "NONSENSE": 0} }';

    private static final String sectionName = 'TEST PAGE SECTION';
    private static final String templateName = 'TEST TEMPLATE';
    private static final String templateContent = '$FieldA $FieldA some text $FieldC default $FieldD $Nested';
    private static final String correctAnswer = '5 5 some text hooray! default Default value for d nested value';

    private static final String htmlSectionName = 'TEST HTML PAGE SECTION';
    private static final String htmlTemplateName = 'TEST HTML TEMPLATE';
    private static final String htmlTemplateContent = '<p>$FieldA is <b>$FieldB</b></p>';
    private static final String htmlAnswer = '<p>5 is <b>b</b></p>';

    @TestSetup
    static void setup(){
        // Form data
        Form__c form = IPUE_TestUtils.createForm(true, 'TEST FORM');
        Page__c page = IPUE_TestUtils.createPage(true, 'TEST PAGE', form.Id);
        Page_Frame__c frame = IPUE_TestUtils.createPageFrame(true, 'TEST FRAME', page.Id);

        Page_Section__c section = IPUE_TestUtils.createPageSection(false, sectionName, page.Id, frame.Id);
        Page_Section__c htmlSection = IPUE_TestUtils.createPageSection(false, htmlSectionName, page.Id, frame.Id);
        insert new List<Page_Section__c> { section, htmlSection };

        // API data
        API_Information__c header = new Api_Information__c(
            Name = 'TEST HEADER'
        );
        insert header;

        List<API_Field_Mapping__c> mappings = new List<API_Field_Mapping__c>();
        API_Field_Mapping__c mappingA = IPUE_TestUtils.createFieldMapping(false, 'FieldA', 'API_A', header.Id, null);
        API_Field_Mapping__c mappingB = IPUE_TestUtils.createFieldMapping(false, 'FieldB', 'API_B', header.Id, null);
        API_Field_Mapping__c mappingC = IPUE_TestUtils.createFieldMapping(false, 'FieldC', 'API_C', header.Id, null);
        API_Field_Mapping__c mappingD = IPUE_TestUtils.createFieldMapping(false, 'FieldD', 'API_D', header.Id, 'Default value for d');
        API_Field_Mapping__c mappingNested = IPUE_TestUtils.createFieldMapping(false, 'Nested', 'API_PARENT.API_CHILD', header.Id, null);
        mappingA.API_Field_Type__c = 'Response';
        mappingB.API_Field_Type__c = 'Response';
        mappingC.API_Field_Type__c = 'Response';
        mappingD.API_Field_Type__c = 'Response';
        mappingNested.API_Field_Type__c = 'Response';
        insert new List<Api_Field_Mapping__c> { mappingA, mappingB, mappingC, mappingD, mappingNested };

        // Templates
        Lightning_Service_Template__c template = IPUE_TestUtils.createServiceTemplate(false, templateName, templateContent, section.Id);
        template.Sequence__c = 0;
        Lightning_Service_Template__c htmlTemplate = IPUE_TestUtils.createServiceTemplate(false, htmlTemplateName, htmlTemplateContent, htmlSection.Id);
        htmlTemplate.Sequence__c = 0;
        insert new List<Lightning_Service_Template__c> { template, htmlTemplate };
    }

    @IsTest
    static void testParse(){
        // Query the template
        Page_Section__c section = [
            SELECT Id, (
                SELECT Id, Name
                FROM Lightning_Service_Templates__r
            )
            FROM Page_Section__c
            WHERE Name = :sectionName
            LIMIT 1
        ];
        Set<Id> param = new Set<Id> { section.Id };
        Lightning_Service_Template__c template = section.Lightning_Service_Templates__r[0];

        // Call the method
        Test.startTest();
        Map<Id, IPUE_FormControllerModels.LightningServiceTemplate> result = IPUE_IntegrationResponseParser.formatTemplate(param, new List<String>{jsonResponse});
        Test.stopTest();

        // Verify the result
        // The map is correct
        System.assert(!result.isEmpty(), 'Empty result map');
        System.assertEquals(1, result.size(), 'Incorrect number of results');
        System.assert(result.containsKey(template.Id), 'Does not contain correct key');

        // The element it contains is right
        IPUE_FormControllerModels.LightningServiceTemplate obj = result.get(template.Id);
        System.assertNotEquals(null, obj, 'List element is null');
        System.assertEquals(section.Id, obj.pageSectionId, 'Incorrect page section id in return object');
        System.assertEquals(template.Id, obj.templateId, 'Incorrect template id in return object');
        System.assertEquals(correctAnswer, obj.content, 'Incorrect substitution in return object');
        System.assertEquals(template.Name, obj.name, 'Incorrect name in return object');
    }

    @IsTest
    static void testHtmlEscape(){

        // Query the template
        Page_Section__c section = [
            SELECT Id, (
                SELECT Id, Name
                FROM Lightning_Service_Templates__r
            )
            FROM Page_Section__c
            WHERE Name = :htmlSectionName
            LIMIT 1
        ];
        Set<Id> param = new Set<Id> { section.Id };
        Lightning_Service_Template__c template = section.Lightning_Service_Templates__r[0];

        // Call the method
        Test.startTest();
        Map<Id, IPUE_FormControllerModels.LightningServiceTemplate> result = IPUE_IntegrationResponseParser.formatTemplate(param, new List<String>{jsonResponse});
        Test.stopTest();

        // Verify the result
        // The map is correct
        System.assert(!result.isEmpty(), 'Empty result map');
        System.assertEquals(1, result.size(), 'Incorrect number of results');
        System.assert(result.containsKey(template.Id), 'Does not contain correct key');

        // The element it contains is right
        IPUE_FormControllerModels.LightningServiceTemplate obj = result.get(template.Id);
        System.assertNotEquals(null, obj, 'List element is null');
        System.assertEquals(section.Id, obj.pageSectionId, 'Incorrect page section id in return object');
        System.assertEquals(template.Id, obj.templateId, 'Incorrect template id in return object');
        System.assertEquals(htmlAnswer, obj.content, 'Incorrect substitution in return object');
        System.assertEquals(template.Name, obj.name, 'Incorrect name in return object');
    }

    private static final String uglyJson =
    '{' +
    '    "parent": [' +
    '        {' +
    '            "key": "wrong"' +
    '        }, {' +
    '            "key": "wrong 2"' +
    '        }, [' +
    '           {' +
    '                "key": {' +
    '                    "key": "value"' +
    '               }' +
    '            }' +
    '        ]' +
    '    ]' +
    '}';
    private static final String uglyJsonKey = 'parent.2.0.key.key';

    @IsTest
    static void testJsonExtractor(){
        Test.startTest();
        Object value = IPUE_IntegrationResponseParser.getValueFromJSON((Map<String, Object>)JSON.deserializeUntyped(uglyJson), uglyJsonKey);
        Test.stopTest();

        String valueString = String.valueOf(value);
        System.assertEquals('value', valueString, 'Incorrect value extracted');
    }

}