/* Name: ATI_REST_CustomerMasterSync
Description : Endpoint which sync customer details and rate details(Labor/Travel/LandingCost) requied for warranty purposes
Author : Tavant(TY)
History:
VERSION     AUTHOR              DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)         10/11/2020          INITIAL DEVELOPMENT            20659                
*/
@RestResource(urlMapping = '/ATIRestCustomerMasterSync/*')
global with sharing class ATI_REST_CustomerMasterSync implements ATI_LoggableInterface{
    @HttpPost
    global Static ATI_REST_CustomerMasterSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_CustomerMasterSync customerMasterSyncObj = new ATI_REST_CustomerMasterSync();
        ATI_REST_CustomerMasterSyncResponse customerMasterResponse = customerMasterSyncObj.updateAccount(requestBody);
        return customerMasterResponse;
    }
    
    public ATI_REST_CustomerMasterSyncResponse updateAccount(String customerMasterRequest){
        ATI_REST_CustomerMasterSyncResponse customerMasterResponse = new ATI_REST_CustomerMasterSyncResponse();
        WOD_2.ResponseWrapper response = processType(customerMasterRequest);
        if(response != null && response.data != null && response.data != '') {
            customerMasterResponse = (ATI_REST_CustomerMasterSyncResponse)Json.deserialize(response.data,ATI_REST_CustomerMasterSyncResponse.class);
        }else {
            customerMasterResponse.status = 'Fail';
            customerMasterResponse.data = null;
            customerMasterResponse.interfaceName = 'I-206 – Customer Master';
            customerMasterResponse.message = response.errormessage;
            createLog('CustomerMasterSync',customerMasterRequest,JSON.serialize(customerMasterResponse),'Failed',null,null,null);
        }
        //System.debug('customerMasterResponse--->>>> '+customerMasterResponse);
        return customerMasterResponse;
    }
    
    private ATI_REST_CustomerMasterValidator  customerMasterValidatorObj{get; private set;}
    private List<WOD_2__Rates_Details__c> rateDetailsInsertOrUpdateLst{get; private set;}
    private Map<String,List<String>> mapOfAccountFailures{get; private set;}
    private Map<Integer,String> mapOfIndexWithUniqueAccount{get; private set;}
    private Map<String,Account> mapOfAccounts{get; private set;}
    private Map<String,Account> mapOfInsertOrUpdateAccounts{get; private set;}
    private Set<String> setOfInsertedAccExternalIds{get; private set;}
    private Id laborRateRecordTypeId{get; private set;}
    private Id landingCostRecordTypeId{get; private set;}
    private Id travelRecordTypeId{get; private set;}
    private Map<String,WOD_2__Rates_Details__c> mapOfInsertedRateDetails{get; private set;}
    private Map<String,String> mapOfChildWithParentAccs{get; private set;}
    private Map<String,Account> mapOfAccountRatesUpdate{get; private set;}
    private Integer totalrecords{get; private set;}
    private Integer totalFailedRecords{get; private set;}
    private Set<String> setOfFailedAccounts{get; private set;}
    private Set<String> setOfSuccessAccounts{get; private set;}
    public WOD_2.ResponseWrapper processType(String customerMasterRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_CustomerMasterRequest customerMasterReqObj = new ATI_REST_CustomerMasterRequest();
        customerMasterValidatorObj = new ATI_REST_CustomerMasterValidator();
        try{
            customerMasterReqObj = ATI_REST_CustomerMasterRequest.parse(customerMasterRequest);
            System.debug('Request>>>> '+customerMasterReqObj);
            customerMasterValidatorObj.validateReqest(customerMasterReqObj);
            mapOfAccountFailures = new Map<String,List<String>>();
            mapOfIndexWithUniqueAccount = new Map<Integer,String>();
            mapOfAccounts = new Map<String,Account>(customerMasterValidatorObj.mapOfAccounts);
            setOfInsertedAccExternalIds = new Set<String>();
            mapOfInsertOrUpdateAccounts = new Map<String,Account>();
            mapOfChildWithParentAccs = new Map<String,String>();
            rateDetailsInsertOrUpdateLst = new List<WOD_2__Rates_Details__c>();
            mapOfInsertedRateDetails = new Map<String,WOD_2__Rates_Details__c>();
            mapOfAccountRatesUpdate = new Map<String,Account>();
            setOfFailedAccounts = new Set<String>();
            setOfSuccessAccounts = new Set<String>();
            laborRateRecordTypeId  = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Labor_Rate').getRecordTypeId();
            landingCostRecordTypeId = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Landing_Cost_Rate').getRecordTypeId();
            travelRecordTypeId = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Travel_Rate').getRecordTypeId();
            totalrecords = 0;
            totalFailedRecords = 0;
            Integer index = 0;
            for(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq : customerMasterValidatorObj.customerMasterReqLst){
                Account accountObj;
                if(!customerMasterValidatorObj.mapOfAccounts.isEmpty() && customerMasterValidatorObj.mapOfAccounts.containsKey(customerMasterReq.externalId.trim())){
                    accountObj = customerMasterValidatorObj.mapOfAccounts.get(customerMasterReq.externalId.trim());
                }else{
                    accountObj = new Account();
                    accountObj.SAP_ID__c = customerMasterReq.externalId;
                    setOfInsertedAccExternalIds.add(accountObj.SAP_ID__c);
                }
                accountObj.WOD_2__Warranty_Account_Type__c = 'Dealer';
                accountObj.Name = customerMasterReq.accountName; //blankcheck for mandatory fields handled in ATI_REST_CustomerMasterValidator class
                accountObj.AccountNumber = customerMasterReq.accountNumber;
                if(!String.isBlank(customerMasterReq.accountDescription)){
                    accountObj.Description = customerMasterReq.accountDescription;
                }
                accountObj.ATI_Active__c = customerMasterReq.active;
                if(!String.isBlank(customerMasterReq.parentAccount)){
                    if(customerMasterValidatorObj.mapOfAccounts.containsKey(customerMasterReq.parentAccount.trim())){
                        accountObj.ParentId = customerMasterValidatorObj.mapOfAccounts.get(customerMasterReq.parentAccount.trim()).Id;
                        if(String.isBlank(accountObj.Id)){
                            accountObj.ATI_Alternate_Parent__c = customerMasterValidatorObj.mapOfAccounts.get(customerMasterReq.parentAccount.trim()).Id;
                        }
                    }else{
                        mapOfChildWithParentAccs.put(customerMasterReq.externalId.trim(),customerMasterReq.parentAccount.trim());
                    }
                }
                accountObj.ATI_Financial_BP_Code__c = customerMasterReq.financialBPCode;
                accountObj.BillingStreet = customerMasterReq.billingStreet;
                accountObj.BillingCity = customerMasterReq.billingCity;
                accountObj.BillingState = customerMasterReq.billingState;
                accountObj.BillingPostalCode = customerMasterReq.billingPostalCode;
                accountObj.BillingCountry = customerMasterReq.billingCountry;
                accountObj.ShippingStreet = customerMasterReq.shippingStreet;
                accountObj.ShippingCity = customerMasterReq.shippingCity;
                accountObj.ShippingState = customerMasterReq.shippingState;
                accountObj.ShippingPostalCode = customerMasterReq.shippingPostalCode;
                accountObj.ShippingCountry = customerMasterReq.shippingCountry;
                accountObj.ATI_Business_Category_Unit__c = customerMasterReq.businessCategoryUnit;
                accountObj.WOD_2__Business_Units__c = customerMasterReq.businessCategoryUnit;
                accountObj.ATI_Currency__c = customerMasterReq.customerCurrency;
                //ALSN-75
                accountObj.CurrencyIsoCode = customerMasterReq.customerCurrency;
                accountObj.ATI_Region__c = customerMasterReq.region;
                accountObj.ATI_Customer_Group__c = customerMasterReq.customerGroup;
                accountObj.ATI_Account_Group__c = customerMasterReq.accountGroup;
                accountObj.ATI_Price_Group__c = customerMasterReq.priceGroup;
                accountObj.ATI_Exchange_Rate_Type__c = customerMasterReq.exchangeRateType;
                if(ATI_Utils.checkIsNotBlankData(customerMasterReq.adjustmentFactor)){
                    accountObj.ATI_Adjustment_Factor__c = Decimal.valueOf(customerMasterReq.adjustmentFactor);
                }
                accountObj.ATI_Performance__c = Boolean.valueOf(customerMasterReq.performance);
                //CHG0043240 - apply performance value to PRP Participation too.
                //Alsn-194
                //ALSN-212 using the expression to check if SAP Id starts with '00000'
                Boolean sapId = Pattern.matches('^[0]{5}[0-9]{5}$', customerMasterReq.externalId);
                //previous condition 'if(customerMasterReq.externalId.length() > 5){'
                if(!sapId){
                    accountObj.PRP_Participation__c = Boolean.valueOf(customerMasterReq.performance);
                }
                //ALSN-212 end
                accountObj.ATI_Distance_Indicator__c = customerMasterReq.distanceIndicator;
                accountObj.ATI_Active_Date__c =  ATI_Utils.parseDate(customerMasterReq.activeDate.trim());
                accountObj.Email_Address__c = customerMasterReq.email;
                accountObj.ATI_Inactive_Date__c = ATI_Utils.parseDate(customerMasterReq.inActiveDate.trim());
                accountObj.ATI_Exempt_From_Part_Return__c = Boolean.valueOf(customerMasterReq.rmaExempt);
                mapOfInsertOrUpdateAccounts.put(customerMasterReq.externalId,accountObj);
                mapOfIndexWithUniqueAccount.put(index,customerMasterReq.identifier.trim()+':'+customerMasterReq.externalId.trim());
                index++;
            }
            if(!mapOfInsertOrUpdateAccounts.isEmpty()){
                createOrUpdateAccountDetails();
            }
            responseWrapper.data = JSON.serialize(createResponse(customerMasterReqObj.account));
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('message>> '+ e.getMessage());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage()+e.getStackTraceString();
        }
        return responseWrapper;
    }
    
    
    private void createOrUpdateAccountDetails(){
        try{
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'SAP_ID__c','WOD_2__Warranty_Account_Type__c','Name','AccountNumber','Description','ATI_Active__c','ParentId','ATI_Alternate_Parent__c','ATI_Financial_BP_Code__c','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry',
                'ShippingStreet','ShippingCity','ShippingState','ShippingPostalCode','ShippingCountry','ATI_Business_Category_Unit__c','ATI_Currency__c','ATI_Region__c','ATI_Customer_Group__c','ATI_Account_Group__c','ATI_Price_Group__c','ATI_Exchange_Rate_Type__c',
                'ATI_Adjustment_Factor__c','ATI_Performance__c','ATI_Distance_Indicator__c','ATI_Active_Date__c','ATI_Exempt_From_Part_Return__c','ATI_Max_Travel_Distance__c','ATI_Distance_Per_Hour__c'};
                    ATI_Utils.NoAccessObjectFieldWrapper accountCreateAccessCheck = ATI_Utils.fetchCreateAccess(accountSObjName,accountFields);
            ATI_Utils.NoAccessObjectFieldWrapper accountUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(accountSObjName,accountFields);
            if(accountCreateAccessCheck.noAccessObjectList.size() == 0 && accountCreateAccessCheck.noAccessFieldList.size() == 0 && accountUpdateAccessCheck.noAccessObjectList.size() == 0 && accountUpdateAccessCheck.noAccessFieldList.size() == 0){
                //upsert mapOfInsertOrUpdateAccounts.values();
                Database.UpsertResult[] accInsertOrUpdateLst = Database.upsert(mapOfInsertOrUpdateAccounts.values(), false);
                Map<String,Id> mapOfExternalIdWithAccountId = new Map<String,Id>();
                Integer index = 0;
                for(Database.UpsertResult sr : accInsertOrUpdateLst){
                    if(sr.isSuccess()){
                        mapOfExternalIdWithAccountId.put(mapOfIndexWithUniqueAccount.get(index).split(':')[1],sr.getId());
                    }else{
                        //Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            if(!mapOfAccountFailures.containsKey(mapOfIndexWithUniqueAccount.get(index).split(':')[0])){
                                mapOfAccountFailures.put(mapOfIndexWithUniqueAccount.get(index).split(':')[0],new List<String>{err.getMessage()});
                            }else{
                                mapOfAccountFailures.get(mapOfIndexWithUniqueAccount.get(index).split(':')[0]).add(err.getMessage());
                            }
                        }
                    }
                    index++;
                }
                fetchInsertedAccountDetails();
                Map<String,List<String>> mapOfRateDetailsFailure = customerMasterValidatorObj.mapOfRateDetailsFailure;
                System.debug('mapOfRateDetailsFailure -> ' + mapOfRateDetailsFailure);
                for(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq : customerMasterValidatorObj.customerMasterReqLst){
                    System.debug('mapOfExternalIdWithAccountId -> ' + mapOfExternalIdWithAccountId);
                    String identifier = customerMasterReq.identifier.trim();
                    if(mapOfExternalIdWithAccountId.containsKey(customerMasterReq.externalId.trim())){
                        if(!mapOfRateDetailsFailure.containsKey('LaborRate:'+identifier)){
                            getLaborRateDetails(customerMasterReq);    
                        }
                        if(!mapOfRateDetailsFailure.containsKey('TravelRate:'+identifier)){
                            getDistanceRateDetails(customerMasterReq);    
                        }
                        if(!mapOfRateDetailsFailure.containsKey('LandingCostRate:'+identifier)){
                            getLandingCostDetails(customerMasterReq);    
                        }
                    }
                }
                System.debug('mapOfInsertedRateDetails -> ' + mapOfInsertedRateDetails);
                if(!mapOfInsertedRateDetails.isEmpty()){
                    List<String> rateDatailsLst = new List<String>();
                    rateDatailsLst.addAll(mapOfInsertedRateDetails.keySet());
                    rateDatailsLst.sort();
                    Integer i = 0;
                    System.debug('rateDatailsLst -> ' + rateDatailsLst);
                    While(i<rateDatailsLst.size()-1){
                        List<String> uniqueRateDetail = rateDatailsLst[i].split(':');
                        List<String> nextUniqueRateDetail = rateDatailsLst[i+1].split(':');
                        if(uniqueRateDetail[0] == nextUniqueRateDetail[0]){
                            WOD_2__Rates_Details__c rateDetail = mapOfInsertedRateDetails.get(rateDatailsLst[i]);
                            WOD_2__Rates_Details__c nextRateDetail = mapOfInsertedRateDetails.get(rateDatailsLst[i+1]);
                            rateDetail.WOD_2__Active_Until__c = nextRateDetail.WOD_2__Active_From__c.addDays(-1);
                            rateDetailsInsertOrUpdateLst.add(rateDetail);
                        }else{
                            rateDetailsInsertOrUpdateLst.add(mapOfInsertedRateDetails.get(rateDatailsLst[i]));
                        }
                        i++;
                    }
                    rateDetailsInsertOrUpdateLst.add(mapOfInsertedRateDetails.get(rateDatailsLst[i]));
                }
                if(!rateDetailsInsertOrUpdateLst.isEmpty()){
                    List<WOD_2__Rates_Details__c> listOfRateDetails = removeDuplicates(rateDetailsInsertOrUpdateLst);
                    rateDetailsInsertOrUpdateLst.clear();
                    rateDetailsInsertOrUpdateLst.addAll(listOfRateDetails);
                    createOrUpdateRateDetails();
                    System.debug('mapOfAccountRatesUpdate -> ' + mapOfAccountRatesUpdate);
                    if(!mapOfAccountRatesUpdate.isEmpty()){
                        update mapOfAccountRatesUpdate.values();
                    }
                }
            }else{
                String errortext = 'Insufficient Account Create Access>> '+JSON.serialize(accountCreateAccessCheck)+',Insufficient Account Update Access>> '+JSON.serialize(accountUpdateAccessCheck);
                ATI_LogService.createLogForAccess('CustomerMasterSync',errortext);
                throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access); 
            }
        }catch(Exception e){
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    
    private void fetchInsertedAccountDetails(){
        try{
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'Name','SAP_ID__c','WOD_2__Warranty_Account_Type__c','ATI_Currency__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            if(acountNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && acountNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0){
                List<Account> accUpdateLst = new List<Account>();
                if(!setOfInsertedAccExternalIds.isEmpty()){
                    List<Account> accountLst = [SELECT Id,Name,SAP_ID__c,ATI_Currency__c,WOD_2__Warranty_Account_Type__c FROM Account WHERE SAP_ID__c IN : setOfInsertedAccExternalIds  AND WOD_2__Warranty_Account_Type__c IN ('Dealer')];
                    for(Account acc : accountLst){
                        if(!mapOfAccounts.containsKey(acc.SAP_ID__c)){
                            mapOfAccounts.put(acc.SAP_ID__c,acc);
                        }
                    }
                }
                for(String childAcc : mapOfChildWithParentAccs.KeySet()){
                    if(mapOfAccounts.containsKey(mapOfChildWithParentAccs.get(childAcc))){
                        Account accData = mapOfInsertOrUpdateAccounts.get(childAcc);
                        accData.ParentId = mapOfAccounts.get(mapOfChildWithParentAccs.get(childAcc)).Id;
                        accData.ATI_Alternate_Parent__c = mapOfAccounts.get(mapOfChildWithParentAccs.get(childAcc)).Id;
                        accUpdateLst.add(accData);
                    }
                }
                if(!accUpdateLst.isEmpty()){
                    update accUpdateLst;
                }
            }else{
                throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access);
            }
        }catch(Exception e){
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    private void getLaborRateDetails(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.LaborRateDetails  lrd : customerMasterReq.laborRateDetail){
            if(Decimal.valueOf(lrd.laborRate.trim()) != 0){
                if(!customerMasterValidatorObj.mapOfLaborRates.containsKey(customerMasterReq.externalId.trim())  ||
                   (customerMasterValidatorObj.mapOfLaborRates.containsKey(customerMasterReq.externalId.trim()) && 
                    customerMasterValidatorObj.mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c < ATI_Utils.parseDate(lrd.activeFrom.trim()))){
                        WOD_2__Rates_Details__c newRd = new WOD_2__Rates_Details__c();
                        newRd.Name = customerMasterReq.accountNumber;
                        newRd.WOD_2__Dealer__c = mapOfAccounts.get(customerMasterReq.externalId.trim()).id;
                        newRd.WOD_2__Labor_Rate__c = Decimal.valueOf(lrd.laborRate);
                        newRd.RecordTypeId = laborRateRecordTypeId;
                        newRd.WOD_2__Rate_Type__c = 'Date Based';
                        newRd.WOD_2__Rate_Sub_Type__c = 'Labor Rate';
                        newRd.WOD_2__Status__c = 'Active';
                        newRd.WOD_2__Active_From__c = ATI_Utils.parseDate(lrd.activeFrom.trim());
                        newRd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                        if(customerMasterValidatorObj.mapOfLaborRates.containsKey(customerMasterReq.externalId.trim())){
                            if(customerMasterValidatorObj.mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c > ATI_Utils.parseDate(lrd.activeFrom.trim())){
                                newRd.WOD_2__Active_Until__c = customerMasterValidatorObj.mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c;
                            }else{
                                newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                            }
                            rateDetailsInsertOrUpdateLst.add(newRd);
                        }else{
                            newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                        }
                        mapOfInsertedRateDetails.put('LaborRate'+customerMasterReq.externalId.trim()+':'+lrd.activeFrom.trim(),newRd);
                    }
                if(!customerMasterValidatorObj.mapOfLaborRates.isEmpty() && customerMasterValidatorObj.mapOfLaborRates.containsKey(customerMasterReq.externalId.trim()) &&
                   customerMasterValidatorObj.mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c <= ATI_Utils.parseDate(lrd.activeFrom.trim())){
                       WOD_2__Rates_Details__c rd = customerMasterValidatorObj.mapOfLaborRates.get(customerMasterReq.externalId.trim());
                       rd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                       if(rd.WOD_2__Active_From__c < ATI_Utils.parseDate(lrd.activeFrom.trim()) &&
                         rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(lrd.activeFrom.trim())){ // Change made by Dishari on 16th Nov 21
                       //if(rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(lrd.activeFrom.trim())){  
                           rd.WOD_2__Active_Until__c = ATI_Utils.parseDate(lrd.activeFrom.trim()).addDays(-1);
                       }
                       if(ATI_Utils.parseDate(lrd.activeFrom.trim()) == rd.WOD_2__Active_From__c){
                           rd.WOD_2__Labor_Rate__c = Decimal.valueOf(lrd.laborRate);    
                       }
                       rateDetailsInsertOrUpdateLst.add(rd);
                   }
            }
        }
    }
    
    private void getDistanceRateDetails(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.DistanceRateDetails distanceRateInfo : customerMasterReq.distanceRateDetails){
            Account acc = mapOfAccounts.get(customerMasterReq.externalId.trim());
            System.debug('Account>>>> '+acc);
             System.debug('RatesDetails>>>> '+distanceRateInfo.maxTravelDist+ ' >>>> '+distanceRateInfo.distancePerHour);
            if(!String.isBlank(distanceRateInfo.maxTravelDist)){
                acc.ATI_Max_Travel_Distance__c = Decimal.valueOf(distanceRateInfo.maxTravelDist);
            }else{
                acc.ATI_Max_Travel_Distance__c = null;
            }
            if(!String.isBlank(distanceRateInfo.distancePerHour)){
                acc.ATI_Distance_Per_Hour__c = Decimal.valueOf(distanceRateInfo.distancePerHour);
            }else{
                acc.ATI_Distance_Per_Hour__c = null;
            }
            mapOfAccountRatesUpdate.put(customerMasterReq.externalId.trim(),acc);
            System.debug('mapOfAccountRatesUpdate>>>> '+mapOfAccountRatesUpdate);
            for(ATI_REST_CustomerMasterRequest.DistanceRateDetailInfo distanceRateDetailInfo : distanceRateInfo.distanceRateDetail){
                if(Decimal.valueOf(distanceRateDetailInfo.distanceRate.trim()) != 0){
                    if(!customerMasterValidatorObj.mapOfTravelRates.containsKey(customerMasterReq.externalId.trim()) ||
                       (customerMasterValidatorObj.mapOfTravelRates.containsKey(customerMasterReq.externalId.trim()) && 
                        customerMasterValidatorObj.mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c < ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim()))){
                            WOD_2__Rates_Details__c newRd = new WOD_2__Rates_Details__c();           
                            newRd.Name = customerMasterReq.accountNumber;
                            newRd.WOD_2__Dealer__c = mapOfAccounts.get(customerMasterReq.externalId.trim()).id;
                            newRd.RecordTypeId = travelRecordTypeId;
                            newRd.WOD_2__Rate_Type__c = 'Date Based';
                            newRd.WOD_2__Rate_Sub_Type__c = 'Travel Rate'; 
                            newRd.WOD_2__Travel_By_Distance_Rate__c = Decimal.valueOf(distanceRateDetailInfo.distanceRate);
                            newRd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                            newRd.WOD_2__Status__c = 'Active';
                            newRd.WOD_2__Active_From__c = ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim());
                            if(customerMasterValidatorObj.mapOfTravelRates.containsKey(customerMasterReq.externalId.trim())){
                                if(customerMasterValidatorObj.mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c > ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim())){
                                    newRd.WOD_2__Active_Until__c = customerMasterValidatorObj.mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c;
                                }else{
                                    newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                                }
                                rateDetailsInsertOrUpdateLst.add(newRd);
                            }else{
                                newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                            }
                            mapOfInsertedRateDetails.put('TravelRate'+customerMasterReq.externalId.trim()+':'+distanceRateDetailInfo.activeFrom.trim(),newRd);
                        }
                    if(!customerMasterValidatorObj.mapOfTravelRates.isEmpty() && customerMasterValidatorObj.mapOfTravelRates.containsKey(customerMasterReq.externalId.trim()) &&
                       customerMasterValidatorObj.mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c <= ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim())){
                           WOD_2__Rates_Details__c rd = customerMasterValidatorObj.mapOfTravelRates.get(customerMasterReq.externalId.trim());
                           rd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                           if(rd.WOD_2__Active_From__c < ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim()) && rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim())){ // Change made by Dishari on 16th Nov 21
                           //if(rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim())){
                               rd.WOD_2__Active_Until__c = ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim()).addDays(-1);
                           }
                           if(ATI_Utils.parseDate(distanceRateDetailInfo.activeFrom.trim()) == rd.WOD_2__Active_From__c){
                               rd.WOD_2__Travel_By_Distance_Rate__c = Decimal.valueOf(distanceRateDetailInfo.distanceRate);
                           }
                           rateDetailsInsertOrUpdateLst.add(rd);
                       }
                }
            }
        }        
    }
    
    private void getLandingCostDetails(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.LandingCostMarkupDetails lcmd : customerMasterReq.landingCostMarkupDetails){
            for(ATI_REST_CustomerMasterRequest.LandingCostDetails lcd : lcmd.landingCostDetail){
                if(Decimal.valueOf(lcd.landingCostRate.trim()) != 0){
                    if(!customerMasterValidatorObj.mapOfLandingCostRates.containsKey(customerMasterReq.externalId.trim()) || 
                       (customerMasterValidatorObj.mapOfLandingCostRates.containsKey(customerMasterReq.externalId.trim()) && 
                        customerMasterValidatorObj.mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c < ATI_Utils.parseDate(lcd.activeFrom.trim()))){
                            WOD_2__Rates_Details__c newRd = new WOD_2__Rates_Details__c();
                            newRd.Name = customerMasterReq.accountNumber;
                            newRd.WOD_2__Dealer__c = mapOfAccounts.get(customerMasterReq.externalId.trim()).id;
                            newRd.RecordTypeId = landingCostRecordTypeId;
                            newRd.WOD_2__Rate_Type__c = 'Date Based';
                            newRd.WOD_2__Rate_Sub_Type__c = 'Landing Cost Rate';
                            newRd.ATI_Landing_Cost_Rate__c = Decimal.valueOf(lcd.landingCostRate);
                            newRd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                            newRd.ATI_Landed_Cost_Markup__c = newRd.ATI_Landing_Cost_Rate__c * 100;
                            newRd.WOD_2__Status__c = 'Active';
                            newRd.WOD_2__Active_From__c =  ATI_Utils.parseDate(lcd.activeFrom.trim());
                            if(customerMasterValidatorObj.mapOfLandingCostRates.containsKey(customerMasterReq.externalId.trim())){
                                if(customerMasterValidatorObj.mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c > ATI_Utils.parseDate(lcd.activeFrom.trim())){
                                    newRd.WOD_2__Active_Until__c = customerMasterValidatorObj.mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_Until__c;
                                }else{
                                    newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                                }
                                rateDetailsInsertOrUpdateLst.add(newRd);
                            }else{
                                newRd.WOD_2__Active_Until__c = ATI_Utils.parseDate('2099-12-31');
                            }
                            mapOfInsertedRateDetails.put('LandingCostRate'+customerMasterReq.externalId.trim()+':'+lcd.activeFrom.trim(),newRd);
                        }
                    if(!customerMasterValidatorObj.mapOfLandingCostRates.isEmpty() && customerMasterValidatorObj.mapOfLandingCostRates.containsKey(customerMasterReq.externalId.trim()) && 
                       customerMasterValidatorObj.mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c <= ATI_Utils.parseDate(lcd.activeFrom.trim())){
                           WOD_2__Rates_Details__c rd = customerMasterValidatorObj.mapOfLandingCostRates.get(customerMasterReq.externalId.trim());
                           rd.CurrencyIsoCode =  mapOfAccounts.get(customerMasterReq.externalId.trim()).ATI_Currency__c;
                           if(rd.WOD_2__Active_From__c < ATI_Utils.parseDate(lcd.activeFrom.trim()) && rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(lcd.activeFrom.trim())){// Change made by Dishari on 16th Nov 21
                           //if(rd.WOD_2__Active_Until__c > ATI_Utils.parseDate(lcd.activeFrom.trim())){
                               rd.WOD_2__Active_Until__c = ATI_Utils.parseDate(lcd.activeFrom.trim()).addDays(-1);
                           }
                           if(ATI_Utils.parseDate(lcd.activeFrom.trim()) == rd.WOD_2__Active_From__c){
                               rd.ATI_Landing_Cost_Rate__c = Decimal.valueOf(lcd.landingCostRate);
                               rd.ATI_Landed_Cost_Markup__c = rd.ATI_Landing_Cost_Rate__c * 100;
                           }
                           rateDetailsInsertOrUpdateLst.add(rd);
                       }
                }
            }
        }
    }
    
    private static List<WOD_2__Rates_Details__c> removeDuplicates(List<WOD_2__Rates_Details__c> rateDetailLst){
        return new List<WOD_2__Rates_Details__c>(new Set<WOD_2__Rates_Details__c>(rateDetailLst));
    }
    
    private void createOrUpdateRateDetails(){
        String rateDetailSObjName = 'WOD_2__Rates_Details__c';
        List<String> rateDetailFields = new List<String>{'WOD_2__Dealer__c','WOD_2__Labor_Rate__c','WOD_2__Travel_By_Distance_Rate__c','ATI_Landing_Cost_Rate__c','WOD_2__Active_From__c','WOD_2__Active_Until__c','WOD_2__Rate_Sub_Type__c','WOD_2__Rate_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper rateDetailCreateAccessCheck = ATI_Utils.fetchCreateAccess(rateDetailSObjName,rateDetailFields);
        ATI_Utils.NoAccessObjectFieldWrapper rateDetailUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(rateDetailSObjName,rateDetailFields);
        if(rateDetailCreateAccessCheck.noAccessObjectList.size() == 0 && rateDetailCreateAccessCheck.noAccessFieldList.size() == 0 && rateDetailUpdateAccessCheck.noAccessObjectList.size() == 0 && rateDetailUpdateAccessCheck.noAccessFieldList.size() == 0){
            upsert rateDetailsInsertOrUpdateLst;
        } else {
            String errortext = 'Insufficient RateDetail Create Access>> '+JSON.serialize(rateDetailCreateAccessCheck)+'Insufficient RateDetail Update Access>> '+JSON.serialize(rateDetailUpdateAccessCheck);
            ATI_LogService.createLogForAccess('CustomerMasterSync',errortext);
            throw new ATI_Exception('(Rates Details) '+Label.ATI_Log_Insufficient_access); 
        }
    }
    
    private ATI_REST_CustomerMasterSyncResponse createResponse(List<ATI_REST_CustomerMasterRequest.CustomerInformation> customerMasterRequest){
        ATI_REST_CustomerMasterSyncResponse customerMasterResponse = new ATI_REST_CustomerMasterSyncResponse();
        List<CustomerMasterData> dataLst = new List<CustomerMasterData>();
        Map<String,List<String>> mapOfFailure = new Map<String,List<String>>();
        Integer  i = 1;
        for(ATI_REST_CustomerMasterRequest.CustomerInformation customerMaster : customerMasterRequest){
            CustomerMasterData responseData = new CustomerMasterData();
            responseData.identifier = customerMaster.identifier;
            responseData.message = '';
            if(mapOfAccountFailures.containsKey(customerMaster.identifier.trim())){
                responseData.message += String.Join(mapOfAccountFailures.get(customerMaster.identifier.trim()),', ');
                setOfFailedAccounts.add(customerMaster.externalId.trim());
                mapOfFailure.put(customerMaster.identifier.trim(),mapOfAccountFailures.get(customerMaster.identifier.trim()));
                totalFailedRecords++;
            }else if(customerMasterValidatorObj.mapOffailure.containsKey(i)){
                responseData.message = String.Join(customerMasterValidatorObj.mapOffailure.get(i),', ') ;
                setOfFailedAccounts.add(customerMaster.externalId.trim());
                mapOfFailure.put(customerMaster.identifier.trim(),customerMasterValidatorObj.mapOffailure.get(i));
                totalFailedRecords++;
            }else{
                if(customerMasterValidatorObj.mapOfAccounts.containsKey(customerMaster.externalId.trim())){
                    responseData.message = 'Record Updated Successfully';
                }else{
                    responseData.message = 'Record Inserted Successfully';    
                }
                setOfSuccessAccounts.add(customerMaster.externalId.trim());
            }
            System.debug('mapOfAccounts>>>> '+mapOfAccounts.keySet());
            System.debug('mapOfAccountFailures>>>> '+mapOfAccountFailures.keySet());
            if(!mapOfAccountFailures.containsKey(customerMaster.identifier.trim()) && mapOfAccounts.containsKey(customerMaster.externalId.trim())){
                responseData.transactionId = mapOfAccounts.get(customerMaster.externalId.trim()).Id;
                responseData.name = mapOfAccounts.get(customerMaster.externalId.trim()).Name;
            }
            dataLst.add(responseData);
            i++;
        }
        totalrecords = i-1;
        customerMasterResponse.interfaceName = 'I-206 – Customer Master';
        customerMasterResponse.data = dataLst;
        if(customerMasterValidatorObj.mapOffailure.isEmpty() && mapOfAccountFailures.isEmpty()){
            customerMasterResponse.status = 'Success';
            customerMasterResponse.message =  'All the records have been inserted / updated successfully';
            createLog('CustomerMasterSync',JSON.serialize(customerMasterRequest),JSON.serialize(customerMasterResponse),'Success',null,JSON.serialize(setOfSuccessAccounts),null);
        }else if(totalFailedRecords == customerMasterRequest.size()){
            customerMasterResponse.status = 'Failed';
            customerMasterResponse.message = 'All the records have failed to insert / update';
            createLog('CustomerMasterSync',JSON.serialize(customerMasterRequest),JSON.serialize(customerMasterResponse),'Failed',JSON.serialize(setOfFailedAccounts),JSON.serialize(setOfFailedAccounts),JSON.serialize(mapOfFailure.values()));
        }else{
            customerMasterResponse.status = 'Partial Success';
            customerMasterResponse.message =  'Few records have not been inserted / updated.';
            createLog('CustomerMasterSync',JSON.serialize(customerMasterRequest),JSON.serialize(customerMasterResponse),'Partial Success',JSON.serialize(setOfFailedAccounts),'Success>> '+JSON.serialize(setOfSuccessAccounts)+',Failure>> '+JSON.serialize(setOfFailedAccounts),JSON.serialize(mapOfFailure.values()));
        }
        System.debug('Response>>>> '+customerMasterResponse);
        return customerMasterResponse;    
    }
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey,String errorMessage){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_CustomerMaster_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            objLogSerWrp.errortext = errorMessage;
            objLogSerWrp.totalRecordCount = totalRecords;
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_CustomerMasterSyncResponse responseWrapperObj = (ATI_REST_CustomerMasterSyncResponse)System.JSON.deserialize(response,ATI_REST_CustomerMasterSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }else{
                objLogSerWrp.successRecordCount = totalRecords - totalFailedRecords;
                objLogSerWrp.failureRecordCount = totalFailedRecords;
            }
            //System.debug('objLogSerWrp-->>> '+objLogSerWrp);
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
    Description    :   A wrapper class to capture the CustomerMaster Rest data.
    *************************************************************************/
    global class ATI_REST_CustomerMasterSyncResponse{
        global String status;
        global String message;
        global String interfaceName;
        global List<CustomerMasterData> data;
    }
    global class CustomerMasterData{
        global String name;
        global String transactionId;
        global String message;
        global String identifier;
    }
}