({
    /*
    This helper function filters emails from objects.
    */
       

    getEmailsFromcopy : function(list){
            var ret = '';
            for (var i in list) {
            //var emailtemp = list[i].Email.replace(",", ";") 
            ret = ret + list[i].Email;
                ret = ret + ';';
            //ret.push(list[i].Email);
			
    }    
        
     return ret;
  },
  
    getrefid : function(subject){        
         var n = subject.indexOf("Ref{");        
       // return subject.substring(n, n+26);
         return subject.substring(n, n+27);
      
       
        
        
        
    }
})