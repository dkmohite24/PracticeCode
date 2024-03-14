/*Description : This class is used for mapping Batch ETC Submittal Response JSON request 
Author : Tavant(Punam)
History:
VERSION     AUTHOR                DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)       	15/02/2021     	  INITIAL DEVELOPMENT                              
*/
public class ATI_Rest_BatchETCSubmitResponseRequest {
    public ETCStatusInformation ETCStatusCheck;
    public class ETCStatusInformation{
        //public String identifier;
        public String businessPartnerCode;
        public String SerialNumber;
        public String businessCategoryConfiguration;
    }
    
    public static ATI_Rest_BatchETCSubmitResponseRequest parse(String json) {
        return (ATI_Rest_BatchETCSubmitResponseRequest) System.JSON.deserialize(json, ATI_Rest_BatchETCSubmitResponseRequest.class);
    }
}