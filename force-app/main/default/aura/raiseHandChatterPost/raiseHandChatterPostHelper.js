({
    getParameterByName: function(parameterName) {
        parameterName = parameterName.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + parameterName + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    openChatterPostInNewTab: function(feedItemId, workspaceAPI){
        console.log('feedItemId >>' + feedItemId);
        workspaceAPI.openTab({
            recordId: feedItemId,
            focus: true
        }).then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    openChatterPost: function(feedItemId, workspaceAPI){
        console.log('feedItemId >>' + feedItemId);
        workspaceAPI.openSubtab({
            recordId: feedItemId,
            focus: true
        }).then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})