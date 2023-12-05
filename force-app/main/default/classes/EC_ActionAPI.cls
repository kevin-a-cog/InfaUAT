@RestResource(urlMapping='/ECActionUpsert')
global without sharing class EC_ActionAPI {
    @HttpPost
    global static String doPost(ActionUpsertWrapper actiondetails) {
        String returnMsg='';
        try{
            Set<String> existingquestions = new Set<String>();
            upsert actiondetails.action EC_Action__c.AEM_Action_Id__c;
            List<EC_Questions__c> questions = new List<EC_Questions__c>();
            for(EC_Questions__c ques: actiondetails.questions){
                existingquestions.add(ques.AEM_Question_Id__c);
                EC_Questions__c qObj = ques;
                qObj.Action_Engagement_Catalog__c=actiondetails.action.Id;
                questions.add(qObj);
            }
            upsert questions EC_Questions__c.AEM_Question_Id__c;
            if(existingquestions.size()>0){
                delete [SELECT id from EC_Questions__c WHERE AEM_Question_Id__c NOT IN :existingquestions AND Action_Engagement_Catalog__c = :actiondetails.action.Id];
            }
            returnMsg='Success';
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            returnMsg = e.getMessage();
        }
        return returnMsg;
    }

    global class ActionUpsertWrapper{
        public EC_Action__c action{get;set;}
        public List<EC_Questions__c> questions{get;set;}
    }
}