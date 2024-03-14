/* Name: ATI_REST_BatchClaimSubmittalResults
Description : Stores query data of BatchClaimSubmittal Validator
Author : Tavant (TY)
History :
VERSION      AUTHOR          DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant (TY)    09/04/2021          INITIAL DEVELOPMENT
*/
public with sharing class ATI_REST_BatchClaimSubmittalResults {
    public Map<string,string> buMap;
    public Map<String,WOD_2__Inventory__c> inventoryMap;
    public Map<String,Account> accMap;
    public Map<String,WOD_2__Warranty_Product__c> warProdMap;
    public Map<String,WOD_2__Warranty_Code__c> warCodeMap;
    //public Map<String,WOD_2__Warranty_Product_Pricebook__c> priceBookMap;
    public Map<String,List<WOD_2__Warranty_Product_Pricebook__c>> priceBookMap;//ALSN-45
    public Map<String,ATI_Exchange_Rate__c> exchangeRateMap;
    public Map<String,WOD_2__Claim__c> claimMap;
    public Map<String,WOD_2__Claim__c> claimIdMap;
    public Map<String,WOD_2__Financial_Line_Item__c> financialLineItemMap;
    public Map<String,twodcms__Campaign_Claim_Template_Association__c> mapOfKeyWithCampaignClaimTempAss;
    public Map<string,WOD_2__Rates_Details__c> rateMap;
    public List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> batchClaimSubmittalReqLst;
    public Map<Integer,List<String>> mapOfFailure;
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation>> mapOfSuccessParts;
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData>> mapOfSuccessDiagnosticCodes;
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation>> mapOfSuccessLaborCodes;
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData>> mapOfSuccessNetItems;
    public Map<String,List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>> mapOfBatchClaimRelatedErrorInfo;
    public ATI_REST_BatchClaimSubmittalResults() {
        buMap = new Map<string,string>();
        inventoryMap = new Map<String,WOD_2__Inventory__c>();
        accMap = new Map<String,Account>();
        warProdMap = new Map<String,WOD_2__Warranty_Product__c>();
        warCodeMap = new Map<String,WOD_2__Warranty_Code__c>();
        //priceBookMap = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
        priceBookMap = new Map<String,List<WOD_2__Warranty_Product_Pricebook__c>>();//ALSN-45
        exchangeRateMap = new Map<String,ATI_Exchange_Rate__c>();
        claimMap = new Map<String,WOD_2__Claim__c>();
        claimIdMap = new Map<String,WOD_2__Claim__c>();
        financialLineItemMap = new Map<String,WOD_2__Financial_Line_Item__c>();
        mapOfKeyWithCampaignClaimTempAss = new Map<String,twodcms__Campaign_Claim_Template_Association__c>();
        rateMap = new Map<string,WOD_2__Rates_Details__c>();
        batchClaimSubmittalReqLst = new List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation>();
        mapOfFailure = new Map<Integer,List<String>>();
        mapOfSuccessParts = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation>>();
        mapOfSuccessDiagnosticCodes = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData>>();
        mapOfSuccessLaborCodes = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation>>();
        mapOfSuccessNetItems = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData>>();
        mapOfBatchClaimRelatedErrorInfo = new Map<String,List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>>();
    }
}