webpackJsonpCoveo__temporary([63],{282:function(t,e,n){"use strict";var o=this&&this.__extends||function(){var t=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(t,e){t.__proto__=e}||function(t,e){for(var n in e)e.hasOwnProperty(n)&&(t[n]=e[n])};return function(e,n){function o(){this.constructor=e}t(e,n),e.prototype=null===n?Object.create(n):(o.prototype=n.prototype,new o)}}();Object.defineProperty(e,"__esModule",{value:!0});var i=n(97);n(672);var s=n(0),u=n(17),r=n(56),c=n(3),l=n(6),a=n(15),p=n(1),m=n(16),h=n(7),d=n(8),f=n(2),v=function(t){function e(n,o,i){var s=t.call(this,n,e.ID,i)||this;return s.element=n,s.options=o,s.isOpened=!1,s.options=d.ComponentOptions.initComponentOptions(n,e,o),s.bind.onRootElement(u.InitializationEvents.afterInitialization,function(){return s.init()}),s}return o(e,t),e.prototype.open=function(){this.isOpened=!0,null!=this.menu&&p.$$(this.menu).detach(),this.menu=this.buildMenu(),p.$$(this.menu).insertAfter(this.element),new i.default(this.element,this.menu,{placement:"bottom-end",modifiers:{offset:{offset:"0, 5"},preventOverflow:{boundariesElement:this.root}}})},e.prototype.close=function(){this.isOpened=!1,null!=this.menu&&(p.$$(this.menu).detach(),this.menu=null)},e.prototype.toggle=function(){this.isOpened?this.close():this.open()},e.prototype.init=function(){var t=this,e=p.$$("span",{className:"coveo-settings-square"}).el,n=p.$$("span",{className:"coveo-settings-squares"}).el;s.times(3,function(){return n.appendChild(e.cloneNode())}),this.element.appendChild(n),(new a.AccessibleButton).withElement(this.element).withOwner(this.bind).withSelectAction(function(){return t.toggle()}).withFocusAndMouseEnterAction(function(){return t.onfocus()}).withBlurAndMouseLeaveAction(function(){return t.onblur()}).withLabel(l.l("Settings")).build()},e.prototype.buildMenu=function(){var t=this,e=p.$$("div",{className:"coveo-settings-advanced-menu"}).el,n={settings:this,menuData:[]};return p.$$(this.root).trigger(r.SettingsEvents.settingsPopulateMenu,n),s.each(n.menuData,function(o){var i=t.buildMenuItem(o,n),s=i.menuItemElement,u=i.menuItemIcon,r=i.menuItemText;s.appendChild(u),s.appendChild(r),e.appendChild(s)}),e},e.prototype.buildMenuItem=function(t,e){var n=this,o=p.$$("div",{className:"coveo-settings-item "+t.className}).el,i=function(){s.each(e.menuData,function(t){t.onClose&&t.onClose()}),n.close(),t.onOpen()};return(new a.AccessibleButton).withElement(o).withSelectAction(i).withFocusAndMouseEnterAction(function(){return n.onfocus()}).withBlurAndMouseLeaveAction(function(){return n.onblur()}).withLabel(t.tooltip||t.text).build(),{menuItemElement:o,menuItemIcon:this.buildMenuItemIcon(t),menuItemText:this.buildMenuItemText(t)}},e.prototype.buildMenuItemIcon=function(t){var e=p.$$("div",{className:"coveo-icon"}).el;return t.svgIcon&&(e.innerHTML=t.svgIcon),t.svgIconClassName&&m.SVGDom.addClassToSVGInContainer(e,t.svgIconClassName),e},e.prototype.buildMenuItemText=function(t){return p.$$("div",{className:"coveo-settings-text"},s.escape(t.text)).el},e.prototype.onblur=function(){var t=this;clearTimeout(this.closeTimeout),this.closeTimeout=window.setTimeout(function(){t.close()},this.options.menuDelay)},e.prototype.onfocus=function(){clearTimeout(this.closeTimeout)},e.ID="Settings",e.doExport=function(){c.exportGlobally({Settings:e})},e.options={menuDelay:d.ComponentOptions.buildNumberOption({defaultValue:300,min:0})},e}(h.Component);e.Settings=v,f.Initialization.registerAutoCreateComponent(v)},672:function(t,e){}});
//# sourceMappingURL=Settings.min__53bc4b917e6dc10866de.js.map