trigger eventBeforeTrigger on Event (before insert) {
   
    list<string> lstServiceAppointment = new list<string>();
    for(Event oevt : trigger.new){
        string saId = oevt.ServiceAppointmentId;
        if(saId != null){lstServiceAppointment.add(saId);}
    }
    map<string,ServiceAppointment> mapIdWiseSA = new map<string,ServiceAppointment>();
    list<ServiceAppointment> lstServiceAppointment1 = [select Id,(select id,CaseNumber From Cases__r LIMIT 1) From ServiceAppointment WHERE Id IN : lstServiceAppointment];
    for(ServiceAppointment oSA : lstServiceAppointment1){mapIdWiseSA.put(oSA.Id, oSA);}
    
    for(Event oevt : trigger.new){
        string saId = oevt.ServiceAppointmentId;
        if(saId != null && mapIdWiseSA.containsKey(saId)){
            if(mapIdWiseSA.get(saId).Cases__r.size() > 0){
               oevt.WhatId = mapIdWiseSA.get(saId).Cases__r[0].Id;    
            }
        }
    }        
}