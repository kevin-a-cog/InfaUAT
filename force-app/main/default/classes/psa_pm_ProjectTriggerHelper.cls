/*
@created by       : MAHESH GANTI
@created on       : 11/12/2020
@description      : PSA- Project Trigger Helper class.
@Testclass        : 
@JIRA             : 


Change History
*****************************************************************************************************************
ModifiedBy          |  Date      |  Requested By   | Description                            |   Jira No.    | Tag
Ranjan              | 02/01/2021 |                 | Set "Exclude from Billing" Flag true   |   PSA-1328    |  1
Ranjan              | 02/28/2021 |                 | Provide project sharingaccess to       |   PSA-757     |  2
                    |            |                 | Portfolio manager.                     |               |
P.Sharma            | 02/03/2021 |                 | Set "% Complete"                       |   PSA-1425    |  3
Ranjan              | 06/17/2021 |                 | Allow multiple non billable projects   |               |  4
                    |            |                 | under an opportunity                   |   PSA-1700    |
MAHESH GANTI        | 07/20/2021 |                 | get RPG fields from Oppty              |   PSA-1904    |
Vivek Warrier       | 18-Nov-2021| Neha Kumari     | Create Opty for Child Project          |   PSA-2070    |  T7
Pavithra V          | 09-Dec-2021|    Cosmos       | To sync the project details to         |               |
                    |            |                 | IPS Jumpstart Engagement               |   AR-1584     |  T8
Vivek Warrier       | 22-Dec-2021| Self            | Tech Debt - Optimization               |   PSA-2220    |  T9
Vivek Warrier       | 22-Dec-2021| Neha Kumari     | Update Project Name on After Insert    |   PSA-2082    |  T10
Vivek Warrier       | 19-Dec-2021| Jan Build '22   | Populating Opportunity Owner           |   PSA-2229    |  T11
Wasim Akram         | 28-Apr-2022|                 | Bug fix - PM do not have sharing access|   PSA-2404    |  T12
Wasim Akram         | 25-May-2022| June Build '22  | Party Address Master - Create new      |   PSA-2447    |  T13
                    |            |                 | address reference fields on Project and                |
                    |            |                 | Sync with Quote                        |               |
Vivek Warrier       | 29-Jul-2022| July Build '22  |                                        |   PSA-2508    |  T14
Wasim Akram         | 20-Sep-2022| Nov Build '22   | Quote & Budget Values Sync             |   PSA-2562    |  T15
Wasim Akram         | 02-Nov-2022| Nov Build '22   | Bug Fix - Budget name character limit  |   PSA-2559    |  T16
Wasim Akram         | 24-Nov-2022| Dec Build '22   | PMO Project Page Automation Requests   |   PSA-2681    |  T17
Wasim Akram         | 23-Jan-2023| Feb Build '23   | RYG Status Section Updates - At Risk   |   PSA-2682    |  T18
Wasim Akram         | 17-May-2023| Jun Build '23   | Service Units implementation           |   PSA-2606    |  T19
Rohit Niranjanamath | 15-Jun-2023| July Build '23  |Bug fix - PSA PM/Portfolio users are    |   PSA-3060    |  T20
                    |            |                 |restricted to edit the project status   |               |
                    |            |                 |section at any project stage            |               |
Rohit Niranjanamath | 12-Aug-2023| Aug Build '23   | Solution type update                   |   PSA-3080    |  T21  
Rohit Niranjanamath | 14-Oct-2023| Oct Build '23   | Auto update Adoption event not required|   PSA-3145    |  T22
                    |                              | field for Child projects               |               |
Wasim               | 17-Oct-2023| Nov Build '23   | The Billing Email when revised in the  |   PSA-3219    |  T23
                                                     Quote should sync to the project        
Rohit Niranjanamath | 18-Nov-2023| Nov Build '23   | Tech Debt: Code refactoring to align   |   PSA-3227    |  T24
                                                     with Unit of Work Framework           
Rohit Niranjanamath | 18-Nov-2023| Nov Build '23   | RevOps access issues                   |   PSA-3240   |   T25
Rohit Niranjanamath | 18-Nov-2023| Nov Build '23   | Rev Ops Contact information to be 
                    |                                updated on Project from Region         |   PSA-3233   |   T26  
Wasim               | 20-Nov-2023| Dec Build '23'  | Project sponsor on Project page        |   PSA-3289   |   T27                                                   
******************************************************************************************************************
*/

