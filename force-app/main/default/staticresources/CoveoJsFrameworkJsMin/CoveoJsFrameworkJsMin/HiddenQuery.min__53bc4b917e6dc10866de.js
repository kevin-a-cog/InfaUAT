webpackJsonpCoveo__temporary([70],{258:function(t,e,n){"use strict";var o=this&&this.__extends||function(){var t=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(t,e){t.__proto__=e}||function(t,e){for(var n in e)e.hasOwnProperty(n)&&(t[n]=e[n])};return function(e,n){function o(){this.constructor=e}t(e,n),e.prototype=null===n?Object.create(n):(o.prototype=n.prototype,new o)}}();Object.defineProperty(e,"__esModule",{value:!0});var i=n(7),r=n(8),a=n(6),u=n(11),s=n(35),c=n(10),p=n(13),d=n(1),l=n(4),m=n(2),y=n(5),h=n(0),E=n(3);n(621);var b=n(12),v=function(t){function e(n,o,i){var a=t.call(this,n,e.ID,i)||this;return a.element=n,a.options=o,a.options=r.ComponentOptions.initComponentOptions(n,e,o),a.bind.onRootElement(u.QueryEvents.buildingQuery,function(t){return a.handleBuildingQuery(t)}),a.bind.onRootElement(s.BreadcrumbEvents.populateBreadcrumb,function(t){return a.handlePopulateBreadcrumb(t)}),a.bind.onRootElement(s.BreadcrumbEvents.clearBreadcrumb,function(){return a.setStateEmpty()}),a}return o(e,t),e.prototype.clear=function(){this.setStateEmpty();var t=this.getDescription();this.usageAnalytics.logSearchEvent(c.analyticsActionCauseList.contextRemove,{contextName:t}),this.queryController.executeQuery()},e.prototype.setStateEmpty=function(){this.queryStateModel.set(p.QUERY_STATE_ATTRIBUTES.HD,""),this.queryStateModel.set(p.QUERY_STATE_ATTRIBUTES.HQ,"")},e.prototype.handleBuildingQuery=function(t){y.Assert.exists(t);var e=this.queryStateModel.get(p.QUERY_STATE_ATTRIBUTES.HQ);l.Utils.isNonEmptyString(e)&&t.queryBuilder.advancedExpression.add(e)},e.prototype.handlePopulateBreadcrumb=function(t){var e=this,n=this.getDescription();if(!h.isEmpty(n)&&!h.isEmpty(this.queryStateModel.get(p.QUERY_STATE_ATTRIBUTES.HQ))){var o=document.createElement("div");d.$$(o).addClass("coveo-hidden-query-breadcrumb");var i=document.createElement("span");d.$$(i).addClass("coveo-hidden-query-breadcrumb-title"),d.$$(i).text(this.options.title),o.appendChild(i);var r=d.$$("span",{className:"coveo-hidden-query-breadcrumb-value"},h.escape(n)).el;o.appendChild(r);var a=d.$$("span",{className:"coveo-hidden-query-breadcrumb-clear"},b.SVGIcons.icons.mainClear);r.appendChild(a.el),d.$$(r).on("click",function(){return e.clear()}),t.breadcrumbs.push({element:o})}},e.prototype.getDescription=function(){var t=this.queryStateModel.get(p.QueryStateModel.attributesEnum.hd);return h.isEmpty(t)&&(t=this.queryStateModel.get(p.QueryStateModel.attributesEnum.hq)),h.isEmpty(t)||t.length>this.options.maximumDescriptionLength&&(t=t.slice(0,this.options.maximumDescriptionLength)+" ..."),t},e.ID="HiddenQuery",e.doExport=function(){E.exportGlobally({HiddenQuery:e})},e.options={maximumDescriptionLength:r.ComponentOptions.buildNumberOption({min:0,defaultValue:100}),title:r.ComponentOptions.buildLocalizedStringOption({localizedString:function(){return a.l("AdditionalFilters")+":"}})},e}(i.Component);e.HiddenQuery=v,m.Initialization.registerAutoCreateComponent(v)},621:function(t,e){}});
//# sourceMappingURL=HiddenQuery.min__53bc4b917e6dc10866de.js.map