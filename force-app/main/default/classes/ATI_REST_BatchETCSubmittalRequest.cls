/* Name: ATI_REST_BatchETCSubmittalRequest
Description : This class is used for mapping the Batch ETC Submittal JSON request 
Author : Tavant(Punam)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)        01/02/2021       INITIAL DEVELOPMENT                              
*/
public class ATI_REST_BatchETCSubmittalRequest {
    public List<ETCPurchaseInformation> etcPurchase;
    public class ETCPurchaseInformation{
        //public String identifier;
        public String businessPartnerCode; //Distributor account
        public String businessCategoryConfiguration; //Business unit
        public String trackingNumber; //Field to be used for Business Partner specific data;
        public String repairOutlet; //Distributor/Dealer account who performed the repair
        public String agreementDate;
        public String submittalIndicator;// Request type
        public String submitterName;  // Name of the ETC purchase submitter
        public String submitterPhone; //Submitter Phone
        public String purchaseOrderNumber;   //ETC purchase order number
        public String etcRegistrationNumber; //ETC registration number, this will be empty for the initial submission
        public String etcCoverageCode;// ETC coverage code
        public String cENumber; 
        public VehicleInformation vehicleInfo;  
        public CustomerInformation customerInfo;
        
    }
    public class VehicleInformation{
        public String serialNumber;
        public String preDelivery; 
        public String vocationCode;
        public String customerAssetNumber;
        public String inServiceDate; 
        public String vehicleIdentificationNumber;
        public String vehicleMileage;
        public String usageUnit; 
        public String vehicleMake;
        public String vehicleModel;
        public String engineMake; 
        public String engineModel;
        public String engineYear; 
        public String executiveOrderDesignation;
       
    }
    public class CustomerInformation{
    	public String customerName;
        public String street; 
        public String city;
        public String state;
        public String postalCode; 
        public String countryCode;
        public String email; 
        public String phone;
        
    }
   
}