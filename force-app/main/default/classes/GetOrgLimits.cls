/*
Class:          GetOrgLimits 
@Author:        Mohammed Anies
@Created Date:  28 June 2022
@Description:   Class to get details of orglimits.


Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag

******************************************************************************************************************************
*/
public without sharing class GetOrgLimits {
    
    class LimitsData implements Comparable {
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public Integer max{get; set;}
        @AuraEnabled
        public Integer usage{get; set;}
        @AuraEnabled
        public Integer usageRate{get; set;}
        
        public LimitsData(String name, Integer max, Integer usage){
            this.name = name;
            this.max = max;
            this.usage = usage;
            if (this.max == 0) {
                this.usageRate = 0;
            } else {
                this.usageRate =  Math.round((Double)this.usage / (Double)this.max *100);
            }
        }
        
        public Integer compareTo(Object compareTo) {
            LimitsData compareToData = (LimitsData)compareTo;
            if (usageRate > compareToData.usageRate) {
                return -1;
            } else if (usageRate < compareToData.usageRate) {
                return 1;
            } else if (name < compareToData.name) {
                return -1;
            } else {
                return 1;
            }
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LimitsData> getAll() {
        List<LimitsData> resList = new List<LimitsData>();
        
        Map<String,OrgLimit> mapLimits = System.OrgLimits.getMap();
        
        for(String s : mapLimits.keySet()){
            LimitsData res = new LimitsData(mapLimits.get(s).getName(), mapLimits.get(s).getLimit(), mapLimits.get(s).getValue() );
            resList.add(res);
        }
        
        resList.sort();
        return resList;
    }
}