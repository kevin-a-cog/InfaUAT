public virtual class ManagedClauseCreationTriggerHandler {

    /*****************
    Private Properties
    ******************/
    protected String sObjectApiName;

    /**********
    Constructor
    ***********/
    public ManagedClauseCreationTriggerHandler(String sObjectName) {
        this.sObjectApiName = sObjectName;
    }

    /**************
    Private Methods
    ***************/
    protected virtual void onAfterInsert(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        ManagedClauseCreationService.processManagedClauses(this.sObjectApiName, oldMap, newMap);
    }

    protected virtual void onAfterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        ManagedClauseCreationService.processManagedClauses(this.sObjectApiName, oldMap, newMap);
    }

    protected virtual void onBeforeDelete(Map<Id, sObject> oldMap) {
        ManagedClauseCreationService.deleteManagedClauses(this.sObjectApiName, oldMap); 
    }

    /*************
    Public Methods
    **************/
    protected virtual boolean triggersEnabled() {
        return true;
    }

    public void onTrigger(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        if (!triggersEnabled()) return;
       
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                onAfterInsert(oldMap, newMap);
            }
            else if (Trigger.isUpdate) {
                onAfterUpdate(oldMap, newMap);
            }
        }
        else if (Trigger.isBefore) {
            if (Trigger.isDelete) {
                onBeforeDelete(oldMap);
            }
        }
    }
}