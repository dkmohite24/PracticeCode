/* Name: ATI_REST_ValidateClaimSubmittalBatch
Description : Batch Class for Submitting Batch Claims through interface
Author : Tavant (TY)
History :
VERSION      AUTHOR          DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant (TY)    28/05/2021          INITIAL DEVELOPMENT
*/
global class ATI_REST_ValidateClaimSubmittalBatch implements Database.Batchable<sObject>, Database.Stateful{
    String strBatchLogId;
    List<WOD_2__Claim__c> claimSubmitList;
    ATI_REST_BatchClaimSubmittalResults batchClaimSubResults;
    Set<Id> claimSubIdSet;
    Map<String,List<String>> mapOfFailure;
    Map<String,WOD_2__Claim__c> mapOfInsertedOrUpdatedClaims;
    Map<string,string> claimIdKeyMap;
    Integer totalRecords;
    Integer totalFailedRecords;
    Set<String> failedRecords;
    Set<String> sucessRecords;
    Boolean isBatchLogCreate;
    Map<Integer,List<String>> mapOfBatchLogErrors;
    public ATI_REST_ValidateClaimSubmittalBatch(List<WOD_2__Claim__c> claimSubmitData,
                                                String batchLogId,
                                                ClaimValidateSubmitWrapper validateSubmitWrapData){
        strBatchLogId = batchLogId;
        claimSubmitList = claimSubmitData;
        batchClaimSubResults = validateSubmitWrapData.batchClaimSubResults;
        mapOfFailure = validateSubmitWrapData.mapOfFailure;                                            
        claimSubIdSet = new Set<Id>();
        mapOfInsertedOrUpdatedClaims = validateSubmitWrapData.mapOfInsertedOrUpdatedClaims;
        claimIdKeyMap = validateSubmitWrapData.claimIdKeyMap;
        totalRecords = 0;
        totalFailedRecords = 0;
        failedRecords = new Set<String>();
        sucessRecords = new Set<String>();
        isBatchLogCreate = validateSubmitWrapData.isBatchLogCreate;  
        mapOfBatchLogErrors = new Map<Integer,List<String>>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        for(WOD_2__Claim__c claim : claimSubmitList){
            claimSubIdSet.add(claim.id);
        }
        String query = 'SELECT Id,WOD_2__BusinessCategory__c FROM WOD_2__Claim__c WHERE Id IN:claimSubIdSet';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WOD_2__Claim__c> claimSubDataLst) {
        System.debug('claimSubDataLst>>> '+claimSubDataLst);
        validateSubmitBURules(claimSubDataLst);
    }
    
    public void finish(Database.BatchableContext bc) {
        if(!Test.isRunningTest()){
            createResponse();
        }
        ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=strBatchLogId,WOD_2__Batch_End_Date__c=System.now())},true);
        ATI_BulkUploadEmailNotification.sendBulkUploadCompletedEmail(strBatchLogId);
    }
    
    public void validateSubmitBURules(List<WOD_2__Claim__c> claimSubDataLst){
        List<WOD_2.TWoD_RecordOutputWrapper> buRuleOutputWrapper = ATI_REST_BatchClaimSubmittalService.validateSubmitBURules(claimSubDataLst);
        List<Id> claimIdsForHardRules = new List<Id>();
        for(integer i=0;i<buRuleOutputWrapper.size();i++){
            if(!buRuleOutputWrapper.get(i).status){
                if(buRuleOutputWrapper.get(i).message.contains('Please review all hard error rules')){
                    claimIdsForHardRules.add(buRuleOutputWrapper.get(i).recordId);
                }
                else if(!buRuleOutputWrapper.get(i).message.contains('This record is currently in an approval process. A record can be in only one approval process at a time.')
                        && buRuleOutputWrapper.get(i).message != ''){
                            if(mapOfFailure.containsKey(claimIdKeyMap.get(buRuleOutputWrapper.get(i).recordId))){
                                mapOfFailure.get(claimIdKeyMap.get(buRuleOutputWrapper.get(i).recordId)).add(buRuleOutputWrapper.get(i).message);
                            }else{
                                mapOfFailure.put(claimIdKeyMap.get(buRuleOutputWrapper.get(i).recordId),new List<String>{buRuleOutputWrapper.get(i).message});
                            }
                        }
            }
        }
        if(!claimIdsForHardRules.isEmpty()){
            fetchBusinessRules(claimIdsForHardRules);
        }
    }
    
    //fetchBusinessRules 
    private void fetchBusinessRules(List<Id> claimIds){
        List<String> businessRuleFields = new List<String>{'WOD_2__Message__c','WOD_2__Claim__r.ATI_Identifier__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Business_Rule__c',businessRuleFields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            for(WOD_2__Business_Rule__c businessRule : [SELECT Id,WOD_2__Message__c,WOD_2__Claim__r.ATI_Identifier__c FROM WOD_2__Business_Rule__c WHERE WOD_2__Claim__c IN:claimIds AND WOD_2__Error_Type__c='Hard']){
                if(mapOfFailure.containskey(businessRule.WOD_2__Claim__r.ATI_Identifier__c)){
                    mapOfFailure.get(businessRule.WOD_2__Claim__r.ATI_Identifier__c).add(businessRule.WOD_2__Message__c);
                }else{
                    mapOfFailure.put(businessRule.WOD_2__Claim__r.ATI_Identifier__c,new List<String>{businessRule.WOD_2__Message__c});
                }
            }
        }else{
            String errortext = 'Insufficient BusinessRule Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
        }
    }
    
    //CreateResponse
    public void createResponse(){
        Set<Id> claimIdLstForShare = new Set<Id>();
        Set<String> claimAccountIdsForShare = new Set<String>();
        Set<Id> setOfClaimIdsForUpdate = new Set<Id>();
        ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
        List<ATI_REST_BatchClaimSubmittalResponse.ResponseData> responseDataLst = new List<ATI_REST_BatchClaimSubmittalResponse.ResponseData>();
        Integer i = 1;
        for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation batchClaim : batchClaimSubResults.batchClaimSubmittalReqLst){
            ATI_REST_BatchClaimSubmittalResponse.ResponseData data = new ATI_REST_BatchClaimSubmittalResponse.ResponseData();
            data.message = '';
            if(batchClaimSubResults.mapOfFailure.containsKey(i) || mapOfFailure.containsKey(batchClaim.identifier)){
                if(batchClaimSubResults.mapOfFailure.containsKey(i)){
                    data.message += String.Join(batchClaimSubResults.mapOfFailure.get(i),', ');
                }else{
                    data.name = batchClaim.trackingNumber;
                }
                if(mapOfFailure.containsKey(batchClaim.identifier)){
                    if(mapOfInsertedOrUpdatedClaims.containskey(batchClaim.identifier)){
                        data.transactionId = mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).Id;
                        data.name = mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).Name;
                        claimIdLstForShare.add(data.transactionId);
                        claimAccountIdsForShare.add(mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).WOD_2__Account__c);
                    }else{
                        data.name = batchClaim.trackingNumber;
                    }
                    if(data.message != ''){
                        data.message += ','+String.Join(mapOfFailure.get(batchClaim.identifier),', ');
                    }else{
                        data.message += String.Join(mapOfFailure.get(batchClaim.identifier),', ');
                    }
                }
                mapOfBatchLogErrors.put(i,new List<String>{data.message});
                failedRecords.add(batchClaim.trackingNumber);
                totalFailedRecords++;
            }else{
                if(!mapOfInsertedOrUpdatedClaims.isEmpty() && mapOfInsertedOrUpdatedClaims.containsKey(batchClaim.identifier)){
                    data.message = 'Batch Processed Successfully';
                    sucessRecords.add(batchClaim.trackingNumber);
                }
            }
            if(mapOfInsertedOrUpdatedClaims.containsKey(batchClaim.identifier.trim()) && !data.message.contains('Identifier is not unique')){
                data.transactionId = mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).Id;
                data.name = mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).Name;
                claimIdLstForShare.add(data.transactionId);
                claimAccountIdsForShare.add(mapOfInsertedOrUpdatedClaims.get(batchClaim.identifier).WOD_2__Account__c);
                if(!mapOfFailure.containsKey(batchClaim.identifier) && !batchClaimSubResults.mapOfFailure.containsKey(i)){
                    setOfClaimIdsForUpdate.add(data.transactionId);
                }
            }
            data.identifier = batchClaim.identifier;
            responseDataLst.add(data);
            i++;
        }
        totalRecords = i-1;
        batchClaimSubmittalResponse.interfaceName = 'I-211 – Batch Claim Submittal';
        batchClaimSubmittalResponse.data = responseDataLst;
        if(batchClaimSubResults.mapOfFailure.isEmpty() && mapOfFailure.isEmpty()){
            batchClaimSubmittalResponse.status = 'Success';
            batchClaimSubmittalResponse.message =  'All the records have been inserted / updated successfully';
            createOrUpdateLog('BatchClaimSubmittalSync',JSON.serialize(batchClaimSubResults.batchClaimSubmittalReqLst),JSON.serialize(batchClaimSubmittalResponse),'Success',null,JSON.serialize(sucessRecords),strBatchLogId);
        }else if(totalFailedRecords ==  batchClaimSubResults.batchClaimSubmittalReqLst.size()){
            batchClaimSubmittalResponse.status = 'Failed';
            batchClaimSubmittalResponse.message = 'All the records have failed to insert / update';
            createOrUpdateLog('BatchClaimSubmittalSync',JSON.serialize(batchClaimSubResults.batchClaimSubmittalReqLst),JSON.serialize(batchClaimSubmittalResponse),'Failed',JSON.serialize(failedRecords),JSON.serialize(failedRecords),strBatchLogId);
        }else{
            batchClaimSubmittalResponse.status = 'Partial Success';
            batchClaimSubmittalResponse.message =  'Few records have not been inserted / updated.';
            createOrUpdateLog('BatchClaimSubmittalSync',JSON.serialize(batchClaimSubResults.batchClaimSubmittalReqLst),JSON.serialize(batchClaimSubmittalResponse),'Partial Success',JSON.serialize(failedRecords),'Success>> '+JSON.serialize(sucessRecords)+',Failure>> '+JSON.serialize(failedRecords),strBatchLogId);
        }
        System.debug('Response>>> '+batchClaimSubmittalResponse);
        if(!claimIdLstForShare.isEmpty() && !claimAccountIdsForShare.isEmpty()){
            new ATI_AddClaimShareRecords(claimAccountIdsForShare,claimIdLstForShare).execute(null); 
        }
    }
    
    public void createOrUpdateLog(String processName, String request, String response, String status, String identifier, String primaryKey, String strBatchLogId){
        if(isBatchLogCreate){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey = primaryKey;
            objLogSerWrp.batchLogId = strBatchLogId;
            objLogSerWrp.errortext = '';
            if(!mapOfBatchLogErrors.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(mapOfBatchLogErrors.values());
            }
            objLogSerWrp.successRecordCount = totalRecords-totalFailedRecords;
            if(primaryKey != null){
                objLogSerWrp.failureRecordCount = totalFailedRecords;
                objLogSerWrp.totalRecordCount = totalRecords;
            }else{
                ATI_REST_BatchClaimSubmittalResponse resp = (ATI_REST_BatchClaimSubmittalResponse)JSON.deserialize(response,ATI_REST_BatchClaimSubmittalResponse.class);
            	objLogSerWrp.errortext = resp.message;
                List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> reqLst = (List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation>)JSON.deserialize(request,List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation>.class);
                objLogSerWrp.failureRecordCount = reqLst.size();
                objLogSerWrp.totalRecordCount = reqLst.size();
            }
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    public class ClaimValidateSubmitWrapper{
        public Map<String,List<String>> mapOfFailure;
        public Map<String,WOD_2__Claim__c> mapOfInsertedOrUpdatedClaims;
        public Map<string,string> claimIdKeyMap;
        public ATI_REST_BatchClaimSubmittalResults batchClaimSubResults;
        public Boolean isBatchLogCreate;
    }
}