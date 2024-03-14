/**
 * @description       : This class is used as invocable in the flow for creating Vehicle Information record.
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : Abhishek Mohapatra
**/
public with sharing class ATI_TAC_VehicleInformation_Invocable {

    /**
    * @description Method used for Invocable in Flows where the Vehicle information record need to be created [USER STORY 32610]
    * @author Abhishek Mohapatra | 07-06-2023 
    * @param vin [VIN number should be added as input in the apex action in flow.]
    * @return List<String> [This will return the id of the Vehicle Information record created.]
    **/
    @InvocableMethod(label = 'Create Vehicle Information' description='Creates the Vehicle Information record after fetching data from NHTSA site. Also returns the id of the Vehicle Information record.')
    public static List<String> createVehicleInfo (List<String> vin){
        List<String> ids = new List<String>();
        
        String vehicleInfoNum = vin[0];
        System.debug('vehicleInfoNum'+vehicleInfoNum);
        ATI_Vehicle_Information__c vi = ATI_TAC_API_VehicleInformation.populateVehicleInformation(vehicleInfoNum);
        System.debug('vi'+vi);
		
        list<ATI_Vehicle_Information__c> viexisting = [Select Id, ATI_Customer_asset_number__c, ATI_Engine_Make__c, ATI_Engine_Model__c, ATI_Engine_Year__c, ATI_Executive_order_Designation__c, ATI_Inventory__c, ATI_Vehicle_Make__c, ATI_Vehicle_Mileage_Usage__c, ATI_Vehicle_Model__c, ATI_Vehicle_Usage__c, ATI_Vehicle_usage_by_Hr__c, ATI_Vehicle_Usage_KM__c, ATI_Vehicle_usage_mi_km_hr__c, ATI_Vocation_Code__c, CreatedById, Name from ATI_Vehicle_Information__c where Name = :vehicleInfoNum];
        System.debug('viexisting'+viexisting);
        
        if(viexisting.size()>0){
             /*33993- Vehicle Information Update Existing Records changes start*/
            ids.add(ATI_TAC_API_DataServices.updateVehicleInformation(vi, viexisting[0]));
             /*33993- Vehicle Information Update Existing Records changes start*/
        }
        else{
            if (vi.Name == vehicleInfoNum) {
            ids.add(ATI_TAC_API_DataServices.insertVehicleInformation(vi));
        }else {
            vi = [select id,Name from ATI_Vehicle_Information__c  WHERE Name = 'Invalid VIN'];
            ids.add(vi.id);
        }
        }
        
        

        System.debug(ids);

        return ids;
    }
}