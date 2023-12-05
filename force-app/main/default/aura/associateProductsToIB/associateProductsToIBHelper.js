({
  //Getting the values for the picklist
  getPicklistValues: function(component, event, helper) {
    var action = component.get("c.getPicklistValues");
    action.setCallback(this, function(result) {
      var res = result.getReturnValue();
      component.set("v.forecastProductList", res.forecastProduct);
      component.set("v.productFamilyList", res.productFamily);
      component.set("v.businessUnitList", res.businessUnit);
    });
    $A.enqueueAction(action);
  },

  //instantiating the column header for displaying the records
  getColumnDefinitions: function(component, helper) {
    var columns = [];
    var addProdButton = {
      label: "",
      type: "button-icon",
      initialWidth: 80,
      typeAttributes: {
        alternativeText: "Add Product",
        iconName: "utility:add",
        name: "addProduct",
        disabled: { fieldName: "Is_Selected__c" },
        variant: "border-filled",
        class: "slds-m-left_xx-small"
      }
    };
    columns.push(addProdButton);
    var action = component.get("c.getFields");
    action.setCallback(this, function(result) {
      var res = result.getReturnValue();
      //formating the data as required by the lightning:datatable
      for (var each in res) {
        var column = new Map();
        column["label"] = each;
        column["fieldName"] = res[each];
        column["type"] = "text";
        columns.push(column);
      }
      component.set("v.productColumns", columns);
      helper.getProducts(component);
    });
    $A.enqueueAction(action);
  },

  addProduct: function(component, helper, row) {
    var prodId = row.Id;
    var pillsList = component.get("v.pillsList");
    var products = component.get("v.products");
    //To check if list is not empty or null
    if (!$A.util.isEmpty(products) && !$A.util.isUndefined(products)) {
      for (var i = 0; i < products.length; i++) {
        if (products[i].Id == prodId) {
          products[i].Is_Selected__c = Boolean("TRUE");
          pillsList.push(products[i]);
        }
      }
      component.set("v.products", products);
      component.set("v.pillsList", pillsList);
    }
  },
  //Commiting the installBase Mapping records
  addInstallBaseMappingRecords: function(component, helper, records) {
    var action = component.get("c.insertinstallBaseMapping");
    var installBase = component.get('v.installBase');
    action.setParams({ installBaseMappings: records });
    action.setCallback(this, function(result) {
      //alert('installBaseMappingRecords Added!');
      //$A.get("e.force:closeQuickAction").fire();
      var sURL = $A.get("$Label.c.PRM_Org_Url") + "lightning/r/InstallBase__c/" + installBase+"/view";
      //alert(sURL);
      sforce.one.navigateToURL(sURL); 
      $A.get('e.force:refreshView').fire();
    });
    $A.enqueueAction(action);
  },
  //Packing the product and InstallBase records for inserting the InstallBase Mapping records
  packInstallBaseMappingRecords: function(component, helper) {
    var records = [];
    var products = component.get("v.pillsList");
    var installBase = component.get("v.installBase");
    //alert(installBase);
    for (var each in products) {
      var rec = new Map();
      rec["Product__c"] = products[each].Id;
      //alert('products[each].Id.....'+products[each].Id);
      rec["Install_Base__c"] = installBase;
      records.push(rec);
    }
    helper.addInstallBaseMappingRecords(component, helper, records);
  },
  //for searching the products based on the filter
  getProducts: function(component) {
    
    var queryString = "";
    var columns = component.get("v.productColumns");
    var queryfields = [];
    for (var each = 1; each < columns.length; each++) {
      queryfields.push(columns[each].fieldName);
    }
    var searchKeyword = component.get('v.searchKeyword').length > 0 ? component.get('v.searchKeyword') : "";
    var action = component.get("c.getProducts");
    action.setParams({
      searchKeyword: searchKeyword,
      forecastProduct: component.get("v.forecastProduct"),
      addOnCountry: component.get("v.addOnCountry"),
      addOnCategory: component.get("v.addOnCategory"),
      productFamily: component.get("v.productFamily"),
      businessUnit: component.get("v.businessUnit"),
      queryfields: queryfields,
      installBase: component.get("v.recordId"),
      pillsList: component.get("v.pillsList")
    });
    action.setCallback(this, function(result) {
      var res = result.getReturnValue();
      component.set("v.products", res);
    });
    $A.enqueueAction(action);
  }
});