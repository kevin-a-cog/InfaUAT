/*
        @Author: Conga Services, Spencer Essey
        @Created Date:  9/01/2018
        @Description:   Used to sync content files associated to CLM practice, like Legal Agreements to Conga Contracts Platform and Conga Contracts Novatus.
*/

public class PlatformContentHandler implements Sfc.ContentDownloadHandlerFactory{ 
    
    public Sfc.ContentDownloadHandler 
    
    getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext c){    
        
        Sfc.ContentDownloadHandler cdh = new Sfc.ContentDownloadHandler();   
        cdh.isDownloadAllowed = true;    
        try{apxt_redlining.PlatformContentDownloadHelper pcd = new apxt_redlining.PlatformContentDownloadHelper();  
        cdh = pcd.getContentDownloadHandler(ids,c);   
        }catch(Exception ex){ cdh = new Sfc.ContentDownloadHandler(); 
            cdh.isDownloadAllowed = true; return cdh;}   
        return cdh;  } 
    }