public without sharing class psa_pm_ProjectTriggerHelper {
    public static globalApexManager gam = new globalApexManager();    
    private static String rowCause = Schema.pse__Proj__Share.RowCause.ProjectTeam__c; //<T12>
    public static List<String> riskStatusList = new List<String>{'Red'};//<T18>
    //<T24>
    private static List<Schema.SObjectType> mySObjects =
        new Schema.SObjectType[] {
                Opportunity.SObjectType,
                pse__Proj__c.SObjectType,
                psa_pm_Project_Contact__c.SObjectType,
                pse__Budget__c.SObjectType,
                pse__Proj__Share.SObjectType,
                psa_pm_Solution_Type__c.SObjectType,
                pse__Resource_Request__c.SObjectType
                };
    public static UnitOfWork uow = new UnitOfWork(mySObjects);
    //</T24>
    /**
* @description - This method is invoked on Before Insert to throw custom validations error on Project Creation.
* @param newProjList - list of new Projects
* @throws exception - NA
*/
    public void runValidationsOnInsert(List<pse__Proj__c> newProjList){
        // Check if the parent opportunity already has a Project associated.
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();

        oppMap = getOppMapOfProjects(newProjList);
        if(oppMap.size()>0){
            for(pse__Proj__c proj : newProjList){
                if(proj.psa_om_Interlock__c == null && proj.pse__Is_Billable__c){ // Tag <04>
                    if(oppMap.containsKey(proj.pse__Opportunity__c) && (oppMap.get(proj.pse__Opportunity__c).pse__Projects__r.size() != 0)){
                        for(pse__Proj__c existingProjRec : oppMap.get(proj.pse__Opportunity__c).pse__Projects__r){ // Tag <04>
                            if(existingProjRec.pse__Is_Billable__c){
                                proj.addError('Billable project is already associated with this Opportunity'); 
                            }
                        }
                        
                    }
                }
            }
        }     
    }
    
    /**
    * @description - This method is invoked on Before Update to throw custom validations error on Project Update.
    * @param oldProjList - list of old Projects
    * @param newProjList - list of new Projects
    * @param oldProjMap - map of old Projects
    * @param newProjMap - map of new Projects
    * @throws exception - NA
    */
    public void runValidationsOnUpdate(List<pse__Proj__c> oldProjList,List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap, Map<Id,pse__Proj__c> newProjMap){
        Map<Id, pse__Proj__c> projMap = new Map<Id, pse__Proj__c>([SELECT Id, pse__Project_Manager__r.pse__Salesforce_User__c,psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c,pse__Opportunity_Owner__c 
                                                                   FROM pse__Proj__c WHERE Id IN :newProjMap.keySet()]);
        //<T21> - Start      
        //Querying the sum of Product Allocation Percentage in each project                                                     
        AggregateResult[] totalSplitPercentSum = [SELECT psa_pm_Project__c,SUM(PSA_PM_Product_Split__c) totalSplitPercent FROM psa_pm_Solution_Type__c WHERE psa_pm_Project__c IN :newProjMap.keyset() GROUP BY psa_pm_Project__c];
        Map<Id, Decimal> mapTotalSplitPercent = new Map<Id, Decimal>();

        //Adding the Project wise sum of Product Split percentage into the map
        for( AggregateResult ar : totalSplitPercentSum){
            mapTotalSplitPercent.put((Id)ar.get('psa_pm_Project__c'),(Decimal)ar.get('totalSplitPercent'));
        }

        //Validation error if the Ready for Ops Review is check but the sum of Product Allocation percentage of all the solution types if not equal to 100
        for(pse__Proj__c proj : newProjList){
            if(oldProjMap.get(proj.Id).PSA_PM_Ready_for_Ops_Review__c!= proj.PSA_PM_Ready_for_Ops_Review__c && proj.PSA_PM_Ready_for_Ops_Review__c && mapTotalSplitPercent.get(proj.Id)!=100){
                proj.addError('The sum of Product Allocation % of all Solution Types must equal 100%. Please review!');
            }
        }
        //<T21> - End

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        oppMap = getOppMapOfProjects(newProjList);
        if(oppMap.size()>0){
            for(pse__Proj__c proj : newProjList){
                if(((proj.pse__Opportunity__c <> oldProjMap.get(proj.Id).pse__Opportunity__c) ||(proj.pse__Is_Billable__c!=oldProjMap.get(proj.Id).pse__Is_Billable__c && proj.pse__Is_Billable__c)) 
                   && (oppMap.containsKey(proj.pse__Opportunity__c)) && (oppMap.get(proj.pse__Opportunity__c).pse__Projects__r.size() != 0) && 
                   (proj.psa_om_Interlock__c == null)){
                       for(pse__Proj__c existingProjRec : oppMap.get(proj.pse__Opportunity__c).pse__Projects__r){ // Tag <04>
                           if(existingProjRec.pse__Is_Billable__c){
                               proj.addError('Billable project is already associated with this Opportunity'); 
                           }
                       }
                   }
            }
        }
        
        for(pse__Proj__c proj : newProjList){
            if(proj.Name <> oldProjMap.get(proj.Id).Name && 
                !(FeatureManagement.checkPermission('PSA_Project_Name_Edit')) && 
                UserInfo.getUserId() != projMap.get(proj.Id).pse__Project_Manager__r.pse__Salesforce_User__c &&
                UserInfo.getUserId() != projMap.get(proj.Id).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c){                    
                    proj.addError('You can not edit Project Name');
            }
            
            if((proj.psa_pm_Journey__c <> oldProjMap.get(proj.Id).psa_pm_Journey__c) && 
               (!(FeatureManagement.checkPermission('PSA_Operations') || FeatureManagement.checkPermission('PSA_Deal_Desk'))) && //<T25>
               UserInfo.getUserId() != projMap.get(proj.Id).pse__Opportunity_Owner__c && 
               UserInfo.getUserId() != projMap.get(proj.Id).pse__Project_Manager__r.pse__Salesforce_User__c &&
               UserInfo.getUserId() != projMap.get(proj.Id).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c){
                proj.addError('Journey can not be changed by current user. Opportunity Owner or a member of the Operations team can assist.');
            }
            
            if((proj.psa_pm_Project_Category__c <> oldProjMap.get(proj.Id).psa_pm_Project_Category__c) && 
            (!(FeatureManagement.checkPermission('PSA_Operations') || FeatureManagement.checkPermission('PSA_Deal_Desk'))) && //<T25>
               UserInfo.getUserId() != projMap.get(proj.Id).pse__Project_Manager__r.pse__Salesforce_User__c &&
               UserInfo.getUserId() != projMap.get(proj.Id).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c &&
               UserInfo.getUserId() != projMap.get(proj.Id).pse__Opportunity_Owner__c){
                proj.addError('Project Category cannot be changed by current user. Portfolio Manager, Opportunity Owner and Project Manager can change the Category.Operations team can also assist.');
            }
        }           
    }
    
    /**
* @description - This method is invoked on Before Insert to populate Project fields.
* @param projList - list of new Projects
* @throws exception - NA
*/
    public void defaultProjectFieldValOnInsert(List<pse__Proj__c> projList){
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,SBQQ__Quote__c> oppIDQuoteMap = new Map<Id,SBQQ__Quote__c>();
        Set<String> busUnitOfQuotes = new Set<String>();
        Map<String,psa_pm_Business_Unit__c> busUnitMap = new Map<String,psa_pm_Business_Unit__c>();
        
        oppMap = getOppMapOfProjects(projList); 
        accMap = getAccountMapOfProjects(projList);        
        populateAENotRequiredReason(projList, null);//<T18>
        populateProjectSponsor(projList);//<T27>
        //From Opportunity Map - fetch the Map<OppId,PrimaryQuoteRec>
        
        if(oppMap.size()>0){
            oppIDQuoteMap = getQuoteMapFromOpp(oppMap.keySet());
        }
        
        if(oppIDQuoteMap.size()>0){
            for(SBQQ__Quote__c quotRec : oppIDQuoteMap.values()){
                if(quotRec.Business_Unit__c <> null){
                    busUnitOfQuotes.add(quotRec.Business_Unit__c);
                }
            }
            if(busUnitOfQuotes.size()>0){
                busUnitMap = getBusUnitMap(busUnitOfQuotes);
            }
        }
        for(pse__Proj__c projRec : projList){
            //<T18> - Start  "At Risk" checkbox to auto-check the box if any status field is set to Red 
            if(riskStatusList.contains(projRec.pse__Project_Status__c) || riskStatusList.contains(projRec.pse__Financial_Status__c) || riskStatusList.contains(projRec.pse__Schedule_Status__c) || riskStatusList.contains(projRec.pse__Scope_Status__c) || riskStatusList.contains(projRec.PSA_PM_Resources__c) || riskStatusList.contains(projRec.psa_Technical_Quality_Status__c) || riskStatusList.contains(projRec.psa_Overall_Project_Status_Trend__c)){
                projRec.psa_pm_At_Risk__c = true;
            }
            //Once the field "Request for Delivery Complete" is checked. The Project stage will be set as "Delivery Complete"
            if(projRec.Request_for_Delivery_Complete__c){
                projRec.pse__Stage__c = 'Delivery Complete';
            }
            //<T18> - End
            if(projRec.pse__Project_Manager__c <> null){
                projRec.psa_pm_Portfolio_Manager__c = projRec.pse__Project_Manager__c;
            }
            if(projRec.pse__Billings__c <> null && projRec.pse__Bookings__c <> null && projRec.pse__Billings__c > 0 && projRec.pse__Bookings__c >0){
                projRec.psa_pm_PercentComplete__c = (projRec.pse__Billings__c /projRec.pse__Bookings__c) * 100;
            }
            if(projRec.pse__Project_Type__c == null){
                projRec.pse__Project_Type__c = 'Customer Project';
            }
            
            if(projRec.pse__Is_Active__c == false && projRec.pse__Project_Type__c <> 'Internal'){
                projRec.pse__Is_Active__c = true;
            }
            
            // Populate Field from Opportunity.
            if(oppMap.containsKey(projRec.pse__Opportunity__c)){
                
                if(projRec.psa_om_Estimated_Begin_Date__c == null && oppMap.get(projRec.pse__Opportunity__c).psa_om_Start_Date__c != null){
                    projRec.psa_om_Estimated_Begin_Date__c = oppMap.get(projRec.pse__Opportunity__c).psa_om_Start_Date__c;
                }
                if(projRec.psa_om_Estimated_End_Date__c == null && oppMap.get(projRec.pse__Opportunity__c).psa_om_End_Date__c != null){
                    projRec.psa_om_Estimated_End_Date__c = oppMap.get(projRec.pse__Opportunity__c).psa_om_End_Date__c;
                }
                if(projRec.psa_pm_Project_Sub_Type__c == null && oppMap.get(projRec.pse__Opportunity__c).PSA_OM_Project_Type__c != null){
                    projRec.psa_pm_Project_Sub_Type__c = oppMap.get(projRec.pse__Opportunity__c).PSA_OM_Project_Type__c;
                }                
                
                if(projRec.PSA_OM_IPS_Package__c == null && oppMap.get(projRec.pse__Opportunity__c).psa_om_IPS_Package__c != null){
                    projRec.PSA_OM_IPS_Package__c = oppMap.get(projRec.pse__Opportunity__c).psa_om_IPS_Package__c;
                } 
                
                if((projRec.psa_pm_Journey__c == '' || projRec.psa_pm_Journey__c == null) && oppMap.get(projRec.pse__Opportunity__c).Sales_Journey__c != null){
                    projRec.psa_pm_Journey__c = oppMap.get(projRec.pse__Opportunity__c).Sales_Journey__c;
                }
                
                if(projRec.pse__Region__c == null && oppMap.get(projRec.pse__Opportunity__c).pse__Region__c != null){
                    projRec.pse__Region__c = oppMap.get(projRec.pse__Opportunity__c).pse__Region__c;
                } 
                
                if(projRec.pse__Practice__c == null && oppMap.get(projRec.pse__Opportunity__c).pse__Practice__c != null){
                    projRec.pse__Practice__c = oppMap.get(projRec.pse__Opportunity__c).pse__Practice__c;
                } 
                
                if(projRec.pse__Group__c == null && oppMap.get(projRec.pse__Opportunity__c).pse__Group__c != null){
                    projRec.pse__Group__c = oppMap.get(projRec.pse__Opportunity__c).pse__Group__c;
                } 

                if(oppMap.get(projRec.pse__Opportunity__c).CurrencyIsoCode != null){
                    projRec.CurrencyIsoCode = oppMap.get(projRec.pse__Opportunity__c).CurrencyIsoCode;
                }
            }
            //Quote fields logic Start. 
            if(oppIDQuoteMap.containsKey(projRec.pse__Opportunity__c)){               
                
                SBQQ__Quote__c quoteRec = oppIDQuoteMap.get(projRec.pse__Opportunity__c);
                //READ ONLY FIELD FROM QUOTE
                projRec.PSA_OM_Planned_Margin__c = quoteRec.PSA_OM_Planned_Margin__c;
                projRec.PSA_OM_Customer_Signoff__c = quoteRec.PSA_OM_Customer_Signoff__c;
                projRec.PSA_OM_Budget_Hours__c = quoteRec.PSA_OM_Budget_Hours__c;   
                projRec.psa_Service_Units__c = quoteRec.psa_Service_Units__c;//<T19>
                projRec.psa_pm_Payment_Terms__c = quoteRec.SBQQ__PaymentTerms__c; 
                projRec.PSA_Primary_Quote__c =  quoteRec.Id;
                projRec.PSA_ERP_Bill_To_Customer_Id__c =  quoteRec.BillToAccount__r.Peoplesoft_External_ID__c;
                projRec.PSA_ERP_Bill_To_Contact_Id__c =  quoteRec.BillToContact__r.Peoplesoft_External_ID__c;
                projRec.PSA_ERP_Ship_To_Customer_Id__c =  quoteRec.ShiptToAccount__r.Peoplesoft_External_ID__c;
                projRec.PSA_ERP_Ship_To_Contact_Id__c =  quoteRec.ShipToContact__r.Peoplesoft_External_ID__c;
                projRec.pse__Planned_Hours__c = quoteRec.PSA_OM_Budget_Hours__c; //<T17>
                if(busUnitMap!=null && busUnitMap.containsKey(quoteRec.Business_Unit__c)){
                    projRec.psa_pm_Business_Unit__c = busUnitMap.get(quoteRec.Business_Unit__c).Id; 
                }
                
                // POPULATE BILL TO FIELDS FROM QUOTE -  user-input takes precendence over automation logic - confirmed by Sarojini
                if(projRec.PSA_OM_Bill_to_Account__c == null){
                    projRec.PSA_OM_Bill_to_Account__c = quoteRec.BillToAccount__c;
                }  
                if(projRec.PSA_OM_Bill_To_Contact__c== null){
                    projRec.PSA_OM_Bill_To_Contact__c = quoteRec.BillToContact__c;
                }  
                if(projRec.PSA_OM_Bill_To_Name__c == null){
                    projRec.PSA_OM_Bill_To_Name__c = quoteRec.SBQQ__BillingName__c;
                }  
                if(projRec.PSA_OM_Bill_To_Street__c == null){
                    projRec.PSA_OM_Bill_To_Street__c = quoteRec.SBQQ__BillingStreet__c;
                }  
                if(projRec.PSA_OM_Bill_To_City__c == null){
                    projRec.PSA_OM_Bill_To_City__c = quoteRec.SBQQ__BillingCity__c;
                }  
                if(projRec.PSA_OM_Bill_To_State__c == null){
                    projRec.PSA_OM_Bill_To_State__c = quoteRec.SBQQ__BillingState__c;
                }  
                if(projRec.PSA_OM_Bill_To_Country__c == null){
                    projRec.PSA_OM_Bill_To_Country__c = quoteRec.SBQQ__BillingCountry__c;
                }  
                if(projRec.PSA_OM_Bill_To_Postal_Code__c == null){
                    projRec.PSA_OM_Bill_To_Postal_Code__c = quoteRec.SBQQ__BillingPostalCode__c;
                }  
                if(projRec.PSA_OM_ERP_Bill_to_Name_ID__c == null){
                    projRec.PSA_OM_ERP_Bill_to_Name_ID__c = quoteRec.BillingName_PSFTID__c;
                }  
                if(projRec.PSA_OM_ERP_Billing_Site_ID__c == null){
                    projRec.PSA_OM_ERP_Billing_Site_ID__c = quoteRec.BillingAddress_PSFTID__c;
                } 
                if(projRec.PSA_OM_Billing_Email__c == null){
                    projRec.PSA_OM_Billing_Email__c = quoteRec.Bill_to_Email__c;
                } 
                //<T13>
                if(projRec.PSA_OM_Bill_To_Additional_Reference_Info__c == null){
                    projRec.PSA_OM_Bill_To_Additional_Reference_Info__c = quoteRec.Bill_To_Additional_Reference_Info__c;
                } 
                //</T13>
                //POPULATE SHIP TO FIELD FROM QUOTE
                if(projRec.PSA_OM_Ship_to_Account__c == null){
                    projRec.PSA_OM_Ship_to_Account__c = quoteRec.ShiptToAccount__c;
                } 
                if(projRec.PSA_OM_Ship_to_Contact__c == null){
                    projRec.PSA_OM_Ship_to_Contact__c = quoteRec.ShipToContact__c;
                } 
                if(projRec.PSA_OM_Ship_To_Name__c == null){
                    projRec.PSA_OM_Ship_To_Name__c = quoteRec.SBQQ__ShippingName__c;
                } 
                if(projRec.PSA_OM_Shipping_Email__c == null){
                    projRec.PSA_OM_Shipping_Email__c = quoteRec.Shipping_Email__c;
                } 
                if(projRec.PSA_OM_Ship_To_Street__c == null){
                    projRec.PSA_OM_Ship_To_Street__c = quoteRec.SBQQ__ShippingStreet__c;
                } 
                if(projRec.PSA_OM_Ship_To_City__c == null){
                    projRec.PSA_OM_Ship_To_City__c = quoteRec.SBQQ__ShippingCity__c;
                } 
                if(projRec.PSA_OM_Ship_To_State__c == null){
                    projRec.PSA_OM_Ship_To_State__c = quoteRec.SBQQ__ShippingState__c;
                } 
                if(projRec.PSA_OM_Ship_To_Country__c == null){
                    projRec.PSA_OM_Ship_To_Country__c = quoteRec.SBQQ__ShippingCountry__c;
                } 
                if(projRec.PSA_OM_Ship_To_Postal_Code__c == null){
                    projRec.PSA_OM_Ship_To_Postal_Code__c = quoteRec.SBQQ__ShippingPostalCode__c;
                } 
                if(projRec.PSA_OM_ERP_Ship_to_Name_ID__c == null){
                    projRec.PSA_OM_ERP_Ship_to_Name_ID__c = quoteRec.ShippingName_PSFTID__c;
                } 
                if(projRec.PSA_OM_ERP_Shipping_Site_ID__c == null){
                    projRec.PSA_OM_ERP_Shipping_Site_ID__c = quoteRec.ShippingAddress_PSFTID__c;
                } 
                //<T13>
                if(projRec.PSA_OM_Ship_To_Additional_Reference_Info__c == null){
                    projRec.PSA_OM_Ship_To_Additional_Reference_Info__c = quoteRec.Ship_To_Additional_Reference_Info__c;
                } 
                //</T13>
                //<T23>
                if(projRec.PO_Number__c == null){
                    projRec.PO_Number__c = quoteRec.PO__c;
                }
                //</T23>
            }               
        }   

        //<T7>
        Map<Id,pse__Proj__c> parentProjMap = new Map<Id,pse__Proj__c>();
        List<pse__Proj__c> childProjList = new List<pse__Proj__c>();
        List<Id> parentProjList = new List<Id>();
        
        for(pse__Proj__c proj : projList){
            if(proj.pse__Parent_Project__c != null){
                parentProjList.add(proj.pse__Parent_Project__c);
                childProjList.add(proj);
            }
        }

        if(parentProjList.size() > 0){
            parentProjMap = getParentProjMap(parentProjList);
            for(pse__Proj__c proj : projList){
                if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Parent_Project__c == null){                    
                    proj.PSA_OM_IPS_Package__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_IPS_Package__c;
                    proj.pse__Region__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Region__c;
                    proj.pse__Practice__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Practice__c;
                    proj.pse__Group__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Group__c;
                    proj.pse__Account__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Account__c;
                    proj.psa_pm_Portfolio_Manager__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Portfolio_Manager__c;
                    proj.pse__Project_Manager__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Project_Manager__c;
                    proj.psa_pm_Journey__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Journey__c;
                    proj.CurrencyIsoCode = parentProjMap.get(proj.pse__Parent_Project__c).CurrencyIsoCode;
                    proj.pse__Is_Billable__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Is_Billable__c;
                    proj.pse__Planned_Hours__c = 0;//T9
                    proj.psa_pm_Payment_Terms__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Payment_Terms__c;//T9
                    proj.pse__Stage__c = 'Planned'; //Default to Planned
                    proj.pse__Billing_Type__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Billing_Type__c;
                    proj.pse__Project_Type__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Project_Type__c;
                    proj.psa_pm_Project_Sub_Type__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Project_Sub_Type__c;
                    proj.psa_pm_Business_Unit__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Business_Unit__c;
                    proj.psa_pm_Time_Approval_Method__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Time_Approval_Method__c;
                    proj.psa_pm_Expense_Approval_Method__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Expense_Approval_Method__c;
                    proj.PSA_OM_Bill_to_Account__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_to_Account__c;
                    proj.PSA_OM_Bill_To_City__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_City__c;
                    proj.PSA_OM_Bill_To_Country__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_Country__c;
                    proj.PSA_OM_Bill_To_Name__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_Name__c;
                    proj.PSA_OM_Bill_To_Postal_Code__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_Postal_Code__c;
                    proj.PSA_OM_Bill_To_State__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_State__c;
                    proj.PSA_OM_Bill_To_Street__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_Street__c;
                    proj.PSA_OM_Ship_To_Street__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_Street__c;
                    proj.PSA_OM_Ship_To_State__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_State__c;
                    proj.PSA_OM_Ship_To_Postal_Code__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_Postal_Code__c;
                    proj.PSA_OM_Ship_To_Name__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_Name__c ;
                    proj.PSA_OM_Ship_To_Country__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_Country__c;
                    proj.PSA_OM_Ship_To_City__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_City__c;
                    proj.PSA_OM_Ship_to_Account__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_to_Account__c;
                    //<T26>-Start
                    proj.psa_RMO_Contact__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_RMO_Contact__c;
                    proj.psa_Rev_Ops_Contact__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_Rev_Ops_Contact__c;//<T26>-End
                    //<T13>
                    proj.PSA_OM_Bill_To_Additional_Reference_Info__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Bill_To_Additional_Reference_Info__c;
                    proj.PSA_OM_Ship_To_Additional_Reference_Info__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_Ship_To_Additional_Reference_Info__c;
                    //</T13>
                    //<T22>
                    proj.PSA_Adoption_Event_Not_Required_Reason__c='Parent Project has an Adoption Event';//</T22>
                    proj.Project_Sponsor__c = parentProjMap.get(proj.pse__Parent_Project__c).Project_Sponsor__c;//<T27>
                    proj.pse__Opportunity_Owner__c = UserInfo.getUserId();//T11
                }
                else{
                    proj.addError('You cannot create a third-level child Project.');
                }
            }
        }
        //</T7>   
    }
    
    /**
    * @description - This method is invoked on Before Update to populate project fields on on Project Update.
    * @param oldProjList - list of old Projects
    * @param newProjList - list of new Projects
    * @param oldProjMap - map of old Projects
    * @param newProjMap - map of new Projects
    * @throws exception - NA
    */
    public void defaultProjectFieldValOnUpdate(List<pse__Proj__c> oldProjList,List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap, Map<Id,pse__Proj__c> newProjMap){
        Map<Id,Contact> conMap = new Map<Id,Contact>(); 
        conMap = getContactMapOfProjects(oldProjList);
        populateAENotRequiredReason(newProjList, oldProjMap);//<T18>
        for(pse__Proj__c projRec : newProjList){           
            pse__Proj__c oldProj = oldProjMap.get(projRec.Id);
            if((oldProj.pse__Project_Manager__c <> null) && 
               (projRec.pse__Project_Manager__c <> oldProj.pse__Project_Manager__c) 
               && (conMap.size()>0)){
                   projRec.psa_pm_Previous_Project_Manager_User__c = conMap.get(oldProj.pse__Project_Manager__c).pse__Salesforce_User__c;
               } 
            if(oldProj.pse__Is_Billable__c!=projRec.pse__Is_Billable__c){
                projRec.pse__Exclude_From_Billing__c = !projRec.pse__Is_Billable__c;
            } 
            
            if(projRec.pse__Billings__c <> null && projRec.pse__Bookings__c <> null && projRec.pse__Billings__c > 0 && projRec.pse__Bookings__c >0){
                projRec.psa_pm_PercentComplete__c = (projRec.pse__Billings__c /projRec.pse__Bookings__c) * 100;
            }
            //<T18> - Start
            if(oldProj.pse__Project_Status__c != projRec.pse__Project_Status__c || oldProj.pse__Financial_Status__c != projRec.pse__Financial_Status__c || oldProj.pse__Schedule_Status__c != projRec.pse__Schedule_Status__c || oldProj.pse__Scope_Status__c != projRec.pse__Scope_Status__c || oldProj.PSA_PM_Resources__c != projRec.PSA_PM_Resources__c || oldProj.psa_Technical_Quality_Status__c != projRec.psa_Technical_Quality_Status__c || oldProj.psa_Overall_Project_Status_Trend__c != projRec.psa_Overall_Project_Status_Trend__c){
                //"At Risk" checkbox to auto-check the box if any status field is set to Red 
                if(riskStatusList.contains(projRec.pse__Project_Status__c) || riskStatusList.contains(projRec.pse__Financial_Status__c) || riskStatusList.contains(projRec.pse__Schedule_Status__c) || riskStatusList.contains(projRec.pse__Scope_Status__c) || riskStatusList.contains(projRec.PSA_PM_Resources__c) || riskStatusList.contains(projRec.psa_Technical_Quality_Status__c) || riskStatusList.contains(projRec.psa_Overall_Project_Status_Trend__c)){
                    projRec.psa_pm_At_Risk__c = true;
                }
                //uncheck "At Risk" checkbox if all status fields are not Red
                else{
                    projRec.psa_pm_At_Risk__c = false;
                }            
            }            
            //Once the field "Request for Delivery Complete" is checked. The Project stage will be set as "Delivery Complete"
            if(oldProj.Request_for_Delivery_Complete__c != projRec.Request_for_Delivery_Complete__c && projRec.Request_for_Delivery_Complete__c){
                projRec.pse__Stage__c = 'Delivery Complete';
                projRec.ByPass_Validation_DateTime__c = System.now();
            }
            //<T18> - End
            //<T20> - Start
            if(oldProj.pse__Stage__c != projRec.pse__Stage__c && projRec.pse__Stage__c != 'Planned' && projRec.psa_pm_Date_Validated_by_OPS__c == null ){
                projRec.psa_pm_Date_Validated_by_OPS__c = System.today();
                projRec.ByPass_Validation_DateTime__c = System.now();
            }
            //<T20> - End
        }       
    }
    
    /**
    * @description - This method is invoked on After Insert to handle After Project creation.
    * @param projList - list of new Projects
    * @param projMap - map of new Projects
    * @throws exception - NA
    */
    public void handleAfterProjInsertActions(List<pse__Proj__c> projList, Map<Id,pse__Proj__c> projMap){
        
        Map<Id,Id> oppProjIdMap = new Map<Id,Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        oppMap = getOppMapOfProjects(projList);
        for(pse__Proj__c proj : projList){
            if(proj.pse__Opportunity__c <> null && 
               oppMap.containsKey(proj.pse__Opportunity__c) && oppMap.get(proj.pse__Opportunity__c).pse__Resource_Requests__r.size() > 0){
                   oppProjIdMap.put(proj.pse__Opportunity__c,proj.Id);
               }
        }
        
        if(oppProjIdMap.size()>0){
            updateResReqRecs(oppProjIdMap,'Opportunity');
        }        
    }
