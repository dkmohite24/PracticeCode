/* Name: ATI_REST_WarrantyStatusCheckValidator
Description : This Class is used to validate WarrantyStatusCheck JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      01/02/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_WarrantyStatusCheckValidator {
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public WOD_2__Inventory__c inventoryItem{get; private set;}
    public WOD_2__Warranty_Code__c vocationCode{get; private set;}
    public Date repairOrderOpenDate{get; private set;}
    public Decimal vehicleUsageValue{get; private set;}
    public String vehicleUsageUnit{get; private set;}
    public Date inServiceDate{get; private set;}
    public boolean shouldRegisterInventory{get;private set;}
    public ATI_REST_WarrantyStatusCheckValidator(){
        mapOfFailure = new Map<Integer,List<String>>();
        shouldRegisterInventory = false;
    }
    
    public void validateReqest(ATI_REST_WarrantyStatusCheckRequest warrantyStatusCheckRequest){
        verifyWarrantyStatusCheckRequest(warrantyStatusCheckRequest);
    }
    
   public void verifyWarrantyStatusCheckRequest(ATI_REST_WarrantyStatusCheckRequest request){
        ATI_REST_WarrantyStatusCheckRequest.WarrantyStatusCheckRequest warrantyStatusCheckRequest = request.warrantyStatusCheck;
        List<String> errorList = new List<String>();
       	if(ATI_Utils.checkIsBlankData(warrantyStatusCheckRequest.serialNumber)){
            errorList.add('SerialNumber is Mandatory');
        } else {
            List<String> iiFieldList = new List<String>{'Name','WOD_2__Serial_Number__c','ATI_Vocation_Code__r.Name','WOD_2__Item_Name__c'};
			String sNo = warrantyStatusCheckRequest.serialNumber;                
            List<WOD_2__Inventory__c> invList = 
                [select ID, Name, WOD_2__Serial_Number__c,ATI_Vocation_Code__r.Name,WOD_2__Item_Name__c,
                 WOD_2__Install_Date__c,ATI_Ship_To__c,WOD_2__Type__c,WOD_2__Item__c,WOD_2__Account__c,
                 (select Name,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c,
                  ATI_Vehicle_Information__r.ATI_Vehicle_usage_mi_km_hr__c from Transmissions__r)
                 from WOD_2__Inventory__c where WOD_2__Serial_Number__c = :sNo];
            if(invList.isEmpty()){
                errorList.add('Invalid Serial Number');
            } else {
                inventoryItem = invList.get(0);
            }
        }
       if(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.repairOrderOpenDate)){
           repairOrderOpenDate = ATI_Utils.parseDate(warrantyStatusCheckRequest.repairOrderOpenDate.trim());
           if(repairOrderOpenDate == null){
               errorList.add('Invalid RepairOrderOpenDate Format');
           }
       }
       if(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageValue)){
           vehicleUsageValue = Decimal.valueOf(warrantyStatusCheckRequest.vehicleUsageValue.trim());
           if(vehicleUsageValue < 0){
               errorList.add('Invalid VehicleUsageValue');    
           }
       }
       if(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageUnit)){
           vehicleUsageUnit = warrantyStatusCheckRequest.vehicleUsageUnit.trim();
           if(vehicleUsageUnit.equalsIgnoreCase('mi') || vehicleUsageUnit.equalsIgnoreCase('km') ||
              vehicleUsageUnit.equalsIgnoreCase('hrs')){
           }else{
              errorList.add('Invalid VehicleUsageUnit');
           }
           if(vehicleUsageUnit.equalsIgnoreCase('km') && vehicleUsageValue != null){
               vehicleUsageValue *= 0.621371;
           }
       	}
       if(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.inServiceDate)){
           this.inServiceDate = ATI_Utils.parseDate(warrantyStatusCheckRequest.inServiceDate);
           if(this.inServiceDate == null){
               errorList.add('Invalid In-Service Date Format');
           }
        }   
        if(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vocationCode)){
            List<WOD_2__Warranty_Code__c> wntyCodeList = [SELECT Id, Name FROM WOD_2__Warranty_Code__c where Name =:warrantyStatusCheckRequest.vocationCode and RecordType.DeveloperName = 'Vocation_Codes'];
            if(wntyCodeList.isEmpty()){
                errorList.add('Invalid Vocation Code Format');
            } else {
                vocationCode = wntyCodeList.get(0);
            }
        }   
       	shouldRegisterInventory = errorList.isEmpty() && ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vocationCode)
            && ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.inServiceDate) && ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageUnit)
            && ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageValue) && ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.repairOrderOpenDate);
       	System.debug('---------------------shouldRegisterInventory--------------------------');
       	System.debug( errorList.isEmpty());
       System.debug(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vocationCode) + ' -> ' + warrantyStatusCheckRequest.vocationCode);
       System.debug(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.inServiceDate));
       System.debug(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageUnit));
       System.debug(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.vehicleUsageValue));
       System.debug(ATI_Utils.checkIsNotBlankData(warrantyStatusCheckRequest.repairOrderOpenDate));
       	System.debug('---------------------shouldRegisterInventory--------------------------');
       	if(errorList.size() > 0){
           mapOfFailure.put(0,errorList);
        }
    }
}