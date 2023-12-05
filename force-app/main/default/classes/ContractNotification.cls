/*
* Class :        ContractNotification
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class Contract Notifications
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************

*/
public class ContractNotification {
    
    public static globalApexManager GAM = new globalApexManager();

    
    @InvocableMethod(label='Notify CSM on Contract' description='Notify CSM queue')
    public static void NotifyCSMs(List<id> contractIds){
        postFeedElementWithMention(contractIds);  
    }
    
    
    public static void postFeedElementWithMention(List<Id> ContarctIds){  
        
        
        Map<ID, set<ID>> mapAccountCSM = new map<Id, set<Id>>();  // Map of Account and CSM users assigned to Account      
        List<Contract>  lstContract = new List<Contract>();  
        
        lstContract = [select id,AccountId,Account.Name,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Name from Contract where Id in :ContarctIds ];
        system.debug('**lstContract'+lstContract);
        
        for(AccountTeamMember atm:[ Select id,Userid,AccountId from AccountTeamMember where TeamMemberRole ='CSM'and AccountId in (Select AccountId from Contract where id in :ContarctIds)  order by createddate asc])
        {             
            if(!mapAccountCSM.containskey(atm.AccountId)){        
                Set<Id>  setuserid= new set<id>();                 
                setuserid.add(atm.userId);
                mapAccountCSM.put(atm.accountid,setuserid );       
            }
            else{
                mapAccountCSM.get(atm.accountid).add(atm.userid);
            }
        }
        
        Set<id> CSMManagersIds = new Set<id>();
        Group CSMGroup =  [Select Id from Group where type='Queue' and Name=: Label.INFA_CSM_Managers_Queue] ;
        for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =: CSMGroup.id]){
            CSMManagersIds.add(gm.UserOrGroupId);
        }
        
        
        // Bulk post to the Plan product feeds.
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for (Contract con : lstContract) {
            
            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            
            input.subjectId = con.id;
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            String mentions ='';
            
            if(mapAccountCSM.containskey(con.AccountId) ){
                
                for( id userid : mapAccountCSM.get(con.AccountId)){
                    
                    mentions= mentions + returnMentionFormat(userid);
                }
                
            }
            else {
                
                for( Id userid :CSMManagersIds){
                    mentions = mentions + returnMentionFormat(userid);
                }
            }
            
            String postContent = ', A new contract has been activated and new plan products have been processed for your account. Below are the details'+'\n\n'+
               ' Account Name : ' + Con.AccountId +'\n'+
            	'Accoun Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ Con.AccountId+'\n \n'+
                'Opportunity Name : '+ Con.SBQQ__Opportunity__r.Name+'\n'+
                'Opportunity Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ Con.SBQQ__Opportunity__c+'\n \n';
            
            String fullbody = mentions +postContent;
            
            //format the textwith mentions 
            body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(fullbody);
            
            input.body = body;
            
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
            
        }
        
        system.debug('**batchInputs'+batchInputs);
        
        if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0){
            Try{
            // API call to post in bulk mode
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
            Catch(Exception e){
              GAM.CreateExceptionRecords('ContractNotification-->postFeedElementWithMention-->Chatterpost failed', e.getMessage(),null);

            }
        }
        
        
        
    }
    
    // Format the id to string
    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }
    
    
}