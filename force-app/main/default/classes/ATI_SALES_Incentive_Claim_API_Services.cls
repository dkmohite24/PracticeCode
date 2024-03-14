/**
 * @description       :
 * @author            : Abhishek Mohapatra
 * @group             :
 * @last modified on  : 09-15-2023
 * @last modified by  : Abhishek Mohapatra
 **/
public without sharing class ATI_SALES_Incentive_Claim_API_Services {
  public static void sendIncentiveClaim(String claimId) {
    String payload = ATI_SALES_API_Services.createClaimPayload(claimId);

    System.debug(payload);

    //API Process Begin
    Http htp = new Http();
    HttpRequest req = new HttpRequest();
    req.setTimeout(30000);
    String Endpoint = 'callout:Claim_API_Endpoint_Mulesoft';
    req.setEndpoint(Endpoint);
    req.setMethod('POST');
    req.setHeader('client_id', '{!$Credential.Username}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('X-Request-ID', '12');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(payload);
    HttpResponse res = htp.send(req);

    System.debug(res.getStatus());
    ATI_SALES_API_Services.ClaimApiRes respParsed = new ATI_SALES_API_Services.ClaimApiRes();
    respParsed = (ATI_SALES_API_Services.ClaimApiRes) JSON.deserialize(
      res.getBody(),
      ATI_SALES_API_Services.ClaimApiRes.class
    );

    ATI_C_E__c ce = ATI_SALES_API_Services.getClaimHeader(claimId);

    if (respParsed.message == 'success') {
        ATI_C_E__c ceUpdated = new ATI_C_E__c();
        ceUpdated.Id = ce.Id;
        ceUpdated.ATI_SALES_Document_Number__c = respParsed.SAP_Document_Number;
        ceUpdated.ATI_SALES_Succesful_Integration_Flag__c = true;

        Update ceUpdated;
    } else {
      ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();
      err.outputType = true;
      err.className = 'ATI_SALES_Incentive_Claim_API_Services';
      err.methodName = 'sendIncentiveClaim';
      ATI_SALES_API_Services.IncentiveClaimWrapper inc = (ATI_SALES_API_Services.IncentiveClaimWrapper) JSON.deserialize(payload, ATI_SALES_API_Services.IncentiveClaimWrapper.class);
      String opPayload = JSON.serialize(inc.header);
      err.output = opPayload;
      err.errorMessage = respParsed.message + ' \n '+ 'Error Details:'+respParsed.details;
      ATI_ErrorLogService.logError(err);

      ATI_C_E__c ceUpdated = new ATI_C_E__c();
      ceUpdated.Id = ce.Id;
      ceUpdated.ATI_SALES_Integration_Retry_Flag__c = true;

      Update ceUpdated;

      System.debug(respParsed.message);
      System.debug('Error Details:'+respParsed.details);
      System.debug(res.getHeaderKeys());
      system.debug(opPayload);
    }
    
    //API Process End
  }

  @InvocableMethod(
    label='Send Claim Header'
    description='Send the Claim Header data through integration interface.'
  )
  public static void sendClaimHeader(List<String> claim) {
    sendIncentiveClaim(claim[0]);
  }
}