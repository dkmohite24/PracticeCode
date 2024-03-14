/* Name: ATI_REST_ExchangeRateRequest
Description : This class is used for mapping the ExchangeRate JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	27/11/2020     	  INITIAL DEVELOPMENT             20656                 
*/
public class ATI_REST_ExchangeRateRequest {
    public List<ExchangeRate> exchangeRate;
    public class ExchangeRate{
        public String rateType;
        public String effectiveDate;
        public String fromCurrency;
        public String toCurrency;
        public String rate;
        public String ratio;
        public String identifier;
    }
    public static ATI_REST_ExchangeRateRequest parse(String json) {
        return (ATI_REST_ExchangeRateRequest) System.JSON.deserialize(json, ATI_REST_ExchangeRateRequest.class);
    }
}