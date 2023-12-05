/*
 * Name			:	esCaseListView
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/24/2022
 * Description	:	This is used to show case in a List view.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh Divakaran	    9/24/2022		I2RT-6880		Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class EsCaseListView extends LightningElement {

    //Public variables
    @api objCase;

    //Private variables
    label = {
        Case_Number: 'Case Number',
        Priority: 'Priority',
        Product: 'Product',
        Status: 'Status',
        Org_ID: 'Org ID',
        Next_Action: 'Next Action',
        Subject: 'Case Subject / Title'
    };

    /*
      Method Name : redirectToIN
      Description : This method redirects user to the case detail page.
      Parameters  : None
      Return Type : None
    */
    redirectToCase(objEvent){
        let strRecordId = objEvent?.currentTarget?.dataset?.id;
        if(objUtilities.isNotBlank(strRecordId)){
            window.open(`casedetails?caseId=${strRecordId}`, '_self');
        }
    }

}