//<T27>
/**
* @description - This method is invoked on Before Insert to auto populate the Project Sponsor field based on the Sub Region
* @param newProjList - list of new Projects
* @throws exception - NA
*/ 
public void populateProjectSponsor(List<pse__Proj__c> newProjList){
    Set<Id> opptyIds = new Set<Id>();
    Map<Id,String> projSubRegionMap = new Map<Id,String>();//Store the map of Project Id and Sub-region 
    Map<String,String> subRegionSponsorMap = new Map<String,String>(); //Store the map of Sub-region and Sponsor 
    //Store the Oppty Ids
    for(pse__Proj__c proj : newProjList){
        if(proj.pse__Opportunity__c != null){
            opptyIds.add(proj.pse__Opportunity__c);
        }
    }
    //Get the Sub Regions for the Opportunities
    Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([SELECT Id,Territory2.Sub_Region__c FROM Opportunity WHERE Id IN :opptyIds AND Territory2.Sub_Region__c != NULL]);
    
    //Get the sponsors List from the PSA Approval Matrix
    List<PSA_Approval_Matrix__c> psaApprovalList = [SELECT Sub_Region__c, Sponsor__c FROM PSA_Approval_Matrix__c];
    for(PSA_Approval_Matrix__c matrix : psaApprovalList){
        subRegionSponsorMap.put(matrix.Sub_Region__c, matrix.Sponsor__c);
    }
    //Map the Sponsor to the Project based on the stored map
    for(pse__Proj__c proj : newProjList){
        String subRegion = opptyMap.get(proj.pse__Opportunity__c)?.Territory2?.Sub_Region__c;
        if(String.isNotBlank(subRegion)){
            proj.Project_Sponsor__c = subRegionSponsorMap.get(subRegion);
        }
    }
}
//</T27>
//<T18> - Start
/**
* @description - This method is invoked on Before Insert and Before Update to auto populate the Adoption Event Not Required Reason field based on the project type
* @param newProjList - list of new Projects
* @param oldProjMap - map of old Projects
* @throws exception - NA
*/ 
    public void populateAENotRequiredReason(List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap){
        List<PSA_Project_AE_Mapping__mdt> projAEList = [SELECT Project_Type__c,AE_Not_Required_Reason__c FROM PSA_Project_AE_Mapping__mdt];
        Map<String,String> projAEMap = new Map<String,String>();
        for(PSA_Project_AE_Mapping__mdt projAE : projAEList){
            projAEMap.put(projAE.Project_Type__c,projAE.AE_Not_Required_Reason__c);
        }
        for(pse__Proj__c proj : newProjList){
            if(oldProjMap == null || (oldProjMap.get(proj.Id).psa_pm_Project_Sub_Type__c != proj.psa_pm_Project_Sub_Type__c)){
                proj.PSA_Adoption_Event_Not_Required_Reason__c = projAEMap.get(proj.psa_pm_Project_Sub_Type__c);
            }
        }
    }
