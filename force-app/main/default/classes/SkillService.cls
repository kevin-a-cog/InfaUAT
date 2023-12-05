/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to ProfileSkill Object
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
public with sharing class SkillService {

    public static final String TYPE_PRODUCT_ENGINEER = 'Product Engineer';
    public static final String TYPE_PRODUCT_SPECIALIST = 'Product Specialist';
    public static final String TYPE_PRODUCT_MANAGER = 'Product Manager';
    public static final String TYPE_PRODUCT_ENG_SPEC = 'Product Engineer/Specialist';
    public static final String TYPE_PRODUCT_SME = 'Product Engineer/Specialist';
    
    public static final String TYPE_OPERATIONS = 'GCS Operations';

    public static final String SKILL_ESCALATION_MANAGER = 'Escalation Manager';

    public static Map<String, ProfileSkill> mapSkillNameToSkill = new Map<String, ProfileSkill>();
    public static Map<String, CollaborationGroup> mapCollabGroupNameToGroup = new Map<String, CollaborationGroup>();
    public static Map<String, Id> mapQueueNameToQueueId = new Map<String, Id>();
    public static Map<Id, String> mapQueueIdToQueueName = new Map<Id, String>();
    public static Map<String, Id> mapServiceChannelNameToId = new Map<String, Id>();
    public static Map<String, Skill> mapNameToOmniSkill = new Map<String, Skill>();

    public static Set<Id> setEscalationUserId = new Set<Id>();

    static{
        List<ProfileSkill> lstProfileSkill = [Select Id, Name, Domain__c, Product_Name__c, Type__c, Queue_Name__c, 
                                                Public_Group_Name__c, Chatter_Group_Name__c, Permission_Set_Name__c, 
                                                Omni_Skill_Name__c 
                                              From ProfileSkill
                                              Order By Name];

        for(ProfileSkill profileSkill : lstProfileSkill){
            mapSkillNameToSkill.put(profileSkill.Name, profileSkill);
        }

        List<Group> lstGroup = [Select Id, Name, DeveloperName From Group Where Type='Queue'];
        for(Group grp:lstGroup){
            mapQueueNameToQueueId.put(grp.DeveloperName, grp.Id);
            mapQueueIdToQueueName.put(grp.Id, grp.Name);
        }

        List<CollaborationGroup> lstCollabGroup = [Select Id, Name From CollaborationGroup];
        for(CollaborationGroup collabGroup : lstCollabGroup){
            mapCollabGroupNameToGroup.put(collabGroup.Name, collabGroup);
        }

        List<ServiceChannel> lstServiceChannel = [Select Id, DeveloperName From ServiceChannel];
        for(ServiceChannel channel : lstServiceChannel){
            mapServiceChannelNameToId.put(channel.DeveloperName, channel.Id);
        }

        List<Skill> lstSkill = [Select Id, DeveloperName From Skill];
        for(Skill skl : lstSkill){
            mapNameToOmniSkill.put(skl.DeveloperName, skl);
        }

        List<GroupMember> lstGroupMember = [SELECT Id, GroupId, UserOrGroupId 
                                                FROM GroupMember 
                                                WHERE Group.Type = 'Queue' AND Group.DeveloperName = 'Escalation_Managers'];
        for(GroupMember groupMember : lstGroupMember){
            setEscalationUserId.add(groupMember.UserOrGroupId);
        }
    }

    public static List<String> getProductNames(String domainName){
        Set<String> setProductName = new Set<String>();
        for(ProfileSkill profileSkill : mapSkillNameToSkill.values()){
            if(String.isNotEmpty(profileSkill.Product_Name__c)){
                setProductName.add(profileSkill.Product_Name__c);
            }
        }

        List<String> lstProductName = new List<String>(setProductName);
        lstProductName.sort();

        return lstProductName;
    }

    public static Id getServiceChannelId(String serviceChannelDevName){
        return mapServiceChannelNameToId.get(serviceChannelDevName);
    }

    public static ProfileSkill getSkillByName(String skillName){
        ProfileSkill profileSkill;

        if(mapSkillNameToSkill.containsKey(skillName)){
            profileSkill = mapSkillNameToSkill.get(skillName);
        }

        return profileSkill;
    }

    //get the list of skill names of given type
    public static List<String> getSkillNames(String type){
        
        System.debug('type - ' + type);

        List<String> lstSkillName = new List<String>();

        for(ProfileSkill profileSkill : mapSkillNameToSkill.values()){
            if(type.equals(profileSkill.Type__c)){
                lstSkillName.add(profileSkill.Name);
            }
        }

        return lstSkillName;
    }
    
    //get the list of skill names of given type and product
    public static List<String> getSkillNames(String type, String productName){
        
        System.debug('type - ' + type);
        System.debug('productName - ' + productName);
        
        List<String> lstSkillName = new List<String>();

        for(ProfileSkill profileSkill : mapSkillNameToSkill.values()){
            if(type.equals(profileSkill.Type__c)){
                if(String.isNotEmpty(productName)){
                    if(productName.equals(profileSkill.Product_Name__c)){
                        lstSkillName.add(profileSkill.Name);
                    }
                }else{
                    lstSkillName.add(profileSkill.Name);
                }
            }
        }

        return lstSkillName;
    }

    public static Skill getOmniSkill(String productName, String skillType){
        System.debug('skillType - ' + skillType);
        System.debug('productName - ' + productName);
        
        String omniSkillName;
        for(ProfileSkill profileSkill : mapSkillNameToSkill.values()){
            if(skillType.equals(profileSkill.Type__c) && productName.equals(profileSkill.Product_Name__c)){
                omniSkillName = profileSkill.Omni_Skill_Name__c;
                break;
            }
        }

        Skill skl;
        if(omniSkillName != null){
            skl = mapNameToOmniSkill.get(omniSkillName);
        }
        return skl;
    }
}