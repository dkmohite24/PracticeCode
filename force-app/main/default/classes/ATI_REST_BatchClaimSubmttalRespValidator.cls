/* Name: ATI_REST_BatchClaimSubmttalRespValidator
Description : This Class is used to validate I207-BatchClaimSubmttal JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      16/02/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_BatchClaimSubmttalRespValidator {
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public List<WOD_2__Claim__c> claimData{get;private set;}
    public List<Account> accountData{get; private set;}
    public Map<String,WOD_2__Inventory__c> mapOfInventory{get; private set;}
    public ATI_REST_BatchClaimSubmttalRespValidator(){
        mapOfFailure = new Map<Integer,List<String>>();
        mapOfInventory = new Map<String,WOD_2__Inventory__c>();
        claimData = new List<WOD_2__Claim__c>();
        accountData = new List<Account>();
    }
    
    public void validateReqest(ATI_REST_BatchClaimSubmttalRespRequest batchClaimSubmittalRequestBody){
        queryClaimData(batchClaimSubmittalRequestBody);
        verifybatchClaimSubmittalRequest(batchClaimSubmittalRequestBody);
    }
    
    public void queryClaimData(ATI_REST_BatchClaimSubmttalRespRequest batchClaimSubmittalRequestBody){
        if(checkClaimReadAccess()){
            ATI_REST_BatchClaimSubmttalRespRequest.ClaimInformation claim = batchClaimSubmittalRequestBody.claimStatusCheck;
            if(ATI_Utils.checkIsNotBlankData(claim.trackingNumber) && ATI_Utils.checkIsNotBlankData(claim.businessCategoryConfiguration) && ATI_Utils.checkIsNotBlankData(claim.businessPartnerCode)){
                claimData = [SELECT Id,Name,CreatedById,ATI_BatchClaim_Error_Messages__c,WOD_2__Account__r.ATI_Financial_BP_Code__c,ATI_Tracking_Number__c,ATI_Disposition_Code__c,WOD_2__BusinessCategory__c,WOD_2__BusinessCategory__r.Name,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Work_Order__c,ATI_Submittal_Indicator__c,
                             WOD_2__Claim_Status__c,ATI_Claim_Status_Codes__c,LastModifiedDate,WOD_2__Inventory__r.Name,ATI_Total_Approved_Amount__c,ATI_No_of_Requested_Parts__c,ATI_No_of_Shipped_Parts__c,ATI_No_of_Received_Parts__c,ATI_No_of_Inspected_Parts__c
                             FROM WOD_2__Claim__c WHERE ATI_Tracking_Number__c=:claim.trackingNumber.trim() AND  WOD_2__BusinessCategory__r.Name=:claim.businessCategoryConfiguration.trim() 
                                                        AND WOD_2__Account__r.SAP_ID__c=:claim.businessPartnerCode Order By CreatedDate DESC Limit 1];
                             System.debug('claimData-------->'+claimData);
                accountData = [SELECT Id FROM Account WHERE SAP_ID__c=:claim.businessPartnerCode];           
            }
        }else{
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
    }
    
    public void verifybatchClaimSubmittalRequest(ATI_REST_BatchClaimSubmttalRespRequest batchClaimSubmittalRequestBody){
        List<String> errorList = new List<String>();
        ATI_REST_BatchClaimSubmttalRespRequest.ClaimInformation claim = batchClaimSubmittalRequestBody.claimStatusCheck;
        if(ATI_Utils.checkIsBlankData(claim.identifier)){
             errorList.add('Identifier is Mandatory');
        }
        if(ATI_Utils.checkIsBlankData(claim.businessPartnerCode)){
            errorList.add('BusinessPartnerCode is Mandatory');
        }
        if(ATI_Utils.checkIsBlankData(claim.businessCategoryConfiguration)){
            errorList.add('BusinessCategoryConfiguration is Mandatory');
        }
        if(ATI_Utils.checkIsBlankData(claim.trackingNumber)){
            errorList.add('TrackingNumber is Mandatory');
        }
        if(ATI_Utils.checkIsNotBlankData(claim.businessCategoryConfiguration) && ATI_Utils.checkIsNotBlankData(claim.trackingNumber)
           && claimData.isEmpty() && ATI_Utils.checkIsNotBlankData(claim.businessPartnerCode) && !accountData.isEmpty()){
               errorList.add('Claim not Found');
        }else if(ATI_Utils.checkIsNotBlankData(claim.businessPartnerCode) && accountData.isEmpty() && ATI_Utils.checkIsNotBlankData(claim.trackingNumber)
                && ATI_Utils.checkIsNotBlankData(claim.businessCategoryConfiguration)){
            errorList.add('BusinessPartnerCode is Invalid');
        }
        if(errorList.size() > 0){
            mapOfFailure.put(0,errorList);
        }
    }
    
    public static Boolean checkClaimReadAccess(){
        String objectName = 'WOD_2__Claim__c';
        List<String> fields = new List<String>{'Name','CreatedById','ATI_Tracking_Number__c','ATI_Disposition_Code__c','WOD_2__BusinessCategory__c','WOD_2__BusinessCategory__r.Name','WOD_2__Account__r.ATI_Financial_BP_Code__c','WOD_2__Account__c','WOD_2__Account__r.SAP_ID__c','ATI_Claim_Status_Codes__c',
            'WOD_2__Work_Order__c','ATI_Submittal_Indicator__c','WOD_2__Claim_Status__c','LastModifiedDate','WOD_2__Inventory__r.Name','ATI_Total_Approved_Amount__c','ATI_No_of_Requested_Parts__c','ATI_No_of_Shipped_Parts__c','ATI_No_of_Received_Parts__c','ATI_No_of_Inspected_Parts__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient Claim Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('BatchClaimSubmittalResponse',errortext);
            return false;
        }
    }
    
}