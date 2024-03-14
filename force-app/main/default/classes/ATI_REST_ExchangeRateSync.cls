/* Name: ATI_REST_ExchangeRateSync
Description : Endpoint which syncs exchange rates required for warranty purposes 
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL                  UserStory/Req#
1.0 -     Tavant(TY)       27/11/2020      INITIAL DEVELOPMENT             20656                 
*/
@RestResource(urlMapping = '/ATIRestExchangeRateSync/*')
global with sharing class ATI_REST_ExchangeRateSync implements ATI_LoggableInterface{
    
    @HttpPost
    global Static ATI_REST_ExchangeRateSyncResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        ATI_REST_ExchangeRateSync exchangeRateSyncObj = new ATI_REST_ExchangeRateSync();
        ATI_REST_ExchangeRateSyncResponse exchangeRateResponse = exchangeRateSyncObj.exchangeRate(requestBody);
        return exchangeRateResponse;
    }
    
    public ATI_REST_ExchangeRateSyncResponse exchangeRate(String exchangeRateRequest){
        ATI_REST_ExchangeRateSyncResponse exchangeRateResponse = new ATI_REST_ExchangeRateSyncResponse();
        WOD_2.ResponseWrapper response = processType(exchangeRateRequest);
        if(response != null && response.data != null && response.data != '') {
            exchangeRateResponse = (ATI_REST_ExchangeRateSyncResponse)Json.deserialize(response.data,ATI_REST_ExchangeRateSyncResponse.class);
        }else {
            exchangeRateResponse.status = 'Fail';
            exchangeRateResponse.data = null;
            exchangeRateResponse.interfaceName = 'I-201 – Exchange Rate';
            exchangeRateResponse.message = response.errormessage;
            createLog('ExchangeRateSync',exchangeRateRequest,JSON.serialize(exchangeRateResponse),'Failed',null,null);
        }
        return exchangeRateResponse;   
    }
    
    private ATI_REST_ExchangeRateValidator exchangeRateValidatorObj{get; private set;}
    private List<ATI_Exchange_Rate__c> exchangeRateInsertOrUpdateLst{get; private set;}
    private Map<String,ATI_Exchange_Rate__c> mapOfInsertedExchangeRates{get; private set;}
    private Map<String,ATI_Exchange_Rate__c> mapOfExchangeRates{get; private set;}
    private Set<String> setOfInsertedFromCurrencies{get; private set;}
    private Set<String> setOfInsertedToCurrencies{get; private set;}
    private Set<String> setOfInsertedRateTypes{get; private set;}
    private Set<Date> setOfInsertedEffectiveDates{get; private set;}
    private Set<ATI_Exchange_Rate__c> exchangeRateUpdateLstEndDate{get; private set;}
    public WOD_2.ResponseWrapper processType(String exchangeRateRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        ATI_REST_ExchangeRateRequest exchangeRateReqObj = new ATI_REST_ExchangeRateRequest();
        exchangeRateValidatorObj = new ATI_REST_ExchangeRateValidator();
        try{
            exchangeRateReqObj = ATI_REST_ExchangeRateRequest.parse(exchangeRateRequest);
            exchangeRateValidatorObj.validateReqest(exchangeRateReqObj);
            exchangeRateInsertOrUpdateLst = new List<ATI_Exchange_Rate__c>();
            mapOfInsertedExchangeRates = new Map<String,ATI_Exchange_Rate__c>();
            mapOfExchangeRates = new Map<String,ATI_Exchange_Rate__c>();
            setOfInsertedFromCurrencies = new Set<String>();
            setOfInsertedToCurrencies = new Set<String>();
            setOfInsertedRateTypes = new Set<String>();
            setOfInsertedEffectiveDates = new Set<Date>();
            exchangeRateUpdateLstEndDate = new Set<ATI_Exchange_Rate__c>();
            for(ATI_REST_ExchangeRateRequest.ExchangeRate exchangeRateReq : exchangeRateValidatorObj.exchangeRateReqLst){
                String uniqueExchangeRate = exchangeRateReq.rateType.trim().toUppercase()+':'+exchangeRateReq.fromCurrency.trim().toUppercase()+':'+exchangeRateReq.toCurrency.trim().toUppercase();
                System.debug('UniqueExchangeRate @@@@ '+uniqueExchangeRate);
                if((exchangeRateValidatorObj.mapOfExchangeRates.containsKey(uniqueExchangeRate) && ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()) > exchangeRateValidatorObj.mapOfExchangeRates.get(uniqueExchangeRate).EffectiveDate__c) ||
                   !exchangeRateValidatorObj.mapOfExchangeRates.containsKey(uniqueExchangeRate)){
                       ATI_Exchange_Rate__c newExchangeRateObj = new ATI_Exchange_Rate__c();
                       newExchangeRateObj.RateType__c = exchangeRateReq.rateType;
                       newExchangeRateObj.FromCurrency__c = exchangeRateReq.fromCurrency;
                       newExchangeRateObj.ToCurrency__c = exchangeRateReq.toCurrency;
                       newExchangeRateObj.EffectiveDate__c = ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim());
                       newExchangeRateObj.Rate__c = Decimal.valueOf(exchangeRateReq.rate);
                       newExchangeRateObj.Ratio__c = Decimal.valueOf(exchangeRateReq.ratio);
                       Date effectiveDate = ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim());
                       if(exchangeRateValidatorObj.mapOfExchangeRates.ContainsKey(uniqueExchangeRate)){
                           
                           //Added By Anjali
                           ATI_Exchange_Rate__c exchangeRateupdate = exchangeRateValidatorObj.mapOfExchangeRates.get(uniqueExchangeRate);
                           exchangeRateUpdateLstEndDate.add(exchangeRateupdate);
                           newExchangeRateObj.EndDate__c = ATI_Utils.parseDate('2099-12-31');
                           mapOfInsertedExchangeRates.put(uniqueExchangeRate+'_'+String.valueOf(effectiveDate),newExchangeRateObj);
                           
                       }
                       else{
                           newExchangeRateObj.EndDate__c = ATI_Utils.parseDate('2099-12-31');
                           mapOfInsertedExchangeRates.put(uniqueExchangeRate+'_'+String.valueOf(effectiveDate),newExchangeRateObj);
                       }
                       setOfInsertedFromCurrencies.add(exchangeRateReq.fromCurrency.trim());
                       setOfInsertedToCurrencies.add(exchangeRateReq.toCurrency.trim());
                       setOfInsertedRateTypes.add(exchangeRateReq.rateType.trim());
                       setOfInsertedEffectiveDates.add(effectiveDate);
                   }
                if(exchangeRateValidatorObj.mapOfExchangeRates.containsKey(uniqueExchangeRate) &&
                   ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()) >= exchangeRateValidatorObj.mapOfExchangeRates.get(uniqueExchangeRate).EffectiveDate__c){
                       ATI_Exchange_Rate__c exchangeRateObj = exchangeRateValidatorObj.mapOfExchangeRates.get(uniqueExchangeRate);
                       
                       if(ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()) == exchangeRateObj.EffectiveDate__c){
                           exchangeRateObj.Rate__c = Decimal.valueOf(exchangeRateReq.rate);
                           exchangeRateObj.Ratio__c = Decimal.valueOf(exchangeRateReq.ratio);
                       }
                       exchangeRateInsertOrUpdateLst.add(exchangeRateObj);
                   } 
                if(exchangeRateValidatorObj.mapOfUniqueExchangeRates.containsKey(uniqueExchangeRate+':'+String.valueOf(exchangeRateReq.effectiveDate.trim()))){
                    ATI_Exchange_Rate__c exchangeRateObj = exchangeRateValidatorObj.mapOfUniqueExchangeRates.get(uniqueExchangeRate+':'+String.valueOf(exchangeRateReq.effectiveDate.trim()));
                    exchangeRateObj.Rate__c = Decimal.valueOf(exchangeRateReq.rate);
                    exchangeRateObj.Ratio__c = Decimal.valueOf(exchangeRateReq.ratio);
                    exchangeRateInsertOrUpdateLst.add(exchangeRateObj);
                }
            }
            
            //Added by Anjali for Exchange Rate Integration to update the existing data End Date
            if(!exchangeRateUpdateLstEndDate.isEmpty()){
                List<String> exchangeRateLst = new List<String>();
                List<ATI_Exchange_Rate__c> exchangeRateLstupdate = new List<ATI_Exchange_Rate__c>();
                Map<String,String> mp = new Map<String,String>();
                exchangeRateLst.addAll(mapOfInsertedExchangeRates.keySet());
                exchangeRateLst.sort();
                List<String> reversed = new List<String>();
                
                for(Integer i = exchangeRateLst.size()- 1; i>= 0; i--){
                    reversed.add(exchangeRateLst[i]);
                }
                for(Integer i=0; i<reversed.size();i++){
                    List<String> reverseString = reversed[i].split('_');
                    mp.put(reverseString[0], reverseString[1]);
                }
                for(ATI_Exchange_Rate__c axr : exchangeRateUpdateLstEndDate){
                    String uniqueRate = axr.RateType__c.trim().toUppercase()+':'+axr.FromCurrency__c.trim().toUppercase()+':'+axr.ToCurrency__c.trim().toUppercase();
                    
                    if(mp.containsKey(uniqueRate)){
                        axr.EndDate__c = Date.valueOf(mp.get(uniqueRate))-1;
                        exchangeRateLstupdate.add(axr);
                    }
                }
                if(!exchangeRateLstupdate.isEmpty()){
                    update exchangeRateLstupdate;
                }
            }
            //End of Modification
            
            createOrUpdateExchangeRates();
            responseWrapper.data = JSON.serialize(createResponse(exchangeRateReqObj.exchangeRate));
            responseWrapper.status = true;
        }catch(Exception e){
            system.debug('message'+ e.getMessage());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString() ;
        }
        return responseWrapper;
    }
    
    private static List<ATI_Exchange_Rate__c> removeDuplicates(List<ATI_Exchange_Rate__c> exchangeRateLst){
        return new List<ATI_Exchange_Rate__c>(new Set<ATI_Exchange_Rate__c>(exchangeRateLst));
    }
    
    private void createOrUpdateExchangeRates(){
        //Yamini Added
        /* if(!mapOfInsertedExchangeRates.isEmpty()){
List<String> exchangeRateLst = new List<String>();
exchangeRateLst.addAll(mapOfInsertedExchangeRates.keySet());
exchangeRateLst.sort();
Integer i = 0;
While(i<exchangeRateLst.size()-1){
List<String> uniqueExchangeRate = exchangeRateLst[i].split(':');
List<String> nextUniqueExchangeRate = exchangeRateLst[i+1].split(':');
if(uniqueExchangeRate[0] == nextUniqueExchangeRate[0]){
ATI_Exchange_Rate__c exchangeRate = mapOfInsertedExchangeRates.get(exchangeRateLst[i]);
ATI_Exchange_Rate__c nextExchangeRate = mapOfInsertedExchangeRates.get(exchangeRateLst[i+1]);
exchangeRate.EndDate__c = nextExchangeRate.EffectiveDate__c.addDays(-1);
exchangeRateInsertOrUpdateLst.add(exchangeRate);
}else{
exchangeRateInsertOrUpdateLst.add(mapOfInsertedExchangeRates.get(exchangeRateLst[i]));
}
i++;
}
exchangeRateInsertOrUpdateLst.add(mapOfInsertedExchangeRates.get(exchangeRateLst[i]));
} */
        
        //Anjali Added
        if(!mapOfInsertedExchangeRates.isEmpty()){
            Map <string,List<Date>> mpCurrencyDate = new Map <string,List<Date>>();
            List<String> exchangeRateLst = new List<String>();
            List<Date> exchangeEffectiveDate = new List<Date>();
            exchangeRateLst.addAll(mapOfInsertedExchangeRates.keySet());
            exchangeRateLst.sort();
            Integer i = 0;
            
            for(i=0; i<exchangeRateLst.size();i++){
                List<String> uniqueExchangeRate = exchangeRateLst[i].split('_');
                if(!mpCurrencyDate.containsKey(uniqueExchangeRate[0])){
                    mpCurrencyDate.put(uniqueExchangeRate[0],new List<Date>{Date.valueOf(uniqueExchangeRate[1])});
                }else{
                    mpCurrencyDate.get(uniqueExchangeRate[0]).add(Date.valueOf(uniqueExchangeRate[1]));
                }
            }
            for(String uniqueKey : mpCurrencyDate.keyset()){
                List<Date> dt = mpCurrencyDate.get(uniqueKey);
                for(Integer j=0; j<dt.size();j++){
                    ATI_Exchange_Rate__c exchangeRate = mapOfInsertedExchangeRates.get(uniqueKey+'_'+String.valueOf(dt[j]));
                    
                    if(j<dt.size()-1){
                        exchangeRate.EndDate__c = dt[j+1]-1;
                    }
                    if(dt.size()-1 == j){
                        exchangeRate.EndDate__c = ATI_Utils.parseDate('2099-12-31');
                    }
                    exchangeRateInsertOrUpdateLst.add(exchangeRate);
                }
            }
        }
        //end of modification
        
        if(!exchangeRateInsertOrUpdateLst.isEmpty()){ 
            List<ATI_Exchange_Rate__c> exchangeRateLst = removeDuplicates(exchangeRateInsertOrUpdateLst);
            exchangeRateInsertOrUpdateLst.clear();
            exchangeRateInsertOrUpdateLst.addAll(exchangeRateLst);
            String objectName = 'ATI_Exchange_Rate__c';
            List<String> fields = new List<String>{'RateType__c','EffectiveDate__c','EndDate__c','FromCurrency__c','ToCurrency__c','Rate__c','Ratio__c'};
                ATI_Utils.NoAccessObjectFieldWrapper exchangeRateCreateAccessCheck = ATI_Utils.fetchCreateAccess(objectName,fields);
            ATI_Utils.NoAccessObjectFieldWrapper exchangeRateUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,fields);
            if(exchangeRateCreateAccessCheck.noAccessObjectList.size() == 0 && exchangeRateCreateAccessCheck.noAccessFieldList.size() == 0 && exchangeRateUpdateAccessCheck.noAccessObjectList.size() == 0 && exchangeRateUpdateAccessCheck.noAccessFieldList.size() == 0){
                upsert exchangeRateInsertOrUpdateLst;
                fetchExchangeRates();
            } else {
                String errortext = 'Insufficient ExchangeRate Create Access>> '+JSON.serialize(exchangeRateCreateAccessCheck)+'Insufficient ExchangeRate Update Access>> '+JSON.serialize(exchangeRateUpdateAccessCheck);
                ATI_LogService.createLogForAccess('ExchangeRateSync',errortext);
                throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            }
        }
    }
    
    private void fetchExchangeRates(){
        if(ATI_REST_ExchangeRateValidator.checkReadAccess()){
            List<ATI_Exchange_Rate__c> exchangeRateLst = [SELECT Id,Name,RateType__c,FromCurrency__c,ToCurrency__c,EffectiveDate__c FROM ATI_Exchange_Rate__c WHERE FromCurrency__c IN:setOfInsertedFromCurrencies AND
                                                          ToCurrency__c IN:setOfInsertedToCurrencies AND RateType__c IN:setOfInsertedRateTypes AND EffectiveDate__c IN:setOfInsertedEffectiveDates];
            if(!exchangeRateLst.isEmpty()){
                for(ATI_Exchange_Rate__c exchangeRate : exchangeRateLst){
                    String uniqueExchangeRate = exchangeRate.RateType__c.toUppercase()+':'+exchangeRate.FromCurrency__c.toUppercase()+':'+exchangeRate.ToCurrency__c.toUppercase()+':'+ String.valueOf(exchangeRate.EffectiveDate__c);
                    mapOfExchangeRates.put(uniqueExchangeRate,exchangeRate);
                }
            }
        }else{
            throw new ATI_Exception(Label.ATI_Log_Insufficient_access); 
        }
    }
    
    private ATI_REST_ExchangeRateSyncResponse createResponse(List<ATI_REST_ExchangeRateRequest.ExchangeRate> exchangeRateRequest){
        ATI_REST_ExchangeRateSyncResponse exchangeRateResponse = new ATI_REST_ExchangeRateSyncResponse();
        List<ResponseData> responseDataLst = new List<ResponseData>();
        Integer i = 1;
        for(ATI_REST_ExchangeRateRequest.ExchangeRate exchangeRateReq : exchangeRateRequest){
            ResponseData data = new ResponseData();
            data.identifier = exchangeRateReq.identifier;
            String effectiveDate = String.valueOf(ATI_Utils.parseDate(exchangeRateReq.effectiveDate.trim()));
            String uniqueExchangeRate = exchangeRateReq.rateType.trim().toUppercase()+':'+exchangeRateReq.fromCurrency.trim().toUppercase()+':'+exchangeRateReq.toCurrency.trim().toUppercase();
            if(exchangeRateValidatorObj.mapOfFailure.containsKey(i)){
                data.message = String.Join(exchangeRateValidatorObj.mapOfFailure.get(i),', ') ;
            }else{
                if(mapOfExchangeRates.containsKey(uniqueExchangeRate+':'+effectiveDate) && 
                   !exchangeRateValidatorObj.mapOfUniqueExchangeRates.containsKey(uniqueExchangeRate+':'+effectiveDate)){
                       data.message = 'Record Inserted Successfully';
                       data.transactionId = mapOfExchangeRates.get(uniqueExchangeRate+':'+effectiveDate).Id;
                       data.name = mapOfExchangeRates.get(uniqueExchangeRate+':'+effectiveDate).Name;
                   }else{
                       data.message = 'Record Updated Successfully';
                       data.transactionId = exchangeRateValidatorObj.mapOfUniqueExchangeRates.get(uniqueExchangeRate+':'+effectiveDate).Id;
                       data.name =  exchangeRateValidatorObj.mapOfUniqueExchangeRates.get(uniqueExchangeRate+':'+effectiveDate).Name;
                   }
            }
            responseDataLst.add(data);
            i++;
        }
        exchangeRateResponse.interfaceName = 'I-201 – Exchange Rate';
        exchangeRateResponse.data = responseDataLst;
        if(exchangeRateValidatorObj.mapOfFailure.isEmpty()){
            exchangeRateResponse.status = 'Success';
            exchangeRateResponse.message =  'All the records have been inserted / updated successfully';
            createLog('ExchangeRateSync',JSON.serialize(exchangeRateRequest),JSON.serialize(exchangeRateResponse),'Success',null,JSON.serialize(exchangeRateValidatorObj.setOfSuccessExchangeRates));
        }else if(exchangeRateValidatorObj.mapOfFailure.size() ==  exchangeRateRequest.size()){
            exchangeRateResponse.status = 'Failed';
            exchangeRateResponse.message = 'All the records have failed to insert / update';
            createLog('ExchangeRateSync',JSON.serialize(exchangeRateRequest),JSON.serialize(exchangeRateResponse),'Failed',JSON.serialize(exchangeRateValidatorObj.setOfFailedExchangeRates),JSON.serialize(exchangeRateValidatorObj.setOfFailedExchangeRates));
        }else{
            exchangeRateResponse.status = 'Partial Success';
            exchangeRateResponse.message =  'Few records have not been inserted / updated.';
            createLog('ExchangeRateSync',JSON.serialize(exchangeRateRequest),JSON.serialize(exchangeRateResponse),'Partial Success',JSON.serialize(exchangeRateValidatorObj.setOfFailedExchangeRates),'Success>> '+JSON.serialize(exchangeRateValidatorObj.setOfSuccessExchangeRates)+',Failure>> '+JSON.serialize(exchangeRateValidatorObj.setOfFailedExchangeRates));
        }
        return exchangeRateResponse;
    }
    
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_ExchangeRate_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(!exchangeRateValidatorObj.mapOfFailure.isEmpty()){
                objLogSerWrp.errortext = JSON.serialize(exchangeRateValidatorObj.mapOfFailure.values());
                objLogSerWrp.successRecordCount = exchangeRateValidatorObj.totalRecords-exchangeRateValidatorObj.totalFailedRecords;
                objLogSerWrp.failureRecordCount = exchangeRateValidatorObj.totalFailedRecords;
            }
            if(identifier == null){
                if(status != 'Success'){
                    ATI_REST_ExchangeRateSyncResponse responseWrapperObj = (ATI_REST_ExchangeRateSyncResponse)System.JSON.deserialize(response,ATI_REST_ExchangeRateSyncResponse.class);
                    objLogSerWrp.errortext = responseWrapperObj.message;
                    objLogSerWrp.successRecordCount = 0;
                    objLogSerWrp.failureRecordCount = exchangeRateValidatorObj.totalRecords;
                }else{
                    objLogSerWrp.successRecordCount = exchangeRateValidatorObj.totalRecords;
                    objLogSerWrp.failureRecordCount = 0;
                }
            }
            objLogSerWrp.totalRecordCount = exchangeRateValidatorObj.totalRecords;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
Description    :   A wrapper class to capture the ExchangeRate Rest data.
*************************************************************************/
    global class ATI_REST_ExchangeRateSyncResponse{
        global String status;
        global String message;
        global String interfaceName;
        global List<ResponseData> data;
    }
    global class ResponseData{
        global String name;
        global String transactionId;
        global String message;
        global String identifier;
    }
}