/* Name: ATI_REST_BatchClaimSubmittalSync
Description : Endpoint which syncs claims for repaired inventories
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       08/02/2021      INITIAL DEVELOPMENT                           
*/
@RestResource(urlMapping = '/ATIRestBatchClaimSubmittalSync/*')
global with sharing class ATI_REST_BatchClaimSubmittalSync {
    @HttpPost
    global Static ATI_REST_BatchClaimSubmittalResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_BatchClaimSubmittalSync batchClaimSubmittalSyncObj = new ATI_REST_BatchClaimSubmittalSync();
        ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = batchClaimSubmittalSyncObj.processClaims(requestBody);
        return batchClaimSubmittalResponse;
    }
    
    public ATI_REST_BatchClaimSubmittalResponse processClaims(String batchClaimSubmittalRequest){
        ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
        WOD_2.ResponseWrapper response = processType(batchClaimSubmittalRequest);
        if(response != null && response.data != null && response.data != '') {
            batchClaimSubmittalResponse = (ATI_REST_BatchClaimSubmittalResponse)JSON.deserialize(response.data,ATI_REST_BatchClaimSubmittalResponse.class);
        }else{
            batchClaimSubmittalResponse.status = 'Fail';
            batchClaimSubmittalResponse.message = response.errormessage;
            batchClaimSubmittalResponse.interfaceName = 'I-211 – Batch Claim Submittal';
            if(isBatchLogCreate){
                ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
                objLogSerWrp.statusText = 'Failed';
                objLogSerWrp.inputRequestJSON = batchClaimSubmittalRequest;
                objLogSerWrp.outputResponseJSON = response.data;
                objLogSerWrp.processName = 'BatchClaimSubmittalSync';
                objLogSerWrp.errortext = response.errormessage;
                objLogSerWrp.successRecordCount = 0;
                objLogSerWrp.failureRecordCount = batchClaimSubmittalValidatorObj.totalRecords;
                objLogSerWrp.totalRecordCount = batchClaimSubmittalValidatorObj.totalRecords;
                ATI_LogService.logRecord(objLogSerWrp);
            }
        }
        return batchClaimSubmittalResponse;   
    }
    
    private static ATI_REST_BatchClaimSubmittalValidator batchClaimSubmittalValidatorObj{get; private set;}
    private static Boolean isBatchLogCreate{get; private set;}
    public static WOD_2.ResponseWrapper processType(String batchClaimSubmittalRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_BatchClaimSubmittalRequest batchClaimSubmittalReqObj = new ATI_REST_BatchClaimSubmittalRequest();
        isBatchLogCreate = false;
        batchClaimSubmittalValidatorObj = new ATI_REST_BatchClaimSubmittalValidator();
        try{
            WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_BatchClaimSubmittal_LogRecord_Check');
            if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
                isBatchLogCreate = true;
            } 
            batchClaimSubmittalReqObj = ATI_REST_BatchClaimSubmittalRequest.parse(batchClaimSubmittalRequest);
             System.debug('Request>>> '+batchClaimSubmittalReqObj);
            batchClaimSubmittalValidatorObj.validateReqest(batchClaimSubmittalReqObj);
            ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
            List<ATI_REST_BatchClaimSubmittalResponse.ResponseData> responseDataLst = new List<ATI_REST_BatchClaimSubmittalResponse.ResponseData>();
            if(!batchClaimSubmittalValidatorObj.batchClaimSubmittalReqLst.isEmpty()){
                WOD_2.ResponseWrapper batchLogResponseWrapper = ATI_Utils.insertSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Name='BatchClaimSubmittalSync_'+System.now().format('yyyy_MM_dd_hh_mm_ss'),
                                                                                                                                               WOD_2__Process_Type__c='BatchClaimSubmittalSync',
                                                                                                                                               WOD_2__Status__c='Queued',
                                                                                                                                               ATI_Request_JSON__c = JSON.serialize(batchClaimSubmittalReqObj.claim))},true);
                Database.SaveResult[] saveResult = (Database.SaveResult[])JSON.deserialize(batchLogResponseWrapper.data,Database.SaveResult[].class);
                WOD_2.ResponseWrapper uploadChucksWrapper = uploadChunks(batchClaimSubmittalValidatorObj.batchClaimSubmittalReqLst,saveResult.get(0).Id);
                if(uploadChucksWrapper.status){
                    ATI_REST_BatchClaimSubmittalResults batchClaimSubResults = new ATI_REST_BatchClaimSubmittalResults();
                    batchClaimSubResults.buMap = batchClaimSubmittalValidatorObj.buMap;
                    batchClaimSubResults.accMap = batchClaimSubmittalValidatorObj.accMap;
                    batchClaimSubResults.warProdMap = batchClaimSubmittalValidatorObj.warProdMap;
                    batchClaimSubResults.warCodeMap = batchClaimSubmittalValidatorObj.warCodeMap;
                    batchClaimSubResults.priceBookMap = batchClaimSubmittalValidatorObj.priceBookMap;
                    batchClaimSubResults.inventoryMap = batchClaimSubmittalValidatorObj.inventoryMap;
                    batchClaimSubResults.claimMap = batchClaimSubmittalValidatorObj.claimMap;
                    batchClaimSubResults.exchangeRateMap = batchClaimSubmittalValidatorObj.exchangeRateMap;
                    batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss = batchClaimSubmittalValidatorObj.mapOfKeyWithCampaignClaimTempAss;
                    batchClaimSubResults.financialLineItemMap = batchClaimSubmittalValidatorObj.financialLineItemMap;
                    batchClaimSubResults.rateMap = batchClaimSubmittalValidatorObj.rateMap;
                    batchClaimSubResults.claimIdMap = batchClaimSubmittalValidatorObj.claimIdMap;
                    batchClaimSubResults.batchClaimSubmittalReqLst = batchClaimSubmittalReqObj.claim;
                    batchClaimSubResults.mapOfFailure = batchClaimSubmittalValidatorObj.mapOfFailure;
                    batchClaimSubResults.mapOfSuccessParts = batchClaimSubmittalValidatorObj.mapOfSuccessParts;
                    batchClaimSubResults.mapOfSuccessDiagnosticCodes = batchClaimSubmittalValidatorObj.mapOfSuccessDiagnosticCodes;
                    batchClaimSubResults.mapOfSuccessLaborCodes = batchClaimSubmittalValidatorObj.mapOfSuccessLaborCodes;
                    batchClaimSubResults.mapOfSuccessNetItems = batchClaimSubmittalValidatorObj.mapOfSuccessNetItems;
                    batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo = batchClaimSubmittalValidatorObj.mapOfBatchClaimRelatedErrorInfo;
                    ATI_REST_ClaimSubmittalBatch claimSubmittalBatch = new ATI_REST_ClaimSubmittalBatch(saveResult.get(0).Id,batchClaimSubResults,isBatchLogCreate);
                    Database.executeBatch(claimSubmittalBatch,1);
                    Integer i = 1;
                    for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation batchClaim : batchClaimSubmittalReqObj.claim){
                        ATI_REST_BatchClaimSubmittalResponse.ResponseData data = new ATI_REST_BatchClaimSubmittalResponse.ResponseData();
                        if(batchClaimSubmittalValidatorObj.mapOfFailure.containsKey(i)){
                            data.message = '';
                        	data.message += String.Join(batchClaimSubmittalValidatorObj.mapOfFailure.get(i),', ');
                        }
                        data.transactionId = saveResult.get(0).Id;
                        data.name = batchClaim.trackingNumber;
                        data.identifier = batchClaim.identifier;
                        responseDataLst.add(data);
                        i++;
                    }
                    batchClaimSubmittalResponse.status = 'Initiated';
                    batchClaimSubmittalResponse.message = 'Batch Claim Initiated Successfully';
                    batchClaimSubmittalResponse.interfaceName = 'I-211 – Batch Claim Submittal';
                    batchClaimSubmittalResponse.data = responseDataLst;
                }
            }else{
                Integer i = 1;
                Set<String> failedRecordsSet = new Set<String>();
            	for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation batchClaim : batchClaimSubmittalReqObj.claim){
                    ATI_REST_BatchClaimSubmittalResponse.ResponseData data = new ATI_REST_BatchClaimSubmittalResponse.ResponseData();
                    if(batchClaimSubmittalValidatorObj.mapOfFailure.containsKey(i)){
                        data.message = '';
                    	data.message += String.Join(batchClaimSubmittalValidatorObj.mapOfFailure.get(i),', ');
                    }
                    data.name = batchClaim.trackingNumber;
                    data.identifier = batchClaim.identifier;
                    responseDataLst.add(data);
                    failedRecordsSet.add(batchClaim.identifier);
            		i++;
                }
                batchClaimSubmittalResponse.status = 'Failed';
                batchClaimSubmittalResponse.message = 'All the records have failed to insert / update';
                batchClaimSubmittalResponse.interfaceName = 'I-211 – Batch Claim Submittal';
            	batchClaimSubmittalResponse.data = responseDataLst;
                if(isBatchLogCreate){
                    ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
                    objLogSerWrp.statusText = 'Failed';
                    objLogSerWrp.inputRequestJSON = JSON.serialize(batchClaimSubmittalReqObj.claim);
                    objLogSerWrp.outputResponseJSON = JSON.serialize(batchClaimSubmittalResponse);
                    objLogSerWrp.processName = 'BatchClaimSubmittalSync';
                    objLogSerWrp.identifier = JSON.serialize(failedRecordsSet);
                    objLogSerWrp.primaryKey = JSON.serialize(failedRecordsSet);
                    objLogSerWrp.errortext = '';
                    if(!batchClaimSubmittalValidatorObj.mapOfFailure.isEmpty()){
                        objLogSerWrp.errortext = JSON.serialize(batchClaimSubmittalValidatorObj.mapOfFailure.values());
                    }
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = batchClaimSubmittalValidatorObj.totalRecords;
                    objLogSerWrp.totalRecordCount = batchClaimSubmittalValidatorObj.totalRecords;
                    WOD_2.ResponseWrapper responseWrapperObj = ATI_LogService.logRecord(objLogSerWrp);
                    if(!responseWrapperObj.status){
                        throw new ATI_Exception(responseWrapperObj.errormessage);
                    }
                }
            }
            responseWrapper.status = true;
            responseWrapper.data = JSON.serialize(batchClaimSubmittalResponse);
        }catch(Exception e){
            system.debug('message===> '+ e.getMessage()+' : '+e.getStackTraceString());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage();
        }
        return responseWrapper;
    }
    
    //inserting uploaded csv in chunks under batch log
    public static WOD_2.ResponseWrapper uploadChunks(List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> claimInfoLst,String strBatchlogId) {
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper();
        try{
            //Uploaded claims data saved to file(Content Version) & attached to Batch Log 
            if(strBatchLogId != null){
                List<ContentVersion> contentVersionLst = new List<ContentVersion>();
                List<ContentDocumentLink> contentDocumentLinkLst = new List<ContentDocumentLink>();
                ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
                for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : claimInfoLst){
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                    conVer.PathOnClient = 'BatchClaimSubmissionJSON' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt'; // The files name, extension is very important here which will help the file in preview.
                    conVer.Title = 'BatchClaimSubmissionJSON' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
                    //conver.Description = 'Uploaded Claims in JSON format';
                    conVer.VersionData = Blob.valueOf(JSON.serialize(claimInfo)); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
                    contentVersionLst.add(conVer);
                }
                if(!contentVersionLst.isEmpty()){ 
                    insert contentVersionLst;
                    Set<Id> contentVersionIds = new Set<Id>();
                    for(ContentVersion cVer : contentVersionLst){
                        contentVersionIds.add(cVer.Id);
                    }
                    List<ContentVersion> contentVersionDataLst = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN:contentVersionIds];
                    for(ContentVersion contentVersion : contentVersionDataLst){
                        //Create ContentDocumentLink
                        ContentDocumentLink cDoc = new ContentDocumentLink();
                        cDoc.ContentDocumentId = contentVersion.ContentDocumentId;
                        cDoc.LinkedEntityId = strBatchlogId; 
                        cDoc.ShareType = 'V'; //Only View permission 
                        cDoc.Visibility = 'AllUsers'; //AllUsers/InternalUsers/SharedUsers
                        contentDocumentLinkLst.add(cDoc);
                    }
                    if(!contentDocumentLinkLst.isEmpty()){
                        insert contentDocumentLinkLst;
                    }
                    responseWrapperObj.data = '';
                    responseWrapperObj.status = true;
                    responseWrapperObj.errormessage = '';
                }
            }
        }
        catch(Exception exp){
            responseWrapperObj.data = '';
            responseWrapperObj.status = false;
            responseWrapperObj.errormessage = exp.getMessage();
        }
        return responseWrapperObj;
    }
}