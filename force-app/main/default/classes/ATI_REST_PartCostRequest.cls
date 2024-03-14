/* Name: ATI_REST_PartCostRequest
Description : This class is used for mapping the PartCost JSON request 
Author : Tavant(Punam)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)        18/01/2021       INITIAL DEVELOPMENT                              
*/
public class ATI_REST_PartCostRequest {
	public List<PartCostInformation> partCost;
    public class PartCostInformation{
        public String identifier;
        public String item; //Part number
        public String value; //Part Cost
        public String active;// Part Cost Status
        public String effectiveDate; //Start Date
        public String itemUnit; //Unit of Measure
    }
   
   /* public static ATI_REST_PartCostRequest parse(String json) {
        return (ATI_REST_PartCostRequest) System.JSON.deserialize(json, ATI_REST_PartCostRequest.class);
    }*/
}