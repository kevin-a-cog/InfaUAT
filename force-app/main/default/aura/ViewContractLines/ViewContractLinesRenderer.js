({
    render : function (component, event, helper) {
        var ret = this.superRender();
        var toggleTable = component.find("originalTable");
        $A.util.addClass(toggleTable, "toggle");
        return ret;
    }
})