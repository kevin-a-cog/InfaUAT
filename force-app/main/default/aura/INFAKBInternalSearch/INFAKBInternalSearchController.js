({
    doInit: function (component, event, helper) {
        try {
            window.location = '/lightning/cmp/c__INFAKBContentSearch';
        } catch (e) {
            console.error('INFAKBInternalSearch : Error in method doInit : ' + e.message);
        }
    }
});