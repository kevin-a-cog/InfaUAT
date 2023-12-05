/****************************************************************************************************************
Class:          UserLicenseDetailsReport
@Author:        Rupesh
@Created Date:   5/29/2018 10:14 AM
@Description:    Get Salesforce License and Manage Package License. Then send mail to Kiran, Omar and Karthik whose cosumed liscence is more than 85% 

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Mohammed Anies      25th July 2022                    Karthik Thitte      Report modified to include pending license request and using name column for MPLs

************************************************************************************************************************************************************
******************************************************************************************************************/
global with sharing class UserLicenseDetailsReport Implements Schedulable{
            
            global void execute(SchedulableContext sc)
            
            {
                
              Monitoring_Notification__c mn= new Monitoring_Notification__c(Notification_Source__c='License monitoring');
              insert mn;
                                
            }

        public static globalApexManager GAM = new globalApexManager(); 
        public List<UserLicense> records{get;set;}        
        public List<PackageLicense> packagelicenserecords{get;set;}
        public List<PackageLicense> records1{get;set;}
        public List<PackageLicense> records2{get;set;}
              
        public List<PermissionSetLicense> permissionSetLicenserecords{get;set;}
        public List<Publisher> publisherList{get;set;}
         
        public decimal p13{set;get;}
        public decimal p14{set;get;}
        public decimal p15{set;get;}
        public decimal p16{set;get;}
        public decimal p17{set;get;}
        public decimal p18{set;get;}
        public List<innerWrapper> wrapObjectList {get; set;}
        public Integer intCount{set;get;}
        public Integer totLic{set;get;}

        public List<packageLicensesDetails> lstPackageLicenseDetails  {get; set;}
        public Map<String,String> publisherNames = new Map<String,String>();
        
        public List<PermissionSetLicenseDetails> lstPermissionSetLicenseDetails {get; set;}
                
         global UserLicenseDetailsReport () { 
          
            totLic=0;

             records  = [SELECT Id,MasterLabel,Name,Status,TotalLicenses,UsedLicenses,UsedLicensesLastUpdated FROM UserLicense WHERE Status != 'Disabled'];            
                                     
             packagelicenserecords = [SELECT AllowedLicenses,ExpirationDate,NamespacePrefix,Status,UsedLicenses,SystemModstamp FROM PackageLicense WHERE AllowedLicenses >= 0];           
                          
             permissionSetLicenserecords = [select MasterLabel,DeveloperName,UsedLicenses, TotalLicenses,ExpirationDate from PermissionSetLicense where UsedLicenses >0 and Status!='Disabled'];           
             
             //Get list of packages details
             publisherList = [SELECT Name, NamespacePrefix, IsSalesforce FROM Publisher where IsSalesforce = false];
             //publisherNames = new Map<String,String>();
             if(publisherList != null){
             for(Publisher publisherRecord : publisherList){
              publisherNames.put(publisherRecord.NamespacePrefix,publisherRecord.Name);
             }

             }

             //Get pendinglicenes details from user provisioning app
             List<Add_On_Permission_Request__c> lstAddonPermissionRequests = new List<Add_On_Permission_Request__c>();
             Map<String,String> mapApptoPSL = new Map<String,String>();
             Map<String,String> mapApptoMPL = new Map<String,String>();
             List<User_provisioning_Approver_Matrix__mdt>  lstPermissionsInfo = [SELECT Id,Label,Managed_Package_License__c,Permission_Set_License__c FROM User_provisioning_Approver_Matrix__mdt];

             if (lstPermissionsInfo != null) {
              for(User_provisioning_Approver_Matrix__mdt permissionInfo:lstPermissionsInfo){
                if(permissionInfo.Permission_Set_License__c != null){
                  mapApptoPSL.put(permissionInfo.Label, permissionInfo.Permission_Set_License__c);
                }

                if(permissionInfo.Managed_Package_License__c != null){
                  mapApptoMPL.put(permissionInfo.Label,permissionInfo.Managed_Package_License__c);
                }



              }
              

             }
             Map<String,integer> mapMPLCount = new Map<String,Integer>(); //Map of Managed Package Licenses
             Map<String,integer> mapPSLCount = new Map<String,Integer>(); //Map of Permission Set Licenses

             lstAddonPermissionRequests = [SELECT Id,Add_Ons__c FROM Add_On_Permission_Request__c WHERE Approval_Status__c IN ('New','Pending Approval')];
             if (lstAddonPermissionRequests != null) {

              for(Add_On_Permission_Request__c userRequest:lstAddonPermissionRequests){
                
                

                if(mapApptoMPL.containsKey(userRequest.Add_Ons__c))
                {
                  string mplLicenses = mapApptoMPL.get(userRequest.Add_Ons__c);
                  Set<String> setMpl = new Set<String>();
                  setMpl.addAll(mplLicenses.split(';'));
                  if(!setMpl.isEmpty()){
                    for(string mpldevName : setMpl){
                      if(mapMPLCount.containsKey(mpldevName)){
                        integer licensecount = mapMPLCount.get(mpldevName) + 1;
                        mapMPLCount.put(mpldevName, licensecount);

                      }else{
                        mapMPLCount.put(mpldevName, 1);

                    }
                  }
                }

                }

                if(mapApptoPSL.containsKey(userRequest.Add_Ons__c)){
                  String pslLicenses = mapApptoPSL.get(userRequest.Add_Ons__c);
                  Set<String> setPsl = new Set<String>();
                  setPsl.addAll(pslLicenses.split(';'));
                if(!setPsl.isEmpty()){
                  for(string psldevName : setPsl){
                    if(mapPSLCount.containsKey(psldevName)){
                      integer licensecount = mapPSLCount.get(psldevName) + 1;
                      mapPSLCount.put(psldevName, licensecount);

                    }else{
                      mapPSLCount.put(psldevName, 1);

                    }
                  }
                }

                }
              }
             }
             //Build MPL list of records
             lstPackageLicenseDetails = new List<packageLicensesDetails>();
             for(PackageLicense mplRecordrecords : packagelicenserecords)
             {
              String pkgName = publisherNames.get(mplRecordrecords.NamespacePrefix);
              integer pendingMPLicenseRequests = 0;
              if (pkgName != null) {
         
                  pkgName = pkgName + ' (' + mplRecordrecords.NamespacePrefix + ')';
                } 
              if(mapMPLCount.containsKey(mplRecordrecords.NamespacePrefix)){
                pendingMPLicenseRequests = mapMPLCount.get(mplRecordrecords.NamespacePrefix);

              }
              lstPackageLicenseDetails.add(new packageLicensesDetails(mplRecordrecords.AllowedLicenses,mplRecordrecords.ExpirationDate,pkgName,mplRecordrecords.Status,mplRecordrecords.UsedLicenses,mplRecordrecords.SystemModstamp,pendingMPLicenseRequests));
             }

             //Build PSL list of records
             lstPermissionSetLicenseDetails = new List<PermissionSetLicenseDetails>();
             if(permissionSetLicenserecords != null){
              for(PermissionSetLicense pslRecord : permissionSetLicenserecords){
                Integer pendingPSLRequests = 0;
                if(mapPSLCount.containsKey(pslRecord.DeveloperName)){
                  pendingPSLRequests = mapPSLCount.get(pslRecord.DeveloperName);

                }
                lstPermissionSetLicenseDetails.add(new PermissionSetLicenseDetails(pslRecord.MasterLabel,pslRecord.UsedLicenses,pslRecord.TotalLicenses,pslRecord.ExpirationDate,pendingPSLRequests));  
               }             

             }

             
                                      
             if(wrapObjectList==null)
             {Integer intCount = 0;
               Integer totLic = integer.valueof(Label.KBFeatureLicenseCount);
               string s = Label.KBFeatureLicenseLabel;
              wrapObjectList = new List<innerWrapper>();
              for(AggregateResult result :[SELECT COUNT(Id) intVal FROM User where UserPermissionsKnowledgeUser = true and isactive=true]) {

              intCount+=(Integer)result.get('intVal');
              p13=(intCount)/(totLic);
              p15=totLic-intCount;
              p14=((intCount*100)/(totLic));
            
              wrapObjectList.add(new innerWrapper(totLic,intCount,p15,p14,s));
               }
             }

            if(wrapObjectList!=null)
             {Integer intCount = 0;
               Integer totLic = integer.valueof(Label.ServiceCloudUserFeatureLicenseCount);
               string s=Label.FeatureLicenseLabelServiceCloudUser;
             
              for(AggregateResult result :[SELECT COUNT(Id) intVal FROM User where UserPermissionsSupportUser  = true and isactive=true]) {

              intCount+=(Integer)result.get('intVal');
             
              p16=(intCount)/(totLic);
              p17=((intCount*100)/(totLic));
              p18=totLic-intCount;
             
              
              wrapObjectList.add(new innerWrapper(totLic,intCount,p18,p17,s));
               }
             }
          }//end of constructor

          
         
         public void init(){}
   
      
   public class innerWrapper{

             public integer TLicen {get; set;}
             public integer UsedLicen {get; set;}
             public decimal AvailLicen {get; set;}
             public decimal UsedPercent {get; set;}
             public string name {get; set;}

 public innerWrapper(integer totalLicense, integer usedLicense, decimal availableLicense, decimal usedPercentage, string label) {
  TLicen = totalLicense;
  UsedLicen = usedLicense;
  AvailLicen = availableLicense;
  UsedPercent = usedPercentage;
  name = label;
 }
 }  
  
 // wrapper class details for managed package licenses
  public class packageLicensesDetails{

    public integer AllowedLicenses {get; set;}
    public Datetime ExpirationDate {get; set;}
    public string NamespacePrefix {get; set;}
    public string Status{get; set;}
    public integer UsedLicenses{get; set;}
    public Datetime SystemModstamp{get; set;}
    public integer PendingMPLRequests{get; set;}

      public packageLicensesDetails(integer AllowedLicenses, Datetime ExpirationDate, string NamespacePrefix, string Status, integer UsedLicenses, Datetime SystemModstamp, integer PendingMPLRequests){

        this.AllowedLicenses = AllowedLicenses;
        this.ExpirationDate = ExpirationDate ;
        this.NamespacePrefix = NamespacePrefix ;
        this.Status = Status;
        this.UsedLicenses = UsedLicenses;
        this.SystemModstamp = SystemModstamp;
        this.PendingMPLRequests = PendingMPLRequests;

      }


  }

  // wrapper class details for permission set licenses
  public class PermissionSetLicenseDetails{
    public string MasterLabel {get; set;}
    public integer UsedLicenses {get; set;}
    public integer TotalLicenses {get; set;}
    public Date ExpirationDate {get; set;}
    public integer PendingPSLRequests {get; set;}

    public PermissionSetLicenseDetails(string MasterLabel,integer UsedLicenses,integer TotalLicenses,Date ExpirationDate,integer PendingPSLRequests)
    {
      this.MasterLabel = MasterLabel;
      this.UsedLicenses = UsedLicenses;
      this.TotalLicenses = TotalLicenses;
      this.ExpirationDate = ExpirationDate;
      this.PendingPSLRequests = PendingPSLRequests;
    }


  }
}