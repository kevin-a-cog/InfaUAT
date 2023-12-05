/*
        Trigger:        AssetAfterDelete
        @Author:        Thejaswini Sattenapalli
        @Created Date:  5 August 2017
        @Description:   Trigger on Asset After Delete Operations
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy      Date        Requested By        Description                                                 
    Kendra          08/29/2017  Prasanth            Added logic to update Marked for Review and Provision Counts on Order if an Asset is deleted    
    Mitra           10/20/2017                      Moved logic to update Marked for Review and provision Counts on Order if an Asset is deleted
                                                    to the Before Delete Trigger Context
    ********************************************************************************************************************************************
   
*/
trigger AssetAfterDelete on Asset (After Delete) {
    if(globalApexManager.avoidRecursion('AssetAfterDelete') ) {
        return;
    }
}