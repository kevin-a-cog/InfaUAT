webpackJsonpCoveo__temporary([37],{179:function(e,t,n){"use strict";var o=this&&this.__assign||Object.assign||function(e){for(var t,n=1,o=arguments.length;n<o;n++){t=arguments[n];for(var i in t)Object.prototype.hasOwnProperty.call(t,i)&&(e[i]=t[i])}return e};Object.defineProperty(t,"__esModule",{value:!0});var i=n(26),s=n(469),r=n(6),l=n(1),c=n(25),a=n(20),u=function(){function e(e,t,n,s){void 0===n&&(n=i.ModalBox),void 0===s&&(s={}),this.className=e,this.ownerElement=t,this.modalboxModule=n,this.options=o({sizeMod:"big"},s)}return Object.defineProperty(e.prototype,"isOpen",{get:function(){return!!this.focusTrap},enumerable:!0,configurable:!0}),Object.defineProperty(e.prototype,"element",{get:function(){return this.activeModal&&this.activeModal.modalBox},enumerable:!0,configurable:!0}),Object.defineProperty(e.prototype,"content",{get:function(){return this.activeModal&&this.activeModal.content},enumerable:!0,configurable:!0}),Object.defineProperty(e.prototype,"wrapper",{get:function(){return this.activeModal&&this.activeModal.wrapper},enumerable:!0,configurable:!0}),Object.defineProperty(e.prototype,"headerElement",{get:function(){return this.element&&this.element.querySelector(".coveo-modal-header h1")},enumerable:!0,configurable:!0}),e.prototype.openResult=function(e){this.isOpen||(this.openModalAndTrap({content:e.content,validation:e.validation,origin:e.origin,title:a.DomUtils.getQuickviewHeader(e.result,e.options,e.bindings).el}),this.makeAccessible(e.options.title||e.result.title))},e.prototype.open=function(e){this.isOpen||(this.openModalAndTrap(e),this.makeAccessible())},e.prototype.openModalAndTrap=function(e){var t=this;this.initiallyFocusedElement=e.origin||document.activeElement,this.activeModal=this.modalboxModule.open(e.content,{title:e.title,className:this.className,validation:function(){return t.onModalClose(),e.validation()},body:this.ownerElement,sizeMod:this.options.sizeMod,overlayClose:this.options.overlayClose}),this.focusTrap=new s.FocusTrap(this.element)},e.prototype.close=function(){this.isOpen&&(this.activeModal.close(),this.activeModal=null)},e.prototype.makeAccessible=function(e){this.element.setAttribute("aria-modal","true"),e&&this.headerElement.setAttribute("aria-label",e),this.makeCloseButtonAccessible(),this.updateFocus()},Object.defineProperty(e.prototype,"closeButton",{get:function(){return this.element.querySelector(".coveo-small-close")},enumerable:!0,configurable:!0}),e.prototype.makeCloseButtonAccessible=function(){var e=this.closeButton;e.setAttribute("aria-label",r.l("Close")),e.setAttribute("role","button"),e.tabIndex=0,l.$$(e).on("keyup",c.KeyboardUtils.keypressAction(c.KEYBOARD.ENTER,function(){return e.click()}))},e.prototype.updateFocus=function(){(this.options.focusOnOpen&&this.options.focusOnOpen()||this.closeButton).focus()},e.prototype.onModalClose=function(){this.focusTrap.disable(),this.focusTrap=null,this.initiallyFocusedElement&&document.body.contains(this.initiallyFocusedElement)&&this.initiallyFocusedElement.focus()},e}();t.AccessibleModal=u},265:function(e,t,n){"use strict";var o=this&&this.__extends||function(){var e=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(e,t){e.__proto__=t}||function(e,t){for(var n in t)t.hasOwnProperty(n)&&(e[n]=t[n])};return function(t,n){function o(){this.constructor=t}e(t,n),t.prototype=null===n?Object.create(n):(o.prototype=n.prototype,new o)}}();Object.defineProperty(t,"__esModule",{value:!0});var i=n(7),s=n(8),r=n(56),l=n(100),c=n(2),a=n(6),u=n(1),p=n(3),d=n(26),f=n(0),h=n(179);n(638);var m=n(17),b=n(12),v=function(e){function t(n,o,i,l){void 0===l&&(l=d.ModalBox);var c=e.call(this,n,t.ID,i)||this;return c.element=n,c.options=o,c.ModalBox=l,c.content=[],c.options=s.ComponentOptions.initComponentOptions(n,t,o),c.bind.onRootElement(r.SettingsEvents.settingsPopulateMenu,function(e){e.menuData.push({className:"coveo-preferences-panel",text:a.l("Preferences"),onOpen:function(){return c.open()},onClose:function(){return c.close()},svgIcon:b.SVGIcons.icons.dropdownPreferences,svgIconClassName:"coveo-preferences-panel-svg"})}),c.bind.onRootElement(m.InitializationEvents.afterComponentsInitialization,function(){c.content=u.$$(c.element).children()}),c.modalbox=new h.AccessibleModal("coveo-preferences-panel",c.searchInterface.options.modalContainer,c.ModalBox,{overlayClose:!0}),c}return o(t,e),t.prototype.open=function(){var e=this,t=u.$$("div");f.each(this.content,function(e){t.append(e)}),this.modalbox.open({title:a.l("Preferences"),content:t.el,origin:this.element,validation:function(){return e.cleanupOnExit(),!0}})},t.prototype.close=function(){this.cleanupOnExit(),this.modalbox.close()},t.prototype.save=function(){u.$$(this.element).trigger(l.PreferencesPanelEvents.savePreferences),this.queryController.executeQuery()},t.prototype.cleanupOnExit=function(){u.$$(this.element).trigger(l.PreferencesPanelEvents.exitPreferencesWithoutSave)},t.ID="PreferencesPanel",t.doExport=function(){p.exportGlobally({PreferencesPanel:t})},t.options={},t}(i.Component);t.PreferencesPanel=v,c.Initialization.registerAutoCreateComponent(v)},469:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var o=n(31),i=n(0),s=n(1),r=function(){function e(e,t){void 0===t&&(t={focusableSelector:"[tabindex], button"}),this.container=e,this.options=t,this.hiddenElements=[],this.enable()}return Object.defineProperty(e.prototype,"focusableElements",{get:function(){return i.chain(s.Dom.nodeListToArray(this.container.querySelectorAll(this.options.focusableSelector))).filter(function(e){return s.$$(e).isVisible()}).sortBy(function(e){return e.tabIndex}).value()},enumerable:!0,configurable:!0}),e.prototype.disable=function(){document.removeEventListener("focusin",this.focusInEvent),document.removeEventListener("focusout",this.focusOutEvent),this.showHiddenElements(),this.enabled=!1},e.prototype.enable=function(){var e=this;document.addEventListener("focusin",this.focusInEvent=function(t){return e.onFocusIn(t)}),document.addEventListener("focusout",this.focusOutEvent=function(t){return e.onFocusOut(t)}),this.hideAllExcept(this.container),this.enabled=!0},e.prototype.showHiddenElements=function(){for(;this.hiddenElements.length;)this.hiddenElements.pop().removeAttribute("aria-hidden")},e.prototype.hideElement=function(e){e.getAttribute("aria-hidden")||(this.hiddenElements.push(e),e.setAttribute("aria-hidden",""+!0))},e.prototype.hideSiblings=function(e){var t=this,n=e.parentElement;n&&i.without(s.$$(n).children(),e).forEach(function(e){t.hideElement(e)})},e.prototype.hideAllExcept=function(e){this.hideSiblings(e);var t=e.parentElement;t&&t!==document.body&&this.hideAllExcept(t)},e.prototype.getFocusableSibling=function(e,t){void 0===t&&(t=!1);var n=this.focusableElements,o=n.indexOf(e);return-1===o?null:n[(o+(t?-1:1)+n.length)%n.length]},e.prototype.focusSibling=function(e,t){void 0===t&&(t=!1);var n=this.getFocusableSibling(e,t);n&&n.focus()},e.prototype.focusFirstElement=function(){var e=this.focusableElements;e.length&&e[0].focus()},e.prototype.elementIsBefore=function(e,t){return!!t&&e.compareDocumentPosition(t)===Node.DOCUMENT_POSITION_PRECEDING},e.prototype.onLosingFocus=function(e,t){var n=this;o.Defer.defer(function(){n.enabled&&(n.enabled=!1,e&&n.focusIsAllowed(e)?n.focusSibling(e,n.elementIsBefore(e,t)):n.focusFirstElement(),n.enabled=!0)})},e.prototype.focusIsAllowed=function(e){return this.container.contains(e)},e.prototype.elementIsInPage=function(e){return e&&e!==document.body.parentElement},e.prototype.onFocusIn=function(e){if(this.enabled){var t=e.relatedTarget;if(!this.elementIsInPage(t)){var n=e.target;this.elementIsInPage(n)&&(this.focusIsAllowed(n)||this.onLosingFocus(null,n))}}},e.prototype.onFocusOut=function(e){if(this.enabled){var t=e.relatedTarget;this.elementIsInPage(t)&&(t&&this.focusIsAllowed(t)||this.onLosingFocus(e.target,t))}},e}();t.FocusTrap=r},638:function(e,t){}});
//# sourceMappingURL=PreferencesPanel.min__53bc4b917e6dc10866de.js.map