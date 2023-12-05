({
    doInit: function (component, event, helper) { },

    publishAllApprovedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.publishAllApprovedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.message",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countno",
                    "WorkInProgress on publishing all draft KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    archiveAllPublishedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.archiveAllPublishedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.message",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countno",
                    "WorkInProgress on archiving all published KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    deleteAllArchivedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.deleteAllArchivedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.message",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countno",
                    "WorkInProgress on deleting all archived KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    publishAllDraftArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.publishAllDraftArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.message",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countno",
                    "WorkInProgress on publishing all draft KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },


    publishSelectiveApprovedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.publishSelectiveApprovedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on publishing selective draft KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    archiveSelectivePublishedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.archiveSelectivePublishedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on archiving selective published KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    deleteSelectiveArchivedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.deleteSelectiveArchivedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on deleting selective archived KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    publishSelectiveDraftArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.publishSelectiveDraftArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on publishing selective draft KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    editSelectivePublishedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.editSelectivePublishedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on editing selective draft KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    editSelectiveArchivedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.editSelectiveArchivedArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on editing selective archived KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    createNewKnowledgeBaseArticleFromCaseByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        
        console.log('Method : createNewKnowledgeBaseArticleFromCaseByDMLClient :' + vararticlID);

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.createNewKnowledgeBaseArticleFromCaseByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parCaseID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else {                    
                }
                console.log('Method : createNewKnowledgeBaseArticleFromCaseByDMLClient :' + JSON.stringify(response));
                console.log('Method : createNewKnowledgeBaseArticleFromCaseByDMLClient :' + JSON.stringify(response.getReturnValue()));
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on creating KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    reassignKnowledgeBaseArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        
        console.log('Method : reassignKnowledgeBaseArticleByDMLClient :' + vararticlID);

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.reassignKnowledgeBaseArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleIDAssignID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else {                    
                }
                console.log('Method : reassignKnowledgeBaseArticleByDMLClient :' + JSON.stringify(response));
                console.log('Method : reassignKnowledgeBaseArticleByDMLClient :' + JSON.stringify(response.getReturnValue()));
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on creating KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    rejectKnowledgeBaseArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        
        console.log('Method : rejectKnowledgeBaseArticleByDMLClient :' + vararticlID);

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.rejectKnowledgeBaseArticleByDML");

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleIDAssignID: vararticlID });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else {                    
                }
                console.log('Method : rejectKnowledgeBaseArticleByDMLClient :' + JSON.stringify(response));
                console.log('Method : rejectKnowledgeBaseArticleByDMLClient :' + JSON.stringify(response.getReturnValue()));
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on creating KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    submitTranslationSelectivePublishedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;
        var varSelectedLang = component.find("selectLanguage").get("v.value");

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.submitTranslationSelectivePublishedArticleByDML");
          

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID, parToLanguage: varSelectedLang });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on submitTranslation selective Published KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    editTranslationSelectivePublishedArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;
        var varSelectedLang = component.find("selectLanguage").get("v.value");

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.editTranslationSelectivePublishedArticleByDML");
          

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID, parToLanguage: varSelectedLang });

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on editTranslation selective Published KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    completeTranslationSelectiveDraftArticleByDMLClient: function (component, event, helper) {
        //var changeType = event.getParams().changeType;

        //if (changeType === "ERROR") { /* handle error; do this first! */ } else if (changeType === "LOADED") { /* handle record load */ } else if (changeType === "REMOVED") { /* handle record removal */ } else if (changeType === "CHANGED") { /* handle record change */ }

        var varCanExecute = false;
        var varFinalStop = false;
        var varTotalRecordProcessedCount = "0";

        var vararticlID = component.find("selectiveArticleId").get("v.value");
        

        var varDMLCallCount = 0;
        var varDMLCallLength = 1000;
       

        function fnTriggerClientCall(component, event, helper, execCount) {
            varCanExecute = false;
            var action = component.get("c.completeTranslationSelectiveDraftArticleByDML");
          

            action.setParams({ parCount: varTotalRecordProcessedCount, parArticleID: vararticlID});

            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && component.isValid()) {
                    component.set(
                        "v.messageselective ",
                        response.getReturnValue()
                    );
                    varTotalRecordProcessedCount = (response.getReturnValue()).split('|')[1];
                    varTotalRecordProcessedCount = varTotalRecordProcessedCount.trim();
                    varCanExecute = true;
                    if ((response.getReturnValue()).indexOf('$Completed') > -1) {
                        varFinalStop = true;
                    } else {

                    }
                } else { }
            });

            fnCustomPooling(component, event, helper, execCount);

            $A.enqueueAction(action);

        }

        function fnCustomPooling(component, event, helper, execCount) {
            try {
                component.set(
                    "v.countnoselective ",
                    "WorkInProgress on completeTranslation selective Published KB articles : " + (execCount).toString()
                );
                if (varCanExecute) {
                    varDMLCallCount++;
                    if ((varDMLCallCount < varDMLCallLength) && varFinalStop == false) {
                        fnTriggerClientCall(component, event, helper, 0);
                    }

                } else if ((execCount < 120) && (varCanExecute == false)) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCustomPooling(component, event, helper, execCount); }, 1000);
                }
            } catch (exThree) { }
        }

        fnTriggerClientCall(component, event, helper, 0);

    },
    openModel: function (component, event, helper) {      
        var varhdnKBLanguage = component.get('v.hdnKBLanguage');
        var varLanguageArray = varhdnKBLanguage.split(';');
        var options = [
            { value: 'none', label: 'None', description: 'No language' }           
        ];
        for (var i = 0; i < varLanguageArray.length; i++) {
            options.push({ value: varLanguageArray[i].split('$$')[1], label: varLanguageArray[i].split('$$')[0], description: varLanguageArray[i].split('$$')[0] });
        }
        
        component.set("v.languageOptions", options);
        component.set("v.isModalOpen", true);
    },    
    closeModel: function (component, event, helper) {       
        component.set("v.isModalOpen", false);
    },    
    submitDetails: function (component, event, helper) {      
        component.set("v.isModalOpen", false);
        var varsubmitTranslationSelectivePublishedArticleByDMLClient = component.get('c.submitTranslationSelectivePublishedArticleByDMLClient');
        $A.enqueueAction(varsubmitTranslationSelectivePublishedArticleByDMLClient);
    }
});