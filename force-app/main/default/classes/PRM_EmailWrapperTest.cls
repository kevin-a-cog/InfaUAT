/****************************************************************************************************************************
 *  @Class Name: PRM_EmailWrapperTest
 *  @Author: Puneet
 *  @Date: 
 *  @Description: This is test class for PRM_EmailWrapper
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/
@IsTest
public class PRM_EmailWrapperTest {
    
    @IsTest
    private static void basicTest(){
        PRM_EmailWrapper wrap = new PRM_EmailWrapper();
        wrap.ccEmails = 'test';
        wrap.recordId = 'test';
        wrap.userId = 'test';
        wrap.templateId = 'test';
        wrap.subject = 'test';
    }
}