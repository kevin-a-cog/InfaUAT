/*********************************************************************************************************************************************
*  @Class Name: PartnerProgramTriggerHandler
*  @Author: Deloitte
*  @Date: 2017-02-14 
*  @Description:This is a handler class which holds all the controller logics implemented for Partner Program Object.
*********************************************************************************************************************************************
ChangeHistory      
Modified By          Date        Requested By        Description                                             Tag
Rupanjana           2/14/2018    US-2165      Changes done to create/update ChannelProgram Member
                          on Partner Program create/update
Kiran G             10/9/2018    PRMRT-81        Updated the condition to check if the Partner Program is
                                                 Active or Inactive and show error                           T01               
*********************************************************************************************************************************************/
public class PartnerProgramTriggerHandler {
  public static globalApexManager GAM = new globalApexManager();
  public static boolean flag;
    
    /* this method called by before insert trigger
    * @Method Name- partnerProgramBeforeInsert
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */
    public static void partnerProgramBeforeInsert(List<Partner_Program__c> newPPList,Map<Id,Partner_Program__c> newPPMap){
    //Ticket: 001527
    if(validatePartnerProgram(newPPList) == true)
    {
      flag = true;
    }
    validateChannelProgramLevel(newPPList);
    }
  
  /* this method called by after insert trigger
    * @Method Name- partnerProgramAfterInsert
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */ 
    public static void partnerProgramAfterInsert(List<Partner_Program__c> triggernew){
    //Ticket: 001527
    if(flag == true)
    {
      appendCountryofChannelProgramMember(triggernew,'insert',null,null);
    }
    else
    {
      createChannelProgramMember(triggernew);
    }
    }
  
  /* this method called by before update trigger
    * @Method Name- partnerProgramBeforeUpdate
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */
    public static void partnerProgramBeforeUpdate(List<Partner_Program__c> triggernew, Map<Id, Partner_Program__c> newMap, Map<Id, Partner_Program__c> oldMap){
    //check If there is change in Channel Program Level
    validateChannelProgramLevel(triggernew);
    updateChannelProgramMember(triggernew, newMap, oldMap);
    
    for(Partner_Program__c oPartnerProgrm : triggernew){
      //check If there is change in Channel Program or Country
      if((null!=newMap.get(oPartnerProgrm.id).Channel_Program__c && newMap.get(oPartnerProgrm.id).Channel_Program__c != oldMap.get(oPartnerProgrm.id).Channel_Program__c) || (null!=newMap.get(oPartnerProgrm.id).Country__c && newMap.get(oPartnerProgrm.id).Country__c != oldMap.get(oPartnerProgrm.id).Country__c))
      {
        //Ticket: 001527
        if(validatePartnerProgram(triggernew) == true && (null!=newMap.get(oPartnerProgrm.id).Country__c && newMap.get(oPartnerProgrm.id).Country__c != oldMap.get(oPartnerProgrm.id).Country__c))
        {
          appendCountryofChannelProgramMember(triggernew,'update',newMap, oldMap);
        }
        else
        {
          upsertChannelProgramMember(triggernew, newMap, oldMap);
        }
      }
    }
    
  }
  
