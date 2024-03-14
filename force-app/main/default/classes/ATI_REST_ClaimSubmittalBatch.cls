/* Name: ATI_REST_ClaimSubmittalBatch
Description : Batch Class for BatchClaimSubmittal interface
Author : Tavant (TY)
History :
VERSION      AUTHOR          DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant (TY)    09/04/2021          INITIAL DEVELOPMENT
*/
public with sharing class ATI_REST_ClaimSubmittalBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    String strBatchLogId;
    Integer proccesingCount;
    ATI_REST_BatchClaimSubmittalResults batchClaimSubResults;
    Boolean isBatchLogCreate;
    Map<String,WOD_2__Claim__c> mapOfInsertedOrUpdatedClaims;
    Map<String,List<String>> mapOfFailure;
    Map<string,string> claimIdKeyMap;
    List<WOD_2__Claim__c> claimSubmitList;
    public ATI_REST_ClaimSubmittalBatch(String strBatchLogIdTemp,
                                        ATI_REST_BatchClaimSubmittalResults batchClaimSubResultsTemp,
                                        Boolean isBatchLogCreateTemp) {
        strBatchLogId = strBatchLogIdTemp;
        proccesingCount = 0;
        mapOfInsertedOrUpdatedClaims = new Map<String,WOD_2__Claim__c>();
        mapOfFailure = new Map<String,List<String>>();
        claimIdKeyMap = new Map<string,string>();
        claimSubmitList = new List<WOD_2__Claim__c>();
        batchClaimSubResults = batchClaimSubResultsTemp; 
        isBatchLogCreate = isBatchLogCreateTemp;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        WOD_2__Batch_Log__c objBatchLog = new WOD_2__Batch_Log__c(Id=strBatchLogId,WOD_2__Status__c='Initiated',WOD_2__Batch_Start_Date__c=System.now());
        update objBatchLog;
        List<ContentDocumentLink> contentDocumentLinkObjList = [SELECT ContentDocumentId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =:strBatchLogId];
        List<Id> contentDocumentIdList = new List<Id>();
        for(ContentDocumentLink contentDocumentObj : contentDocumentLinkObjList) {
            contentDocumentIdList.add(ContentDocumentObj.ContentDocumentId);
        }
        return Database.getQueryLocator([SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIdList]);
    }
    
    //Used for proccessing attachments under batch log
    public void execute(Database.BatchableContext bc, List<ContentVersion> lstAttachment) { 
        List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> claimInfoLst = new List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation>();
        //deserialize the JSON persent in attachment boday to proccess and store
        for(ContentVersion objAttchments :lstAttachment) {
            String strBlob =  objAttchments.VersionData.tostring();     // replaced Body of attachment
            ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo = (ATI_REST_BatchClaimSubmittalRequest.ClaimInformation)JSON.deserialize(strBlob,ATI_REST_BatchClaimSubmittalRequest.ClaimInformation.class);
            claimInfoLst.add(claimInfo);
        }
        if(proccesingCount == 0){
            WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=strBatchLogId,
                                                                                                                                          WOD_2__Status__c='Processing')},true);
            proccesingCount++;
        }
        if(!claimInfoLst.isEmpty()){
            WOD_2.ResponseWrapper processClaimResponseWrapper = ATI_REST_BatchClaimSubmittalService.processClaim(claimInfoLst,strBatchLogId,batchClaimSubResults);
            if(processClaimResponseWrapper.status){
                ATI_REST_BatchClaimSubmittalService.BatchClaimSubmittalWrapper batchClaimWrapper = (ATI_REST_BatchClaimSubmittalService.BatchClaimSubmittalWrapper)JSON.deserialize(processClaimResponseWrapper.data,ATI_REST_BatchClaimSubmittalService.BatchClaimSubmittalWrapper.class);
                mapOfFailure.putAll(batchClaimWrapper.mapOfFailure);
                mapOfInsertedOrUpdatedClaims.putAll(batchClaimWrapper.mapOfInsertedOrUpdatedClaims);
                claimIdKeyMap.putAll(batchClaimWrapper.claimIdKeyMap);
                if(batchClaimWrapper.mapOfFailure.isEmpty() && !batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containsKey(claimInfoLst[0].identifier.trim())){
                    claimSubmitList.addAll(batchClaimWrapper.claimSubmitList);
                }
            }else{
                ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
                batchClaimSubmittalResponse.status = 'Fail';
                batchClaimSubmittalResponse.message = processClaimResponseWrapper.errormessage;
                batchClaimSubmittalResponse.interfaceName = 'I-211 – Batch Claim Submittal';
                ATI_REST_ValidateClaimSubmittalBatch validateClaimSubmittalBatch = createValidateSubmitWrapper();
                validateClaimSubmittalBatch.createOrUpdateLog('BatchClaimSubmittalSync',JSON.serialize(batchClaimSubResults.batchClaimSubmittalReqLst),JSON.serialize(batchClaimSubmittalResponse),'Failed',null,null,strBatchLogId);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        ATI_REST_ValidateClaimSubmittalBatch validateClaimSubmittalBatch = createValidateSubmitWrapper();
        System.debug('claimSubmitList>>> '+claimSubmitList.size());
        if(claimSubmitList.size()>1){
            Database.executeBatch(validateClaimSubmittalBatch,1);
        }else{
            WOD_2__Batch_Log__c objBatchLog = [Select Id,WOD_2__Status__c From WOD_2__Batch_Log__c Where Id=:strBatchLogId];
        	if(objBatchLog.WOD_2__Status__c != 'Failed'){
                if(!claimSubmitList.isEmpty()){
                    validateClaimSubmittalBatch.validateSubmitBURules(claimSubmitList);
                }
                validateClaimSubmittalBatch.createResponse();
            }
            ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=strBatchLogId,WOD_2__Batch_End_Date__c=System.now())},true);
            ATI_BulkUploadEmailNotification.sendBulkUploadCompletedEmail(strBatchLogId);
        }
    }
    
    //CreateValidateSubmitWrapper
    private ATI_REST_ValidateClaimSubmittalBatch createValidateSubmitWrapper(){
        ATI_REST_ValidateClaimSubmittalBatch.ClaimValidateSubmitWrapper validateSubmitWrapper = new ATI_REST_ValidateClaimSubmittalBatch.ClaimValidateSubmitWrapper();
        validateSubmitWrapper.isBatchLogCreate = isBatchLogCreate;
        validateSubmitWrapper.mapOfFailure = mapOfFailure;
        validateSubmitWrapper.mapOfInsertedOrUpdatedClaims = mapOfInsertedOrUpdatedClaims;
        validateSubmitWrapper.batchClaimSubResults = batchClaimSubResults;
        validateSubmitWrapper.claimIdKeyMap = claimIdKeyMap;
        ATI_REST_ValidateClaimSubmittalBatch validateClaimSubmittalBatch = new ATI_REST_ValidateClaimSubmittalBatch(claimSubmitList,strBatchLogId,validateSubmitWrapper);
        return validateClaimSubmittalBatch;
    }
}