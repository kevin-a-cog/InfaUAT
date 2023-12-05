/*
Class:          InvokableGenerateChatterPost
@Author:        Harshita Joshi
@Created Date:  17/11/2022
@Description:   AR-2969 Invocable class for generating chatter post on engagement when project is created.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag                                                       
*************************************************************************************************************************************
*/
public class InvokableGenerateChatterPost {
    /*Method to get the add chatter post.
    * @param Name - list<projectIds>
    * @return n/a
    */
    @InvocableMethod(label='Generate Chatter POst' description='Generate Chatter Post')
    public static void invokeChatterPost(List<Id> ids) {
        globalApexManager GAM = new globalApexManager();
        if(ids.size()<>0){
            //fetch group
            list<CollaborationGroup> adGroup = [SELECT Id from CollaborationGroup where name='Adoption Services Approvers'];
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();       
            for(pse__Proj__c pro:[select psa_pm_Engagement__r.OwnerId,id,pse__Project_Manager__r.pse__Salesforce_User__c,pse__Account__r.Name,pse__Account__c,Name,psa_pm_Engagement__r.Name,psa_pm_Engagement__c,psa_pm_Engagement__r.CSM_Closing_Comments__c,psa_pm_Engagement__r.Opportunity__r.Name,psa_pm_Engagement__r.Opportunity__c from pse__Proj__c where id in : ids]){
                String message ='';            
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
              //  String accountLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Account/'+ pro.pse__Account__c + '/view';
              //  String projectLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/pse__Proj__c/'+ pro.id + '/view';
              //  String engagementLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Engagement__c/'+ pro.psa_pm_Engagement__c + '/view';
              //  String opportunityLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Engagement__c/'+ pro.psa_pm_Engagement__r.Opportunity__c + '/view';
                input.subjectId = pro.psa_pm_Engagement__c;
                message= '\n\r';
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                ConnectApi.TextSegmentInput textSegment11 = new ConnectApi.TextSegmentInput();
                textSegment11.text = message;
                body.messageSegments.add(textSegment11);
                
                //Get the chatter message
                
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = pro.psa_pm_Engagement__r.OwnerId;
                body.messageSegments.add(mentionSegmentInput);
                if(pro.pse__Project_Manager__r.pse__Salesforce_User__c != null){
                    ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput1.id = pro.pse__Project_Manager__r.pse__Salesforce_User__c;
                    body.messageSegments.add(mentionSegmentInput1);
                }
                
                if(adGroup.size()<>0){
                    ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput2.id = adGroup[0].id;
                    body.messageSegments.add(mentionSegmentInput2);
                }
                message = '\n\n';
                body = getTextParagraph(message,body);
                //chatter body
                message = '\nHi,\n\n';
                body = getTextParagraph(message,body);
                message = 'A new Project has been created under this Engagement.\n';
                body = getTextParagraph(message,body);
                message = 'Please find the details below and take necessary action.\n';
                body = getTextParagraph(message,body);
                message = 'Have a great day!\n';
                body = getTextParagraph(message,body);
                message = '\n\n';
                body = getTextParagraph(message,body);
                
                //Account Section
                
                message = 'Account Name : ';
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = message;
                body.messageSegments.add(textSegment);
                body.messageSegments.add(ChatterService.inputLink(pro.pse__Account__c));
                //body = getHyperLink(pro.pse__Account__r.Name,accountLink,body);
                message = '\n\n';
                body = getTextParagraph(message,body);
                message = '\n\n';
                body = getTextParagraph(message,body);
                
                //Project Section
                
                message = 'Project Name : ';
                ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
                textSegment1.text = message;
                body.messageSegments.add(textSegment1);
                body.messageSegments.add(ChatterService.inputLink(pro.Id));
                //body = getHyperLink(pro.Name,projectLink,body);
                message = '\n\n';
                body = getTextParagraph(message,body);
                if(pro.pse__Project_Manager__c != null && pro.pse__Project_Manager__r.pse__Salesforce_User__c != null){
                    message = 'Project Manager : ';
                    ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
                    textSegment2.text = message;
                    body.messageSegments.add(textSegment2);
                    ConnectApi.MentionSegmentInput mentionSegmentInput3 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput3.id = pro.pse__Project_Manager__r.pse__Salesforce_User__c;
                    body.messageSegments.add(mentionSegmentInput3);
                    message = '\n\n';
                    body = getTextParagraph(message,body);
                }
                
                //Engagement Section
                if(pro.psa_pm_Engagement__c != null){
                    message = 'Engagement Name : ';
                    ConnectApi.TextSegmentInput textSegment4 = new ConnectApi.TextSegmentInput();
                    textSegment4.text = message;
                    body.messageSegments.add(textSegment4);
                    body.messageSegments.add(ChatterService.inputLink(pro.psa_pm_Engagement__c));
                    //body = getHyperLink(pro.psa_pm_Engagement__r.Name,engagementLink,body);
                    message = '\n\n';
                    body = getTextParagraph(message,body);
                    message = 'CSM Name : ';
                    ConnectApi.TextSegmentInput textSegment5 = new ConnectApi.TextSegmentInput();
                    textSegment5.text = message;
                    body.messageSegments.add(textSegment5);
                    ConnectApi.MentionSegmentInput mentionSegmentInput4 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput4.id = pro.psa_pm_Engagement__r.OwnerId;
                    body.messageSegments.add(mentionSegmentInput4);
                    if(pro.psa_pm_Engagement__r.CSM_Closing_Comments__c != null){
                        message = '\n'+pro.psa_pm_Engagement__r.CSM_Closing_Comments__c;
                        body = getTextParagraph(message,body);
                    }
                    message = '\n\n';
                    body = getTextParagraph(message,body);
                    
                    if(pro.psa_pm_Engagement__r.Opportunity__c != null){
                        //Opportunity Section
                        message = 'Opportunity Name : ';
                        ConnectApi.TextSegmentInput textSegment6 = new ConnectApi.TextSegmentInput();
                        textSegment6.text = message;
                        body.messageSegments.add(textSegment6);
                        body.messageSegments.add(ChatterService.inputLink(pro.psa_pm_Engagement__r.Opportunity__c));
                        //body = getHyperLink(pro.psa_pm_Engagement__r.Opportunity__r.Name,opportunityLink,body);
                        message = '\n\n';
                        body = getTextParagraph(message,body);
                    }
                    input.body = body;
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input); 
                    batchInputs.add(batchInput);
                    
                }
                
            }//loop ends here
            if(!Test.isRunningTest()){
                try{
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
                }
                catch(Exception e){
                 GAM.CreateExceptionRecords('InvokableGenerateChatterPost.invokeChatterPost() -> ' + e.getCause(),e.getmessage(), ids[0]);
                }
            }
            
        } 
        
    }
    
    
    /*Method to create body as paragraph for chatter post.
    * @param Name - String,ConnectApi.MessageBodyInput
    * @return ConnectApi.MessageBodyInput
    */
    public static ConnectApi.MessageBodyInput getTextParagraph(String paragraphToBeAppended, ConnectApi.MessageBodyInput body) {
        
        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph;
        ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph;
        
        markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
        body.messageSegments.add(markupBeginSegmentParagraph);
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = paragraphToBeAppended;
        body.messageSegments.add(textSegment);
        
        markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
        body.messageSegments.add(markupEndSegmentParagraph);
        return body;
    }
    
}