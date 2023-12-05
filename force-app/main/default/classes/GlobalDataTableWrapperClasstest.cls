/*
Class:          GlobalDataTableWrapperClasstest 
@Author:        Venky K
@Created Date:  5 Oct 2021  
@Description:   Test class for GlobalDataTableWrapperClass
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/
@isTest
public class GlobalDataTableWrapperClasstest {
    
   
    @isTest
    static void testwrapper(){
        GlobalDataTableWrapperClass objRecord = new GlobalDataTableWrapperClass();
			GlobalDataTableWrapperClass.ColumnWrapperClass objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();

			//We first set values.
			objRecord.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();
			objColumn.target = '_blank';
			objColumn.objType = Schema.DisplayType.Picklist;
			objRecord.lstColumns.add(objColumn);
			//objColumn.subtype = 'test';
			//Now we get values.
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Boolean;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Email;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Date;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Double;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Percent;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Reference;
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
        
        objRecord.strRecordId = 'test';
        objRecord.strMainFilterFieldAPIName = 'test';
        objRecord.strObjectName = 'test';
        objRecord.strFielSetName = 'test';
        objRecord.lstRecordIds = new List<String>();
        objRecord.lstFieldNames = new List<String>();
        objRecord.lstAdditionalFilters = new List<String>();
        objRecord.lstRecords =  new List<sObject>();
        
        objColumn.boolIsFormula = true;
            objColumn.initialWidth = 1;
            objColumn.strParentObject = 'test';
            objColumn.strFieldName = 'test';
            objColumn.label = 'test';
            objColumn.sortable = 'test';
    }
}