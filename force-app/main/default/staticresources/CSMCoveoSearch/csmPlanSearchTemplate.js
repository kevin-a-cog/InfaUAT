try
{
    console.log("Registering CSM Plan Search Templates");

    if (Coveo != undefined && csmPlanSearchTemplate != undefined) {
        Coveo.TemplateCache.registerTemplate("Default",
            Coveo.HtmlTemplate.fromString(csmPlanSearchTemplate.template.querySelector(".Default").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true);
                csmPlanSearchTemplate.template.querySelector(".Default").innerHTML = "";
        Coveo.TemplateCache.registerTemplate("CsmPlanResultTemplate", Coveo.HtmlTemplate.fromString(csmPlanSearchTemplate.template.querySelector(".CsmPlanResultTemplate").innerHTML,
                { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true);
                csmPlanSearchTemplate.template.querySelector(".CsmPlanResultTemplate").innerHTML = "";
                
    }
} catch (ex) {
    console.error("Method : CSM Plan Search Template Register Error :" + ex);
}
