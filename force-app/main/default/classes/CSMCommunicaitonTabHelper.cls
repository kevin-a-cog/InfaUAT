/* Author		:	Deva M
* Created Date	: 	04/03/2022
* Description	:	class to map the tab settings

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				04/03/2022		N/A				Initial version.			N/A
*/
public with sharing class CSMCommunicaitonTabHelper {
    @AuraEnabled
    public List<Communication_Tab_Setting__mdt> parentTabList;
     /*
	 Method Name : fetchTabs
	 Description : This method returns the tabs configured for plan communciation
	 Parameters	 : none.
	 Return Type : none 
	 */
    @AuraEnabled(cacheable = false)
    public static CSMCommunicaitonTabHelper fetchTabs() {
        CSMCommunicaitonTabHelper objCont = new CSMCommunicaitonTabHelper();
        objCont.parentTabList = new List<Communication_Tab_Setting__mdt>();
        for(Communication_Tab_Setting__mdt tabObj:[SELECT Id,Tab_Label__c,Tab_Title__c,Tab_Value__c,Order__c,
                                                    (SELECT Id,Tab_Label__c,Tab_Title__c,Tab_Value__c,Order__c,Communication_Tab_Setting__c FROM Communication_Child_Tab_Settings__r ORDER BY Order__c ASC) FROM Communication_Tab_Setting__mdt ORDER BY Order__c ASC]){
            
            objCont.parentTabList.add(tabObj);  
        }
        return objCont;
    }
}