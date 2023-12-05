webpackJsonpCoveo__temporary([42],{473:function(t,e,i){"use strict";function n(t,e){var i=o.once(function(){return e()});s.$$(t).on(["contextmenu","click","mousedown","mouseup"],i);var n;s.$$(t).on("touchstart",function(){n=window.setTimeout(i,1e3)}),s.$$(t).on("touchend",function(){n&&clearTimeout(n)})}Object.defineProperty(e,"__esModule",{value:!0});var o=i(0),s=i(1);e.bindAnalyticsToLink=n},534:function(t,e){},70:function(t,e,i){"use strict";var n=this&&this.__extends||function(){var t=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(t,e){t.__proto__=e}||function(t,e){for(var i in e)e.hasOwnProperty(i)&&(t[i]=e[i])};return function(e,i){function n(){this.constructor=e}t(e,i),e.prototype=null===i?Object.create(i):(n.prototype=i.prototype,new n)}}(),o=this&&this.__assign||Object.assign||function(t){for(var e,i=1,n=arguments.length;i<n;i++){e=arguments[i];for(var o in e)Object.prototype.hasOwnProperty.call(e,o)&&(t[o]=e[o])}return t};Object.defineProperty(e,"__esModule",{value:!0});var s=i(7),l=i(8),r=i(28),u=i(10),p=i(29),c=i(68),h=i(24),a=i(180),d=i(2),f=i(21),O=i(5),m=i(4),g=i(31),k=i(1),y=i(119),v=i(22),b=i(0),A=i(3);i(534);var w=i(15),C=i(473),U=function(t){function e(i,n,s,u,p){var c=t.call(this,i,e.ID,s)||this;c.element=i,c.options=n,c.bindings=s,c.result=u,c.os=p,c.logAnalytics=b.debounce(function(){c.queryController.saveLastQuery();var t=k.$$(c.element).getAttribute("href");void 0!=t&&""!=t||(t=c.escapedClickUri),c.options.logAnalytics?c.options.logAnalytics(t):c.logDocumentOpen(t),g.Defer.flush()},1500,!0);var a=c.searchInterface.options.originalOptionsObject[e.ID]||{},d=l.ComponentOptions.initComponentOptions(i,e,o({},a,n)),f=c.componentOptionsModel.get(r.ComponentOptionsModel.attributesEnum.resultLink);return c.options=b.extend({},d,f),c.result=u||c.resolveResult(),null==c.options.openQuickview&&(c.options.openQuickview="ExchangeCrawler"==u.raw.connectortype&&h.DeviceUtils.isMobileDevice()),c.element.hasAttribute("tabindex")||c.element.setAttribute("tabindex","0"),O.Assert.exists(c.componentOptionsModel),O.Assert.exists(c.result),c.quickviewShouldBeOpened()||C.bindAnalyticsToLink(i,function(){return c.logAnalytics()}),c.renderUri(i,u),c.bindEventToOpen(),c}return n(e,t),e.prototype.renderUri=function(t,e){if(/^\s*$/.test(this.element.innerHTML)){var i=this.getDisplayedTitle();this.element.innerHTML=i;var n=this.getDisplayedTitleAsText();this.element.hasAttribute("aria-label")||this.element.setAttribute("aria-label",n),this.element.title||(this.element.title=n)}},e.prototype.openLink=function(t){void 0===t&&(t=!0),t&&this.logAnalytics(),window.location.href=this.getResultUri()},e.prototype.openLinkInNewWindow=function(t){void 0===t&&(t=!0),t&&this.logAnalytics(),window.open(this.getResultUri(),"_blank")},e.prototype.openLinkInOutlook=function(t){void 0===t&&(t=!0),this.hasOutlookField()&&(t&&this.logAnalytics(),this.openLink())},e.prototype.openLinkAsConfigured=function(t){void 0===t&&(t=!0),this.toExecuteOnOpen&&(t&&this.logAnalytics(),this.toExecuteOnOpen())},e.prototype.bindEventToOpen=function(){return this.bindOnClickIfNotUndefined()||this.bindOpenQuickviewIfNotUndefined()||this.setHrefIfNotAlready()||this.openLinkThatIsNotAnAnchor()},e.prototype.getDisplayedTitle=function(){if(this.options.titleTemplate){var t=v.StringUtils.buildStringTemplateFromResult(this.options.titleTemplate,this.result);return t?y.StreamHighlightUtils.highlightStreamText(t,this.result.termsToHighlight,this.result.phrasesToHighlight):this.escapedClickUri}return this.result.title?c.HighlightUtils.highlightString(this.result.title,this.result.titleHighlights,null,"coveo-highlight"):this.escapedClickUri},e.prototype.getDisplayedTitleAsText=function(){var t=k.$$("div");return t.setHtml(this.getDisplayedTitle()),t.text()},Object.defineProperty(e.prototype,"escapedClickUri",{get:function(){return b.escape(this.result.clickUri)},enumerable:!0,configurable:!0}),e.prototype.bindOnClickIfNotUndefined=function(){var t=this;return void 0!=this.options.onClick&&(this.toExecuteOnOpen=function(e){t.options.onClick.call(t,e,t.result)},(new w.AccessibleButton).withElement(this.element).withLabel(this.result.title).withSelectAction(function(e){return t.toExecuteOnOpen(e)}).build(),!0)},e.prototype.bindOpenQuickviewIfNotUndefined=function(){var t=this;return!!this.quickviewShouldBeOpened()&&(this.toExecuteOnOpen=function(){k.$$(t.bindings.resultElement).trigger(p.ResultListEvents.openQuickview)},k.$$(this.element).on("click",function(e){e.preventDefault(),t.toExecuteOnOpen()}),!0)},e.prototype.openLinkThatIsNotAnAnchor=function(){var t=this;return!this.elementIsAnAnchor()&&(this.toExecuteOnOpen=function(){t.options.alwaysOpenInNewWindow?t.options.openInOutlook?t.openLinkInOutlook():t.openLinkInNewWindow():t.openLink()},k.$$(this.element).on("click",function(){t.toExecuteOnOpen()}),!0)},e.prototype.setHrefIfNotAlready=function(){return!(!this.elementIsAnAnchor()||m.Utils.isNonEmptyString(k.$$(this.element).getAttribute("href")))&&(k.$$(this.element).setAttribute("href",this.getResultUri()),!this.options.alwaysOpenInNewWindow||this.options.openInOutlook&&this.hasOutlookField()||k.$$(this.element).setAttribute("target","_blank"),!0)},e.prototype.logDocumentOpen=function(t){this.usageAnalytics.logClickEvent(u.analyticsActionCauseList.documentOpen,{documentURL:t,documentTitle:this.result.title,author:m.Utils.getFieldValue(this.result,"author")},this.result,this.root)},e.prototype.filterProtocol=function(t){var e=/^(https?|ftp|file|mailto|tel):/i.test(t),i=/^(\/|\.\/|\.\.\/)/.test(t);return e||i?t:""},e.prototype.getResultUri=function(){if(this.options.hrefTemplate){var t=v.StringUtils.buildStringTemplateFromResult(this.options.hrefTemplate,this.result);return this.filterProtocol(t)}return void 0==this.options.field&&this.options.openInOutlook&&this.setField(),void 0!=this.options.field?this.filterProtocol(m.Utils.getFieldValue(this.result,this.options.field)):this.filterProtocol(this.result.clickUri)},e.prototype.elementIsAnAnchor=function(){return"A"==this.element.tagName},e.prototype.setField=function(){var t=m.Utils.exists(this.os)?this.os:a.OSUtils.get();t==a.OS_NAME.MACOSX&&this.hasOutlookField()?this.options.field="@outlookformacuri":t==a.OS_NAME.WINDOWS&&this.hasOutlookField()&&(this.options.field="@outlookuri")},e.prototype.hasOutlookField=function(){var t=m.Utils.exists(this.os)?this.os:a.OSUtils.get();return t==a.OS_NAME.MACOSX&&void 0!=this.result.raw.outlookformacuri||t==a.OS_NAME.WINDOWS&&void 0!=this.result.raw.outlookuri},e.prototype.isUriThatMustBeOpenedInQuickview=function(){return 0==this.escapedClickUri.toLowerCase().indexOf("ldap://")},e.prototype.quickviewShouldBeOpened=function(){return(this.options.openQuickview||this.isUriThatMustBeOpenedInQuickview())&&f.QueryUtils.hasHTMLVersion(this.result)},e.ID="ResultLink",e.doExport=function(){A.exportGlobally({ResultLink:e})},e.options={field:l.ComponentOptions.buildFieldOption(),openInOutlook:l.ComponentOptions.buildBooleanOption({defaultValue:!1}),openQuickview:l.ComponentOptions.buildBooleanOption({defaultValue:!1}),alwaysOpenInNewWindow:l.ComponentOptions.buildBooleanOption({defaultValue:!1}),hrefTemplate:l.ComponentOptions.buildStringOption(),titleTemplate:l.ComponentOptions.buildStringOption(),onClick:l.ComponentOptions.buildCustomOption(function(){return null}),logAnalytics:l.ComponentOptions.buildCustomOption(function(){return null})},e}(s.Component);e.ResultLink=U,d.Initialization.registerAutoCreateComponent(U)}});
//# sourceMappingURL=ResultLink.min__53bc4b917e6dc10866de.js.map