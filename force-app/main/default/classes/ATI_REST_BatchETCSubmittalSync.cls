/* Name: ATI_REST_BatchETCSubmittalSync
Description : Endpoint which sync Extended Warranty Registrations .
Author : Tavant(Punam)
History:
VERSION     AUTHOR                DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         04/02/2021          INITIAL DEVELOPMENT                            
*/
@RestResource(urlMapping = '/ATIRestBatchETCSubmittalSync/*')
global with sharing class ATI_REST_BatchETCSubmittalSync implements ATI_LoggableInterface{
    
    private ATI_REST_BatchETCSubmittal_Validator batchETCValidatorObj;
    private Map<String,WOD_2__Warranty_Registration__c> extWarrantyRegMap = new Map<String,WOD_2__Warranty_Registration__c>();
    // All dependent objects map w.r.t serial numbers so that it can be associated later and updated.
    Map<String, Account> endCustomerMap = new Map<String, Account>();
    Map<String, ATI_Vehicle_Information__c> vehicleInfoMap = new Map<String, ATI_Vehicle_Information__c>(); 
    Map<String, String> serialNumberPolicyNameMap = new Map<String, String>();
    Map<String, Integer> serialNumberIdentifierMap = new Map<String, Integer>();
    
    /* 
     * 
     * Method Added   
     * 
     * Http Post Integration method
     * 
    */
     @HttpPost
    global Static ATI_REST_BatchETCSubmittalResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_BatchETCSubmittalSync batchETCSyncObj = new ATI_REST_BatchETCSubmittalSync();
        ATI_REST_BatchETCSubmittalResponse batchETCResponse = batchETCSyncObj.processExtendedWntyCoverages(requestBody);
        return batchETCResponse;
    }
    
    /* 
     * 
     * Method Added  
     * 
     * Method has been created to do all operations after api hit.
     * 
    */
    public WOD_2.ResponseWrapper processType(String batchEtcRequest){
    	WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        try{
            ATI_REST_BatchETCSubmittalRequest batchETCReqObj = (ATI_REST_BatchETCSubmittalRequest)System.JSON.deserialize(batchEtcRequest,ATI_REST_BatchETCSubmittalRequest.class);
            batchETCValidatorObj = new ATI_REST_BatchETCSubmittal_Validator();
            batchETCValidatorObj.validateReqest(batchETCReqObj);

            // now we will iterate over only valid requests to create/update end customers and vehicle info
            Integer i = 1;
            Map<String,String> submittalIndcMap = new Map<String,String>();
            for(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation etcReq : batchETCValidatorObj.batchETCReqLst){
                String serialNumber = etcReq.vehicleInfo.serialNumber.trim();
                Account endCustomer = createOrUpdateEndCustomer(etcReq, batchETCValidatorObj);
                ATI_Vehicle_Information__c vehicleInfo = createOrUpdateVehicleInfo(etcReq, batchETCValidatorObj);
                endCustomerMap.put(serialNumber, endCustomer);
                vehicleInfoMap.put(serialNumber, vehicleInfo);
                serialNumberPolicyNameMap.put(serialNumber, etcReq.etcCoverageCode);
                submittalIndcMap.put(serialNumber, etcReq.submittalIndicator);
                serialNumberIdentifierMap.put(serialNumber, i);
                i++;
            }
            // upsert all end customers and vehicle information
            if(!endCustomerMap.isEmpty()){
            	upsert endCustomerMap.values();    
            }
            if(!vehicleInfoMap.isEmpty()){
            	upsert vehicleInfoMap.values();
                
                // Added Punam 26th April --Veh Transmission Mapper implementation start
                Map<Id,ATI_Vehicle_Information__c> mapOfInvVehInfoMap = new Map<Id,ATI_Vehicle_Information__c>();
                for(String serial: vehicleInfoMap.keyset()){
                    if(submittalIndcMap.get(serial)=='I'){
                    	mapOfInvVehInfoMap.put(batchETCValidatorObj.invMapDetails.get(serial).Id, vehicleInfoMap.get(serial));
                    }
                }
                ATI_VehicleInformationController.createVehicleInfoMapper(mapOfInvVehInfoMap);
                //Added Punam 26th April --Veh Transmission Mapper implementation End
            }
            for(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation etcReq : batchETCValidatorObj.batchETCReqLst){
                String serialNumber = etcReq.vehicleInfo.serialNumber.trim();
                WOD_2__Inventory__c inv = batchETCValidatorObj.invMapDetails.get(serialNumber);
                inv.WOD_2__Install_Date__c = ATI_Utils.parseDate(etcReq.vehicleInfo.inServiceDate);
                inv.ATI_Vocation_Code__c = batchETCValidatorObj.vocCodeMap.get(etcReq.vehicleInfo.vocationCode.trim()).Id;
                extWarrantyRegMap.put(serialNumber, createOrUpdateWR(etcReq, batchETCValidatorObj));
            }
			system.debug('extWarrantyRegMap***'+extWarrantyRegMap);
            if(!extWarrantyRegMap.isEmpty()){
            	update batchETCValidatorObj.invMapDetails.values();
                upsert extWarrantyRegMap.values();
                System.debug('extWarrantyRegMap.values -> ' + extWarrantyRegMap.values());
                Map<Id, WOD_2__Warranty_Registration__c> wrIdMap = new Map<Id, WOD_2__Warranty_Registration__c>(extWarrantyRegMap.values());
                Map<Id, WOD_2__Warranty_Registration__c> wrIdMapForReg = getWRMap(wrIdMap.keySet());
                Map<Id,WOD_2.WR_RegistrationResponse> coverageResponse = ATI_WarrantyService.runApplicablityEngine(wrIdMapForReg,'ATI_PolicyFetchOverrideForWR');
                System.debug('>>> responseWrapper :'+coverageResponse); //status
                Map<Id, Map<Id, WOD_2__Warranty_Coverages__c>> wrIdWntyCoveragesMap = new Map<Id, Map<Id, WOD_2__Warranty_Coverages__c>>();
                List<Id> policyIdList = new List<Id>();
                for(WOD_2.WR_RegistrationResponse wr : coverageResponse.values()) {
                    if(!wr.status){
                        Integer identifier = serialNumberIdentifierMap.get(wrIdMapForReg.get(wr.warrantyId).WOD_2__Inventory__r.WOD_2__Serial_Number__c);
                        batchETCValidatorObj.mapOfFailure.put(identifier,new List<String>{wr.message});
                    }
                    if(wr.warrantyCoverages.size() > 0 ){
                        for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                            System.debug('>>> coverage :'+ coverage);
                            if(coverage.WOD_2__Policy_Definition__c != null){
                                if(!wrIdWntyCoveragesMap.containsKey(coverage.WOD_2__Warranty_Registration__c)){
                                    wrIdWntyCoveragesMap.put(coverage.WOD_2__Warranty_Registration__c, new Map<Id, WOD_2__Warranty_Coverages__c>());
                                }
                                policyIdList.add(coverage.WOD_2__Policy_definition__c);
                                wrIdWntyCoveragesMap.get(coverage.WOD_2__Warranty_Registration__c).put(coverage.WOD_2__Policy_definition__c, coverage);
                            } 
                        }
						system.debug('wrIdWntyCoveragesMap**'+wrIdWntyCoveragesMap);
                    }
                }
                List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
                List<WOD_2__Warranty_Registration__c> wrListToUpdate = new List<WOD_2__Warranty_Registration__c>();
                Map<Id, WOD_2__Policy_Definition__c> policyDefMap = getPolicyDefsMap(policyIdList);
                for(Id wrId : wrIdWntyCoveragesMap.keySet()){
                    WOD_2__Warranty_Registration__c wntyReg = wrIdMapForReg.get(wrId);
                    Map<Id, WOD_2__Warranty_Coverages__c> policyIdCoveragesMap = wrIdWntyCoveragesMap.get(wrId);
                    String sNo = wntyReg.WOD_2__Inventory__r.WOD_2__Serial_Number__c;
                    System.debug('sNo -> ' + sNo);
                    String policyName = serialNumberPolicyNameMap.get(sNo);
                    System.debug('Policy Name -> ' + policyName);
                    WOD_2__Policy_Definition__c extPolicyDef = batchETCValidatorObj.etcPolicyMap.get(policyName);
                    System.debug('extPolicyDef -> ' + extPolicyDef);
                    if(policyIdCoveragesMap.containsKey(extPolicyDef.Id)){ // Coverage name sent is valid
                        WOD_2__Warranty_Registration__c wrWithCoverage = new WOD_2__Warranty_Registration__c(Id=wrId,ATI_isExtended__c=true);
                        wrListToUpdate.add(wrWithCoverage);
                        // this is the case when Std. Registration is being done with Extended policy.
                        // We need to add all Std. and only this Extended Coverage
                        if(batchETCValidatorObj.existingWarrantyRegMap.get(sNo) == null || batchETCValidatorObj.existingWarrantyRegMap.get(sNo).WOD_2__Status__c.equalsIgnoreCase('Draft')){ //Added 3rd June
                            for(Id policyId : policyIdCoveragesMap.keySet()){
                                if(policyDefMap.get(policyId).WOD_2__Type__c == 'Standard' || policyDefMap.get(policyId).WOD_2__Type__c == 'Supplemental Coverage'){
                                    warrantyCoveragesList.add(policyIdCoveragesMap.get(policyId));
                                }
                            }
                        }
                        WOD_2__Warranty_Coverages__c extCoverage = policyIdCoveragesMap.get(extPolicyDef.Id);
                        extCoverage.ATI_isExtended__c = true;
                        warrantyCoveragesList.add(extCoverage);
                    } else { // coverage name sent does not belong to the coverages list, add to errorlist
                        System.debug('Policy Not Found');
                        Integer identifier = serialNumberIdentifierMap.get(sNo);
                        List<String> errorList = new List<String>();
                        errorList.add('Invalid Etc Coverage Code for the Serial Number');
                        batchETCValidatorObj.mapOfFailure.put(identifier,errorList);
                    }
                }
				system.debug('wrListToUpdate**'+wrListToUpdate);
                if(!wrListToUpdate.isEmpty()){
                    WOD_2.WR_CoverageInputWrapper covrageWrapper = new WOD_2.WR_CoverageInputWrapper();
                    covrageWrapper.coverages = warrantyCoveragesList;
                    covrageWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
                    covrageWrapper.wrRecordIds = new List<Id>(new Map<Id, WOD_2__Warranty_Registration__c>(wrListToUpdate).keyset());
					WOD_2.ResponseWrapper coverageWrapperObj = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);                    
                    System.debug('coverageWrapperObj -> ' + coverageWrapperObj);
                    System.debug('wrIdMapForReg -> ' + wrIdMapForReg);
                    // refetch the warranty registrations, to check if the WR is sent to approval or registered
                    Map<Id, WOD_2__Warranty_Registration__c> regWRIdMap = getWRMap(wrIdMap.keySet());
                    extWarrantyRegMap.clear();
                    for(String wrId : regWRIdMap.keySet()){
                        extWarrantyRegMap.put(regWRIdMap.get(wrId).WOD_2__Inventory__r.WOD_2__Serial_Number__c, regWRIdMap.get(wrId));
                    }
                    if(coverageWrapperObj.status){
                        Map<Id, WOD_2__Warranty_Coverages__c> wcMap = new Map<Id, WOD_2__Warranty_Coverages__c>(warrantyCoveragesList);
                        createETCTransactions(wcMap.keySet(), regWRIdMap);
                        // calling accruals again here as WR is already updated to registered before the ETC transactions are created are created
                        Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                            select id from WOD_2__Warranty_Coverages__c where Id IN:wcMap.keySet()
                            and WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended'
                        ]);
                        System.enqueueJob(new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet())));
                    }
                }
            }
            responseWrapper.data = JSON.serialize(createResponse(batchETCReqObj.etcPurchase));
            System.debug('Response Data -> ' + responseWrapper.data);
            responseWrapper.status = true;
        }catch(Exception e){
            responseWrapper.data = '';
            responseWrapper.status = false;
            System.debug('StackTraceString -> ' + e.getStackTraceString());
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
            System.debug('errormessage -> ' + responseWrapper.errormessage);
        }
		return responseWrapper;
    }    

    private void createETCTransactions(Set<Id> warrantyCoveragesIdList, Map<Id, WOD_2__Warranty_Registration__c> regWRIdMap){
        Map<Id, WOD_2__Transaction_Memo_History__c> wrIdTMHMap = new Map<Id, WOD_2__Transaction_Memo_History__c>();
        Map<Id, WOD_2__Transaction_Memo_History_Line_Item__c> wrIdTMHLIList = new Map<Id, WOD_2__Transaction_Memo_History_Line_Item__c>();
        Map<String,Decimal> bccRecordMap = getBCCSConfigForLateFee();
        List<String> wcFields = new List<String>{'WOD_2__Warranty_Registration__c','WOD_2__Policy_Definition__r.Name',
            'WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c','WOD_2__Warranty_Registration__r.ATI_Extended_Warranty_Purchase_Date__c'};
		ATI_Utils.checkForAccess('WOD_2__Warranty_Coverages__c', 'READ', wcFields);                
        List<WOD_2__Warranty_Coverages__c> coverages = 
            [select Id, WOD_2__Warranty_Registration__c, WOD_2__Policy_Definition__r.Name,
             WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c,
             WOD_2__Warranty_Registration__r.ATI_Extended_Warranty_Purchase_Date__c 
             from WOD_2__Warranty_Coverages__c where id in :warrantyCoveragesIdList and WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended'];
        for(WOD_2__Warranty_Coverages__c wc : coverages){
            Decimal lateFee = 0, finalPrice = 0;
            String sNo = wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c;
            Date purchaseDate = wc.WOD_2__Warranty_Registration__r.ATI_Extended_Warranty_Purchase_Date__c;
            String policyName = wc.WOD_2__Policy_Definition__r.Name;
            Id wrId = wc.WOD_2__Warranty_Registration__c;
            ATI_Extended_Warranty_Pricing__c extndPrice = batchETCValidatorObj.invExtPriceMap.get(sNo);
            Integer monthsBetween = purchaseDate.monthsBetween(System.today());
            if(monthsBetween >= 12 && monthsBetween < 24){
                lateFee = extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanOneYear'))/100;
            } else if(monthsBetween >= 24 && monthsBetween < 36){
                lateFee= extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanTwoYears'))/100;
            } else if(monthsBetween >= 36 && monthsBetween < 48){
                lateFee= extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanThreeYears'))/100;
            } else if(monthsBetween >= 48){
                lateFee= extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanFourYears'))/100;
            }
            finalPrice = (extndPrice.ATI_Base_Price__c + lateFee) - extndPrice.ATI_Handling_Fee__c;
            String transactionStatus = (regWRIdMap.containsKey(wrId) && regWRIdMap.get(wrId).WOD_2__Status__c == 'Registered') ?
                'Pending' : 'Draft';
            WOD_2__Transaction_Memo_History__c transctnHistory = 
                new WOD_2__Transaction_Memo_History__c(ATI_Type__c='EWP', Name= sNo,
                                                       WOD_2__Amount__c = finalPrice, WOD_2__Transaction_Type__c ='Debit', 
                                                       WOD_2__Transaction_Status__c = transactionStatus, WOD_2__Settlement_Category__c ='EWP',
                                                       ATI_Warranty_Registration__c = wrId);
            wrIdTMHMap.put(wrId, transctnHistory);
            WOD_2__Transaction_Memo_History_Line_Item__c transactionLineItem = 
                new WOD_2__Transaction_Memo_History_Line_Item__c(Name= policyName, WOD_2__Total_Amount__c= finalPrice, WOD_2__Unit_Amount__c= extndPrice.ATI_Base_Price__c,
                                                                 ATI_Handling_Fee__c= extndPrice.ATI_Handling_Fee__c, ATI_Late_Fee__c= lateFee,WOD_2__Transaction_Type__c= 'Debit',
                                                                 WOD_2__Quantity__c=1);
            wrIdTMHLIList.put(wrId, transactionLineItem);
        }        
        insert wrIdTMHMap.values();
        for(Id wrId : wrIdTMHMap.keySet()){
            wrIdTMHLIList.get(wrId).WOD_2__Transaction_Memo_History__c = wrIdTMHMap.get(wrId).Id;
        }
        insert wrIdTMHLIList.values();
    }
    
    private Map<String,Decimal> getBCCSConfigForLateFee(){
        Map<String,Decimal> bccRecordMap = new Map<String,Decimal>();
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsRecords= 
            [SELECT Id,Name,RecordTypeId,WOD_2__Business_Category_Configuration__c,WOD_2__Module__c,WOD_2__Value__c FROM 
             WOD_2__Business_Category_Configuration_Setting__c WHERE
             (Name = 'ATI_EWPLateFeeForGreaterThanThreeYears' OR Name = 'ATI_EWPLateFeeForGreaterThanOneYear' OR 
              Name = 'ATI_EWPLateFeeForGreaterThanTwoYears' OR Name = 'ATI_EWPLateFeeForGreaterThanFourYears') 
             AND WOD_2__Business_Category_Configuration__c in :batchETCValidatorObj.buNameIdMap.values()];
        for(WOD_2__Business_Category_Configuration_Setting__c bcc : bccsRecords){
            bccRecordMap.put(bcc.Name,Decimal.valueOf(bcc.WOD_2__Value__c));
        }
        return bccRecordMap;
    }
    
    private WOD_2__Warranty_Registration__c createOrUpdateWR(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation etcReq, ATI_REST_BatchETCSubmittal_Validator batchETCValidatorObj){
        WOD_2__Warranty_Registration__c wr = batchETCValidatorObj.mapOfWarrantyReg.get(etcReq.etcRegistrationNumber);
        System.debug('WR for etcRegistrationNumber -> ' + etcReq.etcRegistrationNumber + ' = ' + wr);
        String serialNumber = etcReq.vehicleInfo.serialNumber.trim();
        if(wr == null){ // lets check if we have any draft WR for this inventory
            wr = batchETCValidatorObj.existingWarrantyRegMap.get(serialNumber);
        }
        if(wr == null || !wr.ATI_isExtended__c){
			String wrType= (wr == null || wr.WOD_2__Status__c=='Draft')?'Standard Registration':'Extended'; //Added 3rd June
			if(wr == null || wr.WOD_2__Status__c!= 'Draft'){ //Added 3rd June
				wr = new  WOD_2__Warranty_Registration__c();
			}
            wr.WOD_2__Registration_Type__c= wrType;
            wr.WOD_2__Install_Date__c= ATI_Utils.parseDate(etcReq.vehicleInfo.inServiceDate);
            //wr.ATI_isExtended__c= true;
            wr.WOD_2__Account__c = batchETCValidatorObj.accSapIdAccountMap.get(etcReq.repairOutlet.trim()).Id;
            wr.WOD_2__Inventory__c = batchETCValidatorObj.invMapDetails.get(serialNumber).Id;
            wr.WOD_2__Status__c = 'Draft';
        }
        wr.WOD_2__Customer__c = endCustomerMap.get(serialNumber).Id;
        wr.ATI_Tracking_Number__c= etcReq.trackingNumber;
        wr.ATI_Extended_Warranty_Purchase_Date__c = ATI_Utils.parseDate(etcReq.agreementDate);
        wr.ATI_Submittal_Indicator__c= etcReq.submittalIndicator;
        wr.ATI_Submitter_Name__c= etcReq.submitterName;
        wr.ATI_Submitter_Phone__c= etcReq.submitterPhone;
        wr.ATI_PO_Number__c = etcReq.purchaseOrderNumber;
        wr.WOD_2__Registration_Date__c =  System.today();
        wr.ATI_CE_Number__c = etcReq.ceNumber;
		wr.ATI_Vocation_Code__c = batchETCValidatorObj.vocCodeMap.get(etcReq.vehicleInfo.vocationCode.trim()).Id;
        wr.WOD_2__Warranty_Product__c=  batchETCValidatorObj.invMapDetails.get(serialNumber).WOD_2__Item__c; //Added by Punam as part of bug fix
        return wr;
    }
    
    private Account createOrUpdateEndCustomer(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation etcReq, ATI_REST_BatchETCSubmittal_Validator batchETCValidatorObj){
        String endCustomerKey = etcReq.customerInfo.customerName + '-'  + etcReq.customerInfo.city + '-'  + etcReq.customerInfo.postalCode;
        Account endCustomer = batchETCValidatorObj.endCustomerAccountMap.get(endCustomerKey);
        if(endCustomer == null){
            endCustomer = new Account();
            endCustomer.Name= etcReq.customerInfo.customerName;
            endCustomer.BillingCity= etcReq.customerInfo.city;
            endCustomer.BillingPostalCode = etcReq.customerInfo.postalCode;
            endCustomer.WOD_2__Warranty_Account_Type__c='Customer';
            endCustomer.Type='End Customer';
            endCustomer.ATI_Customer_Group__c = 'EU99';
        }                                                
        endCustomer.BillingCountry= etcReq.customerInfo.countryCode;
        endCustomer.BillingStreet= etcReq.customerInfo.street;
        endCustomer.BillingState=etcReq.customerInfo.state;
        endCustomer.Email_Address__c= etcReq.customerInfo.email;
        endCustomer.Phone = etcReq.customerInfo.phone;
        return endCustomer;        
    }     
    
    private ATI_Vehicle_Information__c createOrUpdateVehicleInfo(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation etcReq, ATI_REST_BatchETCSubmittal_Validator batchETCValidatorObj){
        ATI_Vehicle_Information__c vehicleInfo = batchETCValidatorObj.vehInfoMapDetails.get(etcReq.vehicleInfo.vehicleIdentificationNumber.trim()); 
        if(vehicleInfo == null){
            vehicleInfo = new ATI_Vehicle_Information__c();
        	vehicleInfo.Name=  etcReq.vehicleInfo.vehicleIdentificationNumber.trim();    
        }
        vehicleInfo.ATI_Customer_asset_number__c=  etcReq.vehicleInfo.customerAssetNumber;
        vehicleInfo.ATI_Vehicle_usage_mi_km_hr__c = etcReq.vehicleInfo.usageUnit; // Added after Anjali's change
      	vehicleInfo.ATI_Vehicle_Usage__c =  Decimal.valueOf(etcReq.vehicleInfo.vehicleMileage); //Changed from ATI_Vehicle_Mileage_Usage__c to ATI_Vehicle_Usage__c after Anjali's change
        vehicleInfo.ATI_Vehicle_Make__c=  etcReq.vehicleInfo.vehicleMake;
        vehicleInfo.ATI_Vehicle_Model__c=  etcReq.vehicleInfo.vehicleModel;
        vehicleInfo.ATI_Engine_Make__c=  etcReq.vehicleInfo.engineMake;
        vehicleInfo.ATI_Engine_Model__c=  etcReq.vehicleInfo.engineModel;
        vehicleInfo.ATI_Engine_Year__c=  etcReq.vehicleInfo.engineYear;
        vehicleInfo.ATI_Executive_order_Designation__c=  etcReq.vehicleInfo.executiveOrderDesignation;
        //Removed vehicleInfo.ATI_Inventory__c as part of Veh Transmission mapper object implementation
        //vehicleInfo.ATI_Inventory__c =  batchETCValidatorObj.invMapDetails.get(etcReq.vehicleInfo.serialNumber.trim()).Id;
        vehicleInfo.ATI_Vocation_Code__c = batchETCValidatorObj.vocCodeMap.get(etcReq.vehicleInfo.vocationCode.trim()).Id;
        return vehicleInfo;
    }

    /* 
     * 
     * Method Added  
     * 
     * Get Response after Batch ETC Submittal Integration
     * 
    */
    public ATI_REST_BatchETCSubmittalResponse processExtendedWntyCoverages(String batchEtcRequest){
        ATI_REST_BatchETCSubmittalResponse batchEtcResponse = new ATI_REST_BatchETCSubmittalResponse();
        WOD_2.ResponseWrapper response = processType(batchEtcRequest);
        if(response != null && response.data != null && response.data != '') {
            batchEtcResponse = (ATI_REST_BatchETCSubmittalResponse)Json.deserialize(response.data,ATI_REST_BatchETCSubmittalResponse.class);
        }else {
            batchEtcResponse.status = 'Fail';
            batchEtcResponse.data = null;
            batchEtcResponse.message = response.errormessage;
            batchEtcResponse.interfaceName=null;
            //createLog('BatchETCSubmittal',batchEtcRequest,JSON.serialize(batchEtcResponse),'Failed',null,null);
        }
        return batchEtcResponse;   
    }
    
    /* Name: createResponse
    Description : This is response method to create responses after Integration
    */
    private ATI_REST_BatchETCSubmittalResponse createResponse(List<ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation> batchETCRequest){
            ATI_REST_BatchETCSubmittalResponse batchETCResponse = new ATI_REST_BatchETCSubmittalResponse();
            List<ResponseData> responseDataLst = new List<ResponseData>();
            Integer i = 1;
            for(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation batchETCReq : batchETCRequest){
                String serialNumber = batchETCReq.vehicleInfo.serialNumber.trim();
                ResponseData data = new ResponseData();
                if(!batchETCValidatorObj.mapOfFailure.isEmpty() && batchETCValidatorObj.mapOfFailure.containsKey(i)){
                    data.message = String.Join(batchETCValidatorObj.mapOfFailure.get(i),', ') ;
                }else{ 
                    if(!extWarrantyRegMap.isEmpty() && extWarrantyRegMap.containsKey(serialNumber)){
                        data.message = Label.ATI_Record_Insert_Message;
                    }else{
                        data.message = Label.ATI_Record_Update_Message;    
                    }
                }
                if(!extWarrantyRegMap.isEmpty() && extWarrantyRegMap.containsKey(serialNumber)){
                    data.transactionId = /*extWarrantyRegMap.get(serialNumber).Id*/extWarrantyRegMap.get(serialNumber).Name;
                    
                }
                //data.identifier= batchETCReq.identifier;
                data.name = /*extWarrantyRegMap.get(serialNumber).Name*/serialNumber;
                responseDataLst.add(data);
                i++;
            }
            
            batchETCResponse.interfaceName = 'I-718 – Batch ETC Purchase Submittal';
            batchETCResponse.data = responseDataLst;
        	System.debug('Failed Records -> ' + batchETCValidatorObj.mapOfFailure.size());
        	System.debug('Success Records -> ' + extWarrantyRegMap.size());
            if(batchETCValidatorObj.mapOfFailure.isEmpty()){
                batchETCResponse.status = 'Success';
                batchETCResponse.message =  Label.ATI_Success_Message;
                createLog('BatchEtcSubmittal',JSON.serialize(batchETCRequest),JSON.serialize(batchETCResponse),'Success',JSON.serialize(batchETCValidatorObj.setOfSuccessRecords),JSON.serialize(batchETCValidatorObj.setOfSuccessRecords));
            }else if(batchETCValidatorObj.mapOfFailure.size() ==  batchETCRequest.size()){
                batchETCResponse.status = 'Failed';
                batchETCResponse.message = Label.ATI_Failed_Message;
                createLog('BatchEtcSubmittal',JSON.serialize(batchETCRequest),JSON.serialize(batchETCResponse),'Failed',JSON.serialize(batchETCValidatorObj.setOfFailedRecords),JSON.serialize(batchETCValidatorObj.mapOfFailure.keySet()));
            }else{
                batchETCResponse.status = 'Partial Success';
                batchETCResponse.message =  Label.ATI_PartialSuccess_Message;
                createLog('BatchEtcSubmittal',JSON.serialize(batchETCRequest),JSON.serialize(batchETCResponse),'Partial Success','Success Records-->> '+JSON.serialize(batchETCValidatorObj.setOfSuccessRecords)+',Failed Records-->> '+JSON.serialize(batchETCValidatorObj.setOfFailedRecords),'Success Records-->> '+JSON.serialize(batchETCValidatorObj.setOfSuccessRecords)+',Failed Records-->> '+JSON.serialize(batchETCValidatorObj.mapOfFailure.keySet()));
            }
            return batchETCResponse;
    }


    private void createLog(String processName, String request, String response, String status,String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_BatchETC_Submittal_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!batchETCValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(batchETCValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = batchETCValidatorObj.totalRecords-batchETCValidatorObj.totalFailedRecords;
                objLogSerWrp.failureRecordCount = batchETCValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_BatchETCSubmittalResponse responseWrapperObj = (ATI_REST_BatchETCSubmittalResponse)System.JSON.deserialize(response,ATI_REST_BatchETCSubmittalResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = batchETCValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = batchETCValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
           
            objLogSerWrp.totalRecordCount = batchETCValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    private Map<Id, WOD_2__Policy_Definition__c> getPolicyDefsMap(List<Id> policyDefIdList){
        List<String> policyDefFields = new List<String>{'Name','WOD_2__Months_Covered__c','WOD_2__Type__c','WOD_2__Status__c'};
        ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', policyDefFields);
        String policyQuery = 'Select Id, ' + String.join(policyDefFields, ', ') + ' FROM WOD_2__Policy_Definition__c WHERE Id IN :policyDefIdList';
        List<WOD_2__Policy_Definition__c> policyLst = DataBase.query(policyQuery);
        return new Map<Id, WOD_2__Policy_Definition__c>(policyLst);
    }

    private Map<Id, WOD_2__Warranty_Registration__c> getWRMap(Set<Id> wrIds){
        return new Map<Id, WOD_2__Warranty_Registration__c>([SELECT id, Name, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
             	WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Install_Date__c,
            	WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Units_Usage__c, 
            	WOD_2__Status__c FROM WOD_2__Warranty_Registration__c 
            	WHERE Id IN :wrIds]);
    }

    
   /************************************************************************
    Description    :   A wrapper class to capture Extended Warranty Registration Rest data.
    *************************************************************************/
    global class ATI_REST_BatchETCSubmittalResponse{
        global String status;
        global String message;
        global String interfaceName;
        global List<ResponseData> data;
    }
    global class ResponseData{
        //global String identifier;
        global String name;
        global String transactionId;
        global String message;
    }

        
}