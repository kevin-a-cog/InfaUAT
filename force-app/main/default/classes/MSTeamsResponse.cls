/*
Class:          MSTeamsResponse
@Author:        Venky K
@Created Date:  1-Aug-2021
@Description:   MSTeamsResponse class to handle response from MSTeams.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/

@RestResource(urlMapping='/MSTeamsResponse')
global class MSTeamsResponse  {
    @HttpPost
    global static void doPost() {
                                        
        try{
            
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
           
            
			List<SObject> sobjlist = new List<SObject>();
            String objType;
            String oldval;
            System.debug('---req ---'+req);
            System.debug('---res---'+res);
                        
            string jsonbody = req.requestBody.toString();
            System.debug('---jsonbody---'+jsonbody);
            
            
            MSTeamsResponseJSON obj = (MSTeamsResponseJSON)System.JSON.deserialize(jsonbody, MSTeamsResponseJSON.class);
            
            System.debug('---obj---'+obj);                     
            System.debug('recordid     = ' + obj.recordid);
            System.debug('respondeid   = ' + obj.responseid);            
            System.debug('fieldname   = ' + obj.fieldname);            
            
            if(obj.recordid != null) {
                Id recid = Id.valueof(obj.recordid);
                objType = recid.getSObjectType().getDescribe().getName(); 
                String s1 = obj.fieldname;
                String s2 = obj.recordid;
                
                String dynamicquery = 'Select Id,' + s1 + ' From ' + objType + ' where Id =' +' \'' + s2 + '\'';
                system.debug('dynamic query:'+dynamicquery);
                sobjlist = Database.query(dynamicquery);
                for(SObject sobj : sobjlist){
                   oldval = (string)sobj.put(obj.fieldname,obj.responseid);
                }
                if(sobjlist.size() > 0){
                    update sobjlist;
                }
            }

           
        }
        catch (exception e){
            
            system.debug('Exception occured'+e.getmessage());
            
        }
    }
    
   
   
     
      
     
    public class MSTeamsResponseJSON {
        public string recordid    {get;set;}
        public string fieldname  {get;set;}
        public string responseid  {get;set;}
        

        
        public MSTeamsResponseJSON(){
        
        }
    }
    
}