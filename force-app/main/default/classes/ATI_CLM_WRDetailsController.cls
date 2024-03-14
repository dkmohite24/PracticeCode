/* Name: ATI_CLM_WRDetailsController
Description : ATI_CLM_WRDetailsController - Controller for dynamic component to show WR detials.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      08-JAN-2021          INITIAL DEVELOPMENT
*/
public with sharing class ATI_CLM_WRDetailsController {

    @AuraEnabled
    public static WOD_2.ResponseWrapper fetchInvAndVIDetails(String invId){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('', true, '');
        InvAndVIDetailsWrapper wrapper = new InvAndVIDetailsWrapper();
        List<String> invFieldsList = getInvFields();
        Id inventoryId = Id.valueOf(String.escapeSingleQuotes(invId));
        String query = 'Select id, ' + String.join(invFieldsList, ',') + ' from WOD_2__Inventory__c where id = :inventoryId';
        System.debug('Query -> ' + query);
        List<WOD_2__Inventory__c> invList = Database.query(query);
        
        if(!invList.isEmpty()){
            wrapper.invDetails = invList.get(0);
            //ALSN-63                        //ALSN - 149.. ***status = 'Registered' added in the query***
            query = 'Select id, ATI_Pre_Delivery__c,WOD_2__Customer__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :inventoryId AND WOD_2__Status__c =\'Registered\' ORDER BY LastModifiedDate DESC';
            List<WOD_2__Warranty_Registration__c> wrList = Database.query(query);
            if(!wrList.isEmpty()){
            	wrapper.regDetails= wrList.get(0);
            }
            WOD_2.ResponseWrapper viResponseWrapper = ATI_VehicleInformationController.getVehicleData(invId);
            if(viResponseWrapper.status && String.isNotBlank(viResponseWrapper.data)){
                wrapper.vehicleInfo = (ATI_Vehicle_Information__c)JSON.deserialize(viResponseWrapper.data, ATI_Vehicle_Information__c.class);
            }
            responseWrapper.data = JSON.serialize(wrapper);
        }
        return responseWrapper;
    }
    
     @AuraEnabled
    public static WOD_2.ResponseWrapper isLoggedInUserAsDistributor(){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('', true, '');
        responseWrapper.data = JSON.serialize(ATI_Utils.isLoggedInUserAsDistributor());
        return responseWrapper;
    }
    
     @AuraEnabled
    public static WOD_2.ResponseWrapper VehiclePicklistUnit(){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('', true, '');
        Map<String,String> kmMileHourPicklistval = ATI_Utils.getPicklistOptions('ATI_Vehicle_Information__c','ATI_Vehicle_usage_mi_km_hr__c');
        responseWrapper.data = JSON.serialize(kmMileHourPicklistval.keySet());
        return responseWrapper;
    }
    
    private static List<String> getInvFields(){
        List<String> invFieldsList = new List<String>();
        invFieldsList.add('WOD_2__Customer__c');
        invFieldsList.add('WOD_2__Install_Date__c');
        invFieldsList.add('ATI_Vocation_Code__c');
        invFieldsList.add('ATI_Vocation_Code__r.Name');
        invFieldsList.add('ATI_Vocation_Code__r.WOD_2__Description__c');
        invFieldsList.add('WOD_2__Type__c');
        return invFieldsList;
    }
    
    public class InvAndVIDetailsWrapper {
        public WOD_2__Inventory__c invDetails;
        public ATI_Vehicle_Information__c vehicleInfo;
        //ALSN-63
        public WOD_2__Warranty_Registration__c regDetails;
        //public Boolean isDealerDistributor;
    }
}