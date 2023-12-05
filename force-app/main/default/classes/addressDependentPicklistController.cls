/*
@created by       : Wasim Akram
@created on       : 02-Nov-2022
@Purpose          : Controller class for the LWC Component addressDependentPicklist

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
Wasim           09-Aug-2023                         Project Location bug fix for more than 2000 cities    PSA-3115       <T1>
****************************************************************************************************************************
*/
public with sharing class addressDependentPicklistController {
    public static globalApexManager GAM = new globalApexManager();
    //Wrapper class that contains the picklist options and the default City, State, and Country
    public class WrapperAddressDetails{
        @AuraEnabled
        public String Country {get; set;}
        @AuraEnabled
        public String State {get; set;}
        @AuraEnabled
        public String City {get; set;} 
        @AuraEnabled
        public List<String> CountryOptions {get; set;} 
        @AuraEnabled
        public List<String> StateOptions {get; set;}
        @AuraEnabled
        public List<String> CityOptions {get; set;}
    }
    /**
    * Method invoked to get the default Country, City, and State for the existing project location
    * @param recordId - Project Location Id 
    * @return return- WrapperAddressDetails class
    * @throws exception - NA
    */
    @AuraEnabled(cacheable=true)
    public static WrapperAddressDetails getDefaultValues(Id recordId){
        try {
            List<pse__Project_Location__c> projLoc = [SELECT PSA_Work_Country__c,PSA_PM_Work_State__c,psa_PM_Work_City__c FROM pse__Project_Location__c WHERE Id = :recordId];
            WrapperAddressDetails wrapper = new WrapperAddressDetails();
            wrapper.Country = projLoc[0].PSA_Work_Country__c;
            wrapper.State = projLoc[0].PSA_PM_Work_State__c;
            wrapper.City = projLoc[0].psa_PM_Work_City__c;
            wrapper.CountryOptions = getCountryList();
            wrapper.StateOptions = getStateList(projLoc[0].PSA_Work_Country__c);
            wrapper.CityOptions = getCityList(projLoc[0].PSA_Work_Country__c,projLoc[0].PSA_PM_Work_State__c);
            return wrapper;
        } catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.getDefaultValues() -> ' + e.getCause(),e.getmessage(), recordId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Method invoked to get the Country picklist options
    * @param - no parameters 
    * @return return- List<String>
    * @throws exception - NA
    */
    @AuraEnabled
    public static List<String> getCountryList(){
        try {
            List<String> countryList = new List<String>();
            //Get unique Countries
            for(AggregateResult ag : [SELECT Country__c FROM AddressMatrix__c WHERE Is_Active__c = TRUE
                                      GROUP BY Country__c LIMIT 50000]){
                countryList.add((String) ag.get('Country__c'));
            }
            return(countryList);
        }
        catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.getCountryList() -> ' + e.getCause(),e.getmessage(), '');
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Method invoked to get the Country picklist options without United States
    * @param - no parameters 
    * @return return- List<String>
    * @throws exception - NA
    */
    @AuraEnabled
    public static List<String> getCountryListWithoutUS(){
        try {
            List<String> countryList = new List<String>();
            //Get unique Countries
            for(AggregateResult ag : [SELECT Country__c FROM AddressMatrix__c WHERE Is_Active__c = TRUE
                                      AND Country__c != :Label.countryUS GROUP BY Country__c ORDER BY Country__c LIMIT 50000]){
                countryList.add((String) ag.get('Country__c'));
            }
            return(countryList);
        }
        catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.getCountryListWithoutUS() -> ' + e.getCause(),e.getmessage(), '');
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Method invoked to get the State picklist options
    * @param countryName - String
    * @return return- List<String>
    * @throws exception - NA
    */
    @AuraEnabled
    public static List<String> getStateList(String countryName){
        try {
            List<String> stateList = new List<String>();
            for(AggregateResult ag : [SELECT State__c FROM AddressMatrix__c WHERE Is_Active__c = TRUE
                                      AND Country__c = :countryName GROUP BY State__c ORDER BY State__c LIMIT 50000]){
                stateList.add((String) ag.get('State__c'));
            }
            return(stateList);
        } catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.getStateList() -> ' + e.getCause(),e.getmessage(), '');
            throw new AuraHandledException(e.getMessage());}
    }
    /**
    * Method invoked to get the City picklist options
    * @param countryName - String, stateName - String
    * @return return- List<String>
    * @throws exception - NA
    */
    @AuraEnabled
    public static List<String> getCityList(String countryName, String stateName){
        try {
            List<String> cityList = new List<String>();
            Set<String> citySet = new Set<String>();
            for(AddressMatrix__c am : [SELECT City__c FROM AddressMatrix__c WHERE Is_Active__c = TRUE
                                      AND Country__c = :countryName AND State__c = :stateName ORDER BY City__c /*<T1> GROUP BY City__c*/ LIMIT 50000]){
                citySet.add(am.City__c);
            }
            cityList.addAll(citySet);
            return(cityList);
        } catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.getCityList() -> ' + e.getCause(),e.getmessage(), '');
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Method invoked to update the Project Location address fields
    * @param recordId,countryName,stateName,cityName
    * @return return- String
    * @throws exception - NA
    */
    @AuraEnabled
    public static String updateAddress(Id recordId, String countryName, String stateName, String cityName){
        try {
            pse__Project_Location__c projLoc = new pse__Project_Location__c(Id = recordId, PSA_Work_Country__c = countryName, PSA_PM_Work_State__c = stateName, psa_PM_Work_City__c = cityName,psa_pm_MSA_Code_Mapping__c = null,PSA_PM_Work_County__c = '',Home_Location__c = false);
            update projLoc;
            return 'SUCCESS';
        } catch (Exception e) {GAM.CreateExceptionRecords('addressDependentPicklistController.updateAddress() -> ' + e.getCause(),e.getmessage(), recordId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}