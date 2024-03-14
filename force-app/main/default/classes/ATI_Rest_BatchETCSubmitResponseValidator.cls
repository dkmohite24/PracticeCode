/* Name: ATI_Rest_BatchETCSubmitResponseValidator
Description : This Class is used to validate Batch ETC Submit Response JSON request data
Author : Tavant(Punam)
History:
VERSION     AUTHOR             DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)      15/02/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_Rest_BatchETCSubmitResponseValidator {
	public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public String accountId{get; private set;}
    Set<String> buSet{get; private set;}
    public Map<String,String> buNameIdMap{get; private set;}
    public Map<String,WOD_2__Inventory__c> invMapDetails{get; private set;}
    
    public ATI_Rest_BatchETCSubmitResponseValidator(){
        mapOfFailure = new Map<Integer,List<String>>();
        buSet= new Set<String>();
        buNameIdMap= new Map<String,String>();
        invMapDetails= new Map<String,WOD_2__Inventory__c>();
    }
    
    /* Name: validateReqest
	Description : This method is used to call validate Json request method.
	*/
    public void validateReqest(ATI_Rest_BatchETCSubmitResponseRequest.ETCStatusInformation batchETCResponseRequest){
        verifyBatchETCResponseReq(batchETCResponseRequest);
    }
    
    /* Name: verifyBatchETCResponseReq
	Description : This method is to validate Json request. It will throw error after validation.
	*/
    public void verifyBatchETCResponseReq(ATI_Rest_BatchETCSubmitResponseRequest.ETCStatusInformation batchETCResponseRequest){
        Set<String> serialNumberSet = new Set<String>();
        List<String> fieldsForBusinessUnit = new List<String> {'Name','Id'};
        String sObjName = 'WOD_2__Business_Category_Configuration__c';
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForBusinessUnit);
        if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
        {
            List<WOD_2__Business_Category_Configuration__c> buConfigList =[Select Id,Name From WOD_2__Business_Category_Configuration__c Where Name =: batchETCResponseRequest.businessCategoryConfiguration];
            if(buConfigList!= null && buConfigList.size()>0){
                for(WOD_2__Business_Category_Configuration__c bu: buConfigList){
                    buNameIdMap.put(bu.Name, bu.Id);
                }
            }
        }
        String invObj = 'WOD_2__Inventory__c';
		List<String> invfields = new List<String>{'Name','WOD_2__Serial_Number__c','WOD_2__Type__c','WOD_2__Item__r.WOD_2__Parent_Product__c'};
        ATI_REST_BatchETCSubmittal_Validator validateObj = new ATI_REST_BatchETCSubmittal_Validator();
        serialNumberSet.add(batchETCResponseRequest.serialNumber);
        invMapDetails = validateObj.getInvMap(invObj,invfields,serialNumberSet);
        system.debug('batchETCResponseRequest.businessCategoryConfiguration'+batchETCResponseRequest.businessCategoryConfiguration);
        
        List<String> errorList = new List<String>();
        
        Set<String> identifireLst = new Set<String>();
        /*if(batchETCResponseRequest.identifier.trim()== ''){
            errorList.add('Identifier is mandatory.');
        }else{
            if(identifireLst.contains(batchETCResponseRequest.identifier.trim())){
                errorList.add('Duplicate Identifier :'+batchETCResponseRequest.identifier.trim());
            }else{
                identifireLst.add(batchETCResponseRequest.identifier.trim());
            }
        }*/
        if(batchETCResponseRequest.businessPartnerCode==''){
            errorList.add('Business Partner Code cannot be blank.');
        }else if(batchETCResponseRequest.businessPartnerCode!= ''){
            String accObj = 'Account';
            List<Account> endCustomerList = new List<Account>();
            List<String> accfields = new List<String>{'SAP_ID__c'};
            ATI_Utils.NoAccessObjectFieldWrapper accReadAccessCheck = ATI_Utils.fetchReadAccess(accObj,accfields);
            if(accReadAccessCheck.noAccessObjectList.size() == 0 && accReadAccessCheck.noAccessFieldList.size() == 0){
                endCustomerList= [select Id, Name,SAP_ID__c From Account Where SAP_ID__c =: batchETCResponseRequest.businessPartnerCode.trim() limit 1];
            }else {
                String errortext = 'Insufficient Account Read Access-->> '+JSON.serialize(accReadAccessCheck);
                ATI_LogService.createLogForAccess('BatchEtcSubmittal',errortext);
            }
            system.debug('endCustomerList'+endCustomerList);
            if(endCustomerList.isEmpty() || endCustomerList.size()<=0){
            	errorList.add('Please provide valid Business Partner Code.');
            }else{
                accountId = endCustomerList[0].Id;
            }
						
        }
        
        if(batchETCResponseRequest.businessCategoryConfiguration==''){
            errorList.add('Business Category Configuration cannot be blank.');
        }else if(batchETCResponseRequest.businessCategoryConfiguration!='' && batchETCResponseRequest.businessCategoryConfiguration!=null){
            if(!buNameIdMap.containskey(batchETCResponseRequest.businessCategoryConfiguration) || buNameIdMap.get(batchETCResponseRequest.businessCategoryConfiguration)== null){
                errorList.add(Label.ATI_ValidBuName);
            }
        }
        if(String.isBlank(batchETCResponseRequest.serialNumber)){
            errorList.add('Serial Number cannot be blank.');
        }else if(batchETCResponseRequest.serialNumber!='' && batchETCResponseRequest.serialNumber!= null){
            if(invMapDetails== null || !invMapDetails.containskey(batchETCResponseRequest.serialNumber)){
                errorList.add('Please Enter valid Serial Number.');
            }
        }
        if(errorList.size() > 0){
           mapOfFailure.put(0,errorList);
        }
    }
}