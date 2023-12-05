/*
    @created by       : vwarrier
    @created on       : 09-Apr-2021
    @Purpose          : Testing psa_HelpController 
*/
@isTest(seeAllData=false)
public with sharing class psa_HelpControllerTest{

    public static testMethod void helpControllerTest(){
        psa_HelpController.getHelpItems();
    }
    
}