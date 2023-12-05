public with sharing class CSMPlanTeamTriggerCheckRecursive {
    private static boolean runBeforeInsert = true;
    private static boolean runBeforeUpdate = true;
    private static boolean runAfterInsert = true;    
    private static boolean runAfterUpdate = true;
    public static boolean recursionUpsert = true;// Added as part of AR-2889  
    public static boolean bypassValidationForupsert = true;  // Added as part of AR-2889 
    public static boolean runBeforeUpdateOnce(){
        if(runBeforeUpdate){
            runBeforeUpdate=false;
            return true;
        }else{
            return runBeforeUpdate;
        }
    }
    
    public static boolean runBeforeInsertOnce(){
        if(runBeforeInsert){
            runBeforeInsert=false;
            return true;
        }else{
            return runBeforeInsert;
        }
    }
    
    public static boolean runAfterInsertOnce(){
        if(runAfterInsert){
            runAfterInsert=false;
            return true;
        }else{
            return runAfterInsert;
        }
    }

    public static boolean runAfterUpdateOnce(){
        if(runAfterUpdate){
            runAfterUpdate=false;
            return true;
        }else{
            return runAfterUpdate;
        }
    }
}