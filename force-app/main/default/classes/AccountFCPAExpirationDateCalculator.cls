/****************************************************************************************************************************
 *  @Class Name: AccountFCPAExpirationDateCalculator
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-10-24 
 *  @Description:This is a helper class which set the FCPA Expiration Date Value of the FCPA Compliant Partners.
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/
public class AccountFCPAExpirationDateCalculator
{
  
  /**
    * This method gets invoked from a process builder named 'Account_Upsert' and updates the FCPA expiration date. 
    * @param parameter- newCons- list of new account Ids
    * @return return- void
    */
    
	@InvocableMethod     
	public static void setFCPAExpirationDate(List<Id> FCPAAccIds)
    {
        //List to store the Account Ids and Values that need to be updated
		List<Account> listOfFCPAAccs = new List<Account>();  
		List<PRM_Custom_Data_Settings__mdt> PRM_Custom_Data_No_Of_Days = new List<PRM_Custom_Data_Settings__mdt>();
        Integer NoOfMonths;    
		
        //Instanciated the globalApexManager class to pass parameters for error log creation when exception occurs
		globalApexManager GAM = new globalApexManager();
            
		//Get the number of months after the FCPA Expiration Date need to be set after the record creation
		PRM_Custom_Data_No_Of_Days = [SELECT No_Of_Days_After_Program_Expires__c from PRM_Custom_Data_Settings__mdt where No_Of_Days_After_Program_Expires__c <> null limit 1];         

        if(PRM_Custom_Data_No_Of_Days != null && !PRM_Custom_Data_No_Of_Days.isEmpty())
        {
            NoOfMonths = (Integer)PRM_Custom_Data_No_Of_Days[0].No_Of_Days_After_Program_Expires__c;
        }
        
		//Iterating over the newly created/updated accounts and updating their FCPA Expiration Date
		if(FCPAAccIds != null && !FCPAAccIds.isEmpty() && NoOfMonths!= null)
		{	
            for(Account ac : [SELECT Id,FCPA_Expiration_Date__c FROM Account WHERE Id IN :FCPAAccIds])
			{
                date currentDate = system.today();
				ac.FCPA_Expiration_Date__c = currentDate.addMonths(NoOfMonths);
				listOfFCPAAccs.add(ac);                	
			}
		}
        
        //DML Actions and Exception Handling happens here.
		if(listOfFCPAAccs != null && listOfFCPAAccs.size()>0 && Schema.getGlobalDescribe().get('Account').getDescribe().isUpdateable())
		{
			try
            {
                update listOfFCPAAccs;
            }
            catch (System.DmlException e) 
            {
                //Sending Process Builder Name and Apex Class name which caused the DML exception.
                GAM.CreateLogs('Process Builder:Account_Upsert '+e,'ApexClass:AccountFCPAExpirationDateCalculator');
            }
        }
    }
}