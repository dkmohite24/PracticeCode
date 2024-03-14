/* Name: ATI_REST_SerialNumberInfoResponse
Description : This class is used for mapping the Serial Number Info JSON response 
Author : Tavant(MB)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(MB)        04/03/2021       INITIAL DEVELOPMENT                              
*/
global class ATI_REST_SerialNumberInfoSyncResponse {
    global SerialNumberResponseInformation SerialNumberResponseInfo;
    global String status = 'false';
    global String interfaceName = '';
    global String message ='';
    public class SerialNumberResponseInformation {
		public String BusinessPartnerCode ='';	//0322400000
		public List<DetailInformation> Details= new List<DetailInformation>();
	}
    
    public class DetailInformation{
        //public string identifier='';
        public string TrackingNumber='';
        public string RepairOutlet='';
        public string SerialNumber='';
        public string ProcessCode='';
        public string ProcessMessage='';
        public string ModelNumber='';
        public string VocationCode='';
        public string VIN='';
        public string VehicleMake='';
        public string VehicleModel='';
        public string EngineMake='';
        public string EngineModel='';
        public string EngineYear='';
        public string InServiceDate='';
        public List<CoverageInformation> coverages = new List<CoverageInformation>();
        public OwnerInformation ownerInfo = new OwnerInformation();
        
    }
    public class CoverageInformation{
        public string CoverageType='';
        public string CoverageCode='';
        public string CoverageName='';
        public string CoverageStartDate='';// Added by Mukesh as CR from Noor
        public string CoverageEndDate='';// Added by Mukesh as CR from Noor
        
    }
    public class OwnerInformation{
		public string OwnerName='';
        public string OwnerTelephone='';
        public string OwnerAddress='';
        public string OwnerCity='';
        public string OwnerState_Province='';  // TBD Prasad OwnerState/Province;
        public string OwnerCountryCode='';
        public string OwnerPostalCode='';
        public string OwnerEmailAddress='';
    }
}