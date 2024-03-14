/* Name: ATI_REST_PartPriceSync
Description : Endpoint which syncs partprice required for warranty purposes 
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       21/12/2020      INITIAL DEVELOPMENT             20670                
*/
@RestResource(urlMapping = '/ATIRestPartPriceSync/*')
global with sharing class ATI_REST_PartPriceSync implements ATI_LoggableInterface{
    @HttpPost
    global Static ATI_REST_PartPriceSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_PartPriceSync partPriceSyncObj = new ATI_REST_PartPriceSync();
        ATI_REST_PartPriceSyncResponse partPriceResponse = partPriceSyncObj.partPrice(requestBody);
        return partPriceResponse;
    }
    
    public ATI_REST_PartPriceSyncResponse partPrice(String partPriceRequest){
        ATI_REST_PartPriceSyncResponse partPriceResponse = new ATI_REST_PartPriceSyncResponse();
        WOD_2.ResponseWrapper response = processType(partPriceRequest);
        if(response != null && response.data != null && response.data != '') {
            partPriceResponse = (ATI_REST_PartPriceSyncResponse)JSON.deserialize(response.data,ATI_REST_PartPriceSyncResponse.class);
        }else{
            partPriceResponse.status = 'Fail';
            partPriceResponse.data = null;
            partPriceResponse.interfaceName = 'I-264 – Part Price';
            partPriceResponse.message = response.errormessage;
            createLog('PartPriceSync',partPriceRequest,JSON.serialize(partPriceResponse),'Failed',null,null);
        }
        return partPriceResponse;   
    }
    
    private ATI_REST_PartPriceValidator partPriceValidatorObj{get; private set;}
    private List<WOD_2__Warranty_Product_Pricebook__c> wpPricebookInsertOrUpdateLst{get; private set;}
    private Map<String,WOD_2__Warranty_Product_Pricebook__c> mapOfInsertedOrUpdatedWPPriceBooks{get; private set;}
    public WOD_2.ResponseWrapper processType(String partPriceRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_PartPriceRequest partPriceReqObj = new ATI_REST_PartPriceRequest();
        partPriceValidatorObj = new ATI_REST_PartPriceValidator();
        try{
            partPriceReqObj = ATI_REST_PartPriceRequest.parse(partPriceRequest);
            partPriceValidatorObj.validateReqest(partPriceReqObj);
            wpPricebookInsertOrUpdateLst = new List<WOD_2__Warranty_Product_Pricebook__c>();
            mapOfInsertedOrUpdatedWPPriceBooks = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
            Id partPriceRecordTypeId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Price').getRecordTypeId();
            for(ATI_REST_PartPriceRequest.PartPriceInfo partPriceReq : partPriceValidatorObj.partPriceReqLst){
                WOD_2__Warranty_Product_Pricebook__c wpPriceBook;
                String effectiveDate = String.valueOf(ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()));
                String endDate = String.valueOf(ATI_Utils.parseDate(partPriceReq.endDate.trim()));
                String uniqueWPB = partPriceReq.manufNumber.trim().toUppercase()+':'+partPriceReq.priceGroup.trim().toUppercase()+':'+effectiveDate+':'+endDate;
                String uniqueWPBnew = partPriceReq.manufNumber.trim().toUppercase()+':'+partPriceReq.priceGroup.trim().toUppercase();//ALSN-16
                
                /*Added by Anjali for i264 bug where existing record end date should not overlap with current end Date */
                
                if(!partPriceValidatorObj.wpPricebookMapnew.isEmpty() && partPriceValidatorObj.wpPricebookMapnew.containsKey(uniqueWPBnew) &&
                   ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()) >partPriceValidatorObj.wpPricebookMapnew.get(uniqueWPBnew).WOD_2__Valid_From__c){
                       
                       wpPriceBook = partPriceValidatorObj.wpPricebookMapnew.get(uniqueWPBnew);
                       wpPriceBook.WOD_2__Valid_Until__c = ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()) -1;
                       wpPricebookInsertOrUpdateLst.add(wpPriceBook);
                   } /*End */
                   
                //System.debug('uniqueWPB>>>>>> '+uniqueWPB);
                if(!partPriceValidatorObj.wpPricebookMap.isEmpty() && partPriceValidatorObj.wpPricebookMap.containsKey(uniqueWPB)){
                    wpPriceBook = partPriceValidatorObj.wpPricebookMap.get(uniqueWPB);
                }else{
                    wpPriceBook = new WOD_2__Warranty_Product_Pricebook__c();
                    wpPriceBook.Name = partPriceReq.manufNumber;
                    wpPriceBook.RecordTypeId = partPriceRecordTypeId;
                    if(partPriceValidatorObj.warrantyProductMap.containsKey(partPriceReq.manufNumber.trim())){
                        wpPriceBook.WOD_2__Warranty_Product__c = partPriceValidatorObj.warrantyProductMap.get(partPriceReq.manufNumber.trim()).Id; 
                    }
                    wpPriceBook.ATI_Price_Group__c  = partPriceReq.priceGroup;
                    wpPriceBook.WOD_2__Valid_From__c = ATI_Utils.parseDate(partPriceReq.effectiveDate.trim());
                    wpPriceBook.WOD_2__Valid_Until__c = ATI_Utils.parseDate(partPriceReq.endDate.trim());
                }
                wpPriceBook.WOD_2__Price__c = Decimal.valueof(partPriceReq.value.trim());
                wpPriceBook.WOD_2__Unit_Price__c = Decimal.valueof(partPriceReq.value.trim());
                wpPriceBook.ATI_Active__c = true;
                wpPriceBook.ATI_Unit_of_Measure__c = partPriceReq.priceUnit;
                wpPriceBook.ATI_Condition_Type__c = partPriceReq.conditionType;  
                wpPricebookInsertOrUpdateLst.add(wpPriceBook);
                //System.debug('wpPricebookInsertOrUpdateLst>>>>>> '+wpPricebookInsertOrUpdateLst);
            }
            if(!wpPricebookInsertOrUpdateLst.isEmpty()){
                createOrUpdateWPPriceBooks();
            }
            responseWrapper.data = JSON.serialize(createResponse(partPriceReqObj.partPrice));
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('message'+ e.getMessage());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return responseWrapper;
    }
    
    private void createOrUpdateWPPriceBooks(){
        String objectName = 'WOD_2__Warranty_Product_Pricebook__c';
        List<String> wpFieldsForRecordInsertion = new List<String>{'WOD_2__Warranty_Product__c','ATI_Price_Group__c','ATI_Unit_of_Measure__c','WOD_2__Price__c','ATI_Condition_Type__c','WOD_2__Valid_From__c','WOD_2__Valid_Until__c'};
            List<String> wpFieldsForRecordUpdation = new List<String>{'WOD_2__Price__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wpPriceBookCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,wpFieldsForRecordInsertion);
        ATI_Utils.NoAccessObjectFieldWrapper wpPriceBookUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,wpFieldsForRecordUpdation);
        if(wpPriceBookCreateAccessCheck.noAccessObjectList.size() == 0 && wpPriceBookCreateAccessCheck.noAccessFieldList.size() == 0 && wpPriceBookUpdateAccessCheck.noAccessObjectList.size() == 0 && wpPriceBookUpdateAccessCheck.noAccessFieldList.size() == 0){
            upsert wpPricebookInsertOrUpdateLst;
            fetchWPPriceBooks();
        } else {
            String errortext = 'Insufficient WPPriceBook Create Access>> '+JSON.serialize(wpPriceBookCreateAccessCheck)+'Insufficient WPPriceBook Update Access>> '+JSON.serialize(wpPriceBookUpdateAccessCheck);
            ATI_LogService.createLogForAccess('PartPriceSync',errortext);
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void fetchWPPriceBooks(){
        if(ATI_REST_ExchangeRateValidator.checkReadAccess()){
            List<WOD_2__Warranty_Product_Pricebook__c> wpPricebookLst = [SELECT Id,Name,WOD_2__Warranty_Product__r.Name,ATI_Price_Group__c,WOD_2__Valid_From__c,ATI_Unit_of_Measure__c,WOD_2__Valid_Until__c FROM WOD_2__Warranty_Product_Pricebook__c
                                                                         WHERE WOD_2__Warranty_Product__r.Name IN:partPriceValidatorObj.setOfPartNumbers AND ATI_Price_Group__c IN:partPriceValidatorObj.setOfPriceGroups 
                                                                         AND WOD_2__Valid_From__c IN:partPriceValidatorObj.setOfEffectiveDates AND WOD_2__Valid_Until__c IN:partPriceValidatorObj.setOfEndDates AND ATI_Unit_of_Measure__c IN:partPriceValidatorObj.setOfPriceUnits
                                                                         AND RecordType.DeveloperName='ATI_Part_Price' AND ATI_Active__c=true];
            if(!wpPricebookLst.isEmpty()){
                for(WOD_2__Warranty_Product_Pricebook__c wpPriceBook : wpPricebookLst){
                    String uniqueWPPriceBook = wpPricebook.WOD_2__Warranty_Product__r.Name.toUppercase()+':'+wpPricebook.ATI_Price_Group__c.toUppercase()+':'+String.valueOf(wpPricebook.WOD_2__Valid_From__c)+':'+String.valueOf(wpPricebook.WOD_2__Valid_Until__c);
                    mapOfInsertedOrUpdatedWPPriceBooks.put(uniqueWPPriceBook,wpPriceBook);
                }
            }
            //System.debug('mapOfInsertedOrUpdatedWPPriceBooks>>>>>>>> '+mapOfInsertedOrUpdatedWPPriceBooks);
        }else{
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
        }
    }
    
    private ATI_REST_PartPriceSyncResponse createResponse(List<ATI_REST_PartPriceRequest.PartPriceInfo> partPriceRequest){
        ATI_REST_PartPriceSyncResponse partPriceResponse = new ATI_REST_PartPriceSyncResponse();
        List<ResponseData> responseDataLst = new List<ResponseData>();
        Integer i = 1;
        for(ATI_REST_PartPriceRequest.PartPriceInfo partPriceReq : partPriceRequest){
            ResponseData data = new ResponseData();
            data.identifier = partPriceReq.identifier;
            String effectiveDate = String.valueOf(ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()));
            String endDate = String.valueOf(ATI_Utils.parseDate(partPriceReq.endDate.trim()));
            String uniqueWPB = partPriceReq.manufNumber.trim().toUppercase()+':'+partPriceReq.priceGroup.trim().toUppercase()+':'+effectiveDate+':'+endDate;
            //System.debug('uniqueWPB>>>>>> '+uniqueWPB);
            if(!partPriceValidatorObj.mapOfFailure.isEmpty() && partPriceValidatorObj.mapOfFailure.containsKey(i)){
                data.message = String.Join(partPriceValidatorObj.mapOfFailure.get(i),', ') ;
            }else{
                if(!partPriceValidatorObj.wpPricebookMap.isEmpty() && partPriceValidatorObj.wpPricebookMap.containskey(uniqueWPB)){
                    data.message = 'Record Updated Successfully';
                }else{
                    data.message = 'Record Inserted Successfully';
                }
                if(!mapOfInsertedOrUpdatedWPPriceBooks.isEmpty() && mapOfInsertedOrUpdatedWPPriceBooks.containsKey(uniqueWPB)){
                    data.transactionId = mapOfInsertedOrUpdatedWPPriceBooks.get(uniqueWPB).Id;
                    data.name = mapOfInsertedOrUpdatedWPPriceBooks.get(uniqueWPB).Name;
                }
            }
            responseDataLst.add(data);
            i++;
        }
        partPriceResponse.interfaceName = 'I-264 – Part Price';
        partPriceResponse.data = responseDataLst;
        if(partPriceValidatorObj.mapOfFailure.isEmpty()){
            partPriceResponse.status = 'Success';
            partPriceResponse.message =  'All the records have been inserted / updated successfully';
            createLog('PartPriceSync',JSON.serialize(partPriceRequest),JSON.serialize(partPriceResponse),'Success',null,JSON.serialize(partPriceValidatorObj.partPriceSuccessSet));
        }else if(partPriceValidatorObj.mapOfFailure.size() ==  partPriceRequest.size()){
            partPriceResponse.status = 'Failed';
            partPriceResponse.message = 'All the records have failed to insert / update';
            createLog('PartPriceSync',JSON.serialize(partPriceRequest),JSON.serialize(partPriceResponse),'Failed',JSON.serialize(partPriceValidatorObj.partPriceFailedSet),JSON.serialize(partPriceValidatorObj.partPriceFailedSet));
        }else{
            partPriceResponse.status = 'Partial Success';
            partPriceResponse.message =  'Few records have not been inserted / updated.';
            createLog('PartPriceSync',JSON.serialize(partPriceRequest),JSON.serialize(partPriceResponse),'Partial Success',JSON.serialize(partPriceValidatorObj.partPriceFailedSet),'Success>> '+JSON.serialize(partPriceValidatorObj.partPriceSuccessSet)+',Failure>> '+JSON.serialize(partPriceValidatorObj.partPriceFailedSet));
        }
        return partPriceResponse;
    }
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_PartPrice_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!partPriceValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(partPriceValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = partPriceValidatorObj.totalRecords-partPriceValidatorObj.totalFailedRecords;
                objLogSerWrp.failureRecordCount = partPriceValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_PartPriceSyncResponse responseWrapperObj = (ATI_REST_PartPriceSyncResponse)System.JSON.deserialize(response,ATI_REST_PartPriceSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = partPriceValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = partPriceValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            objLogSerWrp.totalRecordCount = partPriceValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
	Description    :   A wrapper class to capture the PartPrice Rest data.
	*************************************************************************/
    global class ATI_REST_PartPriceSyncResponse{
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