/*Name: ATI_REST_PartPriceRequest
Description : This class is used for mapping the PartPrice JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	21/12/2020     	  INITIAL DEVELOPMENT             20670                 
*/
public class ATI_REST_PartPriceRequest {
    public List<PartPriceInfo> partPrice;
    public class PartPriceInfo{
        public String manufNumber;
        public String conditionType;
        public String priceGroup;
        public String effectiveDate;
        public String endDate;
        public String value;
        public String priceUnit;
        public String identifier;
    }
    public static ATI_REST_PartPriceRequest parse(String json) {
        return (ATI_REST_PartPriceRequest) System.JSON.deserialize(json, ATI_REST_PartPriceRequest.class);
    }
}