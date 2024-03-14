public class ATI_ClaimHeaderHandler {
    public static void updateFieldOnStatusChange(List<ATI_C_E__c> newRecords, Map<Id, ATI_C_E__c> oldMap) {
        List<ATI_C_E__c> recordsToUpdate = new List<ATI_C_E__c>();
        
        for (ATI_C_E__c header : newRecords) {
            // Check if the Processing Status has been updated to 'Pending Approval'
            if (oldMap.get(header.Id).Status__c != 'Pending Approval' && 
                header.Status__c == 'Pending Approval') {
                    
                    Decimal ExchangeRate, USD_Amount;
                    
                    //Calculate ATI_Approval_US_Dollar_Amount__c
                    If(header.Total_Unique_Claim_Value__c != 0){
                        
                        //Query the Claim header currencyISOCode
                        List<ATI_C_E__c> CurrencyCode = [SELECT CurrencyIsoCode from ATI_C_E__c  where ID = :header.Id];
                    	String CurrencyCodeClaim = CurrencyCode.get(0).CurrencyIsoCode;
                        
                        //If CurrencyISOCode is USD, Exchange rate is 1, Else get Conversion Rate of CurrencyISOCode
                        If(CurrencyCodeClaim == 'USD'){
                            ExchangeRate = 1.00000; 
                        }
                        Else{
                            List<CurrencyType> ConRate = [SELECT ConversionRate from CurrencyType where IsoCode = :CurrencyCodeClaim];
                            ExchangeRate = ConRate.get(0).ConversionRate;
                        }
                        
                        USD_Amount = header.Total_Unique_Claim_Value__c/ExchangeRate; 
                    }
                    
                    If(header.Total_Unique_Claim_Value__c != 0){
                         // Add the record to the list to be updated and Update the field you want to change in the Incentive Proposal object
                    recordsToUpdate.add(new ATI_C_E__c(
                        Id = header.Id,
                        ATI_Approved_Ex_Rate__c = ExchangeRate,
                        ATI_Approval_US_Dollar_Amount__c = USD_Amount
                    ));
                    }
                   
                }
        }
        
        // Update records if there are any in the list
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
}