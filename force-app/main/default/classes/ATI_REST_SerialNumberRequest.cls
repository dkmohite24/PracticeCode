/* Name: ATI_REST_SerialNumberRequest
Description : This class is used for mapping the SerialNumber JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)        18/01/2021      INITIAL DEVELOPMENT                           
*/
public class ATI_REST_SerialNumberRequest {
    public List<Inventory> inventory;
    
    public class Inventory {
        public String serialNumber; 
        public String item;
        public String egcn; //Engineering group number(Text)
        public String shipDate;
        public String buildDate;
        public String shipTo; //ShipTo (Text)
        public String customerId;
        public String plantCode; //Build plant(Text)
        public String businessCategoryUnit;
        public String programLevel;
        public String active; //Active__c
        public String partcfn; //Customer Part Number(Text)
        public String majorComponentType; //Mandatory for ECU & TCMs(Picklist(ECU,TCM))
        public String vin;
        public String transmissionSerialNumber; //Transmission Serial Number host for ECU or TCM(Lookup to Inventory)
        public String identifier;
        public String UHMessage;//DMND-5817 New fields to Inventory[Start]
        public String ShipToDescription;
       
    }
    
    
    public static ATI_REST_SerialNumberRequest parse(String json) {
        return (ATI_REST_SerialNumberRequest) System.JSON.deserialize(json, ATI_REST_SerialNumberRequest.class);
    }
}