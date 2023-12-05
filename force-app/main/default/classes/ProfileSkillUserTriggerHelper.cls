/*
    @created by       : balajip
    @created on       : 07/27/2020
    @Purpose          : ProfileSkill handler helper class.
    @Testclass        : 
    @JIRA             : I2RT-53
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
    Venky K        01-10-2021    Utopia             To consider approval                    T01
                                                    scenarios
    Isha B        23-05-2023                       Added Null and duplicate check           I2RT-7849     T02                      
 ****************************************************************************************************
 */

 public class ProfileSkillUserTriggerHelper {
    
    private void addToMap(Map<Id, Set<String>> mapUserIdToValues, Id UserId, String value){
        if(!String.isEmpty(value)){
            Set<String> setValue = new Set<String>();
            if(mapUserIdToValues.containsKey(UserId)){
                setValue = mapUserIdToValues.get(UserId);
            }else{
                mapUserIdToValues.put(UserId, setValue);
            }
            setValue.add(value);
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description: Inserts the given list of Group Member details.
    * 
    *————————————————————————————————————————————————————
    * @param    lstGroupMember
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @Future
    public static void createGroupMember(List<String> lstGroupMember) {
        List<GroupMember> lstPublicGroupMember = new List<GroupMember>();
        for(String memberDetail : lstGroupMember){
            Id groupId = memberDetail.split('-').get(0);
            Id userId = memberDetail.split('-').get(1);

            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = groupId;
            groupMember.UserOrGroupId = userId;
            lstPublicGroupMember.add(groupMember);
        }
    
        System.debug('Group Member List is ' + lstPublicGroupMember);
        if(!lstPublicGroupMember.isEmpty()) {
            insert lstPublicGroupMember;
        }
    }

    /**
    *————————————————————————————————————————————————————
    * @Description: Inserts the given list of Collaboration Group Member details.
    * 
    *————————————————————————————————————————————————————
    * @param    lstGroupMember
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @Future
    public static void createChatterGroupMember(List<String> lstGroupMember) {
        List<CollaborationGroupMember> lstChatterGroupMember = new List<CollaborationGroupMember>();
        for(String memberDetail : lstGroupMember){
            Id groupId = memberDetail.split('-').get(0);
            Id userId = memberDetail.split('-').get(1);

            CollaborationGroupMember groupMember = new CollaborationGroupMember();
            groupMember.CollaborationGroupId = groupId;
            groupMember.MemberId = userId;
            groupMember.NotificationFrequency = 'P';
            lstChatterGroupMember.add(groupMember);
        }
    
        System.debug('Group Member List is ' + lstChatterGroupMember);
        if(!lstChatterGroupMember.isEmpty()) {
            insert lstChatterGroupMember;
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description: Inserts the given list of Permission Set Association details.
    * 
    *————————————————————————————————————————————————————
    * @param    lstPSMember
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @Future
    public static void assignPermissionSet(List<String> lstPSMember) {
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        for(String memberDetail : lstPSMember){
            Id permissionSetId = memberDetail.split('-').get(0);
            Id userId = memberDetail.split('-').get(1);

            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = permissionSetId;
            psa.AssigneeId = userId;
            lstPSA.add(psa);
        }
    
        System.debug('Permission Set Member List is ' + lstPSA);
        if(!lstPSA.isEmpty()) {
            insert lstPSA;
        }
    }

    @Future
    public static void assignOmniSkill(List<String> lstSkillResource) {
        List<ServiceResourceSkill> lstResourceSkill = new List<ServiceResourceSkill>();
        for(String memberDetail : lstSkillResource){
            Id skillId = memberDetail.split('-').get(0);
            Id serviceResourceId = memberDetail.split('-').get(1);

            ServiceResourceSkill resourceSkill = new ServiceResourceSkill();
            resourceSkill.SkillId = skillId;
            resourceSkill.ServiceResourceId = serviceResourceId;
            resourceSkill.EffectiveStartDate = System.today();
            lstResourceSkill.add(resourceSkill);
        }
    
        System.debug('Service Resource Skill List is ' + lstResourceSkill);
        if(!lstResourceSkill.isEmpty()) {
            insert lstResourceSkill;
        }
    }
    
    public static void addUserToGroupAndQueue(Map<Id, Set<String>> mapUserIdToGroupNames, Map<Id, Set<String>> mapUserIdToQueueNames) {
        Set<String> setGroupName = new Set<String>();
        for(Set<String> setValue : mapUserIdToGroupNames.values()){
            setGroupName.addAll(setValue);
        }
        Map<String, Id> mapGroupNameToId = new Map<String, Id>();
        for (Group grp : [Select Id, DeveloperName From Group Where DeveloperName in :setGroupName And Type='Regular']){
            mapGroupNameToId.put(grp.DeveloperName, grp.Id);
        }

        Set<String> setQueueName = new Set<String>();
        for(Set<String> setValue : mapUserIdToQueueNames.values()){
            setQueueName.addAll(setValue);
        }
        Map<String, Id> mapQueueNameToId = new Map<String, Id>();
        for (Group grp : [Select Id, DeveloperName From Group Where DeveloperName in :setQueueName And Type='Queue']){
            mapQueueNameToId.put(grp.DeveloperName, grp.Id);
        }
        
        List<String> lstGroupMember = new List<String>();
        for(Id userId : mapUserIdToGroupNames.keySet()){
            for(String groupName : mapUserIdToGroupNames.get(userId)){
                Id groupId = mapGroupNameToId.get(groupName);

                lstGroupMember.add(groupId + '-' + userId);
            }
        }
        for(Id userId : mapUserIdToQueueNames.keySet()){
            for(String queueName : mapUserIdToQueueNames.get(userId)){
                Id queueId = mapQueueNameToId.get(queueName);

                lstGroupMember.add(queueId + '-' + userId);
            }
        }
    
        System.debug('Group Member List is ' + lstGroupMember);
        if(!lstGroupMember.isEmpty()) {
            createGroupMember(lstGroupMember);
        }
    }
    
    public static void addUserToChatterGroup(Map<Id, Set<String>> mapUserIdToGroupNames) {
        Set<String> setChatterGroupName = new Set<String>();

        for(Set<String> setValue : mapUserIdToGroupNames.values()){
            setChatterGroupName.addAll(setValue);
        }

        Map<String, Id> mapGroupNameToId = new Map<String, Id>();
        for (CollaborationGroup grp : [Select Id, Name From CollaborationGroup Where Name in :setChatterGroupName]){
            mapGroupNameToId.put(grp.Name, grp.Id);
        }

        List<String> lstChatterGroupMember = new List<String>();
        for(Id userId : mapUserIdToGroupNames.keySet()){
            for(String groupName : mapUserIdToGroupNames.get(userId)){
                Id groupId = mapGroupNameToId.get(groupName);

                lstChatterGroupMember.add(groupId + '-' + userId);
            }
        }
    
        System.debug('Group Member List is ' + lstChatterGroupMember);
        if(!lstChatterGroupMember.isEmpty()) {
            createChatterGroupMember(lstChatterGroupMember);
        }
    }

    public static void addUserToPermissionSet(Map<Id, Set<String>> mapUserIdToPSNames){
        Set<String> setPermissionSetName = new Set<String>();

        for(Set<String> setValue : mapUserIdToPSNames.values()){
            setPermissionSetName.addAll(setValue);
        }

        Map<String, Id> mapPSNameToId = new Map<String, Id>();
        Map<String, Set<Id>> mapPSNameToSetUserId = new Map<String, Set<Id>>();
        for (PermissionSetAssignment psAssignment : [Select Id, PermissionSetId, PermissionSet.Name, AssigneeId From PermissionSetAssignment Where PermissionSet.Name in :setPermissionSetName]){
            mapPSNameToId.put(psAssignment.PermissionSet.Name, psAssignment.PermissionSetId);

            Set<Id> setAssigneeId = new Set<Id>();
            if (mapPSNameToSetUserId.containsKey(psAssignment.PermissionSet.Name)){
                setAssigneeId = mapPSNameToSetUserId.get(psAssignment.PermissionSet.Name);
            }else{
                mapPSNameToSetUserId.put(psAssignment.PermissionSet.Name, setAssigneeId);
            }
            setAssigneeId.add(psAssignment.AssigneeId);
        }

        List<String> lstPermissionSetMember = new List<String>();
        for(Id userId : mapUserIdToPSNames.keySet()){
            for(String permissionSetName : mapUserIdToPSNames.get(userId)){
                if (mapPSNameToSetUserId.containsKey(permissionSetName)){
                    if(! mapPSNameToSetUserId.get(permissionSetName).contains(userId)){
                        Id permissionSetId = mapPSNameToId.get(permissionSetName);
                        lstPermissionSetMember.add(permissionSetId + '-' + userId); 
                    }
                }
            }
        }

        System.debug('Permission Set Member List is ' + lstPermissionSetMember);
        if(!lstPermissionSetMember.isEmpty()) {
            assignPermissionSet(lstPermissionSetMember);
        }
    }

    public static void addUserToOmniSkill(Map<Id, Set<String>> mapUserIdToSkillNames){
        Set<String> setSkillName = new Set<String>();

        for(Set<String> setValue : mapUserIdToSkillNames.values()){
            setSkillName.addAll(setValue);
        }
        
        Map<String, Id> mapSkillNameToId = new Map<String, Id>();
        for (Skill skill : [Select Id, DeveloperName From Skill Where DeveloperName in :setSkillName]){
            mapSkillNameToId.put(skill.DeveloperName, skill.Id);
        }

        List<ServiceResource> lstServiceResource = [Select Id, Name, RelatedRecordId, ResourceType, IsActive 
                                                      From ServiceResource 
                                                      Where ResourceType = 'A' And RelatedRecordId in :mapUserIdToSkillNames.keySet()];
        Map<Id, ServiceResource> mapUserIdToServResource = new Map<Id, ServiceResource>();
        for(ServiceResource resource : lstServiceResource){
            mapUserIdToServResource.put(resource.RelatedRecordId, resource);
        }

        List<ServiceResource> lstServiceResourceToUpsert = new List<ServiceResource>();
        for(Id userId : mapUserIdToSkillNames.keySet()){
            if(mapUserIdToServResource.containsKey(userId)){
                ServiceResource resource = mapUserIdToServResource.get(userId);
                if(!resource.IsActive){
                    resource.IsActive = true;
                    lstServiceResourceToUpsert.add(resource);
                }
            }else{
                ServiceResource resource = new ServiceResource();
                resource.Name = userId;
                resource.RelatedRecordId = userId;
                resource.ResourceType = 'A';
                resource.IsActive = true;
                lstServiceResourceToUpsert.add(resource);
            }
        }
        if(!lstServiceResourceToUpsert.isEmpty()){
            upsert lstServiceResourceToUpsert;
        }

        lstServiceResource = [Select Id, Name, RelatedRecordId, ResourceType, IsActive,
                                (Select Id, ServiceResourceId, SkillId, Skill.DeveloperName, SkillLevel, EffectiveStartDate, EffectiveEndDate From ServiceResourceSkills) 
                                From ServiceResource 
                                Where RelatedRecordId in :mapUserIdToSkillNames.keySet()];
        Set<Id> setServResourceId = new Set<Id>();
        mapUserIdToServResource = new Map<Id, ServiceResource>();
        for(ServiceResource resource : lstServiceResource){
            setServResourceId.add(resource.Id);
            mapUserIdToServResource.put(resource.RelatedRecordId, resource);
        }

        /*List<ServiceResourceSkill> lstResourceSkill = [Select Id, ServiceResourceId, SkillId, Skill.DeveloperName, SkillLevel, EffectiveStartDate, EffectiveEndDate 
                                                        From ServiceResourceSkill 
                                                        Where ServiceResourceId in :setServResourceId And Skill.DeveloperName in :setSkillName];
        */
        
        List<String> lstResourceSkill = new List<String>();
        List<ServiceResourceSkill> lstResourceSkillToUpdate = new List<ServiceResourceSkill>();
        for(Id userId : mapUserIdToSkillNames.keySet()){
            ServiceResource resource = mapUserIdToServResource.get(userId);
            for(String skillName : mapUserIdToSkillNames.get(userId)){
                Boolean resourceSkillFound = false;
                for(ServiceResourceSkill resourceSkill : resource.ServiceResourceSkills){
                    if(skillName.equals(resourceSkill.Skill.DeveloperName)){
                        resourceSkillFound = true;
                        if(resourceSkill.EffectiveEndDate != null){
                            resourceSkill.EffectiveEndDate = null;
                            lstResourceSkillToUpdate.add(resourceSkill);
                        }
                        break;
                    }
                }
                if(!resourceSkillFound){
                    Id skillId = mapSkillNameToId.get(skillName);
                    lstResourceSkill.add(skillId + '-' + resource.Id);     
                }
            }
        }

        System.debug('Omni skill member list to update ' + lstResourceSkillToUpdate);
        if(!lstResourceSkillToUpdate.isEmpty()) {
            update lstResourceSkillToUpdate;
        }

        System.debug('Omni skill member list is ' + lstResourceSkill);
        if(!lstResourceSkill.isEmpty()) {
            assignOmniSkill(lstResourceSkill);
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description: Adds the Users to the Public Group, Queue, Chatter Group and Permission Set 
    *                    associated to the Skill the User is being added to.
    * 
    *————————————————————————————————————————————————————
    * @param    newMap
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void addUserToGroups(Map<Id, ProfileSkillUser> newMap) {
        List<ProfileSkillUser> lstSkillUser = [Select Id, Name, Status__c, UserId, 
                                                  ProfileSkillId, Profileskill.Approval_Needed__c,
                                                  ProfileSkill.Public_Group_Name__c, ProfileSkill.Queue_Name__c, 
                                                  ProfileSkill.Chatter_Group_Name__c, ProfileSkill.Permission_Set_Name__c,
                                                  ProfileSkill.Omni_Skill_Name__c
                                                From ProfileSkillUser Where Id in :newMap.keyset()];

        Map<Id, Set<String>> mapUserIdToGroupNames = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapUserIdToQueueNames = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapUserIdToChatterGroupNames = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapUserIdToPSNames = new Map<Id, Set<String>>();        
        Map<Id, Set<String>> mapUserIdToOmniSkillNames = new Map<Id, Set<String>>();

        for(ProfileSkillUser skillUser : lstSkillUser){
            if(!skillUser.Profileskill.Approval_Needed__c || (skillUser.Profileskill.Approval_Needed__c && skillUser.Status__c == 'Approved')){
                addToMap(mapUserIdToGroupNames, skillUser.UserId, skillUser.ProfileSkill.Public_Group_Name__c);
                
                addToMap(mapUserIdToQueueNames, skillUser.UserId, skillUser.ProfileSkill.Queue_Name__c);
                
                System.debug('value of Chatter Group Name'+skillUser.ProfileSkill.Chatter_Group_Name__c);
                addToMap(mapUserIdToChatterGroupNames, skillUser.UserId, skillUser.ProfileSkill.Chatter_Group_Name__c);
                
                addToMap(mapUserIdToPSNames, skillUser.UserId, skillUser.ProfileSkill.Permission_Set_Name__c);
                
                addToMap(mapUserIdToOmniSkillNames, skillUser.UserId, skillUser.ProfileSkill.Omni_Skill_Name__c);
            }
        }

        System.debug('Group Member List is ' + mapUserIdToGroupNames);
        System.debug('Queue Member List is ' + mapUserIdToQueueNames);
        if(!mapUserIdToGroupNames.isEmpty() || !mapUserIdToQueueNames.isEmpty()) {
            addUserToGroupAndQueue(mapUserIdToGroupNames, mapUserIdToQueueNames);
        }

        System.debug('Chatter Group Member List is ' + mapUserIdToChatterGroupNames);
        if(!mapUserIdToChatterGroupNames.isEmpty()) {
            addUserToChatterGroup(mapUserIdToChatterGroupNames);
        }

        System.debug('Permission Set Member List is ' + mapUserIdToPSNames);
        if(!mapUserIdToPSNames.isEmpty()) {
            addUserToPermissionSet(mapUserIdToPSNames);
        }

        System.debug('Omni Skills Member List is ' + mapUserIdToOmniSkillNames);
        if(!mapUserIdToOmniSkillNames.isEmpty()) {
            addUserToOmniSkill(mapUserIdToOmniSkillNames);
        }
    }

    /**
    *————————————————————————————————————————————————————
    * @Description: Delete the given list of Group Member records
    * 
    *————————————————————————————————————————————————————
    * @param    setGroupMemberId
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @Future
    public static void removeUserFromPublicGroup(Set<Id> setGroupMemberId) {
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        for(Id grpMemberId : setGroupMemberId){
            GroupMember groupMember = new GroupMember(Id=grpMemberId);
            lstGroupMember.add(groupMember);
        }
        
        if(!lstGroupMember.isEmpty()) {
            delete lstGroupMember;
        }
    }

    /**
    *————————————————————————————————————————————————————
    * @Description: Deletes the given list of PermissionSetAssignment records
    * 
    *————————————————————————————————————————————————————
    * @param    setPSAId
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @Future
    public static void removeUserFromPermissionSet(Set<Id> setPSAId) {
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        for(Id psaId : setPSAId){
            PermissionSetAssignment psa = new PermissionSetAssignment(Id=psaId);
            lstPSA.add(psa);
        }
        
        if(!lstPSA.isEmpty()) {
            delete lstPSA;
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description: Removes the Users from the Public Group, Queue, Chatter Group and Permission Set 
    *                    associated to the Skill the User is being removed from.
    * 
    *————————————————————————————————————————————————————
    * @param    oldMap
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void removeUserFromGroups(Map<Id, ProfileSkillUser> oldMap, String contxt) {
        System.debug(oldMap);
        List<ProfileSkillUser> lstSkillUser = [Select Id, Name, Status__c, UserId, 
                                                ProfileSkillId, Profileskill.Approval_Needed__c,
                                                ProfileSkill.Public_Group_Name__c, ProfileSkill.Queue_Name__c, 
                                                ProfileSkill.Chatter_Group_Name__c, ProfileSkill.Permission_Set_Name__c,
                                                ProfileSkill.Omni_Skill_Name__c
                                              From ProfileSkillUser Where Id in :oldMap.keyset() ALL ROWS];

        Set<String> setPublicGroupName = new Set<String>();
        Set<String> setQueueName = new Set<String>();
        Set<String> setChatterGroupName = new Set<String>();
        Set<String> setPSName = new Set<String>();
        Set<String> setOmniSkillName = new Set<String>();
        Set<Id> setUserId = new Set<Id>();
        for(ProfileSkillUser skillUser : lstSkillUser){
            if((contxt.equals('Update') && skillUser.Profileskill.Approval_Needed__c &&  skillUser.Status__c == 'Rejected') || contxt.equals('Delete')){
                if(!String.isEmpty(skillUser.ProfileSkill.Public_Group_Name__c)){
                    setPublicGroupName.add(skillUser.ProfileSkill.Public_Group_Name__c);
                }
                if(!String.isEmpty(skillUser.ProfileSkill.Queue_Name__c)){
                    setQueueName.add(skillUser.ProfileSkill.Queue_Name__c);
                }
                if(!String.isEmpty(skillUser.ProfileSkill.Chatter_Group_Name__c)){
                    setChatterGroupName.add(skillUser.ProfileSkill.Chatter_Group_Name__c);
                }
                if(!String.isEmpty(skillUser.ProfileSkill.Permission_Set_Name__c)){
                    setPSName.add(skillUser.ProfileSkill.Permission_Set_Name__c);
                }
                if(!String.isEmpty(skillUser.ProfileSkill.Omni_Skill_Name__c)){
                    setOmniSkillName.add(skillUser.ProfileSkill.Omni_Skill_Name__c);
                }
                setUserId.add(skillUser.UserId);
            }
        }

        System.debug('list of user ids - ' + setUserId);
        List<GroupMember> lstPublicGroupMember = [Select Id, UserOrGroupId, GroupId, Group.DeveloperName From GroupMember 
                                                    Where UserOrGroupId in :setUserId And Group.DeveloperName in :setPublicGroupName 
                                                        And Group.Type='Regular'];
        
        List<GroupMember> lstQueueMember = [Select Id, UserOrGroupId, GroupId, Group.DeveloperName From GroupMember 
                                                    Where UserOrGroupId in :setUserId And Group.DeveloperName in :setQueueName 
                                                        And Group.Type='Queue'];

        List<CollaborationGroupMember> lstChatterGroupMember = [Select Id, MemberId, CollaborationGroupId, CollaborationGroup.Name From CollaborationGroupMember
                                                    Where MemberId in :setUserId And CollaborationGroup.Name in :setChatterGroupName];

        List<PermissionSetAssignment> lstPSA = [Select Id, AssigneeId, PermissionSetId, PermissionSet.Name From PermissionSetAssignment
                                                    Where AssigneeId in :setUserId And PermissionSet.Name in :setPSName];

        System.debug('list of omni skill names - ' + setOmniSkillName);
        List<ServiceResourceSkill> lstResourceSkill = [Select Id, ServiceResourceId, ServiceResource.RelatedRecordId, SkillId, Skill.DeveloperName, SkillLevel, EffectiveStartDate, EffectiveEndDate 
                                                        From ServiceResourceSkill 
                                                        Where ServiceResource.ResourceType = 'A' And ServiceResource.RelatedRecordId in :setUserId And Skill.DeveloperName in :setOmniSkillName];

        Set<Id> setPublicGroupMemberIdToDelete = new Set<Id>();
        Set<Id> setPSAIdToDelete = new Set<Id>();
        List<CollaborationGroupMember> lstChatterGroupMemberToDelete = new List<CollaborationGroupMember>();
        List<ServiceResourceSkill> lstServResSkillToUpdate = new List<ServiceResourceSkill>();
        for(ProfileSkillUser skillUser : lstSkillUser){
            for(GroupMember grpMember : lstPublicGroupMember){
                if(grpMember.UserOrGroupId==skillUser.UserId && !string.isblank(skillUser.ProfileSkill.Public_Group_Name__c) &&  skillUser.ProfileSkill.Public_Group_Name__c.equals(grpMember.Group.DeveloperName)){
                    setPublicGroupMemberIdToDelete.add(grpMember.Id);
                }
            }

            for(GroupMember grpMember : lstQueueMember){
                if(grpMember.UserOrGroupId==skillUser.UserId && !string.isblank(skillUser.ProfileSkill.Queue_Name__c) && skillUser.ProfileSkill.Queue_Name__c.equals(grpMember.Group.DeveloperName)){
                    setPublicGroupMemberIdToDelete.add(grpMember.Id);
                }
            }

            for(CollaborationGroupMember grpMember : lstChatterGroupMember){
                if(grpMember.MemberId==skillUser.UserId && !string.isblank(skillUser.ProfileSkill.Chatter_Group_Name__c) && skillUser.ProfileSkill.Chatter_Group_Name__c.equals(grpMember.CollaborationGroup.Name)){
                    lstChatterGroupMemberToDelete.add(grpMember);
                }
            }

            for(PermissionSetAssignment psa : lstPSA){
                if(psa.AssigneeId==skillUser.UserId && !string.isblank(skillUser.ProfileSkill.Permission_Set_Name__c) && skillUser.ProfileSkill.Permission_Set_Name__c.equals(psa.PermissionSet.Name)){
                    setPSAIdToDelete.add(psa.Id);
                }
            }

            for(ServiceResourceSkill servResSkill : lstResourceSkill){               
                                if(servResSkill.ServiceResource.RelatedRecordId==skillUser.UserId && skillUser.ProfileSkill.Omni_Skill_Name__c!=null && skillUser.ProfileSkill.Omni_Skill_Name__c.equals(servResSkill.Skill.DeveloperName) ){ //T02 -> added null check
                    //servResSkill.EffectiveEndDate = System.today().addDays(-1);
                    servResSkill.EffectiveEndDate = System.today();
                        if(!lstServResSkillToUpdate.contains(servResSkill) )
                        { //T02 added duplicate check
                            lstServResSkillToUpdate.add(servResSkill); 
                        }
                }
            }
        }
    
        System.debug('Service Resource Skill List is ' + lstServResSkillToUpdate);
        if(!lstServResSkillToUpdate.isEmpty()) {
            update lstServResSkillToUpdate;
        }

        System.debug('Chatter Group Member List is ' + lstChatterGroupMemberToDelete);
        if(!lstChatterGroupMemberToDelete.isEmpty()) {
            try{
                delete lstChatterGroupMemberToDelete;
            }catch(Exception ex){
                
            }
        }

        System.debug('Group Member List is ' + setPublicGroupMemberIdToDelete);
        if(!setPublicGroupMemberIdToDelete.isEmpty()) {
            removeUserFromPublicGroup(setPublicGroupMemberIdToDelete);
        }

        System.debug('PSA List is ' + setPSAIdToDelete);
        if(!setPSAIdToDelete.isEmpty()) {
            removeUserFromPermissionSet(setPSAIdToDelete);
        }
    }
}