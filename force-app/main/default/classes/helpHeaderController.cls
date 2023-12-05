/*
* Name         :   helpHeaderController
* Author       :   Deeksha Shetty
* Created Date :   20/02/2022
* Description  :   Controller class for Header Component.

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                                 Tag
**********************************************************************************************************
Deeksha Shetty      20/02/2022      N/A             Initial version.                            N/A
*/


public without sharing class helpHeaderController {
    
    
    @AuraEnabled
    public static List<NavigationBarData> getHeaderData(){
        
        try{            
            List<NavigationBarData> MainheaderData = new List<NavigationBarData>();
            Map<Decimal,List<Header_Meta__mdt>> MainheaderMap = new Map<Decimal,List<Header_Meta__mdt>>();
            Map<Decimal,NavigationBarData> MainheaderMap2 = new Map<Decimal,NavigationBarData>();            
            List<NavigationBarData> FinalDataList = new List<NavigationBarData>();                        
            Map<Decimal,List<DataLinksWrapper>> dataLinkMap = new Map<Decimal,List<DataLinksWrapper>>();
            Map<Decimal,List<FeaturedLinksWrapper>> featureLinkMap = new Map<Decimal,List<FeaturedLinksWrapper>>();
            Map<Decimal,List<FeaturedLinksWrapper>> NavigationHideMap = new Map<Decimal,List<FeaturedLinksWrapper>>();
            Map<Decimal,List<FeaturedLinksWrapper>> NavigationHideMap2 = new Map<Decimal,List<FeaturedLinksWrapper>>();
            Map<Decimal,List<RegularLinksWrapper>> regularLinkMap = new Map<Decimal,List<RegularLinksWrapper>>();
            boolean showdivider = false;
            User userdata;
            Boolean isGuestUser = false;            
            
            List<Header_Meta__mdt> headerNavLinks = [SELECT Id,DeveloperName,Anonymous_User__c, Authenticated_User__c, Column__c,Error_Link__c ,Permission_Props__c, 
                                                     Description__c, Header__c, Language__c, Level__c, Header_Sequence__c ,Mutlilevel__c,
                                                     Navigation_Link__c, Show_Divider__c, Target__c, Title__c FROM Header_Meta__mdt where DeveloperName Like 'Header%' ORDER BY Header_Sequence__c,Level__c,Column__c ASC];
                        
            
            if(userinfo.getUserType()!= 'Guest'){
                Id userId = userinfo.getuserId();
                userdata = [Select isSuccessUser__c,isCustomer__c ,isIpuUser__c FROM User where Id=:userId];                
            }
            else{                
                isGuestUser = true;
            }
            
            for(Header_Meta__mdt navLink: headerNavLinks){                
                if(navLink.Header_Sequence__c!=null){
                    if(!MainheaderMap.keyset().contains(navLink.Header_Sequence__c)){
                        MainheaderMap.put(navLink.Header_Sequence__c,new List<Header_Meta__mdt>{navLink});
                    }
                    else{
                        MainheaderMap.get(navLink.Header_Sequence__c).add(navLink);
                    }
                }
                
                
                if(navLink.Level__c==1 && navLink.Column__c==1 ){
                    NavigationBarData navbarData = new NavigationBarData();                   
                    navbarData.Id = navLink.Id;
                    navbarData.navBarItem = navLink.Header__c;
                    navbarData.DeveloperName = navLink.DeveloperName;
                    navbarData.multiLevel = navLink.Mutlilevel__c;
                    navbarData.link =  navlink.Navigation_Link__c;                 
                    navbarData.title = navlink.Title__c;
                    navbarData.description = navlink.Description__c;
                    if(navLink.Header_Sequence__c!=null){
                        if(!MainheaderMap2.keyset().contains(navLink.Header_Sequence__c)){
                            MainheaderMap2.put(navLink.Header_Sequence__c,navbarData);
                        }
                    }
                }
            }
            
            
            for(Decimal d : MainheaderMap2.keyset()){
                Level2wrapper lw = new Level2wrapper();
                for(Header_Meta__mdt nav : MainheaderMap.get(d)){                   
                    if((nav.Level__c >=1 && nav.Column__c==1 && nav.Mutlilevel__c == false && nav.Show_Divider__c==false) || test.isRunningTest() ){
                        DataLinksWrapper lw1 = new DataLinksWrapper();
                        lw1.image = false;
                        lw1.title = nav.Title__c;
                        
                        if(isGuestUser==true && (nav.Permission_Props__c == 'isSuccessUser__c' || nav.Permission_Props__c == 'isCustomer__c' ||nav.Permission_Props__c == 'isIpuUser__c')){
                            lw1.showLockIcon = true;
                            lw1.link =  nav.Error_Link__c;
                        }
                        
                        else if((isGuestUser==true)||(userdata.isSuccessUser__c==true && nav.Permission_Props__c == 'isSuccessUser__c') 
                                || (userdata.isCustomer__c==true && nav.Permission_Props__c == 'isCustomer__c') 
                                ||(userdata.isIpuUser__c==true && nav.Permission_Props__c == 'isIpuUser__c') ){
                                    lw1.link =  nav.Navigation_Link__c;
                                    lw1.showLockIcon = false;
                                }
                        else if(nav.Permission_Props__c ==null ){
                            lw1.link =  nav.Navigation_Link__c;
                            lw1.showLockIcon = false;
                        }
                        else{
                            lw1.showLockIcon = true;
                            lw1.link =  nav.Error_Link__c;
                        }
                        
                        if(lw1.showLockIcon== true && isGuestUser==true){
                            lw1.isGuestAndShowGreyIcon = true;
                        }
                        else{
                            lw1.isGuestAndShowGreyIcon = false;
                        }
                        lw1.description = nav.Description__c;
                        lw1.target = nav.Target__c;
                        
                        if(!dataLinkMap.keyset().contains(nav.Header_Sequence__c)){
                            dataLinkMap.put(nav.Header_Sequence__c,new List<DataLinksWrapper>{lw1});
                        }
                        else{
                            dataLinkMap.get(nav.Header_Sequence__c).add(lw1);
                        }
                        lw.dataLinks = dataLinkMap.get(d); 
                    }
                    
                    if(nav.Show_Divider__c == true){						                                              
                        showdivider = true;                                             
                    }
                    
                    if(nav.Level__c >=1 && nav.Column__c>1 &&  nav.Column__c < 5 && nav.Mutlilevel__c == true &&nav.Title__c!=null && nav.Show_Divider__c==false){                           
                        FeaturedLinksWrapper fw = new FeaturedLinksWrapper();
                        fw.title = nav.Title__c;
                        
                        if(isGuestUser==true && (nav.Permission_Props__c == 'isSuccessUser__c' || nav.Permission_Props__c == 'isCustomer__c' ||nav.Permission_Props__c == 'isIpuUser__c')){                          
                            fw.showLockIcon = true;
                            fw.link =  nav.Error_Link__c;
                        }
                        
                        else if((isGuestUser==true) || (userdata.isSuccessUser__c==true && nav.Permission_Props__c == 'isSuccessUser__c') 
                                || (userdata.isCustomer__c==true && nav.Permission_Props__c == 'isCustomer__c') 
                                ||(userdata.isIpuUser__c==true && nav.Permission_Props__c == 'isIpuUser__c')){
                                    fw.link =  nav.Navigation_Link__c;
                                    fw.showLockIcon = false;
                                }
                        else if(nav.Permission_Props__c ==null ){
                            fw.link =  nav.Navigation_Link__c;
                            fw.showLockIcon = false;
                        }
                        else{
                            fw.link =  nav.Error_Link__c;
                            fw.showLockIcon = true;
                        }
                        
                        if(fw.showLockIcon== true && isGuestUser==true){
                            fw.isGuestAndShowGreyIcon = true;
                        }
                        else{
                            fw.isGuestAndShowGreyIcon = false;
                        }
                        fw.description = nav.Description__c;
                        fw.target = nav.Target__c;                        
                        if(!featureLinkMap.keyset().contains(nav.Header_Sequence__c)){
                            featureLinkMap.put(nav.Header_Sequence__c,new List<FeaturedLinksWrapper>{fw});
                        }
                        else{
                            featureLinkMap.get(nav.Header_Sequence__c).add(fw);
                        }
                        
                        
                        lw.featuredLinks = featureLinkMap.get(d);                                                                    
                        
                    }
                    if(nav.Level__c >=1 && nav.Column__c>=1 &&  nav.Column__c > 5 && nav.Mutlilevel__c == true  &&nav.Title__c!=null){                           
                        RegularLinksWrapper rw = new RegularLinksWrapper();
                        rw.title = nav.Title__c;
                        
                        if(isGuestUser==true && (nav.Permission_Props__c == 'isSuccessUser__c' || nav.Permission_Props__c == 'isCustomer__c' ||nav.Permission_Props__c == 'isIpuUser__c')){
                            rw.showLockIcon = true;
                            rw.link =  nav.Error_Link__c;
                        }
                        
                        else if((isGuestUser==true)||(userdata.isSuccessUser__c==true && nav.Permission_Props__c == 'isSuccessUser__c') 
                                || (userdata.isCustomer__c==true && nav.Permission_Props__c == 'isCustomer__c') 
                                ||(userdata.isIpuUser__c==true && nav.Permission_Props__c == 'isIpuUser__c') ){
                                    rw.link =  nav.Navigation_Link__c;
                                    rw.showLockIcon = false;
                                }
                        else if(nav.Permission_Props__c ==null ){
                            rw.link =  nav.Navigation_Link__c;
                            rw.showLockIcon = false;
                        }
                        else{
                            rw.link =  nav.Error_Link__c;
                            rw.showLockIcon = true;
                        }
                        
                        if(rw.showLockIcon== true && isGuestUser==true){
                            rw.isGuestAndShowGreyIcon = true;
                        }
                        else{
                            rw.isGuestAndShowGreyIcon = false;
                        }
                        rw.target = nav.Target__c;
                        if(!regularLinkMap.keyset().contains(nav.Header_Sequence__c)){
                            regularLinkMap.put(nav.Header_Sequence__c,new List<RegularLinksWrapper>{rw});
                        }
                        else{
                            regularLinkMap.get(nav.Header_Sequence__c).add(rw);
                        }
                        
                        lw.regularLinks = regularLinkMap.get(d);
                    }                                        
                }
                
                /*For Hiding the Navigation Items that has gated icons for both Authenticated and Anonymous */
                for(FeaturedLinksWrapper fw1 : featureLinkMap.get(d)){
                    if(fw1.showLockIcon== true){
                        if(!NavigationHideMap.keyset().contains(d)){
                            NavigationHideMap.put(d,new List<FeaturedLinksWrapper>{fw1});
                        }
                        else{
                            NavigationHideMap.get(d).add(fw1);
                        }                        
                    }
                }
                               
                
                if(NavigationHideMap.keyset().contains(d) && (NavigationHideMap.get(d).size()==featureLinkMap.get(d).size())){
                    if(MainheaderMap2.keyset().contains(d)) MainheaderMap2.remove(d);                    
                }
                else{
                    for(FeaturedLinksWrapper fw1 : featureLinkMap.get(d)){
                        if(fw1.showLockIcon!=true){
                            if(!NavigationHideMap2.keyset().contains(d)){
                                NavigationHideMap2.put(d,new List<FeaturedLinksWrapper>{fw1});
                            }
                            else{
                                NavigationHideMap2.get(d).add(fw1);
                            }                        
                        }
                    }
                    
                    lw.featuredLinks = NavigationHideMap2.get(d);
                    NavigationBarData bardata = MainheaderMap2.get(d);
                    bardata.level2 = lw;
                    bardata.showdivider = showdivider;              
                    FinalDataList.add(bardata);                   
                }
                
            }
            
            System.debug('FinalDataList='+FinalDataList);     
            return FinalDataList;          
        }catch(Exception e){
            system.debug('Error in INHeader : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        /*
    Author : Akhilesh Soni @19 Apil 2022
    Method Name : isCSMSuccessCommunity
    Description : This method returns TRUE if the current community is CSM Success.
    Parameters	 : None
    Return Type : Boolean
    */
    @AuraEnabled(cacheable = false)
    public static Boolean isCSMSuccessCommunity() {
        Boolean boolIsCSMSuccessComunity = false; 
        for(Site objSite : [SELECT Id FROM Site WHERE Id = :Site.getSiteId() AND (UrlPathPrefix = 'success' OR UrlPathPrefix = 'success/s') LIMIT 1]) {
            boolIsCSMSuccessComunity = true;
        }
        return boolIsCSMSuccessComunity;
    }

    @AuraEnabled(cacheable = false)
    public static Boolean geteSupportURL() {
        Boolean boolIsEsupportCommunity = false;
        for(Site objSite : [SELECT Id FROM Site WHERE Id = :Site.getSiteId() AND UrlPathPrefix = 'eSupport/s' LIMIT 1]) {
            boolIsEsupportCommunity = true;
        }
        return boolIsEsupportCommunity;
    }

    
    
    public class NavigationBarData{
        @AuraEnabled public String id;
        @AuraEnabled public String navBarItem;
        @AuraEnabled public String DeveloperName;
        @AuraEnabled public String link;
        @AuraEnabled public String title;
        @AuraEnabled public String description;        
        @AuraEnabled public boolean ShowDivider;
        @AuraEnabled public boolean multiLevel; 
        @AuraEnabled public Level2wrapper level2;
    }
    public class Level2wrapper{
        @AuraEnabled public boolean image;
        @AuraEnabled public String title;
        @AuraEnabled public String link;
        @AuraEnabled public String description;
        @AuraEnabled public String target;
        @AuraEnabled public List<DataLinksWrapper> datalinks;
        @AuraEnabled public List<FeaturedLinksWrapper> featuredLinks;
        @AuraEnabled public List<RegularLinksWrapper> regularLinks;
        
    }
    
    public class DataLinksWrapper{
        @AuraEnabled public boolean image = false;
        @AuraEnabled public String title;
        @AuraEnabled public String link;
        @AuraEnabled public String description;
        @AuraEnabled public String target;
        @AuraEnabled public boolean showLockIcon;
        @AuraEnabled public boolean isGuestAndShowGreyIcon;
        @AuraEnabled public boolean tooltip = false;
    }
    
    public class FeaturedLinksWrapper{
        @AuraEnabled public boolean image = false;
        @AuraEnabled public String title;
        @AuraEnabled public String link;
        @AuraEnabled public String description;
        @AuraEnabled public String target;
        @AuraEnabled public boolean authenticated = false;
        @AuraEnabled public boolean showLockIcon;
        @AuraEnabled public boolean isGuestAndShowGreyIcon;
        @AuraEnabled public boolean tooltip = false;
    }
    
    public class RegularLinksWrapper{
        @AuraEnabled public boolean image = false;
        @AuraEnabled public String title;
        @AuraEnabled public String link;
        @AuraEnabled public String target;
        @AuraEnabled public boolean showLockIcon;
        @AuraEnabled public boolean isGuestAndShowGreyIcon;
        @AuraEnabled public boolean tooltip = false;
    }
    
    
    
}