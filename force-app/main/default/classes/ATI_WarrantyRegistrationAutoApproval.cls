/* Name: ATI_WarrantyRegistrationAutoApproval
Description : This class is used to for both Auto & Manual Approval of warranty Registration  
Author : TAVANT(RG)
History:
VERSION     AUTHOR                 DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(RG)             12/31/2020                  INITIAL DEVELOPMENT                              
*/
public without sharing class ATI_WarrantyRegistrationAutoApproval {
    @InvocableMethod
	public static void wrAutoApproval(List<WOD_2__Warranty_Registration__c> wodwrlst){
        System.debug('WR Record ----> '+wodwrlst);
		// ALSN-65 Vijay chages start : get pre-delivery warranty registration record and change status to InActive  
       List<WOD_2__Warranty_Registration__c> preDeliveryWrList = [select id,ATI_Pre_Delivery__c,WOD_2__Status__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :wodwrlst[0].WOD_2__Inventory__c AND ATI_Pre_Delivery__c = true];
        List<WOD_2__Warranty_Registration__c> updpreDeliveryWrList = new  List<WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c preWr:preDeliveryWrList){
            preWr.WOD_2__Status__c  = 'InActive';
            updpreDeliveryWrList.add(preWr);
         }
        if(!updpreDeliveryWrList.isEmpty()){
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
             update updpreDeliveryWrList;
             TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        } 
        // ALSN-65 Vijay chages end 
        List<WOD_2__Warranty_Registration__c> wrToUpdateLst = new List<WOD_2__Warranty_Registration__c>();
        List<WOD_2__Inventory__c> invLst = new List<WOD_2__Inventory__c>();
        List<WOD_2__Inventory__c> invToUpdateLst = new List<WOD_2__Inventory__c>();
        for(WOD_2__Warranty_Registration__c wrObj: wodwrlst){
            WOD_2__Warranty_Registration__c wrObjTemp = new WOD_2__Warranty_Registration__c(Id=wrObj.Id,
                																			WOD_2__Status__c = 'Registered');
            if(wrObj.ATI_Pre_Delivery__c){
                wrObjTemp.WOD_2__Registration_Type__c = 'Pre-Delivery';
                invToUpdateLst.add(new WOD_2__Inventory__c(Id=wrObj.WOD_2__Inventory__c,WOD_2__Type__c='Stock'));
            }
            wrToUpdateLst.add(wrObjTemp);
        }
        update wrToUpdateLst;
        if(!invToUpdateLst.isEmpty()){
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update invToUpdateLst;
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        }
    }
}