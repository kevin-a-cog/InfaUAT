try
{
    if (Coveo != 'undefined') {
        // Coveo.TemplateCache.registerTemplate("helpDiscLandingCard", Coveo.HtmlTemplate.fromString(helpDiscLandingTemplate.template.querySelector(".helpDiscLandingCard").innerHTML,
        // { "condition": null, "layout": "card", "fieldsToMatch": null, "mobile": null, "role": null }), true, true);
        Coveo.TemplateCache.registerTemplate("Default", Coveo.HtmlTemplate.fromString(helpDiscLandingTemplate.template.querySelector(".Default").innerHTML,
        { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true); 
        Coveo.TemplateCache.registerTemplate("helpDiscLandingList", Coveo.HtmlTemplate.fromString(helpDiscLandingTemplate.template.querySelector(".helpDiscLandingList").innerHTML,
        { "condition": null, "layout": "list", "fieldsToMatch": [{ 'field': 'infadocumenttype', 'values': ['UserFeed'] }], "mobile": null, "role": null }), true, true);
        Coveo.TemplateCache.registerTemplate("helpDiscComment", Coveo.HtmlTemplate.fromString(helpDiscLandingTemplate.template.querySelector(".helpDiscComment").innerHTML,
        { "condition": null, "layout": "list", "fieldsToMatch": [{ 'field': 'infadocumenttype', 'values': ['FeedComment'] }], "mobile": null, "role": null }), true, true);
        Coveo.TemplateCache.registerTemplate("helpDiscChildResults", Coveo.HtmlTemplate.fromString(helpDiscLandingTemplate.template.querySelector(".helpDiscChildResults").innerHTML,
        { "condition": null, "layout": "list", "fieldsToMatch": null, "mobile": null, "role": null }), true, true);
    }
} catch (ex) {
    console.error("Method : helpDiscussionLanding ResultTemplate Error :" + ex);
}