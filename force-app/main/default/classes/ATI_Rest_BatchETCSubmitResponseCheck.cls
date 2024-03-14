/* Name: ATI_Rest_BatchETCSubmitResponseCheck
Description : Endpoint which retrieves Extended Warranty Registration data and send it to  external system 
Author : Tavant(Punam)
History:
VERSION     AUTHOR            DATE              DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)       22/02/2021      INITIAL DEVELOPMENT             20656                 
*/

@RestResource(urlMapping = '/ATIRestBatchETC/*')
global with sharing class ATI_Rest_BatchETCSubmitResponseCheck implements ATI_LoggableInterface{
    
     /* 
     * 
     * Method Added  
     * 
     * Http Post Integration method
     * 
	*/
    @HttpPost
    global Static ATI_Rest_BatchETCSubmitCheckResponse doPost(){
		String requestBody = RestContext.request.requestBody.toString();
        ATI_Rest_BatchETCSubmitResponseCheck batchETCRespCheckObj = new ATI_Rest_BatchETCSubmitResponseCheck();
        ATI_Rest_BatchETCSubmitCheckResponse batchETCRespCheckResponse = batchETCRespCheckObj.batchEtcResponseCheck(requestBody);
        return batchETCRespCheckResponse;
	}
    
    /* 
     * 
     * Method Added  
     * 
     * Get Response after Batch ETC Submittal Response Integration
     * 
	*/
    public ATI_Rest_BatchETCSubmitCheckResponse batchEtcResponseCheck(String batchETCCheckRequest){
        ATI_Rest_BatchETCSubmitCheckResponse batchEtcResponse = new ATI_Rest_BatchETCSubmitCheckResponse();
        WOD_2.ResponseWrapper response = processType(batchETCCheckRequest);
        if(response != null && response.data != null && response.data != '') {
            batchEtcResponse = (ATI_Rest_BatchETCSubmitCheckResponse)Json.deserialize(response.data,ATI_Rest_BatchETCSubmitCheckResponse.class);
        }else {
            batchEtcResponse.status = 'Fail';
            batchEtcResponse.data = null;
            batchEtcResponse.message = response.errormessage;
            createLog('BatchEtcResponseCheck',batchETCCheckRequest,JSON.serialize(batchEtcResponse),'Failed',null,null,response.errormessage);
        }
        return batchEtcResponse;  
    }
    
    private ATI_Rest_BatchETCSubmitResponseValidator batchEtcResponseValidatorObj{get; private set;}
    
    /* 
     * 
     * Method Added  
     * 
     * Method has been created to do all operations after api hit.
     * 
	*/
    public WOD_2.ResponseWrapper processType(String batchEtcResponseRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        batchEtcResponseValidatorObj = new ATI_Rest_BatchETCSubmitResponseValidator();
        ATI_Rest_BatchETCSubmitResponseRequest batchEtcRespReq = new ATI_Rest_BatchETCSubmitResponseRequest();
        try{
			system.debug('batchEtcResponseRequest'+batchEtcResponseRequest);
            batchEtcRespReq = (ATI_Rest_BatchETCSubmitResponseRequest) System.JSON.deserialize(batchEtcResponseRequest,ATI_Rest_BatchETCSubmitResponseRequest.class);
            batchEtcResponseValidatorObj.validateReqest(batchEtcRespReq.ETCStatusCheck);
            ATI_Rest_BatchETCSubmitCheckResponse response = new ATI_Rest_BatchETCSubmitCheckResponse();
            response.interfaceName = 'I-719 - Batch ETC Purchase Submittal Response';
            if(!batchEtcResponseValidatorObj.mapOfFailure.isEmpty() && batchEtcResponseValidatorObj.mapOfFailure.containsKey(0)){
                response.message = String.Join(batchEtcResponseValidatorObj.mapOfFailure.get(0),', ')+'. Serial no: '+ batchEtcRespReq.ETCStatusCheck.serialNumber;
                response.status = 'Failed';
                response.data= new ResponseData();
                createLog('BatchEtcResponseCheck',batchEtcResponseRequest,JSON.serialize(response),'Failed',null,null,response.message);
            }else{
                List<WOD_2__Warranty_Registration__c> wRegList = new List<WOD_2__Warranty_Registration__c>();
				
                ResponseData data = new ResponseData();
                String wRegObj='WOD_2__Warranty_Registration__c';
                List<String> wRegfields = new List<String>{'Id','Name','ATI_Tracking_Number__c','ATI_Extended_Warranty_Purchase_Date__c','ATI_Submittal_Indicator__c','ATI_Submitter_Name__c','ATI_Submitter_Phone__c','ATI_PO_Number__c','WOD_2__Registration_Date__c','ATI_CE_Number__c','WOD_2__Registration_Type__c','WOD_2__Status__c','WOD_2__Account__c','WOD_2__Units_Usage__c','WOD_2__Inventory__c','WOD_2__Install_Date__c','ATI_Vocation_Code__c','WOD_2__Customer__c','LastModifiedDate'};           
                ATI_Utils.NoAccessObjectFieldWrapper wRegReadAccessCheck = ATI_Utils.fetchReadAccess(wRegObj,wRegfields);
				Set<Id> wrIdSet= new Set<Id>();
                // Vijay changes start - ALSN 35
                Set<Id> wrIdSetFromInv= new Set<Id>();
                List<WOD_2__Inventory__c> invList = [select Id,(select id from WOD_2__Warranty_Registration__r) from WOD_2__Inventory__c where WOD_2__Serial_Number__c =: batchEtcRespReq.ETCStatusCheck.serialNumber AND WOD_2__Business_Unit__r.Name =: batchEtcRespReq.ETCStatusCheck.businessCategoryConfiguration];
                if(invList!= null && invList.size()>0){
                    for(WOD_2__Inventory__c inv: invList){
                        for(WOD_2__Warranty_Registration__c wr :inv.WOD_2__Warranty_Registration__r){
                            wrIdSetFromInv.add(wr.Id);
                        }
					}
                } 
                // Vijay changes end
                 
				List<WOD_2__Warranty_Coverages__c> coverageList= [SELECT WOD_2__Warranty_Registration__c FROM WOD_2__Warranty_Coverages__c where WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended' ANd WOD_2__Warranty_Registration__c IN:wrIdSetFromInv]; // vijay changes : AND condition added
				if(coverageList!= null && coverageList.size()>0){
					for(WOD_2__Warranty_Coverages__c cov: coverageList){
						wrIdSet.add(cov.WOD_2__Warranty_Registration__c);
					}
					
				}
				
                if(wRegReadAccessCheck.noAccessObjectList.size() == 0 && wRegReadAccessCheck.noAccessFieldList.size() == 0){
	                    wRegList=[Select Id,Name,ATI_Tracking_Number__c,ATI_Extended_Warranty_Purchase_Date__c,ATI_Submittal_Indicator__c,ATI_Submitter_Name__c,ATI_Submitter_Phone__c,ATI_PO_Number__c,WOD_2__Registration_Date__c,ATI_CE_Number__c,WOD_2__Registration_Type__c,WOD_2__Status__c,WOD_2__Account__c,WOD_2__Units_Usage__c,WOD_2__Inventory__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Install_Date__c,ATI_Vocation_Code__c,WOD_2__Customer__c,(SELECT Id,WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Warranty_Registration__c,ATI_Reason__c,Name,WOD_2__Policy_Definition__r.WOD_2__Type__c,WOD_2__Is_Active__c FROM WOD_2__Warranty_Coverages__r where WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended' /*AND WOD_2__Is_Active__c=true*/),(Select Id,WOD_2__Amount__c,WOD_2__Transaction_Status__c,ATI_Warranty_Registration__r.WOD_2__Account__c,WOD_2__Transaction_Type__c From Transaction_Memo_Histories__r order by CreatedDate desc LIMIT 1/*Where WOD_2__Transaction_Type__c='Debit'*/ /*AND ATI_Warranty_Registration__r.WOD_2__Account__c=: batchEtcResponseValidatorObj.accountId*/),LastModifiedDate From WOD_2__Warranty_Registration__c  Where WOD_2__Inventory__r.WOD_2__Serial_Number__c =: batchEtcRespReq.ETCStatusCheck.serialNumber AND WOD_2__Inventory__r.WOD_2__Business_Unit__r.Name =: batchEtcRespReq.ETCStatusCheck.businessCategoryConfiguration /*AND WOD_2__Account__c =: batchEtcResponseValidatorObj.accountId */AND (Id IN: wrIdSet OR (WOD_2__Status__c='Draft' AND WOD_2__Registration_Type__c='Extended')) order by CreatedDate desc LIMIT 1 ];
                }else {
                    String errortext = 'Insufficient Warranty Registration Read Access-->> '+JSON.serialize(wRegReadAccessCheck);
                    ATI_LogService.createLogForAccess('BatchEtcSubmittalResponse',errortext);
                } 
                
                if(wRegList.size()>0){
                    Map<Id,List<WOD_2__Business_Category_Configuration_Setting__c>> burRulesTriggeredMap = runBURules(batchEtcResponseValidatorObj.buNameIdMap.get(batchEtcRespReq.ETCStatusCheck.businessCategoryConfiguration),'WOD_2__Warranty_Registration__c',new List<Id>{wRegList[0].Id},'Warranty Registration','Registration Logic');
                    List<EtcProcessMsgInformation> etcProcessMsgInfoList = new List<EtcProcessMsgInformation>();
                    EtcProcessMsgInformation etcProcess = new EtcProcessMsgInformation();
                    Integer i=1;
                    if(burRulesTriggeredMap!= null){
                        for(WOD_2__Business_Category_Configuration_Setting__c buConfig: burRulesTriggeredMap.values()[0]){
                            etcProcess = new EtcProcessMsgInformation();
                            etcProcess.processMessage=buConfig.WOD_2__Display_Message__c;
                            etcProcess.processCategoryDescription='Warranty Registration';
                            etcProcess.processCode='';
                            //etcProcess.lineNumber=String.valueOf(i);
                            
                            etcProcessMsgInfoList.add(etcProcess);
                            i++;
                        }
                    }
					response.message = 'Record Retrieved Successfully for' +' Serial no: '+ batchEtcRespReq.ETCStatusCheck.serialNumber;
					EtcInformation etcData = new EtcInformation();
					if(wRegList[0].Name != '' && wRegList[0].Name!= null){
						etcData.etcRegistrationNumber= wRegList[0].Name;
					}else{
						etcProcess = getEtcProcessCode(String.valueOf(i),'7081','Warranty Registration',ATI_UtilConstants.regNumValidation );
						etcProcessMsgInfoList.add(etcProcess);
						i++;
					}
					etcData.trackingNumber= wRegList[0].ATI_Tracking_Number__c;
					etcData.repairingOutlet= batchEtcRespReq.ETCStatusCheck.businessPartnerCode.trim();
					etcData.purchaseOrder= wRegList[0].ATI_PO_Number__c;
					if(wRegList[0].WOD_2__Inventory__r.WOD_2__Serial_Number__c!='' && wRegList[0].WOD_2__Inventory__r.WOD_2__Serial_Number__c!= null){
						etcData.serialNumber= wRegList[0].WOD_2__Inventory__r.WOD_2__Serial_Number__c;
					}else{
						etcProcess = getEtcProcessCode(String.valueOf(i),'105','Warranty Registration',ATI_UtilConstants.serialNumValidation );
						etcProcessMsgInfoList.add(etcProcess);
						i++;
					}
					if(wRegList[0].ATI_Submittal_Indicator__c!='' && wRegList[0].ATI_Submittal_Indicator__c!= null){
						etcData.submittalIndicator= wRegList[0].ATI_Submittal_Indicator__c;
					}else{
						etcProcess = getEtcProcessCode(String.valueOf(i),'7001','Warranty Registration',ATI_UtilConstants.submitIndValidation );
						etcProcessMsgInfoList.add(etcProcess);
						i++;
					}
					etcData.dateTimeETCProcessed= String.valueOf(wRegList[0].LastModifiedDate);
					if(wRegList[0].Transaction_Memo_Histories__r!= null && wRegList[0].Transaction_Memo_Histories__r.size()>0){
						//etcData.etcStatusCode= statusCodeMap.get(wRegList[0].WOD_2__Status__c);
						//etcData.etcStatusDescription= wRegList[0].WOD_2__Status__c;
						String etcStatusDescription = getStatus(wRegList[0].WOD_2__Status__c,wRegList[0].Transaction_Memo_Histories__r);
						etcData.etcStatusCode= getTMHStatusCodeMap().get(etcStatusDescription);
						etcData.etcStatusDescription= etcStatusDescription;
                    }else if(wRegList[0].Transaction_Memo_Histories__r.size()<=0){
                        String etcStatusDescription = getStatus(wRegList[0].WOD_2__Status__c,null);
						etcData.etcStatusCode= getTMHStatusCodeMap().get(etcStatusDescription);
						etcData.etcStatusDescription= etcStatusDescription;
                        
                    }else{
						etcProcess = getEtcProcessCode(String.valueOf(i),'','Warranty Registration',ATI_UtilConstants.statusCodeValidation);
						etcProcessMsgInfoList.add(etcProcess);
						i++;
					}
                    //19th April
                    if(wRegList[0].Transaction_Memo_Histories__r!= null && wRegList[0].Transaction_Memo_Histories__r.size()>0 && wRegList[0].WOD_2__Account__c== batchEtcResponseValidatorObj.accountId){
                        etcData.etcDebitAmount= String.valueOf(wRegList[0].Transaction_Memo_Histories__r[0].WOD_2__Amount__c);
                        
                    }
					
					if(wRegList[0].WOD_2__Registration_Date__c > Date.Today()){
						etcProcess = getEtcProcessCode(String.valueOf(i),'7083','Warranty Registration',ATI_UtilConstants.regDateValidation);
						etcProcessMsgInfoList.add(etcProcess);
						i++;
					}
                    if(wRegList[0].WOD_2__Status__c.equalsignorecase(ATI_UtilConstants.deRegistered)){
                        etcData.dispositionCode= '7144';
                        etcData.dispositionCodeDescription= ATI_UtilConstants.etcCancelValidation;	
                    }else if(wRegList[0].WOD_2__Status__c.equalsignorecase(ATI_UtilConstants.rejected)){
                        etcData.dispositionCode= '7143';
                        etcData.dispositionCodeDescription= ATI_UtilConstants.etcDeniedValidation;
                    }
                    
					etcData.etcProcessMsgInfo = etcProcessMsgInfoList;
					//data.etcIno.etcProcessMsgInfo = etcProcessMsgInfoList;
					data.etcInfo = etcData;
                    data.businessPartnerCode= batchEtcRespReq.ETCStatusCheck.businessPartnerCode.trim();
                    //data.identifier= batchEtcRespReq.ETCStatusCheck.identifier;
                    response.status = 'Success';
                    //createLog('BatchEtcResponseCheck',batchEtcResponseRequest,JSON.serialize(response),'Success',null,batchEtcRespReq.ETCStatusCheck.serialNumber,response.message);
                    if(data!= null){
                        response.data = data;
                    }else{
                        response.data = new ResponseData();
                    }
                    createLog('BatchEtcResponseCheck',batchEtcResponseRequest,JSON.serialize(response),'Success',null,batchEtcRespReq.ETCStatusCheck.serialNumber,response.message);
				}else{
                    response.message = 'No Extended Warranty Registration Found for' +' Serial no: '+ batchEtcRespReq.ETCStatusCheck.serialNumber;
                    response.status = 'Success';
                    createLog('BatchEtcResponseCheck',batchEtcResponseRequest,JSON.serialize(response),'Failed',batchEtcRespReq.ETCStatusCheck.serialNumber,batchEtcRespReq.ETCStatusCheck.serialNumber,response.message);
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
	
	public static String getStatus(String wrStatus, List<WOD_2__Transaction_Memo_History__c> tmhRecords ){
		String statusDesc;
		
			//String debitStatus='';
			//String creditStatus='';
			String tmhStatus='';
        if(tmhRecords!= null){
			/*for(WOD_2__Transaction_Memo_History__c tmh: tmhRecords){
				if(tmh.WOD_2__Transaction_Type__c=='Debit'){
					debitStatus= tmh.WOD_2__Transaction_Status__c;
				}
				if(tmh.WOD_2__Transaction_Type__c=='credit'){
					creditStatus= tmh.WOD_2__Transaction_Status__c;
				}
			}*/
			tmhStatus= tmhRecords[0].WOD_2__Transaction_Status__c;
        }
		
		if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.draft)){
			statusDesc=ATI_UtilConstants.draft;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.inProgress) || wrStatus.equalsIgnoreCase(ATI_UtilConstants.pendWP)){
			statusDesc=ATI_UtilConstants.pendApp;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.rejected)){
			statusDesc=ATI_UtilConstants.rejected;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.registered) && (tmhStatus.equalsIgnoreCase(ATI_UtilConstants.pending) || tmhStatus.equalsIgnoreCase('Waiting for Payment Confirmation'))){
			statusDesc=ATI_UtilConstants.pendingPayment;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.registered) && (tmhStatus.equalsIgnoreCase(ATI_UtilConstants.draft))){
			statusDesc=ATI_UtilConstants.pendApp;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.registered) && tmhStatus.equalsIgnoreCase(ATI_UtilConstants.paid)){
			statusDesc=ATI_UtilConstants.approved;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.inActive) && tmhStatus.equalsIgnoreCase(ATI_UtilConstants.cancelled)){
			statusDesc=ATI_UtilConstants.cancelled;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.inActive) && tmhStatus.equalsIgnoreCase(ATI_UtilConstants.tliStatus)){
			statusDesc=ATI_UtilConstants.pendingPayment;
		}else if(wrStatus.equalsIgnoreCase(ATI_UtilConstants.inActive) && tmhStatus.equalsIgnoreCase(ATI_UtilConstants.paid)){
			statusDesc=ATI_UtilConstants.cancelApproved;
		}
		return statusDesc;
	}
	
	
    /* Name: runBURules
	Description : This method is used to run business rules for Warranty Registrations
	*/
	public static Map<Id,List<WOD_2__Business_Category_Configuration_Setting__c>> runBURules(Id buId,String ruleObjectAPIName,List<Id> ruleObjectIdList,String moduleName,String subModuleName){
        WOD_2.BR_BusinessRuleEngineWrapper wrapper = new WOD_2.BR_BusinessRuleEngineWrapper();
        wrapper.buId = buId;
        wrapper.configType = 'Rule';
        wrapper.configNameList = NULL;
        wrapper.flowName = '';
        wrapper.ruleObjectAPIName = ruleObjectAPIName; 
        wrapper.ruleObjectIdList = ruleObjectIdList;
        wrapper.moduleName = moduleName; 
        wrapper.subModuleName = subModuleName; 
        
        WOD_2.BR_BusinessRuleEngineOutputWrapper response = WOD_2.BR_BusinessRuleEngineUtility.runBusinessRuleEngine(wrapper);
        System.debug('------'+response);
        if(!response.ruleObjectIdToMapOfBccsObjectList.isEmpty()){
            return response.ruleObjectIdToMapOfBccsObjectList;
        }else{
			return null;
		}
    }
	
    /* Name: createResponse
	Description : This is response method to create responses after Integration
	*/
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey,String errorMessage){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_Batch_ETC_Submittal_Response_Check');
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
    
     
	
	/* 
     * 
     * Method Added  
     * 
     * Method has been created to generate Status Code map for Response.
     * 
	*/
	public Static Map<String,String> getTMHStatusCodeMap(){
        Map<String,String> getTMHStatusCodeMap = new Map<String,String>();
        getTMHStatusCodeMap.put(ATI_UtilConstants.draft,'10');
        getTMHStatusCodeMap.put(ATI_UtilConstants.pendApp,'30');
        getTMHStatusCodeMap.put(ATI_UtilConstants.rejected,'50');
        getTMHStatusCodeMap.put(ATI_UtilConstants.pendingPayment,'70');
		getTMHStatusCodeMap.put(ATI_UtilConstants.approved,'40');
		getTMHStatusCodeMap.put(ATI_UtilConstants.cancelled,'60');
		getTMHStatusCodeMap.put(ATI_UtilConstants.cancelApproved,'80');
        return getTMHStatusCodeMap;
    }
    
    /* 
     * 
     * Method Added  
     * 
     * Method has been created to generate ETC process Code for Response.
     * 
	*/
    public Static EtcProcessMsgInformation getEtcProcessCode(String lineNum,String processCode, String descrptn, String message){
        EtcProcessMsgInformation etcProcess = new EtcProcessMsgInformation();
        //etcProcess.lineNumber=lineNum;
        etcProcess.processCode=processCode;
        etcProcess.processCategoryDescription=descrptn;
        etcProcess.processMessage=message;
        return etcProcess;
    }
    
    /************************************************************************
	Description    :   A wrapper class to capture the Batch ETC Response Rest data.
	*************************************************************************/
    global class ATI_Rest_BatchETCSubmitCheckResponse{
        global String status;
        global String interfaceName;
        global ResponseData data;
        global String message;
    }
    
    global class ResponseData{
        //global String identifier='';
        global String businessPartnerCode='';
        global EtcInformation etcInfo=new EtcInformation();
        //global List<EtcProcessMsgInformation> etcProcessMsgInfo;
    }
    
    global class EtcInformation{
        global String etcRegistrationNumber='';
        global String trackingNumber='';
        global String repairingOutlet='';
        global String purchaseOrder='';
        global String serialNumber='';
        global String submittalIndicator='';
        global String dateTimeETCProcessed='';
        global String etcStatusCode='';
        global String etcStatusDescription='';
        global String etcDebitAmount='';
        global String dispositionCode='';
        global String dispositionCodeDescription='';
        global List<EtcProcessMsgInformation> etcProcessMsgInfo = new List<EtcProcessMsgInformation>();
    }
    
    global class EtcProcessMsgInformation{
        //global String lineNumber='';
        global String processCode='';
        global String processCategoryDescription='';
        global String processMessage='';
        
    }
}