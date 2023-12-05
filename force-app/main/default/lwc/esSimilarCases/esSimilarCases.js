import { LightningElement, track, api, wire } from "lwc";

import INFAKBSearch from "@salesforce/resourceUrl/INFAKBSearch";

import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import getSimilarcases from '@salesforce/apex/KBContentSearch.getSimilarcases'; 

import { loadStyle, loadScript } from "lightning/platformResourceLoader";

export default class EsSimilarCases extends LightningElement {
    @api recordId;
   
    searchtoken;
    searchhubname;
    searchorgname;
    varCoveoSearchInterface;
    varCoveoAnalytics;
    @track caserecords
    showmessage = false;
    error = '';

    vartitle = '';
    varsubject = '';
    varproduct = '';

    varprevtitle = '';
    varprevsubject = '';
    varpreproduct = '';
        
    previoussearchkeywordinchild = { 'title': '', 'subject': '' };

    renderedCallback() {
    }

    connectedCallback() {
        try {
            console.log("Method : esSimilarCases connectedCallback Called");
            this.fnGetSearchToken();
        } catch (ex) {
            console.error("Method : esSimilarCases connectedCallback Method; Error :" + ex.description);
        }
        return "";
    }

    fnGetSearchToken() {
        try {
            console.log("Method : esSimilarCases fnGetSearchToken Called");
            getSearchToken({ strSessionId: '', strUserEmail: '', strUserId: '', strCalledFrom: 'esupportsimilarcases' })
                .then((result) => {
                    console.log("Method : esSimilarCases getSearchToken Returned");                    
                    this.searchtoken = JSON.parse(result).APISearchToken;
                    this.searchhubname = JSON.parse(result).APISearchHub;
                    this.searchorgname = JSON.parse(result).SearchOrgName;
                    console.log("Method : esSimilarCases getSearchToken this.searchtoken : " + this.searchtoken);
                    this.fnGetSimilarCasesAgaintsCaseDetails();                    
                })
                .catch((error) => {
                    console.error("error esSimilarCases getSearchToken");
                });
        } catch (ex) {
            console.error("Method : esSimilarCases fnGetSearchToken Method; Error :" + ex.description);
        }
    }

    fnGetSimilarCasesAgaintsCaseDetails() {
        try {
            console.log("Method : esSimilarCases fnGetSimilarCasesAgaintsCaseDetails Called");
            if (this.searchtoken != null) {
                getSimilarcases({
                    strSearchToken: this.searchtoken
                })
                    .then(result => {                        
                        console.log('"Method : esSimilarCases fnGetSimilarCasesAgaintsCaseDetails getSimilarcases Output Status ' + JSON.parse(result).APIResponseStatus)
                        if(JSON.parse(result).APIResponseStatus==='SUCCESS'){
                            this.caserecords = JSON.parse(result).searchDataList;
                            if(this.caserecords.length == 0){
                                this.showmessage = true;
                                this.error = 'No Similar Cases Found';
                                document.querySelector('c-k-b-similar-articles').style.display='none';

                                console.log('after hiding  similar articles')
                                
                            }
                        }else{
                            this.error = 'An error occured, please try again later';
                            console.log('Similar Cases Error occured: Please check with your system administrator');
                            document.querySelector('c-k-b-similar-articles').style.display='none';

                            console.log('after hiding  similar articles')
                           
                        }
                    
                    
                    })
                    .catch(error => {
                        console.log('error' + JSON.stringify(error));
                        // this.error = 'Error occured: Please check with your system administrator';
                    });
            }
        } catch (ex) {
            console.error("Method : esSimilarCases fnGetSimilarCasesAgaintsCaseDetails Method; Error :" + ex.description);
        }
       
    }

    fnTriggerSearch() {
        var varIsChanged = false;
        var varSearchKeyword = '';
        var varLQParameter = '';
        var varAQParameter = '';
        if (this.varprevtitle !== undefined && this.varprevtitle !== this.vartitle) {
            this.varprevtitle = this.vartitle;
            console.log('Child Search: ' + this.varprevtitle);
            varIsChanged = true;
        }

        if (this.varprevsubject !== undefined && this.varprevsubject !== this.varsubject) {
            this.varprevsubject = this.varsubject;
            console.log('Child Search : ' + this.varprevsubject);
            varIsChanged = true;
        }

        if (this.varprevproduct !== undefined && this.varprevproduct !== this.varproduct) {
            this.varprevproduct = this.varproduct;
            console.log('Child Search : ' + this.varprevproduct);
            varIsChanged = true;
        }

        if (varIsChanged) {
            if (this.vartitle !== '') {
                varSearchKeyword = this.vartitle;
            }

            if (this.varsubject !== '') {
                if (varSearchKeyword.length > 0) {
                    varSearchKeyword += ' ' + this.varsubject;
                }
                else {
                    varSearchKeyword = this.varsubject;
                }
            }

            if (this.varproduct !== '') {
                // varAQParameter = "($qre(expression: @athenaProduct=\"" + this.varproduct + "\", modifier: 50)) ($sort(criteria: relevancy))";
                // varLQParameter = this.varproduct;
            }
            
            
        }
    }

    @api get similarcasesearchkeywordstitle() {
        console.log('Child Called Get : ');
        return this.vartitle;
    }
    set similarcasesearchkeywordstitle(value) {
        console.log('Child Called Set : ');
        this.vartitle = value;
        this.fnTriggerSearch();
    }

    @api get similarcasesearchkeywordssubject() {
        console.log('Child Called Get : ');
        return this.varsubject;
    }
    set similarcasesearchkeywordssubject(value) {
        console.log('Child Called Set : ');
        this.varsubject = value;
        this.fnTriggerSearch();
    }
    
    @api get similarcasesearchkeywordsproduct() {
        console.log('Child Called Get : ');
        return this.varproduct;
    }
    set similarcasesearchkeywordsproduct(value) {
        console.log('Child Called Set : ');
        this.varproduct = value;
        //this.fnTriggerSearch();        
    }
}