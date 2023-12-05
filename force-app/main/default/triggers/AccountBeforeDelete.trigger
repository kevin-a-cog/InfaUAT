/*
        Trigger:        AccountBeforeDelete
        @Author:        Ambica Pyati
        @Created Date:  3/23/2018
        @Description:   handler logic on before delete of account
*/

trigger AccountBeforeDelete on Account(Before Delete) {

        
    if(globalApexManager.avoidRecursion('AccountBeforeDelete ')) {
                    return;
        }
    
    AccountTriggerHandler.AccountBeforeDelete (Trigger.old);

}