try
{
    Coveo.TemplateCache.registerTemplate("KBCaseDeflectionTemplate", Coveo.HtmlTemplate.fromString(esCaseDeflectionTemplate.template.querySelector(".KBCaseDeflectionTemplate").innerHTML, { "condition": null, "layout": "list", "fieldsToMatch": [{ "field": "objecttype", "values": ["Knowledge"] }], "mobile": null, "role": null }), true, true); esCaseDeflectionTemplate.template.querySelector(".KBCaseDeflectionTemplate").innerHTML = "";
    Coveo.TemplateCache.registerTemplate("Default", Coveo.HtmlTemplate.fromString(esCaseDeflectionTemplate.template.querySelector(".Default").innerHTML, { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true); esCaseDeflectionTemplate.template.querySelector(".Default").innerHTML = "";
} catch (ex) {
    console.error("Method : esCaseDeflection ResultTemplate Error :" + ex);
}
