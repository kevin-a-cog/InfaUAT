trigger DiscountApprovalBeforeDelete on DiscountApproval__c (before delete) {

CustomPermissionsReader csm = new CustomPermissionsReader();
 if(!(csm.hasPermission('SystemAdmin')) && (!csm.hasPermission('IntegrationUser')))
{
  for(DiscountApproval__c DA:trigger.old){
DA.addError('Insufficient Previleges to Delete Discount Approval Record');
}
}


}