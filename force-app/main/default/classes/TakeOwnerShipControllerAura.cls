/*      Class:          TakeOwnerShipControllerAura
@Author:        Lokesh kumar
@Created Date:  29-Oct-2017
@Description:   Marketo US- 1438 - This class is being used for taking the ownership of Lead,Contact and 
Task Records by using the Lightning Quick action button on record detail page.
*/


/*
Change History
**********************************************************************************************************
ModifiedBy          Date        Requested By        Description                         Tag
Ambica Pyati      11/15/2017    Lynnette      SALESRT-220 New Default Owner for         T1
Lead/Contact Assignment
Ambica Pyati      4/20/2020    pkoolwal	      MKTO-24 remove validations on contact 	T02
take ownership
***********************************************************************************************************
*/
public class TakeOwnerShipControllerAura {
    
    public static String PartnerUserId= [SELECT id, FederationIdentifier FROM User where FederationIdentifier = 'puser' limit 1].id;
    public static String UnassignedUserId= [SELECT id, FederationIdentifier FROM User where FederationIdentifier = 'unasgn' limit 1].id;
    
    /* TakeOwnerShipControllerAura() {

PartnerUserId= [SELECT id, FederationIdentifier FROM User where FederationIdentifier = 'puser' limit 1].id;
UnassignedUserId= [SELECT id, FederationIdentifier FROM User where FederationIdentifier = 'unasgn' limit 1].id;

}*/
    
    
    
    /* ContactOwnership method is used to take the ownership of Contact Record 
	and referenced in ContactTakeownershipController lightning  */
    
    @AuraEnabled
    Public static string ContactOwnership(Id contactId){
        Contact con = [select id,ownerId from Contact where id =:contactId limit 1];
        String ContactOwnerId = String.valueOf(con.ownerId); // store the contact ownerID
        
        // commented the check for current owner<T02>
		/*
        //Check for the leadowner shouldn't be partner user and not equal to Logged in user.
        if(!ContactOwnerId.contains(PartnerUserId) && !ContactOwnerId.contains(UnassignedUserId) && !ContactOwnerId.contains(UserInfo.getUserId()))  //T1
        {
            return 'cannot change ownership';
        }*/
        
        //</T02>

        //check for the current logged in User
        if(ContactOwnerId.contains(UserInfo.getUserId())){
            return 'same owner';
        }
        
        // commented the check for current owner<T02>
        //if(con.ownerId == PartnerUserId || con.ownerId == UnassignedUserId ) //T1 
        //</T02>
        con.ownerid= UserInfo.getUserId();
        try
        {
            update con;
            return 'success';
        }
        Catch(Exception e){
            return e.getMessage();
        }
        
    }
    
    /* LeadchangeOwnerShip method is used to take the ownership of Lead Record 
	and referenced in LeadTakeownershipController lightning  */
    
    @AuraEnabled
    public static String LeadchangeOwnerShip(ID leadID){
        Lead ld = [select id,ownerId from Lead where id =:leadID limit 1];
        String LeadOwnerId = String.valueOf(ld.ownerId); // store the lead ownerID
        //Check for the leadowner shouldn't be partner user and not equal to Logged in user.
        if(!LeadOwnerId.contains(PartnerUserId) && !LeadOwnerId.contains(UnassignedUserId)&& !LeadOwnerId.contains(UserInfo.getUserId()))//T1
        {
            return 'cannot change ownership';
        }
        //check for the current logged in User
        if(LeadOwnerId.contains(UserInfo.getUserId())){
            return 'same owner';
        }
        if(ld.ownerId == PartnerUserId || ld.ownerId == UnassignedUserId) //T1
        {
            ld.ownerid= UserInfo.getUserId();
            try
            {
                update ld;
                return 'success';
            }
            Catch(Exception e){
                return e.getMessage();
            }
        }
        return null;
    }
}