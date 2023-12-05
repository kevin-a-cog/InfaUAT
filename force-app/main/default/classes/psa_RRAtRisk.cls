/*
 * @author : Vivek Warrier
 * @date   : 09-Nov-2018
 * @purpose: to display the 'Staffing at Risk' warning on the RR page
*/
public class psa_RRAtRisk {
	@AuraEnabled
    public static pse__Resource_Request__c getisRRatRiskVar(Id recordId){
        return [SELECT Id FROM pse__Resource_Request__c Where Id = :recordId];
    }
}