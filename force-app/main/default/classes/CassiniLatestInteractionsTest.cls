/*
Class:          CassiniLatestInteractionsTest 
@Author:        Anil Solanki
@Created Date:  05/29/2018
@Description:   Test class for CassiniLatestInteractions Class
*/

@isTest
private class CassiniLatestInteractionsTest {
    static testMethod void testDefaultMockValues(){
        //Test handler using the default mock RenderContext Canvas.Test creates
        CassiniLatestInteractions handler = new CassiniLatestInteractions();
        handler.excludeContextTypes();
        Canvas.Test.testCanvasLifecycle(handler,null);
    }

    static testMethod void testOverriddenAppValues(){
        // Test handler with some mock application context values
        Map<String,String> appValues = new Map<String,String>();
        appValues.put(Canvas.Test.KEY_CANVAS_URL,'https://myserver.com:6000/myAppPath');
        appValues.put(Canvas.Test.KEY_VERSION,'3.0');
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues,null);
        CassiniLatestInteractions handler = new     CassiniLatestInteractions();
        Canvas.Test.testCanvasLifecycle(handler,mock);
    }

    static testMethod void testOverriddenEnvironmentValues(){
        // Test handler with some mock environment context values
        Map<String,String> envValues = new Map<String,String>();
        envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION,'Chatter');
        envValues.put(Canvas.Test.KEY_LOCATION_URL,
            'https://infa--a2rdev.lightning.force.com/one/one.app?source=alohaHeader#/sObject/123456/view');
        CassiniLatestInteractions handler = new  CassiniLatestInteractions();
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(null,envValues);
        // Directly update the mock RenderContext and set the custom parameters
        mock.getEnvironmentContext().setParametersAsJSON(
            '{\"one\":1,\"two\":2,\"bool\":true,\"stringVal\":\"some string\"}');
        Canvas.Test.testCanvasLifecycle(handler,mock);
    }
}