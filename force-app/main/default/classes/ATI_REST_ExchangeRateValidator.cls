/* Name: ATI_REST_ExchangeRateValidator
Description : This Class is used to validate ExchangeRate JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      27/11/2020        INITIAL DEVELOPMENT             20656                  
*/
public with sharing class ATI_REST_ExchangeRateValidator {
    public List<ATI_REST_ExchangeRateRequest.ExchangeRate> exchangeRateReqLst{get; private set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Map<String,CurrencyType> mapOfCurrencyTypes{get; private set;}
    public Set<String> setOfRateTypes{get; private set;}
    public Set<String> setOfFromCurrencies{get; private set;}
    public Set<String> setOfToCurrencies{get; private set;}
    public Set<String> setOfFailedExchangeRates{get; private set;}
    public Set<String> setOfSuccessExchangeRates{get; private set;}
    public Map<String,ATI_Exchange_Rate__c> mapOfExchangeRates{get; private set;}
    public Map<String,ATI_Exchange_Rate__c> mapOfUniqueExchangeRates{get; private set;}
    public Integer totalrecords{get; private set;}
    public Integer totalFailedRecords{get; private set;}
    public ATI_REST_ExchangeRateValidator(){
        exchangeRateReqLst = new List<ATI_REST_ExchangeRateRequest.ExchangeRate>();
        mapOfFailure = new Map<Integer,List<String>>();
        mapOfCurrencyTypes = new Map<String,CurrencyType>();
        setOfRateTypes = new Set<String>();
        setOfFromCurrencies = new Set<String>();
        setOfToCurrencies = new Set<String>();
        mapOfExchangeRates = new Map<String,ATI_Exchange_Rate__c>();
        mapOfUniqueExchangeRates = new Map<String,ATI_Exchange_Rate__c>();
        setOfFailedExchangeRates = new Set<String>();
        setOfSuccessExchangeRates = new Set<String>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    public void validateReqest(ATI_REST_ExchangeRateRequest exchangeRateRequestBody){
        queryExchangeRateData(exchangeRateRequestBody);
        verifyExchangeRateRequest(exchangeRateRequestBody);
    }
    
    private void queryExchangeRateData(ATI_REST_ExchangeRateRequest exchangeRateRequestBody){
        for(ATI_REST_ExchangeRateRequest.ExchangeRate exchangeRateReq : exchangeRateRequestBody.exchangeRate){
            if(!String.isBlank(exchangeRateReq.rateType)){
                setOfRateTypes.add(exchangeRateReq.rateType.trim());
            }
            if(!String.isBlank(exchangeRateReq.fromCurrency)){
                setOfFromCurrencies.add(exchangeRateReq.fromCurrency.trim());
            }
             if(!String.isBlank(exchangeRateReq.toCurrency)){
                setOfToCurrencies.add(exchangeRateReq.toCurrency.trim());
            }
        }
        Set<String> setOfCurrencies = new Set<String>();
        setOfCurrencies.addAll(setOfFromCurrencies);
        setOfCurrencies.addAll(setOfToCurrencies);
        mapOfCurrencyTypes = ATI_Utils.getGlobalCurrencies(setOfCurrencies);
        if(checkReadAccess()){
            List<ATI_Exchange_Rate__c> exchangeRateLst = [SELECT Id,EffectiveDate__c,Name,EndDate__c,RateType__c,FromCurrency__c,ToCurrency__c FROM ATI_Exchange_Rate__c WHERE RateType__c IN:setOfRateTypes AND FromCurrency__c IN:setOfFromCurrencies 
                                                      AND ToCurrency__c IN:setOfToCurrencies ORDER By EffectiveDate__c DESC];
            for(ATI_Exchange_Rate__c exchangeRate :exchangeRateLst){
                String uniqueExchangeRate = exchangeRate.RateType__c.toUpperCase()+':'+exchangeRate.FromCurrency__c.toUpperCase()+':'+exchangeRate.ToCurrency__c.toUpperCase();
                if(!mapOfExchangeRates.containsKey(uniqueExchangeRate)){
                    mapOfExchangeRates.put(uniqueExchangeRate,exchangeRate);
                }
                mapOfUniqueExchangeRates.put(uniqueExchangeRate+':'+String.valueOf(exchangeRate.EffectiveDate__c),exchangeRate);
            }
        }else{
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
        }
    }
    
    private void verifyExchangeRateRequest(ATI_REST_ExchangeRateRequest exchangeRateRequestBody){
        Integer  i = 1;
        set<String> identifierSet = new set<String>();
        for(ATI_REST_ExchangeRateRequest.ExchangeRate exchangeRateReq : exchangeRateRequestBody.exchangeRate){
            List<String> errorList = new List<String>();
            String uniqueExchangeRate = '';
            if(String.isBlank(exchangeRateReq.identifier)){
                errorList.add('Identifier is Mandatory');
            }
            else if(!identifierSet.add(exchangeRateReq.identifier.trim())){
                errorList.add('Identifier is not unique');
            }
            if(String.isBlank(exchangeRateReq.rateType)){
                errorList.add('RateType is Mandatory');
            }else{
                uniqueExchangeRate = exchangeRateReq.rateType.trim();
            }
            if(String.isBlank(exchangeRateReq.effectiveDate)){
                errorList.add('EffectiveDate can not be empty');
            }else{
                if(uniqueExchangeRate != ''){
                    uniqueExchangeRate += ';'+exchangeRateReq.effectiveDate.trim();
                }else{
                    uniqueExchangeRate = exchangeRateReq.effectiveDate.trim();
                }
                if(ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()) == null){
                    errorList.add('Invalid EffectiveDate Format');
                }
            }
            if(String.isBlank(exchangeRateReq.fromCurrency)){
                errorList.add('FromCurrency is Mandatory');
            }else{
                if(uniqueExchangeRate != ''){
                    uniqueExchangeRate += ';'+exchangeRateReq.fromCurrency.trim();
                }else{
                    uniqueExchangeRate = exchangeRateReq.fromCurrency.trim();
                }
                if(!mapOfCurrencyTypes.containsKey(exchangeRateReq.fromCurrency.trim())){
                    errorList.add('FromCurrency is invalid');
                }
            }
            if(String.isBlank(exchangeRateReq.toCurrency)){
                errorList.add('ToCurrency is Mandatory');
            }else{
                if(uniqueExchangeRate != ''){
                    uniqueExchangeRate += ';'+exchangeRateReq.toCurrency.trim();
                }else{
                    uniqueExchangeRate = exchangeRateReq.toCurrency.trim();
                }
                if(!mapOfCurrencyTypes.containsKey(exchangeRateReq.toCurrency.trim())){
                    errorList.add('ToCurrency is invalid');
                }
            }
            
            if(!String.isBlank(exchangeRateReq.fromCurrency) && !String.isBlank(exchangeRateReq.fromCurrency)){
                if(mapOfCurrencyTypes.containsKey(exchangeRateReq.fromCurrency.trim()) && mapOfCurrencyTypes.containsKey(exchangeRateReq.toCurrency.trim()) && exchangeRateReq.fromCurrency.trim() == exchangeRateReq.toCurrency.trim()){
                    errorList.add('FromCurrency and ToCurrency can not be same');
                }
            }
            
            if(String.isBlank(exchangeRateReq.rate)){
                errorList.add('Rate is Mandatory');
            }
            if(String.isBlank(exchangeRateReq.ratio)){
                errorList.add('Ratio can not be empty');
            }else{
                if(Integer.valueOf(exchangeRateReq.ratio.trim()) < 0){
                 	errorList.add('Ratio is invalid');   
                }
            }
            
            if(errorList.isEmpty()){
                String exchangeRateKey = exchangeRateReq.rateType.trim().toUpperCase()+':'+exchangeRateReq.fromCurrency.trim().toUpperCase()+':'+exchangeRateReq.toCurrency.trim().toUpperCase();
				if(mapOfExchangeRates.containsKey(exchangeRateKey)){
                    Date effectiveDate = mapOfExchangeRates.get(exchangeRateKey).EffectiveDate__c;
                    if(ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()) < effectiveDate && !mapOfUniqueExchangeRates.containsKey(exchangeRateKey+':'+String.valueOf(exchangeRateReq.effectiveDate.trim()))){
                        errorList.add('Please provide valid ExchangeRate details');
                    }
                }
            }
            
            if(errorList.isEmpty()){
                exchangeRateReqLst.add(exchangeRateReq);
                setOfSuccessExchangeRates.add(uniqueExchangeRate);
            }else{
                totalFailedRecords++;
                mapOfFailure.put(i,errorList);
                setOfFailedExchangeRates.add(uniqueExchangeRate);
            }
            i++;
        }
        totalrecords = i-1;
    }
    
    public static Boolean checkReadAccess(){
        String objectName = 'ATI_Exchange_Rate__c';
        List<String> fields = new List<String>{'Name','EffectiveDate__c','EndDate__c','RateType__c','FromCurrency__c','ToCurrency__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient ExchangeRate Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('ExchangeRateSync',errortext);
            return false;
        }
    }
}