//</T18> - End
//<T7>
/**
* @description - This method is invoked on After Insert to handle After Project creation.
* @param newProjList - list of new Projects
* @throws exception - NA
*/ 
    public void createChildProjectOpty(List<pse__Proj__c> newProjList){
        Map<Id,pse__Proj__c> parentProjMap = new Map<Id,pse__Proj__c>();
        Map<Id,pse__Proj__c> childProjMap = new Map<Id,pse__Proj__c>();
        List<Id> parentProjList = new List<Id>();
        for(pse__Proj__c proj : newProjList){
            if(proj.pse__Parent_Project__c != null){
                parentProjList.add(proj.pse__Parent_Project__c);
                childProjMap.put(proj.Id,proj);
            }
        }

        if(childProjMap.size() > 0){
            parentProjMap = getParentProjMap(parentProjList);
            for(pse__Proj__c proj : [SELECT Id,pse__Parent_Project__c,pse__Start_Date__c,pse__End_Date__c FROM pse__Proj__c WHERE Id IN :childProjMap.keySet()]){
                if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Parent_Project__c == null){ 
                    Opportunity opp = new Opportunity();
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Opportunity__r.Name != null) opp.Name = 'CP - ' + parentProjMap.get(proj.pse__Parent_Project__c).pse__Opportunity__r.Name;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Region__c != null) opp.pse__Region__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Region__c;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Practice__c != null) opp.pse__Practice__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Practice__c;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Group__c != null) opp.pse__Group__c = parentProjMap.get(proj.pse__Parent_Project__c).pse__Group__c;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Project_Type__c != null) opp.PSA_OM_Project_Type__c = parentProjMap.get(proj.pse__Parent_Project__c).psa_pm_Project_Sub_Type__c;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_IPS_Package__c != null) opp.psa_om_IPS_Package__c = parentProjMap.get(proj.pse__Parent_Project__c).PSA_OM_IPS_Package__c;
                    if(parentProjMap.get(proj.pse__Parent_Project__c).pse__Account__c != null) opp.AccountId = parentProjMap.get(proj.pse__Parent_Project__c).pse__Account__c;
                    opp.psa_om_Start_Date__c = proj.pse__Start_Date__c; 
                    opp.psa_om_End_Date__c = proj.pse__End_Date__c;
                    opp.StageName = 'Identify';
                    opp.CloseDate = date.today();
                    opp.pse__Primary_Project__c = proj.Id;
                    uow.registerNew(opp);
                    uow.registerDirty(proj,pse__Proj__c.pse__Opportunity__c,opp);
                }
            }
        }        
    }
    /**
    * @description - This method commits the entire DML to the database using UOW framework
    * @param newList - list of sObject Ids
    * @throws exception - NA
    */
    public void callCommitMethod(List<SObject> newList){
       
            try{
                uow.commitWork();
            }
            catch(Exception e){
                gam.CreateExceptionRecords('Error caused from psa_pm_ProjectTriggerHelper class', e.getMessage(),newList[0].id);
            }
    }

    /**
    * @description - This method is invoked on to get the Parent Project details in a map
    * @param lstProjectIds - list of Project Ids
    * @return Map<Id,pse__Proj__c>
    * @throws exception - NA
    */
    public Map<Id,pse__Proj__c> getParentProjMap(List<Id> lstProjectIds){
        
        Map<Id,pse__Proj__c> parentProjectMap = new Map<Id,pse__Proj__c>();
        //<T13> - Added two new fields on the below select query
        for(pse__Proj__c parentProj : [SELECT Id,pse__Parent_Project__c,pse__Opportunity__r.Name,pse__Region__c,pse__Practice__c,pse__Group__c,pse__Project_Type__c,PSA_OM_IPS_Package__c,
                                        pse__Account__c,PSA_PM_Opportunity_Probability__c,PSA_OM_Bill_to_Account__c,PSA_OM_Bill_To_City__c,PSA_OM_Bill_To_Country__c,PSA_OM_Bill_To_Name__c,
                                        PSA_OM_Bill_To_Postal_Code__c,PSA_OM_Bill_To_State__c,PSA_OM_Bill_To_Street__c,psa_pm_Portfolio_Manager__c,pse__Project_Manager__c,psa_pm_Journey__c,
                                        CurrencyIsoCode,pse__Is_Billable__c,pse__Planned_Hours__c,psa_pm_Payment_Terms__c,pse__Stage__c,pse__Billing_Type__c,psa_pm_Project_Sub_Type__c,psa_pm_Business_Unit__c,
                                        psa_pm_Time_Approval_Method__c,psa_pm_Expense_Approval_Method__c,PSA_OM_Ship_To_Street__c,PSA_OM_Ship_To_State__c,PSA_OM_Ship_To_Postal_Code__c,Project_Sponsor__c,
                                        PSA_OM_Ship_To_Name__c,PSA_OM_Ship_To_Country__c,PSA_OM_Ship_To_City__c,PSA_OM_Ship_to_Account__c,PSA_OM_Bill_To_Additional_Reference_Info__c,PSA_OM_Ship_To_Additional_Reference_Info__c,psa_RMO_Contact__c,psa_Rev_Ops_Contact__c
                                        FROM pse__Proj__c WHERE Id IN :lstProjectIds]){
            parentProjectMap.put(parentProj.Id, parentProj);
        }

        return parentProjectMap;
    }
