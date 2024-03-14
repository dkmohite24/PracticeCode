/* Name: ATI_REST_SerialNumberInfoRequest
Description : This class is used for mapping the Serial Number Info JSON request 
Author : Tavant(Punam)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)        03/03/2021       INITIAL DEVELOPMENT                              
*/
global class ATI_REST_SerialNumberInfoRequest {
    public SerialNumberInformation SerialNumberInfo;
    public class SerialNumberInformation{
        public String businessPartnerCode; //Distributor account
        public List<SerialInformation> serialInfo;
        
    }
    public class SerialInformation{
        public String trackingNumber;
        public String repairOutlet; 
        public String serialNumber;
    }
    
    public static ATI_REST_SerialNumberInfoRequest parse(String json) {
        system.debug('json**'+json);
        ATI_REST_SerialNumberInfoRequest req= (ATI_REST_SerialNumberInfoRequest) System.JSON.deserialize(json, ATI_REST_SerialNumberInfoRequest.class);
        system.debug('req**'+req);
        return req;
        
    }
   
}