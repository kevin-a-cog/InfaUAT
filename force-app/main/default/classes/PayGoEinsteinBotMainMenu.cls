/*
Class:              PayGoEinsteinBotMainMenu
@Author:            Madhu Shanthappa & Sandeep Duggi
@Created Date:      11-Sep-2023
@Description:       I2RT-8961:To get the Main menu dynamically from custom metadata.
@TestClass:         PayGoEinsteinBotTest
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************

*/
public class PayGoEinsteinBotMainMenu {
    /*  
	 Method Name : getMainMenu
	 Description : This method returns the Menu items as list from metadata
                   Called as Invocable from Einstein bot for Paygo
	 Parameters	 : None
	 Return Type : List of List of String contains menu Item
	*/
    @InvocableMethod(label='Get PayGo Einstein Main Menu')
    public static List<List<String>> getMainMenu() {
    
        String chatwithAnExpertStr = 'Chat with an Expert';
        List<String> mainMenu = new List<String>();
        List<List<String>> menuList = new List<List<String>>();
        
        for(PayGo_EinsteinBot_Configurations__mdt objRecord : [SELECT Menu_Item__c,Order__c 
                                                               FROM PayGo_EinsteinBot_Configurations__mdt 
                                                               WHERE Is_Main_Menu__c = true AND Is_Active__c = true 
                                                               ORDER BY Order__c ASC]){
            
            if(objRecord.Menu_Item__c == chatwithAnExpertStr){
                if(PayGoEinsteinBotSecondaryMenu.checkIsPayGoExpertAvailable()){
                    mainMenu.add(objRecord.Menu_Item__c);
                }
            }else{
                mainMenu.add(objRecord.Menu_Item__c);
            }
        }
        menuList.add(mainMenu);
        return menuList;
    }  
}