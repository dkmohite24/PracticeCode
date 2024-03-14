/* Name: ATI_RESTSerialNumberInfoService
Description : This class provide service for ATI_RESTSerialNumberInfoSync JSON response 
Author : Tavant(MB)
History:
VERSION     AUTHOR              DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(MB)        04/03/2021       INITIAL DEVELOPMENT                              
*/
@RestResource(urlMapping = '/ATI_RESTSerialNumberInfoSync/*')
global with sharing class ATI_RESTSerialNumberInfoSync implements ATI_LoggableInterface{
    public static List<ATI_REST_SerialNumberInfoSyncResponse.DetailInformation> detailsList = new List<ATI_REST_SerialNumberInfoSyncResponse.DetailInformation>();
    public static set<String> srNoErrorSet = new set<String>();  
    @HttpPost
    global static ATI_REST_SerialNumberInfoSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_RESTSerialNumberInfoSync serialNumberInfoSyncObj = new ATI_RESTSerialNumberInfoSync();
        return serialNumberInfoSyncObj.serialNumberInfo(requestBody);
         
    }
    public ATI_REST_SerialNumberInfoSyncResponse serialNumberInfo(String serialNumberInfoRequest){
        ATI_REST_SerialNumberInfoSyncResponse Sresponse = new ATI_REST_SerialNumberInfoSyncResponse();
        WOD_2.ResponseWrapper response = processType(serialNumberInfoRequest);
        return  (ATI_REST_SerialNumberInfoSyncResponse)JSON.deserialize(response.data, ATI_REST_SerialNumberInfoSyncResponse.class);

    }
    private ATI_REST_SerialNumberInfo_Validator serialInfoValidatorObj{get; private set;}
    
    public WOD_2.ResponseWrapper processType(String serialNumberInfoRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_SerialNumberInfoRequest serialNumberInfoReqObj = new ATI_REST_SerialNumberInfoRequest();
        ATI_REST_SerialNumberInfoSyncResponse finalResponse = new ATI_REST_SerialNumberInfoSyncResponse();
        ///Added by Punam
        finalResponse.interfaceName = 'I-255 - Serial Number Info';
        ATI_REST_SerialNumberInfoSyncResponse.SerialNumberResponseInformation srNRinfo = new ATI_REST_SerialNumberInfoSyncResponse.SerialNumberResponseInformation();
        List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation> coverageList = new List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation>();
        //List<ATI_REST_SerialNumberInfoSyncResponse.DetailInformation> detailsList = new List<ATI_REST_SerialNumberInfoSyncResponse.DetailInformation>();
        
        serialInfoValidatorObj = new ATI_REST_SerialNumberInfo_Validator();
        try{
            serialNumberInfoReqObj = ATI_REST_SerialNumberInfoRequest.parse(serialNumberInfoRequest);
            serialInfoValidatorObj.validateReqest(serialNumberInfoReqObj);
            System.debug('>>>>>> Hello detailsList.size()'+detailsList.size());
            /*if(!serialInfoValidatorObj.mapOfFailure.isEmpty() && serialInfoValidatorObj.mapOfFailure.keyset()!= null){
                for(Integer i=1; i<=serialInfoValidatorObj.totalrecords;i++){
                    if(serialInfoValidatorObj.mapOfFailure.containsKey(i)){
                        system.debug('>>>> finalResponse:'+finalResponse.message+i+': '+String.Join(serialInfoValidatorObj.mapOfFailure.get(i),', '));
                        finalResponse.message = finalResponse.message+i+': '+String.Join(serialInfoValidatorObj.mapOfFailure.get(i),', ') ;
                    }
                }
               // List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation> tempCoverageList = new List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation>();
               // ATI_REST_SerialNumberInfoSyncResponse.DetailInformation DetailInformation = new ATI_REST_SerialNumberInfoSyncResponse.DetailInformation();
                
                finalResponse.message= finalResponse.message.removeEnd(',');
                finalResponse.status = 'Success';
                //finalResponse.
                finalResponse.SerialNumberResponseInfo= new ATI_REST_SerialNumberInfoSyncResponse.SerialNumberResponseInformation();
                createLog('SerialInfoLog',serialNumberInfoRequest,JSON.serialize(finalResponse),'Failed',null,null,finalResponse.message); */
            //}else{
            Set<String> serialNumberSet = new Set<String>();
            Set<String> repairOutletSet = new Set<String>();
            Set<String> trackingNumberSet = new Set<String>();
            map<id,ATI_Vehicle_Information__c> invIdToVehicleMap = new map<id,ATI_Vehicle_Information__c>();
            Map<String, String> trackingNumMap = new Map<String, String>();
            Map<String,ATI_REST_SerialNumberInfoRequest.SerialInformation> srNoInfoMap = new Map<String,ATI_REST_SerialNumberInfoRequest.SerialInformation>();
            //map<id,Account> invIdToCustomerMap = new map<id,Account>();
            srNRinfo.BusinessPartnerCode = serialNumberInfoReqObj.SerialNumberInfo.businessPartnerCode;
            for(ATI_REST_SerialNumberInfoRequest.SerialInformation srInfo: serialNumberInfoReqObj.SerialNumberInfo.serialInfo){
                trackingNumberSet.add(srInfo.trackingNumber); // TBD : With Prasad and Noor as optional value
                repairOutletSet.add(srInfo.repairOutlet);
                if(!srNoErrorSet.contains(srInfo.serialNumber)){
                    serialNumberSet.add(srInfo.serialNumber);
                    srNoInfoMap.put(srInfo.serialNumber,srInfo);
                }
                trackingNumMap.put(srInfo.serialNumber,srInfo.trackingNumber);
            }
            Set<String> serialNumberWRSet = new Set<String>();
            Map<String, String> srNoToModelNumberMap = new Map<String, String>();
            for(WOD_2__Inventory__c inv : [SELECT id,WOD_2__Serial_Number__c,WOD_2__Item__r.Extended_Base_Model__c FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN :serialNumberSet]){
                srNoToModelNumberMap.put(inv.WOD_2__Serial_Number__c,inv.WOD_2__Item__r.Extended_Base_Model__c);
            }
            List<WOD_2__Warranty_Registration__c> WRList =[SELECT id, ATI_Tracking_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Install_Date__c,WOD_2__Inventory__c,
                                                           WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Inventory__r.WOD_2__Item__r.Name,WOD_2__Inventory__r.WOD_2__Item__r.Extended_Base_Model__c,
                                                           WOD_2__Inventory__r.ATI_Vocation_Code__r.Name,WOD_2__Inventory__r.WOD_2__Customer__r.Name,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.Email_Address__c,WOD_2__Inventory__r.WOD_2__Customer__r.Phone,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingStreet , WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity ,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingState , WOD_2__Inventory__r.WOD_2__Customer__r.BillingCountry,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode,
                                                           (SELECT id, Name,WOD_2__Policy_Definition__r.WOD_2__Type__c,WOD_2__Policy_Name__c, WOD_2__Policy_Definition__r.WOD_2__Description__c,WOD_2__Warranty_Start_Date__c,WOD_2__Warranty_End_Date__c FROM WOD_2__Warranty_Coverages__r 
                                                            )//WHERE WOD_2__Warranty_End_Date__c >=:system.today()
                                                           FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Status__c ='Registered' 
                                                           AND WOD_2__Inventory__r.WOD_2__Serial_Number__c IN :serialNumberSet
                                                           //AND WOD_2__Warranty_End_Date__c >=:system.today()
                                                           /*AND (WOD_2__Account__r.SAP_ID__c IN : repairOutletSet OR WOD_2__Account__r.SAP_ID__c =: serialNumberInfoReqObj.SerialNumberInfo.businessPartnerCode)*/];
            Map<Id,List<WOD_2__Warranty_Coverages__c>> invToCovergesMap = new Map<Id,List<WOD_2__Warranty_Coverages__c>>();
            for(WOD_2__Warranty_Registration__c wr : WRList){
                serialNumberWRSet.add(wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c);
                if(wr.WOD_2__Inventory__c != null && !invIdToVehicleMap.containsKey(wr.WOD_2__Inventory__c)){
                    invIdToVehicleMap.put(wr.WOD_2__Inventory__c,null);
                }
                if(!wr.WOD_2__Warranty_Coverages__r.isEmpty()){
                    if(invToCovergesMap.containsKey(wr.WOD_2__Inventory__c)){
                        invToCovergesMap.get(wr.WOD_2__Inventory__c).addAll(wr.WOD_2__Warranty_Coverages__r);
                    }else{
                        invToCovergesMap.put(wr.WOD_2__Inventory__c,wr.WOD_2__Warranty_Coverages__r);
                    }
                }
            }
            for(String s:serialNumberSet){
                if(!serialNumberWRSet.contains(s)){
                    ATI_REST_SerialNumberInfoSyncResponse.SerialNumberResponseInformation tempDrNRinfo = new ATI_REST_SerialNumberInfoSyncResponse.SerialNumberResponseInformation();
                    ATI_REST_SerialNumberInfoSyncResponse.DetailInformation tempDetailInformation = new ATI_REST_SerialNumberInfoSyncResponse.DetailInformation();
                    tempDetailInformation.SerialNumber = s;
                    tempDetailInformation.ProcessCode = '107';
                    tempDetailInformation.ProcessMessage = 'Serial Number is valid, but no registration information exists';
                    tempDetailInformation.TrackingNumber =  srNoInfoMap.get(s).trackingNumber;
                    tempDetailInformation.RepairOutlet = srNoInfoMap.get(s).repairOutlet;
                    tempDetailInformation.ModelNumber = srNoToModelNumberMap.get(s);
                    detailsList.add(tempDetailInformation);
                    //tempDrNRinfo.Details = tempDetailInformation;
                }
                
            }
            /*Commented due to VIN Mapper implementation for(WOD_2__Inventory__c inv : [SELECT id, (SELECT id,ATI_Engine_Make__c,ATI_Engine_Year__c,ATI_Engine_Model__c,ATI_Executive_order_Designation__c,
                                                       ATI_Vehicle_Make__c,ATI_Vehicle_Model__c,Name,ATI_Vocation_Code__c
                                                       FROM ATI_Vehicle_Information__r LIMIT 1) FROM WOD_2__Inventory__c WHERE Id IN : invIdToVehicleMap.keySet()]){
                                                           if(!inv.ATI_Vehicle_Information__r.isEmpty()){
                                                               invIdToVehicleMap.put(inv.id, inv.ATI_Vehicle_Information__r);                                         
                                                           }
                                                       }*/
             //Added For VIN mapper Implementation Start   
            for(WOD_2__Inventory__c inv : [SELECT id, (SELECT id,Name,ATI_Vehicle_Information__c,ATI_Vehicle_Information__r.Name, ATI_Vehicle_Information__r.ATI_Engine_Make__c,ATI_Vehicle_Information__r.ATI_Engine_Year__c,
                                                       ATI_Vehicle_Information__r.ATI_Engine_Model__c,ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c,
                                                       ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Vocation_Code__c, ATI_Inventory__c FROM Transmissions__r order by LastModifiedDate desc LIMIT 1) FROM WOD_2__Inventory__c WHERE Id IN : invIdToVehicleMap.keySet()]){
                                                           if(!inv.Transmissions__r.isEmpty()){
                                                               ATI_Vehicle_Information__c vehInfo= new ATI_Vehicle_Information__c(Id=inv.Transmissions__r[0].ATI_Vehicle_Information__c);
                                                               vehInfo.ATI_Engine_Model__c= inv.Transmissions__r[0].ATI_Vehicle_Information__r.ATI_Engine_Model__c;
                                                               vehInfo.ATI_Engine_Year__c= inv.Transmissions__r[0].ATI_Vehicle_Information__r.ATI_Engine_Year__c;
                                                               vehInfo.ATI_Vehicle_Make__c= inv.Transmissions__r[0].ATI_Vehicle_Information__r.ATI_Vehicle_Make__c;
                                                               vehInfo.ATI_Engine_Make__c= inv.Transmissions__r[0].ATI_Vehicle_Information__r.ATI_Engine_Make__c;
                                                               vehInfo.ATI_Vehicle_Model__c= inv.Transmissions__r[0].ATI_Vehicle_Information__r.ATI_Vehicle_Model__c;
                                                               vehInfo.Name= inv.Transmissions__r[0].ATI_Vehicle_Information__r.Name;
                                                               
                                                               invIdToVehicleMap.put(inv.id, vehInfo);                                         
                                                           }
                                                       }    
                //Added For VIN mapper Implementation End  
            //set of inventory ids to skip iteration , we already added all coverages related to the inventory so
            Set<Id> processedInvIdSet = new Set<Id>();
            for(WOD_2__Warranty_Registration__c wr : WRList){
                if(!processedInvIdSet.contains(wr.WOD_2__Inventory__c)){
                    processedInvIdSet.add(wr.WOD_2__Inventory__c);
                    ATI_REST_SerialNumberInfoSyncResponse.OwnerInformation owner = new ATI_REST_SerialNumberInfoSyncResponse.OwnerInformation();
                    List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation> tempCoverageList = new List<ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation>();
                    ATI_REST_SerialNumberInfoSyncResponse.DetailInformation DetailInformation = new ATI_REST_SerialNumberInfoSyncResponse.DetailInformation();
                    
                    owner.OwnerName = wr.WOD_2__Inventory__r.WOD_2__Customer__r.Name;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.Phone!=null )
                        owner.OwnerTelephone = wr.WOD_2__Inventory__r.WOD_2__Customer__r.Phone;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.Email_Address__c!=null)
                        owner.OwnerEmailAddress = wr.WOD_2__Inventory__r.WOD_2__Customer__r.Email_Address__c;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingStreet!=null)
                        owner.OwnerAddress = wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingStreet;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity!=null)
                        owner.OwnerCity = wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingState!=null)
                        owner.OwnerState_Province = wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingState;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingCountry!=null)
                        owner.OwnerCountryCode = wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingCountry;
                    if(wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode!=null)
                        owner.OwnerPostalCode = wr.WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode;
                    
                    //updated : to add extended WR coverages also in same list
                    if(invToCovergesMap.containsKey(wr.WOD_2__Inventory__c) && invToCovergesMap.get(wr.WOD_2__Inventory__c)!= NULL
                       && !invToCovergesMap.get(wr.WOD_2__Inventory__c).isEmpty())
                    {
                        for(WOD_2__Warranty_Coverages__c wc : invToCovergesMap.get(wr.WOD_2__Inventory__c)){
                            ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation wcWr = new ATI_REST_SerialNumberInfoSyncResponse.CoverageInformation();
                            wcWr.CoverageType = wc.WOD_2__Policy_Definition__r.WOD_2__Type__c;
                            wcWr.CoverageCode = wc.WOD_2__Policy_Name__c;
                            if(wc.WOD_2__Policy_Definition__r.WOD_2__Description__c!=null){
                                wcWr.CoverageName = wc.WOD_2__Policy_Definition__r.WOD_2__Description__c;
                            }
                            String sDate = ''+wc.WOD_2__Warranty_Start_Date__c;
                            String edate = ''+wc.WOD_2__Warranty_End_Date__c;
                            wcWr.CoverageStartDate=''+sDate.split(' ')[0];
                            wcWr.CoverageEndDate=''+eDate.split(' ')[0];
                            tempCoverageList.add(wcWr);
                        } 
                    }
                    
                    if(trackingNumMap.containsKey(wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c)){
                        DetailInformation.TrackingNumber = trackingNumMap.get(wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c);
                    }
                    //DetailInformation.TrackingNumber = wr.ATI_Tracking_Number__c;
                    DetailInformation.RepairOutlet = wr.WOD_2__Account__r.SAP_ID__c;
                    DetailInformation.SerialNumber = wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c;
                    DetailInformation.ProcessCode = '000';
                    DetailInformation.ProcessMessage = 'No errors for this Serial Number';
                    DetailInformation.ModelNumber = wr.WOD_2__Inventory__r.WOD_2__Item__r.Extended_Base_Model__c;// Updated by Mukesh 4/22/2021 From Name to Extended_Base_Model__c
                    DetailInformation.VocationCode = wr.WOD_2__Inventory__r.ATI_Vocation_Code__r.Name;
                    
                    if(wr.WOD_2__Install_Date__c!=null){
                        String tDate = ''+wr.WOD_2__Install_Date__c;
                        DetailInformation.InServiceDate = tDate.split(' ')[0]; 
                    }
                    
                    DetailInformation.coverages = tempCoverageList;
                    DetailInformation.ownerInfo = owner;
                    if(invIdToVehicleMap.containsKey(wr.WOD_2__Inventory__c) && null != invIdToVehicleMap.get(wr.WOD_2__Inventory__c)){
                        DetailInformation.VIN = invIdToVehicleMap.get(wr.WOD_2__Inventory__c).Name;
                        if(invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Vehicle_Make__c!=null)
                            DetailInformation.VehicleMake = invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Vehicle_Make__c;
                        if(invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Vehicle_Model__c!=null)
                            DetailInformation.VehicleModel = invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Vehicle_Model__c;
                        if(invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Make__c!=null)
                            DetailInformation.EngineMake = invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Make__c;
                        if(invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Model__c!=null)
                            DetailInformation.EngineModel = invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Model__c;
                        if(invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Year__c!=null)
                            DetailInformation.EngineYear = ''+invIdToVehicleMap.get(wr.WOD_2__Inventory__c).ATI_Engine_Year__c;
                    }
                    detailsList.add(DetailInformation);
                }
            }
            srNRinfo.Details = detailsList;
            finalResponse.SerialNumberResponseInfo = srNRinfo; 
            finalResponse.status = 'Success';
            finalResponse.interfaceName ='I-255 - Serial Number Info';
            //finalResponse.message= 'Record retrieved successfully.';
            createLog('SerialInfoLog',serialNumberInfoRequest,JSON.serialize(finalResponse),'Success',null,JSON.serialize(serialNumberSet),finalResponse.message);
            //}
        }catch(Exception e){
            system.debug('Catch Exception>> '+ e.getMessage()+' : '+e.getLineNumber());
            //finalResponse.status = '';
            finalResponse.interfaceName ='I-255 - Serial Number Info';
            finalResponse.message=e.getMessage()+e.getStackTraceString();
            finalResponse.SerialNumberResponseInfo =null;
            finalResponse.status = 'failed';
            responseWrapper.data = JSON.serialize(finalResponse);
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage()+e.getStackTraceString();
            return responseWrapper;
        }
            
        responseWrapper.data = JSON.serialize(finalResponse);  
        responseWrapper.status = true;
        responseWrapper.errormessage = '';
        
        return responseWrapper;
        
    }
        
    public void createLog(String processName, String request, String response, String status, String identifier, String primaryKey,String errorMessage){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_SerialNumber_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            //if(!serialNumberValidatorObj.mapOfFailure.isEmpty()){
            //    objLogSerWrp.errortext = JSON.serialize(serialNumberValidatorObj.mapOfFailure.values());
            //    objLogSerWrp.successRecordCount = serialNumberValidatorObj.totalRecords-serialNumberValidatorObj.totalFailedRecords;
            //    objLogSerWrp.failureRecordCount = serialNumberValidatorObj.totalFailedRecords;
            //}
            if(identifier == null){
                if(status != 'Success'){
                    //  ATI_REST_SerialNumberSyncResponse responseWrapperObj = (ATI_REST_SerialNumberSyncResponse)System.JSON.deserialize(response,ATI_REST_SerialNumberSyncResponse.class);
                    //  objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    //  objLogSerWrp.failureRecordCount = serialNumberValidatorObj.totalRecords;
                }else{
                    // objLogSerWrp.successRecordCount = serialNumberValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            //objLogSerWrp.totalRecordCount = serialNumberValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    
}