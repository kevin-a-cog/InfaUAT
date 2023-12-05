/*
 * Name:   globalCustomSettings
 * Author: Prasanth Sagar
 * Date:   09 April 2014
 * Description: The main purpose of the class is to have a framework to be used from anywhere(class or trigger) that will fetch the custom settings values from Global settings.
 
*/


public class globalCustomSettings{
    
    // Function that returns the String value of Type of the Instance from the custom setting 'Instance Settings'
    Public String FetchInstance(){
        //system.debug('..ins value..' +Instance_Settings__c.getValues('Name').Type_of_Instance__c);
        return Instance_Settings__c.getValues('Name') != null ? Instance_Settings__c.getValues('Name').Type_of_Instance__c : '';
        
    }
    
    // Function that returns the value depending on the Parameter passed, from the custom setting 'Global Settings'
    public String FetchCustomSettings(String CSName){
        
        String ParamValue = CSName;
        // Set the value of parameter in the string.
        
        String InstValue = FetchInstance() != null ? FetchInstance().toLowerCase() : '';
        // Fetch the value of the Type of Instance from the method
        
         // system.debug('..inst value..' +InstValue);
        
        String FinalValue;
        // String that returns the Final value depending on the Param passed and the Value fetched from the custom setting for that parameter value.
        
        if(InstValue !=null){
            if(Global_Settings__c.getValues(ParamValue) != null){
                FinalValue= InstValue == 'production' ? Global_Settings__c.getValues(ParamValue).Production_Value__c : InstValue == 'uat' ? Global_Settings__c.getValues(ParamValue).UAT_Value__c : InstValue == 'developer' ? Global_Settings__c.getValues(ParamValue).Developer_Value__c : '';
                // Set the value of FinalValue depending on the Instance values from the custom settings.
                //  If the Instance Value from "Instance Settings" is 'Production', fetch the value of Production_Value__c from "Global Settings"
                //  If the Instance Value from "Instance Settings" is 'UAT', fetch the value of UAT_Value__c from "Global Settings"
                //  If the Instance Value from "Instance Settings" is 'Developer', fetch the value of Developer_Value__c from "Global Settings"   
               // system.debug('..FinalValue..' +FinalValue);
            }           
            else
            {
                FinalValue = null;
            }                       
          
          
        }

        if(InstValue == null){
            FinalValue = null;
        }   
      //  system.debug('..FinalValue..' +FinalValue);
       
        return FinalValue;    
        
    }
    
}