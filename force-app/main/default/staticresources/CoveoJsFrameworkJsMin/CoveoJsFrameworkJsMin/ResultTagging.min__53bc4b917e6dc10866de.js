webpackJsonpCoveo__temporary([64],{278:function(e,t,o){"use strict";var n=this&&this.__extends||function(){var e=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(e,t){e.__proto__=t}||function(e,t){for(var o in t)t.hasOwnProperty(o)&&(e[o]=t[o])};return function(t,o){function n(){this.constructor=t}e(t,o),t.prototype=null===o?Object.create(o):(n.prototype=o.prototype,new n)}}();Object.defineProperty(t,"__esModule",{value:!0}),o(668);var i=o(0),a=o(3),l=o(5),s=o(13),u=o(6),r=o(1),p=o(25),c=o(22),d=o(16),g=o(12),h=o(4),m=o(10),f=o(7),v=o(8),$=o(2),C=function(e){function t(o,n,a,s){var u=e.call(this,o,t.ID,a)||this;if(u.element=o,u.options=n,u.result=s,u.options=v.ComponentOptions.initComponentOptions(o,t,n),u.result=s||u.resolveResult(),l.Assert.exists(u.componentOptionsModel),l.Assert.exists(u.result),!u.options.field)return u.logger.error("You must specify a field to the ResultTagging component"),u;var p=h.Utils.getFieldValue(u.result,u.options.field);return p&&h.Utils.isNonEmptyString(p)?u.tags=p.split(";"):p&&h.Utils.isNonEmptyArray(p)?u.tags=p:u.tags=[],u.tags=i.map(u.tags,function(e){return e.trim()}),u.tagZone=r.$$("div",{className:"coveo-result-tagging-tag-zone"}).el,o.appendChild(u.tagZone),o.appendChild(u.buildTagIcon()),u.autoCompleteZone=r.$$("div",{className:"coveo-result-tagging-auto-complete-zone"}).el,o.appendChild(u.autoCompleteZone),u.autoCompleteZone.appendChild(u.buildTextBox()),u.autoCompleteZone.appendChild(u.buildAddIcon()),u.autoCompleteZone.appendChild(u.buildClearIcon()),u.buildExistingTags(),u}return n(t,e),t.prototype.buildExistingTags=function(){var e=this;this.tags&&i.each(this.tags,function(t){e.tagZone.appendChild(e.buildTagValue(t))})},t.prototype.buildTagIcon=function(){var e=this,t=r.$$("div",{className:"coveo-result-tagging-add-tag"}),o=r.$$("span",{className:"coveo-result-tagging-add-tag-text"});o.text(u.l("EnterTag"));var n=r.$$("span",{className:"coveo-result-tagging-add-tag-icon"});return n.on("click",function(){i.defer(function(){e.focusOnTextBox()},20)}),t.el.appendChild(n.el),t.append(o.el),t.setAttribute("title",u.l("EnterTag")),t.el},t.prototype.focusOnTextBox=function(){this.textBox.focus()},t.prototype.buildTagValue=function(e){var t=this,o=r.$$("div",{className:"coveo-result-tagging-coveo-tag"});o.el.appendChild(this.buildShortenedTagWithTitle(e));var n=r.$$("span",{className:"coveo-result-tagging-delete-icon"},g.SVGIcons.icons.delete);return d.SVGDom.addClassToSVGInContainer(n.el,"coveo-result-tagging-delete-icon-svg"),o.el.appendChild(n.el),n.on("click",function(){t.doRemoveTag(o.el,e.toLowerCase())}),o.el},t.prototype.buildShortenedTagWithTitle=function(e){var t=c.StringUtils.removeMiddle(e,16,"..."),o=r.$$("a",{title:e,href:"javascript:void(0);"});return o.text(t),this.bindFacetEventOnValue(o.el,e),o.el},t.prototype.buildTextBox=function(){var e=this;return this.textBox=r.$$("input",{type:"text",className:"coveo-add-tag-textbox",placeholder:u.l("EnterTag")}).el,this.autoCompletePopup=r.$$("div",{className:t.autoCompleteClass}).el,this.autoCompleteZone.appendChild(this.autoCompletePopup),this.manageAutocompleteAutoHide(),r.$$(this.textBox).on("keyup",function(t){t.keyCode==p.KEYBOARD.UP_ARROW||t.keyCode==p.KEYBOARD.DOWN_ARROW||t.keyCode==p.KEYBOARD.ENTER?e.manageUpDownEnter(t.keyCode):p.KeyboardUtils.isArrowKeyPushed(t.keyCode)||e.populateSuggestions(),r.$$(e.element).removeClass("coveo-error")}),r.$$(this.textBox).on("click",function(){e.populateSuggestions()}),this.textBox},t.prototype.buildAddIcon=function(){var e=this,t=r.$$("div",{className:"coveo-result-tagging-add-tag-tick-icon"},g.SVGIcons.icons.taggingOk);d.SVGDom.addClassToSVGInContainer(t.el,"coveo-result-tagging-add-tag-tick-icon-svg");var o=r.$$("span");return o.on("click",function(){e.doAddTag()}),t.el.appendChild(o.el),t.el},t.prototype.buildClearIcon=function(){var e=this,t=r.$$("div",{className:"coveo-result-tagging-clear-icon"},g.SVGIcons.icons.clear);d.SVGDom.addClassToSVGInContainer(t.el,"coveo-result-tagging-clear-icon-svg");var o=r.$$("span");return o.on("click",function(){e.textBox.value=""}),t.el.appendChild(o.el),t.el},t.prototype.bindFacetEventOnValue=function(e,t){var o=this,n=s.QueryStateModel.getFacetId(this.options.field),a=this.queryStateModel.get(n),l=this.componentStateModel.get(n),u=i.filter(l,function(e){return!e.disabled}).length>0;null!=a&&u&&(r.$$(e).on("click",function(){i.contains(a,t)?o.queryStateModel.set(n,i.without(a,t)):o.queryStateModel.set(n,i.union(a,[t])),o.queryController.deferExecuteQuery({beforeExecuteQuery:function(){return o.usageAnalytics.logSearchEvent(m.analyticsActionCauseList.documentTag,{facetId:o.options.field,facetField:o.options.field,facetValue:t})}})}),i.contains(a,t)&&r.$$(e).addClass("coveo-selected"),r.$$(e).addClass("coveo-clickable"))},t.prototype.clearPopup=function(){r.$$(this.autoCompletePopup).hide(),r.$$(this.autoCompletePopup).empty()},t.prototype.showPopup=function(){r.$$(this.autoCompletePopup).show()},t.prototype.populateSuggestions=function(){var e=this,t=this.queryController.getEndpoint(),o=this.textBox.value,n={field:this.options.field,ignoreAccents:!0,sortCriteria:"occurences",maximumNumberOfValues:this.options.suggestBoxSize,queryOverride:"@uri",pattern:this.buildRegEx(o),patternType:"RegularExpression"};t.listFieldValues(n).then(function(t){e.clearPopup(),i.each(t,function(t){e.autoCompletePopup.appendChild(e.buildSelectableValue(t.lookupValue))}),e.showPopup(),e.autoCompletePopup.style.width=e.textBox.offsetWidth+" px"})},t.prototype.manageAutocompleteAutoHide=function(){var e,o=this;r.$$(this.textBox).on("mouseover",function(){clearTimeout(e)}),r.$$(this.autoCompletePopup).on("mouseout",function(n){r.$$(n.target).hasClass(t.autoCompleteClass)&&(e=setTimeout(function(){o.clearPopup()},o.options.autoCompleteTimer))}),r.$$(this.autoCompletePopup).on("mouseenter",function(){clearTimeout(e)}),r.$$(this.element).on("mouseenter",function(){o.clearPopup(),r.$$(o.element).addClass("coveo-opened")}),r.$$(r.$$(this.element).closest(".CoveoResult")).on("mouseleave",function(){o.clearPopup(),""==o.textBox.value&&r.$$(o.element).removeClass("coveo-opened")}),r.$$(r.$$(this.element).closest(".CoveoResult")).on("focusout",function(e){""!=o.textBox.value&&r.$$(e.target).closest(".CoveoResult")!=r.$$(o.element).closest(".CoveoResult")&&r.$$(o.element).addClass("coveo-error")}),r.$$(r.$$(this.element).closest(".CoveoResult")).on("focusin",function(){r.$$(o.element).removeClass("coveo-error")})},t.prototype.buildRegEx=function(e){var t=this;return"(?=.*"+e+")"+i.map(this.tags,function(e){return t.buildTermToExclude(e)}).join("")+".*"},t.prototype.buildTermToExclude=function(e){return"(?!^"+e+"$)"},t.prototype.manageUpDownEnter=function(e){var t=r.$$(this.element).findAll(".coveo-selectable");if(e==p.KEYBOARD.ENTER)return void this.doAddTag();if(t.length>0){var o=this.computeNextIndex(e,t);o=Math.max(0,o),o=Math.min(t.length-1,o);var n=r.$$(t[o]);n.addClass("coveo-selected"),this.textBox.value=n.text()}},t.prototype.computeNextIndex=function(e,t){var o=0;return i.each(t,function(t,n){r.$$(t).hasClass("coveo-selected")&&(e==p.KEYBOARD.UP_ARROW?o=n-1:e==p.KEYBOARD.DOWN_ARROW&&(o=n+1),r.$$(t).removeClass("coveo-selected"))}),o},t.prototype.buildSelectableValue=function(e){var t=this,o=r.$$("div",{className:"coveo-selectable"});return o.el.appendChild(this.buildShortenedTagWithTitle(e)),o.on("click",function(){t.doAddTagWithValue(e)}),o.el},t.prototype.doRemoveTag=function(e,t){var o=this,n={fieldName:this.options.field,fieldValue:t,doAdd:!1,uniqueId:this.result.uniqueId};this.queryController.getEndpoint().tagDocument(n).then(function(){o.tags.splice(i.indexOf(o.tags,t),1),r.$$(e).detach()})},t.prototype.doAddTagWithValue=function(e){var t=this;i.each(e.split(","),function(e){t.doAddSingleTagValue(e)})},t.prototype.doAddSingleTagValue=function(e){var t=this;if(this.clearPopup(),i.indexOf(this.tags,e)>-1)return void r.$$(this.element).addClass("coveo-error");this.tags.push(e);var o={fieldName:this.options.field,fieldValue:e,doAdd:!0,uniqueId:this.result.uniqueId};this.queryController.getEndpoint().tagDocument(o).then(function(){t.tagZone.appendChild(t.buildTagValue(e)),t.textBox.value="",r.$$(t.element).removeClass("coveo-error")}).catch(function(){t.tags=i.without(t.tags,i.findWhere(t.tags,e))})},t.prototype.doAddTag=function(){var e=h.Utils.trim(this.textBox.value.toLowerCase());this.doAddTagWithValue(e)},t.ID="ResultTagging",t.autoCompleteClass="coveo-result-tagging-auto-complete",t.doExport=function(){a.exportGlobally({ResultTagging:t})},t.options={field:v.ComponentOptions.buildFieldOption({match:function(e){return"Tag"==e.type},required:!0}),suggestBoxSize:v.ComponentOptions.buildNumberOption({defaultValue:5,min:0}),autoCompleteTimer:v.ComponentOptions.buildNumberOption({defaultValue:2e3,min:0})},t.AUTO_COMPLETE_CLASS="coveo-result-tagging-auto-complete",t}(f.Component);t.ResultTagging=C,$.Initialization.registerAutoCreateComponent(C)},668:function(e,t){}});
//# sourceMappingURL=ResultTagging.min__53bc4b917e6dc10866de.js.map