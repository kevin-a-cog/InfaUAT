public class copyToClipBoardCtrl {
    @AuraEnabled
    public static string fetchSiteUrl(){
        
        string siteId = '';
        string siteUrl = '';
        for(Site sSite : [SELECT  Id, Name,  Status FROM Site Where  Name = 'eSupport' And Status = 'Active']){
            siteId = sSite.Id;
        }
        if(siteId != ''){
        for(SiteDetail sDetail : [SELECT   Id,SecureUrl FROM SiteDetail Where DurableId =: siteId]){
            siteUrl = sDetail.SecureUrl;
        }    
        }
        
        return siteUrl;
        
    }

}