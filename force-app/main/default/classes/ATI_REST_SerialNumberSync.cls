/* Name: ATI_REST_SerialNumberSync
Description : Endpoint which syncs inventory data required for warranty purposes 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)        18/01/2021      INITIAL DEVELOPMENT                           
*/
@RestResource(urlMapping = '/ATIRestSerialNumberSync/*')
global with sharing class ATI_REST_SerialNumberSync implements ATI_LoggableInterface{
    @HttpPost
    global Static ATI_REST_SerialNumberSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_SerialNumberSync serialNumberSyncObj = new ATI_REST_SerialNumberSync();
        ATI_REST_SerialNumberSyncResponse exchangeRateResponse = serialNumberSyncObj.serialNumber(requestBody);
        return exchangeRateResponse;
    }
    
    public ATI_REST_SerialNumberSyncResponse serialNumber(String serialNumberRequest){
        ATI_REST_SerialNumberSyncResponse serialNumberResponse = new ATI_REST_SerialNumberSyncResponse();
        WOD_2.ResponseWrapper response = processType(serialNumberRequest);
        if(response != null && response.data != null && response.data != '') {
            serialNumberResponse = (ATI_REST_SerialNumberSyncResponse)Json.deserialize(response.data,ATI_REST_SerialNumberSyncResponse.class);
        }else{
            serialNumberResponse.interfaceName = 'I-249 – Serial Number Interface';
            serialNumberResponse.status = 'Fail';
            serialNumberResponse.data = null;
            serialNumberResponse.message = response.errormessage;
            createLog('SerialNumberSync',serialNumberRequest,JSON.serialize(serialNumberResponse),'Failed',null,null);
        }
        System.debug('Response>>>> '+serialNumberResponse);
        return serialNumberResponse;   
    }
    
    private ATI_REST_SerialNumberValidator serialNumberValidatorObj{get; private set;}
    private Map<String,WOD_2__Inventory__c> mapOfInventoriesForUpsertion{get; private set;}
    private Map<String,WOD_2__Major_Component__c> mapOfMCsForInsertionOrUpdation{get; private set;}
    //private Map<String,ATI_Vehicle_Information__c> mapOfInvWithVehicleInfo{get; private set;}
    private Map<String,WOD_2__Inventory__c> mapOfInsertedOrUpdatedInventories{get; private set;}
    private Map<String,WOD_2__Major_Component__c> mapOfInsertedOrUpdatedMajorCmps{get; private set;}
    private Map<String,String> mapOfInvWithVIN{get; private set;}
    private Map<String,String> mapOfTransSNWithMCSN{get; private set;}
    public WOD_2.ResponseWrapper processType(String serialNumberRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_SerialNumberRequest serialNumberReqObj = new ATI_REST_SerialNumberRequest();
        serialNumberValidatorObj = new ATI_REST_SerialNumberValidator();
        try{
            serialNumberReqObj = ATI_REST_SerialNumberRequest.parse(serialNumberRequest);
            System.debug('Request>>>> '+serialNumberReqObj);
            serialNumberValidatorObj.validateReqest(serialNumberReqObj);
            mapOfInventoriesForUpsertion = new Map<String,WOD_2__Inventory__c>();
            //mapOfInvWithVehicleInfo = new Map<String,ATI_Vehicle_Information__c>();
            mapOfMCsForInsertionOrUpdation = new Map<String,WOD_2__Major_Component__c>();
            mapOfInsertedOrUpdatedInventories = new Map<String,WOD_2__Inventory__c>();
            mapOfInsertedOrUpdatedMajorCmps = new Map<String,WOD_2__Major_Component__c>();
            mapOfInvWithVIN = new Map<String,String>();
            mapOfTransSNWithMCSN = new Map<String,String>();
            for(ATI_REST_SerialNumberRequest.Inventory serialNumberReq : serialNumberValidatorObj.serialNumberReqLst){
                if(String.isBlank(serialNumberReq.majorComponentType)){
                    WOD_2__Inventory__c inventory;
                    if(!serialNumberValidatorObj.mapOfInventories.isEmpty() && serialNumberValidatorObj.mapOfInventories.containsKey(serialNumberReq.serialNumber.trim())){
                        inventory = serialNumberValidatorObj.mapOfInventories.get(serialNumberReq.serialNumber.trim());
                    }else{
                        inventory = new WOD_2__Inventory__c();
                        inventory.WOD_2__Type__c = 'Stock';
                        inventory.Name = serialNumberReq.serialNumber;
                        inventory.WOD_2__Serial_Number__c = serialNumberReq.serialNumber;
                    }
                    inventory.WOD_2__Item__c = serialNumberValidatorObj.mapOfWarrantyProducts.get(serialNumberReq.Item.trim()).Id;
                    inventory.WOD_2__Business_Unit__c = serialNumberValidatorObj.mapOfBusinessConfigs.get(serialNumberReq.businessCategoryUnit.trim()).Id;
                    if(!String.isBlank(serialNumberReq.egcn)){
                        inventory.ATI_Engineering_Group_Number__c = serialNumberReq.egcn;
                    }
                    if(!String.isBlank(serialNumberReq.buildDate)){
                        inventory.WOD_2__Manufacturing_Date__c = ATI_Utils.parseDate(serialNumberReq.buildDate);
                    }
                    if(!String.isBlank(serialNumberReq.shipDate)){
                        inventory.WOD_2__Shipment_Date__c = ATI_Utils.parseDate(serialNumberReq.shipDate);
                    }
                    if(!String.isBlank(serialNumberReq.customerId)){
                        inventory.ATI_CustomerId__c = serialNumberReq.customerId;
                    }
                    if(!String.isBlank(serialNumberReq.shipTo)){
                        inventory.ATI_Ship_To__c = serialNumberReq.shipTo; 
                    }
                    inventory.WOD_2__Account__c = serialNumberValidatorObj.oemAccount.get(0).Id;
                    if(!String.isBlank(serialNumberReq.programLevel)){
                        inventory.ATI_Program_Level__c = serialNumberReq.programLevel;
                    }
                    if(!String.isBlank(serialNumberReq.plantCode)){
                        inventory.ATI_Plant_Code__c = serialNumberReq.plantCode;
                    }
                    if(!String.isBlank(serialNumberReq.active)){
                        inventory.ATI_Active__c = Boolean.valueOf(serialNumberReq.active);
                    }
                    if(!String.isBlank(serialNumberReq.partcfn)){
                        inventory.ATI_Customer_Part_Number__c = serialNumberReq.partcfn;
                    }
                    //DMND-5817 New fields to Inventory[Start]
                    if(!String.isBlank(serialNumberReq.UHMessage)){
                        inventory.ATI_UH_Messages__c = serialNumberReq.UHMessage;
                    }
                    if(!String.isBlank(serialNumberReq.ShipToDescription)){
                        inventory.ATI_ShipTo_Description__c = serialNumberReq.ShipToDescription;
                    } //DMND-5817 New fields to Inventory[End]
                    mapOfInventoriesForUpsertion.put(inventory.WOD_2__Serial_Number__c,inventory);
                }else{
                    WOD_2__Major_Component__c majorCmp;
                    if(serialNumberValidatorObj.mapOfMajorComponents.containsKey(serialNumberReq.serialNumber.trim())){
                        majorCmp = serialNumberValidatorObj.mapOfMajorComponents.get(serialNumberReq.serialNumber.trim());
                    }else{
                        majorCmp = new WOD_2__Major_Component__c();
                        majorCmp.Name = serialNumberReq.serialNumber;
                        majorCmp.WOD_2__Serial_number__c = serialNumberReq.serialNumber;
                    }
                    majorCmp.ATI_Type__c = serialNumberReq.majorComponentType;
                    majorCmp.WOD_2__Part_Number__c = serialNumberReq.Item;
                    majorCmp.WOD_2__Warranty_Product__c = serialNumberValidatorObj.mapOfWarrantyProducts.get(serialNumberReq.Item.trim()).Id;
                    majorCmp.ATI_Business_Unit__c = serialNumberValidatorObj.mapOfBusinessConfigs.get(serialNumberReq.businessCategoryUnit.trim()).Id;
                    if(!String.isBlank(serialNumberReq.transmissionSerialNumber) && serialNumberReq.transmissionSerialNumber != '0'){
                        if(serialNumberValidatorObj.mapOfInventories.containsKey(serialNumberReq.transmissionSerialNumber.trim())){
                            majorCmp.WOD_2__Inventory__c = serialNumberValidatorObj.mapOfInventories.get(serialNumberReq.transmissionSerialNumber.trim()).Id;
                        }else{
                            mapOfTransSNWithMCSN.put(majorCmp.WOD_2__Serial_number__c,serialNumberReq.transmissionSerialNumber.trim());
                        }
                    }else{
                        majorCmp.WOD_2__Inventory__c = null;
                    }
                    if(!String.isBlank(serialNumberReq.buildDate)){
                        majorCmp.WOD_2__Manufacturing_Date__c = ATI_Utils.parseDate(serialNumberReq.buildDate);
                    }
                    mapOfMCsForInsertionOrUpdation.put(majorCmp.WOD_2__Serial_number__c,majorCmp);
                    if(!String.isBlank(serialNumberReq.vin) ){ 
                        majorCmp.ATI_VIN_from_Unit_history_field__c = serialNumberReq.vin.trim();
                    }
                }
            }
            if(!mapOfInventoriesForUpsertion.isEmpty()){
                createOrUpdateInventories();
            }
            if(!mapOfMCsForInsertionOrUpdation.isEmpty()){
                createOrUpdateMajorComponents();
            }
            responseWrapper.data = JSON.serialize(createResponse(serialNumberReqObj));
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('Catch Exception>> '+ e.getMessage()+' : '+e.getStackTraceString());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage();
        }
        return responseWrapper;
    }
    
    private void createOrUpdateInventories(){
        String objectName = 'WOD_2__Inventory__c';
        List<String> inventoryFields = new List<String>{'Name','WOD_2__Type__c','WOD_2__Serial_Number__c','WOD_2__Shipment_Date__c','WOD_2__Item__c','WOD_2__Manufacturing_Date__c','WOD_2__Account__c','ATI_Ship_To__c','ATI_Program_Level__c','ATI_Plant_Code__c','WOD_2__Business_Unit__c','ATI_Active__c','ATI_Customer_Part_Number__c','ATI_Engineering_Group_Number__c','ATI_ShipTo_Description__c','ATI_UH_Messages__c'};
            ATI_Utils.NoAccessObjectFieldWrapper inventoryCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,inventoryFields);
        ATI_Utils.NoAccessObjectFieldWrapper inventoryUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,inventoryFields);
        if(inventoryCreateAccessCheck.noAccessObjectList.size() == 0 && inventoryCreateAccessCheck.noAccessFieldList.size() == 0 && inventoryUpdateAccessCheck.noAccessObjectList.size() == 0 && inventoryUpdateAccessCheck.noAccessFieldList.size() == 0){
            upsert mapOfInventoriesForUpsertion.values();
            fetchInventoryDetails();
        } else {
            String errortext = 'Insufficient Inventory Create Access>> '+JSON.serialize(inventoryCreateAccessCheck)+'Insufficient Inventory Update Access-->> '+JSON.serialize(inventoryUpdateAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void fetchInventoryDetails(){
        if(ATI_REST_SerialNumberValidator.checkInventoryReadAccess()){
            List<WOD_2__Inventory__c> invLst = [SELECT Id,Name,WOD_2__Serial_Number__c,WOD_2__Item__r.Name,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN:serialNumberValidatorObj.serialNumbersSet AND WOD_2__Item__r.Name IN:serialNumberValidatorObj.itemNumbersSet];// AND WOD_2__Type__c=:'Stock'
            if(!invLst.isEmpty()){
                for(WOD_2__Inventory__c inv : invLst){
                    mapOfInsertedOrUpdatedInventories.put(inv.WOD_2__Serial_Number__c,inv);
                }
            }
        }else{
            throw new ATI_Exception('(Inventory) '+Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void createOrUpdateMajorComponents(){
        String objectName = 'WOD_2__Major_Component__c';
        List<String> inventoryFields = new List<String>{'Name','WOD_2__Serial_number__c','WOD_2__Part_Number__c','WOD_2__Warranty_Product__c','WOD_2__Inventory__c','WOD_2__Manufacturing_Date__c','ATI_Business_Unit__c','ATI_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper majorCmpCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,inventoryFields);
        ATI_Utils.NoAccessObjectFieldWrapper majorCmpUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,inventoryFields);
        if(majorCmpCreateAccessCheck.noAccessObjectList.size() == 0 && majorCmpCreateAccessCheck.noAccessFieldList.size() == 0 && majorCmpUpdateAccessCheck.noAccessObjectList.size() == 0 && majorCmpUpdateAccessCheck.noAccessFieldList.size() == 0){
            if(!mapOfTransSNWithMCSN.isEmpty()){
                for(String st : mapOfTransSNWithMCSN.KeySet()){
                    WOD_2__Major_Component__c majorCmp = mapOfMCsForInsertionOrUpdation.get(st);
                    if(mapOfMCsForInsertionOrUpdation.get(st).WOD_2__Inventory__c == null && 
                       mapOfInsertedOrUpdatedInventories.containsKey(mapOfTransSNWithMCSN.get(st))){
                        Id invId = mapOfInsertedOrUpdatedInventories.get(mapOfTransSNWithMCSN.get(st)).Id;
                        majorCmp.WOD_2__Inventory__c = invId;
                        mapOfMCsForInsertionOrUpdation.put(st,majorCmp);
                    }
                }
            }
            upsert mapOfMCsForInsertionOrUpdation.values();
            fetchMajorComponentDetails();
        } else {
            String errortext = 'Insufficient MajorComponent Create Access>> '+JSON.serialize(majorCmpCreateAccessCheck)+'Insufficient MajorComponent Update Access-->> '+JSON.serialize(majorCmpUpdateAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            throw new ATI_Exception('(Major Component) '+Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void fetchMajorComponentDetails(){
        if(ATI_REST_SerialNumberValidator.checkMajorComponentReadAccess()){
            List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,Name,WOD_2__Serial_Number__c,ATI_Type__c FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_Number__c IN:serialNumberValidatorObj.majorComponentSerialNumberSet];
            if(!majorCmpLst.isEmpty()){
                for(WOD_2__Major_Component__c majorCmp : majorCmpLst){
                    mapOfInsertedOrUpdatedMajorCmps.put(majorCmp.WOD_2__Serial_Number__c+':'+majorCmp.ATI_Type__c,majorCmp);
                }
            }
        }else{
            throw new ATI_Exception('(Major Component) '+Label.ATI_Log_Insufficient_access);
        }
    }
    
    private ATI_REST_SerialNumberSyncResponse createResponse(ATI_REST_SerialNumberRequest serialNumberRequest){
        ATI_REST_SerialNumberSyncResponse serialNumberResponse = new ATI_REST_SerialNumberSyncResponse();
        List<ResponseData> responseDataLst = new List<ResponseData>();
        Integer i = 1;
        for(ATI_REST_SerialNumberRequest.Inventory serialNumberReq : serialNumberRequest.inventory){
            ResponseData data = new ResponseData();
            if(!serialNumberValidatorObj.mapOfFailure.isEmpty() && serialNumberValidatorObj.mapOfFailure.containsKey(i)){
                data.message = String.Join(serialNumberValidatorObj.mapOfFailure.get(i),', ') ;
            }else{
                if(String.isBlank(serialNumberReq.majorComponentType)){
                    if(!serialNumberValidatorObj.mapOfInventories.isEmpty() && serialNumberValidatorObj.mapOfInventories.containskey(serialNumberReq.serialNumber.trim())){
                        data.message = 'Record Updated Successfully';
                    }else{
                        data.message = 'Record Inserted Successfully';
                    }
                    if(!mapOfInsertedOrUpdatedInventories.isEmpty() && mapOfInsertedOrUpdatedInventories.containsKey(serialNumberReq.serialNumber.trim())){
                        data.transactionId = mapOfInsertedOrUpdatedInventories.get(serialNumberReq.serialNumber.trim()).Id;
                        data.name = mapOfInsertedOrUpdatedInventories.get(serialNumberReq.serialNumber.trim()).Name;
                    }
                }else{
                    if(!serialNumberValidatorObj.mapOfMajorComponents.isEmpty() && serialNumberValidatorObj.mapOfMajorComponents.containskey(serialNumberReq.serialNumber.trim())){
                        data.message = 'Record Updated Successfully';
                    }else{
                        data.message = 'Record Inserted Successfully';
                    }
                    if(!mapOfInsertedOrUpdatedMajorCmps.isEmpty() && mapOfInsertedOrUpdatedMajorCmps.containsKey(serialNumberReq.serialNumber.trim()+':'+serialNumberReq.majorComponentType.trim())){
                        data.transactionId = mapOfInsertedOrUpdatedMajorCmps.get(serialNumberReq.serialNumber.trim()+':'+serialNumberReq.majorComponentType.trim()).Id;
                        data.name = mapOfInsertedOrUpdatedMajorCmps.get(serialNumberReq.serialNumber.trim()+':'+serialNumberReq.majorComponentType.trim()).Name;
                    }
                }
            }
            data.identifier = serialNumberReq.identifier;
            responseDataLst.add(data);
            i++;
        }
        serialNumberResponse.interfaceName = 'I-249 – Serial Number Interface';
        serialNumberResponse.data = responseDataLst;
        if(serialNumberValidatorObj.mapOfFailure.isEmpty()){
            serialNumberResponse.status = 'Success';
            serialNumberResponse.message =  'All the records have been inserted / updated successfully';
            createLog('SerialNumberSync',JSON.serialize(serialNumberRequest),JSON.serialize(serialNumberResponse),'Success',null,JSON.serialize(serialNumberValidatorObj.serialNumberSuccessSet));
        }else if(serialNumberValidatorObj.mapOfFailure.size() ==  serialNumberRequest.inventory.size()){
            serialNumberResponse.status = 'Failed';
            serialNumberResponse.message = 'All the records have failed to insert / update';
            createLog('SerialNumberSync',JSON.serialize(serialNumberRequest),JSON.serialize(serialNumberResponse),'Failed',JSON.serialize(serialNumberValidatorObj.serialNumberFailedSet),JSON.serialize(serialNumberValidatorObj.serialNumberFailedSet));
        }else{
            serialNumberResponse.status = 'Partial Success';
            serialNumberResponse.message =  'Few records have not been inserted / updated.';
            createLog('SerialNumberSync',JSON.serialize(serialNumberRequest),JSON.serialize(serialNumberResponse),'Partial Success',JSON.serialize(serialNumberValidatorObj.serialNumberFailedSet),'Success>> '+JSON.serialize(serialNumberValidatorObj.serialNumberSuccessSet)+',Failure>> '+JSON.serialize(serialNumberValidatorObj.serialNumberFailedSet));
        }
        return serialNumberResponse;
    }
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_SerialNumber_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!serialNumberValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(serialNumberValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = serialNumberValidatorObj.totalRecords-serialNumberValidatorObj.totalFailedRecords;
                objLogSerWrp.failureRecordCount = serialNumberValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_SerialNumberSyncResponse responseWrapperObj = (ATI_REST_SerialNumberSyncResponse)System.JSON.deserialize(response,ATI_REST_SerialNumberSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = serialNumberValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = serialNumberValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            objLogSerWrp.totalRecordCount = serialNumberValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
	Description    :   A wrapper class to capture the SerialNumber Rest data.
	*************************************************************************/
    global class ATI_REST_SerialNumberSyncResponse{
        global String status;
        global String message;
        global String interfaceName;
        global List<ResponseData> data;
    }
    global class ResponseData{
        global String name;
        global String transactionId;
        global String message;
        global String identifier;
    }
}