/* Name: ATI_REST_PartsMasterRequest
Description : This class is used for mapping the PartsMaster JSON request 
Author : Tavant(Punam)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)        08/01/2021       INITIAL DEVELOPMENT                              
*/
public class ATI_REST_PartsMasterRequest {
    public List<WarrantyProductInformation> warrantyProduct;
    public class WarrantyProductInformation{
        public String identifier;
        public String businessCategoryUnit;
        public String description;
        public String externalProductCode;
        public String itemType; //Item Type: Identifier to identify a transmission or a part
        public String parentProduct; //Self Lookup field which allows to build the relationship. Field to link one level to the parent product/level
        public String productCode; 
        public String productName;
        public String trackType;//Track type to denote if a product is tracked as serialized or non-serialized
        public String prodType; //Type: Type/level of the product
        public String unitOfMeasure;
        public String active; //Active__c
        public String hardwareModel;
        public String nameplateModel;
        public String extendedBaseModel;
        public String eeNumber;//Engineering group number
        public String thirtyTwoMiNum;
        //public String categoryNum2;
        public PartMarkupDetails partMarkup;
        public String rmaPolicy;//checkbox
        public String primaryFailedPartProhibit; //checkbox
        public String hierarchy;
        public String gNumber; //Engineering group number
    }
    public class PartMarkupDetails{
        public String partMarkupPercentage; //Percentage 
        public String effectiveDate; //Date (Effective Date)
    }
    
    /*public static ATI_REST_PartsMasterRequest parse(String json) {
        return (ATI_REST_PartsMasterRequest) System.JSON.deserialize(json, ATI_REST_PartsMasterRequest.class);
    }*/

}