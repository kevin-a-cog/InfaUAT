webpackJsonpCoveo__temporary([54],{190:function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),i=n(0),r=n(6);n(574);var l=n(4),u=n(3),a=function(){function t(t,e,n){void 0===t&&(t=function(t){}),this.onChange=t,this.options=e,this.label=n,this.buildContent()}return t.doExport=function(){u.exportGlobally({MultiSelect:t})},t.prototype.build=function(){return this.element},t.prototype.getElement=function(){return this.element},t.prototype.getValue=function(){return i.chain(this.element.options).toArray().filter(function(t){return t.selected}).map(function(t){return t.value}).value()},t.prototype.getUnselectedValues=function(){return i.chain(this.element.options).toArray().filter(function(t){return!t.selected}).map(function(t){return t.value}).value()},t.prototype.setValue=function(t){var e=this.getValue(),n=i.partition(i.toArray(this.element.options),function(t){return i.contains(e,t.value)}),r=i.partition(i.toArray(this.element.options),function(e){return i.contains(t,e.value)});i.each(r[0],function(t){return t.selected=!0}),i.each(r[1],function(t){return t.selected=!1});var u=!1;l.Utils.arrayEqual(n[0],r[0],!1)||(u=!0),l.Utils.arrayEqual(n[1],r[1],!1)||(u=!0),u&&o.$$(this.element).trigger("change")},t.prototype.reset=function(){var t=this.getValue();this.element.selectedIndex=-1,l.Utils.isEmptyArray(t)||o.$$(this.element).trigger("change")},t.prototype.buildContent=function(){var t=this;this.element=o.$$("select",{className:"coveo-multi-select",multiple:"",size:this.options.length.toString()}).el;var e=o.$$("optgroup",{className:"coveo-list-group",label:this.label}),n=i.map(this.options,function(t){return o.$$("option",{value:t,className:"coveo-list-item"},r.l(t))});i.each(n,function(t){return e.append(t.el)}),this.element.appendChild(e.el),o.$$(this.element).on("change",function(){return t.onChange(t)})},t}();e.MultiSelect=a},574:function(t,e){}});
//# sourceMappingURL=MultiSelect.min__5550c8f4f93c4d333ac5.js.map