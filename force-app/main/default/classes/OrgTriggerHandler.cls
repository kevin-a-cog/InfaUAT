/*
        Class:          OrgTriggerHandler
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler class for Org Object triggers

    Change History
******************************************************************
    ModifiedBy          Date        Requested By        Description                 Tag
    
******************************************************************
*/


public class OrgTriggerHandler{


    public static void OrgUserBeforeInsert(List<Org_User__c>  lstNew){
    
        List<Org_User__c> lstinsert= new list< Org_User__c>();//List of Org users which needs to be updated with lead/contact reference
        
        //Check if email is not null
        for(Org_User__c ou : lstNew){
    
                if(ou.lead__c==null && ou.Contact__c ==null && ou.Email__c!=null){
                
                   lstinsert.add(ou);
                }
        }
        //method to lookup org user email with lead/contact
        lookupLeadContact(lstinsert);
    }
    
    
    public static void OrgUserBeforeUpdate(Map<id,Org_User__c> mapOld, List<Org_User__c>  lstNew){
    
        List<Org_User__c> lstupdate= new list< Org_User__c>();//List of Org users which needs to be updated with lead/contact reference
        
        
        //Check if email is updated   
        for(Org_User__c ou: lstNew){
        
            if((mapOld.get(ou.id).Email__c!=null && ou.Email__c!=null && !mapOld.get(ou.id).Email__c.equals(ou.Email__c))
             || (mapOld.get(ou.id).Email__c==null&&ou.Email__c!=null) 
             ||(mapOld.get(ou.id).Email__c!=null&&ou.Email__c==null)){
            
                lstupdate.add(ou);
            }
        }
        
        //method to lookup org user email with lead/contact
        lookupLeadContact(lstupdate);
    }
    
    
    
    //method to lookup org user email with lead/contact
    static void lookupLeadContact(List<Org_User__c>  lstNew){
    
        set<string> setEmails = new Set<String>();  // set of emails which needs to be searched for lead/contacts
        map<string,lead> mapLeads = new  map<string,lead>(); // map of Leadids grouped by email
        map<string,contact> mapContacts = new  map<string,contact>();// map of ContactIds grouped by email
    
        //get all org user emails to lookup 
        for ( Org_User__c ou : lstNew){
              
            IF( ou.Email__c!=null){
                setEmails.add(ou.Email__c);
                }
            
        }
                
        //query leads matching email
        for(Lead ld: [select id,email from lead where  email in : setEmails]){
            mapLeads.put(ld.email,ld);
        }
        
        //quey contacts matching email
        for(Contact con: [select id,email from Contact where  email in : setEmails]){
            mapContacts.put(con.email,con);
        }
        
        
        //update org user with lead reference 
        
            for(Org_User__c ou : lstNew){
                if(mapLeads!=null && mapLeads.keyset().size()>0 && mapLeads.keyset().contains(ou.email__c)){
                    ou.Lead__c = mapLeads.get(ou.email__c).id;
               }
               else{
                   ou.Lead__c =null;
               }
            }
 
        
        
        //update org user with contact reference 
        
            for(Org_User__c ou : lstNew){
                if(mapContacts!=null && mapContacts.keyset().size()>0&&mapContacts.keyset().contains(ou.email__c)){
                    ou.Contact__c = mapContacts.get(ou.email__c).id;
               }
               else{
                   ou.Contact__c =null;
               }
            }
        
    }
    


}