/*
  @description       : 
  @author            : Sathish Rajalingam
  @group             : 
  @last modified on  : 01-29-2021
  @last modified by  : Sathish Rajalingam
  Modifications Log 
  
  Tag       |  Date           |  Modified by                |  Jira reference   |   ChangesMade    
   1       |  22-Jan-2021     |  Ranjan Kishore             |      I2RT - 869   |   Copy Icon will be shown based on the Article Visibility 
   2       |  18-Jan-2022     |  Sathish Rajalingam         |      I2RT-3137	|   Content on PDF Render for non-English articles is distorted and the language continues to be English 
   
*/

({
    getKnowledgeArticleId: function (component, event) {
        console.log('recordId', component.get('v.recordId'));
        var action1 = component.get("c.getArticle");
        action1.setParams({ articleId: component.get('v.recordId') });
        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var articleRecord = response.getReturnValue();
                component.set('v.knowledgeArticleId', articleRecord.KnowledgeArticleId)
                component.set('v.isPublicArticle', articleRecord.Visible_In_Public_Knowledge_Base__c);/* Tag 1 */
                component.set('v.knowledgeLanguage', articleRecord.Language);/* Tag 2 */
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action1);
    }
})