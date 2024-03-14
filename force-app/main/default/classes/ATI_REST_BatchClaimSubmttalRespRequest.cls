/* Name: ATI_REST_BatchClaimSubmttalRespRequest
Description : This class is used for mapping the I207-BatchClaimSubmittal JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	16/02/2021     	  INITIAL DEVELOPMENT                              
*/
public class ATI_REST_BatchClaimSubmttalRespRequest {
    public ClaimInformation claimStatusCheck;
    public class ClaimInformation{
        public String businessPartnerCode;
        public String businessCategoryConfiguration;
        public String trackingNumber;
        public String identifier;
    }
    public static ATI_REST_BatchClaimSubmttalRespRequest parse(String json) {
        return (ATI_REST_BatchClaimSubmttalRespRequest) System.JSON.deserialize(json, ATI_REST_BatchClaimSubmttalRespRequest.class);
    }
}