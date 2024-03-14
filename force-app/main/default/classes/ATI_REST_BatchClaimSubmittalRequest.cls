/*Name: ATI_REST_BatchClaimSubmittalRequest
Description : This class is used for mapping the BatchClaimSubmittal JSON request 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	08/02/2021     	  INITIAL DEVELOPMENT                              
*/
public class ATI_REST_BatchClaimSubmittalRequest {
	public List<ClaimInformation> claim;
	Public class ClaimInformation {
		public String businessCategoryConfiguration;
		public String submittalIndicator;
		public String repairOutlet;	
		public String serialNumber;	
		public String trackingNumber;
		public String claimNumber;	
		public String claimType;	
		public String repairOrder;	
		public String specialActivityCode;
        public String campaignTemplateName;
		public String repairOrderOpenDate;	
		public String laborLastAppliedDate;	
		public String primaryFailedPart;	
        public string primaryFailedPartSerialNumber;
		public String dateOfPurchase;
		public String complaintCode;
		public String failureCode;
        public String failureLocation;
		public String replacementUnitSerialNumber;
		public String serviceReplacementIndicator;
		public String technicianName;
		public String preAuthorizationRequired;
        public String preAuthorizationReason;
        public String preAuthorizationComments;
		public String workPerformedComments;
        public String identifier;
		public RegistrationInformation registrationInfo;
		public List<PartsInformation> serviceParts;
		public List<LaborInfomation> laborCodes;
		public List<NetItemsData> netItems;
		public List<DiagnosticCodesData> diagnosticCodes;
		public TurnAroundInformation turnAroundData;
	}
    
	public class RegistrationInformation {
		public CustomerInformation customerInfo;
		public VehicleInformation vehicleInfo;
	}
    
	public class CustomerInformation {
		public String customerName;
		public String street;
		public String city;
		public String state;
		public String postalCode;
		public String countryCode;
		public String email;
		public String phone;
	}
    
	public class VehicleInformation {
		public String preDelivery;
		public String inServiceDate;
		public String vocationCode;
		public String customerAssetNumber;
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
    
	public class PartsInformation{
		public String lineNumber;	//1
		public String failedPartNumber;	//29503283
        public String failedPartSerialNumber;
        public String replacedPartNumber;
        public String replacementPartSerialNumber;
		public String partQuantity;	//1
		public String partUnit;	//ea
	}
    
	public class LaborInfomation {
		public String lineNumber;	//3
		public String laborOperationCode;	//00096901
		public String laborTimeActual;	//1.5
        public String reason;
	}
    
	public class NetItemsData {
		public String lineNumber;	//5
		public String netItemType;	//P
		public String netItemQuantity;	//3
		public String netItemUnit;	//ea
		public String netItemUnitCost;	//25.69
        public String reason;
	}
    
	public class DiagnosticCodesData {
		public String lineNumber;
		public String diagnosticCode;
	}
    
	public class TurnAroundInformation {
		public String dateTimeCustomerRequestedService;
		public String dateTimeDistributorScheduledService;
		public String dateTimeOfVehicleArrival;
		public String dateTimeLaborFirstApplied;
		public String dateTimeFirstPartOrdered;	
		public String dateTimeLastPartArrived;
		public String dateTimeLaborLastRecordedOrApplied;
		public String dateTimeRepairOrderClosed;	
		public String dateTimeCustomerNotified;
		public String repairOrderOpenDateTime;	
        //public String customerAuthorizeWorkDateOrTime;
	}
    
	public static ATI_REST_BatchClaimSubmittalRequest parse(String jsonData){
		return (ATI_REST_BatchClaimSubmittalRequest) System.JSON.deserialize(jsonData, ATI_REST_BatchClaimSubmittalRequest.class);
	}

}