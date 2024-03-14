/* Name: ATI_VehicleInformationController
Description : Controller for ATI_VehicleInformationComponent
Author : Tavant (Akshatha S)
History :
VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
1.0 -       Tavant (Akshatha S)    04/12/2020          INITIAL DEVELOPMENT
*/
public with sharing class ATI_VehicleInformationController {

    /*
Method Name :   saveVehicleInfo
Params      :   Method to insert Vehicle information record
*/  
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper saveVehicleInfo(String vehicleInformationObjectJSON){
      try{
            System.debug('vehicleInformationObject--->'+vehicleInformationObjectJSON); 
            Map<String, Object> vehicleinfoObject = (Map<String, Object>)JSON.deserializeUntyped(vehicleInformationObjectJSON);
             System.debug('vehicleinfoObject--->'+vehicleinfoObject);
            Id inventryId = (Id) vehicleinfoObject.get('ATI_Inventory__c');
            System.debug('inventryId--->'+inventryId);
            ATI_Vehicle_Information__c vehicleInformationObject = (ATI_Vehicle_Information__c)JSON.deserialize(vehicleInformationObjectJSON, ATI_Vehicle_Information__c.class );
            System.debug('vehicleInformationObject123--->'+vehicleInformationObject);
            WOD_2.ResponseWrapper TWoD_ResponseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
            String vehicleInfoObjName = 'ATI_Vehicle_Information__c';
            //WOD_2__Warranty_Registration__c wrc = [SELECT Id,WOD_2__Account__c,WOD_2__Account__r.BillingCountry,ATI_Vocation_Code__c,ATI_Vocation_Code__r.Name FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c =:vehicleInformationObject.ATI_Inventory__c order by createddate limit 1];
          //ALSN-39 WOD_2__Customer_Billing_Country__c added to the query  
          WOD_2__Warranty_Registration__c wrc = [SELECT Id,WOD_2__Account__c,WOD_2__Account__r.BillingCountry,WOD_2__Customer_Billing_Country__c,ATI_Vocation_Code__c,ATI_Vocation_Code__r.Name FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c =:inventryId order by createddate desc limit 1];
          system.debug('wrc---'+wrc);
          //Changes done by Dishari on 08/31/2021 for Bug 28433  
           ATI_Usage_Codes__mdt usageMdt =[Select ATI_Usage_Codes__c,DeveloperName from ATI_Usage_Codes__mdt where DeveloperName='ATI_VIN_Usage_Codes']; 
            boolean usageCodeCondition = true;
            if(wrc.ATI_Vocation_Code__c!=null){
                if((usageMdt.ATI_Usage_Codes__c).Length() > (wrc.ATI_Vocation_Code__r.Name).Length()){
                    usageCodeCondition = (!usageMdt.ATI_Usage_Codes__c.contains(wrc.ATI_Vocation_Code__r.Name));
                }
                else{
                    usageCodeCondition = (!wrc.ATI_Vocation_Code__r.Name.contains(usageMdt.ATI_Usage_Codes__c));
                    //  usageCodeCondition =true;
                }
            }
          //Changes End Here by Dishari on 08/31/2021 for Bug 28433 
          //ALSN-39 changed the billing country check to that of Customer Country
            if(wrc.WOD_2__Customer_Billing_Country__c != null && (wrc.WOD_2__Customer_Billing_Country__c.equalsIgnoreCase('United States') ||  wrc.WOD_2__Customer_Billing_Country__c.equalsIgnoreCase('US') ||
                wrc.WOD_2__Customer_Billing_Country__c.equalsIgnoreCase('USA')) && usageCodeCondition &&
               !ATI_VehicleInformationController.checkRegex(vehicleInformationObject.Name)){ 
                   //throw new AuraHandledException('Invalid VIN');
                   System.debug('Invalid VIN check');   
                   throw new ATI_Exception('Invalid VIN');  
               }
            List<String> vehicleInfoFields = new List<String>{'Name','ATI_Customer_asset_number__c','ATI_Vehicle_Usage__c', 'ATI_Engine_Make__c', 'ATI_Vehicle_Make__c', 'ATI_Vehicle_Model__c', 'ATI_Engine_Model__c', 'ATI_Engine_Year__c', 'ATI_Executive_order_Designation__c'};
                ATI_Utils.NoAccessObjectFieldWrapper vehicleInfoNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(vehicleInfoObjName,vehicleInfoFields);
            if (vehicleInfoNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && vehicleInfoNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                List<ATI_Vehicle_Information__c> vehicleInfo = [SELECT Id FROM ATI_Vehicle_Information__c WHERE Name=:vehicleInformationObject.Name Order BY CreatedDate DESC LIMIT 1];
                System.debug('vehicleInfo>>> '+vehicleInfo);
                System.debug('vehicleInformationObject>>> '+vehicleInformationObject);
                if(!vehicleInfo.isEmpty()){
                    vehicleInformationObject.id = vehicleInfo.get(0).id;
                }else{
                    vehicleInformationObject.id = null;
                }
                Database.UpsertResult results =  Database.upsert(vehicleInformationObject);
                List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = [SELECT Id,ATI_Vehicle_Information__c FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:inventryId ORDER BY CreatedDate Limit 1];
                Map<String,ATI_Vehicle_Information__c> vehicleInfoMap = new Map<String,ATI_Vehicle_Information__c>();
                System.debug('vehicleTransMapperLst>>.. '+vehicleTransMapperLst);
                if(vehicleTransMapperLst.isEmpty()){
                    vehicleInformationObject.id = results.id;
                    Map<Id,ATI_Vehicle_Information__c> invVehicleMap = new Map<Id,ATI_Vehicle_Information__c>();
                    invVehicleMap.put(inventryId,vehicleInformationObject);                    
                    System.debug('invVehicleMap--->'+invVehicleMap);
                    createVehicleInfoMapper(invVehicleMap);
                }else{
                    vehicleTransMapperLst.get(0).ATI_Vehicle_Information__c = results.id;
                    Database.update(vehicleTransMapperLst);
                }
                if(inventryId != NULL){ 
                    String vehicleName = (String)vehicleinfoObject.get('Name');
                    WOD_2__Inventory__c invToUpdateObj = new WOD_2__Inventory__c(Id=inventryId);
                    /*ATI_Vehicle_Information__c vehicleObj = [SELECT Id,ATI_Vehicle_Mileage_Usage__c FROM ATI_Vehicle_Information__c 
                                                                WHERE Name=:vehicleName];*/
                    //Added query ALSN-54
                    ATI_VIN_Transmission_Mapper__c vehicleObj = [SELECT Id,ATI_Vehicle_Information__c,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c FROM ATI_VIN_Transmission_Mapper__c 
                                              WHERE ATI_Vehicle_Information__r.Name=:vehicleName AND ATI_Inventory__c=:inventryId];                                            
                    //invToUpdateObj.WOD_2__Units_Usage__c = vehicleObj.ATI_Vehicle_Mileage_Usage__c; 
                    invToUpdateObj.WOD_2__Units_Usage__c = vehicleObj.ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c;
                    //ALSN-139
                    invToUpdateObj.Vehicle_Information__c = vehicleObj.ATI_Vehicle_Information__r.Id;
                    //
                    TriggerHandler.bypass('ATI_InventoryTriggerHandler');
                    update invToUpdateObj;
                    TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
                }
                vehicleInfoMap = setSoftErrorDetails(vehicleInfoMap,vehicleInformationObject,inventryId,wrc);
                TWoD_ResponseWrapperObj.data = JSON.serialize(vehicleInfoMap);
                TWoD_ResponseWrapperObj.status=true;
            }
            return TWoD_ResponseWrapperObj;
        } catch(Exception excp) {
            System.debug('catch exception>>> '+excp.getMessage()+ ':'+excp.getLineNumber());
            return new WOD_2.ResponseWrapper('',false,excp.getMessage());
        }
    }

    private static Map<String,ATI_Vehicle_Information__c> setSoftErrorDetails(Map<String,ATI_Vehicle_Information__c> vehicleInfoMap,
                                            ATI_Vehicle_Information__c vehicleInformationObject,Id inventryId,WOD_2__Warranty_Registration__c wrc)
    {
        List<ATI_VIN_Transmission_Mapper__c> vehiclesMapperLst = [SELECT Id FROM ATI_VIN_Transmission_Mapper__c
                                                                    WHERE ATI_Vehicle_Information__r.Name=:vehicleInformationObject.Name];
        WOD_2__Business_Rule__c buRuleToDeleteOrUpsertObj;
        for(WOD_2__Business_Rule__c businessRule : [SELECT Id,WOD_2__Message__c FROM WOD_2__Business_Rule__c
                                                                WHERE ATI_Inventory__c=:inventryId])
        {
            if(businessRule.WOD_2__Message__c.contains(System.Label.ATI_The_VIN_is_already_associated_with_a_transmission)){
                buRuleToDeleteOrUpsertObj = businessRule;
                break;
            }
        }
        if(vehiclesMapperLst.size() > 1){
            vehicleInfoMap.put('VIN on two',vehicleInformationObject);
            if(buRuleToDeleteOrUpsertObj == NULL){
                WOD_2__Business_Rule__c businessRule = new WOD_2__Business_Rule__c();
                businessRule.ATI_Inventory__c = inventryId;
                businessRule.WOD_2__Error_Type__c = 'Soft';
                businessRule.WOD_2__Message__c = System.Label.ATI_The_VIN_is_already_associated_with_a_transmission;
                insert businessRule;
            }
        }else{
            vehicleInfoMap.put('VIN on one',vehicleInformationObject);
            if(buRuleToDeleteOrUpsertObj != NULL){
                delete buRuleToDeleteOrUpsertObj;
            }
        }
        return vehicleInfoMap;
    }
    
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper getVehicleData(String invId){
        try{
            WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
            Map<String,String> kmMileHourPicklistval = ATI_Utils.getPicklistOptions('ATI_Vehicle_Information__c','ATI_Vehicle_usage_mi_km_hr__c');
            System.debug('kmMileHourPicklistval--->'+kmMileHourPicklistval);
            List<String> fieldNames = new List<String>{'ATI_Vehicle_Information__r.Name','ATI_Vehicle_Information__r.ATI_Customer_asset_number__c','ATI_Vehicle_Information__r.ATI_Engine_Make__c','ATI_Vehicle_Information__r.ATI_Engine_Model__c','ATI_Vehicle_Information__r.ATI_Engine_Year__c','ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c',
               'ATI_Inventory__c','ATI_Vehicle_Information__c','ATI_Vehicle_Information__r.ATI_Vocation_Code__r.name','ATI_Vehicle_Information__r.ATI_Vehicle_Make__c','ATI_Vehicle_Information__r.ATI_Vehicle_Model__c','ATI_Vehicle_Information__r.ATI_Vehicle_usage_mi_km_hr__c','ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c',
                'ATI_Vehicle_Information__r.ATI_Vehicle_Usage_KM__c','ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c'};
                    ATI_Utils.NoAccessObjectFieldWrapper accessWrapper = ATI_Utils.fetchReadAccess('ATI_VIN_Transmission_Mapper__c', fieldNames);
            if (accessWrapper.noAccessObjectList.isEmpty() && accessWrapper.noAccessFieldList.isEmpty()) {
                System.debug('In if');
                String inventoryId = String.escapeSingleQuotes(invId);
                String query = 'select Id, ' + String.join(fieldNames, ',') + ' from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__c = :inventoryId';
                List<ATI_VIN_Transmission_Mapper__c> vehicleList = Database.query(query); 
                System.debug('Vehicle List--->'+vehicleList);
                
                //List<ATI_Vehicle_Information__c> vdlist = new List<ATI_Vehicle_Information__c>();
                
                //System.debug('vehclStrng--->'+vehclStrng);
                //where ATI_Inventory__c =:inventoryId
                //for(ATI_Vehicle_Information__c vi : [Select Name,ATI_Customer_asset_number__c,ATI_Engine_Make__c,ATI_Engine_Model__c,ATI_Engine_Year__c,ATI_Executive_order_Designation__c,ATI_Vocation_Code__r.name,ATI_Vehicle_Make__c,ATI_Vehicle_Model__c,ATI_Vehicle_usage_mi_km_hr__c,ATI_Vehicle_Usage__c from ATI_Vehicle_Information__c ORDER BY CreatedDate DESC NULLS FIRST limit 1]){
                //    vdlist.add(vi);
                //}  
                //System.debug('VDLst--->'+vdlist);
            
                if(!vehicleList.isEmpty()){ 
                    String vehclStrng ='{' + '\"ATI_Inventory__c\":\"' + vehicleList[0].ATI_Inventory__c + '\"' + ',\"ATI_Vehicle_Mileage_Usage__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c + '\"' + ',\"ATI_Vehicle_Usage_KM__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_Usage_KM__c + '\"' + ',\"Id\":\"' + vehicleList[0].ATI_Vehicle_Information__c+ '\"' + ',\"Name\":\"' + vehicleList[0].ATI_Vehicle_Information__r.Name + '\"' + ',\"ATI_Customer_asset_number__c\":\"' +vehicleList[0].ATI_Vehicle_Information__r.ATI_Customer_asset_number__c + '\"' + ',\"ATI_Engine_Make__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Engine_Make__c + '\"' + ',\"ATI_Engine_Model__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Engine_Model__c + '\"' +',\"ATI_Engine_Year__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Engine_Year__c+ '\"' +',\"ATI_Executive_order_Designation__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c + '\"'+ ',\"ATI_Vehicle_Usage__c\":\"' +vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c + '\"' + ',\"ATI_Vehicle_usage_mi_km_hr__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_usage_mi_km_hr__c + '\"' + ',\"ATI_Vehicle_Model__c\":\"' + vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_Model__c + '\"' + ',\"ATI_Vehicle_Make__c\":\"'+  vehicleList[0].ATI_Vehicle_Information__r.ATI_Vehicle_Make__c + '\"'  + ',\"Mapval\":\"' + kmMileHourPicklistval.keySet() + '\"}';
                    String refinedString = vehclStrng.replace('null',''); 
                    System.debug('JSON.serialize(vdlist.get(0))---'+JSON.serialize(vehicleList.get(0)));
                  //  responseWrapperObj.data= JSON.serialize(vdlist.get(0));
                  //  responseWrapperObj.data= responseWrapperObj.data.removeEnd('}') + ',\"ATI_Inventory__c\":\"' + vehicleList[0].ATI_Inventory__c +  '\"' + ',\"Mapval\":\"' + kmMileHourPicklistval.keySet() + '\"}';
                responseWrapperObj.data= refinedString;
                }
                else{
                    System.debug('in else');
                    responseWrapperObj.data = '{' +'\"Mapval\":\"' + kmMileHourPicklistval.keySet() + '\"}';
                }
                System.debug('responseWrapperObj.data --->'+responseWrapperObj.data);
            }
            return responseWrapperObj;
        } catch(Exception excp) {
            return new WOD_2.ResponseWrapper('',false,excp.getMessage());
        }
    }    
    
    //Create createVehicleInfoMapper
    public static void createVehicleInfoMapper(Map<Id,ATI_Vehicle_Information__c> mapOfInvWithVehicleInfo){
        List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = new List<ATI_VIN_Transmission_Mapper__c>();
        for(Id invId : mapOfInvWithVehicleInfo.KeySet()){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c(ATI_Inventory__c=invId,ATI_Vehicle_Information__c=mapOfInvWithVehicleInfo.get(invId).Id);
            vehicleTransMapperLst.add(vehicleTransMapper);
        }
        if(!vehicleTransMapperLst.isEmpty()){
            Database.insert(vehicleTransMapperLst);
        }
    }
    
    public static boolean checkRegex(String vin){
        Boolean result = false;
        String vinRegex= '^(?<wmi>[A-HJ-NPR-Z\\d]{3})(?<vds>[A-HJ-NPR-Z\\d]{5})(?<check>[\\dX])(?<vis>(?<year>[A-HJ-NPR-Z\\d])(?<plant>[A-HJ-NPR-Z\\d])(?<seq>[A-HJ-NPR-Z\\d]{6}))$';
        result = Pattern.matches(vinRegex, vin);
        if(result){
            Integer sum = 0;
            Map<String, Integer> transliterations = new Map<String,Integer>{
                'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8,
                    'j' => 1, 'k' => 2, 'l' => 3, 'm' => 4, 'n' => 5, 'p' => 7, 'r' => 9, 's' => 2,
                    't' => 3, 'u' => 4, 'v' => 5, 'w' => 6,'x' => 7, 'y' => 8, 'z' => 9};
            List<Integer> weights = new List<Integer>{8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2};    
            String lowerCaseVIN = vin.toLowerCase();
            for(Integer i = 0; i < lowerCaseVIN.length(); i++){
                String charAt = lowerCaseVIN.substring(i, i+1);
                if(!charAt.isNumeric()){
                    sum += transliterations.get(charAt) * weights[i];
                } else {
                    sum += Integer.valueOf(charAt) * weights[i];
                }
            }
            Integer checkDigit = Math.mod(sum, 11);
            String vinCheckDigit = checkDigit == 10 ? 'X' : checkDigit+'';
            result = (vinCheckDigit == lowerCaseVIN.substring(8, 9));
        }
        return result;
    } 

}