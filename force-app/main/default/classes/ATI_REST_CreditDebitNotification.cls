/*
	Class Name	:	ATI_REST_CreditDebitNotification
	Created On	:	22nd march 2021
	Description	:	REST service to update TMH and claim to Paid
*/
@RestResource(urlMapping = '/ATIRestCreditDebitNotification/*')
global with sharing class ATI_REST_CreditDebitNotification {
    @HttpPost
    global Static CreditNotificationResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        System.debug('requestBody -> ' + requestBody);
        ATI_REST_CreditDebitNotification creditDebitNotfnControllerObj = new ATI_REST_CreditDebitNotification();
        CreditNotificationResponse responseObj = creditDebitNotfnControllerObj.updateCreditNotification(requestBody);
        return responseObj;
    }

    public CreditNotificationResponse updateCreditNotification(String creditNotificationRequest){
        CreditNotificationResponse creditNotificationResponse = new CreditNotificationResponse();
        WOD_2.ResponseWrapper response = processType(null, creditNotificationRequest);
        System.debug('Response Wrapper -> ' + response);
        if(response != null && response.data != null && response.data != '') {
            creditNotificationResponse = (CreditNotificationResponse)Json.deserialize(response.data,CreditNotificationResponse.class);
        }else {
            creditNotificationResponse.status = 'Failed';
            creditNotificationResponse.data = null;
            creditNotificationResponse.message = response.errormessage;
            createLog('Credit/Debit_Notification', creditNotificationRequest, JSON.serialize(creditNotificationResponse), 'Failed','','');
        }
        System.debug(creditNotificationResponse);
        return creditNotificationResponse;
    }

    //global variables
    Private Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> validClaimCreditDebitNotfnMap = 
        new Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification>();

    private CreditNotificationResponse createResponse(ATI_REST_CreditDebitNotificationRequest creditNtfnReqObj){
        CreditNotificationResponse response = new CreditNotificationResponse();
        List<CreditNotificationData> dataList = new List<CreditNotificationData>();
        Map<String, String> erroredClaimData = ATI_REST_CreditDebitNotifnValidator.erroredClaimData;
        for(ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification cd : creditNtfnReqObj.CreditDebitNotification){
            CreditNotificationData cnd = new CreditNotificationData();
            cnd.claimNumber = cd.claim.trim();
            cnd.message = erroredClaimData.get(cd.claim.trim()) == null ? 'Record Updated Successfully.' : erroredClaimData.get(cd.claim.trim());
            cnd.status = erroredClaimData.get(cd.claim.trim()) == null ? 'Success' : 'Failure';
            if(cd.claim.trim() == NULL || cd.claim.trim() == ''){
                cnd.message = 'Please provide value for claim!.';
                cnd.status = 'Failure';
            }
            dataList.add(cnd);
        }
        response.data = dataList;
        Set<String> errorLst = erroredClaimData.keySet();
        Set<String> successLst = validClaimCreditDebitNotfnMap.keySet();
        System.debug('successLst-------->'+validClaimCreditDebitNotfnMap);
        System.debug('errorLst-------->'+erroredClaimData);
        System.debug('creditNtfnReqObj.CreditDebitNotification-------->'+creditNtfnReqObj.CreditDebitNotification);
        System.debug('creditNtfnReqObj.CreditDebitNotification---size----->'+creditNtfnReqObj.CreditDebitNotification.size());
        response.interfaceName = 'I717 – Credit/Debit Notification';
        if(validClaimCreditDebitNotfnMap.size() == creditNtfnReqObj.CreditDebitNotification.size()){
            response.message = 'All the records have been updated successfully.';
            response.status = 'Success';
            createLog('Credit/Debit_Notification', JSON.serialize(creditNtfnReqObj), Json.serialize(response), 'Success','',JSON.serialize(successLst));
        } else if(creditNtfnReqObj.CreditDebitNotification.size() == ATI_REST_CreditDebitNotifnValidator.totalFailedRecords){
            response.message = 'All the records have failed to update.';
            response.status = 'Failed';
            createLog('Credit/Debit_Notification', JSON.serialize(creditNtfnReqObj), Json.serialize(response), 'Failed',JSON.serialize(errorLst),JSON.serialize(errorLst));
        } else {
            response.message = 'Few records have not been inserted / updated.';
            response.status = 'Partial Success';
            createLog('Credit/Debit_Notification', JSON.serialize(creditNtfnReqObj), Json.serialize(response), 'Partial Success',JSON.serialize(errorLst),'Success>> '+JSON.serialize(successLst)+',Failure>> '+JSON.serialize(errorLst));
        }
        return response;    
    }
    
    private void createLog(String processName,String request,String response, String status, String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_CreditNotification_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.ProcessName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!ATI_REST_CreditDebitNotifnValidator.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(ATI_REST_CreditDebitNotifnValidator.mapOfFailure.values());
                objLogSerWrp.failureRecordCount = ATI_REST_CreditDebitNotifnValidator.totalFailedRecords;
            }
            objLogSerWrp.successRecordCount = ATI_REST_CreditDebitNotifnValidator.totalRecords-ATI_REST_CreditDebitNotifnValidator.totalFailedRecords;
            if(identifier == null || identifier == ''){
                if(status != 'Success'){
                    CreditNotificationResponse responseWrapperObj = (CreditNotificationResponse)System.JSON.deserialize(response,CreditNotificationResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = ATI_REST_CreditDebitNotifnValidator.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = ATI_REST_CreditDebitNotifnValidator.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            objLogSerWrp.totalRecordCount = ATI_REST_CreditDebitNotifnValidator.totalRecords;
            System.debug('LogService'+objLogSerWrp);
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    public WOD_2.ResponseWrapper processType(Id logId, String creditNotificationRequest){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper(null,false,null);
        SavePoint sp = Database.setSavepoint();
        try {
            ATI_REST_CreditDebitNotificationRequest creditNtfnReqObj = new ATI_REST_CreditDebitNotificationRequest();
        	creditNtfnReqObj = ATI_REST_CreditDebitNotificationRequest.parse(creditNotificationRequest);
            ATI_REST_CreditDebitNotifnValidator validatorObj = new ATI_REST_CreditDebitNotifnValidator();
            validatorObj.validateRequest(creditNtfnReqObj.CreditDebitNotification); 
            validClaimCreditDebitNotfnMap = ATI_REST_CreditDebitNotifnValidator.validClaimCreditDebitNotfnMap;
            if(!validClaimCreditDebitNotfnMap.isEmpty()){
                updateClaimAndTMHStatus(creditNtfnReqObj.CreditDebitNotification);
            }
            CreditNotificationResponse response = createResponse(creditNtfnReqObj);
            responseWrapperObj.data = Json.serialize(response);
            responseWrapperObj.status = true;
        }catch(Exception e){
            responseWrapperObj.data = null;
            responseWrapperObj.status = true;
            responseWrapperObj.errormessage = e.getMessage() + e.getStackTraceString();
            Database.rollback(sp);
        }
        return responseWrapperObj;
    }

    private void updateClaimAndTMHStatus(List<ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> creditNtfnReqObj){
       List<WOD_2__Transaction_Memo_History__c> tmhList = 
            [SELECT Id, WOD_2__Claim__c, WOD_2__Claim__r.Name, WOD_2__Transaction_Status__c,ATI_Warranty_Registration__r.Name,
                WOD_2__Transaction_Number__c, WOD_2__Comments__c,WOD_2__Transaction_Type__c,WOD_2__Transaction_Date__c
                FROM WOD_2__Transaction_Memo_History__c WHERE (WOD_2__Claim__r.Name IN :validClaimCreditDebitNotfnMap.keySet() OR 
                ATI_Warranty_Registration__r.Name IN :validClaimCreditDebitNotfnMap.keySet())
                AND WOD_2__Transaction_Status__c = 'Waiting for Payment Confirmation'];
        List<WOD_2__Claim__c> claimLst = new List<WOD_2__Claim__c>();
        Set<Id> lockedClaimIdSet = new Set<Id>();
        List<WOD_2__Transaction_Memo_History__c> tmhToUpdateLst = new List<WOD_2__Transaction_Memo_History__c>();
        for(WOD_2__Transaction_Memo_History__c tmhObj : tmhList){
            String claimOrWRName = '';
            if(tmhObj.WOD_2__Claim__c != NULL){
                claimOrWRName = tmhObj.WOD_2__Claim__r.Name;
            }else{
                claimOrWRName = tmhObj.ATI_Warranty_Registration__r.Name;
            }
            if(validClaimCreditDebitNotfnMap.get(claimOrWRName).transactionStatus.equalsIgnoreCase('Paid')){
                if(tmhObj.WOD_2__Claim__c != NULL){
                    WOD_2__Claim__c claimObj = new WOD_2__Claim__c(Id=tmhObj.WOD_2__Claim__c);
                    claimObj.WOD_2__Claim_Status__c = 'Paid';
                    claimObj.ATI_Is_Claim_Appealed_Or_Reopened__c = false;
                    claimLst.add(claimObj);
                    if(Approval.isLocked(claimObj.Id)){
                        lockedClaimIdSet.add(claimObj.Id);
	                }
                }
                
                tmhObj.WOD_2__Transaction_Status__c = 'Paid';
                if(validClaimCreditDebitNotfnMap.get(claimOrWRName).Comment != NULL){
                	tmhObj.WOD_2__Comments__c = validClaimCreditDebitNotfnMap.get(claimOrWRName).Comment.trim();   
                }
                tmhObj.WOD_2__Transaction_Number__c = validClaimCreditDebitNotfnMap.get(claimOrWRName).transactionNumber.trim();
                tmhObj.WOD_2__Transaction_Date__c = ATI_Utils.parseDate(validClaimCreditDebitNotfnMap.get(claimOrWRName).transactionDate.trim());
                tmhToUpdateLst.add(tmhObj);
            }
        }
        if(!claimLst.isEmpty()){
            List<Id> lockedClaimIdList = new List<Id>(lockedClaimIdSet);
            ATI_WithoutSharingService.unLockRecords(lockedClaimIdList);
            update claimLst; 
            ATI_WithoutSharingService.lockRecords(lockedClaimIdList);
        }
        //ALSN-116 TMH update will happen after claim update to get the previous field values of FLI too.
        if(!tmhToUpdateLst.isEmpty()){
            update tmhToUpdateLst;
        }
    }
    
    global class CreditNotificationResponse {
        global String status;
        global String message;
        global String interfaceName;
        global List<CreditNotificationData> data;
    }

    global class CreditNotificationData {
        global String claimNumber;
        global String message;
        global String status;
    }
}