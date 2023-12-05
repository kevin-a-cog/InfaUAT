/***************************************************************************************************************************************************************
 *  @Class Name: GenerateDocWithoutTaxController
 *  @Author: Chandana Gowda
 *  @Date: 19 Sept 2023
 *  @Description: created as part of PoC to check performance of generate Doc button, without making tax call                            
 ****************************************************************************************************************************************************************/
public class GenerateDocWithoutTaxController {
    public SBQQ__Quote__c quoteObj {get;set;}
    
    public GenerateDocWithoutTaxController(ApexPages.StandardController stdController) {
        this.quoteObj = (SBQQ__Quote__c)stdController.getRecord();
    }
    public void generateIPUEntitlements(){
        new AnnualizeIPUQuantitiesCls().createAnnualCommitments(quoteObj.Id);
    }    
}