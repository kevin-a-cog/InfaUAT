/*
Class:          PRMProductHandlerUtilityTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for PRMProductHandlerUtility

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest
public class PRMProductHandlerUtilityTest {
	@testSetup
    static void setupObjectTestData() {
        
    }
    // This test method creates data to be used during Adding/Removing Products in PRM using inheritance
    @isTest 
    public static void testMethodAddRemProducts(){
		
        //Used to cover the constructor method in PRMProductHandlerUtility
        PRMProductHandlerUtility psdp = new PRMProductHandlerUtility();

        List<PRMProductHandlerUtility.FieldSetMember> fset2 = PRMProductHandlerUtility.getFieldDetails('Product2', 'PRM_AddProductsFieldSet');
        if(fset2 != null && !fset2.isEmpty())
        {
        	Integer recordsNumberfset2 = fset2.size();
            system.assert(recordsNumberfset2 > 0);
			system.assertEquals(fset2.size(),4);
        }
        Map<String, List<String>> dependentPicklistMap = PRMProductHandlerUtility.getDependentPicklistValues('Product2','PRM_Product_Family__c','PRM_Product_Sub_Family__c');
		if(dependentPicklistMap != null && !dependentPicklistMap.isEmpty())
        {
        	Integer sizeMap = dependentPicklistMap.size();
            system.assert(sizeMap > 0);
			system.assertEquals(sizeMap,6);
        }
        List<PRMProductHandlerUtility.SelectOption> productPickList = PRMProductHandlerUtility.getPicklistValues('Product2','PRM_Product_Family__c');
        if(productPickList != null && !productPickList.isEmpty())
        {
        	Integer recordsNumberPrdctList = productPickList.size();
            system.assert(recordsNumberPrdctList > 0);
			system.assertEquals(recordsNumberPrdctList,6);
        }
        
        PRMProductHandlerUtility.prmProductFamilySet();
		system.assertEquals(PRMProductHandlerUtility.prmProductFamilySet().size(),6);
    }
}