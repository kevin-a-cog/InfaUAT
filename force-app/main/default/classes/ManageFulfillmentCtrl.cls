/****************************************************************************************************************
Class:          ManageFulfillmentCtrl
@Author:        vsabbell
@Created Date:  8/7/2019.
@Description:   Controlled for Lightning Component ManageFulfillments to create fulfillment data. 

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                         Tag

Vignesh D           7/29/2020   F2A-240             Fulfillment creation for Cloud/Daas products        T01

Vignesh D           7/29/2020   F2A-244             Skip provisioning for MR only orders                T02

Vignesh D			9/22/2020	F2A-265				Added method to check if user has shipping user 	T03
													custom permission
Pavithra V			11/23/2020	F2A-313				Modified to create Fulfillment versions only for 	T04
													On-premise type Install Bases
Pavithra V        	02/03/2020  F2A-364/F2A-354	    Update the edition value for the fulfillment Line   T05
Vignesh D           2/2/2023    F2A-493             Fulfillment Line creation for Flex IPU products     T06
Vignesh D           2/16/2023   F2A-493             Create a new aura method to call from the aura      T07
                                                    component to delete OE and to create OE, OEL 
                                                    & fulfillment
*************************************************************************************************************************/
public with sharing class ManageFulfillmentCtrl {

    public virtual class BaseException extends Exception {}
    public class FulfillmentException extends BaseException {}
    public class NoFulfillmentLinesException extends BaseException {}
    public class SkipFulfillmentException extends BaseException{}

    @AuraEnabled
    public static String createOEAndFulfillment(Id orderId) { //<T07>
        OrgEntitlementService.deleteOrgEntitlements(orderId);
        OrgEntitlementService.createOrgEntitlements(orderId);
        Id fulfillmentId = createFulfillments(orderId);
        OrgEntitlementService.updateFLOnOrgEntitlementLine(orderId);

        return fulfillmentId;
    }
    
    public static String createFulfillments(String OrderId) {
        
        globalApexManager GAM = new globalApexManager();
        Savepoint sp = Database.setSavepoint();
        Id fulfillmentId;

        try{
            OrderId = String.escapeSingleQuotes(OrderId); 
            Boolean boolMROnlyOrder = FulfillmentService.checkMRSkipProvisioning(OrderId); //<T02>
            
            if(boolMROnlyOrder){ //<T02>
                throw new SkipFulfillmentException(OrderId);
            }

            //---------------------------------------<T06>---------------------------------------
            List<Fulfillment__c> lstFulfillments = [SELECT Id FROM Fulfillment__c WHERE Order__c = :OrderId AND Active__c = true];

            if(!lstFulfillments.isEmpty()){
                return lstFulfillments[0].Id;
            }
            
            Fulfillment__c objFulfillment = FulfillmentService.createFulfillment(OrderId);
            fulfillmentId = objFulfillment.Id; 
            List<OrderItem> lstOrderProducts = FulfillmentService.getOrderProducts(OrderId);
            Map<Id, List<OrderItem>> orderProductParentToChildMap = FulfillmentService.sortOrderProductsByParentAndChild(lstOrderProducts);
            Map<Id, Fulfillment_Line__c> orderProductToFulfillmentLineMap = FulfillmentService.createFulfillmentLines(OrderId, lstOrderProducts, objFulfillment);
            
            if(orderProductToFulfillmentLineMap.isEmpty()){
                throw new NoFulfillmentLinesException(fulfillmentId);
            }
            
            List<Related_Fulfillment_Line__c> relatedfflineList = FulfillmentService.createRelatedFulfillmentLines(OrderId, lstOrderProducts, orderProductParentToChildMap, objFulfillment.Id, orderProductToFulfillmentLineMap);
            //---------------------------------------</T06>---------------------------------------
            FulfillmentService.updateEditionInffline(relatedfflineList); /**<T05>**/
            associateInstallBases(OrderId);
        }
        catch(SkipFulfillmentException skipFulfillmentEx){
            String ordId = String.escapeSingleQuotes(skipFulfillmentEx.getMessage());
            return ordId;
        }
        catch(NoFulfillmentLinesException noFulfillmentLinesEx){
            String fulfillmentHeaderId = String.escapeSingleQuotes(noFulfillmentLinesEx.getMessage());
            if(String.isNotBlank(fulfillmentId)){
                Database.rollback(sp);
            }
            return OrderId;
        }
        catch(Exception Ex){
            GAM.CreateExceptionRecords('ManageFulfillmentCtrl', 'Exception in ManageFulfillmentCtrl',ex.getMessage());
            throw new FulfillmentException('Fulfillment Exception Occured.'+ex.getMessage());
        }
        
        return fulfillmentId;
    }
    
    public static void associateInstallBases(Id OrderId){
        List<Id> productIds = new List<Id>();
        Map<Id,Set<Id>> InstallBasesByProduct = new Map<Id,set<Id>>();
        Map<Id,Id> fulfillmentByProduct = new  Map<Id,Id>();
        Map<String,FulfillmentData.FulfillmentLine> fulfillmentById = new Map<String,FulfillmentData.FulfillmentLine>();
        List<Fulfillment__c> fulfillmentHeaders= [Select id FROM Fulfillment__c where Order__c=:OrderId and Active__c =true order by CreatedDate  desc];
        
        if(fulfillmentHeaders.size()>0){
            Id fulfillmentId = fulfillmentHeaders[0].Id;
            fulfillmentId= String.escapeSingleQuotes(fulfillmentId);
            List<Fulfillment_Line__c> fulfillmentLines = FulfillmentData.getFulfillmentLines(fulfillmentId);
            List<FulfillmentData.FulfillmentLine> fulfillmentLinesDT = FulfillmentData.getFulfillmentLinesDT(fulfillmentLines);
            for(FulfillmentData.FulfillmentLine fulfillmentLineDT: fulfillmentLinesDT){
                fulfillmentById.put(fulfillmentLineDT.id,fulfillmentLineDT);
                
            }
            System.debug(LoggingLevel.ERROR,'fflines:-->before'+ JSON.serialize(fulfillmentLinesDT));
            
            
            for(FulfillmentData.RelatedLine RelatedLine: FulfillmentData.getRelatedLinesDT(fulfillmentLines)){
                FulfillmentData.FulfillmentLine fulfillmentLine =  fulfillmentById.get(RelatedLine.parentid);
                fulfillmentLine.addProduct(RelatedLine.productId);
                fulfillmentByProduct.put(RelatedLine.productId,fulfillmentLine.id);
                productIds.add(String.escapeSingleQuotes(RelatedLine.productId) );
                
            }
            system.debug(LoggingLevel.ERROR, '-->'+JSON.serialize(fulfillmentByProduct));  
            system.debug(LoggingLevel.ERROR, '-->'+JSON.serialize(productIds));        
            
            List<Id> installBases = new List<Id>();
            
            for(InstallBase_Mapping__c ibm: [select id,name, Product__c, Install_Base__c  from InstallBase_Mapping__c where Product__c In :productIds 
                                             and Install_Base__r.RecordType.DeveloperName='On_Premise']){ /**<T04>**/
                if(fulfillmentByProduct.containsKey(ibm.Product__c)) {
                    fulfillmentById.get(fulfillmentByProduct.get(ibm.Product__c)).addinstallBase(ibm.Install_Base__c);
                }           
                installBases.add(String.escapeSingleQuotes(ibm.Install_Base__c) );  
            }
            
            System.debug(LoggingLevel.ERROR,'fflines:-->after;'+ JSON.serialize(fulfillmentLines));
            Map<Id,InstallBase__c> installbaseVersions = new Map<Id,InstallBase__c>([select id,name,(select id,name,Install_Base__c,Active_Version__c, Current_Version__c   
                                                                                                     from Versions__r  where Active_Version__c =true order by   
                                                                                                     Current_Version__c desc) 
                                                                                     from InstallBase__c where Id IN :installBases]);
            
            
            
            
            
            List<Fulfillment_Version__c> downloadLinks = new List<Fulfillment_Version__c>();
            
            for(FulfillmentData.FulfillmentLine fulfillmentLine: fulfillmentLinesDT){
                for(Id installBaseId: fulfillmentLine.getInstallBases()){
                    installBaseId = String.escapeSingleQuotes(installBaseId);
                    Id currentVersion = getCurrentVersion(installbaseVersions.get(installBaseId));
                    downloadLinks.add(new Fulfillment_Version__c( Fullfillment_Line__c = fulfillmentLine.id,InstallBase__c = installBaseId, Order__c=OrderId,Supplied_Version__c=currentVersion));
                }
            }
            
            insert downloadLinks;
            
        }
        
        
        
    }
    
    static Id getCurrentVersion(Sobject installBase){
        List<Sobject> versions = installBase.getSobjects('Versions__r');
        if(versions!=null && versions.size()>0){
            return String.escapeSingleQuotes(versions[0].Id) ;
        }
        return null;
        
    }
    
    /*Method to check whether user has Shipping User custom permission.
    * @param Name - n/a
    * @throws exception -n/a
    * @return Boolean---Response will be true/false
    */
    
    @AuraEnabled
    public static Boolean checkUserPermission(){
        String customPermission = 'Shipping_User';
        Boolean retMessage = FeatureManagement.checkPermission(customPermission);
        return retMessage;
    }
}