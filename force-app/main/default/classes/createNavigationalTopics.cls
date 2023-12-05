public class createNavigationalTopics {
    public static Map<Id, String> topicsMap = new Map<Id, String>();
    public static Map<Id, String> navTopicsMap = new Map<Id, String>();
    public static String communityName = label.help_siteName;
    public static String communityId;
    public static boolean debugMode = false;
     
    public createNavigationalTopics(String jsonData, Boolean debugMode){
        if(debugMode){
            createNavigationalTopics.debugMode = debugMode;
        } 
        
        if(jsonData == null || jsonData == ''){
            jsonData = '[{"topic":"Data Engineering Integration","child":[{"topic":"Big Data Home"},{"topic":"Data Engineering Integration"},{"topic":"Enterprise Data Catalog","child":[{"topic":"Informatica Enterprise Information Catalog"}]},{"topic":"Enterprise Data Preparation"}]},{"topic":"Cloud Integration","child":[{"topic":"Cloud Application Integration"},{"topic":"Cloud Data Integration","child":[{"topic":"Cloud Support"},{"topic":"IICS Community Support"},{"topic":"Dataloader"}]},{"topic":"Cloud Customer 360"},{"topic":"Cloud Data Wizard"},{"topic":"Informatica Cloud for Amazon AWS"},{"topic":"Informatica for Microsoft"},{"topic":"Cloud Integration Hub"},{"topic":"Cloud B2B Gateway"},{"topic":"Cloud Developers"},{"topic":"Cloud API Management"},{"topic":"Cloud Data Integration-Elastic"},{"topic":"Cloud RCA"},{"topic":"Cloud Assurance Service"}]},{"topic":"Complex Event Processing","child":[{"topic":"Proactive Monitoring","child":[{"topic":"PowerCenter Operations"}]}]},{"topic":"Data Integration","child":[{"topic":"B2B Data Exchange"},{"topic":"B2B Data Transformation"},{"topic":"Data Integration Hub"},{"topic":"Data Services"},{"topic":"Data Validation Option"},{"topic":"Fast Clone"},{"topic":"Informatica Platform","child":[{"topic":"Informatica 9"},{"topic":"Informatica 9.5.1"},{"topic":"Informatica 9.6.1"}]},{"topic":"Metadata Manager","child":[{"topic":"Metadata Reporter"}]},{"topic":"PowerCenter"},{"topic":"PowerExchange"},{"topic":"PowerExchange Adapters"}]},{"topic":"Data Quality & Governance","child":[{"topic":"Data as a Service","child":[{"topic":"Address Doctor Cloud (Address Verification)"},{"topic":"Address Doctor (Address Verification (On-Premises)"}]},{"topic":"Data Explorer"},{"topic":"Data Quality"},{"topic":"Axon Data Governance"}]},{"topic":"Data Security Group (Formerly ILM)","child":[{"topic":"Data Archive"},{"topic":"Data Centric Security","child":[{"topic":"Dynamic Data Masking"}]},{"topic":"Secure@Source (Data Privacy Management)"},{"topic":"Secure Testing","child":[{"topic":"Data Subset"},{"topic":"Test Data Management"},{"topic":"Test Data Generation"},{"topic":"Test Data Warehouse"}]}]},{"topic":"Master Data Management","child":[{"topic":"Identity Resolution"},{"topic":"MDM - Relate 360"},{"topic":"Multidomain MDM"},{"topic":"MDM Registry Edition"}]},{"topic":"Process Automation","child":[{"topic":"ActiveVOS"}]},{"topic":"Product Information Management","child":[{"topic":"Informatica Procurement"},{"topic":"MDM - Product 360"}]},{"topic":"Ultra Messaging","child":[{"topic":"Ultra Messaging Options"}]}]';
        }
        
        List<navTopics> navTopicsList = (List<navTopics>) System.JSON.deserialize(jsonData,  List<navTopics>.class);
        communityId = [select id from network where name = :communityName limit 1].id;
        createNavigationalTopics.topicsMap = createNavigationalTopics.getTopicId();
        createNavigationalTopics.navTopicsMap = createNavigationalTopics.getNavParentId();
        createNavigationalTopics.processNavigationalTopicCreation(navTopicsList);
        
    }
    
    public static void processNavigationalTopicCreation(List<navTopics> ntRecords){
        for(navTopics nt : ntRecords){
            String topicId = createNavigationalTopic(nt.topic, null);
            
            if(nt.child != null){
                System.debug('child loop start');
                for(navTopics ntchild1 : nt.child){
                    String parent1 = createNavigationalTopic(ntchild1.topic, topicId);
                    
                    if(ntchild1.child != null){
                        for(navTopics ntchild2 : ntchild1.child){
                            createNavigationalTopic(ntchild2.topic, parent1);
                            //if(nt.child != null){}
                        }
                    }
                }
            }
        }
    }
    
    public static String createNavigationalTopic(String topicName, String parentId){
        try{
            ConnectApi.ManagedTopic managedTopics;
            
            
            if(debugMode){
                System.debug('topicName > ' + topicName);
            }else{
                if(parentId != null){
                    managedTopics = ConnectApi.ManagedTopics.createManagedTopicByName(communityId, topicName, ConnectApi.ManagedTopicType.Navigational, parentId);
                }
                else if(parentId == null){
                    managedTopics = ConnectApi.ManagedTopics.createManagedTopicByName(communityId, topicName, ConnectApi.ManagedTopicType.Navigational);
                }
                
                if(managedTopics <> null){
                    system.debug('managedTopics created > '+ managedTopics.topic.name +' with id > ' + managedTopics.id);
                    navTopicsMap = getNavParentId();
                    return managedTopics.id;
                }
            }
        }catch(Exception ex){
            System.debug('Exception > ' + ex.getMessage() + 'on line . ' + ex.getLineNumber());
        }
        return null;
    }
    
      public static Map<Id, String> getNavParentId(){
        Map<Id, String> navTopicsMap = new Map<Id, String>();
        for(ConnectApi.ManagedTopic navTopic : ConnectApi.ManagedTopics.getManagedTopics(communityId, ConnectApi.ManagedTopicType.Navigational).managedTopics){
            System.debug('navTopic > ' + navTopic.topic.name);
            navTopicsMap.put(navTopic.Id, navTopic.topic.name);
        }
        return navTopicsMap;
    }
    
    public static Map<Id, String> getTopicId(){
        Map<Id, String> topicsMap = new Map<Id, String>();
        for(ConnectApi.Topic tpic : ConnectApi.Topics.getTopics(communityId).topics){
            System.debug('toipc > ' + tpic.name);
            topicsMap.put(tpic.Id, tpic.Name);
        }
        return topicsMap;
    }    
    public class navTopics{
        public String topic;
        public List<navTopics> child;
        public navTopics(){
            
        }
        public navTopics(String topic, List<navTopics> child){
            this.topic = topic;
            this.child = child;
        }
    }
    
}