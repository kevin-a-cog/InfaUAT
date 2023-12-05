try {
    console.log('INside template resgiter js');
    if (Coveo != 'undefined') {
        Coveo.TemplateCache.registerTemplate("Default",
            Coveo.HtmlTemplate.fromString(csmDefaultTemplate.template.querySelector(".Default").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true);
        csmDefaultTemplate.template.querySelector(".Default").innerHTML = "";
        Coveo.TemplateCache.registerTemplate("CosmosPlan",
            Coveo.HtmlTemplate.fromString(csmDefaultTemplate.template.querySelector(".CosmosPlan").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": [{ "field": "objecttypelabel", "values": ["Plan"] }], "mobile": null, "role": null }), true, true);
        csmDefaultTemplate.template.querySelector(".CosmosPlan").innerHTML = "";
        Coveo.TemplateCache.registerTemplate("CosmosMilestone",
            Coveo.HtmlTemplate.fromString(csmDefaultTemplate.template.querySelector(".CosmosMilestone").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": [{ "field": "objecttypelabel", "values": ["Milestone"] }], "mobile": null, "role": null }), true, true);
        csmDefaultTemplate.template.querySelector(".CosmosMilestone").innerHTML = "";
        Coveo.TemplateCache.registerTemplate("CosmosObjective",
            Coveo.HtmlTemplate.fromString(csmDefaultTemplate.template.querySelector(".CosmosObjective").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": [{ "field": "objecttypelabel", "values": ["Objective"] }], "mobile": null, "role": null }), true, true);
        csmDefaultTemplate.template.querySelector(".CosmosObjective").innerHTML = "";
        Coveo.TemplateCache.registerTemplate("CosmosComments",
            Coveo.HtmlTemplate.fromString(csmDefaultTemplate.template.querySelector(".CosmosComments").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": [{ "field": "objecttypelabel", "values": ["Plan Comment"] }], "mobile": null, "role": null }), true, true);
        csmDefaultTemplate.template.querySelector(".CosmosComments").innerHTML = "";
    }
    console.log('After register : ', csmDefaultTemplate);
} catch (ex) {
    console.error("Method : csmDefaultTemplate ResultTemplate Error :" + ex);
}
