var Coveo = Coveo || (Coveo = {});
Coveo.PS = {};


//----------------------------------------------------------------------------
// CustomNoResult Component
// The purpose of the component is to add a quick action in the Coveo Insight Panel.
//----------------------------------------------------------------------------
Coveo.PS.CustomNoResults = (function(_super) {

    __extends(CustomNoResults, _super);

    function CustomNoResults(element, options, bindings) {
        _super.call(this, element, CustomNoResults.ID, bindings);
        var _this = this;
        this.element = element;
        this.options = options;
        this.bindings = bindings;
        this.options = Coveo.ComponentOptions.initComponentOptions(element, CustomNoResults, options);
        if (this.options.noResultsTemplate == null) {
            this.options.noResultsTemplate = new Coveo.Template(Coveo._.template('<div>Your No Result Custom Msg</div>'));
        }

        Coveo.$(this.root).on(Coveo.QueryEvents.noResults, Coveo.$.proxy(this.handleNoResults, this));
        Coveo.$(this.root).on(Coveo.QueryEvents.querySuccess, Coveo.$.proxy(this.handleQuerySuccess, this));
        Coveo.$(this.root).on(Coveo.QueryEvents.deferredQuerySuccess, Coveo.$.proxy(this.handleDeferredQuerySuccess, this));
        
    }



    CustomNoResults.prototype.handleDeferredQuerySuccess = function (e, data) {
        console.log("CustomNoResults.prototype.handleDeferredQuerySuccess");
        var _this = this;
        try {
            if (this.bindings.searchInterface.options.endpoint.accessToken.token != this.bindings.usageAnalytics.endpoint.endpointCaller.options.accessToken) {
                this.bindings.usageAnalytics.endpoint.endpointCaller.options.accessToken = document.getElementById($("[id*='hdnInternalSearchToken']")[0].id).value;
            }
        } catch (e) {
            console.log(e);
        }

    };


    CustomNoResults.prototype.handleQuerySuccess = function(e, data) {
        var _this = this;
        if (data.results.totalCount > 0) {
            _this.options.noResultsContainer.innerHTML = '';
            Coveo.$(_this.root).removeClass("showing-custom-no-results");
        }
    };


    var noResultElement = null;
    var localdata = null;
    CustomNoResults.prototype.handleNoResults = function(e, data) {
        var _this = this;
        _this.options.noResultsContainer.innerHTML = '';
        Coveo.$(_this.root).addClass("showing-custom-no-results");
        localdata = data;
        var noResultElementPromise = _this.options.noResultsTemplate.instantiateToElement(data).then(function(result) {
            noResultElement = result;
            _this.renderComponent(localdata);
        });

    };
    CustomNoResults.prototype.renderComponent = function(data) {
        var _this = this;
        var initOptions = _this.searchInterface.options;
        //var noResultElement = _this.options.noResultsTemplate.instantiateToElement(data);

        var initParameters = {
            options: initOptions,
            bindings: _this.getBindings(),
            result: data
        };

        if (noResultElement != null) {
            _this.options.noResultsContainer.appendChild(noResultElement);
            Coveo.CoveoJQuery.automaticallyCreateComponentsInside(noResultElement, initParameters);
        }

    };
    CustomNoResults.ID = 'CustomNoResults';
    CustomNoResults.options = {
        noResultsContainer: Coveo.ComponentOptions.buildChildHtmlElementOption({ defaultFunction: function(element) { return Coveo.$('<div/>').appendTo(element).get(0); } }),
        noResultsTemplate: Coveo.ComponentOptions.buildTemplateOption({
            selectorAttr: 'data-template-selector',
            idAttr: 'data-template-id'
        })
    };
    return CustomNoResults;

})(Coveo.Component);

Coveo.CoveoJQuery.registerAutoCreateComponent(Coveo.PS.CustomNoResults);


////////////////////////////////////////////////////////////////////////////////////////////////////////////

Coveo.AthenaCustom = Coveo.AthenaCustom || (Coveo.AthenaCustom = {});

