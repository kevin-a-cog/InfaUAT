/**
 * @description       :
 * @author            : Sathish Rajalingam
 * @group             :
 * @last modified on  : 10-28-2020
 * @last modified by  : Sathish Rajalingam
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   10-28-2020   Sathish Rajalingam   Initial Version
 
 * Change History
***************************************************************************************************************************************************
Modified By            Date            Jira No.            Description                                                                   Tag
***************************************************************************************************************************************************
Deeksha Shetty        10-Apr-2023      I2RT-8075         UAT Env - Parameter article type - Issue observed in "Article Details" screen    T1
 **/
public class knowledgeRenderAsPDF {
	public Knowledge__kav knwldgeRec {get; set;}
	public String NonEngCss {get; set;}
	public String currentRecordId {get; set;}
	public String langValue {get; set;}

	public knowledgeRenderAsPDF(ApexPages.StandardController controller) {
		currentRecordId  = ApexPages.CurrentPage().getparameters().get('Id');
		langValue  = ApexPages.CurrentPage().getparameters().get('Language');
		knwldgeRec = [select id,title, Description__c, Solution__c, Additional_Information__c,Problem_Type__c,User_Types__c,Project_Phases__c,Primary_Product__c,Product_Component__c,Product_Version__c,Also_Applies_To__c,Last_Modified_Date__c,urlname,Language,
                      Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,
                      Alternate_Value__c,Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
                      from Knowledge__kav where KnowledgeArticleId =: currentRecordId and Language =: langValue];

		String title = knwldgeRec.UrlName;
		if(knwldgeRec.Language == 'en_US')
		{
			NonEngCss = 'body { font-family: \'futura-pt\', sans-serif;  margin: 0px; }';
		}
		else {
			NonEngCss = 'body { margin: 0px; }  body, .SharepointToSalesforceMigrationCss { font-family: \'Arial Unicode MS\' !important;   }';
		}
		//Assign "KB_UrlName.pdf" as a file name
		String fileName = 'KB_' + title + '.pdf';
		Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
	}

}