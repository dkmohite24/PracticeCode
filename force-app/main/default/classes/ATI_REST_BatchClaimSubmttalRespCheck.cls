/* Name: ATI_REST_BatchClaimSubmttalRespCheck
Description : Endpoint which retrieves claim information
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL                  UserStory/Req#
1.0 -     Tavant(TY)       16/02/2021      INITIAL DEVELOPMENT                              
*/
@RestResource(urlMapping = '/ATIRESTBatchClaimSubmittalResponse/*')
global class ATI_REST_BatchClaimSubmttalRespCheck implements ATI_LoggableInterface{
    
    @HttpPost
    global Static ATI_REST_BatchClaimSubmittalResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_BatchClaimSubmttalRespCheck batchClaimSubmittalObj = new ATI_REST_BatchClaimSubmttalRespCheck();
        ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = batchClaimSubmittalObj.getClaimDetails(requestBody);
        return batchClaimSubmittalResponse;
    }
    
    public ATI_REST_BatchClaimSubmittalResponse getClaimDetails(String batchClaimSubmittalRequest){
        ATI_REST_BatchClaimSubmittalResponse batchClaimSubmittalResponse = new ATI_REST_BatchClaimSubmittalResponse();
        WOD_2.ResponseWrapper response = processType(batchClaimSubmittalRequest);
        if(response != null && response.data != null && response.data != '') {
            batchClaimSubmittalResponse = (ATI_REST_BatchClaimSubmittalResponse)Json.deserialize(response.data,ATI_REST_BatchClaimSubmittalResponse.class);
        }else {
            batchClaimSubmittalResponse.status = 'Success';
            batchClaimSubmittalResponse.batchClaimResponse = null;
            batchClaimSubmittalResponse.message = response.errormessage;
            createLog('BatchClaimSubmittalResponse',batchClaimSubmittalRequest,JSON.serialize(batchClaimSubmittalResponse),'Success',null,null,response.errormessage);
        }
        return batchClaimSubmittalResponse;   
    }
    
    private ATI_REST_BatchClaimSubmttalRespValidator batchClaimSubmittalValidatorObj{get; private set;}
    private String rmsCodeWithDescription{get; private set;}
    private ATI_REST_BatchClaimSubmttalRespRequest batchClaimSubmittalReq{get; private set;}
    public WOD_2.ResponseWrapper processType(String batchClaimSubmittalRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        batchClaimSubmittalValidatorObj = new ATI_REST_BatchClaimSubmttalRespValidator();
        try{
            batchClaimSubmittalReq = ATI_REST_BatchClaimSubmttalRespRequest.parse(batchClaimSubmittalRequest);
            batchClaimSubmittalValidatorObj.validateReqest(batchClaimSubmittalReq);
            ATI_REST_BatchClaimSubmittalResponse response = new ATI_REST_BatchClaimSubmittalResponse();
            response.interfaceName = 'I-207 - Batch Claim Submittal Response';
            rmsCodeWithDescription = null;
            if(!batchClaimSubmittalValidatorObj.mapOfFailure.isEmpty() && batchClaimSubmittalValidatorObj.mapOfFailure.containsKey(0)){
                response.message = String.Join(batchClaimSubmittalValidatorObj.mapOfFailure.get(0),', ') ;
                response.status = 'Success';
                createLog('BatchClaimSubmittalResponse',batchClaimSubmittalRequest,JSON.serialize(response),'Success',null,null,response.message);
            }else{
                if(!batchClaimSubmittalValidatorObj.claimData.isEmpty()){
                    List<BatchClaimResponseData> claimResponseData = new List<BatchClaimResponseData>();
                    response.message = 'Record Retrieved Successfully';
                    ATI_REST_BatchClaimSubmttalRespRequest.ClaimInformation claimInfo = batchClaimSubmittalReq.claimStatusCheck;
            		BatchClaimResponseData responseData = new BatchClaimResponseData();
                    ClaimInformation claimData = new ClaimInformation();
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).Name != null){
                        claimData.claimNumber = batchClaimSubmittalValidatorObj.claimData.get(0).Name;
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Tracking_Number__c != null){
                        claimData.trackingNumber = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Tracking_Number__c;
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Account__c != null && batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Account__r.SAP_ID__c != null){
                        if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Account__r.ATI_Financial_BP_Code__c != null){
                            responseData.businessPartnerCode = batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Account__r.ATI_Financial_BP_Code__c;
                        }
						claimData.repairingOutlet = batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Account__r.SAP_ID__c;
                        List<Account> accountLst = [SELECT Id,SAP_ID__c FROM Account WHERE (ATI_Alternate_Parent__c != null AND ATI_Alternate_Parent__r.SAP_ID__c=:claimInfo.businessPartnerCode) OR SAP_ID__c=:claimInfo.businessPartnerCode];
                        Map<String,Account> accMap = new Map<String,Account>();
                        for(Account acc : accountLst){
                            accMap.put(acc.SAP_ID__c,acc);
                        }
                        if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Total_Approved_Amount__c != null && accMap.containsKey(claimData.repairingOutlet)){
                           // claimData.approvedDollarAmount = String.valueOf(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Total_Approved_Amount__c);
                       claimData.approvedDollarAmount = String.valueOf(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Total_Approved_Amount__c.setScale(2));
                        }
                        
                        
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Work_Order__c != null){
                        claimData.repairOrder = batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Work_Order__c;
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Inventory__r.Name != null){
                        claimData.serialNumber =  batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Inventory__r.Name;
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Submittal_Indicator__c != null){
                        claimData.submittalIndicator = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Submittal_Indicator__c;
                    }
                    claimData.dateTimeProcessed = String.valueOf(batchClaimSubmittalValidatorObj.claimData.get(0).LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Claim_Status_Codes__c != null){
                        claimData.claimStatusCode = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Claim_Status_Codes__c.split('-')[0];
                        claimData.claimStatusDescription = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Claim_Status_Codes__c.split('-')[1];
                    }else{
                        claimData.claimStatusCode = '99';
                        claimData.claimStatusDescription = 'OTHERS';
                    }
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Disposition_Code__c != null){
                        claimData.dispositionCode = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Disposition_Code__c.SubStringBefore('-');
                        claimData.dispositionCodeDescription = batchClaimSubmittalValidatorObj.claimData.get(0).ATI_Disposition_Code__c.SubStringAfter('-');
                    }
                    rmsCodeWithDescription = getRMSStatusCodes();
                    if(rmsCodeWithDescription != null){
                        claimData.rmaStatusCode = rmsCodeWithDescription.split('-')[0];
                        claimData.rmaStatusDescription = rmsCodeWithDescription.split('-')[1];
                    }
                    claimData.identifier = claimInfo.identifier;
                    //Integer index = 1;
                    List<ClaimRelatedInformation> claimRelatedInfoData = new List<ClaimRelatedInformation>();
                    if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_BatchClaim_Error_Messages__c != null){
                         claimRelatedInfoData = (List<ClaimRelatedInformation>)JSON.deserialize(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_BatchClaim_Error_Messages__c,List<ClaimRelatedInformation>.class);
                    }
                    List<WOD_2__Business_Rule__c> businessRulesLst = fetchBURules(batchClaimSubmittalValidatorObj.claimData.get(0));
                    if(!businessRulesLst.isEmpty()){
                        for(WOD_2__Business_Rule__c businessRule : businessRulesLst){
                            if(businessRule.WOD_2__Message__c != null){
                                ClaimRelatedInformation claimRelatedInfo = new ClaimRelatedInformation();
                                //claimRelatedInfo.lineNumber = String.valueOf(index);
                                claimRelatedInfo.processCategoryDescription = businessRule.WOD_2__Business_Category_Configuration_Setting__r.WOD_2__Sub_Module__c;
                                if(businessRule.WOD_2__Message__c.contains('-')){
                                    claimRelatedInfo.processCode = businessRule.WOD_2__Message__c.split('-')[0];
                                    claimRelatedInfo.processMessage = businessRule.WOD_2__Message__c.split('-')[1];
                                }else{
                                    claimRelatedInfo.processCode = '99';
                                    claimRelatedInfo.processMessage = businessRule.WOD_2__Message__c;
                                }
                                claimRelatedInfoData.add(claimRelatedInfo);
                                //index++;
                            }
                        }
                    }
                    claimData.claimProcessMsgInfo = claimRelatedInfoData;
                    responseData.claimInfo = claimData;
                    claimResponseData.add(responseData);
                    response.batchClaimResponse = claimResponseData;
                    response.status = 'Success';
                    createLog('BatchClaimSubmittalResponse',batchClaimSubmittalRequest,JSON.serialize(response),'Success',null,batchClaimSubmittalValidatorObj.claimData.get(0).Name,null);
                }
            }
            responseWrapper.data = JSON.serialize(response);
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('message'+ e.getMessage());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return responseWrapper;
    }
    
    //getRMSStatusCodes
    private String getRMSStatusCodes(){
        if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_No_of_Requested_Parts__c > 0){
            if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Claim_Status__c.equalsIgnoreCase('Paid')){
                rmsCodeWithDescription = '10-DONE';
            }else if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected')){
                rmsCodeWithDescription = '30-RMA EXCEPTIONS';
            }else if(batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') || batchClaimSubmittalValidatorObj.claimData.get(0).WOD_2__Claim_Status__c.equalsIgnoreCase('Submitted')){
                if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_No_of_Requested_Parts__c == batchClaimSubmittalValidatorObj.claimData.get(0).ATI_No_of_Received_Parts__c){
                    rmsCodeWithDescription = '50-RECEIVED';
                }else if(batchClaimSubmittalValidatorObj.claimData.get(0).ATI_No_of_Requested_Parts__c == batchClaimSubmittalValidatorObj.claimData.get(0).ATI_No_of_Shipped_Parts__c){
                    rmsCodeWithDescription = '40-SENT';
                }else{
                    rmsCodeWithDescription = '20-ISSUED';
                }
            }
        }
        return rmsCodeWithDescription;
    }
    
    //fetchBURules
    private static List<WOD_2__Business_Rule__c> fetchBURules(WOD_2__Claim__c claim){
        List<WOD_2__Business_Rule__c> businessRulesLst = new List<WOD_2__Business_Rule__c>();
        List<String> removedPartFields = new List<String>{'WOD_2__Message__c','WOD_2__Claim__c','WOD_2__Business_Category_Configuration_Setting__r.WOD_2__Sub_Module__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Business_Rule__c',removedPartFields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            businessRulesLst = [SELECT Id,WOD_2__Message__c,WOD_2__Business_Category_Configuration_Setting__r.WOD_2__Sub_Module__c FROM WOD_2__Business_Rule__c WHERE WOD_2__Claim__c=:claim.id];
        }else{
            String errortext = 'Insufficient BusinessRule Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('BatchClaimSubmittalResponse',errortext);
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
        return businessRulesLst;
    }
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey,String errorMessage){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_BatchClaimSubResp_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(status == 'Success'){
                objLogSerWrp.successRecordCount = 1;
                objLogSerWrp.failureRecordCount = 0;
            }else{
                objLogSerWrp.failureRecordCount = 1;
                objLogSerWrp.successRecordCount = 0;
            }
            objLogSerWrp.errortext = errorMessage;
            objLogSerWrp.totalRecordCount = 1;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /*******************************************************************************
	Description    :   A wrapper class to capture the BatchClaimSubmittal Rest data.
	********************************************************************************/
    global class ATI_REST_BatchClaimSubmittalResponse{
        global String status;
        global String interfaceName;
        global List<BatchClaimResponseData> batchClaimResponse;
        global String message;
    }
    
    global class BatchClaimResponseData{
        global String businessPartnerCode = '';
        global ClaimInformation claimInfo;
    }
    
    global class ClaimInformation{
        global String claimNumber = '';
        global String trackingNumber = '';
        global String repairingOutlet = '';
        global String repairOrder = '';
        global String serialNumber = '';
        global String submittalIndicator = '';
        global String dateTimeProcessed = '';
        global String claimStatusCode = '';
        global String claimStatusDescription = '';
        global String dispositionCode = '';
        global String dispositionCodeDescription = '';
        global String rmaStatusCode = '';
        global String rmaStatusDescription = '';
        global String approvedDollarAmount = '';
        global String identifier = '';
        global List<ClaimRelatedInformation> claimProcessMsgInfo;
    }
    
    global class ClaimRelatedInformation{
        global String lineNumber = '';
        global String processCode = '';
        global String processCategoryDescription = '';
        global String processMessage = '';
    }   
}