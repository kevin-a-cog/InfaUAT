/*
Class:              PayGoEinsteinBotSecondaryMenu
@Author:            Madhu Shanthappa & Sandeep Duggi
@Created Date:      11-Sep-2023
@Description:       I2RT-8961:To get the seconday menu dynamically from custom metadata.
@TestClass:         PayGoEinsteinBotTest
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************
*/
public with sharing class PayGoEinsteinBotSecondaryMenu {
    
    /*  
	 Method Name : getSecondaryMenu
	 Description : This method returns the Menu items as list from metadata
                   Called as Invocable from Einstein bot for Paygo
	 Parameters	 : None
	 Return Type : List of List of String contains menu Item
	*/
    @InvocableMethod(label='Get PayGo Einstein Secondary Menu')
    public static List<List<String>> getSecondaryMenu() {
        
        String chatwithAnExpertStr = 'Chat with an Expert';
        List<String> secondaryMenu = new List<String>();
        List<List<String>> menuList = new List<List<String>>();
        
        for(PayGo_EinsteinBot_Configurations__mdt objRecord : [SELECT Menu_Item__c,Order__c 
                                                               FROM PayGo_EinsteinBot_Configurations__mdt 
                                                               WHERE Is_Secondary_Menu__c = true AND Is_Active__c = true 
                                                               ORDER BY Order__c ASC]){
            if(objRecord.Menu_Item__c == chatwithAnExpertStr){
                if(checkIsPayGoExpertAvailable()){
                    secondaryMenu.add(objRecord.Menu_Item__c);
                }
            }else{
                secondaryMenu.add(objRecord.Menu_Item__c);
            }
        }
        menuList.add(secondaryMenu);
        return menuList;
    }
    /*  
	 Method Name : checkIsPayGoExpertAvailable
	 Description : This method returns the true or false of Agents/Experts are available
                   IF Queue members are availabe returns true else return false
	 Parameters	 : None
	 Return Type : Boolean
	*/
    public static Boolean checkIsPayGoExpertAvailable(){
    
        String queueDeveloperName = 'PayGo_Einstein_Bot';
        List<Id> userIdList = new List<Id>();
        List<UserServicePresence> userServicePresenceList = new List<UserServicePresence>();
        Boolean isExpertAvailable = false;
        
        for(GroupMember member:[SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :queueDeveloperName AND Group.Type  ='Queue']){
                userIdList.add(member.UserOrGroupId);
            }
            if(!userIdList.isEmpty()){
                userServicePresenceList = [SELECT Id FROM UserServicePresence
                                       WHERE IsAway = false AND IsCurrentState = true AND UserId IN :userIdList];
               if(!userServicePresenceList.isEmpty()){
                   isExpertAvailable = true;
               }
            }
        return isExpertAvailable;
    }
}