Coveo.AthenaCustom.previousQuery = '';

Coveo.AthenaCustom.CommonEventBindings = {
    handleBuildingQuery: function(e, data) {
        data.queryBuilder.fieldsToExclude = ['allfieldvalues', 'infainternalnotes'];
    },
    handleQueryError: function(e, data) {
        if (data.error.type == 'InvalidQueryExpressionException') {
            if (Coveo.AthenaCustom.previousQuery != data.query.q) {

                var noQuerySyntaxQuery = '<@- ' + data.queryBuilder.expression.build().replace( /(<@-|-@>)/g , '') + ' -@>';
                Coveo.AthenaCustom.previousQuery = noQuerySyntaxQuery;
                setTimeout(function() {
                    Coveo.$(".CoveoSearchInterface").coveo('state', 'q', noQuerySyntaxQuery);
                    Coveo.$('.CoveoSearchInterface').coveo('executeQuery');
                }, 0);
            }
        } else {
            Coveo.AthenaCustom.previousQuery = '';
        }
    },
    handlePreprocessResults: function(e, data) {
        Coveo._.each(data.results.results, function(r, idx) {
            var infa_docType = r.raw.infadocumenttype ? r.raw.infadocumenttype : '';
            var infa_permissionType = r.raw.infapermissiontype ? r.raw.infapermissiontype.toLowerCase() : '';
            var infa_moderationStatus = r.raw.infamoderationstatus ? r.raw.infamoderationstatus : '';
            if (r.raw.connectortype == 'SharePoint') {
                //IsUserAuthenticated == true means the logged user is not a guest user thus we are on Internal KB page
                var re = /(kb(?:-?test)?(?:crawl)?.informatica.com)/gi
                r.clickUri = Coveo.SharePointContext.IsUserAuthenticated == 'true' && Coveo.SharePointContext.UserType == 'Standard' && Coveo.SharePointContext.Current_Page != 'AthenaPanelForCases' ?
                    r.clickUri.replace(re, Coveo.SharePointContext.KBInternalHost).replace('https', 'http') :
                    ((infa_permissionType == 'internal' || (infa_permissionType == 'public' && infa_moderationStatus != 0)) ?
                        r.clickUri.replace(re, Coveo.SharePointContext.KBInternalHost).replace('https', 'http') :
                        r.clickUri.replace(re, Coveo.SharePointContext.KBExternalHost));
                r.ClickUri = r.clickUri;
                r.PrintableUri = r.printableUri = r.clickUri;

            }
            if ( /(\bKB\b|\bIPSKB\b|\bPAMEOL\b|\bSupportTV\b|\bExpertAssistant\b)/i .test(infa_docType)) {
                //r.hasHtmlVersion = true;
                r.clickUri = (data.query.q ? (r.clickUri + '?myk=' + data.query.q) : r.clickUri);
                // temporary hack to fix KB Title ...
                r.title = (r.title == 'Login' ? (r.raw.infakbtitle ? r.raw.infakbtitle : r.title) : r.title);
            }
            r.raw.infarating = (r.raw.infakbrating ? r.raw.infakbrating : r.raw.infarating);
            r.raw.athenaauthor = (r.raw.athenaauthor ? r.raw.athenaauthor : r.raw.sysauthor);
        });
    }
};
    


Coveo.$(function() {

    var searchInterface = Coveo.$('.CoveoSearchInterface');

    //Common Event bindings


    searchInterface.on(Coveo.QueryEvents.buildingQuery, Coveo.$.proxy(Coveo.AthenaCustom.CommonEventBindings.handleBuildingQuery, this));
    searchInterface.on(Coveo.QueryEvents.queryError, Coveo.$.proxy(Coveo.AthenaCustom.CommonEventBindings.handleQueryError, this));
    searchInterface.on(Coveo.QueryEvents.preprocessResults, Coveo.$.proxy(Coveo.AthenaCustom.CommonEventBindings.handlePreprocessResults, this));

});