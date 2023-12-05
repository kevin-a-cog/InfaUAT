import { LightningElement } from 'lwc';
import loginURL from '@salesforce/label/c.CustomerSupportLoginURL'





//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
    try {
        if (ISDEBUGENABLED == true || parType == 'error') {
            if (parType == 'log') {
                console.log(parMessage);
            }
            else if (parType == 'error') {
                console.error(parMessage);
            }
            else if (parType == 'warn') {
                console.warn(parMessage);
            }
        }
    } catch (err) {
        console.log('Utility Log : ' + err.message);
    } finally {

    }
}
//For Loggging in Console

const ERRORMESSAGE = "Invalid Page";

function fnPgaeLoad() {
    try {
      
        Log('log', 'Method : kbRedirects connectedCallback');
        Log('log', 'Method : Community Login Redirect');

        function fnQuerystring(qs) {
            // optionally pass a querystring to parse
            var varQueryString = new Array();

            if (qs == null)
                qs = location.search.substring(1, location.search.length);

            if (qs.length == 0)
                return;

            // Turn <plus> back to <space>
            qs = qs.replace(/\+/g, ' ');

            var args = qs.split('&'); // parse out name/value pairs separated via &

            // split out each name=value pair
            for (var i = 0; i < args.length; i++) {
                var pair = args[i].split('=');
                var name = decodeURIComponent(pair[0]);

                var value = (pair.length == 2)
                    ? decodeURIComponent(escape(pair[1]))
                    : name;

                varQueryString[name] = value;
            }

            return varQueryString;
        }

        var varCurrentURL = window.top.location.href;
        var varCurrentOrRefererURL = '';
        var varIsCurrentPageLoginPage = true;

        if ((varCurrentURL.indexOf('/login') > -1)) {
            varIsCurrentPageLoginPage = true;
            console.log('varCurrentOrRefererURL ' + varCurrentOrRefererURL.toString().toLowerCase().trim());
        }
        else {
            varIsCurrentPageLoginPage = false;
            varCurrentOrRefererURL = varCurrentURL;
            console.log(varCurrentOrRefererURL.toString().toLowerCase().trim());
        }
      
        try {
            varCurrentOrRefererURL = decodeURIComponent(varCurrentURL.substring(varCurrentURL.indexOf("startURL=") + 9));
        }
        catch (error1) {
            Log('error', 'Method : connectedCallback1; Catch Error :' + error1.message + " : " + error1.stack);
        }
        if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/s/') > -1)) {
            console.log('varCurrentOrRefererURL ' + varCurrentOrRefererURL.toString().toLowerCase().trim());
            var loginLink = loginURL;
            loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentOrRefererURL));
            console.log('KB Login page : redirectURI is : ' + loginLink); 
			window.location.assign(loginLink);                                   
        }
       
    }
    catch (error) {
        Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
        try {            
        } catch (error) {
            
        }
    }
}

fnPgaeLoad();

export default class KbLogkbRedirects extends LightningElement {


    
}