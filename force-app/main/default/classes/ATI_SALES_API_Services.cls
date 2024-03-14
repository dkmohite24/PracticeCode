/**
 * @description       :
 * @author            : Abhishek Mohapatra
 * @group             :
 * @last modified on  : 10-24-2023
 * @last modified by  : Abhishek Mohapatra
 * Updated by Spandana -1/23
 **/
global without sharing class ATI_SALES_API_Services {
  public static String createClaimPayload(String claimId) {
    //Data Handling Begin
    ATI_C_E__c ce = getClaimHeader(claimId);

    RebateProgram rp = [
      SELECT
        Id
      FROM RebateProgram
      WHERE Id = :ce.Incentive_Proposal__c
    ]; 

    Set<Id> apIds = new Set<Id>();


    for (ProcessInstance p : ce.ProcessInstances) {
      apIds.add(p.Id);
    }

    List<ProcessInstanceStep> apSteps = [
      SELECT
        OriginalActorId,
        OriginalActor.name,
        Actor.name,
        ActorId,
        ProcessInstanceId
      FROM ProcessInstanceStep
      WHERE ProcessInstanceId IN :apIds
    ];

    List<String> aprvrs = new List<String>();
    for (ProcessInstanceStep apStep : apSteps) {
      aprvrs.add(apstep.Actor.Name);
    }

    List<ContentVersion> cvs = new List<ContentVersion>();
    List<ContentDocumentLink> cdls = [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :rp.Id
    ];

    if (cdls.size() > 0) {
      Set<Id> cdIds = new Set<Id>();
      for (ContentDocumentLink cdl : cdls) {
        cdIds.add(cdl.ContentDocumentId);
      }

      cvs = [
        SELECT Id, ContentDocumentId, VersionData, FileExtension
        FROM ContentVersion
        WHERE ContentDocumentId IN :cdIds AND IsLatest = TRUE
      ];
    }

    //Data Handling End

    //Data Assignment Begin
    IncentiveClaimWrapper icw = new IncentiveClaimWrapper();
    cls_header hdr = new cls_header();
    hdr.amount = String.valueOf(ce.Total_Unique_Claim_Value__c);
    hdr.approvers = aprvrs;
    hdr.companyCode = ce.ATI_SALES_Account_Company_Code__c;
    hdr.currencyOfAmount = ce.CurrencyIsoCode;
    hdr.dateProcessed = Datetime.now().format('MM/dd/yyyy');
    hdr.dateProcessed =  Datetime.now().format('MM/dd/yyyy');
    hdr.GLAccount = ce.ATI_SALES_GL_Account_Number__c;
    hdr.invoiceNumber = ce.Name;

    if (!String.isBlank(ce.ATI_SALES_Vendor_Code__c)) {
      hdr.vendorCode = ce.ATI_SALES_Vendor_Code__c;
    } else {      
        hdr.customerCode = ce.ATI_SALES_Account_Number__c;
    } 
      if (!String.isBlank(ce.ATI_SALES_Vendor_Code__c)) {
      hdr.paymentType = 'Cheque Request'; 
    } else if (!String.isBlank(ce.ATI_SALES_Account_Number__c)) {
      hdr.paymentType = 'Credit Memo';
    }

    if (!(String.isEmpty(ce.ATI_Sales_Cost_Center__c)|| ce.ATI_Sales_Cost_Center__c == '--none--')) {
      hdr.COSTCENTER = ce.ATI_Sales_Cost_Center__c;
    }

    icw.header = hdr;

    if (cvs.size() > 0) {
      List<cls_items> cis = new List<cls_items>();
      for (ContentVersion cv : cvs) {
        cls_items ci = new cls_items();

        Blob filedata = cv.VersionData;
     
        ci.file = EncodingUtil.Base64Encode(filedata);

        ci.fileType = cv.FileExtension;

        cis.add(ci);
      }
      icw.items = cis;
    }
    //Data Assignment End

    //Data Conversion
    String payload = JSON.serialize(icw);

    return payload;
  }

  public Static ATI_C_E__c getClaimHeader(String claimId){
    ATI_C_E__c ce = [
      SELECT
        Id,
        Name,
        Incentive_Proposal__c,
        ATI_SALES_Account_Number__c,
        ATI_SALES_Vendor_Code__c,
        Total_Unique_Claim_Value__c,
        ATI_SALES_GL_Account_Number__c,
        ATI_SALES_Invoice_Number__c,
        ATI_SALES_Account_Company_Code__c,
        CurrencyIsoCode,
        ATI_Sales_Cost_Center__c,
        (
          SELECT Id, LastActor.Name
          FROM ProcessInstances
          ORDER BY CompletedDate ASC
          LIMIT 1
        )
      FROM ATI_C_E__c
      WHERE id = :claimId
    ];
    return ce;
  }

  global class IncentiveClaimWrapper {
    public cls_header header;
    public List<cls_items> items;
  }
  public class cls_header {
    public String companyCode { get; set; }
    public String dateProcessed { get; set; }
    public String invoiceNumber { get; set; }
    public String vendorCode { get; set; }
    public String GLAccount { get; set; }
    public String customerCode { get; set; }
    public String paymentType { get; set; }
    public String amount { get; set; }
    public String currencyOfAmount { get; set; }
    public List<String> approvers { get; set; }
    public String SI { get; set; }
    public String COSTCENTER { get; set; }
  }
  public class cls_items {
    public string file { get; set; }
    public String fileType { get; set; }
  }

  public class ClaimApiRes {
    public String message{get;set;}
    public String invoiceNumber{get;set;}
    public String SAP_Document_Number{get;set;}
    public String details{get; set;}
  }
}