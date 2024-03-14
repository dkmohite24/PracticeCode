public class ATI_RebateProgramHandler {
    public static void updateFieldOnProcessingStatusChange(List<RebateProgram> newRecords, Map<Id, RebateProgram> oldMap) {
        List<RebateProgram> recordsToUpdate = new List<RebateProgram>();
        
        for (RebateProgram proposal : newRecords) {
            // Check if the Processing Status has been updated to 'Submitted - Waiting for Approval'
            if (oldMap.get(proposal.Id).ATI_Processing_Status__c != 'Submitted - Waiting for Approval' && 
                proposal.ATI_Processing_Status__c == 'Submitted - Waiting for Approval') {
                    
                    Decimal ExchangeRate, USD_Amount;
                    
                    //Calculate ATI_Approval_US_Dollar_Amount__c - If ATI_Incentive_Proposal_Value__c is not null, ATI_Approval_US_Dollar_Amount__c should be calculated
                    If(proposal.ATI_Incentive_Proposal_Value__c != Null){
                        
                        
                        //Query the Incentive Proposal currencyISOCode
                        List<RebateProgram> CurrencyCode = [SELECT CurrencyIsoCode from RebateProgram  where ID = :proposal.Id];
                        String CurrencyCodeClaim = CurrencyCode.get(0).CurrencyIsoCode;
                        
                        //If CurrencyISOCode is USD, Exchange rate is 1, Else get Conversion Rate of CurrencyISOCode
                        If(CurrencyCodeClaim == 'USD'){
                            
                            ExchangeRate = 1.00000;
                        }
                        Else{
                            
                            List<CurrencyType> ConRate = [SELECT ConversionRate from CurrencyType where IsoCode = :CurrencyCodeClaim];
                            ExchangeRate = ConRate.get(0).ConversionRate;
                        }
                        
                        USD_Amount = proposal.ATI_Incentive_Proposal_Value__c/ExchangeRate; 
                    }
                    
                  If(proposal.ATI_Incentive_Proposal_Value__c != Null){
                        
                        // Add the record to the list to be updated and Update the field you want to change in the Incentive Proposal object
                        recordsToUpdate.add(new RebateProgram(
                            Id = proposal.Id,
                            ATI_Approved_Ex_Rate__c = ExchangeRate,
                            ATI_Approval_US_Dollar_Amount__c = USD_Amount
                        ));
                    }
                }
            
            // Update records if there are any in the list
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
    }
}