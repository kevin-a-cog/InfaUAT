/*
@created by       : Wasim
@created on       : 08/24/2023
@Purpose          : Controller class for the VF component ApprovalRequestComments to get the Last approval comment and use it in the VF Email Template.

Change History
**************************************************************************************************************************************************
ModifiedBy      |Date           |Requested By   |Description                                                                    |  Jira No.     | Tag No:
**************************************************************************************************************************************************
*/
public class ApprovalRequestCommentsController {

    // ID of the record whose most recent approval process comments to retrieve
    @TestVisible
    public ID targetObjectId { get; set; }
    
    // The most recent approval process comments
    // Could show in visualforce email template, for example
    @TestVisible
    public String comments {
        get {
            if ( comments == null || comments == '') {
            	ProcessInstanceStep lastStep = getLastApprovalStep();
            	comments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return comments;
        }
        private set;
    }
    
    public ApprovalRequestCommentsController() {}
    
    // Queries the most recent approval process step for the target record
    public ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([SELECT	Comments FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId = :targetObjectId ORDER BY SystemModStamp DESC LIMIT 1]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }
    
}