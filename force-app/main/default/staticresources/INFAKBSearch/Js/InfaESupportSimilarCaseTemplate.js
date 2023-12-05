try
{
    Coveo.TemplateCache.registerTemplate("KBSimilarCasesTemplpate", Coveo.HtmlTemplate.fromString(esSimilarCasesTemplate.template.querySelector(".KBSimilarCasesTemplpate").innerHTML, { "condition": null, "layout": "card", "fieldsToMatch": [{ "field": "objecttype", "values": ["Knowledge"] }], "mobile": null, "role": null }), true, true); esSimilarCasesTemplate.template.querySelector(".KBSimilarCasesTemplpate").innerHTML = "";
    Coveo.TemplateCache.registerTemplate("Default", Coveo.HtmlTemplate.fromString(esSimilarCasesTemplate.template.querySelector(".Default").innerHTML, { "condition": null, "layout": "card", "fieldsToMatch": null, "mobile": null, "role": null }), true, true); esSimilarCasesTemplate.template.querySelector(".Default").innerHTML = "";
} catch (ex) {
    console.error("Method : esSimilarCase ResultTemplate Error :" + ex);
}

