/* Name: ATI_CLM_RatesOverride
Description : ATI_CLM_RatesOverride - Rates override class for picking up correct rates for ATI
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      25-APR-2021          INITIAL DEVELOPMENT
*/
global class ATI_CLM_RatesOverride implements WOD_2.CLM_RatesOverrideInterface{

    global List<WOD_2.CLM_RatesOverrideOutputWrapper> getRates(List<WOD_2.CLM_RatesOverrideInputWrapper> inputWrapList){
        // since ATI is multicurrency enabled implementation not checking for it 
        //Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        System.debug('inputWrapList--------------->'+inputWrapList);
        List<WOD_2.CLM_RatesOverrideOutputWrapper> outputWrapList = new List<WOD_2.CLM_RatesOverrideOutputWrapper>();
        if(inputWrapList != null && !inputWrapList.isEmpty()){
            try{
                Set<Id> claimIdSet = new Set<Id>();
                for(WOD_2.CLM_RatesOverrideInputWrapper iw : inputWrapList){
                    claimIdSet.add(iw.claimId);			            
                }
                Set<Id> accountIdSet = new Set<Id>();
                List<String> claimFields = new List<String>{'WOD_2__Date_Of_Repair__c','WOD_2__Date_Of_Failure__c',
                    'WOD_2__BusinessCategory__c', 'WOD_2__Account__c','CurrencyIsoCode','WOD_2__Claim_Type__c'}; 
                ATI_Utils.checkForAccess('WOD_2__Claim__c', 'READ', claimFields);
                Map<Id, WOD_2__Claim__c> claimsMap = new Map<Id, WOD_2__Claim__c>(
                    [select id, WOD_2__Date_Of_Repair__c,WOD_2__Date_Of_Failure__c,WOD_2__BusinessCategory__c, 
                     WOD_2__Account__c, CurrencyIsoCode,WOD_2__Claim_Type__c from WOD_2__Claim__c where id in :claimIdSet]);
                for(WOD_2__Claim__c claim : claimsMap.values()){
                    accountIdSet.add(claim.WOD_2__Account__c);
                }
                Map<Id, Map<String, List<WOD_2__Rates_Details__c>>> accRatesMap = getAccountRatesMap(accountIdSet); 	
                WOD_2__Business_Category_Configuration_Setting__c dateFieldToCompareConfigSetting = ATI_Utils.getConfiguration(claimsMap.values()[0].WOD_2__BusinessCategory__c, 'CLM_RateFetch_ClaimField_To_Be_Compare');
                String dateFieldToCompare = (dateFieldToCompareConfigSetting == null || dateFieldToCompareConfigSetting.Id == null) ? 'WOD_2__Date_Of_Repair__c' : dateFieldToCompareConfigSetting.WOD_2__Value__c;
                for(WOD_2.CLM_RatesOverrideInputWrapper inputWrapper: inputWrapList){
                    WOD_2.CLM_RatesOverrideOutputWrapper outputWrapper = new WOD_2.CLM_RatesOverrideOutputWrapper();
                    outputWrapper.status = true;
                    outputWrapper.claimId = inputWrapper.claimId;
                    WOD_2__Claim__c claim = claimsMap.get(inputWrapper.claimId);
                    if(claim.WOD_2__Claim_Type__c == 'Claim Template'){
                        outputWrapper.laborRate = 0;    
                     	outputWrapper.travelByHoursRate = 0;    
                        outputWrapper.travelByDistanceRate = 0;    
                        outputWrapList.add(outputWrapper);
                        continue;
                    }
                    Date claimDate = (Date)claim.get(dateFieldToCompare);
                    List<String> errorList = new List<String>();
                    if(accRatesMap.containsKey(claim.WOD_2__Account__c)){
                        if(inputWrapper.fetchLaborRate){
                            WOD_2__Rates_Details__c laborRate = getRateAmount(accRatesMap.get(claim.WOD_2__Account__c).get('ATI_Labor_Rate'), claimDate);
                            if(laborRate != null){
                                outputWrapper.laborRate = laborRate.WOD_2__Labor_Rate__c;    
                            } else {
                                errorList.add('Labor Rates are not defined for this account !!');
                            }
                        }
                        if(inputWrapper.fetchTravelByHoursRate){
                            WOD_2__Rates_Details__c travelRate = getRateAmount(accRatesMap.get(claim.WOD_2__Account__c).get('ATI_Travel_Rate'), claimDate);
                            if(travelRate != null){
                                outputWrapper.travelByHoursRate = travelRate.WOD_2__Travel_By_Hours_Rate__c;    
                            } else {
                                errorList.add('\'Travel By Hours\' are not defined for this account !!');
                            }
                        }
                        if(inputWrapper.fetchTravelByDistanceRate){
                            WOD_2__Rates_Details__c travelRate = getRateAmount(accRatesMap.get(claim.WOD_2__Account__c).get('ATI_Travel_Rate'), claimDate);
                            if(travelRate != null){
                                outputWrapper.travelByDistanceRate = travelRate.WOD_2__Travel_By_Distance_Rate__c;    
                            } else {
                                errorList.add('\'Travel By Distance\' are not defined for this account !!');
                            }
                        }
                    } else {
                        errorList.add('Rate Details are not defined for this account !!');
                    }
                    if(!errorList.isEmpty()){
                        outputWrapper.status = false;
                        outputWrapper.message = String.join(errorList, ', ');
                    }
                    outputWrapList.add(outputWrapper);
                }
            }catch(Exception e){
                System.debug('Exception -> ' + e.getStackTraceString());
            }            
        }
        System.debug('outWrapList--------------->'  + outputWrapList);
        return outputWrapList;
    }
    
    public static WOD_2__Rates_Details__c getRateAmount(List<WOD_2__Rates_Details__c> rateDetails, Date claimDate){
        WOD_2__Rates_Details__c rate = null;
        if(rateDetails != null && !rateDetails.isEmpty()){
            for(WOD_2__Rates_Details__c rateDetail : rateDetails){
                if(claimDate >= rateDetail.WOD_2__Active_From__c && claimDate <= rateDetail.WOD_2__Active_Until__c) {
    //                if(claimObject.get('CurrencyIsoCode') == rateDetail.get('CurrencyIsoCode')) {
                        rate = rateDetail;
                        break;
    //                }
                }
            }
        }
        return rate;
    }
    
    public static Map<Id, Map<String, List<WOD_2__Rates_Details__c>>> getAccountRatesMap(Set<Id> accountIdSet){
        Map<Id, Map<String, List<WOD_2__Rates_Details__c>>> ratesAccMap = new Map<Id, Map<String, List<WOD_2__Rates_Details__c>>>();
        //ALSN-164 - Sorting the query by CreatedDate, so it always picks the first applicable rate
        List<String> rateFieldsList = new List<String> {'Name','WOD_2__Active_From__c','WOD_2__Active_Until__c',
            'WOD_2__Dealer__c','CurrencyIsoCode','WOD_2__Labor_Rate__c','WOD_2__Travel_By_Hours_Rate__c','WOD_2__Travel_By_Distance_Rate__c'};
		String query = 'SELECT RecordType.DeveloperName, '+ String.join(rateFieldsList,',') +' from WOD_2__Rates_Details__c where WOD_2__Active_From__c != NULL ' + 
                'AND WOD_2__Active_Until__c != NULL AND WOD_2__Status__c = :status AND WOD_2__Dealer__c in :accountIdSet ORDER BY CreatedDate Desc';                
        System.debug('Query -> ' + query);
        String status = 'Active';
        List<WOD_2__Rates_Details__c> ratesList = Database.query(String.escapeSingleQuotes(query));
        for(WOD_2__Rates_Details__c rate : ratesList){
            if(!ratesAccMap.containsKey(rate.WOD_2__Dealer__c)){
                ratesAccMap.put(rate.WOD_2__Dealer__c, new Map<String, List<WOD_2__Rates_Details__c>>());
            } 
            if(!ratesAccMap.get(rate.WOD_2__Dealer__c).containsKey(rate.RecordType.DeveloperName)){
                ratesAccMap.get(rate.WOD_2__Dealer__c).put(rate.RecordType.DeveloperName, new List<WOD_2__Rates_Details__c>());
            }
            ratesAccMap.get(rate.WOD_2__Dealer__c).get(rate.RecordType.DeveloperName).add(rate);
        }
        return ratesAccMap;
    } 	
}