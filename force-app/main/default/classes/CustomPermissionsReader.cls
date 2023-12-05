/*    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
 Chandana Gowda			10-Oct-2019       AR-970			Added the method to check for has permission given	 T1
															the list of custom permissions						
*************************************************************************************************************************************
*/
public virtual class CustomPermissionsReader {

    private Set<String> customPermissionNames;
 
    private Set<String> customPermissionsForCurrentUser;
 
    public CustomPermissionsReader() {
        
    }
 
    public Boolean hasPermission(String customPermissionName) {
        // Demand load the custom permissions from the database?        
        if(customPermissionNames==null)
            init();
        // Is this a valid custom permission name?
        if(!customPermissionNames.contains(customPermissionName))
            throw new CustomPermissionsException('Custom Permission ' + customPermissionName + ' is not valid.');
        // Has this user been assigned this custom permission?
        return customPermissionsForCurrentUser.contains(customPermissionName);
    }
	//------------------------------------------------------------------------------<T1>    
    public Boolean hasPermission(List<String> customPermissionLst) {
        boolean permission=false;
        // Demand load the custom permissions from the database?        
        if(customPermissionNames==null)
            init();
        for(String customPermissionName:customPermissionLst){
        	// Is this a valid custom permission name?
            if(!customPermissionNames.contains(customPermissionName))
                throw new CustomPermissionsException('Custom Permission ' + customPermissionName + ' is not valid.');
            permission = permission || customPermissionsForCurrentUser.contains(customPermissionName);
        }
        return permission;
    }    
	//------------------------------------------------------------------------------</T1>    
    private void init() {
 
        customPermissionNames = new Set<String>();
        customPermissionsForCurrentUser = new Set<String>();

        // Query the full set of Custom Permissions
        Map<Id, String> customPermissionNamesById = new Map<Id, String>();
        
        for(CustomPermission customPermission : [select Id, DeveloperName from CustomPermission]) {
            customPermissionNames.add(customPermission.DeveloperName);
            customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
        }
 
        // Query to determine which of these custom permissions are assigned to this user
        List<SetupEntityAccess> setupEntities = 
            [SELECT SetupEntityId
                FROM SetupEntityAccess
                WHERE SetupEntityId in :customPermissionNamesById.keySet() AND
                      ParentId
                        IN (SELECT PermissionSetId 
                            FROM PermissionSetAssignment
                            WHERE AssigneeId = :UserInfo.getUserId())]; 
        for(SetupEntityAccess setupEntity : setupEntities)
            customPermissionsForCurrentUser.add(customPermissionNamesById.get(setupEntity.SetupEntityId));  
    }
 
    public class CustomPermissionsException extends Exception {}
}