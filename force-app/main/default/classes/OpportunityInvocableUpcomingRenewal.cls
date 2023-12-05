/****************************************************************************************************************
Class:          OpportunityInvocableUpcomingRenewal
@Author:        vsabbell 
@Created Date:  7/23/2018
@Description:  Notify CSMs of upcoming renewal in 120 days(AR-747).

*/
public class OpportunityInvocableUpcomingRenewal {



    Private Static final String TeamMemberRole_CSM = 'CSM';

    @InvocableMethod(label='Upcoming Renewal in 120 days' description='Notify CSM of Upcoming Renewal')
    
    public static void UpcomingRenewalin120days(List<Id> OpportunityIds){
        postFeedElementWithMention(OpportunityIds);  //T01- pass full list of optys 
    }

    

    public static void postFeedElementWithMention(List<Id> OpportunityIds){  
    
    //-----------------------------------------------------------------------------------------<T01>
        
        Map<ID, set<ID>> mapAccountCSM = new map<Id, set<Id>>();  // Map of Account and CSM users assigned to Account      
        List<Opportunity>  lstOpportunity = new List<Opportunity>();  // List of renewal optys created/updated
        

       
        for(AccountTeamMember atm : [select id,userId,AccountId from AccountTeamMember
                where AccountId In (select AccountId from Opportunity where Id in :OpportunityIds) and  TeamMemberRole = :TeamMemberRole_CSM  order by createddate asc])
        {
             
             Set<Id>  setuserid= new set<id>();             
             if(mapAccountCSM.keyset().contains(atm.AccountId)){                     
             setuserid= mapAccountCSM.get(atm.AccountId);
             
             setuserid.add(atm.userId);
             
             mapAccountCSM.put(atm.accountid,setuserid );
                    
             }
             
             else{
                          
             setuserid.add(atm.userid);
             
             mapAccountCSM.put(atm.accountid,setuserid);
             
             }
            
        }
        
        
        lstOpportunity = [select id,name,AccountId,Account.name,StageName,CloseDate,New_Org_Opportunity_Number__c  from Opportunity where Id in :OpportunityIds ];

            
        // Bulk post to the opportnity feeds.
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (Opportunity opp : lstOpportunity) {                    
              if(mapAccountCSM!=null && mapAccountCSM.get(opp.AccountId)!=null){               
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = opp.id;                
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();                
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();                                
                String mentions ='';                
                for( id userid : mapAccountCSM.get(opp.AccountId)){                
                    mentions= mentions + returnMentionFormat(userid);
                }
                String postContent = 'A renewal opportunity is due to close in 140 days. '+' Please find the details below \n \n'+
                      'Opportunity: '+Opp.name+'\n\n' +
                      'Opportunity Number: '+Opp.New_Org_Opportunity_Number__c+'\n\n' +
                      'Opportunity Link: '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'\n \n'+
                      'Account: '+opp.account.name +'\n \n'+
                      'Link to Account:'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.AccountId+'\n \n'+
                      'Stage: '+opp.StageName+ '\n\n'+
                      'Close Date: '+opp.CloseDate.format();        
                String fullbody = mentions+postContent;               
                //format the textwith mentions 
                body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(fullbody);
                input.body = body;
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
                }
            }

      if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0)
        // API call to post in bulk mode
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    
    //---------------------------------------------------------------------------------------------------------</T01>
    
    }
                
    // Format the id to string
    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }

}