/*
    @created by       : Venky K
    @created on       : 4/29/2020
    @Purpose          : Trigger handler class common for all triggers.
    @TestClass        : 
    @JIRA             : 
    @Tag              : T01
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         03/09/2022  I2RT-5624   T01     added constructor that accepts one parameter recursionCheckNeeded

*/
public virtual class TriggerHandler{
    protected List<SObject> oldList;
    protected List<SObject> newList;
    protected Map<Id, SObject> oldMap;
    protected Map<Id, SObject> newMap;
    protected Boolean isInsert = false;
    protected Boolean isUpdate = false;
    protected Boolean isDelete = false;
    protected Boolean isUndelete = false;
    protected Boolean isBefore = false;
    protected Boolean isAfter = false;
    protected Boolean recursionCheckNeeded;
    private Boolean skipExecution = false;

    //this must be a static variable as we have to track all processed classes in the current execution context
    public static Set<String> processedClasses = new Set<String>(); 

    //T01 - made this one a constructor as it was declared as a method by mistake.
    public TriggerHandler(Boolean recursionCheckNeeded) {
        this.recursionCheckNeeded = recursionCheckNeeded;
        init();
    }

    public TriggerHandler() {
        this.recursionCheckNeeded = true;  //by default recursion check is turned on
        init();
    }
    
    public void process() {
        checkRecursion();
        if (skipExecution == false) {
            if(Trigger.isBefore) {
                before();
            }
            else if(Trigger.isAfter) {
                after();
            }       
        }
    }

    /* PRIVATE METHODS */

    private void init() {
        newList = Trigger.New;
        oldList = Trigger.Old;
        newMap = Trigger.NewMap;
        oldMap = Trigger.OldMap;
    }

    private void before() {
        isBefore = true;
        if(Trigger.isInsert) {
            isInsert = true;
            beforeInsert();
        }      
        else if(Trigger.isUpdate) {
            isUpdate = true;
            beforeUpdate();
        }
        else if(Trigger.isDelete) {
            isDelete = true;
            beforeDelete();
        }       
    }

    private void after() {
        isAfter = true;
        if(Trigger.isInsert) {
            isInsert = true;
            afterInsert();
        }      
        else if(Trigger.isUpdate) {
            isUpdate = true;
            afterUpdate();
        }
        else if(Trigger.isDelete) {
            isDelete = true;
            afterDelete();
        }
        else if(Trigger.isUndelete) {
            isUndelete = true;
            afterUndelete();
        }
    }

    //If current class was already processed earlier during the current execution context, then processing will be skipped
    private void checkRecursion() {
        String className = getCurrentClassName();
        if (recursionCheckNeeded) {
            if (processedClasses.contains(className)) {
                this.skipExecution = true;
            }
        }
        processedClasses.add(className);
    }
    
    private String getCurrentClassName() {
        String context = Trigger.isBefore ? 'BEFORE:' : 'AFTER:';
        if (Trigger.isInsert) {
            context = context + ' INSERT';
        } else if (Trigger.isUpdate) {
            context = context + ' UPDATE';
        } else if (Trigger.isDelete) {
            context = context + ' DELETE';
        } else if (Trigger.isUndelete) {
            context = context + ' UNDELETE';
        }
        
        String clsNameStr = String.valueOf(this);
        String name = context + clsNameStr.substring(0, clsNameStr.indexOf(':'));
        return name;
    }


    /* PROTECTED METHODS */

    /* The following methods (one or more) can be overridden by the sub classes as per need */
    
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}

}