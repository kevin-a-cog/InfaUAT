/*
@created by       : Wasim Akram
@created on       : 22/05/2023
@Purpose          : Class to utilize Unit of Work Pattern

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/	
public class UnitOfWork{
    protected List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();
    protected Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();
    protected Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();
    protected Map<String, Relationships> m_relationships = new Map<String, Relationships>();
    protected Map<String, Map<Id, SObject>> m_deletedMapByType = new Map<String, Map<Id, SObject>>();
    protected IDML m_dml;
    public class UnitOfWorkException extends Exception {}
    public interface IDML
    {
        void dmlInsert(List<SObject> objList);
        void dmlUpdate(List<SObject> objList);
        void dmlDelete(List<SObject> objList);
    }
    
    public virtual class SimpleDML implements IDML
    {
        public virtual void dmlInsert(List<SObject> objList)
        {
            insert objList;
        }
        public virtual void dmlUpdate(List<SObject> objList)
        {
            update objList;
        }
        public virtual void dmlDelete(List<SObject> objList)
        {
            delete objList;
        }
    }
    public UnitOfWork(List<Schema.SObjectType> sObjectTypes)
    {
        this(sObjectTypes,new SimpleDML());
    }
    public UnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)
    {
        m_sObjectTypes = sObjectTypes.clone();
        
        for (Schema.SObjectType sObjectType : m_sObjectTypes)
        {
            // register the type
            handleRegisterType(sObjectType);
        }
        
        m_relationships.put(Messaging.SingleEmailMessage.class.getName(), new Relationships());
        
        m_dml = dml;
    }
    /**
* Registers the type to be used for DML operations
*
* @param sObjectType - The type to register
*
*/
    private void handleRegisterType(Schema.SObjectType sObjectType)
    {
        String sObjectName = sObjectType.getDescribe().getName();
        
        // add type to dml operation tracking
        m_newListByType.put(sObjectName, new List<SObject>());
        m_dirtyMapByType.put(sObjectName, new Map<Id, SObject>());
        m_deletedMapByType.put(sObjectName, new Map<Id, SObject>());
        m_relationships.put(sObjectName, new Relationships());
    }
    /**
* Register a newly created SObject instance to be inserted when commitWork is called
*
* @param record A newly created SObject instance to be inserted during commitWork
**/
    public void registerNew(SObject record)
    {
        registerNew(record, null, null);
    }
    
    /**
* Register a list of newly created SObject instances to be inserted when commitWork is called
*
* @param records A list of newly created SObject instances to be inserted during commitWork
**/
    public void registerNew(List<SObject> records)
    {
        for (SObject record : records)
        {
            registerNew(record, null, null);
        }
    }
    
    /**
* Register a newly created SObject instance to be inserted when commitWork is called,
*   you may also provide a reference to the parent record instance (should also be registered as new separately)
*
* @param record A newly created SObject instance to be inserted during commitWork
* @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
* @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
**/
    public void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
    {
        if (record.Id != null)
            throw new UnitOfWorkException('Only new records can be registered as new');
        String sObjectType = record.getSObjectType().getDescribe().getName();
                
        m_newListByType.get(sObjectType).add(record);
        if (relatedToParentRecord!=null && relatedToParentField!=null)
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
    }
    
    /**
* Register a relationship between two records that have yet to be inserted to the database. This information will be
*  used during the commitWork phase to make the references only when related records have been inserted to the database.
*
* @param record An existing or newly created record
* @param relatedToField A SObjectField reference to the lookup field that relates the two records together
* @param relatedTo A SObject instance (yet to be committed to the database)
*/
    public void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
    {
        String sObjectType = record.getSObjectType().getDescribe().getName();
                
        m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);
    }
    /**
* Register an existing record to be updated during the commitWork method
*
* @param record An existing record
**/
    public void registerDirty(SObject record)
    {
        registerDirty(record, new List<SObjectField>());
    }
    
    /**
* Registers the entire records as dirty or just only the dirty fields if the record was already registered
*
* @param records SObjects to register as dirty
* @param dirtyFields A list of modified fields
*/
    public void registerDirty(List<SObject> records, List<SObjectField> dirtyFields)
    {
        for (SObject record : records)
        {
            registerDirty(record, dirtyFields);
        }
    }
    
    /**
* Registers the entire record as dirty or just only the dirty fields if the record was already registered
*
* @param record SObject to register as dirty
* @param dirtyFields A list of modified fields
*/
    public void registerDirty(SObject record, List<SObjectField> dirtyFields)
    {
        if (record.Id == null)
            throw new UnitOfWorkException('New records cannot be registered as dirty');
        String sObjectType = record.getSObjectType().getDescribe().getName();
        
        // If record isn't registered as dirty, or no dirty fields to drive a merge
        if (!m_dirtyMapByType.get(sObjectType).containsKey(record.Id) || dirtyFields.isEmpty())
        {
            // Register the record as dirty
            m_dirtyMapByType.get(sObjectType).put(record.Id, record);
        }
        else
        {
            // Update the registered record's fields
            SObject registeredRecord = m_dirtyMapByType.get(sObjectType).get(record.Id);
            
            for (SObjectField dirtyField : dirtyFields) {
                registeredRecord.put(dirtyField, record.get(dirtyField));
            }
            
            m_dirtyMapByType.get(sObjectType).put(record.Id, registeredRecord);
        }
    }
    
    /**
* Register an existing record to be updated when commitWork is called,
*   you may also provide a reference to the parent record instance (should also be registered as new separately)
*
* @param record A newly created SObject instance to be inserted during commitWork
* @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
* @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
**/
    public void registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
    {
        registerDirty(record);
        if (relatedToParentRecord!=null && relatedToParentField!=null)
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
    }
    
    /**
* Register a list of existing records to be updated during the commitWork method
*
* @param records A list of existing records
**/
    public void registerDirty(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerDirty(record);
        }
    }
    /**
* Register a new or existing record to be inserted/updated during the commitWork method
*
* @param record A new or existing record
**/
    public void registerUpsert(SObject record)
    {
        if (record.Id == null) 
        {
            registerNew(record, null, null);
        }
        else
        {
            registerDirty(record, new List<SObjectField>());
        }
    }
    
    /**
* Register a list of mix of new and existing records to be inserted updated during the commitWork method
*
* @param records A list of mix of new and existing records
**/
    public void registerUpsert(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerUpsert(record);
        }
    }
    
    /**
* Register an existing record to be deleted during the commitWork method
*
* @param record An existing record
**/
    public void registerDeleted(SObject record)
    {
        if (record.Id == null)
            throw new UnitOfWorkException('New records cannot be registered for deletion');
        String sObjectType = record.getSObjectType().getDescribe().getName();
        
        m_deletedMapByType.get(sObjectType).put(record.Id, record);
    }
    
    /**
* Register a list of existing records to be deleted during the commitWork method
*
* @param records A list of existing records
**/
    public void registerDeleted(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerDeleted(record);
        }
    }    
   
    /**
* Takes all the work that has been registered with the UnitOfWork and commits it to the database
**/
    public void commitWork()
    {
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        try
        {
            doCommitWork();
            wasSuccessful = true;
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            throw e;
        }
    }
    private void doCommitWork()
    {
        insertDmlByType();
        updateDmlByType();
        deleteDmlByType();
    }
    private void insertDmlByType()
    {
        for (Schema.SObjectType sObjectType : m_sObjectTypes)
        {
            m_relationships.get(sObjectType.getDescribe().getName()).resolve();
            m_dml.dmlInsert(m_newListByType.get(sObjectType.getDescribe().getName()));
        }
    }
    
    private void updateDmlByType()
    {
        for (Schema.SObjectType sObjectType : m_sObjectTypes)
        {
            m_dml.dmlUpdate(m_dirtyMapByType.get(sObjectType.getDescribe().getName()).values());
        }
    }
    
    private void deleteDmlByType()
    {
        Integer objectIdx = m_sObjectTypes.size() - 1;
        while (objectIdx >= 0)
        {
            m_dml.dmlDelete(m_deletedMapByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName()).values());
        }
    }
    private class Relationships
    {
        private List<IRelationship> m_relationships = new List<IRelationship>();
        
        public void resolve()
        {
            // Resolve relationships
            for (IRelationship relationship : m_relationships)
            {
                //relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
                relationship.resolve();
            }
            
        }
        public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
        {
            // Relationship to resolve
            Relationship relationship = new Relationship();
            relationship.Record = record;
            relationship.RelatedToField = relatedToField;
            relationship.RelatedTo = relatedTo;
            m_relationships.add(relationship);
        }
    }
    private interface IRelationship
    {
        void resolve();
    }
    private class Relationship implements IRelationship
    {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public SObject RelatedTo;
        
        public void resolve()
        {
            this.Record.put( this.RelatedToField, this.RelatedTo.Id);
        }
    }
}