  /* On new Partner Program record creation, this method checks
    * If Partner Program with given Partner Account, Channel Program and Country already exists, then throw error
  * If Partner Program with given Partner Account and same Channel Program has different Country, set Flag to
  * be used for Channel Program Member Update.
  * @Method Name- validatePartnerProgram
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static boolean validatePartnerProgram(List<Partner_Program__c> triggernew){
    boolean flag = false;
    //set that will have Partner__c of all Partner Program
    set<String> newPartnerProgrmPartnerSet = new Set<String>();
    
    //set that will have Channel_Program__c of all Partner Program
    set<String> newPartnerProgrmChannelProgrmSet = new Set<String>();
    
    //set that will have Channel_Program_Level__c of all Partner Program
    set<String> newPartnerProgrmChannelProgrmLevelSet = new Set<String>();
    
    //set with PartnerProgrm that are duplicate
    set<Partner_Program__c> oPartnerProgrmErrorSet = new Set<Partner_Program__c>();

    for(Partner_Program__c oPartnerProgrm : triggernew){
      if(null != oPartnerProgrm.Partner__c && null != oPartnerProgrm.Channel_Program__c)
      {
        //populate newPartnerProgrmPartnerSet and newPartnerProgrmChannelProgrmSet
        newPartnerProgrmPartnerSet.add(oPartnerProgrm.Partner__c);
        newPartnerProgrmChannelProgrmSet.add(oPartnerProgrm.Channel_Program__c);
      }
    }
    
    if(!newPartnerProgrmPartnerSet.isEmpty() && !newPartnerProgrmChannelProgrmSet.isEmpty())
    {
      //List to fetch all Partner Program that have given Partner account
      Set<Partner_Program__c> oPartnerProgrmPartnerSet = new Set<Partner_Program__c>([select id from Partner_Program__c where Partner__c in :newPartnerProgrmPartnerSet]);

      //For the given account, check if any Partner Program has given Channel_Program__c
      if(null != oPartnerProgrmPartnerSet && !oPartnerProgrmPartnerSet.isEmpty())
      {
        //Added Program_Status__c field in query ------------------ T01
        Set<Partner_Program__c> oPartnerProgrmFinalSet = new Set<Partner_Program__c>([select id,Partner__c,Channel_Program__c,Country__c,Program_Status__c from Partner_Program__c where id in :oPartnerProgrmPartnerSet and Channel_Program__c in :newPartnerProgrmChannelProgrmSet]);
        
        if(null != oPartnerProgrmFinalSet && !oPartnerProgrmFinalSet.isEmpty() && oPartnerProgrmFinalSet.size()>0)
        {
          for(Partner_Program__c oPartnerProgrm : oPartnerProgrmFinalSet)
          {
            oPartnerProgrmErrorSet.add(oPartnerProgrm);
          }
        }
      }
    
    }
    
    for(Partner_Program__c oPartnerProgrm : triggernew)
    {
      //check if Partner Program with given Partner Account and Channel Program already exists
      if(null != oPartnerProgrm.Partner__c && null != oPartnerProgrm.Channel_Program__c && !oPartnerProgrmErrorSet.isEmpty())
      {
        for(Partner_Program__c errorPartnerProgrm : oPartnerProgrmErrorSet)
        {
          //Ticket: 001527:: Check if for same Partner Account, same Channel Program, Country is different
          if(oPartnerProgrm.Partner__c == errorPartnerProgrm.Partner__c && oPartnerProgrm.Channel_Program__c == errorPartnerProgrm.Channel_Program__c && oPartnerProgrm.Country__c != errorPartnerProgrm.Country__c)
          {
            flag = true;
          }
          //throw error if record with same Partner Account, same Channel Program and same Country exists
          //-----------------------------------------------------------<T01>
          if(oPartnerProgrm.Partner__c == errorPartnerProgrm.Partner__c && oPartnerProgrm.Channel_Program__c == errorPartnerProgrm.Channel_Program__c && oPartnerProgrm.Country__c == errorPartnerProgrm.Country__c && errorPartnerProgrm.Program_Status__c == 'Active')
          //-----------------------------------------------------------</T01>
          {
            oPartnerProgrm.addError(Label.PRM_Partner_Program_Error);
          }
        }
      }
    }
    return flag;
  }
  
  /* On new Partner Program record creation/update, this method checks
  *  if for the channel program level selected, if channel program level matches selected channel program, else throw error
  * @Method Name- validateChannelProgramLevel
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void validateChannelProgramLevel(List<Partner_Program__c> triggernew){
    
    //set that will have Channel_Program__c id of all Partner Program
    set<String> newPartnerProgrmChannelProgrmSet = new Set<String>();
    //map with Channel Program Id and List of Channel Program Level Id
    Map<Id, List<Id>> chnlProgrmIdWiseChnlProgrmLevelListMap = new Map<Id, List<Id>>();
    //set of channel program that do not have channel program levels
    set<String> channelProgramErrorSet = new set<String>();
    //List of Channel Program Level Id
    List<Id> channelPrgrmLevelList;
    //List of Channel Program 
    List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
    
    for(Partner_Program__c oPartnerProgrm : triggernew){
      if(null != oPartnerProgrm.Channel_Program_Level__c && null != oPartnerProgrm.Channel_Program__c)
      {
        newPartnerProgrmChannelProgrmSet.add(oPartnerProgrm.Channel_Program__c);
      }
    }
    
    //For the channel program level selected, check if channel program level matches selected channel program
    if(null != newPartnerProgrmChannelProgrmSet)
    {
      channelProgramList = [select id, (select id from ChannelProgramLevels) from ChannelProgram where id in :newPartnerProgrmChannelProgrmSet];
      if(null != channelProgramList && !channelProgramList.isempty())
      {
        for(ChannelProgram channelPrgrm : channelProgramList)
        {  
          //if channel program has no channel program levels
          if(channelPrgrm.ChannelProgramLevels.isEmpty())
          {
            channelProgramErrorSet.add(channelPrgrm.id);
          }
          else
          {
            for(ChannelProgramLevel channelPrgrmLevel : channelPrgrm.ChannelProgramLevels)
            {
              if(chnlProgrmIdWiseChnlProgrmLevelListMap.get(channelPrgrm.id) == null)
              {
                channelPrgrmLevelList = new List<Id>();
                channelPrgrmLevelList.add(channelPrgrmLevel.id);
              }
              else
              {
                channelPrgrmLevelList = chnlProgrmIdWiseChnlProgrmLevelListMap.get(channelPrgrm.id);
                channelPrgrmLevelList.add(channelPrgrmLevel.id);
              }
              chnlProgrmIdWiseChnlProgrmLevelListMap.put(channelPrgrm.id, channelPrgrmLevelList);
            }
          }
        }
        
      }
      
    }
    
    
    
    for(Partner_Program__c oPartnerProgrm : triggernew)
    {
      if(null != oPartnerProgrm.Channel_Program__c && null != channelProgramErrorSet && channelProgramErrorSet.contains(oPartnerProgrm.Channel_Program__c))
      {
        oPartnerProgrm.addError(Label.PRM_Partner_Program_Channel_Error);
      }
      //check if channel program level matches selected channel program
      else if(null != oPartnerProgrm.Channel_Program__c && null != oPartnerProgrm.Channel_Program_Level__c && !chnlProgrmIdWiseChnlProgrmLevelListMap.isEmpty() && null != chnlProgrmIdWiseChnlProgrmLevelListMap.get(oPartnerProgrm.Channel_Program__c))
      {
        GAM.CreateLogs('validateChannelProgramLevel','chnlProgrmIdWiseChnlProgrmLevelListMap: '+chnlProgrmIdWiseChnlProgrmLevelListMap);            
        GAM.CreateLogs('validateChannelProgramLevel','oPartnerProgrm.Channel_Program__c: '+oPartnerProgrm.Channel_Program__c);   
        if(!chnlProgrmIdWiseChnlProgrmLevelListMap.get(oPartnerProgrm.Channel_Program__c).contains(oPartnerProgrm.Channel_Program_Level__c))
        {         
          oPartnerProgrm.addError(Label.PRM_Partner_Program_Channel_Error);
        }
      }
    }
  }
  
  /* this method creates new Channel Program Member record upon new Partner Program Creation
  * @Method Name- createChannelProgramMember
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void createChannelProgramMember(List<Partner_Program__c> triggernew){
    //List of ChannelProgramMember to be inserted
    List<ChannelProgramMember> channelPrgrmMembrList = new List<ChannelProgramMember>();
    
    for(Partner_Program__c oPartnerProgrm : triggernew){
      if(null != oPartnerProgrm.Partner__c && null != oPartnerProgrm.Channel_Program__c)
      {
        ChannelProgramMember channelProgramMember= new ChannelProgramMember();
        channelProgramMember.PartnerId = oPartnerProgrm.Partner__c;
        channelProgramMember.ProgramId = oPartnerProgrm.Channel_Program__c;
        channelProgramMember.DEV_PartnerProgram__c = oPartnerProgrm.Id;
        if(null != oPartnerProgrm.Channel_Program_Level__c)
          channelProgramMember.LevelId = oPartnerProgrm.Channel_Program_Level__c;
        
        if(null != oPartnerProgrm.No_of_projects_registered__c)
          channelProgramMember.No_of_projects_registered__c = oPartnerProgrm.No_of_projects_registered__c;
        if(null != oPartnerProgrm.Co_Sell_License_Revenue_Actual__c)
          channelProgramMember.Co_Sell_License_Revenue_Actual__c = oPartnerProgrm.Co_Sell_License_Revenue_Actual__c;
        if(null != oPartnerProgrm.Co_Sell_Subscription_Revenue_Actual__c)
          channelProgramMember.Co_Sell_Subscription_Revenue_Actual__c = oPartnerProgrm.Co_Sell_Subscription_Revenue_Actual__c;
        if(null != oPartnerProgrm.Country__c)
          channelProgramMember.Country__c = oPartnerProgrm.Country__c;
        if(null != oPartnerProgrm.End_Date__c)
          channelProgramMember.End_Date__c = oPartnerProgrm.End_Date__c;
        if(null != oPartnerProgrm.No_of_Projects_CSAT_85__c)
          channelProgramMember.No_of_Projects_CSAT_85__c = oPartnerProgrm.No_of_Projects_CSAT_85__c;
        if(null != oPartnerProgrm.Pre_Sale_Certification_Compliance__c)
          channelProgramMember.Pre_Sale_Certification_Compliance__c = oPartnerProgrm.Pre_Sale_Certification_Compliance__c;
        if(null != oPartnerProgrm.Program_Level__c)
          channelProgramMember.Program_Level__c = oPartnerProgrm.Program_Level__c;
        if(null != oPartnerProgrm.Program_Name__c)
          channelProgramMember.Program_Name__c = oPartnerProgrm.Program_Name__c;
        if(null != oPartnerProgrm.Program_Status__c)
          channelProgramMember.Program_Status__c = oPartnerProgrm.Program_Status__c;
        if(null != oPartnerProgrm.Program_Type__c)
          channelProgramMember.Program_Type__c = oPartnerProgrm.Program_Type__c;
        if(null != oPartnerProgrm.Program_Year__c)
          channelProgramMember.Program_Year__c = oPartnerProgrm.Program_Year__c;
        if(null != oPartnerProgrm.Q1_Resell_Revenue__c)
          channelProgramMember.Q1_Resell_Revenue__c = oPartnerProgrm.Q1_Resell_Revenue__c;
        if(null != oPartnerProgrm.Q2_Resell_Revenue__c)
          channelProgramMember.Q2_Resell_Revenue__c = oPartnerProgrm.Q2_Resell_Revenue__c;
        if(null != oPartnerProgrm.Q3_Resell_Revenue__c)
          channelProgramMember.Q3_Resell_Revenue__c = oPartnerProgrm.Q3_Resell_Revenue__c;
        if(null != oPartnerProgrm.Q4_Resell_Revenue__c)
          channelProgramMember.Q4_Resell_Revenue__c = oPartnerProgrm.Q4_Resell_Revenue__c;
        if(null != oPartnerProgrm.Qp_Resell_Revenue__c)
          channelProgramMember.Qp_Resell_Revenue__c = oPartnerProgrm.Qp_Resell_Revenue__c;
        if(null != oPartnerProgrm.Renewal_Status__c)
          channelProgramMember.Renewal_Status__c = oPartnerProgrm.Renewal_Status__c;
        if(null != oPartnerProgrm.Resellers_Recruited_Annual_Actual__c)
          channelProgramMember.Resellers_Recruited_Annual_Actual__c = oPartnerProgrm.Resellers_Recruited_Annual_Actual__c;
        if(null != oPartnerProgrm.Resellers_Recruited_Annual_Target__c)
          channelProgramMember.Resellers_Recruited_Annual_Target__c = oPartnerProgrm.Resellers_Recruited_Annual_Target__c;
        if(null != oPartnerProgrm.Sale_Accreditation_Compliance__c)
          channelProgramMember.Sale_Accreditation_Compliance__c = oPartnerProgrm.Sale_Accreditation_Compliance__c;
        if(null != oPartnerProgrm.Start_Date__c)
          channelProgramMember.Start_Date__c = oPartnerProgrm.Start_Date__c;
        if(null != oPartnerProgrm.Total_Revenue_Target__c)
          channelProgramMember.Total_Revenue_Target__c = oPartnerProgrm.Total_Revenue_Target__c;
        if(null != oPartnerProgrm.Channel_Program_Level__c)
          channelProgramMember.DEV_Channel_Program_Level__c = oPartnerProgrm.Channel_Program_Level__c;
        
        channelPrgrmMembrList.add(channelProgramMember);
      }
    }
    
    if(null != channelPrgrmMembrList && !channelPrgrmMembrList.isEmpty())
    {
      try
        {
          insert channelPrgrmMembrList;
        }
        catch (System.DmlException e) 
        {   
          //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
          GAM.CreateLogs('Error while inserting from PartnerProgramTriggerHandler:createChannelProgramMember','ApexClass:PartnerProgramTriggerHandler');            
        }
    }    
  }
  
  
  /* this method updates new Channel Program Member record upon new Partner Program Creation
    *  If Partner Program with Partner and Channel Program already exists, then throw error
  * @Method Name- createChannelProgramMember
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void updateChannelProgramMember(List<Partner_Program__c> triggernew, Map<Id, Partner_Program__c> newMap, Map<Id, Partner_Program__c> oldMap){
    set<Id> partnerPrgrmIdSet = new Set<Id>();
    
    map<Id,Partner_Program__c> mapIdWisePartnrPrgrm = new map<Id,Partner_Program__c>();
    
    list<ChannelProgramMember> updateChnlPrgrmList = new list<ChannelProgramMember>();
    
    for(Partner_Program__c oPartnerProgrm : triggernew)
        {   
        partnerPrgrmIdSet.add(oPartnerProgrm.id);
        mapIdWisePartnrPrgrm.put(oPartnerProgrm.id,oPartnerProgrm);
    }
    List<ChannelProgramMember> chnlPrgrmList = new List<ChannelProgramMember>([select id,PartnerId,ProgramId,DEV_PartnerProgram__c from ChannelProgramMember where DEV_PartnerProgram__c in :mapIdWisePartnrPrgrm.keySet()]);

    if(null != chnlPrgrmList && !chnlPrgrmList.isEmpty())
    {
      for(ChannelProgramMember ochnlPrgrm : chnlPrgrmList)
      {
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Channel_Program_Level__c)
          ochnlPrgrm.LevelId = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Channel_Program_Level__c;
        
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).No_of_projects_registered__c)
          ochnlPrgrm.No_of_projects_registered__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).No_of_projects_registered__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Co_Sell_License_Revenue_Actual__c)
          ochnlPrgrm.Co_Sell_License_Revenue_Actual__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Co_Sell_License_Revenue_Actual__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Co_Sell_Subscription_Revenue_Actual__c)
          ochnlPrgrm.Co_Sell_Subscription_Revenue_Actual__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Co_Sell_Subscription_Revenue_Actual__c;
        //if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Country__c)
          //ochnlPrgrm.Country__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Country__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).End_Date__c)
          ochnlPrgrm.End_Date__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).End_Date__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).No_of_Projects_CSAT_85__c)
          ochnlPrgrm.No_of_Projects_CSAT_85__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).No_of_Projects_CSAT_85__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Pre_Sale_Certification_Compliance__c)
          ochnlPrgrm.Pre_Sale_Certification_Compliance__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Pre_Sale_Certification_Compliance__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Level__c)
          ochnlPrgrm.Program_Level__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Level__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Name__c)
          ochnlPrgrm.Program_Name__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Name__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Status__c)
          ochnlPrgrm.Program_Status__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Status__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Type__c)
          ochnlPrgrm.Program_Type__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Type__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Year__c)
          ochnlPrgrm.Program_Year__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Program_Year__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q1_Resell_Revenue__c)
          ochnlPrgrm.Q1_Resell_Revenue__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q1_Resell_Revenue__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q2_Resell_Revenue__c)
          ochnlPrgrm.Q2_Resell_Revenue__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q2_Resell_Revenue__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q3_Resell_Revenue__c)
          ochnlPrgrm.Q3_Resell_Revenue__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q3_Resell_Revenue__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q4_Resell_Revenue__c)
          ochnlPrgrm.Q4_Resell_Revenue__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Q4_Resell_Revenue__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Qp_Resell_Revenue__c)
          ochnlPrgrm.Qp_Resell_Revenue__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Qp_Resell_Revenue__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Renewal_Status__c)
          ochnlPrgrm.Renewal_Status__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Renewal_Status__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Resellers_Recruited_Annual_Actual__c)
          ochnlPrgrm.Resellers_Recruited_Annual_Actual__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Resellers_Recruited_Annual_Actual__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Resellers_Recruited_Annual_Target__c)
          ochnlPrgrm.Resellers_Recruited_Annual_Target__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Resellers_Recruited_Annual_Target__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Sale_Accreditation_Compliance__c)
          ochnlPrgrm.Sale_Accreditation_Compliance__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Sale_Accreditation_Compliance__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Start_Date__c)
          ochnlPrgrm.Start_Date__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Start_Date__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Total_Revenue_Target__c)
          ochnlPrgrm.Total_Revenue_Target__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Total_Revenue_Target__c;
        if(null != mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Channel_Program_Level__c)
          ochnlPrgrm.DEV_Channel_Program_Level__c = mapIdWisePartnrPrgrm.get(ochnlPrgrm.DEV_PartnerProgram__c).Channel_Program_Level__c;
        
        
        updateChnlPrgrmList.add(ochnlPrgrm);
      }
    }
    
    if(null != updateChnlPrgrmList && !updateChnlPrgrmList.isEmpty())
    {
      try
        {              
          update updateChnlPrgrmList;
        }
        catch (System.DmlException e) 
        {   
          //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
          GAM.CreateLogs('Error while updating from PartnerProgramTriggerHandler:updateChannelProgramMember','ApexClass:PartnerProgramTriggerHandler');            
        }
    }
  }
  
  /* On Partner Program update, if Channel Program Updates,
    *  delete old Channel PRogram Member record, and create new record
  * @Method Name- upsertChannelProgramMember
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void upsertChannelProgramMember(List<Partner_Program__c> triggernew,Map<Id, Partner_Program__c> newMap, Map<Id, Partner_Program__c> oldMap){
    
    set<Id> partnerProgrmIdSetOld = new Set<Id>();
    
    list<Partner_Program__c> partnerProgrmListNew = new List<Partner_Program__c>();
    
    for(Partner_Program__c oPartnerProgrm : triggernew){
      //check If there is change in Channel Program 
      if(null!=oldMap.get(oPartnerProgrm.id).Channel_Program__c)
      {
        partnerProgrmIdSetOld.add(oPartnerProgrm.id);
      }
      if(null != newMap.get(oPartnerProgrm.id).Channel_Program__c)
      {
        partnerProgrmListNew.add(oPartnerProgrm);
      }
    }
    
    if(!partnerProgrmIdSetOld.isEmpty())
    {
      List<ChannelProgramMember> chanlPrgrmListDelete = new List<ChannelProgramMember>([select id,PartnerId,ProgramId,DEV_PartnerProgram__c from ChannelProgramMember where DEV_PartnerProgram__c in :partnerProgrmIdSetOld]);
    
      //delete old channel program member tagged to old channel program for this partner program
      if(null != chanlPrgrmListDelete && !chanlPrgrmListDelete.isEmpty())
      {
        try
        {              
          delete chanlPrgrmListDelete;
        }
        catch (System.DmlException e) 
        {   
          //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
          GAM.CreateLogs('Error while deleting from PartnerProgramTriggerHandler:upsertChannelProgramMember','ApexClass:PartnerProgramTriggerHandler');            
        }
      }
    }
    
    if(!partnerProgrmListNew.isEmpty())
    {
      createChannelProgramMember(partnerProgrmListNew);
    }
    
  }
  
  
  /* this method appends Country field of Channel Program Member record
  *  if new Partner Program record is created with same Partner Account, 
  *  same Channel Program but different Country
  * @Method Name- appendCountryofChannelProgramMember
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void appendCountryofChannelProgramMember(List<Partner_Program__c> triggernew,string triggerOperation, Map<Id, Partner_Program__c> newMap, Map<Id, Partner_Program__c> oldMap){
    //set of Channel Program Id
    set<Id> chnlPrgrmIdSet = new Set<Id>();
    //set of Acc Id
    set<Id> accIdSet = new Set<Id>();
    
    list<ChannelProgramMember> updateChnlPrgrmMembrList = new list<ChannelProgramMember>();
    
    try
    {
      for(Partner_Program__c oPartnerProgrm : triggernew)
      {   
          chnlPrgrmIdSet.add(oPartnerProgrm.Channel_Program__c);
          accIdSet.add(oPartnerProgrm.Partner__c);
      }
      
      //Fetch the Channel Program Member that has the same Channel Program and Account Id
      List<ChannelProgramMember> chnlPrgrmMembrList = new List<ChannelProgramMember>([select id,PartnerId,ProgramId,DEV_PartnerProgram__c,Country__c from ChannelProgramMember where ProgramId in :chnlPrgrmIdSet and PartnerId in :accIdSet]);
      
      for(Partner_Program__c oPartnerProgrm : triggernew)
      {
        for(ChannelProgramMember ochnlPrgrmMembr : chnlPrgrmMembrList)
        {
          //handle Insert
          if(triggerOperation.equalsIgnoreCase('insert'))
          {
            //If existing Country field of Channel Program Member does not contain New Country from Inserted Partner Program, append country
            if(oPartnerProgrm.Partner__c == ochnlPrgrmMembr.PartnerId && oPartnerProgrm.Channel_Program__c == ochnlPrgrmMembr.ProgramId &&
            !ochnlPrgrmMembr.Country__c.split(';').contains(oPartnerProgrm.Country__c))
            {
              ochnlPrgrmMembr.Country__c = ochnlPrgrmMembr.Country__c + ';' + oPartnerProgrm.Country__c;
              updateChnlPrgrmMembrList.add(ochnlPrgrmMembr);
            }
          }
          //handle Update
          else
          {
            if(oPartnerProgrm.Partner__c == ochnlPrgrmMembr.PartnerId && oPartnerProgrm.Channel_Program__c == ochnlPrgrmMembr.ProgramId)
            {
              //delete old counntry
              if(ochnlPrgrmMembr.Country__c.split(';').contains(oldMap.get(oPartnerProgrm.id).Country__c))
              {
                string newCountry = '';
                for(string country : ochnlPrgrmMembr.Country__c.split(';'))
                {
                  if(country != oldMap.get(oPartnerProgrm.id).Country__c)
                  {
                    newCountry = country + ';';
                  }
                }
                //remove trailing ';'
                if(newCountry != '' && newCountry.substring(newCountry.length() - 1) == ';')
                {
                  newCountry = newCountry.substring(0,newCountry.length() - 1);
                }
                ochnlPrgrmMembr.Country__c = newCountry;
              }
              //add new country
              if(!ochnlPrgrmMembr.Country__c.split(';').contains(newMap.get(oPartnerProgrm.id).Country__c))
              {
                ochnlPrgrmMembr.Country__c = ochnlPrgrmMembr.Country__c + ';' + oPartnerProgrm.Country__c;
              }
            }
            updateChnlPrgrmMembrList.add(ochnlPrgrmMembr);
          }
        }
      }
      
      if(null != updateChnlPrgrmMembrList && !updateChnlPrgrmMembrList.isEmpty())
      {
        try
        {              
          update updateChnlPrgrmMembrList;
        }
        catch (System.DmlException e) 
        {   
          //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
          GAM.CreateLogs('Error while updating from PartnerProgramTriggerHandler:appendCountryofChannelProgramMember','ApexClass:PartnerProgramTriggerHandler');            
        }
      }
    }
    catch(Exception e)
    {
      GAM.CreateLogs('Error from PartnerProgramTriggerHandler:appendCountryofChannelProgramMember','ApexClass:PartnerProgramTriggerHandler'); 
    }
    
  }
}