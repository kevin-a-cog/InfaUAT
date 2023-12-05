Coveo.TemplateCache.registerTemplate("SlackMessageReply", Coveo.HtmlTemplate.fromString("<style>\n  .CoveoResultList .coveo-slack-result-template .coveo-highlight {\n    font-weight: normal;\n    background-color: #FFE300;\n  }\n\n  .CoveoResult .coveo-slack-result-template {\n    margin-right: 16px;\n  }\n\n  .coveo-slack-result-template .CoveoImageFieldValue[data-field=\"@slackmessageauthorprofilepicture\"]>span>img {\n    border-radius: 4px;\n  }\n</style>\n\n<div class=\"coveo-result-frame coveo-slack-result-template\" style=\"margin-bottom: 8px;\">\n  <div class=\"coveo-result-row\" style=\"margin-right: 16px;\">\n    <div style=\"display: flex; margin-bottom: 4px; margin-left: 22px;\">\n      <div\n        style=\"display: flex; background-color: #F6F7F9; border-radius: 8px; flex-grow: 1; padding: 8px; padding-bottom: 16px;\">\n        <span class=\"CoveoImageFieldValue\" data-field=\"@slackmessageauthorprofilepicture\" data-width=\"30\"\n          data-height=\"30\" style=\"margin-right: 16px; border-radius: 4px;\"></span>\n        <div style=\"display: flex; flex-direction: column; margin-top: 5px;\">\n          <div style=\"display: flex; font-size: 12px; align-items: baseline; margin-bottom: 4px;\">\n            <span class=\"CoveoFieldValue\" data-field=\"@slackmessageauthor\"\n              style=\"font-size: 16px; margin-right: 8px; font-weight: bold;\"></span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"time\"\n              style=\"color: #616061; padding-bottom: 2px;\"></span>\n            <span>&nbsp;-&nbsp;</span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"dateTime\"\n              data-helper-options-predefined-format=\"MM/dd/yyyy\" style=\"color: #616061; padding-bottom: 2px;\"></span>\n          </div>\n          <span class=\"CoveoExcerpt\"></span>\n        </div>\n      </div>\n    </div>\n  </div>\n</div>",{"condition":null,"layout":"list","fieldsToMatch":[{"field":"filetype","values":["slackmessage"]},{"field":"slackmessagetype","values":["Reply"]}],"mobile":null,"role":null}),true, true)
Coveo.TemplateCache.registerTemplate("SlackMessageThread", Coveo.HtmlTemplate.fromString("<style>\n  .CoveoResultList .coveo-slack-result-template .coveo-highlight {\n    font-weight: normal;\n    background-color: #FFE300;\n  }\n\n  .CoveoResult .coveo-slack-result-template {\n    margin-right: 16px;\n  }\n\n  .coveo-slack-result-template .CoveoImageFieldValue[data-field=\"@slackmessageauthorprofilepicture\"]>span>img {\n    border-radius: 4px;\n  }\n\n  .coveo-slack-result-template .coveo-folding-footer {\n    order: 1;\n    margin: 0;\n    font-size: 12px;\n  }\n\n  .coveo-slack-result-template .CoveoResultFolding .coveo-folding-results {\n    margin-left: 22px; \n    border-left: thin solid #bcc3ca;\n  }\n\n  .coveo-slack-result-template .coveo-folding-results .coveo-result-folding-child-result, .coveo-slack-result-template .coveo-folding-results .coveo-result-folding-child-result:hover {\n    padding-left: 0;\n    border-left: none;\n    margin-bottom: 8px;\n  }\n\n  .coveo-slack-result-template .coveo-folding-oneresult-caption {\n    display: none;\n  }\n\n  .coveo-slack-result-template .coveo-folding-show-less {\n    margin: 0 0 0 46px;\n  }  \n</style>\n\n<div class=\"coveo-result-frame coveo-slack-result-template\">\n  <div class=\"coveo-result-row\" style=\"margin-right: 16px;\">\n    <div\n      style=\"font-size: 12px; display: flex; align-items: baseline; margin-bottom: 10px; justify-content: space-between;\">\n      <div>\n        <span class=\"CoveoText\" data-value=\"THREAD\" style=\"background-color: #86D8FF; color: #FFFFFF; padding: 3px 10px; border-radius: 32px; margin-right: 8px;\"></span>\n        <span class=\"CoveoText\" data-value=\"in\"></span>\n        <span>:&nbsp;</span>\n        <a class=\"CoveoResultLink\" data-always-open-in-window=\"true\" data-field=\"@clickableuri\">\n          <span class=\"CoveoFieldValue\" data-field=\"@slackchannelname\"></span>\n        </a>\n      </div>\n    </div>\n    <div style=\"display: flex; margin-bottom: 16px;\">\n      <span class=\"CoveoIcon\" data-with-label=\"false\"\n        style=\"height: 32px; width: 32px; background-size: cover; margin-right: 16px; flex-shrink: 0;\"></span>\n      <div\n        style=\"display: flex; background-color: #F6F7F9; border-radius: 8px; flex-grow: 1; padding: 8px; padding-bottom: 16px;\">\n        <span class=\"CoveoImageFieldValue\" data-field=\"@slackmessageauthorprofilepicture\" data-width=\"30\"\n          data-height=\"30\" style=\"margin-right: 16px; border-radius: 4px;\"></span>\n        <div style=\"display: flex; flex-direction: column; margin-top: 5px;\">\n          <div style=\"display: flex; font-size: 12px; align-items: baseline; margin-bottom: 4px;\">\n            <span class=\"CoveoFieldValue\" data-field=\"@slackmessageauthor\"\n              style=\"font-size: 16px; margin-right: 8px; font-weight: bold;\"></span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"time\"\n              style=\"color: #616061; padding-bottom: 2px;\"></span>\n            <span>&nbsp;-&nbsp;</span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"dateTime\"\n              data-helper-options-predefined-format=\"MM/dd/yyyy\" style=\"color: #616061; padding-bottom: 2px;\"></span>              \n          </div>\n          <span class=\"CoveoExcerpt\"></span>\n          <div  style=\"color: #626971; margin-top: 8px; font-weight: 700;\">\n            <span class=\"CoveoFieldValue\" data-field=\"@slackmessagereplycount\"></span>\n            <span class=\"CoveoFieldValue\" data-field=\"@slackmessagereplycount\" data-helper=\"pluralHelper\" \n              data-helper-options=\"{'singular': 'reply', 'plural': 'replies'}\">\n          </div>\n        </div>\n      </div>\n    </div>\n    <div\n      style=\"display: grid; grid-template-columns: 1fr auto; grid-template-rows: 1fr min-content; padding-left: 50px;\">\n      <span class=\"CoveoResultFolding\" style=\"grid-column: 1 / 3; grid-row: 1;\"\n        data-result-template-id=\"SlackMessageReply\" data-more-caption=\"Show thread\"\n        data-less-caption=\"Hide thread\" data-range=\"0\"></span>\n      <a class=\"CoveoResultLink\" style=\"order: 3;\" data-field=\"@clickableuri\" data-always-open-in-new-window=\"true\">\n        <span class=\"CoveoText\" data-value=\"Open in Slack\" style=\"font-size: 12px;\"></span>\n      </a>\n    </div>\n  </div>\n</div>",{"condition":null,"layout":"list","fieldsToMatch":[{"field":"filetype","values":["slackmessage"]},{"field":"slackmessagetype","values":["ThreadStart"]}],"mobile":null,"role":null}),true, true)
Coveo.TemplateCache.registerTemplate("SlackMessage", Coveo.HtmlTemplate.fromString("<style>\n  .CoveoResultList .coveo-slack-result-template .coveo-highlight {\n    font-weight: normal;\n    background-color: #FFE300;\n  }\n\n  .CoveoResult .coveo-slack-result-template {\n    margin-right: 16px;\n  }\n\n  .coveo-slack-result-template .CoveoImageFieldValue[data-field=\"@slackmessageauthorprofilepicture\"]>span>img {\n    border-radius: 4px;\n  }\n</style>\n\n<div class=\"coveo-result-frame coveo-slack-result-template\">\n  <div class=\"coveo-result-row\" style=\"margin-right: 16px;\">\n    <div\n      style=\"font-size: 12px; display: flex; align-items: baseline; margin-bottom: 10px; justify-content: space-between;\">\n      <div>\n        <span class=\"CoveoText\" data-value=\"MESSAGE\"\n          style=\"background-color: #86D8FF; color: #FFFFFF; padding: 3px 10px; border-radius: 32px; margin-right: 8px;\"></span>\n        <span class=\"CoveoText\" data-value=\"in\"></span>\n        <span>:&nbsp;</span>\n        <a class=\"CoveoResultLink\" data-always-open-in-window=\"true\" data-field=\"@clickableuri\">\n          <span class=\"CoveoFieldValue\" data-field=\"@slackchannelname\"></span>\n        </a>\n      </div>\n    </div>\n    <div style=\"display: flex; margin-bottom: 16px;\">\n      <span class=\"CoveoIcon\" data-with-label=\"false\"\n        style=\"height: 32px; width: 32px; background-size: cover; margin-right: 16px; flex-shrink: 0;\"></span>\n      <div\n        style=\"display: flex; background-color: #F6F7F9; border-radius: 8px; flex-grow: 1; padding: 8px; padding-bottom: 16px;\">\n        <span class=\"CoveoImageFieldValue\" data-field=\"@slackmessageauthorprofilepicture\" data-width=\"30\"\n          data-height=\"30\" style=\"margin-right: 16px; border-radius: 4px;\"></span>\n        <div style=\"display: flex; flex-direction: column; margin-top: 5px;\">\n          <div style=\"display: flex; font-size: 12px; align-items: baseline; margin-bottom: 4px;\">\n            <span class=\"CoveoFieldValue\" data-field=\"@slackmessageauthor\"\n              style=\"font-size: 16px; margin-right: 8px; font-weight: bold;\"></span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"time\"\n              style=\"color: #616061; padding-bottom: 2px;\"></span>\n            <span>&nbsp;-&nbsp;</span>\n            <span class=\"CoveoFieldValue\" data-field=\"@date\" data-helper=\"dateTime\"\n              data-helper-options-predefined-format=\"MM/dd/yyyy\" style=\"color: #616061; padding-bottom: 2px;\"></span>              \n          </div>\n          <span class=\"CoveoExcerpt\"></span>\n        </div>\n      </div>\n    </div>\n    <div style=\"display: flex; justify-content: flex-end;\">\n      <a class=\"CoveoResultLink\" data-field=\"@clickableuri\" data-always-open-in-new-window=\"true\">\n        <span class=\"CoveoText\" data-value=\"Open in Slack\" style=\"font-size: 12px;\"></span>\n      </a>\n    </div>\n  </div>\n</div>",{"condition":null,"layout":"list","fieldsToMatch":[{"field":"filetype","values":["slackmessage"]},{"field":"slackmessagetype","values":["Normal"]}],"mobile":null,"role":null}),true, true)