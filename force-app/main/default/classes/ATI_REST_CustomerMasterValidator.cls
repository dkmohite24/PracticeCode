/* Name: ATI_REST_CustomerMasterValidator
Description : This Class is used to validate CustomerMaster JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR           DATE               DETAIL                   UserStory/Req#
1.0 -     Tavant(TY)       10/11/2020        INITIAL DEVELOPMENT            20659                   
*/
public with sharing class ATI_REST_CustomerMasterValidator {
    public List<ATI_REST_CustomerMasterRequest.CustomerInformation> customerMasterReqLst{get; private set;}
    public List<ATI_REST_CustomerMasterRequest.CustomerInformation> customerMasterReqForRateDetailsLst{get; private set;}
    public Map<Integer,List<String>> mapOffailure{get; private set;}
    public Map<String,List<String>> mapOfRateDetailsFailure{get; private set;}
    public Map<String,Account> mapOfAccounts{get; private set;}
    public Map<String,CurrencyType> mapOfCurrencyTypes{get; private set;}
    public Set<String> setOfCurrencies{get; private set;}
    public Set<String> setOfExternalIds{get; private set;}
    public Set<String> setOfRateDetails{get; private set;}
    public Map<String,WOD_2__Rates_Details__c> mapOfLaborRates{get; private set;}
    public Map<String,WOD_2__Rates_Details__c> mapOfTravelRates{get; private set;}
    public Map<String,WOD_2__Rates_Details__c> mapOfLandingCostRates{get; private set;}
    public Map<String,ATI_REST_CustomerMasterRequest.CustomerInformation> mapOfExternalIdWithReq;
    public ATI_REST_CustomerMasterValidator(){
        customerMasterReqLst = new List<ATI_REST_CustomerMasterRequest.CustomerInformation>();
        customerMasterReqForRateDetailsLst = new List<ATI_REST_CustomerMasterRequest.CustomerInformation>();
        mapOffailure = new Map<Integer,List<String>>();
        mapOfRateDetailsFailure = new Map<String,List<String>>();
        mapOfAccounts = new Map<String,Account>();
        mapOfCurrencyTypes = new Map<String,CurrencyType>();
        setOfCurrencies = new Set<String>();
        setOfExternalIds = new Set<String>();
        setOfRateDetails = new Set<String>();
        mapOfLaborRates = new Map<String,WOD_2__Rates_Details__c>();
        mapOfTravelRates = new Map<String,WOD_2__Rates_Details__c>();
        mapOfLandingCostRates = new Map<String,WOD_2__Rates_Details__c>();
        mapOfExternalIdWithReq = new Map<String,ATI_REST_CustomerMasterRequest.CustomerInformation>();
    }
    public void validateReqest(ATI_REST_CustomerMasterRequest customerMasterRequestBody){
        queryCustomerMasterData(customerMasterRequestBody);
        verifyCustomerMasterRequest(customerMasterRequestBody);
    }
    
    private void queryCustomerMasterData(ATI_REST_CustomerMasterRequest customerMasterRequestBody){
        for(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq : customerMasterRequestBody.account){
            if(!String.isBlank(customerMasterReq.externalId)){
                setOfExternalIds.add(customerMasterReq.externalId.trim());
                mapOfExternalIdWithReq.put(customerMasterReq.externalId.trim(),customerMasterReq);
            }
            if(!String.isBlank(customerMasterReq.parentAccount)){
                setOfExternalIds.add(customerMasterReq.parentAccount.trim());
            }
            if(!String.isBlank(customerMasterReq.customerCurrency)){
                setOfCurrencies.add(customerMasterReq.customerCurrency.trim());
            }
        }
        if(checkReadAccess()){
            if(!setOfExternalIds.isEmpty()){
                List<Account> accountLst = [SELECT Id,Name,SAP_ID__c,Parent.SAP_ID__c,ParentId,WOD_2__Warranty_Account_Type__c,ATI_Currency__c,
                                            (SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__r WHERE WOD_2__Status__c='Active' 
                                             Order By WOD_2__Active_From__c DESC) FROM Account WHERE SAP_ID__c IN : setOfExternalIds  AND WOD_2__Warranty_Account_Type__c IN ('Dealer')];
                for(Account acc:accountLst){
                    mapOfAccounts.put(acc.SAP_ID__c,acc);
                    for(WOD_2__Rates_Details__c rd : acc.WOD_2__Rates_Details__r){
                        if(!mapOfLaborRates.containsKey(acc.SAP_ID__c) && rd.RecordType.DeveloperName == 'ATI_Labor_Rate'){
                            mapOfLaborRates.put(acc.SAP_ID__c,rd);
                        }else if(!mapOfTravelRates.containsKey(acc.SAP_ID__c) && rd.RecordType.DeveloperName == 'ATI_Travel_Rate'){
                            mapOfTravelRates.put(acc.SAP_ID__c,rd);
                        }else if(!mapOfLandingCostRates.containsKey(acc.SAP_ID__c) && rd.RecordType.DeveloperName == 'ATI_Landing_Cost_Rate'){
                            mapOfLandingCostRates.put(acc.SAP_ID__c,rd);
                        }
                    }
                }
                mapOfCurrencyTypes = ATI_Utils.getGlobalCurrencies(setOfCurrencies);
            }
        }else{
            throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access); 
        }
    }
    
    private void verifyCustomerMasterRequest(ATI_REST_CustomerMasterRequest customerMasterRequestBody){
        Integer  i = 1;
        set<String> identifierSet = new set<String>();
        Map<String,String> buMap = ATI_Utils.getPicklistOptions('Account','WOD_2__Business_Units__c');
        for(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq : customerMasterRequestBody.account){
            List<String> errorList = new List<String>();
            List<String> rateDetailsErrorLst = new List<String>();
            if(String.isBlank(customerMasterReq.identifier)){
                errorList.add('Identifier is Mandatory');
            }
            else if(!identifierSet.add(customerMasterReq.identifier.trim())){
                errorList.add('Identifier is not unique');
            }
            if(String.isBlank(customerMasterReq.accountName)){
                errorList.add('AccountName can not be empty');
            }
            if(String.isBlank(customerMasterReq.accountNumber)){
                errorList.add('AccountNumber can not be empty');
            }
            if(String.isBlank(customerMasterReq.active)){
                errorList.add('Active can not be empty');
            }
            if(String.isBlank(customerMasterReq.externalId)){
                errorList.add('ExternalId is Mandatory');
            }else{
                if(!String.isBlank(customerMasterReq.parentAccount) && !mapOfExternalIdWithReq.containsKey(customerMasterReq.parentAccount.trim()) &&
                                                                       !mapOfAccounts.containsKey(customerMasterReq.parentAccount.trim())){
                    errorList.add('ParentAccount is Invalid');
                }
                validateLaborRates(customerMasterReq);
                validateTravelRates(customerMasterReq);
                validateLandingCostRates(customerMasterReq);
                if(!mapOfRateDetailsFailure.isEmpty()){
                    if(mapOfRateDetailsFailure.containsKey('LaborRate:'+customerMasterReq.identifier.trim())){
                        rateDetailsErrorLst.addAll(mapOfRateDetailsFailure.get('LaborRate:'+customerMasterReq.identifier.trim()));
                    }
                    if(mapOfRateDetailsFailure.containsKey('TravelRate:'+customerMasterReq.identifier.trim())){
                        rateDetailsErrorLst.addAll(mapOfRateDetailsFailure.get('TravelRate:'+customerMasterReq.identifier.trim()));
                    }
                    if(mapOfRateDetailsFailure.containsKey('LandingCostRate:'+customerMasterReq.identifier.trim())){
                        rateDetailsErrorLst.addAll(mapOfRateDetailsFailure.get('LandingCostRate:'+customerMasterReq.identifier.trim()));
                    }
                }
            }
            if(String.isBlank(customerMasterReq.shippingStreet)){
                errorList.add('ShippingStreet can not be empty');
            }
            if(String.isBlank(customerMasterReq.shippingCity)){
                errorList.add('ShippingCity can not be empty');
            }
            if(String.isBlank(customerMasterReq.shippingState)){
                errorList.add('ShippingState can not be empty');
            }
            if(String.isBlank(customerMasterReq.shippingPostalCode)){
                errorList.add('ShippingPostalCode can not be empty');
            }
            if(String.isBlank(customerMasterReq.shippingCountry)){
                errorList.add('ShippingCountry can not be empty');
            }
            if(customerMasterReq.type != 'F' && customerMasterReq.type !='B'){
                if(String.isBlank(customerMasterReq.businessCategoryUnit)){
                    errorList.add('BusinessCategoryUnit is Mandatory');
                }else if(!(buMap.containsKey(customerMasterReq.businessCategoryUnit) || buMap.values().contains(customerMasterReq.businessCategoryUnit))){
                    errorList.add('BusinessCategoryUnit is Invalid');
                }
                if(String.isBlank(customerMasterReq.customerCurrency)){
                    errorList.add('CustomerCurrency is Mandatory');
                }else{
                    if(!mapOfCurrencyTypes.containsKey(customerMasterReq.customerCurrency)){
                         errorList.add('CustomerCurrency is invalid');
                    }
                }
                if(String.isBlank(customerMasterReq.exchangeRateType)){
                    errorList.add('ExchangeRateType can not be empty');
                }
                if(String.isBlank(customerMasterReq.adjustmentFactor)){
                    errorList.add('AdjustmentFactor can not be empty');
                }else{
                    if(Decimal.valueOf(customerMasterReq.adjustmentFactor.trim()) < 0){
                        errorList.add('AdjustmentFactor is invalid'); 
                    }
                }
                if(String.isBlank(customerMasterReq.performance)){
                    errorList.add('Performance can not be empty');
                }
                if(String.isBlank(customerMasterReq.distanceIndicator)){
                    errorList.add('DistanceIndicator can not be empty');
                }
                if(String.isBlank(customerMasterReq.rmaExempt)){
                    errorList.add('RMAExempt can not be empty');
                }
            }
            if(String.isBlank(customerMasterReq.customerGroup)){
                errorList.add('CustomerGroup is Mandatory');
            }else{
                if(customerMasterReq.customerGroup.trim() != '01' && customerMasterReq.customerGroup.trim() != '02' && customerMasterReq.customerGroup.trim() != '03' && 
                   customerMasterReq.customerGroup.trim() != '04' && customerMasterReq.customerGroup.trim() != '05' && customerMasterReq.customerGroup.trim() != '06' &&
                   customerMasterReq.customerGroup.trim() != '14' && customerMasterReq.customerGroup.trim() != '15'){
                       errorList.add('CustomerGroup is invalid');
                   }else if(String.isBlank(customerMasterReq.financialBPCode)){
                       errorList.add('FinancialBPCode is Mandatory');
                   }else if(Integer.valueOf(customerMasterReq.financialBPCode.trim()) < 0){
                       errorList.add('FinancialBPCode is invalid'); 
                   }
            }
            if(String.isBlank(customerMasterReq.accountGroup)){
                errorList.add('AccountGroup is Mandatory');
            }
            if(String.isBlank(customerMasterReq.priceGroup)){
                errorList.add('PriceGroup is Mandatory');
            }
            
            if(!String.isBlank(customerMasterReq.markUpPercent) && Decimal.valueOf(customerMasterReq.markUpPercent.trim()) < 0){
                errorList.add('MarkUpPercent is invalid');
            }
            if(!String.isBlank(customerMasterReq.activeDate) && ATI_Utils.ParseDate(customerMasterReq.activeDate.trim()) == null){
                errorList.add('Invalid ActiveDate Format');
            }
            if(!String.isBlank(customerMasterReq.inActiveDate) && ATI_Utils.ParseDate(customerMasterReq.inActiveDate.trim()) == null){
                errorList.add('Invalid InActiveDate Format');
            }
            if(errorList.isEmpty()){
                customerMasterReqLst.add(customerMasterReq);
                if(rateDetailsErrorLst.isEmpty()){
                    customerMasterReqForRateDetailsLst.add(customerMasterReq);
                }
            }else{
                mapOffailure.put(i,errorList);
            }
            if(!rateDetailsErrorLst.isEmpty()){
                if(mapOffailure.containsKey(i)){
                    mapOffailure.get(i).addAll(rateDetailsErrorLst);
                }else{
                    mapOffailure.put(i,rateDetailsErrorLst);
                }
            }
            /*if(!rateDetailsErrorLst.isEmpty() || !errorList.isEmpty()){
                setOfFailedAccounts.add(customerMasterReq.externalId);
            }*/
            i++;
        }
    }
    
    private void validateLaborRates(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.LaborRateDetails lr : customerMasterReq.laborRateDetail){
            if(!mapOfRateDetailsFailure.containsKey('LaborRate:'+customerMasterReq.identifier.trim())){
                List<String> errorLst = new List<String>();
                if(String.isBlank(lr.laborRate)){
                    errorLst.add('LaborRate is Mandatory');
                }else{
                    if(Decimal.valueOf(lr.laborRate.trim()) < 0){
                        errorLst.add('LaborRate is invalid');
                    }else{
                        if(Decimal.valueOf(lr.laborRate.trim()) != 0){
                            if(String.isBlank(lr.activeFrom)){
                                errorLst.add('ActiveFrom can not be empty for laborRate');
                            }else{
                                if(ATI_Utils.parseDate(lr.activeFrom.trim()) == null){
                                    errorLst.add('Invalid ActiveFrom Date Format');
                                }
                                if(!mapOfLaborRates.isEmpty() && ATI_Utils.parseDate(lr.activeFrom.trim()) != null && mapOfLaborRates.containsKey(customerMasterReq.externalId.trim())){
                                    if(ATI_Utils.parseDate(lr.activeFrom.trim()) < mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c){
                                        //added by Dishari on 11/11/21 for 29219
                                        //errorLst.add(String.valueOf(ATI_Utils.parseDate(lr.activeFrom.trim()))+'(LaborRate ActiveFrom) should be greater than or equals to '+String.valueOf(mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c));
                                         mapOfRateDetailsFailure.put('LaborRate:'+mapOfLaborRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c,errorLst);
                                    }
                                }
                            }
                        }
                    }
                }
                if(!errorLst.isEmpty()){
                    mapOfRateDetailsFailure.put('LaborRate:'+customerMasterReq.identifier.trim(),errorLst);
                }  
            }
        }
    }
    
    private void validateTravelRates(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.DistanceRateDetails distanceRate : customerMasterReq.distanceRateDetails){
            for(ATI_REST_CustomerMasterRequest.DistanceRateDetailInfo tr : distanceRate.distanceRateDetail){
                if(!mapOfRateDetailsFailure.containsKey('TravelRate:'+customerMasterReq.identifier.trim())){
                    List<String> errorLst = new List<String>();
                    if(String.isBlank(tr.distanceRate)){
                        errorLst.add('DistanceRate is Mandatory');
                    }else{
                        if(Decimal.valueOf(tr.distanceRate.trim()) < 0){
                            errorLst.add('DistanceRate is invalid');
                        }else{
                            if(Decimal.valueOf(tr.distanceRate.trim()) != 0){
                                if(String.isBlank(tr.activeFrom)){
                                    errorLst.add('ActiveFrom can not be empty for distanceRate');
                                }else{
                                    if(ATI_Utils.parseDate(tr.activeFrom.trim()) == null){
                                        errorLst.add('Invalid ActiveFrom Date Format');
                                    }
                                    if(!mapOfTravelRates.isEmpty() && ATI_Utils.parseDate(tr.activeFrom.trim()) != null && mapOfTravelRates.containsKey(customerMasterReq.externalId.trim())){
                                        if(ATI_Utils.parseDate(tr.activeFrom.trim()) < mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c){
                                            //added by Dishari on 11/11/21 for 29219
                                            //errorLst.add(String.valueOf(ATI_Utils.parseDate(tr.activeFrom.trim()))+'(DistanceRate ActiveFrom) should be greater than or equals to '+String.valueOf(mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c));
                                            mapOfRateDetailsFailure.put('TravelRate:'+mapOfTravelRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c,errorLst);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(!String.isBlank(distanceRate.distancePerHour) && (Decimal.valueOf(distanceRate.distancePerHour.trim()) < 0 || distanceRate.distancePerHour.trim().contains('.') || Decimal.valueOf(distanceRate.distancePerHour.trim().length()) > 3)){
                        errorLst.add('DistancePerHour is invalid');
                    }
                    
                    if(!String.isBlank(distanceRate.maxTravelDist) && (Decimal.valueOf(distanceRate.maxTravelDist.trim()) < 0 || distanceRate.maxTravelDist.trim().contains('.') || Decimal.valueOf(distanceRate.maxTravelDist.trim().length()) > 5)){
                        errorLst.add('MaxTravelDist is invalid');
                    }
                    
                    if(!errorLst.isEmpty()){
                        mapOfRateDetailsFailure.put('TravelRate:'+customerMasterReq.identifier.trim(),errorLst);
                    }
                }            
            }
        }
    }
    
    private void validateLandingCostRates(ATI_REST_CustomerMasterRequest.CustomerInformation customerMasterReq){
        for(ATI_REST_CustomerMasterRequest.LandingCostMarkupDetails landingCostRate : customerMasterReq.landingCostMarkupDetails){
            for(ATI_REST_CustomerMasterRequest.LandingCostDetails lcr : landingCostRate.landingCostDetail){
                if(!mapOfRateDetailsFailure.containsKey('LandingCostRate:'+customerMasterReq.identifier.trim())){
                    List<String> errorLst = new List<String>();
                    if(String.isBlank(lcr.landingCostRate)){
                        errorLst.add('LandingCostRate is Mandatory');
                    }else{
                        if(Decimal.valueOf(lcr.landingCostRate.trim()) < 0){
                            errorLst.add('LandingCostRate is invalid');
                        }else{
                            if(Decimal.valueOf(lcr.landingCostRate.trim()) != 0){
                                if(String.isBlank(lcr.activeFrom)){
                                    errorLst.add('ActiveFrom cannot be empty for landingCostRate');
                                }else{
                                    if(ATI_Utils.parseDate(lcr.activeFrom.trim()) == null){
                                        errorLst.add('Invalid ActiveFrom Date Format');
                                    }
                                    if(!mapOfLandingCostRates.isEmpty() && ATI_Utils.parseDate(lcr.activeFrom.trim()) != null && mapOfLandingCostRates.containsKey(customerMasterReq.externalId.trim())){
                                        if(ATI_Utils.parseDate(lcr.activeFrom.trim()) < mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c){
                                            //added by Dishari on 11/11/21 for 29219
                                            //errorLst.add(String.valueOf(ATI_Utils.parseDate(lcr.activeFrom.trim()))+'(LandingCostRate ActiveFrom) should be greater than or equals to '+String.valueOf(mapOfLandingCostRates.get(customerMasterReq.externalId.trim()).WOD_2__Active_From__c));
                                             mapOfRateDetailsFailure.put('LandingCostRate:'+mapOfLandingCostRates.get(customerMasterReq.externalId.trim()),errorLst);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(!errorLst.isEmpty()){
                        mapOfRateDetailsFailure.put('LandingCostRate:'+customerMasterReq.identifier.trim(),errorLst);
                    }
                }
            }
        }
    }
    
    private Boolean checkReadAccess(){
        String accountSObjName = 'Account';
        List<String> accountFields = new List<String>{'Name','SAP_ID__c','Parent.SAP_ID__c','ParentId','WOD_2__Warranty_Account_Type__c','ATI_Currency__c'};
            String rateDetailSObjName = 'WOD_2__Rates_Details__c';
        List<String> rateDetailFields = new List<String>{'WOD_2__Active_From__c','WOD_2__Active_Until__c','RecordType.DeveloperName'};
            ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
        ATI_Utils.NoAccessObjectFieldWrapper rateDetailNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(rateDetailSObjName,rateDetailFields);
        if(acountNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && acountNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 && rateDetailNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && rateDetailNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient Account Read Access>> '+JSON.serialize(acountNoAccessObjectFieldWrapper)+'Insufficient RateDetail Read Access>> '+JSON.serialize(rateDetailNoAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('CustomerMasterSync',errortext);
            return false;
        }
    }   
}