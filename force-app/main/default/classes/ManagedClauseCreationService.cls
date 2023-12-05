public class ManagedClauseCreationService {

    /********
    constants
    ********/
    private static final String CRITERIA_SELECTION_OPERATOR_AND = 'AND';
    private static final String CRITERIA_SELECTION_OPERATOR_OR = 'OR';
    @TestVisible private static final String CLAUSE_BUNDLE_MAPPING_PARAMETER_TYPE = 'Bundle Selection Criteria';
    @TestVisible private static final String SOURCE_OBJECT_ASSIGMENT_PARAMETER_TYPE = 'Source Object Assignment';

    /**************
    class variables
    /**************/
    private static List<MappingInfo> objectMappingsCache = null;

    /*********
    exceptions
    *********/
    public class ManagedClauseCreationException extends Exception {}

    /***************
    internal classes
    ***************/
    @TestVisible
    private class MappingParameter {
        public String sourceFieldName {get; set;}
        public String targetFieldName {get; set;}
        public String value {get; set;}
        public Boolean required {get; set;}

        public MappingParameter(String sFieldName, String tFieldName, String val, Boolean req) {
            this.sourceFieldName = sFieldName;
            this.targetFieldName = tFieldName;
            this.value = val;
            this.required = req;
        }
    }

    @TestVisible
    private class MappingInfo {
        public String name {get; set;}
        public String sourceObjectName {get; set;}
        public String sourceObjectControlFieldName {get; set;}
        public String targetObjectName {get; set;}
        public List<MappingParameter> bundleSelectionCriterias {get; set;}
        public List<MappingParameter> fieldAssignments {get; set;}
        public String criteriaSelectionOperator {get; set;}
        public String managedClauseLookupFieldName {get; set;}
        public Boolean allowMultipleClauseBundles {get; set;}
        
        public MappingInfo() {
            this.name = null;
            this.sourceObjectName = null;
            this.targetObjectName = null;
            this.bundleSelectionCriterias = new List<MappingParameter>();
            this.fieldAssignments = new List<MappingParameter>();
            this.criteriaSelectionOperator = null;
            this.managedClauseLookupFieldName = null;
            this.allowMultipleClauseBundles = false;
        }
        
    }

    private class FieldAssignmentInfo {
        public String fieldName {get; set;}
        public Object fieldValue {get; set;}

        public FieldAssignmentInfo(String name, Object value) {
            this.fieldName = name;
            this.fieldValue = value;
        }
    }

    private class ManagedClauseCreationInfo {
        public Map<Id, List<APXT_Redlining__Clause_Bundle__c>> sObjectIdToClauseBundleListMap {get; set;}
        public Map<Id, List<FieldAssignmentInfo>> sObjectIdToFieldAssignmentInfoListMap {get; set;}

        public ManagedClauseCreationInfo() {
            this.sObjectIdToClauseBundleListMap = new Map<Id, List<APXT_Redlining__Clause_Bundle__c>>();
            this.sObjectIdToFieldAssignmentInfoListMap = new Map<Id, List<FieldAssignmentInfo>>();
        }
    }

    /**************
    private methods
    **************/      

    /*
    @description Gets an ordered list of mapping information that applies to the given object. This info includes bundle selection criteria and field assignment info.
    */
    @TestVisible 
    private static List<MappingInfo> getMappingInfoForSourceObject(String objectApiName) {

        if (objectMappingsCache != null) return objectMappingsCache;

        List<MappingInfo> infos = new List<MappingInfo>();        

        Map<Id, Clause_Bundle_Mapping__mdt> configuredMappings = getConfiguredMappings(objectApiName);
        if (configuredMappings.isEmpty()) return infos;

        Map<Id, List<Clause_Bundle_Mapping_Parameter__mdt>> mappingIdToMappingsParametersMap = getMappingsParameters(configuredMappings.keySet());

        for (Clause_Bundle_Mapping__mdt mapping : configuredMappings.values()) {            

            MappingInfo info = new MappingInfo();
            info.name = mapping.MasterLabel;
            info.sourceObjectName = mapping.Object__r.QualifiedApiName;
            info.sourceObjectControlFieldName = mapping.Object_Control_Field__r.QualifiedApiName;
            info.targetObjectName = mapping.Managed_Clause_Object__r.QualifiedApiName;
            info.managedClauseLookupFieldName = mapping.Managed_Clause_Lookup_Field__r.QualifiedApiName;
            info.criteriaSelectionOperator = mapping.Operator__c;
            info.allowMultipleClauseBundles = mapping.Allow_Multiple_Clause_Bundles__c;

            for (Clause_Bundle_Mapping_Parameter__mdt p : mappingIdToMappingsParametersMap.get(mapping.Id)) {
                if (p.Type__c == CLAUSE_BUNDLE_MAPPING_PARAMETER_TYPE) {
                    info.bundleSelectionCriterias.add(new MappingParameter(p.Source_Field__r.QualifiedApiName, p.Target_Field__r.QualifiedApiName, p.Value__c, p.Required__c));
                }
                else if (p.Type__c == SOURCE_OBJECT_ASSIGMENT_PARAMETER_TYPE) {
                    info.fieldAssignments.add(new MappingParameter(p.Source_Field__r.QualifiedApiName, p.Target_Field__r.QualifiedApiName, p.Value__c, p.Required__c));
                }
                else {
                    throw new ManagedClauseCreationException(String.format(Label.Mapping_parameter_type_not_supported, new String[] { p.Type__c }));
                }

            }
            
            infos.add(info);
        }                      
        objectMappingsCache = infos;
        return infos;
    }

    /*
    @description This method returns two maps: One for the clause bundles that has to be used for managed clause creation and other for field value assignment from bundle to the object.
    */
    private static ManagedClauseCreationInfo getManagedClauseCreationInfo(List<MappingInfo> infos, List<sObject> objects) {

        ManagedClauseCreationInfo returnInfo = new ManagedClauseCreationInfo();

        List<APXT_Redlining__Clause_Bundle__c> clauseBundles = getAllClauseBundles(infos); // This get's all clause bundles ordered.

        if (clauseBundles.isEmpty()) return returnInfo;

        for (sObject obj : objects) {
            List<APXT_Redlining__Clause_Bundle__c> clauseBundlesForObject = new List<APXT_Redlining__Clause_Bundle__c>();
            List<FieldAssignmentInfo> fieldValueAssignmentsForObject = new List<FieldAssignmentInfo>();
            // loop first by clause bundles to keep correct order.            
            for (APXT_Redlining__Clause_Bundle__c cb : clauseBundles) { 
                Integer clauseBundleNumber = 0;                                
                for (MappingInfo info : infos) {
                    // check field bundle selection criteria
                    if (!info.bundleSelectionCriterias.isEmpty()) {
                        if (checkClauseBundleSelectionCriteria(obj, cb, info)) {
                            clauseBundlesForObject.add(cb);
                            clauseBundleNumber++;
                            // check object field assignment values
                            if (!info.fieldAssignments.isEmpty()) {
                                for (MappingParameter param : info.fieldAssignments) {
                                    if (!param.required || (param.required && cb.get(param.sourceFieldName) != null)) {
                                        fieldValueAssignmentsForObject.add(new FieldAssignmentInfo(param.targetFieldName, cb.get(param.sourceFieldName)));
                                    }
                                }
                            }
                        }
                    }
                    if (clauseBundleNumber == 1 && !info.allowMultipleClauseBundles) break;                    
                }
            }
            if (!clauseBundlesForObject.isEmpty()) returnInfo.sObjectIdToClauseBundleListMap.put(obj.Id, clauseBundlesForObject);
            if (!fieldValueAssignmentsForObject.isEmpty()) returnInfo.sObjectIdToFieldAssignmentInfoListMap.put(obj.Id, fieldValueAssignmentsForObject);
        }

        return returnInfo;
    }

    /*
    @description This method checks bundle selection criteria for a given bundle, based on configured criteria.
    */
    private static Boolean checkClauseBundleSelectionCriteria(sObject obj, APXT_Redlining__Clause_Bundle__c clauseBundle, MappingInfo info) {
        Boolean includeBundle = true;
        Boolean requiredEval = true;
        String clauseBundleObjectName = Schema.SObjectType.APXT_Redlining__Clause_Bundle__c.getName();
        for (MappingParameter param : info.bundleSelectionCriterias) {
            if (param.sourceFieldName != null) {
                if (param.required) {
                    if (isCheckbox(clauseBundleObjectName, param.targetFieldName)) {
                        requiredEval = clauseBundle.get(param.targetFieldName) == true;
                    }
                    else {
                        requiredEval = clauseBundle.get(param.targetFieldName) != null;
                    }
                }
                if (info.criteriaSelectionOperator == CRITERIA_SELECTION_OPERATOR_AND) {
                    includeBundle = includeBundle && (obj.get(param.sourceFieldName) == clauseBundle.get(param.targetFieldName) && requiredEval);
                }
                else {
                    includeBundle = includeBundle || (obj.get(param.sourceFieldName) == clauseBundle.get(param.targetFieldName) && requiredEval);
                }
            }
            else {
                if (param.value != null) {
                    if (info.criteriaSelectionOperator == CRITERIA_SELECTION_OPERATOR_AND) {
                        includeBundle = includeBundle && fieldValueToConfiguredValueComparer(clauseBundleObjectName, param.targetFieldName, param.value, clauseBundle.get(param.targetFieldName));
                    }
                    else {
                        includeBundle = includeBundle || fieldValueToConfiguredValueComparer(clauseBundleObjectName, param.targetFieldName, param.value, clauseBundle.get(param.targetFieldName));
                    }
                }
                else
                    includeBundle = false;
            }
            if (!includeBundle) break;
        }
        return includeBundle;
    }

    /*
    @description Return the field type associated with the given field name in the given object.
    */
    @TestVisible 
    private static Schema.DisplayType getObjectFieldType(String objectApiName, String objectApiFieldName) {
        try {
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectApiName); 
            Schema.DescribeSObjectResult r = t.getDescribe();
            Schema.DescribeFieldResult f = r.fields.getMap().get(objectApiFieldName).getDescribe();         
            return f.getType();
        }
        catch (Exception e) {
            String errorMessage = String.Format('ERROR in getObjectFieldType method with params {0}, {1}. Detail: {2}', new String[] {objectApiName, objectApiFieldName, e.getMessage()});
            system.debug(errorMessage);
            return null;
        }
    }

    /*
    @description Compares the value configured to the value in the corresponding field of the target object, using appropiate casting when needed.
    */
    private static Boolean fieldValueToConfiguredValueComparer(String targetObjectName, String targetFieldName, String configuredFieldValue, Object targetFieldValue) {
        try {
            Schema.DisplayType fieldDataType = getObjectFieldType(targetObjectName, targetFieldName);
            if (fieldDataType == Schema.DisplayType.String || 
                fieldDataType == Schema.DisplayType.Picklist || 
                fieldDataType == Schema.DisplayType.Combobox || 
                fieldDataType == Schema.DisplayType.Email || 
                fieldDataType == Schema.DisplayType.URL || 
                fieldDataType == Schema.DisplayType.Phone || 
                fieldDataType == Schema.DisplayType.TextArea) {
                return targetFieldValue == configuredFieldValue;
            }
            else if (fieldDataType == Schema.DisplayType.Boolean) { 
                //checkbox
                return targetFieldValue == Boolean.valueOf(configuredFieldValue);
            }
            else if (fieldDataType == Schema.DisplayType.MultiPicklist) {
                return String.valueOf(targetFieldValue).split(';').contains(configuredFieldValue);
            }
            else if (fieldDataType == Schema.DisplayType.Id) {
                return targetFieldValue == Id.valueOf(configuredFieldValue);
            }
            else if (fieldDataType == Schema.DisplayType.Double || fieldDataType == Schema.DisplayType.Currency || fieldDataType == Schema.DisplayType.Percent) {
                return targetFieldValue == Double.valueOf(configuredFieldValue);
            }
            else if (fieldDataType == Schema.DisplayType.Time) {
                List<String> timeElements = configuredFieldValue.split(':');
                Time configuredTimeValue;
                if (timeElements.size() == 1)
                    configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), 0, 0, 0);
                else if (timeElements.size() == 2)
                    configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), 0, 0);            
                else if (timeElements.size() == 3)
                    configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), Integer.valueOf(timeElements[2]), 0);
                else if (timeElements.size() == 4)
                    configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), Integer.valueOf(timeElements[2]), Integer.valueOf(timeElements[3]));            
                else
                    return false;
                return targetFieldValue == configuredTimeValue;
            }
            else if (fieldDataType == Schema.DisplayType.Date) {
                return targetFieldValue == Date.valueOf(configuredFieldValue);
            }
            else if (fieldDataType == Schema.DisplayType.DateTime) {
                return targetFieldValue == DateTime.valueOf(configuredFieldValue);
            }
            else {
                return false;
            }
        }
        catch (Exception e) {
            String errorMessage = String.Format('ERROR in fieldValueToConfiguredValueComparer with params: {0}, {1}, {2}, {3}. Detail: {4}', new String[] { targetObjectName, targetFieldName, configuredFieldValue, String.valueOf(targetFieldValue), e.getMessage() });
            system.debug(errorMessage);
            return false;
        }
    }

    /*
    @description Check whether the given field name in the given object is a checkbox.
    */
    private static Boolean isCheckbox(String objectName, String fieldName) {
        return getObjectFieldType(objectName, fieldName) == Schema.DisplayType.Boolean; 
    }

    /*
    @description Returns an object map whose bundle selection criteria has changed.
    */
    private static Map<Id, sObject> getModifiedObjectsMap(String objectApiName, Map<Id, sObject> oldObjectsMap, Map<Id, sObject> newObjectsMap) {
        Map<Id, sObject> sObjectsToProcess = new Map<Id, sObject>();     
        
        if (oldObjectsMap == null || oldObjectsMap.size() == 0) return sObjectsToProcess;

        List<MappingInfo> mappings = getMappingInfoForSourceObject(objectApiName);

        if (mappings.isEmpty()) return sObjectsToProcess;        

        for (MappingInfo mapping : mappings) {
            if (!mapping.bundleSelectionCriterias.isEmpty()) {
                for (sObject newObject : newObjectsMap.values()) {
                    sObject oldObject = oldObjectsMap.get(newObject.Id);
                    Boolean fieldValueChange = false;
                    for (MappingParameter param : mapping.bundleSelectionCriterias) {
                        if (param.sourceFieldName != null && newObject.get(param.sourceFieldName) != oldObject.get(param.sourceFieldName)) {
                            fieldValueChange = true;
                            break;
                        }
                    }
                    if (fieldValueChange) sObjectsToProcess.put(newObject.Id, newObject);
                }
            }
        }

        return sObjectsToProcess;
    }

    /*
    @description This method is risponsable for managed clauses creation and field value asssigments for the objects of the given map.
    */
    private static void createManagedClausesAndAssignments(String objectApiName, Map<Id, sObject> newObjectsMap) {

        List<MappingInfo> mappingInfos = getMappingInfoForSourceObject(objectApiName);
        if (mappingInfos.isEmpty()) return;

        // get existing managed clauses by object
        String managedClauseLookupFieldName = mappingInfos[0].managedClauseLookupFieldName; // This assumes the same managed clause lookup field name for all mappings.
        if (managedClauseLookupFieldName == null) return;               
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> objectIdToManagedClausesMap = getObjectRelatedManagedClausesMap(managedClauseLookupFieldName, newObjectsMap.keySet());

        // ManagedClauseCreationInfo creationInfo = getManagedClauseCreationInfo(mappingInfos, newObjectsMap.values());
        // if (creationInfo.sObjectIdToClauseBundleListMap.isEmpty()) return;

        // if no clause bundle selected for object and there is managed clauses, these has to be deleted.
        ManagedClauseCreationInfo creationInfo = getManagedClauseCreationInfo(mappingInfos, newObjectsMap.values());
        if (creationInfo.sObjectIdToClauseBundleListMap.isEmpty() && !objectIdToManagedClausesMap.isEmpty()) {
            List<APXT_Redlining__Managed_Clause__c> managedClausesToDelete = new List<APXT_Redlining__Managed_Clause__c>();
            for (Id objectId : objectIdToManagedClausesMap.keySet()) {
                managedClausesToDelete.addAll(objectIdToManagedClausesMap.get(objectId));
            }
            delete managedClausesToDelete;
            return;
        }

        // get the clauses for the bundles
        Set<Id> clauseBundleIds = new Set<Id>();
        for(Id objectId : creationInfo.sObjectIdToClauseBundleListMap.keySet()) {
            List<APXT_Redlining__Clause_Bundle__c> clauseBundles = creationInfo.sObjectIdToClauseBundleListMap.get(objectId);
            for(APXT_Redlining__Clause_Bundle__c clauseBundle : clauseBundles) {
                clauseBundleIds.add(clauseBundle.Id);
            }
        }

        // get the bundled clauses
        Map<Id,List<APXT_Redlining__Bundle_Clause__c>> clauseBundleIdToBundledClauses = new Map<Id,List<APXT_Redlining__Bundle_Clause__c>>();
        for(APXT_Redlining__Bundle_Clause__c bundledClause : getBundledClausesByClauseBundleIds(clauseBundleIds)) {
            if(!clauseBundleIdToBundledClauses.containsKey(bundledClause.APXT_Redlining__Clause_Bundle__c)) clauseBundleIdToBundledClauses.put(bundledClause.APXT_Redlining__Clause_Bundle__c, new List<APXT_Redlining__Bundle_Clause__c>());
            clauseBundleIdToBundledClauses.get(bundledClause.APXT_Redlining__Clause_Bundle__c).add(bundledClause);
        }

        // managed clauses to delete
        List<APXT_Redlining__Managed_Clause__c> managedClausesToDelete = new List<APXT_Redlining__Managed_Clause__c>();
        
        // managed clauses to create
        List<APXT_Redlining__Managed_Clause__c> managedClausesToInsert = new List<APXT_Redlining__Managed_Clause__c>();

        // managed clauses to update
        List<APXT_Redlining__Managed_Clause__c> managedClausesToUpdate = new List<APXT_Redlining__Managed_Clause__c>();        

        for (Id objectId : newObjectsMap.keySet()) {
            
            List<APXT_Redlining__Clause_Bundle__c> clauseBundles = creationInfo.sObjectIdToClauseBundleListMap.get(objectId);
            if(clauseBundles == null || clauseBundles.isEmpty()) continue;            

            Decimal bundledClauseOrder = 0;
       
            for (APXT_Redlining__Clause_Bundle__c clauseBundle : clauseBundles) {

                List<APXT_Redlining__Bundle_Clause__c> bundledClauses = clauseBundleIdToBundledClauses.get(clauseBundle.Id); 
                if (bundledClauses == null) continue;

                for (APXT_Redlining__Bundle_Clause__c bundledClause : bundledClauses) {

                    bundledClauseOrder += 1;

                    APXT_Redlining__Clause__c clause = bundledClause.APXT_Redlining__Clause__r;

                    APXT_Redlining__Managed_Clause__c clauseToUpsert;
                   
                    clauseToUpsert = getExistingManagedClauseByClauseId(clause.Id, objectIdToManagedClausesMap.get(objectId));
                    if (clauseToUpsert == null) {
                        clauseToUpsert = new APXT_Redlining__Managed_Clause__c();
                        clauseToUpsert.put(managedClauseLookupFieldName, objectId); // This assumes only one lookup field from managed clauses to the object. Is the same for all mappings.
                        if (clause.APXT_Redlining__Latest_Revision__c != null) {
                            clauseToUpsert.APXT_Redlining__Clause_Revision__c = clause.APXT_Redlining__Latest_Revision__c;               
                            clauseToUpsert.APXT_Redlining__Latest_Revision_Text__c = clause.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text__c;
                            clauseToUpsert.APXT_Redlining__Text_Rich__c = clause.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text_Rich__c;
                        }
                        clauseToUpsert.APXT_Redlining__Label__c = clause.Name;                  
                        clauseToUpsert.APXT_Redlining__Order__c = bundledClauseOrder;
                        managedClausesToInsert.add(clauseToUpsert);
                    }
                    else {
                        clauseToUpsert.APXT_Redlining__Order__c = bundledClauseOrder;                        
                        managedClausesToUpdate.add(clauseToUpsert);
                    }
                }
            }
            


            if (!alwaysDeleteExistingManagedClauses()) {
                List<APXT_Redlining__Managed_Clause__c> existingManagedClausesForObject = objectIdToManagedClausesMap.get(objectId);
                if (existingManagedClausesForObject != null && !existingManagedClausesForObject.isEmpty()) {
                    for (APXT_Redlining__Managed_Clause__c mc : existingManagedClausesForObject) {
                        if (!existsManagedClauseByClauseId(mc.APXT_Redlining__Clause_Revision__r.APXT_Redlining__Clause__c, managedClausesToUpdate) && !existsManagedClauseByClauseId(mc.APXT_Redlining__Clause_Revision__r.APXT_Redlining__Clause__c, managedClausesToInsert)) {
                            managedClausesToDelete.add(mc);
                        }
                    }
                }

            }            
        }
        
        if (!managedClausesToDelete.isEmpty()) delete managedClausesToDelete;                
        if (!managedClausesToUpdate.isEmpty()) update managedClausesToUpdate;
        if (!managedClausesToInsert.isEmpty()) insert managedClausesToInsert;

        // assign values to source object fields.
        if (!creationInfo.sObjectIdToFieldAssignmentInfoListMap.isEmpty()) {
            Set<String> targetFieldNames = new Set<String>();
            for (List<FieldAssignmentInfo> assignmentInfoList : creationInfo.sObjectIdToFieldAssignmentInfoListMap.values()) {
                for (FieldAssignmentInfo assignmentInfo : assignmentInfoList) {
                    targetFieldNames.add(assignmentInfo.fieldName);
                }
            }
            if (!targetFieldNames.isEmpty()) {
                List<sObject> objectsToUpdate = getAssignmentObjects(objectApiName, targetFieldNames, creationInfo.sObjectIdToFieldAssignmentInfoListMap.keySet());
                if (!objectsToUpdate.isEmpty()) {
                    for (sObject obj : objectsToUpdate) {
                        for (FieldAssignmentInfo assignmentInfo : creationInfo.sObjectIdToFieldAssignmentInfoListMap.get(obj.Id)) {
                            obj.put(assignmentInfo.fieldName, assignmentInfo.fieldValue);
                        }
                    }
                }
                update objectsToUpdate;
            }
        }
    }

    private static boolean existsManagedClauseByClauseId(Id clauseId, List<APXT_Redlining__Managed_Clause__c> existingManagedClauses) {
        return (getExistingManagedClauseByClauseId(clauseId, existingManagedClauses) != null);
    }

    private static APXT_Redlining__Managed_Clause__c getExistingManagedClauseByClauseId(Id clauseId, List<APXT_Redlining__Managed_Clause__c> existingManagedClauses) {
        if (alwaysDeleteExistingManagedClauses()) return null;
        if (existingManagedClauses == null) return null;
        for (APXT_Redlining__Managed_Clause__c mc : existingManagedClauses) {
            if (mc.APXT_Redlining__Clause_Revision__r.APXT_Redlining__Clause__c == clauseId) return mc;
        }
        return null;
    }

    /*
    @description Checks is trigger execution is disabled for object.
    */
    private static boolean canProcessObject(MappingInfo mapping, sObject obj) {
        return mapping.sourceObjectControlFieldName == null || (mapping.sourceObjectControlFieldName != null && obj.get(mapping.sourceObjectControlFieldName) == true);
    }

    /*
    @description Return objects that allows trigger execution for all configured mappings. If configured, the record must meet the condition for all mappings.
    */
    private static Map<Id, sObject> checkTriggerControllingFieldsForObjects(String objectApiName, Map<Id, sObject> objectsMap) {
        
        Map<Id, sObject> objectsToProcess = new Map<Id, sObject>();
        List<MappingInfo> mappings = getMappingInfoForSourceObject(objectApiName);
        if (mappings.isEmpty()) return objectsToProcess;

        for (sObject obj : objectsMap.values()) {
            Boolean excluded = false;
            for (MappingInfo mapping : mappings) {
                if (!canProcessObject(mapping, obj)) {
                    excluded = true;
                    break;
                }
            }
            if (!excluded) objectsToProcess.put(obj.Id, obj);
        }

        return objectsToProcess;
    }

    /*
    @description Return value of custom setting.
    */
    private static Boolean alwaysDeleteExistingManagedClauses() {
        Managed_Clauses_Settings__c settings = Managed_Clauses_Settings__c.getInstance();     
        return settings.Always_Delete_Existing_Managed_Clauses__c;
    }

    
    /*************
    public methods
    *************/
    /*
    @description Given and object map, deletes existing managed clauses for that objects.
    */
    public static void deleteManagedClauses(String objectApiName, Map<Id, sObject> objectMap) {

        Map<Id, Clause_Bundle_Mapping__mdt> mappings = getConfiguredMappings(objectApiName);
        if (mappings.isEmpty()) return;
        String managedClauseLookupFieldName = mappings.values()[0].Managed_Clause_Lookup_Field__r.QualifiedApiName; // This assumes the same managed clause lookup field name for all mappings.
        if (managedClauseLookupFieldName == null) return;
        List<APXT_Redlining__Managed_Clause__c> managedClauses = getObjectRelatedManagedClauses(managedClauseLookupFieldName, objectMap.keySet());
        if (!managedClauses.isEmpty()) {
            SavePoint sp = Database.setSavePoint();
            try {            
                delete managedClauses;
            } 
            catch (Exception e) {
                Database.rollback(sp);
                throw e;
            }       
        }
    }    

    /*
    @description Given object map's, determines the need for existing managed clauses deletion, creation of new managed clauses and source object field value assigments, based on configuration.
    */
    public static void processManagedClauses(String objectApiName, Map<Id, sObject> oldObjectsMap, Map<Id, sObject> newObjectsMap) {

        Map<Id, sObject> objectsToProcess = checkTriggerControllingFieldsForObjects(objectApiName, newObjectsMap);
        if (objectsToProcess.isEmpty()) return;

        Map<Id, sObject> modifiedObjectsMap = null;
        if (oldObjectsMap != null && !oldObjectsMap.isEmpty()) {
            modifiedObjectsMap = getModifiedObjectsMap(objectApiName, oldObjectsMap, objectsToProcess);        
        }

        SavePoint sp = Database.setSavePoint();
        try {
            if (oldObjectsMap != null && !oldObjectsMap.isEmpty()) {                
                if (modifiedObjectsMap != null && !modifiedObjectsMap.isEmpty()) {                                        
                    if (alwaysDeleteExistingManagedClauses()) deleteManagedClauses(objectApiName, modifiedObjectsMap);
                    createManagedClausesAndAssignments(objectApiName, modifiedObjectsMap);
                }
            }
            else {
                createManagedClausesAndAssignments(objectApiName, objectsToProcess);
            }
        } 
        catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }       
    }    

    /********
    selectors
    ********/
    private static Map<Id, Clause_Bundle_Mapping__mdt> getConfiguredMappings(String objectApiName) {
        String query = 'SELECT Id, MasterLabel, Object__r.QualifiedApiName, Object_Control_Field__r.QualifiedApiName, Allow_Multiple_Clause_Bundles__c, Operator__c, Managed_Clause_Object__r.QualifiedApiName, Managed_Clause_Lookup_Field__r.QualifiedApiName ';
        query+= 'FROM Clause_Bundle_Mapping__mdt ';
        query+= 'WHERE Active__c = true AND Object__r.QualifiedApiName = :objectApiName AND Test_Case__c = {0}';

        String queryParam = Test.isRunningTest() ? 'true' : 'false';
        query = String.Format(query, new String[] {queryParam});
        List<Clause_Bundle_Mapping__mdt> mappings = Database.query(query);
        return new Map<Id, Clause_Bundle_Mapping__mdt>(mappings);
    }

    private static Map<Id, List<Clause_Bundle_Mapping_Parameter__mdt>> getMappingsParameters(Set<Id> mappingIds) {
        Map<Id, List<Clause_Bundle_Mapping_Parameter__mdt>> returnMap = new Map<Id, List<Clause_Bundle_Mapping_Parameter__mdt>>();
        List<Clause_Bundle_Mapping_Parameter__mdt> mappingsParameters = [
            SELECT
                Clause_Bundle_Mapping__c,
                Source_Object__r.QualifiedApiName,
                Source_Field__r.QualifiedApiName,
                Target_Object__r.QualifiedApiName,
                Target_Field__r.QualifiedApiName,
                Type__c,
                Value__c,
                Required__c
            FROM Clause_Bundle_Mapping_Parameter__mdt 
            WHERE Active__c = true AND Clause_Bundle_Mapping__c IN :mappingIds
        ];
        if (mappingsParameters.isEmpty()) return returnMap;
        for (Clause_Bundle_Mapping_Parameter__mdt mp : mappingsParameters) {
            if (!returnMap.containsKey(mp.Clause_Bundle_Mapping__c)) returnMap.put(mp.Clause_Bundle_Mapping__c, new List<Clause_Bundle_Mapping_Parameter__mdt>());
            returnMap.get(mp.Clause_Bundle_Mapping__c).add(mp);
        }
        return returnMap;
    }

    private static List<APXT_Redlining__Clause_Bundle__c> getAllClauseBundles(List<MappingInfo> mappingInfos) {

        Set<String> fields = new Set<String> { 'Id', 'Name', 'Order__c'};

        for (MappingInfo info : mappingInfos) {
            for (MappingParameter param : info.bundleSelectionCriterias) {
                fields.add(param.targetFieldName);
            }
            for (MappingParameter param : info.fieldAssignments) {
                fields.add(param.sourceFieldName);
            }
        }

        if (fields.isEmpty()) return new List<APXT_Redlining__Clause_Bundle__c>();

        String fromClause = String.join(new List<String>(fields),',');
        String query = 'SELECT {0} FROM APXT_Redlining__Clause_Bundle__c ORDER BY Order__c NULLS LAST';
        query = String.Format(query, new List<String> { fromClause });
        return Database.query(query);
    }

    private static List<APXT_Redlining__Managed_Clause__c> getObjectRelatedManagedClauses(String managedClauseLookupFieldName, Set<Id> objectIds) {
        String query = 'SELECT Id, APXT_Redlining__Clause_Revision__r.APXT_Redlining__Clause__c, APXT_Redlining__Order__c FROM APXT_Redlining__Managed_Clause__c WHERE ' + managedClauseLookupFieldName + ' IN ';
        query += ':objectIds';
        return Database.Query(query);
    }

    private static Map<Id, List<APXT_Redlining__Managed_Clause__c>> getObjectRelatedManagedClausesMap(String managedClauseLookupFieldName, Set<Id> objectIds) {
        String query = 'SELECT Id, APXT_Redlining__Clause_Revision__r.APXT_Redlining__Clause__c, APXT_Redlining__Order__c, ' + managedClauseLookupFieldName + ' FROM APXT_Redlining__Managed_Clause__c WHERE ' + managedClauseLookupFieldName + ' IN ';
        query += ':objectIds';
        query += ' ORDER BY ' + managedClauseLookupFieldName + ', APXT_Redlining__Order__c';
        List<APXT_Redlining__Managed_Clause__c> managedClauses = Database.Query(query);
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> objectIdToManagedClausesListMap = new Map<Id, List<APXT_Redlining__Managed_Clause__c>>();
        if (managedClauses.isEmpty()) return objectIdToManagedClausesListMap;
        for (APXT_Redlining__Managed_Clause__c mc : managedClauses) {
            Id objectId = (Id)mc.get(managedClauseLookupFieldName);
            if (!objectIdToManagedClausesListMap.containsKey(objectId)) objectIdToManagedClausesListMap.put(objectId, new List<APXT_Redlining__Managed_Clause__c>());
            objectIdToManagedClausesListMap.get(objectId).add(mc);
        }
        return objectIdToManagedClausesListMap;
    }

    private static List<APXT_Redlining__Bundle_Clause__c> getBundledClausesByClauseBundleIds(Set<Id> clauseBundleIds)  {
        return [
            SELECT
                Id,
                Name,
                APXT_Redlining__Clause_Bundle__r.Order__c,
                APXT_Redlining__Clause__c,
                APXT_Redlining__Clause_Bundle__c,
                APXT_Redlining__Clause__r.Name, 
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__c,                 
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text__c,
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text_Rich__c,
                APXT_Redlining__Clause__r.APXT_Redlining__Text__c, 
                APXT_Redlining__Clause__r.APXT_Redlining__Text_Rich__c,
                APXT_Redlining__Order__c
            FROM APXT_Redlining__Bundle_Clause__c
            WHERE APXT_Redlining__Clause_Bundle__c IN :clauseBundleIds
            ORDER BY APXT_Redlining__Clause_Bundle__r.Order__c, APXT_Redlining__Order__c
        ];           
    }

    private static List<sObject> getAssignmentObjects(String objectName, Set<String> fromFields, Set<Id> objectIds) {
        if (objectName == null || objectName == '' || fromfields == null || fromFields.isEmpty() || objectIds == null || objectIds.isEmpty()) return new List<sObject>();
        fromFields.addAll(new List<String> { 'Id', 'Name'});
        String targetAssignmentObjectFromFields = String.Join(new List<String>(fromFields), ',');        
        String query = 'SELECT {0} FROM {1} WHERE Id IN ';
        query = String.Format(query, new List<String> {targetAssignmentObjectFromFields, objectName});
        query += ':objectIds';
        return Database.Query(query);
    }
}