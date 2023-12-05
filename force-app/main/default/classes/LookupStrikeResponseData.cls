/*********************************************************************************************************
Class Name      : LookupStrikeResponseData
Description     : 
Created By      : Deloitte
Created Date    : April 4, 2018
Modification Log:
--------------------------------------------------------------------------------------------------------------
Developer                   Date                   Description
--------------------------------------------------------------------------------------------------------------
Deloitte               April 4, 2018              Initial Version
*******************************************************************************************************/
public with sharing class LookupStrikeResponseData {
    public Boolean isSuccess;
    public Map<String, Object> results;
    public String errMsg;

    public LookupStrikeResponseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public void addError(String errMsg){
        this.errMsg = errMsg;
        this.isSuccess = false;
    }

    public String getJsonString() {
        return StrikeUtilities.serializeWithoutNamespace(this);
    }
}