/* Name: ATI_REST_CustomerMasterRequest
Description : This class is used for mapping the CustomerMaster JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(TY)        10/11/2020       INITIAL DEVELOPMENT             20659                 
*/
public class ATI_REST_CustomerMasterRequest {
    public List<CustomerInformation> account;
    public class CustomerInformation{
        public String accountName;
        public String accountNumber;
        public String accountDescription;
        public String active; 
        public String type;
        public String parentAccount;
        public String financialBPCode; 
        public String externalId;
        public String billingStreet;
        public String billingCity;
        public String billingState;
        public String billingPostalCode;
        public String billingCountry;
        public String shippingStreet;
        public String shippingCity;
        public String shippingState;
        public String shippingPostalCode;
        public String shippingCountry;
        public List<LaborRateDetails> laborRateDetail;
        public List<DistanceRateDetails> distanceRateDetails;
        public List<LandingCostMarkupDetails> landingCostMarkupDetails;
        public String businessCategoryUnit;
        public String markUpPercent;
        public String email;
        public String customerCurrency; 
        public String region;
        public String customerGroup; 
        public String accountGroup;
        public String priceGroup;
        public String exchangeRateType; 
        public String adjustmentFactor; 
        public String performance; 
        public String distanceIndicator; 
        public String activeDate; 
        public String rmaExempt;
        public String inActiveDate; 
        public String identifier;
    }
    public class LaborRateDetails{
        public String laborRate;
        public String activeFrom;
    }
    public class DistanceRateDetails{
        public String distancePerHour;
        public String maxTravelDist;
        public List<DistanceRateDetailInfo> distanceRateDetail;
    }
    public class DistanceRateDetailInfo{
        public String distanceRate;
        public String activeFrom;
    }
    public class LandingCostMarkupDetails{
        public List<LandingCostDetails> landingCostDetail;
    }
    public class LandingCostDetails{
        public String landingCostRate;
        public String activeFrom;
    }
    public static ATI_REST_CustomerMasterRequest parse(String json) {
        return (ATI_REST_CustomerMasterRequest) System.JSON.deserialize(json, ATI_REST_CustomerMasterRequest.class);
    }
}