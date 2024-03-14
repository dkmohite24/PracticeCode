/* Name: CLM_PartPriceInterface
Description : CLM_PartPriceInterface for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     13-JAN-2021        INITIAL DEVELOPMENT
*/

public class ATI_ExchangeRateService {
    	
    /*Method accept fromCurrency, toCurrency and dateOfConversion parameters 
     * 
     * Return Rate and message
    */
    public static ExchangeWrapper convertCurrency(String fromCurrency, String toCurrency, Date dateOfConversion){
        ExchangeWrapper ew = new ExchangeWrapper();
        if(fromCurrency=='' || toCurrency=='' || dateOfConversion ==null ){
         	ew.msg = System.Label.ATI_Please_send_all_requested_parameters;
            return ew;  
        }else{
            system.debug('dateOfConversion'+dateOfConversion+'fromCurrency**'+fromCurrency+'toCurrency**'+toCurrency);
            //ALSN-117 changed to Value__c field instead of Rate__c
             List<ATI_Exchange_Rate__c> erList = [SELECT id, FromCurrency__c, Rate__c, Value__c, ToCurrency__c, EffectiveDate__c, EndDate__c
                                             FROM ATI_Exchange_Rate__c WHERE FromCurrency__c =: fromCurrency 
                                             AND  ToCurrency__c=:toCurrency AND EffectiveDate__c <=:dateOfConversion
                                             AND EndDate__c>=: dateOfConversion];
            if(!erList.isEmpty() && erList[0].Value__c !=null){
                
                ew.rate = erList[0].Value__c;
                ew.msg = '';
                return ew;
                
            }else{
                String customLabelStr = System.Label.No_exchange_rate_available_from_fromCurrency_to_toCurrency_for_dateOfConversion;
                customLabelStr = customLabelStr.replace('fromCurrency', fromCurrency);
                customLabelStr = customLabelStr.replace('toCurrency', toCurrency);
                ew.msg = customLabelStr+' '+dateOfConversion ;
            	return ew; 
            }
        }   
    }
    
    public static ExchangeWrapper convertCurrencyOfType(String fromCurrency, String toCurrency, Date dateOfConversion, String rateType){
        ExchangeWrapper ew = new ExchangeWrapper();
        if(String.isBlank(fromCurrency) || String.isBlank(toCurrency) || dateOfConversion == null || String.isBlank(rateType) == null ){
         	ew.msg = System.Label.ATI_Please_send_all_requested_parameters;
            return ew;  
        }else{
            //ALSN-117 changed to Value__c field instead of Rate__c
             List<ATI_Exchange_Rate__c> erList = [SELECT id, FromCurrency__c, Rate__c, ToCurrency__c, EffectiveDate__c, EndDate__c, Value__c
                                             FROM ATI_Exchange_Rate__c WHERE FromCurrency__c =: fromCurrency 
                                             AND  ToCurrency__c=:toCurrency AND EffectiveDate__c <=:dateOfConversion
                                             AND EndDate__c>=: dateOfConversion and RateType__c = :rateType];
            if(!erList.isEmpty() && erList[0].Value__c !=null){
                ew.rate = erList[0].Value__c;
                ew.msg = '';
                return ew;
            }else{
                String customLabelStr = System.Label.No_exchange_rate_available_from_fromCurrency_to_toCurrency_for_dateOfConversion;
                customLabelStr = customLabelStr.replace('fromCurrency', fromCurrency);
                customLabelStr = customLabelStr.replace('toCurrency', toCurrency);
                ew.msg = customLabelStr + ' ' + dateOfConversion + ' of type ' + rateType;
            	return ew; 
            }
        }        
    }
    
    public static ExchangeWrapper convertCurrencyForAccount(String fromCurrency, String toCurrency, Date dateOfConversion, Id accountId){
        ATI_Utils.checkForAccess('Account', 'READ', new List<String>{'ATI_Exchange_Rate_Type__c'});
        Account acc = [select Id, ATI_Exchange_Rate_Type__c from Account where Id =:accountId];
        return convertCurrencyOfType(fromCurrency, toCurrency, dateOfConversion, acc.ATI_Exchange_Rate_Type__c);
    }
    
    public class ExchangeWrapper{
        public Decimal rate;
        public String msg;   
    }

}