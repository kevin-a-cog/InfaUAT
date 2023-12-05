@isTest
public class helpNetworkModerationControllerTest {
    
    
    static testmethod void testmethod0(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'PendingReview';
        insert fc;
        
        NetworkActivityAudit na = new NetworkActivityAudit();
        na.EntityId = fc.Id;
        na.Action = 'ModerationRuleReview';
        na.NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        
        test.startTest();
        helpNetworkModerationController.ModerationDetailsDisplay();
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod02(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        item.NetworkScope = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'Published';
        //insert fc;
        
        NetworkModeration na = new NetworkModeration();
        na.EntityId = item.Id;
        na.ModerationType = 'FlagAsSpam';
        na.NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        insert na;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
        helpNetworkModerationController.FlaggedItemsDisplay();
        test.stopTest();
        
    }
    
    
    
    @isTest(SeeAllData=true)
    public static void testmethod03(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        item.NetworkScope = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'Published';
        insert fc;
        
        NetworkModeration na = new NetworkModeration();
        na.EntityId = fc.Id;
        na.ModerationType = 'FlagAsSpam';
        na.NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        insert na;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
        helpNetworkModerationController.FlaggedItemsDisplay();
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod01(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='PendingReview';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        test.startTest();
        helpNetworkModerationController.ModerationDetailsDisplay();
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod00(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'PendingReview';
        insert fc;
        
        test.startTest();
        helpNetworkModerationController.ModerationDetailsDisplay();
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod1(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='PendingReview';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        test.startTest();
        helpNetworkModerationController.FlaggedItemsDisplay();
        test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void testmethod11(){
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'PendingReview';
        insert fc;
        
        test.startTest();
        helpNetworkModerationController.FlaggedItemsDisplay();
        test.stopTest();
        
    }
    
    
    static testmethod void testmethod2(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='PendingReview';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'PendingReview';        
        
        test.startTest();
        helpNetworkModerationController.ApproveAction(item.Id);
        helpNetworkModerationController.RejectAction(item.Id);      
        test.stopTest();
        
    }
    
    
    
    static testmethod void testmethod3(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        insert fc;
        
        test.startTest();
        try{
            helpNetworkModerationController.ApproveAction(fc.Id);
            helpNetworkModerationController.RejectAction(fc.Id);
        }
        Catch(Exception ex){}
        
        test.stopTest();
        
    }
    
    static testmethod void testmethod4(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        fc.status = 'PendingReview';
        
        test.startTest();       
        try{
            helpNetworkModerationController.ModerationDetailDisplayOnId(item.Id);
        }
        Catch(Exception ex){}        
        test.stopTest();
        
    }
    
    static testmethod void testmethod5(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        Topic a = new Topic(Name='cloud xyz',NetworkId=networkId,Description='abcd');
        insert a;
           
        
        FeedItem item = new FeedItem();
        item.Body = '<p>test comment mutliple images<img src="sfdc://0696C000002CRb1QAG" alt="bug"></img><img src="sfdc://0696C000002CRbGQAW" alt="600x75 (1)"></img></p>';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        item.NetworkScope = networkId;
        insert item;
        
        TopicAssignment ta = new topicAssignment(topicId=a.Id);
        ta.entityId= item.Id;
        ta.NetworkId = networkId;
        insert ta;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = '<p>test comment mutliple images<img src="sfdc://0696C000002CRb1QAG" alt="bug"></img><img src="sfdc://0696C000002CRbGQAW" alt="600x75 (1)"></img></p>';
        insert fc;
        
        test.startTest();       
        try{
            Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
            helpNetworkModerationController.ModerationDetailDisplayOnId(fc.Id);
        }
        Catch(Exception ex){}        
        test.stopTest();        
    }
    
    /*I2RT-8826*/
    static testmethod void testmethod9(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        Topic a = new Topic(Name='cloud xyz',NetworkId=networkId,Description='abcd');
        insert a;
        
        CollaborationGroup grp= new CollaborationGroup();
        grp.Name='testabc';
        grp.NetworkId=networkId;
        grp.Description='abcd';
        grp.CollaborationType = 'Public';
        insert grp;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'CZDSTOU'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        FeedItem item = new FeedItem();
        item.Body = '<p>test comment mutliple images<img src="sfdc://' + cvlist.contentdocumentId +'" alt="bug"></img><img src="sfdc://0696C000002CRbGQAW" alt="600x75 (1)"></img></p>';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = grp.Id;
        item.NetworkScope = networkId;
        insert item;
        
        /*TopicAssignment ta = new topicAssignment(topicId=a.Id);
        ta.entityId= item.Id;
        ta.NetworkId = networkId;
        insert ta;*/        
        
        test.startTest();       
        try{
            Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
            helpNetworkModerationController.ModerationDetailDisplayOnId(item.Id);
        }
        Catch(Exception ex){}        
        test.stopTest();        
    }
    
    /*I2RT-8826*/
    static testmethod void testmethod6(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        insert fc;
        
        test.startTest();       
        try{
            helpNetworkModerationController.ModerationDetailDisplayOnId(fc.Id);
            helpNetworkModerationController.DeleteItem(item.Id);
            //helpNetworkModerationController.UnflagItem(item.Id);
            helpNetworkModerationController.UnflagSelectedItems('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.ApproveSelectedRecords('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.RejectSelectedRecords('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.DeleteSelectedItems('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
        }
        Catch(Exception ex){}        
        test.stopTest();        
    }
    
    
    
    static testmethod void testUnflagItem(){        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.Status ='Published';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        insert fc;
        
        test.startTest();       
        try{
            helpNetworkModerationController.UnflagItem(item.Id);
            helpNetworkModerationController.UnflagSelectedItems('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.ApproveSelectedRecords('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.RejectSelectedRecords('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.DeleteSelectedItems('[{"AuditId":"0D77j000000J8NnCAK","ContentBody":"flaggedcomment5","ContentCreator":"Test Creation","ContentStatus":"Published","ContentTitle":"NA","CreatedDate":"2022-04-14","EntityType":"FeedComment","FlaggedBy":"Test Creation","ModerationType":"FlagAsInappropriate","Note":"abcd","URL":"/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId=0D77j000000J8NnCAK"}]');
            helpNetworkModerationController.getRelatedFilesByRecordId(item.Id);
            
        }
        Catch(Exception ex){}        
        test.stopTest();        
    }
    
    static testmethod void testmethod7(){
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        FeedItem item = new FeedItem();
        item.Body = 'testnjsjjsj';
        item.Title = 'Title';
        item.ParentId = userinfo.getUserId();
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = item.Id;
        fc.CommentBody = 'gdjwdhwjkdkwdj';
        insert fc;
        
        /*NetworkModeration nm = new NetworkModeration();
        nm.EntityId = fc.Id;
        nm.NetworkId = NetworkId;
        insert nm;*/
        Set<Id> usrId = new Set<Id>();
        usrId.add(userinfo.getUserId());
        
        test.startTest();       
        try{            
            
            helpNetworkModerationController.DeleteItem(fc.Id);
            helpNetworkModerationController.getUserNames(usrId);
        }
        Catch(Exception ex){}        
        test.stopTest();        
    }
    
    static testmethod void testIncrement() {
        helpNetworkModerationController.justIncrement();
    }
    
}