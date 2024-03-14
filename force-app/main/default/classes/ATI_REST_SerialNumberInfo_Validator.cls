/* Name: ATI_REST_SerialNumberInfo_Validator
Description : This Class is used to validate Batch ETC Submittal JSON request data
Author : Tavant(Punam)
History:
VERSION     AUTHOR              DATE               DETAIL                   UserStory/Req#
1.0 -     Tavant(Punam)       03/02/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_SerialNumberInfo_Validator {
    public List<ATI_REST_SerialNumberInfoRequest.SerialInformation> serialInfoReqLst{get; set;}	
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Set<String> serialNumberSet{get; private set;}
    public String accountId{get; private set;}
    Set<String> buSet{get; private set;}
    public Map<String,String> buNameIdMap{get; private set;}
    public Map<String,WOD_2__Inventory__c> invMapDetails{get; private set;}
    public Integer totalrecords{get; set;}
    public Integer totalFailedRecords{get; set;}
    public Set<String> setOfFailedProducts{get; private set;}
    public Set<String> repairOutletSet{get; private set;}// Added by Mukesh
    public Map<String,String> srNo_AccSapIdToErrorMap{get; private set;}// Added by Mukesh
    
    //public ATI_REST_SerialNumberInfoSyncResponse.DetailInformation detail{get; private set;}
    
    
    public ATI_REST_SerialNumberInfo_Validator(){
        serialInfoReqLst= new List<ATI_REST_SerialNumberInfoRequest.SerialInformation>();
        mapOfFailure = new Map<Integer,List<String>>();
        buSet= new Set<String>();
        buNameIdMap= new Map<String,String>();
        invMapDetails= new Map<String,WOD_2__Inventory__c>();
        serialNumberSet = new Set<String>();
        repairOutletSet = new Set<String>();
        srNo_AccSapIdToErrorMap =new Map<String,String>();
        invMapDetails= new Map<String,WOD_2__Inventory__c>();
        setOfFailedProducts = new Set<String>();
        //detail = new ATI_REST_SerialNumberInfoSyncResponse.DetailInformation();
        totalrecords= 0;
        totalFailedRecords=0;
       
        //ATI_RESTSerialNumberInfoSync.detailsList.add(detail);
    }
    
    public void validateReqest(ATI_REST_SerialNumberInfoRequest serialInfoReq){
        verifySerialInfoReq(serialInfoReq);
    }
    
     /* Name: verifySerialInfoReq
	Description : This method is to validate Json request. It will throw error after validation.
	*/
    Map<integer, ATI_REST_SerialNumberInfoRequest.SerialInformation> intToreqMap = new Map<integer, ATI_REST_SerialNumberInfoRequest.SerialInformation>();
    public void verifySerialInfoReq(ATI_REST_SerialNumberInfoRequest serialInfoReq){
        Integer counter = 1;
        for(ATI_REST_SerialNumberInfoRequest.SerialInformation serial: serialInfoReq.SerialNumberInfo.serialInfo){
            if(serial.serialNumber!= null && serial.serialNumber!=''){
                serialNumberSet.add(serial.serialNumber.trim());
            }
            if(serial.repairOutlet!=null && serial.repairOutlet!=''){
                repairOutletSet.add(serial.repairOutlet.trim());
            }
            if(serial.repairOutlet!=null && serial.repairOutlet!='' && serial.serialNumber!= null && serial.serialNumber!='')
            srNo_AccSapIdToErrorMap.put(serial.serialNumber+'_'+serial.repairOutlet, '');
            
            intToreqMap.put(counter,serial);
            counter++;
        }
        
        
        String invObj = 'WOD_2__Inventory__c';
		List<String> invfields = new List<String>{'Name','WOD_2__Serial_Number__c','WOD_2__Type__c','WOD_2__Account__c','WOD_2__Item__r.WOD_2__Parent_Product__c','WOD_2__Item__r.WOD_2__Parent_Product__r.Name'};
        ATI_REST_BatchETCSubmittal_Validator etcValidator = new ATI_REST_BatchETCSubmittal_Validator();
        invMapDetails= etcValidator.getInvMap(invObj,invfields,serialNumberSet); 
        List<String> errorList = new List<String>();
        if(serialInfoReq.SerialNumberInfo.businessPartnerCode== null || String.isBlank(serialInfoReq.SerialNumberInfo.businessPartnerCode)){
			errorList.add('103-Business Partner Code is missing or not valid');            
        }else if(serialInfoReq.SerialNumberInfo.businessPartnerCode!= ''){
        	List<Account> endCustomerList = getAccountList(serialInfoReq.SerialNumberInfo.businessPartnerCode.trim());
            if(endCustomerList.isEmpty() || endCustomerList.size()<=0){
                errorList.add('103-Business Partner Code is missing or not valid');
            }else{
                accountId = endCustomerList[0].Id;
            }
						
        }
        Integer  i = 1;
        for(ATI_REST_SerialNumberInfoRequest.SerialInformation serial: serialInfoReq.SerialNumberInfo.serialInfo){
            System.debug('>>>>> serial : '+serial);
            if(serial.repairOutlet== null || String.isBlank(serial.repairOutlet)){
				errorList.add('1031-Repairing Business Partner Code is missing or not valid');            
            }else if(serial.repairOutlet!= ''){
                List<Account> accList = getAccountList(serial.repairOutlet.trim());
                if(accList.isEmpty() || accList.size()<=0){
                    errorList.add('1031-Repairing Business Partner Code is missing or not valid');
                }
                
            }
            if(serial.serialNumber== null || String.isBlank(serial.serialNumber)){
				errorList.add('001-Serial Number not found');            
            }else if(serial.serialNumber!= null && serial.serialNumber!=''){
                if(invMapDetails== null || !invMapDetails.containskey(serial.serialNumber)){
                        errorList.add('001-Serial Number not found');
                }
                /*else if(invMapDetails.containskey(serial.serialNumber) && invMapDetails.get(serial.serialNumber).WOD_2__Account__c!=
                        getAccountList(serialInfoReq.SerialNumberInfo.businessPartnerCode.trim())[0].Id){
                            errorList.add('Please provide Business Partner code associated with Serial Number.');
                    
                }*/
            }
            
            totalrecords= totalrecords+1;
            if(errorList.size() == 0){
                serialInfoReqLst.add(serial);
            }
            else{
                setOfFailedProducts.add(serial.serialNumber);
                totalFailedRecords++;
                mapOfFailure.put(i,errorList);
                system.debug('mapOfFailure***'+mapOfFailure);
                integer temp = 0;
                for(Integer count : intToreqMap.keySet() ){
                    if(intToreqMap.containsKey(i) && temp==0){
                        temp++;
                        String pCode = '';
                        String pMessage = '';
                        for(String s : errorList){
                            system.debug('>>> S:'+s);
                            //system.debug('>>> s.split('-')[0]:'+s.split('-')[0]);
                            //system.debug('>>> s.split('-')[1]:'+s.split('-')[1]);
                            pCode = pCode+' '+s.split('-')[0];
                            pMessage = pMessage+' '+s.split('-')[1];
                            system.debug('>>> pCode:'+pCode);
                            system.debug('>>> pMessage:'+pMessage);
                        }
                        ATI_REST_SerialNumberInfoSyncResponse.DetailInformation detail = new ATI_REST_SerialNumberInfoSyncResponse.DetailInformation(); 
                        detail.ProcessCode = pCode;
                        detail.ProcessMessage = pMessage;
                        detail.TrackingNumber = intToreqMap.get(i).trackingNumber;
                        detail.RepairOutlet = intToreqMap.get(i).repairOutlet;
                        detail.SerialNumber = intToreqMap.get(i).serialNumber;
                        System.debug('>>> detail'+detail);
                        ATI_RESTSerialNumberInfoSync.srNoErrorSet.add(intToreqMap.get(i).serialNumber);
                        ATI_RESTSerialNumberInfoSync.detailsList.add(detail);
                       /* for(Integer i=1; i<=serialInfoValidatorObj.totalrecords;i++){
                    if(serialInfoValidatorObj.mapOfFailure.containsKey(i)){
                        system.debug('>>>> finalResponse:'+finalResponse.message+i+': '+String.Join(serialInfoValidatorObj.mapOfFailure.get(i),', '));
                        finalResponse.message = finalResponse.message+i+': '+String.Join(serialInfoValidatorObj.mapOfFailure.get(i),', ') ;
                    }
                } */
                       
                    }
                }
                
            }
            system.debug('errorList***'+errorList);
            errorList = new List<String>();
            i++;
        }
        
    
    }
    // Added by Mukesh
    /*
    public static void fatchWRDetails(Set<String> serialNumberSet,Set<String> repairOutletSet, String  businessPartnerCode){
        Set<String> serialNumberWRSet = new Set<String>();
        List<WOD_2__Warranty_Registration__c> WRList =[SELECT id, ATI_Tracking_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Install_Date__c,WOD_2__Inventory__c,
                                                           WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Inventory__r.WOD_2__Item__r.Name,
                                                           WOD_2__Inventory__r.ATI_Vocation_Code__r.Name,WOD_2__Inventory__r.WOD_2__Customer__r.Name,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.Email_Address__c,WOD_2__Inventory__r.WOD_2__Customer__r.Phone,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingStreet , WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity ,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingState , WOD_2__Inventory__r.WOD_2__Customer__r.BillingCountry,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode,
                                                           (SELECT id, Name,WOD_2__Policy_Definition__r.WOD_2__Type__c,WOD_2__Policy_Name__c, WOD_2__Policy_Definition__r.WOD_2__Description__c FROM WOD_2__Warranty_Coverages__r)
                                                           FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Status__c ='Registered' 
                                                           AND WOD_2__Inventory__r.WOD_2__Serial_Number__c IN :serialNumberSet
                                                           AND (WOD_2__Account__r.SAP_ID__c IN : repairOutletSet OR WOD_2__Account__r.SAP_ID__c =:businessPartnerCode )];//serialNumberInfoReqObj.SerialNumberInfo.businessPartnerCode
        for(WOD_2__Warranty_Registration__c wr:WRList){
            serialNumberWRSet.add(wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c);   
        }
        for(String s:serialNumberSet){
            if(!serialNumberWRSet.contains(s)){
                
            }
        }
    
    } */
    
    public static List<Account> getAccountList(String code){
        String accObj = 'Account';
        List<Account> endCustomerList = new List<Account>();
        List<String> accfields = new List<String>{'SAP_ID__c'};
        ATI_Utils.NoAccessObjectFieldWrapper accReadAccessCheck = ATI_Utils.fetchReadAccess(accObj,accfields);
        if(accReadAccessCheck.noAccessObjectList.size() == 0 && accReadAccessCheck.noAccessFieldList.size() == 0){
            endCustomerList= [select Id, Name,SAP_ID__c From Account Where SAP_ID__c =: code limit 1];
            return endCustomerList;
        }else {
            String errortext = 'Insufficient Account Read Access-->> '+JSON.serialize(accReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
            return null;
        }
    } 
    
   /* public static void checkAccessMethod(){
        String wRegObj = 'WOD_2__Warranty_Registration__c';
        String invObj = 'WOD_2__Inventory__c';
        String wCovObj = 'WOD_2__Warranty_Coverages__c';
        String polObj = 'WOD_2__Policy_Definition__c';
        String vehObj = 'ATI_Vehicle_Information__c';
        
        List<String> wRegfields = new List<String>{'ATI_Tracking_Number__c','id','WOD_2__Account__c','WOD_2__Install_Date__c','WOD_2__Inventory__c','WOD_2__Status__c'};
		List<String> wCovfields = new List<String>{'Name','id','WOD_2__Policy_Name__c'};
        List<String> invFields = new List<String>{'WOD_2__Serial_Number__c','WOD_2__Item__c','ATI_Vocation_Code__c','Id'};
        List<String> polFields = new List<String>{'WOD_2__Type__c'};
        List<String> vehFields = new List<String>{'ATI_Engine_Make__c','ATI_Engine_Model__c','ATI_Engine_Year__c','ATI_Executive_order_Designation__c','ATI_Vehicle_Make__c','ATI_Vehicle_Mileage_Usage__c','ATI_Vocation_Code__c','ATI_Vehicle_Model__c','Name','Id'};  
            
            
            
        ATI_Utils.NoAccessObjectFieldWrapper wRegReadAccessCheck = ATI_Utils.fetchReadAccess(wRegObj,wRegfields);
        ATI_Utils.NoAccessObjectFieldWrapper wCovReadAccessCheck = ATI_Utils.fetchReadAccess(wCovObj,wCovfields);
        ATI_Utils.NoAccessObjectFieldWrapper invReadAccessCheck = ATI_Utils.fetchReadAccess(invObj,invFields);
        ATI_Utils.NoAccessObjectFieldWrapper polReadAccessCheck = ATI_Utils.fetchReadAccess(polObj,polFields);
        ATI_Utils.NoAccessObjectFieldWrapper vehReadAccessCheck = ATI_Utils.fetchReadAccess(vehObj,vehFields);
        
        if(wRegReadAccessCheck.noAccessObjectList.size() != 0 || wRegReadAccessCheck.noAccessFieldList.size() != 0){
            String errortext = 'Insufficient Warranty Registration Read Access-->> '+JSON.serialize(wRegReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
        }
        
        if(wCovReadAccessCheck.noAccessObjectList.size() != 0 || wCovReadAccessCheck.noAccessFieldList.size() != 0){
            String errortext = 'Insufficient Warranty Coverage Read Access-->> '+JSON.serialize(wCovReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
        }
        
        if(invReadAccessCheck.noAccessObjectList.size() != 0 || invReadAccessCheck.noAccessFieldList.size() != 0){
            String errortext = 'Insufficient Inventory Read Access-->> '+JSON.serialize(invReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
        }
        
        if(polReadAccessCheck.noAccessObjectList.size() != 0 || polReadAccessCheck.noAccessFieldList.size() != 0){
            String errortext = 'Insufficient Policy Definition Read Access-->> '+JSON.serialize(polReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
        }
        
        if(vehReadAccessCheck.noAccessObjectList.size() != 0 || vehReadAccessCheck.noAccessFieldList.size() != 0){
            String errortext = 'Insufficient Vehicle Information Read Access-->> '+JSON.serialize(vehReadAccessCheck);
            ATI_LogService.createLogForAccess('SerialNumberInfo',errortext);
        }
            
    }*/

}