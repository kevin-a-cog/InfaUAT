({
	 defaultfun : function (component) {
       var dashboardURL =  $A.get("$Label.c.Proforma_Dashboard1");
    	//window.open(dashboardURL,'name','left=100,top=300,height=400,width=900,location=0');
	},
    
	 gotoURL1 : function (component) {
       var dashboardURL =  $A.get("$Label.c.Proforma_Dashboard1");
    	window.open(dashboardURL,'name','height=900,width=1600,location=0');
	},
    gotoURL2 : function (component) {
       var dashboardURL =  $A.get("$Label.c.Proforma_Dashboard2");
    	window.open(dashboardURL,'name','height=900,width=1600,location=0');
	}
})