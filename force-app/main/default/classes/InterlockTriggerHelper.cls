/*
@created by       : Venky K
@created on       : 4/29/2020
@Purpose          : Interlock handler helper class.
@Testclass        : 
@JIRA             : 
@Tag              : T01


Change History
*******************************************************************************************************************************************************
ModifiedBy      Date        Requested By        			Description               							Jira No.       Tag
*******************************************************************************************************************************************************
abadri         07-Oct-2020   Sarojini 		Populate the interlock name field to improve                        AR-1194         T02
											the searchability of interlocks on outlook plugin.
*/
public class InterlockTriggerHelper { 
    
    
    
    /**
*————————————————————————————————————————————————————
* @Description: 
* To Update IPS Project owner from fed id (fed id is updated by ICS job) 
*————————————————————————————————————————————————————
* @param    New and old map
* @return   void
*————————————————————————————————————————————————————
**/
    
    
   /* public void updateIPSOwner(Map<Id,Related_Opportunity_Plan__c > newMap, Map<Id,Related_Opportunity_Plan__c > oldMap) {
        Set<String> fedidset = new Set<String>();
        for(Related_Opportunity_Plan__c ro: newMap.values()){
            if(ro.Project_manager_fed_id__c != null){
                fedidset.add(ro.Project_manager_fed_id__c);
            }
        }
        
        Map<String,Id> fedmap = new Map<String,Id>();
        for(User u: [SELECT Id,FederationIdentifier FROM User where FederationIdentifier  in :fedidset]){
            fedmap.put(u.FederationIdentifier, u.Id);
        }
        
        for(Related_Opportunity_Plan__c ro: newMap.values()){
            if(ro.Profssional_Services_Owner__c  != null && ro.Project_manager_fed_id__c != null && fedmap.get(ro.Project_manager_fed_id__c)!= null && ro.Profssional_Services_Owner__c != fedmap.get(ro.Project_manager_fed_id__c)){
                ro.Profssional_Services_Owner__c = fedmap.get(ro.Project_manager_fed_id__c);
            }
        }  
        
    } */
    
    /**
     *Modified By : abadri
	  Modified On : 07-oct-2020
*————————————————————————————————————————————————————
* @Description: 
* To populate Interlock name to improve searchability  

*————————————————————————————————————————————————————
* @param    New List
* @return   void
*————————————————————————————————————————————————————
**/    //<T02>
    public void populateInterlockName(List<Related_Opportunity_Plan__c> newList)
    {
        System.debug('populateInterlockName Entry');
        System.debug('newList-->'+newList);
        Map<Id,Plan__c> planMap=new Map<Id,Plan__c>();
        Set<Id> planIds=new Set<Id>();
        String planName='';
        String interlockName='';
        
        
        for(Related_Opportunity_Plan__c interlock :newList)
        {
            if(interlock.Plan__c!=null)
            {
                planIds.add(interlock.Plan__c);
            }
        }
        
        if(planIds!=null && planIds.size()>0)
        {
            planMap=new Map<Id,Plan__c>([select Id,Name from Plan__c where Id in :planIds]);
        }
        for(Related_Opportunity_Plan__c interlock :newList)
        {
            System.debug('interlock.RecordType.Name-->'+interlock.RecordType.Name);
            System.debug('interlock.RecordTypeId-->'+interlock.RecordTypeId);
            if(interlock.RecordTypeId!=null)
            {
                if(interlock.RecordTypeId == Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId())
                {
                    System.debug('recType=Renewal (SMG)');
                    if(planMap!=null && interlock.Plan__c!=null)
                    {
                        planName=planMap.get(interlock.Plan__c).Name;
                        if(planName!='')
                        {
                            interlockName=planName+' '+'SMG';
                        }
                    }
                }
                else if(interlock.RecordTypeId == Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId())
                {
                    System.debug('recType=Professional Services');
                    if(interlock.Interlock_Type__c!=null && interlock.Interlock_Type__c!='')
                    {
                        if(planMap!=null && interlock.Plan__c!=null)
                        {
                            planName=planMap.get(interlock.Plan__c).Name;
                            System.debug('planName-->'+planName);
                            if(planName!='')
                            {	
                                //  interlockName=planName.substring(0,planName.length()-1)+''+'PS'+interlock.Interlock_Type__c.substring(0,interlock.Interlock_Type__c.length()-1);
                                interlockName=planName+' '+'Professional Services'+' '+interlock.Interlock_Type__c;
                                
                                System.debug('interlockName-->'+interlockName);
                            }
                        }
                    }
                }
                
                else if(interlock.RecordTypeId == Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId())
                {
                    System.debug('recType=CST');
                    if(planMap!=null && interlock.Plan__c!=null)
                    {
                        planName=planMap.get(interlock.Plan__c).Name;
                        if(planName!='')
                        {
                            interlockName=planName+' '+'CST';
                        }
                    }
                }
                
                else if(interlock.RecordTypeId == Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('PreSales').getRecordTypeId())
                {
                    System.debug('recType=PreSales');
                    if(planMap!=null && interlock.Plan__c!=null )
                    {
                        planName=planMap.get(interlock.Plan__c).Name;
                        if(planName!='')
                        {
                            interlockName=planName+' '+'PreSales';
                        }
                    }
                }
                System.debug('interlockName-->'+interlockName);
                if(interlockName!='')
                {
                    interlock.Related_Opportunity_Name__c=interlockName;
                }
                System.debug('interlock.Name-->'+interlock.Name);
            }
        }//</T02>
    }
}