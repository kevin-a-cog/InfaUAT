/************************************************************************************
 *  @Trigger Name: PartnerProgramBeforeInsert
 *  @Author: Deloitte
 *  @Date: 2017-02-14 
 *  @Description:This is a before Insert Trigger on Partner Program Object.
 ************************************************************************************
 ChangeHistory      
 ************************************************************************************/
trigger PartnerProgramBeforeInsert on Partner_Program__c (before insert) {
    if(globalApexManager.avoidRecursion('PartnerProgramBeforeInsert'))
    {
                    return;
    }
     
    If(Trigger.isBefore && Trigger.isInsert)
    PartnerProgramTriggerHandler.partnerProgramBeforeInsert(Trigger.New,Trigger.NewMap);
}