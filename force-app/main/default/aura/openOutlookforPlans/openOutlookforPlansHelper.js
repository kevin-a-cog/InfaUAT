({
	makeTextFile : function(textbox) {
        var textFile = null;
		var data = new Blob([textbox], {type: 'text/plain'});

    if (textFile !== null) {
      window.URL.revokeObjectURL(textFile);
    }
 
    textFile = window.URL.createObjectURL(data);
    console.log('txt file'+textFile);
    return textFile;
	}
})