//</T7>

//<T10>
/**
* @description - This method is invoked on After Insert to handle the name change after the Project creation.
* @param newMap - map of new Projects
* @param newList - list of new Projects
* @throws exception - NA
*/ 
public void updateProjectName(Map<Id,pse__Proj__c> newMap,List<pse__Proj__c> newList){
    for(pse__Proj__c project : [SELECT Id,Name,pse__Project_ID__c FROM pse__Proj__c WHERE Id IN :newMap.keySet()]){
        if(project.pse__Project_ID__c != null){
            //<T16>
            String projName = (String)project.Name;
            if(project.Name.length() > 70){
                newList[0].addError('Project name has exceeded the character limit of 70. Project Name has '+ project.Name.length()  +' characters.' );
            }
            //</T16>
            if(!projName.startsWith(project.pse__Project_ID__c)){
                project.Name = project.pse__Project_ID__c + ' ' + project.Name;
                uow.registerDirty(project,new List<SObjectField> { pse__Proj__c.Name });
            }
        }
    }
}
//</T10>

    /**
    * @description - Method invoked on After Insert to created BudgetRecords
    * @param projList - list of new Projects
    * @param projMap - map of new Projects
    * @throws exception - NA
    */
    public void createBudgetRecs(List<pse__Proj__c> projList, Map<Id,pse__Proj__c> projMap){
        List<pse__Proj__c> baseProjList = new List<pse__Proj__c>([SELECT Id,Name,pse__Opportunity__c,pse__Account__c,pse__Opportunity__r.Professional_Services_Total__c,pse__Start_Date__c,pse__Project_Type__c,pse__Is_Active__c,
                                                                  pse__Opportunity__r.Name,pse__Opportunity__r.AccountId,CurrencyIsoCode
                                                                  FROM pse__Proj__c
                                                                  WHERE ID IN :projMap.keySet()]);
        //<T15> - Start
        Decimal totalExpenseAmount = 0;
        Map<String,Decimal> mapCurrencyExcRate = new Map<String,Decimal>();
        Map<Id,Decimal> mapOpptyIdUnitPrice = new Map<Id,Decimal>();
        Set<Id> opptyIdSet = new Set<Id>();
        //Get unique set of Opportunity Ids from the Project List
        for(pse__Proj__c proj: baseProjList){
            opptyIdSet.add(proj.pse__Opportunity__c);
        }
        //Get the Sum of Expense Amount from the Opportunity Products and group the result by Opportunity
        AggregateResult[] agrResult = [SELECT SUM(UnitPrice) totalExpenseAmount,OpportunityId FROM OpportunityLineItem 
                                       WHERE OpportunityId IN :opptyIdSet 
                                       AND Product2.Name LIKE '%Expense%' AND Product2.Business_Unit__c = 'Professional Services' AND 
                                       Product2.IsActive = TRUE GROUP BY OpportunityId];
        //Create a map of Opportunity Id and Expense Amount
        for(AggregateResult ar : agrResult){
            mapOpptyIdUnitPrice.put((Id) ar.get('OpportunityId'), (Decimal) ar.get('totalExpenseAmount'));
        }
        //Get the Conversion Rate for the Currencies
        for(DatedConversionRate dcr : [SELECT Id,ConversionRate,IsoCode FROM DatedConversionRate WHERE StartDate = THIS_MONTH]){
            mapCurrencyExcRate.put(dcr.IsoCode, dcr.ConversionRate);
        }
        //</T15> - End
        if(baseProjList.size()>0){
            for(pse__Proj__c prjRec : baseProjList){
                if(prjRec.pse__Is_Active__c == true && prjRec.pse__Project_Type__c <>'Internal') {
                    pse__Budget__c budRec = new pse__Budget__c();
                    String budgetName = prjRec.pse__Opportunity__r?.Name;
                    budRec.Name = budgetName?.length() > 70 ? budgetName?.substring(0, 70)+' - '+'Budget' : budgetName +' - '+'Budget'; // Defaulting to Opportunity Name - <T16>
                    budRec.pse__Account__c = prjRec.pse__Opportunity__r?.AccountId;
                    budRec.pse__Project__c = prjRec.Id;
                    budRec.pse__Opportunity__c = prjRec.pse__Opportunity__c;
                    //<T15> - Start
                    if(mapOpptyIdUnitPrice.size() > 0 && mapOpptyIdUnitPrice.get(prjRec.pse__Opportunity__c) != null){       
                        //If the Project currency is not USD - multiply with the conversion rate
                        if(prjRec.CurrencyIsoCode != 'USD' && mapCurrencyExcRate.get(prjRec.CurrencyIsoCode) != null){
                            totalExpenseAmount = mapOpptyIdUnitPrice.get(prjRec.pse__Opportunity__c) * mapCurrencyExcRate.get(prjRec.CurrencyIsoCode);
                        }                 
                        else{
                            totalExpenseAmount = mapOpptyIdUnitPrice.get(prjRec.pse__Opportunity__c);
                        }
                        totalExpenseAmount = totalExpenseAmount.setScale(0,System.RoundingMode.CEILING);
                    }
                    //</T15> - End
                    if(prjRec.pse__Opportunity__r.Professional_Services_Total__c <> null){                        
                        budRec.pse__Expense_Amount__c = totalExpenseAmount; //<T15>
                        budRec.pse__Amount__c = prjRec.pse__Opportunity__r.Professional_Services_Total__c - totalExpenseAmount; //<T15>
                    }else{
                        budRec.pse__Amount__c = 0;
                    }                   
                    budRec.pse__Type__c = 'Customer Purchase Order';
                    budRec.pse__Status__c = 'Approved';
                    budRec.pse__Approved__c = true;
                    budRec.pse__Include_In_Financials__c = true;
                    budRec.pse__Effective_Date__c = prjRec.pse__Start_Date__c;
                    uow.registerNew(budRec);
                }                
            }
        }
    }
    
    /**
    * @description - Method invoked on After Insert to created Projec ShareRecords
    * @param projList - list of new Projects
    * @param projMap - map of new Projects
    * @throws exception - NA
    */
    public void checkForPMPermissions(List<pse__Proj__c> projList, Map<Id,pse__Proj__c> projMap){
        
        List<pse__Proj__c> projRecsToProcess = new List<pse__Proj__c>();
        List<pse__Proj__c> baseProjList = new List<pse__Proj__c>([SELECT Id,Name,pse__Opportunity__c,OwnerId,pse__Project_Manager__c,
                                                                  pse__Project_Manager__r.pse__Salesforce_User__c,psa_pm_Portfolio_Manager__c,
                                                                  psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c
                                                                  FROM pse__Proj__c
                                                                  WHERE ID IN :projList]);
        
        for(pse__Proj__c prjRec : baseProjList){ 
            if((prjRec.pse__Project_Manager__c <> null) && (prjRec.pse__Project_Manager__r.pse__Salesforce_User__c <> null) && (prjRec.OwnerId <> prjRec.pse__Project_Manager__r.pse__Salesforce_User__c)){
                projRecsToProcess.add(prjRec);
            }
            if((prjRec.psa_pm_Portfolio_Manager__c <> null) && (prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c <> null) && (prjRec.OwnerId <> prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c)){
                projRecsToProcess.add(prjRec);
            }
        }
        
        if(projRecsToProcess.size()>0){
            createProjShareRecs(projRecsToProcess);
        }
    }
    
    /**
    * @description - Method to Create Project Share records for the PM who is not the owner of the Project.
    * @param projToProcess - list of Projects whose PM is not the Owner.
    * @throws exception - NA
    */
    public static void createProjShareRecs(List<pse__Proj__c> projToProcess){
        Set<Id> processedProjRecs = new Set<Id>();        
        if(!projToProcess.isEmpty()){
            //<T12> - Logic to check if a project share record already exists for project manager/portfolio manager
            Map<Id, Set<Id>> projIdUserGroupIdMap = new Map<Id, Set<Id>>();
            List<pse__Proj__Share> projShareList = [SELECT ParentId, UserOrGroupId FROM pse__Proj__Share WHERE ParentId IN :projToProcess];
            for(pse__Proj__Share projShare : projShareList){
                if(!projIdUserGroupIdMap.containsKey(projShare.ParentId)){
                    projIdUserGroupIdMap.put(projShare.ParentId, new Set<Id> {projShare.UserOrGroupId});
                }
                else{
                    projIdUserGroupIdMap.get(projShare.ParentId).add(projShare.UserOrGroupId);
                }
            }
            //</T12>
            for(pse__Proj__c prjRec : projToProcess){ 
                if(!processedProjRecs.contains(prjRec.Id)){
                    //<T12> - Logic to check if a project share record already exists for project manager/portfolio manager
                    Set<Id> usergroupIdSet = new Set<Id>();
                    Integer userCount = 0;
                    if(projIdUserGroupIdMap.size() > 0){
                        usergroupIdSet = projIdUserGroupIdMap.get(prjRec.Id);
                        userCount = usergroupIdSet.size();
                    }
                    //</T12>
                    if(String.isNotBlank(prjRec.pse__Project_Manager__r.pse__Salesforce_User__c) &&  (userCount == 0 || (userCount > 0 && !usergroupIdSet.contains(prjRec.pse__Project_Manager__r.pse__Salesforce_User__c))) && prjRec.OwnerId <> prjRec.pse__Project_Manager__r.pse__Salesforce_User__c) //<T12> - Do not create sharing record for the Owner
                    {
                        pse__Proj__Share projShare = new pse__Proj__Share();
                        projShare.ParentId = prjRec.Id;
                        projShare.UserOrGroupId = prjRec.pse__Project_Manager__r.pse__Salesforce_User__c;
                        projShare.AccessLevel = 'Edit';
                        projShare.RowCause = rowCause; //T12 - Added to prevent deleting this record on Owner change
                        uow.registerNew(projShare);
                    }
                    // Tag
                    if(String.isNotBlank(prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c) && (userCount == 0 || (userCount > 0 && !usergroupIdSet.contains(prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c))) && prjRec.OwnerId <> prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c) //<T12> - Do not create sharing record for the Owner
                    {
                        pse__Proj__Share projShare = new pse__Proj__Share();
                        projShare.ParentId = prjRec.Id;
                        projShare.UserOrGroupId = prjRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c;
                        projShare.AccessLevel = 'Edit';
                        projShare.RowCause = rowCause; //T12 - Added to prevent deleting this record on Owner change
                        uow.registerNew(projShare);
                    }
                }
                processedProjRecs.add(prjRec.Id);
            }
        }
    }
    
    /**
    * @description - Method to Delete Project Share records.
    * @param oldPMSet - list of old PM Ids
    * @param projIdSet - list of Project Ids
    * @param userIdSet - list of User Ids
    * @throws exception - NA
    */
    public static void deleteProjShareRecs(Set<Id> oldPMSet,Set<Id> projIdSet, Set<Id> userIdSet){
        
        Set<Id> olduserId = new Set<Id>();       
        List<Contact> oldPMConList = new List<Contact>([SELECT Id,Name,pse__Salesforce_User__c FROM Contact WHERE ID IN :oldPMSet]);
        for(Contact conRec : oldPMConList){
            if(conRec.pse__Salesforce_User__c <> null){
                olduserId.add(conRec.pse__Salesforce_User__c);
            }
        }
        olduserId = (olduserId.size() == 0) ? userIdSet : olduserId; //<T12>
        List<pse__Proj__Share> baseProjShareRecs = new List<pse__Proj__Share>([SELECT Id,ParentId,UserOrGroupId,AccessLevel FROM pse__Proj__Share WHERE UserOrGroupId IN : olduserId AND ParentId IN :projIdSet AND RowCause = :rowCause]);
        
        if(baseProjShareRecs.size()>0){
            try{
                delete baseProjShareRecs;
            }         
            catch(Exception e){
                gam.CreateLogs('CLASS: psa_pm_ProjectTriggerHelper | METHOD: deleteProjShareRecs', baseProjShareRecs , 'baseProjShareRecs- Project SHARE Delete');
            }
        }
    }
    
    /**
    * @description - This method is invoked on After Update of Project records Update to check for PM Change
    * @param oldProjList - list of old Projects
    * @param newProjList - list of new Projects
    * @param oldProjMap - map of old Projects
    * @param newProjMap - map of new Projects
    * @throws exception - NA
    */
    public void checkForPMPermissionsOnUpdate(List<pse__Proj__c> oldProjList,List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap, Map<Id,pse__Proj__c> newProjMap){
        
        List<pse__Proj__c> projRecsToCreateShareRecs = new List<pse__Proj__c>();
        //List<pse__Proj__c> projRecsToDelShareRecs = new List<pse__Proj__c>();
        Set<Id> oldPMIds = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<pse__Proj__c> baseProjList = new List<pse__Proj__c>([SELECT Id,Name,pse__Opportunity__c,OwnerId,pse__Project_Manager__c,
                                                                  pse__Project_Manager__r.pse__Salesforce_User__c,psa_pm_Portfolio_Manager__c,
                                                                  psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c FROM pse__Proj__c
                                                                  WHERE ID IN :newProjList]);
        for(pse__Proj__c newProj : baseProjList){
            pse__Proj__c  oldProj = oldProjMap.get(newProj.Id); // Tag 2
            //if((oldProj.pse__Project_Manager__c <> newProj.pse__Project_Manager__c) && (newProj.pse__Project_Manager__r.pse__Salesforce_User__c <> newProj.OwnerId)){ //<T12> - Commented
            //If Project Manager is changed
            if(oldProj.pse__Project_Manager__c <> newProj.pse__Project_Manager__c){
                projRecsToCreateShareRecs.add(newProj);
                oldPMIds.add(oldProj.pse__Project_Manager__c);
            }
            // Tag 2
            //if((oldProj.psa_pm_Portfolio_Manager__c <> newProj.psa_pm_Portfolio_Manager__c) && (newProj.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c <> newProj.OwnerId)){ //<T12> - Commented
            //If Portfolio Manager is changed
            if(oldProj.psa_pm_Portfolio_Manager__c <> newProj.psa_pm_Portfolio_Manager__c){
                projRecsToCreateShareRecs.add(newProj);
                oldPMIds.add(oldProj.psa_pm_Portfolio_Manager__c);
            }
            //<T12>
            //When the Project Owner is changed - create ProjectTeam(Custom) sharing record if the Old Project Owner is either a Project or Portfolio Manager 
            if(oldProj.OwnerId <> newProj.OwnerId){
                projRecsToCreateShareRecs.add(newProj);                
                oldPMIds.clear();
            }
            //When the Project Owner is changed and the Old Project Owner is not a Portfolio or Project Manager then revoke his/her access
            if(oldProj.OwnerId <> newProj.OwnerId && (oldProj.OwnerId <> newProj.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c || oldProj.OwnerId <> newProj.pse__Project_Manager__r.pse__Salesforce_User__c)){
                userIdSet.add(oldProj.OwnerId);
            }
            //Remove sharing duplicate records - When the Project Owner is changed and the new Project Owner is same as the Project or Portfolio Manager
            if(oldProj.OwnerId <> newProj.OwnerId && (newProj.OwnerId == newProj.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c || newProj.OwnerId == newProj.pse__Project_Manager__r.pse__Salesforce_User__c)){
                userIdSet.add(newProj.OwnerId);
            }   
            //<T12>
        }        
        if(oldPMIds.size()>0 || userIdSet.size() > 0){
            deleteProjShareRecs(oldPMIds,newProjMap.keyset(),userIdSet);//<T12> - Added one more parameter
        }
        if(projRecsToCreateShareRecs.size()>0){
            createProjShareRecs(projRecsToCreateShareRecs);
        }
        
        
    }
    /**
    * @description - This method is invoked on After Update of Project records Update.
    * @param oldProjList - list of old Projects
    * @param newProjList - list of new Projects
    * @param oldProjMap - map of old Projects
    * @param newProjMap - map of new Projectd
    * @throws exception - NA
    */
    public void checkForResReqUpdatesOnProjUpdate(List<pse__Proj__c> oldProjList,List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap, Map<Id,pse__Proj__c> newProjMap){
        Map<Id,Id> oppProjIdMap = new Map<Id,Id>();
        Map<Id,Id> projOppIdMap = new Map<Id,Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        oppMap = getOppMapOfProjects(newProjList);
        
        for(pse__Proj__c oldProjRec : oldProjList){
            for(pse__Proj__c newProjRec : newProjList){
                if((oldProjRec.Id == newProjRec.Id) && (oldProjRec.pse__Opportunity__c <> newProjRec.pse__Opportunity__c) && (newProjRec.pse__Opportunity__c <> null) && (oppMap.containsKey(newProjRec.pse__Opportunity__c)) && 
                   (oppMap.get(newProjRec.pse__Opportunity__c).pse__Resource_Requests__r.size() > 0)){
                       oppProjIdMap.put(newProjRec.pse__Opportunity__c,newProjRec.Id);
                   }
                if((oldProjRec.Id == newProjRec.Id) && (oldProjRec.pse__Opportunity__c <> newProjRec.pse__Opportunity__c) && (newProjRec.pse__Opportunity__c <> null)){
                    projOppIdMap.put(newProjRec.Id,newProjRec.pse__Opportunity__c);
                }
            }
        }
        if(oppProjIdMap.size()>0){
            updateResReqRecs(oppProjIdMap,'Opportunity');
        }
        if(projOppIdMap.size()>0){
            updateResReqRecs(projOppIdMap,'Project');
        }
    }
    
    /**
    * @description - Method to get the Account Map from Projec recs.
    * @param newProjList - list of new projects
    * @return Map<AccountId,AccounRec>
    * @throws exception - NA
    */
    
    public Map<Id,Account> getAccountMapOfProjects(List<pse__Proj__c> newProjList){
        Set<Id> accIdSet = new Set<Id>();
        for(pse__Proj__c projRec : newProjList){
            if(projRec.pse__Account__c <> null || projRec.pse__Account__c <> ''){
                accIdSet.add(projRec.pse__Account__c);
            }
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN :accIdSet]);
        return accMap;
    }
    
    /**
    * @description - Method to get the Opportunity Map from Projec recs.
    * @param newProjList - List<ProjeRcs>
    * @return Map<OppId,OppMap>
    * @throws exception - NA
    */
    public Map<Id,Opportunity> getOppMapOfProjects(List<pse__Proj__c> newProjList){
        Set<Id> oppIdSet = new Set<Id>();
        for(pse__Proj__c projRec : newProjList){
            if(projRec.pse__Opportunity__c <> null || projRec.pse__Opportunity__c <> ''){
                oppIdSet.add(projRec.pse__Opportunity__c);
            }
        }
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,Name,StageName, Probability,Sales_Journey__c,psa_om_Start_Date__c,psa_om_End_Date__c,PSA_OM_Project_Type__c,psa_om_IPS_Package__c,
                                                                pse__Region__c,pse__Practice__c,pse__Group__c,CurrencyIsoCode,
                                                              (SELECT id,pse__Is_Billable__c FROM pse__Projects__r),(SELECT id FROM pse__Resource_Requests__r) FROM Opportunity WHERE Id IN:oppIdSet]);    
        return oppMap;
    }
    
    /**
    * @description - Method to get Business Unit Recs from Quote Business Unit
    * @param busUnits - Set<Business Unit Name>
    * @return Map<Business UnitName, Business Unit Rec>
    * @throws exception - NA
    */
    public Map<String,psa_pm_Business_Unit__c> getBusUnitMap(Set<String> busUnits){
        Map<String,psa_pm_Business_Unit__c> busUnitMap = new Map<String,psa_pm_Business_Unit__c>();
        List<psa_pm_Business_Unit__c> busUnitList = new List<psa_pm_Business_Unit__c>([SELECT Id,Name FROM psa_pm_Business_Unit__c WHERE NAME IN :busUnits]);
        if(busUnitList.size()>0){
            for(psa_pm_Business_Unit__c buRec : busUnitList){
                busUnitMap.put(buRec.Name,buRec);
            }
        }
        return busUnitMap;
    }
    
    
    /*
* @description - Method to get the Contact Map from Projec recs.
* @param newProjList - list of new projects 
* @return Map<ConId,CondRec>
* @throws exception - NA
*/
    public Map<Id,Contact> getContactMapOfProjects(List<pse__Proj__c> newProjList){
        Set<Id> conIdSet = new Set<Id>();
        for(pse__Proj__c projRec : newProjList){
            if(projRec.pse__Project_Manager__c <> null || projRec.pse__Project_Manager__c <> ''){
                conIdSet.add(projRec.pse__Project_Manager__c);
            }
        }
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id,Name,pse__Salesforce_User__c FROM Contact WHERE Id IN:conIdSet]);
        return conMap;
    }
    
    /**
    * @description - Method to get the Primary Quote for a Opportunity Id
    * @param oppIdSet - Opportunities Id
    * @return Map<OppId,SBQQ__Quote__c>
    * @throws exception - NA
    */
    public Map<Id,SBQQ__Quote__c> getQuoteMapFromOpp(Set<Id> oppIdSet){
        Map<Id,SBQQ__Quote__c> oppIDQuoteMap = new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>([SELECT Id,ShipToContact__r.Peoplesoft_External_ID__c,BillToContact__r.Peoplesoft_External_ID__c,
                                                                   BillToAccount__r.Peoplesoft_External_ID__c,ShiptToAccount__r.Peoplesoft_External_ID__c,Name,
                                                                   SBQQ__Opportunity2__c,SBQQ__Primary__c,ShiptToAccount__c,ShipToContact__c,SBQQ__ShippingStreet__c,
                                                                   ShippingAddress_PSFTID__c,Shipping_Email__c,ShippingName_PSFTID__c,SBQQ__ShippingPostalCode__c,
                                                                   SBQQ__ShippingName__c,SBQQ__ShippingCity__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,
                                                                   Bill_to_Email__c,Bill_to_Phone__c,BillToAccount__c,BillToContact__c,SBQQ__BillingStreet__c,
                                                                   BillingName_PSFTID__c,SBQQ__BillingPostalCode__c,SBQQ__BillingName__c,SBQQ__BillingCity__c,
                                                                   SBQQ__BillingCountry__c,SBQQ__BillingState__c,BillingAddress_PSFTID__c,PSA_OM_Planned_Margin__c,
                                                                   PSA_OM_Customer_Signoff__c,PSA_OM_Budget_Hours__c,psa_Service_Units__c,Business_Unit__c,SBQQ__PaymentTerms__c,
                                                                   Bill_To_Additional_Reference_Info__c, Ship_To_Additional_Reference_Info__c,PO__c //<T13>
                                                                   FROM SBQQ__Quote__c WHERE  SBQQ__Primary__c = true AND SBQQ__Opportunity2__c IN :oppIdSet]);
        if(quoteList.size()>0){
            for(SBQQ__Quote__c qrec : quoteList){
                if(qrec.SBQQ__Opportunity2__c <> null){
                    oppIDQuoteMap.put(qrec.SBQQ__Opportunity2__c,qrec);
                }
            }
        }
        return oppIDQuoteMap;
    }
    
    
    /**
    * @description - Method to update Resource Request record on Project creation or update to either update the Parent Project or the Parent Opportunity
    * @param sourceMap - Map<ProjectId,OpportunityId> OR Map<OpportunityId,ProjectId>, 
    * @param referenceObjName - ObjectName is either Opportunity or Project, depending on what parent attribute on Resource request is being updated.               
    * @throws exception - NA
    */
    public void updateResReqRecs(Map<Id,Id> sourceMap,string referenceObjName){        
        List<pse__Resource_Request__c> baseResReqlist = new List<pse__Resource_Request__c>();
        
        if(referenceObjName == 'Opportunity'){
            baseResReqlist = [SELECT id,Name,pse__Project__c,pse__Opportunity__c FROM pse__Resource_Request__c WHERE  pse__Opportunity__c IN :sourceMap.keyset()];
        }
        if(referenceObjName == 'Project'){
            baseResReqlist = [SELECT id,Name,pse__Project__c,pse__Opportunity__c FROM pse__Resource_Request__c WHERE  pse__Project__c IN :sourceMap.keyset()];
        }
        
        if(baseResReqlist.size()>0){
            for(pse__Resource_Request__c resReq : baseResReqlist){
                
                if(referenceObjName == 'Opportunity' && sourceMap.ContainsKey(resReq.pse__Opportunity__c)){
                    resReq.pse__Project__c = sourceMap.get(resReq.pse__Opportunity__c);
                }
                if(referenceObjName == 'Project' && sourceMap.ContainsKey(resReq.pse__Project__c)){
                    resReq.pse__Opportunity__c = sourceMap.get(resReq.pse__Project__c);
                }
                uow.registerDirty(resReq);
            }
        }
    }
    /**
    * @description - Method invoked on After Insert to created PROJECT CONTACT records - From Opportunity TEAM.
    * @param projList - list of new Projects
    * @param projMap - map of new Projects
    * @throws exception - NA
    */
    public void createProjectContactRecs(List<pse__Proj__c> projList, Map<Id,pse__Proj__c> projMap){
        map<String,string> mapProjectIdWiseOppId = new map<String,String>();
        for(pse__Proj__c proj : projList){
            if(proj.pse__Opportunity__c != null){
                mapProjectIdWiseOppId.put(proj.Id,proj.pse__Opportunity__c);
            }
        }
        map<String,Opportunity> mapOpp = new map<String,Opportunity>();
        map<String,String>mapUserIdWiseContactId = new map<String,String>();
        for(Opportunity opp: [Select Id, 
                              (Select Id,TeamMemberRole,UserId  
                               From OpportunityTeamMembers
                               Where TeamMemberRole = 'IPS Sales' 
                               Order By CreatedDate Desc
                               Limit 1)
                              From Opportunity 
                              Where Id In :mapProjectIdWiseOppId.values()])
        {
            mapOpp.put(opp.Id,opp);
            for(OpportunityTeamMember otm: opp.OpportunityTeamMembers){
                mapUserIdWiseContactId.put(otm.UserId,null);
            }    
            
        }
        for(Contact con : [Select Id,pse__Salesforce_User__c  From Contact Where pse__Salesforce_User__c In :mapUserIdWiseContactId.keySet()]){
            mapUserIdWiseContactId.put(con.pse__Salesforce_User__c,con.Id);
        }
        for(pse__Proj__c proj : projList){
            if(mapProjectIdWiseOppId.containsKey(proj.Id)){
                String oppId = mapProjectIdWiseOppId.get(proj.Id);
                if(mapOpp.containsKey(oppId)){
                    Opportunity opp = mapOpp.get(oppId);
                    for(OpportunityTeamMember otm: opp.OpportunityTeamMembers){
                        if(mapUserIdWiseContactId.containsKey(otm.UserId)){
                            psa_pm_Project_Contact__c proCon = new psa_pm_Project_Contact__c();
                            proCon.psa_pm_Project__c = proj.Id;
                            proCon.psa_pm_Contact__c = mapUserIdWiseContactId.get(otm.UserId);
                            proCon.psa_pm_Contact_Role__c = 'IPS Sales';
                            uow.registerNew(proCon);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * @description - Method invoked on After Insert to check if we need to update SOLUTION TYPE RECS with the primary project ID
    * @param projList - list of new Projects
    * @param projMap - map of new Projects
    * @throws exception - NA
    */
    public void updateSolutionTypeRecs(List<pse__Proj__c> projList, Map<Id,pse__Proj__c> projMap){
        
        Map<Id,Id> oppProjIdMap = new Map<Id,Id>();
        
        for(pse__Proj__c projRec : projList){
            if(!String.isBlank(projRec.pse__Opportunity__c) && String.isBlank(projRec.psa_om_Interlock__c)){
                oppProjIdMap.put(projRec.pse__Opportunity__c,projRec.Id);  
            }
        }
        if(!oppProjIdMap.isEmpty()){            
            List<psa_pm_Solution_Type__c> baseSolList = new List<psa_pm_Solution_Type__c>();
            baseSolList = [SELECT Id,psa_pm_Project__c,Opportunity__c FROM psa_pm_Solution_Type__c WHERE  Opportunity__c IN :oppProjIdMap.keySet()];
            for(psa_pm_Solution_Type__c solRec : baseSolList){
                if(String.isBlank(solRec.psa_pm_Project__c)){
                    solRec.psa_pm_Project__c = oppProjIdMap.get(solRec.Opportunity__c); 
                    uow.registerDirty(solRec);
                }
            }
        }
    }
    /**<T8>**/
   /*  
   * @description - This method calls on after update even of project object and sync back project info on related engagement  
   * @param newProjList - list of new Projects 
   * @param oldProjMap - map of old Projects
   * @throws exception - NA
   */      
     public void syncProjectBackToEngagement(List<pse__Proj__c> newProjList, Map<Id,pse__Proj__c> oldProjMap){  
        //Query Metadata  
        SobjectFieldChangeSetting__mdt fieldChangeSetting=[SELECT Fields_List__c,sObjectApi_Name__c FROM SobjectFieldChangeSetting__mdt WHERE DeveloperName='Project_Sync_To_Engagement_Setting'];  
        Set<String> fieldList = new Set<String>();  
        Set<Id> engagementSet = new Set<Id>();  
        //Prepare the set of fields to check if they are udated or not  
        for(string strField: fieldChangeSetting.Fields_List__c.split(',')){  
            if(String.isNotBlank(strField)){  
                fieldList.add(strField);  
            }  
        }  
        //Iterate over the new project isntance records  
        for(pse__Proj__c newProj:newProjList){  
            if(oldProjMap.get(newProj.Id)!=null){  
                pse__Proj__c oldProj = oldProjMap.get(newProj.Id);  
                for(String strField : fieldList) {  
                    //Check if the list of any of the field values are updated or not  
                    if(oldProj!=null && newProj.get(strField) != oldProj.get(strField) && newProj.psa_pm_Engagement__c!=null){  
                        engagementSet.add(newProj.psa_pm_Engagement__c);  
                        break;  
                    }  
                }                  
            }              
        }  
        //Now call the helper class to sync project values to related enagement  
        if(engagementSet.size()>0){  
            psa_om_UpdateInterlockBatchHandler.updateEngagementRecs(engagementSet);  
        }  
     }
    /**<T8>**/
}