/*
    @created by       : balajip
    @created on       : 08/07/2020
    @Purpose          : ArticleQuality handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description   Jira No.       Tag
 ****************************************************************************************************
 */

public class ArticleQualityTriggerHandler extends TriggerHandler {

    //Iniitialize the helper method to be called
    private ArticleQualityTriggerHelper helper = new ArticleQualityTriggerHelper();

    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.updateRelatedArticles((Map<Id, aqi_ltng_mng__Article_Quality__c>) newMap);        
    }
        
    //Methods related to the module to be called in after update context
    public override void beforeUpdate() {        

    }
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {
        helper.updateRelatedArticles((Map<Id, aqi_ltng_mng__Article_Quality__c>) newMap);
    }

    //Methods related to the module to be called in before insert context
    public override void afterDelete() {
        
    }
}