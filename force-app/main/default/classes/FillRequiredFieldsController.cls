/*
 * Name			:	FillRequiredFieldsController
 * Author		:	VENKATESH BALLA
 * Created Date	: 	10/20/2023
 * Description	:	Allows required to be filled.
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description									Tag
 **********************************************************************************************************
 VENKATESH BALLA		10/20/2023		SALESRT-17407   Additional changes to support Opportunity    N/A
 														substage progression.
 */
public with sharing class FillRequiredFieldsController {
    @AuraEnabled
    public static string saveData(String sobjectName, String fieldAPI, String recordId, String valueToSave){
        try {
            SObject sobj = Schema.getGlobalDescribe().get(sobjectName).newSObject() ;
            sobj.put('Id', recordId);
            sobj.put(fieldAPI, valueToSave);
            update sobj;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}