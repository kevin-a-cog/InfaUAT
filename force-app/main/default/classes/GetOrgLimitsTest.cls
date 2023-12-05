/*
Class:          GetOrgLimitsTest 
@Author:        Mohammed Anies
@Created Date:  30 July 2022
@Description:   Test Class for GetOrgLimits


Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag

******************************************************************************************************************************
*/
@isTest
public class GetOrgLimitsTest {
    
     static testMethod void GetAllLimits()
    {
        integer orgLimitsSize = GetOrgLimits.getAll().size();
        system.assert(orgLimitsSize > 1, 'Org Limits Size not greater than 1');
    }

}