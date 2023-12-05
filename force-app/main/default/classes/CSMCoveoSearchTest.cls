@isTest
public class CSMCoveoSearchTest {


	private class getSearchTokenRestMock implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {
		String fullJson = '{"token": "eyJhbGciOiJIUzI1NiJ9.eyJmaWx0ZXIiOiIoQElORkFNb2RlcmF0aW9uU3RhdHVzPT0wIChOT1QgQGluZmFwZXJtaXNzaW9udHlwZT09SW50ZXJuYWwpIChOT1QgQGluZmFkb2N1bWVudHR5cGU9PShTdXBwb3J0VFYsUEFNRU9MKSkgKE5PVCBAaW5mYWRvY3VtZW50c3RhdHVzPT0oYXJjaGl2ZWQscHVyZ2VkKSkpIE9SIChAc3lzY29ubmVjdG9ydHlwZT09Sml2ZUNyYXdsZXIgQGppdmVzdGF0dXM9PShhY3RpdmUscHVibGlzaGVkKSBAaW5mYWRvY3VtZW50dHlwZTw-Q1IpIiwidjgiOnRydWUsIm9yZ2FuaXphdGlvbiI6ImluZm9ybWF0aWNhc2FuZGJveCIsInVzZXJJZHMiOlt7InByb3ZpZGVyIjoiRW1haWwgU2VjdXJpdHkgUHJvdmlkZXIiLCJuYW1lIjoiYW5vbnltb3VzQGNvdmVvLmNvbSIsInR5cGUiOiJVc2VyIn1dLCJyb2xlcyI6WyJxdWVyeUV4ZWN1dG9yIl0sImV4cCI6MTU4MjE5NTM1MCwiaWF0IjoxNTgyMTA4OTUwfQ.zIfidbzUL6-qSM48CvBJq8yvDj4ORJSrJauiNvYu21w"}';

		HTTPResponse res = new HTTPResponse();
		res.setHeader('Content-Type', 'text/json');
		res.setBody(fullJson);
		res.setStatusCode(200);
		return res;
	}
	}

	private class ExceptiongetSearchTokenRestMock implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {
		String fullJson = '{"token": "\"eyJhbGciOiJIUzI1NiJ9.eyJmaWx0ZXIiOiIoQElORkFNb2RlcmF0aW9uU3RhdHVzPT0wIChOT1QgQGluZmFwZXJtaXNzaW9udHlwZT09SW50ZXJuYWwpIChOT1QgQGluZmFkb2N1bWVudHR5cGU9PShTdXBwb3J0VFYsUEFNRU9MKSkgKE5PVCBAaW5mYWRvY3VtZW50c3RhdHVzPT0oYXJjaGl2ZWQscHVyZ2VkKSkpIE9SIChAc3lzY29ubmVjdG9ydHlwZT09Sml2ZUNyYXdsZXIgQGppdmVzdGF0dXM9PShhY3RpdmUscHVibGlzaGVkKSBAaW5mYWRvY3VtZW50dHlwZTw-Q1IpIiwidjgiOnRydWUsIm9yZ2FuaXphdGlvbiI6ImluZm9ybWF0aWNhc2FuZGJveCIsInVzZXJJZHMiOlt7InByb3ZpZGVyIjoiRW1haWwgU2VjdXJpdHkgUHJvdmlkZXIiLCJuYW1lIjoiYW5vbnltb3VzQGNvdmVvLmNvbSIsInR5cGUiOiJVc2VyIn1dLCJyb2xlcyI6WyJxdWVyeUV4ZWN1dG9yIl0sImV4cCI6MTU4MjE5NTM1MCwiaWF0IjoxNTgyMTA4OTUwfQ.zIfidbzUL6-qSM48CvBJq8yvDj4ORJSrJauiNvYu21w"}';

		HTTPResponse res = new HTTPResponse();
		res.setHeader('Content-Type', 'text/json');
		res.setBody(fullJson);
		res.setStatusCode(200);
		return res;
	}
	}

	private class getSearchResultRecenttDataRestMock implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {
		String fullJson = '{"totalCount":138381,"totalCountFiltered":138381,"results":[{"title":"Internal error. An error occurred while connecting to the Salesforce.com web service.","clickUri":"https://kb-test.informatica.com/solution/23/Pages/58/497848.aspx","raw":{"infadocid":"497848","sysfiletype":"html"},"Title":"Internal error. An error occurred while connecting to the Salesforce.com web service","Uri":"https://kbtestcrawl.informatica.com/SiteCollection:2c79e3a3-7df7-4786-a441-72eda38cbf56/Web:8f1a3020-3327-4f39-ba1f-7a1dadb57e74/List:0d732225-91a0-4711-9e61-e99da2c48d2c/ListFolder:181757/ListItem:181966","PrintableUri":"https://kb-test.informatica.com/solution/23/Pages/58/497848","ClickUri":"https://kb-test.informatica.com/solution/23/Pages/58/497848.aspx","UniqueId":"42.57428$https://kbtestcrawl.informatica.com/SiteCollection:2c79e3a3-7df7-4786-a441-72eda38cbf56/Web:8f1a3020-3327-4f39-ba1f-7a1dadb57e74/List:0d732225-91a0-4711-9e61-e99da2c48d2c/ListFolder:181757/ListItem:181966","Excerpt":"In Informatica Intelligent Cloud Services, while testing a Salesforce connection, the following ... Internal error. ... An error occurred while connecting to the Salesforce.com web service.","FirstSentences":null}]}';

		HTTPResponse res = new HTTPResponse();
		res.setHeader('Content-Type', 'text/json');
		res.setBody(fullJson);
		res.setStatusCode(200);
		return res;
	}
	}


	//getSearchToken Test Method
	@isTest static void TestgetSearchToken(){
		Test.setMock(HttpCalloutMock.class, new getSearchTokenRestMock());
		Test.startTest();
		string strCTsearchToken = CSMCoveoSearch.getSearchToken('csmcontentsearch');
		Test.StopTest();

	}

	//getSearchToken Exception Test Method
	@isTest static void TestgetSearchTokenExeception(){
		Test.setMock(HttpCalloutMock.class, new ExceptiongetSearchTokenRestMock());
		Test.startTest();
		string strsearchToken = CSMCoveoSearch.getSearchToken('contentsearch');
		Test.StopTest();

	}

	//getCurrentUsersDetails Test Method
	@isTest static void TestgetCurrentUsersDetails(){
		Test.startTest();

		CSMCoveoSearch.getCurrentUsersDetails();

		Test.StopTest();

	}
	//getCurrentSessionId Test Method
	@isTest static void TestgetCurrentSessionId(){
		Test.startTest();

		CSMCoveoSearch.getCurrentSessionId();

		Test.StopTest();

	}

}