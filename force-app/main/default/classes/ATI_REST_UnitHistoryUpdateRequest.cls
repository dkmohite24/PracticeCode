/* Name: ATI_REST_UnitHistoryUpdateRequest
Description : ATI_REST_UnitHistoryUpdateRequest - Request for Unit History Rest Callout
History:
VERSION     AUTHOR               DATE                  DETAIL             UserStory/Req#
1.0 -     Tavant(TY)          Mar 15th 2021      INITIAL DEVELOPMENT
*/
public class ATI_REST_UnitHistoryUpdateRequest {
    
    public List<UNIT_HISTORY_UPDATE> unitHistoryUpdate;
    
    public class BOM_AWAARE_REPLACECOMPONENT {
        public String serialNumber = '';
        public String replaceComponentSerial = '';
        public String replaceComponentType = '';
        public String replCompSNRODate = '';
    }
    
    public class BOM_AWAARE_MESSAGE_COPY {
        public String dispositionCodeId = ''; //code
        public String dispositionMessage = ''; //description
    }
    
    public class BOM_AWAARE_COVERAGES {
        public String coverage = '';
        public String coverageType = '';
        public String coverageDescription = '';
    }
    
    public class BOM_CAMPAIGNS {
        public String campaignCodeRequired = '';
        public String description = '';
    }
    
    public class UNIT_HISTORY_UPDATE {
        public List<BOM_AWAARE_TRANS_HISTORY> bomAwaareTransHistory;
        public List<BOM_AWAARE_REPLACECOMPONENT> bomAwaareReplaceComponent; //ReplacementClaims
        public List<BOM_CAMPAIGNS> bomCampaigns; 
        public List<BOM_CAMPAIGNSTOSERIAL> bomCampaignsToSerial; 
        public List<BOM_AWAARE_MESSAGE_COPY> bomAwaareMessageCopy; //Disposition Codes
        public List<BOM_AWAARE_MESSAGES> bomAwaareMessages;
        public List<BOM_AWAARE_COVERAGES> bomAwaareCoverages;
    }
    
    public class BOM_AWAARE_TRANS_HISTORY {
        public String serialNumber = '';
        public String warrantyCode = ''; //Standard Warranty Code
        public String customerDeliveryDate = '';
        public String etcCode = ''; //ETC Coverage Code
        public String vocationCode = '';
        public String vin = '';
        public String assetNumber = '';
        public String endCustomerName = '';
        public String endCustomerStreet = '';
        public String endCustomerCity = '';
        public String endCustomerState = '';
        public String endCustomerCountry = '';
        public String endCustomerZip = '';
        public String currentProgramLevel = '';
    }
    
    public class BOM_CAMPAIGNSTOSERIAL {
        public String campaignCodeRequired = '';
        public String serialNumber = '';
        public String campaignCodeCompleteDate = '';
    }
    
    public class BOM_AWAARE_MESSAGES {
        public String dispositionCodeId = '';
        public String serialNumber = '';
        public String updateDelete = '';
    }
}