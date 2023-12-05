({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var accs = myPageRef.state.c__contractid;
        console.log('contractId',JSON.stringify(accs));
        cmp.set("v.contractId",accs);
        //split the account ids by comma and continue logic
    }
})