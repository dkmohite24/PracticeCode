/* Name: CLM_PartPriceInterface
Description : CLM_PartPriceInterface for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     12-JAN-2021        INITIAL DEVELOPMENT
*/
global class ATI_CLM_PartPriceInterface implements WOD_2.CLM_PriceFetchInterface{
    
    // since we are not getting bulk implementation from Product and we are not using this interface
    // to fetch prices for different claim, assuming we will be fetching prices for a single claim of single BU
    global List<WOD_2.CLM_PartPriceWrapper> fetchPartPrice(List<WOD_2.CLM_PartPriceWrapper> ppwList){
        System.debug('ppwList -> ' + ppwList);
        if(!ppwList.isEmpty()){
            List<String> fieldList = new List<String>{'Name','WOD_2__Account__r.ATI_Price_Group__c','WOD_2__BusinessCategory__c','WOD_2__Account__r.ATI_Exchange_Rate_Type__c',
                'WOD_2__Date_Of_Failure__c','WOD_2__Date_Of_Purchase__c','WOD_2__Date_Of_Repair__c','WOD_2__Claim_Type__c','CurrencyISOCode'};
            ATI_Utils.checkForAccess('WOD_2__Claim__c', 'READ', fieldList); 
            List<Id> claimIdList = new List<Id>();
            List<Id> partIdList = new List<Id>();
            for(WOD_2.CLM_PartPriceWrapper ppWrapper : ppwList){
                partIdList.add(ppWrapper.partSalesforceId);		
                claimIdList.add(ppWrapper.claimId);		
            }
            String claimQuery = 'Select ID, ' + String.join(fieldList, ', ') + ' FROM WOD_2__Claim__c  WHERE id in :claimIdList';
            List<WOD_2__Claim__c> claimList = Database.query(claimQuery);
            System.debug('claimList -> ' + claimList);
            Map<Id,WOD_2__Claim__c> claimsMap = new Map<Id,WOD_2__Claim__c>(claimList);
            Map<Id, WOD_2__Warranty_Product_Pricebook__c> partPriceBookMap = new Map<Id, WOD_2__Warranty_Product_Pricebook__c>();
            ATI_ExchangeRateService.ExchangeWrapper currencyExchangeWrapper = null;
            if(!claimList.isEmpty()){
                String dateFieldForPriceFetchStr = ATI_Utils.getConfiguration(claimList[0].WOD_2__BusinessCategory__c, 'CLM_Price_Fetch_ClaimField_Tobe_Compare').WOD_2__Value__c;
                Date dateFieldForPriceFetch = (Date) claimList[0].get(dateFieldForPriceFetchStr);
                String priceGroup = claimList[0].WOD_2__Account__r.ATI_Price_Group__c;
                if(claimList[0].CurrencyISOCode != null && claimList[0].CurrencyISOCode != 'USD'){
                	currencyExchangeWrapper = ATI_ExchangeRateService.convertCurrencyOfType(claimList[0].CurrencyISOCode, 'USD', dateFieldForPriceFetch, claimList[0].WOD_2__Account__r.ATI_Exchange_Rate_Type__c);    
                }
                List<String> priceBookFields = new List<String>{'WOD_2__Unit_Price__c','WOD_2__Valid_From__c','ATI_Active__c',
                    'WOD_2__Warranty_Product__c','ATI_Price_Group__c','WOD_2__Valid_Until__c'};
				ATI_Utils.checkForAccess('WOD_2__Warranty_Product_Pricebook__c', 'READ', priceBookFields);                        
				String priceQuery = 'Select ID, ' + String.join(priceBookFields, ', ') + ' from WOD_2__Warranty_Product_Pricebook__c where ' +
                    'WOD_2__Valid_From__c <= :dateFieldForPriceFetch  AND WOD_2__Valid_Until__c >= :dateFieldForPriceFetch AND ATI_Price_Group__c = :priceGroup AND ' +
                    'WOD_2__Warranty_Product__c in :partIdList AND RecordType.Name = \'Part Price\' AND ATI_Active__c = true';
                List<WOD_2__Warranty_Product_Pricebook__c> wpPriceBookList = Database.query(priceQuery);
                for(WOD_2__Warranty_Product_Pricebook__c wpPriceBook : wpPriceBookList){
                    partPriceBookMap.put(wpPriceBook.WOD_2__Warranty_Product__c, wpPriceBook);
                }
            }
            for(WOD_2.CLM_PartPriceWrapper ppWrapper : ppwList){
                if(claimsMap.containsKey(ppWrapper.claimId) && claimsMap.get(ppWrapper.claimId).WOD_2__Claim_Type__c == 'Claim Template'){
                    ppWrapper.unitPrice = null;
                    ppWrapper.totalPrice = null;
                    ppWrapper.status = true;
                    continue; 
                }
                if(partPriceBookMap.containsKey(ppWrapper.partSalesforceId)){
                    WOD_2__Warranty_Product_Pricebook__c wpPriceBook = partPriceBookMap.get(ppWrapper.partSalesforceId);
                    Double unitPrice = wpPriceBook.WOD_2__Unit_Price__c;
                    if(claimsMap.get(ppWrapper.claimId).CurrencyISOCode != 'USD' && String.isBlank(currencyExchangeWrapper.msg)){
                        unitPrice = unitPrice/currencyExchangeWrapper.rate;
                    }else if(currencyExchangeWrapper != null && String.isNotBlank(currencyExchangeWrapper.msg)){
                        ppWrapper.msg = currencyExchangeWrapper.msg;
                        continue;
                    }
                    ppWrapper.unitPrice = unitPrice.format();
                    System.debug('>> unitPrice'+wpPriceBook.WOD_2__Unit_Price__c);
                    ppWrapper.totalPrice = (Integer.valueof(ppWrapper.quantity) * unitPrice).format();
                    System.debug('>> totalPrice'+ppWrapper.totalPrice);
                    ppWrapper.status = true;
                } else {
                	ppWrapper.msg = 'No matching prices available in Warranty Price Book for part - ' + ppWrapper.partNumber;    
                }
            }
            
        }
        return ppwList;
    }
}