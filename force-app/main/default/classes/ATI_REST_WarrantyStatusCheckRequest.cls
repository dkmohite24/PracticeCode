/* Name: ATI_REST_WarrantyStatusCheckRequest
Description : This class is used for mapping the WarrantyStatusCheck JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	01/02/2021     	  INITIAL DEVELOPMENT                              
*/
public class ATI_REST_WarrantyStatusCheckRequest {

    public WarrantyStatusCheckRequest warrantyStatusCheck;
    
    public static ATI_REST_WarrantyStatusCheckRequest parse(String json) {
        return (ATI_REST_WarrantyStatusCheckRequest) System.JSON.deserialize(json, ATI_REST_WarrantyStatusCheckRequest.class);
    }

    public class WarrantyStatusCheckRequest {
        public String serialNumber;
        public String repairOrderOpenDate;
        public String vehicleUsageValue;
        public String vehicleUsageUnit;
        public String inServiceDate;
        public String vocationCode;    
    }

}