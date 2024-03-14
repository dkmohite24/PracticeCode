/* Name: ATI_REST_PartCostSync
Description : Endpoint which sync part cost information requied for warranty purposes
Author : Tavant(Punam)
History:
VERSION     AUTHOR                DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         18/01/2021          INITIAL DEVELOPMENT                            
*/
@RestResource(urlMapping = '/ATIRestPartCostSync/*')
global with sharing class ATI_REST_PartCostSync implements ATI_LoggableInterface {
    @HttpPost
    global Static ATI_REST_PartCostSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_PartCostSync partMasterSyncObj = new ATI_REST_PartCostSync();
        ATI_REST_PartCostSyncResponse partCostResponse = partMasterSyncObj.partsCost(requestBody);
        return partCostResponse;
    }
    
    public ATI_REST_PartCostSyncResponse partsCost(String partsCostRequest){
        ATI_REST_PartCostSyncResponse partCostResponse = new ATI_REST_PartCostSyncResponse();
        WOD_2.ResponseWrapper response = processType(partsCostRequest);
        if(response != null && response.data != null && response.data != '') {
            partCostResponse = (ATI_REST_PartCostSyncResponse)Json.deserialize(response.data,ATI_REST_PartCostSyncResponse.class);
        }else {
            partCostResponse.status = 'Fail';
            partCostResponse.data = null;
            partCostResponse.message = response.errormessage;
            createLog('PartCostSync',partsCostRequest,JSON.serialize(partCostResponse),'Failed',null,null);
        }
        return partCostResponse;   
    }
	private ATI_REST_PartCostValidator partCostValidatorObj{get; private set;}
    private List<WOD_2__Warranty_Product_Pricebook__c> partsCostInsertOrUpdateLst{get; private set;}
	private List<WOD_2__Warranty_Product_Pricebook__c> oldPartsCostUpdateLst{get; private set;}
    private Map<String,WOD_2__Warranty_Product_Pricebook__c> mapOfInsertOrUpdatePartCosts{get; private set;}
    private Map<String,WOD_2__Warranty_Product_Pricebook__c> mapOfInsertedPartCost{get; private set;}
	
	
	public WOD_2.ResponseWrapper processType(String partsCostRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_PartCostRequest partsCostRequestObj = new ATI_REST_PartCostRequest();
        partCostValidatorObj = new ATI_REST_PartCostValidator();
        try{
            partsCostRequestObj = (ATI_REST_PartCostRequest)System.JSON.deserialize(partsCostRequest,ATI_REST_PartCostRequest.class);
            partCostValidatorObj.validateReqest(partsCostRequestObj);
            partsCostInsertOrUpdateLst = new List<WOD_2__Warranty_Product_Pricebook__c>();
            oldPartsCostUpdateLst= new List<WOD_2__Warranty_Product_Pricebook__c>();
            mapOfInsertOrUpdatePartCosts = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
            mapOfInsertedPartCost = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
            Set<String> buSet = new Set<String>();
            Set<String> parentProdSet = new Set<String>();
            Set<String> prodCategorySet = new Set<String>();
            Map<String,String> buNameIdMap = new Map<String,String>();
            Boolean oldEndDate=false;
            Map<String,ATI_REST_PartCostRequest.PartCostInformation> prodNameDetailsMap = new Map<String,ATI_REST_PartCostRequest.PartCostInformation>();
            
            //Integer i=1;
            
            Id recordTypeId = SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
            system.debug('partCostValidatorObj.partCostReqLst**'+partCostValidatorObj.partCostReqLst);
            for(ATI_REST_PartCostRequest.PartCostInformation partReq: partCostValidatorObj.partCostReqLst){
				oldEndDate= false;
				WOD_2__Warranty_Product_Pricebook__c pBookObj= new WOD_2__Warranty_Product_Pricebook__c();
                if(!partCostValidatorObj.mapOfPriceBook.isEmpty() && partCostValidatorObj.mapOfPriceBook.containsKey(partReq.item)){
                    if(partCostValidatorObj.mapOfPriceBook.get(partReq.item).WOD_2__Valid_From__c== ATI_Utils.parseDate(partReq.effectiveDate)){
						pBookObj = new WOD_2__Warranty_Product_Pricebook__c(Id=partCostValidatorObj.mapOfPriceBook.get(partReq.item).Id);
					}else{
						partCostValidatorObj.mapOfPriceBook.get(partReq.item).WOD_2__Valid_Until__c= ATI_Utils.parseDate(partReq.effectiveDate)-1;
						oldEndDate= true;
						pBookObj= partCostValidatorObj.mapOfPriceBook.get(partReq.item);
					}
					
				}
				if(!oldEndDate){
                    pBookObj.RecordTypeId= recordTypeId;
					pBookObj.WOD_2__Warranty_Product__c= partCostValidatorObj.mapOfProducts.get(partReq.item).Id;
                    pBookObj.Name= partReq.item;
					pBookObj.WOD_2__Price__c= Decimal.valueOf(partReq.value);
					pBookObj.ATI_Unit_of_Measure__c= partReq.itemUnit;
					if(partReq.active!= null && partReq.active!=''){
						pBookObj.ATI_Active__c = Boolean.valueOf(partReq.active);
					}
					pBookObj.WOD_2__Valid_From__c= ATI_Utils.parseDate(partReq.effectiveDate);
					pBookObj.WOD_2__Valid_Until__c = Date.valueOf(Label.ATI_Part_Cost_EndDate);
				}
                if(oldEndDate==true){
                    WOD_2__Warranty_Product_Pricebook__c pBookObjNew= new WOD_2__Warranty_Product_Pricebook__c();
					pBookObjNew.RecordTypeId= recordTypeId;
                    pBookObjNew.WOD_2__Warranty_Product__c= partCostValidatorObj.mapOfProducts.get(partReq.item).Id;
                    pBookObjNew.Name= partReq.item;
					pBookObjNew.WOD_2__Price__c= Decimal.valueOf(partReq.value);
					pBookObjNew.ATI_Unit_of_Measure__c= partReq.itemUnit;
					if(partReq.active!= null && partReq.active!=''){
						pBookObjNew.ATI_Active__c = Boolean.valueOf(partReq.active);
					}
					pBookObjNew.WOD_2__Valid_From__c= ATI_Utils.parseDate(partReq.effectiveDate);
					pBookObjNew.WOD_2__Valid_Until__c = Date.valueOf(Label.ATI_Part_Cost_EndDate);
                    partsCostInsertOrUpdateLst.add(pBookObjNew);
                    mapOfInsertedPartCost.put(partReq.item,pBookObjNew);
				}
                partsCostInsertOrUpdateLst.add(pBookObj);
			
			
				if(pBookObj.Id== null){
					mapOfInsertedPartCost.put(partReq.item,pBookObj);
				}
            }
            
            
            if(!partsCostInsertOrUpdateLst.isEmpty() || !oldPartsCostUpdateLst.isEmpty()){
                createOrUpdatePartCosts(partsCostRequest);
            }
            responseWrapper.data = JSON.serialize(createResponse(partsCostRequestObj.partCost));
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('message'+ e.getMessage());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
            
        }
        return responseWrapper;
    }
	
    
    private void createLog(String processName, String request, String response, String status,String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_PartsMaster_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!partCostValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(partCostValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = partCostValidatorObj.totalRecords-partCostValidatorObj.totalFailedRecords;
            	objLogSerWrp.failureRecordCount = partCostValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_PartCostSyncResponse responseWrapperObj = (ATI_REST_PartCostSyncResponse)System.JSON.deserialize(response,ATI_REST_PartCostSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = partCostValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = partCostValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            /*if(primaryKey == null){
                WOD_2.ResponseWrapper responseWrapperObj = (WOD_2.ResponseWrapper)System.JSON.deserialize(response,WOD_2.ResponseWrapper.class);
                objLogSerWrp.errortext = responseWrapperObj.errormessage;
            }*/
            objLogSerWrp.totalRecordCount = partCostValidatorObj.totalRecords;
            
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
	private void createOrUpdatePartCosts(String partsCostRequest){
        
        String objectName = Label.ATI_PartCost_ObjectName;
        List<String> fields = new List<String>{'WOD_2__Price__c','WOD_2__Warranty_Product__c','ATI_Unit_of_Measure__c','ATI_Active__c','WOD_2__Valid_From__c','WOD_2__Valid_Until__c'};
        ATI_Utils.NoAccessObjectFieldWrapper partCostCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,fields);
        ATI_Utils.NoAccessObjectFieldWrapper partCostUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,fields);
        
        if(partCostCreateAccessCheck.noAccessObjectList.size() == 0 && partCostCreateAccessCheck.noAccessFieldList.size() == 0 && partCostUpdateAccessCheck.noAccessObjectList.size() == 0 && partCostUpdateAccessCheck.noAccessFieldList.size() == 0){
			if(!partsCostInsertOrUpdateLst.isEmpty()){
				upsert partsCostInsertOrUpdateLst;
                fetchCostInformation(partsCostRequest);
			}
		
            
        } else {
            String errortext = 'Insufficient Warranty product Pricebook Create Access-->> '+JSON.serialize(partCostCreateAccessCheck)+'Insufficient Warranty product Pricebook Update Access-->> '+JSON.serialize(partCostUpdateAccessCheck);
            ATI_LogService.createLogForAccess('PartCostSync',errortext);
        }
    }
	
	private ATI_REST_PartCostSyncResponse createResponse(List<ATI_REST_PartCostRequest.PartCostInformation> partsRequest){
            ATI_REST_PartCostSyncResponse partsResponse = new ATI_REST_PartCostSyncResponse();
            List<ResponseData> responseDataLst = new List<ResponseData>();
            Integer i = 1;
            for(ATI_REST_PartCostRequest.PartCostInformation partsReq : partsRequest){
                ResponseData data = new ResponseData();
                if(!partCostValidatorObj.mapOfFailure.isEmpty() && partCostValidatorObj.mapOfFailure.containsKey(i)){
                    data.message = String.Join(partCostValidatorObj.mapOfFailure.get(i),', ') ;
                }else{
					if(!mapOfInsertedPartCost.isEmpty() && mapOfInsertedPartCost.containsKey(partsReq.item)){
						data.message = Label.ATI_Record_Insert_Message;
					}else{
						data.message = Label.ATI_Record_Update_Message;    
					}
				}
				if(!mapOfInsertOrUpdatePartCosts.isEmpty() && mapOfInsertOrUpdatePartCosts.containsKey(partsReq.item)){
                    //data.identifier= partsReq.identifier;
					data.transactionId = mapOfInsertOrUpdatePartCosts.get(partsReq.item).Id;
					data.name = mapOfInsertOrUpdatePartCosts.get(partsReq.item).Name;
				}
                data.identifier= partsReq.identifier;
                responseDataLst.add(data);
                i++;
            }
            partsResponse.interfaceName = 'I-265 – Part Cost';
            partsResponse.data = responseDataLst;
            if(partCostValidatorObj.mapOfFailure.isEmpty()){
                partsResponse.status = 'Success';
                partsResponse.message =  Label.ATI_Success_Message;
                createLog('PartCostSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Success',null,JSON.serialize(partCostValidatorObj.setOfSuccessRecords));
            }else if(partCostValidatorObj.mapOfFailure.size() ==  partsRequest.size()){
                partsResponse.status = 'Failed';
                partsResponse.message = Label.ATI_Failed_Message;
                createLog('PartCostSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Failed',JSON.serialize(partCostValidatorObj.setOfFailedPartCosts),JSON.serialize(partCostValidatorObj.setOfFailedPartCosts));
            }else{
                partsResponse.status = 'Partial Success';
                partsResponse.message =  Label.ATI_PartialSuccess_Message;
                createLog('PartCostSync',JSON.serialize(partsRequest),JSON.serialize(partsResponse),'Partial Success',JSON.serialize(partCostValidatorObj.setOfFailedPartCosts),'Success Records-->> '+JSON.serialize(partCostValidatorObj.setOfSuccessRecords)+',Failed Records-->> '+JSON.serialize(partCostValidatorObj.setOfFailedPartCosts));
            }
        	return partsResponse;
    }
	
	private void fetchCostInformation(String partsCostRequest){
		ATI_REST_PartCostRequest partCostRequestBody= (ATI_REST_PartCostRequest)System.JSON.deserialize(partsCostRequest,ATI_REST_PartCostRequest.class);
		Set<String> itemIds= ATI_REST_PartCostValidator.getItemsList(partCostRequestBody);
		Set<Date> effectiveDateValues= new Set<Date>();
        for(ATI_REST_PartCostRequest.PartCostInformation partCostReq : partCostRequestBody.partCost){
            if(!String.isBlank(partCostReq.effectiveDate)){
                effectiveDateValues.add(ATI_Utils.parseDate(partCostReq.effectiveDate));
            }
        }
		
        if(ATI_REST_PartCostValidator.checkReadAccess()){
            List<WOD_2__Warranty_Product_Pricebook__c> wpLst = [SELECT Id,Name,WOD_2__Warranty_Product__c,WOD_2__Warranty_Product__r.Name,WOD_2__Price__c,ATI_Unit_of_Measure__c,ATI_Active__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c FROM WOD_2__Warranty_Product_Pricebook__c WHERE WOD_2__Valid_From__c IN: effectiveDateValues AND WOD_2__Warranty_Product__r.Name IN: itemIds];
            if(!wpLst.isEmpty()){
            	for(WOD_2__Warranty_Product_Pricebook__c prod : wpLst){
                	mapOfInsertOrUpdatePartCosts.put(prod.WOD_2__Warranty_Product__r.Name,prod);
            	}
            }
        }
    }
	
	
    
	/************************************************************************
	Description    :   A wrapper class to capture the Parts Cost Information Rest data.
	*************************************************************************/
    global class ATI_REST_PartCostSyncResponse{
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