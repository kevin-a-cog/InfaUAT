import { LightningElement, track } from 'lwc';

import IN_CommunityName from '@salesforce/label/c.IN_CommunityName';
import KB_Community_External from '@salesforce/label/c.KB_Community_External';
import eSupport_Community_URL from '@salesforce/label/c.eSupport_Community_URL';
import IN_OnlineHelp_Url from '@salesforce/label/c.IN_OnlineHelp_Url';
import AccountURL from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';


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
      
        Log('log', 'Method : inRedirects connectedCallback');
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
      
        try {
            varCurrentOrRefererURL = decodeURIComponent(varCurrentURL.substring(varCurrentURL.indexOf("startURL=") + 9));
        }
        catch (error1) {
            Log('error', 'Method : connectedCallback1; Catch Error :' + error1.message + " : " + error1.stack);
        }
        if ((varCurrentURL.indexOf('/login') > -1)) {
            varIsCurrentPageLoginPage = true;
            console.log('varCurrentOrRefererURL ' + varCurrentOrRefererURL.toString().toLowerCase().trim());
        }
        else {
            varIsCurrentPageLoginPage = false;
            varCurrentOrRefererURL = varCurrentURL;
            console.log(varCurrentOrRefererURL.toString().toLowerCase().trim());
        }
        
        if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/ideas/') != -1) {
            console.log('inside ideas condition in lwc');
            var varNewURL = IN_CommunityName + 'ideas';
            window.location.replace(varNewURL)

        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/thread/') != -1) {
            console.log('inside thread condition in lwc');
            var varNewURL = IN_CommunityName + 'global-search/%20#t=Blog&f:@incontenttype=[Discussion]';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/events/') != -1) {
            console.log('inside events condition in lwc');
            var varNewURL = IN_CommunityName + 'event-landing';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/polls/') != -1) {
            console.log('inside polls condition in lwc');
            var varNewURL = IN_CommunityName + '/global-search/%20#t=Blog&sort=relevancy&f:@incontenttype=[Poll]';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/message/') != -1) {
            console.log('inside message condition in lwc');
            var varNewURL = IN_CommunityName + 'global-search/%20#t=Blog&f:@incontenttype=[Message]';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/blog/') != -1) {
            console.log('inside blog condition in lwc');
            var varCurrentOrRefererURLName = varCurrentOrRefererURL.substring((varCurrentOrRefererURL.lastIndexOf('/') + 1));
            var varNewURL = KB_Community_External + '/' + varCurrentOrRefererURLName;
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/docs/') != -1) {
            console.log('inside docs condition in lwc');
            var varCurrentOrRefererURLName = varCurrentOrRefererURL.substring((varCurrentOrRefererURL.lastIndexOf('/') + 1));
            var varNewURL = KB_Community_External + '/' + varCurrentOrRefererURLName;
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/downloadsview.jspa') != -1) {
            console.log('inside downloadsview condition in lwc');
            var varNewURL = eSupport_Community_URL + 'hotfix-downloads';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/onlinehelp/') != -1) {
            console.log('inside onlinehelp ' + window.top.location.href);
            var urlPart = varCurrentOrRefererURL.split('/onlinehelp/')[1];
            var varNewURL = IN_OnlineHelp_Url + '/' + urlPart;
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/videos/') != -1 || varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/support-tv!input.jspa') != -1) {
            var varNewURL = IN_CommunityName + 'global-search/%20#t=SupportVideo';
            window.location.replace(varNewURL)
        }
        else if (varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/cr/') != -1 || varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/cr') != -1) {
            var varNewURL = IN_CommunityName + 'global-search/%20#t=CR';
            window.location.replace(varNewURL)
        }
        else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/s/') > -1)) {
            console.log('varCurrentOrRefererURL ' + varCurrentOrRefererURL.toString().toLowerCase().trim());
            var varNewURL = AccountURL + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(varCurrentOrRefererURL);
            console.log('Login page : redirectURI is : ' + varNewURL);
            window.location.replace(varNewURL)
        }
        //Add conditions for cmmunities n groups
        else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/wisconsin-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PjSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/washington-dc') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PQSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/uk-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PxSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/twin-cities-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PiSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/toronto-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PhSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/sw-ohio') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PgSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/sweden-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PySAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/st-louis-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PfSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/south-florida-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PaSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/southern-california-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PbSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/snowflake-iics-users') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q7SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/seattle-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PeSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/san-diego-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PdSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/raleigh-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PsSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/pune-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PpSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/portland-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PZSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/pittsburgh-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PYSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/pim-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PFSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/phoenix-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PXSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/philadelphia-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PWSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/pharma-life-sciences-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q9SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/norway-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q3SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/new-york-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PVSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/new-england-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PUSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/nebraska-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q8SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/london-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PlSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/korea-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PrSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/kansas-city-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q4SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/japan-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PqSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/japan-partner') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q6SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/iowa-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PTSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/informatica-user-group-chennai') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PISA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/informatica-university') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PJSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/informatica-procurement') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PGSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/informatica????') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PHSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/houston-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PSSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/germany-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PoSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/germany-data-governance-privacy-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q5SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/france-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PvSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/france-master-data-management') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2QASA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/france-data-warehouse-lake-app-modernization-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2QCSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/france-data-governance-quality-privacy-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2QBSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/finland-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q2SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/detroit-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PtSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/des-moines-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PRSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/denver-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PPSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/denmark-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PzSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/dayton-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q1SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/dallas-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2POSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/customer-on-boarding') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PuSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/columbus-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PNSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/chicago-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PkSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/carolinas-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PMSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/benelux-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PmSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/bay-area-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PcSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/australian-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2Q0SAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/austin-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PKSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/atlanta-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PLSA0';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/groups/arkansas-user-group') > -1)) {
          
            window.top.location.href = '/group/0F96S000000Q2PwSAK';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/ultra-messaging/ultra-messaging-options') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAkWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/ultra-messaging') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAjWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/product-information-management/mdm-product-360') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAiWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/product-information-management/informatica-procurement') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAhWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/product-information-management') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAgWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/process_automation/active_vos') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAfWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/process_automation') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAeWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/master_data_management/multidomain_mdm') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAcWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/master_data_management/mdm-relate-360') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAbWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/master_data_management/mdm_registry_edition') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAdWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/master_data_management/identity-resolution') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAaWAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/master_data_management') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAZWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure-testing/test-data-warehouse') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAYWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure-testing/test-data-management') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAWWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure-testing/test-data-generation') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAXWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure-testing/data_subset') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAVWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure-testing') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAUWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/secure@source') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAATWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/data-centric-security/dynamic_data_masking') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAASWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/data-centric-security') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAARWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)/data-archive') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAQWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-security-group-(formerly-ilm)') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAPWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-engineering/enterprise-data-preparation') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9gWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-engineering/enterprise-data-catalog') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9eWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-engineering/data-engineering-integration') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9cWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data-engineering/big-data-home') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9dWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/data-quality') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAANWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/data-explorer') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAMWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/data-as-a-service/address-doctor-cloud') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAKWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/data-as-a-service/address-doctor') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAALWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/data-as-a-service') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAJWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality/axon_data_governance') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAOWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_quality') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAANWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/powerexchange_adapters') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAHWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/powerexchange') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAGWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/powercenter') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAFWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/metadata-manager/metadata-reporter') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAEWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/metadata-manager') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAADWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/informatica_platform/informatica-9.6.1') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAACWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/informatica_platform/informatica-9') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAAAWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/informatica_platform/informatica_9.5.1') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAABWA4';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/informatica_platform') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA9WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/data-validation-option') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA7WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/data-services') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA6WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/data-integration-hub') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA4WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/b2b_data_transformation') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA3WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration/b2b_data_exchange') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA2WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/data_integration') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA1WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/complex_event_processing/proactive-monitoring/powercenter_operations') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JAA0WAO';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/complex_event_processing/proactive-monitoring') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9zWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/complex_event_processing') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9yWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/informatica-for-microsoft') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9qWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-rca') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9wWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-integration-hub') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9rWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-developers') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9tWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-data-integration-elastic') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9vWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-customer-360') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9nWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-assurance-service') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9xWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud-application-integration') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9iWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud_data_integration/dataloader') > -1)) {
          
            window.top.location.href = '/topic/0TO6S000000JA9mWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud_data_integration/cloud-support') > -1)) {
          window.top.location.href = '/topic/0TO6S000000JA9kWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration/cloud_data_integration') > -1)) {
          window.top.location.href = '/topic/0TO6S000000JA9jWAG';
        } else if ((varCurrentOrRefererURL.toString().toLowerCase().trim().indexOf('/community/informatica-network/products/cloud-integration') > -1)) {
            window.top.location.href = '/topic/0TO6S000000JA9hWAG';
        }
        else {
            var varNewURL = IN_CommunityName + 'global-search/%20#t=All';
            window.location.replace(varNewURL)
        }
       
    }
    catch (error) {
        Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
        try {
            document.getElementById('inLoginRedirectLWCinLoginRedirectLWC').style.display = 'none';
        } catch (error) {
            
        }
    }
}

fnPgaeLoad();

export default class InLoginRedirects extends LightningElement {

    @track errorMessage = "";
    @track isPageLoading = false;

    connectedCallback() {
        this.isPageLoading = true;
    }
}