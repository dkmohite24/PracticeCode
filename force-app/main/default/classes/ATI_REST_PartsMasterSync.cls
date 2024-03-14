/* Name: ATI_REST_PartsMasterSync
Description : Endpoint which sync parts information requied for warranty purposes
Author : Tavant(Punam)
History:
VERSION     AUTHOR                DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         11/01/2021          INITIAL DEVELOPMENT                            
*/
@RestResource(urlMapping = '/ATIRestPartsMasterSync/*')
global with sharing class ATI_REST_PartsMasterSync implements ATI_LoggableInterface {
    
    @HttpPost
    global Static ATI_REST_PartsMasterSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_PartsMasterSync partMasterSyncObj = new ATI_REST_PartsMasterSync();
        ATI_REST_PartsMasterSyncResponse partMasterResponse = partMasterSyncObj.partsMaster(requestBody);
        return partMasterResponse;
    }
    
    public ATI_REST_PartsMasterSyncResponse partsMaster(String partsMasterRequest){
        ATI_REST_PartsMasterSyncResponse partsMasterResponse = new ATI_REST_PartsMasterSyncResponse();
        WOD_2.ResponseWrapper response = processType(partsMasterRequest);
        if(response != null && response.data != null && response.data != '') {
            partsMasterResponse = (ATI_REST_PartsMasterSyncResponse)Json.deserialize(response.data,ATI_REST_PartsMasterSyncResponse.class);
        }else {
            partsMasterResponse.status = 'Failed';
            partsMasterResponse.data = null;
            partsMasterResponse.message = response.errormessage;
            createLog('PartsMasterSync',partsMasterRequest,JSON.serialize(partsMasterResponse),'Failed',null,null);
        }
        return partsMasterResponse;   
    }
    
    private ATI_REST_PartsMasterValidator partsMasterValidatorObj{get; private set;}
    private List<WOD_2__Warranty_Product__c> partsInsertOrUpdateLst{get; private set;}
    private List<WOD_2__Warranty_Product__c> childpartsInsertOrUpdateLst{get; private set;}
    private Map<String,WOD_2__Warranty_Product__c> mapOfInsertOrUpdateParts{get; private set;}
    private Map<String,WOD_2__Warranty_Product__c> mapOfInsertedParts{get; private set;}
    
    public WOD_2.ResponseWrapper processType(String partsMasterRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_PartsMasterRequest partsMasterReqObj = new ATI_REST_PartsMasterRequest();
        partsMasterValidatorObj = new ATI_REST_PartsMasterValidator();
        try{
            partsMasterReqObj = (ATI_REST_PartsMasterRequest)System.JSON.deserialize(partsMasterRequest,ATI_REST_PartsMasterRequest.class);
            system.debug('partsMasterReqObj**'+partsMasterReqObj);
            partsMasterValidatorObj.validateReqest(partsMasterReqObj);
            partsInsertOrUpdateLst = new List<WOD_2__Warranty_Product__c>();
            childpartsInsertOrUpdateLst= new List<WOD_2__Warranty_Product__c>();
            mapOfInsertOrUpdateParts = new Map<String,WOD_2__Warranty_Product__c>();
            mapOfInsertedParts = new Map<String,WOD_2__Warranty_Product__c>();
            //Set<String> buSet = new Set<String>();
            Set<String> parentProdSet = new Set<String>();
            Set<String> prodCategorySet = new Set<String>();
            //Map<String,String> buNameIdMap = new Map<String,String>();
            Boolean hierachyError=false;
            Boolean isChildPart= false;
            Map<String,ATI_REST_PartsMasterRequest.WarrantyProductInformation> prodNameDetailsMap = new Map<String,ATI_REST_PartsMasterRequest.WarrantyProductInformation>();
            
            Integer i=1;
            system.debug('partsMasterValidatorObj.warrantyProductReqLst'+partsMasterValidatorObj.warrantyProductReqLst);
            Set<String> prodNamesTobePassed = new Set<String>();
            for(ATI_REST_PartsMasterRequest.WarrantyProductInformation partReq: partsMasterValidatorObj.warrantyProductReqLst){
                //buSet.add(partReq.businessCategoryUnit);
                if(partReq.parentProduct!=''){
                    parentProdSet.add(partReq.parentProduct);
                    prodNamesTobePassed.add(partReq.parentProduct);
                }
                prodCategorySet.add(partReq.thirtyTwoMiNum);
                prodNamesTobePassed.add(partReq.thirtyTwoMiNum);
                //prodCategorySet.add(partReq.categoryNum2);
                prodNameDetailsMap.put(partReq.productCode,partReq);
                
            }

            Map<String,ATI_Managed_Serialized_Part__c> serializedPartMap = new Map<String,ATI_Managed_Serialized_Part__c>();
            for(ATI_Managed_Serialized_Part__c partObj : [SELECT Id,Name FROM ATI_Managed_Serialized_Part__c WHERE Name IN :prodNameDetailsMap.keySet()]){
                serializedPartMap.put(partObj.Name,partObj);
            }
            
            Map<String,WOD_2__Warranty_Product__c> parentNameIdMap= new Map<String,WOD_2__Warranty_Product__c>();
            Map<String,WOD_2__Warranty_Product__c> prodCategoryNameIdMap= new Map<String,WOD_2__Warranty_Product__c>();
            Map<String,WOD_2__Warranty_Product__c> prodNameIdMap= getParentProductDetails(prodNamesTobePassed);
            for(String key: prodNameIdMap.keySet()){
                if(parentProdSet.contains(key)){
                    parentNameIdMap.put(key,prodNameIdMap.get(key));
                }
                if(prodCategorySet.contains(key)){
                    prodCategoryNameIdMap.put(key,prodNameIdMap.get(key));
                }
            }
            
            for(ATI_REST_PartsMasterRequest.WarrantyProductInformation partReq : partsMasterValidatorObj.warrantyProductReqLst){
                List<String> errorList = new List<String>();
                hierachyError= false;
                isChildPart= false;
                
                WOD_2__Warranty_Product__c partsDataObj = new WOD_2__Warranty_Product__c();
                if(partsMasterValidatorObj.mapOfProducts.isEmpty()){
                     partsDataObj = new WOD_2__Warranty_Product__c();
                }else if(!partsMasterValidatorObj.mapOfProducts.isEmpty() && partsMasterValidatorObj.mapOfProducts.containsKey(partReq.externalProductCode)){
                    partsDataObj = partsMasterValidatorObj.mapOfProducts.get(partReq.externalProductCode);
                       
                }
                    partsDataObj.WOD_2__Business_Unit__c = partsMasterValidatorObj.buNameIdMap.get(partReq.businessCategoryUnit);
                	partsDataObj.WOD_2__Business_Units__c = partReq.businessCategoryUnit;
                    partsDataObj.WOD_2__Description__c = partReq.description;
                    partsDataObj.External_Product_Code__c = partReq.externalProductCode.trim();
                    partsDataObj.WOD_2__Item_Type__c = partReq.itemType;
                	partsDataObj.ATI_Part_Description__c = (partReq.itemType == 'Part') ? partReq.description : '';
                    if(partReq.parentProduct!= '' && parentNameIdMap.get(partReq.parentProduct)!= null){
                        if((partReq.prodType=='Model' && parentNameIdMap.get(partReq.parentProduct).WOD_2__Type__c=='Product') ||(partReq.prodType=='Item' && parentNameIdMap.get(partReq.parentProduct).WOD_2__Type__c=='Model')){
                            partsDataObj.WOD_2__Parent_Product__c = parentNameIdMap.get(partReq.parentProduct).Id;
                        }else{
                            hierachyError=true;
                            errorList.add(Label.ATI_Product_HierarchyError);
                        }
                    }
                    if(!hierachyError){
                        WOD_2__Warranty_Product__c proTest= new WOD_2__Warranty_Product__c();
                        if((!parentNameIdMap.isEmpty() && !parentNameIdMap.containsKey(partReq.parentProduct)) || parentNameIdMap.isEmpty()){
                            if(!String.isBlank(partReq.parentProduct)){
                                if(prodNameDetailsMap.containsKey(partReq.parentProduct)){
                                    if((partReq.prodType=='Model' && prodNameDetailsMap.get(partReq.parentProduct).prodType!='Product') ||
                                    (partReq.prodType=='Item' && prodNameDetailsMap.get(partReq.parentProduct).prodType!='Model')){
                                        hierachyError=true;
                                        errorList.add(Label.ATI_Product_HierarchyError);
                                                
                                    }else{
                                        isChildPart= true;
                                        partsDataObj.WOD_2__Parent_Product__r = new WOD_2__Warranty_Product__c( External_Product_Code__c=prodNameDetailsMap.get(partReq.parentProduct).externalProductCode);
                                        
                                    }
                                
                                }else{
                                    hierachyError=true;
                                    errorList.add(Label.ATI_Invalid_ParentError);
                                }
                            }
                        }
                        //ALSN-17 Commenting the code as it doesn't seem to refer correct values always and the parentProduct can correctly assign the hierarchy.
                        /*
                        if(String.isNotBlank(partReq.thirtyTwoMiNum) && prodCategoryNameIdMap.get(partReq.thirtyTwoMiNum)== null){
                            errorList.add('Please enter valid 32M number.');
                            hierachyError=true;
                        }*/
                        partsDataObj.Name = partReq.productCode.trim();
                        partsDataObj.WOD_2__Product_Name__c = partReq.productName.trim();
                        //Task-25979
                        if(serializedPartMap.containsKey(partReq.productCode.trim()) || partReq.itemType.trim()=='Machine'){
                            partsDataObj.WOD_2__Track_Type__c = 'Serialized';
                        }else{
                            partsDataObj.WOD_2__Track_Type__c = 'Non-Serialized';
                        }
                        
                        partsDataObj.WOD_2__Type__c = partReq.prodType;
                        partsDataObj.WOD_2__Units_Of_Measure__c = partReq.unitOfMeasure;
                        //ALSN-126 will be set to true only on insert as default value through field
                        //partsDataObj.Active__c = Boolean.valueOf(partReq.active);
                        partsDataObj.Hardware_Model__c = partReq.hardwareModel;
                        partsDataObj.Name_Plate_Model__c = partReq.nameplateModel;
                        partsDataObj.Extended_Base_Model__c = partReq.extendedBaseModel;
                        partsDataObj.EE_Number__c = partReq.eeNumber;
                        if(partReq.thirtyTwoMiNum!= '' && partReq.thirtyTwoMiNum!= null && prodCategoryNameIdMap.get(partReq.thirtyTwoMiNum)!=null){
                         partsDataObj.X32M_Number__c = prodCategoryNameIdMap.get(partReq.thirtyTwoMiNum).Id;
                        }
                        
                        partsDataObj.RMA_Policy__c = Boolean.valueOf(partReq.rmaPolicy);
                        partsDataObj.Primary_Failed_Part_Prohibit__c = Boolean.valueOf(partReq.primaryFailedPartProhibit);
                        partsDataObj.Hierarchy__c = partReq.hierarchy;
                        //partsDataObj.G_Number__c = partReq.gNumber;

                        //for(ATI_REST_PartsMasterRequest.PartMarkupDetails partMark: partReq.partMarkup){
                            if(partReq.partMarkup.partMarkupPercentage!= null && partReq.partMarkup.partMarkupPercentage!='' && Decimal.valueOf(partReq.partMarkup.partMarkupPercentage)!=0){
                                partsDataObj.Part_Markup_Percentage__c = Decimal.valueOf(partReq.partMarkup.partMarkupPercentage);
                            }else{
                                partsDataObj.Part_Markup_Percentage__c = NULL;
                            }
                            partsDataObj.Effective_Date__c = ATI_Utils.parseDate(partReq.partMarkup.effectiveDate);
                        //}           
                        if(hierachyError==false && isChildPart==false){
                            partsInsertOrUpdateLst.add(partsDataObj);
                        
                        }
                        if(isChildPart==true){
                            childpartsInsertOrUpdateLst.add(partsDataObj);
                        }
                    }
                    if(partsMasterValidatorObj.mapOfProducts.isEmpty()){
                        mapOfInsertedParts.put(partReq.externalProductCode,partsDataObj);
                    }
                    if(errorList.size() != 0){
                        partsMasterValidatorObj.setOfFailedProducts.add(partReq.externalProductCode);
                        partsMasterValidatorObj.totalFailedRecords++;
                        partsMasterValidatorObj.mapOfFailure.put(i,errorList);
                    }
                    
                i++;
            }
            
            if(!partsInsertOrUpdateLst.isEmpty() || !childpartsInsertOrUpdateLst.isEmpty()){
                createOrUpdateParts();
            }
            responseWrapper.data = JSON.serialize(createResponse(partsMasterReqObj.warrantyProduct));
            responseWrapper.status = true;
        }catch(Exception e){
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
            
        }
        return responseWrapper;
    }
    
    private static List<WOD_2__Warranty_Product__c> removeDuplicates(List<WOD_2__Warranty_Product__c> partsMasterList){
        return new List<WOD_2__Warranty_Product__c>(new Set<WOD_2__Warranty_Product__c>(partsMasterList));
    }
    
    private void createOrUpdateParts(){
        String objectName = 'WOD_2__Warranty_Product__c';
        List<String> fields = new List<String>{'WOD_2__Business_Unit__c','WOD_2__Description__c','External_Product_Code__c','WOD_2__Item_Type__c','WOD_2__Parent_Product__c',/*'WOD_2__Parent_Product__r',*/'Name','WOD_2__Product_Name__c','WOD_2__Track_Type__c','WOD_2__Type__c','WOD_2__Units_Of_Measure__c','Active__c','Hardware_Model__c','Name_Plate_Model__c','Extended_Base_Model__c','EE_Number__c','X32M_Number__c','X70M_Number__c','RMA_Policy__c','Primary_Failed_Part_Prohibit__c','Hierarchy__c','Part_Markup_Percentage__c','Effective_Date__c'};
        ATI_Utils.NoAccessObjectFieldWrapper partsCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,fields);
        ATI_Utils.NoAccessObjectFieldWrapper partsUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,fields);
        if(partsCreateAccessCheck.noAccessObjectList.size() == 0 && partsCreateAccessCheck.noAccessFieldList.size() == 0 && partsUpdateAccessCheck.noAccessObjectList.size() == 0 && partsUpdateAccessCheck.noAccessFieldList.size() == 0){        
            if(!partsInsertOrUpdateLst.isEmpty()){
                List<WOD_2__Warranty_Product__c> partsMasterLst = removeDuplicates(partsInsertOrUpdateLst);
                partsInsertOrUpdateLst.clear();
                partsInsertOrUpdateLst.addAll(partsMasterLst);
                upsert partsInsertOrUpdateLst;
                
                fetchPartsInformation();
            }
            if(!childpartsInsertOrUpdateLst.isEmpty()){
                List<WOD_2__Warranty_Product__c> newChildPartList = new List<WOD_2__Warranty_Product__c>();
                for(WOD_2__Warranty_Product__c prod: childpartsInsertOrUpdateLst){
                    List<String> errorList = new List<String>();
                    Integer i=1;
                    if(mapOfInsertOrUpdateParts.containsKey(prod.WOD_2__Parent_Product__r.External_Product_Code__c)){
                        prod.WOD_2__Parent_Product__c= mapOfInsertOrUpdateParts.get(prod.WOD_2__Parent_Product__r.External_Product_Code__c).Id;
                        prod.WOD_2__Parent_Product__r=null;
                        newChildPartList.add(prod);
                    }else{
                        errorList.add('Parent Product ('+prod.WOD_2__Parent_Product__r.External_Product_Code__c+') is not valid.');
                       
                    }
                    if(errorList.size() != 0){
                        partsMasterValidatorObj.setOfFailedProducts.add(prod.External_Product_Code__c);
                        partsMasterValidatorObj.totalFailedRecords++;
                        partsMasterValidatorObj.mapOfFailure.put(i,errorList);
                    }
                    i++;
                }
                if(newChildPartList.size()>0){
                    upsert newChildPartList;
                    fetchPartsInformation();
                }
            }
            
        } else {
            String errortext = 'Insufficient Warranty product Create Access-->> '+JSON.serialize(partsCreateAccessCheck)+'Insufficient Warranty Product Update Access-->> '+JSON.serialize(partsUpdateAccessCheck);
            ATI_LogService.createLogForAccess('PartsMasterSync',errortext);
        }
    }
    
    private void fetchPartsInformation(){
        if(ATI_REST_PartsMasterValidator.checkReadAccess()){
            List<WOD_2__Warranty_Product__c> wpLst = [SELECT Id,WOD_2__Business_Unit__c,WOD_2__Description__c,External_Product_Code__c,WOD_2__Item_Type__c,WOD_2__Parent_Product__c,Name,WOD_2__Product_Name__c,WOD_2__Track_Type__c,WOD_2__Type__c,WOD_2__Units_Of_Measure__c,Active__c,Hardware_Model__c,Name_Plate_Model__c,Extended_Base_Model__c,EE_Number__c,X32M_Number__c,X70M_Number__c,RMA_Policy__c,Primary_Failed_Part_Prohibit__c,Hierarchy__c,Part_Markup_Percentage__c,Effective_Date__c
                                                      FROM WOD_2__Warranty_Product__c WHERE External_Product_Code__c IN:partsMasterValidatorObj.setOfExternalIds];
            if(!wpLst.isEmpty()){
                for(WOD_2__Warranty_Product__c prod : wpLst){
                    mapOfInsertOrUpdateParts.put(prod.External_Product_Code__c,prod);
                }
            }
        }
    }
    
    private ATI_REST_PartsMasterSyncResponse createResponse(List<ATI_REST_PartsMasterRequest.WarrantyProductInformation> partsRequest){
            ATI_REST_PartsMasterSyncResponse partsResponse = new ATI_REST_PartsMasterSyncResponse();
            List<ResponseData> responseDataLst = new List<ResponseData>();
            Integer i = 1;
            for(ATI_REST_PartsMasterRequest.WarrantyProductInformation partsReq : partsRequest){
                ResponseData data = new ResponseData();
                if(!partsMasterValidatorObj.mapOfFailure.isEmpty() && partsMasterValidatorObj.mapOfFailure.containsKey(i)){
                    data.message = String.Join(partsMasterValidatorObj.mapOfFailure.get(i),', ') ;
                }else{
                    if(!mapOfInsertedParts.isEmpty() && mapOfInsertedParts.containsKey(partsReq.externalProductCode)){
                        data.message = Label.ATI_Record_Insert_Message;
                    }else{
                        data.message = Label.ATI_Record_Update_Message;    
                    }
                }
                if(!mapOfInsertOrUpdateParts.isEmpty() && mapOfInsertOrUpdateParts.containsKey(partsReq.externalProductCode)){
                    //data.identifier= partsReq.identifier;
                    data.transactionId = mapOfInsertOrUpdateParts.get(partsReq.externalProductCode).Id;
                    data.name = mapOfInsertOrUpdateParts.get(partsReq.externalProductCode).External_Product_Code__c;
                }
                data.identifier= partsReq.identifier;
                responseDataLst.add(data);
                i++;
            }
            partsResponse.interfaceName = 'I721- Part Master';
            partsResponse.data = responseDataLst;
            if(partsMasterValidatorObj.mapOfFailure.isEmpty()){
                partsResponse.status = 'Success';
                partsResponse.message =  Label.ATI_Success_Message;
                createLog('PartsMasterSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Success',null,JSON.serialize(partsMasterValidatorObj.setOfSuccessRecords));
            }else if(partsMasterValidatorObj.mapOfFailure.size() ==  partsRequest.size()){
                partsResponse.status = 'Failed';
                partsResponse.message = Label.ATI_Failed_Message;
                createLog('PartsMasterSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Failed',JSON.serialize(partsMasterValidatorObj.setOfFailedProducts),JSON.serialize(partsMasterValidatorObj.setOfFailedProducts));
            }else{
                partsResponse.status = 'Partial Success';
                partsResponse.message =  Label.ATI_PartialSuccess_Message;
                createLog('PartsMasterSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Partial Success',JSON.serialize(partsMasterValidatorObj.setOfFailedProducts),'Success Records-->> '+JSON.serialize(partsMasterValidatorObj.setOfSuccessRecords)+',Failed Records-->> '+JSON.serialize(partsMasterValidatorObj.setOfFailedProducts));
            }
            return partsResponse;
    }
    
    public static Map<String,WOD_2__Warranty_Product__c> getParentProductDetails(Set<String> prodNameSet){ 
        Map<String,WOD_2__Warranty_Product__c> productNameIdMap = new Map<String,WOD_2__Warranty_Product__c>();
        
        if(prodNameSet!= null && prodNameSet.size()>0){
            if(ATI_REST_PartsMasterValidator.checkReadAccess()){
                List<WOD_2__Warranty_Product__c> prodDetailsList =[select Id,External_Product_Code__c,/*Name,*/WOD_2__Type__c From WOD_2__Warranty_Product__c Where External_Product_Code__c IN: prodNameSet];
                if(prodDetailsList!= null && prodDetailsList.size()>0){
                    for(WOD_2__Warranty_Product__c prod: prodDetailsList){
                        productNameIdMap.put(prod.External_Product_Code__c, prod);
                    }
                }
            }
        }
        return productNameIdMap;
    }
    
    private void createLog(String processName, String request, String response, String status,String identifier, String primaryKey){
        system.debug('request JSON'+request);
        system.debug('response JSON'+response);
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_PartsMaster_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!partsMasterValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(partsMasterValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = partsMasterValidatorObj.totalRecords-partsMasterValidatorObj.totalFailedRecords;
                objLogSerWrp.failureRecordCount = partsMasterValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_PartsMasterSyncResponse responseWrapperObj = (ATI_REST_PartsMasterSyncResponse)System.JSON.deserialize(response,ATI_REST_PartsMasterSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = partsMasterValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = partsMasterValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            /*if(primaryKey == null){
                WOD_2.ResponseWrapper responseWrapperObj = (WOD_2.ResponseWrapper)System.JSON.deserialize(response,WOD_2.ResponseWrapper.class);
                objLogSerWrp.errortext = responseWrapperObj.errormessage;
            }*/
            objLogSerWrp.totalRecordCount = partsMasterValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
    Description    :   A wrapper class to capture the Parts Information Rest data.
    *************************************************************************/
    global class ATI_REST_PartsMasterSyncResponse{
        global String status;
        global String message;
        global String interfaceName;
        global List<ResponseData> data;
    }
    global class ResponseData{
        global String identifier;
        global String name;
        global String transactionId;
        global String message;
    }


}