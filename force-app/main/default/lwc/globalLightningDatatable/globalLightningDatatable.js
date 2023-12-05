/*
 * Name			:	GlobalLightningDatatable
 * Author		:	Gabriel Coronel
 * Created Date	: 	6/6/2021
 * Description	:	Custom version of the Lightning Datatable.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Gabriel Coronel		6/6/2021		N/A				Initial version.			N/A
 */

//Core imports.
import LightningDatatable from "lightning/datatable";

//Templates.
import customCell from "./customCell";
 
 //Class body.
export default class GlobalLightningDatatable extends LightningDatatable {
 
	//Custom Types.
	static customTypes = {
		custom: {
			template: customCell,
			typeAttributes: [
				"label",
				"objectapiname",
				"boolisname",
				"mapids",
				"editable",
				"fieldapiname",
				"parentobjectapiname",
				"subtype",
				"tableid",
				"columnlabel"
			]
		}
	}
}