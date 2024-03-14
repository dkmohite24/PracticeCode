/* Name: ATI_REST_SerialNumberValidator
Description : This Class is used to validate SerialNumber JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)        18/01/2021      INITIAL DEVELOPMENT                           
*/
public with sharing class ATI_REST_SerialNumberValidator {
    public Map<String,String> mapOfInvSerialNumberWithRequestData{get; private set;}
    public List<ATI_REST_SerialNumberRequest.Inventory> serialNumberReqLst{get; private set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Set<String> businessUnitsSet{get; private set;}
    public Set<String> itemNumbersSet{get; private set;}
    public Set<String> serialNumbersSet{get; private set;}
    public Set<String> vinNumbersSet{get; private set;}
    public Set<String> majorComponentSerialNumberSet{get; private set;}
    public Map<String,WOD_2__Business_Category_Configuration__c> mapOfBusinessConfigs{get; private set;}
    public Map<String,WOD_2__Warranty_Product__c> mapOfWarrantyProducts{get; private set;}
    public Map<String,WOD_2__Inventory__c> mapOfInventories{get; private set;}
    public Map<String,WOD_2__Major_Component__c> mapOfMajorComponents{get; private set;}
    public Integer totalrecords{get; private set;}
    public Integer totalFailedRecords{get; private set;}
    public List<Account> oemAccount{get; private set;}
    public Set<String> serialNumberFailedSet{get; private set;}
    public Set<String> serialNumberSuccessSet{get; private set;}
    public ATI_REST_SerialNumberValidator(){
        mapOfInvSerialNumberWithRequestData = new Map<String,String>();
        serialNumberReqLst = new List<ATI_REST_SerialNumberRequest.Inventory>();
        mapOfFailure = new Map<Integer,List<String>>();
        businessUnitsSet = new Set<String>();
        itemNumbersSet = new Set<String>();
        serialNumbersSet = new Set<String>();
        vinNumbersSet = new Set<String>();
        majorComponentSerialNumberSet = new Set<String>();
        oemAccount = new List<Account>();
        mapOfBusinessConfigs = new Map<String,WOD_2__Business_Category_Configuration__c>();
        mapOfWarrantyProducts = new Map<String,WOD_2__Warranty_Product__c>();
        mapOfInventories = new Map<String,WOD_2__Inventory__c>();
        mapOfMajorComponents = new  Map<String,WOD_2__Major_Component__c>();
        serialNumberFailedSet = new Set<String>();
        serialNumberSuccessSet = new Set<String>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    public void validateReqest(ATI_REST_SerialNumberRequest serialNumberRequestBody){
        querySerialNumberData(serialNumberRequestBody);
        verifySerialNumberRequest(serialNumberRequestBody);
    }
    
    private void querySerialNumberData(ATI_REST_SerialNumberRequest serialNumberRequestBody){
        for(ATI_REST_SerialNumberRequest.Inventory serialNumberReq : serialNumberRequestBody.inventory){
            if(!String.isBlank(serialNumberReq.businessCategoryUnit)){
                businessUnitsSet.add(serialNumberReq.businessCategoryUnit.trim());
            }
            if(!String.isBlank(serialNumberReq.item)){
                itemNumbersSet.add(serialNumberReq.item.trim());
            }
            if(!String.isBlank(serialNumberReq.serialNumber)){
                if(String.isBlank(serialNumberReq.majorComponentType)){
                    serialNumbersSet.add(serialNumberReq.serialNumber.trim());
                    mapOfInvSerialNumberWithRequestData.put(serialNumberReq.serialNumber.trim(),JSON.serialize(serialNumberReq));
                }else if(!String.isBlank(serialNumberReq.transmissionSerialNumber) && serialNumberReq.transmissionSerialNumber != '0'){
                    serialNumbersSet.add(serialNumberReq.transmissionSerialNumber.trim());
                }
            }
            if(!String.isBlank(serialNumberReq.serialNumber) && !String.isBlank(serialNumberReq.majorComponentType)){
                majorComponentSerialNumberSet.add(serialNumberReq.serialNumber.trim());
                if(!String.isBlank(serialNumberReq.transmissionSerialNumber) && !String.isBlank(serialNumberReq.vin)){
                    vinNumbersSet.add(serialNumberReq.vin.trim());
                }
            }
        }
        
        if(checkBCCSReadAccess()){
            List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = [SELECT Id,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name='ATI_InventorySyncAccountLookup' AND WOD_2__Value__c != null];
            if(!bccsLst.isEmpty()){
                oemAccount = [SELECT Id FROM Account WHERE Id=:bccsLst.get(0).WOD_2__Value__c];
            }
     	}else{
            throw new ATI_Exception('(Business Category Configuration Setting) '+Label.ATI_Log_Insufficient_access);
        }
        
        if(checkBusinessUnitReadAccess()){
            List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigLst = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c WHERE Name IN:businessUnitsSet];
            if(!businessCategoryConfigLst.isEmpty()){
                for(WOD_2__Business_Category_Configuration__c bu : businessCategoryConfigLst){
                    if(!mapOfInventories.containsKey(bu.Name)){
                        mapOfBusinessConfigs.put(bu.Name,bu);
                    }
                }
            }
        }else{
            throw new ATI_Exception('(Business Category Configuration) '+Label.ATI_Log_Insufficient_access);
        }
        
        if(checkWarrantyProductReadAccess()){
            List<WOD_2__Warranty_Product__c> wpLst = [SELECT Id,Name,WOD_2__Type__c,WOD_2__Track_Type__c FROM WOD_2__Warranty_Product__c 
                                                      WHERE Name IN:itemNumbersSet AND WOD_2__Type__c='Item' AND WOD_2__Track_Type__c='Serialized'];
            if(!wpLst.isEmpty()){
                for(WOD_2__Warranty_Product__c wp :wpLst){
                    if(!mapOfWarrantyProducts.containsKey(wp.Name)){
                        mapOfWarrantyProducts.put(wp.Name,wp);
                    }
                }
            }
        }else{
            throw new ATI_Exception('(Warranty Product) '+Label.ATI_Log_Insufficient_access);
        }
        
        if(checkInventoryReadAccess()){
            List<WOD_2__Inventory__c> invLst = [SELECT Id,Name,WOD_2__Serial_Number__c,WOD_2__Business_Unit__r.Name,WOD_2__Item__r.Name,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN:serialNumbersSet];// AND WOD_2__Type__c=:'Stock'
            if(!invLst.isEmpty()){
                for(WOD_2__Inventory__c inv :invLst){
                    if(!mapOfInventories.containsKey(inv.WOD_2__Serial_Number__c)){
                        mapOfInventories.put(inv.WOD_2__Serial_Number__c,inv);
                    }
                }
            }
        }else{
            throw new ATI_Exception('(Inventory) '+Label.ATI_Log_Insufficient_access);
        }  
        
        if(checkMajorComponentReadAccess()){
            List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,Name,WOD_2__Serial_number__c,WOD_2__Inventory__c,ATI_Type__c FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c IN:majorComponentSerialNumberSet];
            if(!majorCmpLst.isEmpty()){
                for(WOD_2__Major_Component__c majorcmp: majorCmpLst){
                    mapOfMajorComponents.put(majorcmp.WOD_2__Serial_number__c,majorcmp);
                }
            }
        }else{
            throw new ATI_Exception('(Major Component) '+Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void verifySerialNumberRequest(ATI_REST_SerialNumberRequest serialNumberRequestBody){
        Integer  i = 1;
        Set<String> identifierSet = new Set<String>();
        for(ATI_REST_SerialNumberRequest.Inventory serialNumberReq : serialNumberRequestBody.inventory){
            List<String> errorList = new List<String>();
            if(String.isBlank(serialNumberReq.identifier)){
                errorList.add('Identifier is Mandatory');
            }
            else if(!identifierSet.add(serialNumberReq.identifier.trim())){
                errorList.add('Identifier is not unique');
            }
            if(String.isBlank(serialNumberReq.majorComponentType) && oemAccount.isEmpty()){
                errorList.add('Something went wrong, please contact support');
            }
            if(String.isBlank(serialNumberReq.businessCategoryUnit)){
                errorList.add('BusinessCategoryUnit can not be empty');
            }else{
                if(!mapOfBusinessConfigs.containsKey(serialNumberReq.businessCategoryUnit.trim())){
                    errorList.add('BusinessCategoryUnit is invalid');
                }
            }
            
            /*if(!String.isBlank(serialNumberReq.majorComponentType) && !String.isBlank(serialNumberReq.transmissionSerialNumber) && serialNumberReq.transmissionSerialNumber != '0'){
                if(!mapOfInventories.containsKey(serialNumberReq.transmissionSerialNumber.trim()) && !mapOfInvSerialNumberWithRequestData.containskey(serialNumberReq.transmissionSerialNumber.trim())){
                    errorList.add('TransmissionSerialNumber is invalid');
                }
            }*/
            
            /*if(!String.isBlank(serialNumberReq.majorComponentType) && !String.isBlank(serialNumberReq.serialNumber) && 
               mapOfMajorComponents.containsKey(serialNumberReq.serialNumber.trim())){
                   if(!serialNumberReq.majorComponentType.trim().equalsIgnoreCase(mapOfMajorComponents.get(serialNumberReq.serialNumber.trim()).ATI_Type__c)){
                       errorList.add('MajorComponent is invalid');
                   }
            }*/
               
            if(String.isBlank(serialNumberReq.serialNumber)){
                errorList.add('SerialNumber is Mandatory');
            }
            
            if(String.isBlank(serialNumberReq.item)){
                errorList.add('Item can not be empty');
            }else{
                if(!mapOfWarrantyProducts.containsKey(serialNumberReq.item.trim())){
                    errorList.add('Item is invalid');
                }
            }
            if(!String.isBlank(serialNumberReq.shipDate) && ATI_Utils.parseDate(serialNumberReq.shipDate.trim()) == null){
                errorList.add('Invalid ShipDate Format');
            }
            if(!String.isBlank(serialNumberReq.buildDate) && ATI_Utils.parseDate(serialNumberReq.buildDate.trim()) == null){
                errorList.add('Invalid BuildDate Format');
            }
            
            if(ATI_Utils.checkIsBlankData(serialNumberReq.majorComponentType) && ATI_Utils.checkIsBlankData(serialNumberReq.programLevel)){
                errorList.add('ProgramLevel is Mandatory');
            }
            
            if(errorList.size() == 0){
                serialNumberReqLst.add(serialNumberReq);
                serialNumberSuccessSet.add(serialNumberReq.serialNumber.trim());
            }
            else{
                totalFailedRecords++;
                mapOfFailure.put(i,errorList);
                if(!String.isBlank(serialNumberReq.serialNumber)){
                    serialNumberFailedSet.add(serialNumberReq.serialNumber.trim());
                }
            }
            i++;
        }
        totalrecords = i-1;
    }
    
    private static Boolean checkBCCSReadAccess(){
        String objectName = 'WOD_2__Business_Category_Configuration_Setting__c';
        List<String> fields = new List<String>{'WOD_2__Value__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient BCCS Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }        
    }
    
    private static Boolean checkBusinessUnitReadAccess(){
        String objectName = 'WOD_2__Business_Category_Configuration__c';
        List<String> fields = new List<String>{'Name'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient BusinessCategoryConfiguration Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }
    }
    
    private static Boolean checkWarrantyProductReadAccess(){
        String objectName = 'WOD_2__Warranty_Product__c';
        List<String> fields = new List<String>{'Name','WOD_2__Type__c','WOD_2__Track_Type__c'}; //,'WOD_2__Parent_Product__r.Name'
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient WarrantyProduct Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }
    }
    
    public static Boolean checkInventoryReadAccess(){
        String objectName = 'WOD_2__Inventory__c';
        List<String> fields = new List<String>{'Name','WOD_2__Serial_Number__c','WOD_2__Business_Unit__r.Name','WOD_2__Item__r.Name','WOD_2__Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient Inventory Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }
    }
    
    private static Boolean checkVehicleInfoReadAccess(){
        String objectName = 'ATI_VIN_Transmission_Mapper__c';
        List<String> fields = new List<String>{'ATI_Inventory__r.Name','ATI_Inventory__c','ATI_Vehicle_Information__c','ATI_Vehicle_Information__r.Name'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient VehicleTransmissionMapper Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }
    }
    
    public static Boolean checkMajorComponentReadAccess(){
        String objectName = 'WOD_2__Major_Component__c';
        List<String> fields = new List<String>{'Name','WOD_2__Serial_number__c','ATI_Type__c','WOD_2__Inventory__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient MajorComponent Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('SerialNumberSync',errortext);
            return false;
        }     
    }    
}