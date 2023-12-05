/*
 * Name         :   HelpHeading
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is a base component for setting headers for OOB components.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     Utopia-ph-3         Initial version.                                          NA
 */
import { api, LightningElement } from 'lwc';

export default class HelpHeading extends LightningElement {
    @api title;
    @api headingClass = "in-feeds-heading in-heading in-orange";

}