/* Name: ATI_RESTUtility
Description : ATI_RESTUtility Webservices
Author : Tavant (TY)
History:
VERSION     AUTHOR               DATE                DETAIL                 UserStory/Req#
1.0 -     Tavant (TY)         Mar 25th 2021      INITIAL DEVELOPMENTs
*/
public class ATI_RESTUtility {
    
    public static HttpRequest buildHttpRequest(ATI_HttpRequestParameter reqParam){
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        
        if (reqParam.endPoint != null && !String.isBlank(reqparam.endPoint)) { 
            request.setEndpoint(reqParam.endPoint); 
        }
        
        if(reqParam.httpMethod != null && !String.isBlank(reqparam.httpMethod)){ 
            request.setMethod(reqParam.httpMethod); 
        }
        
        if((reqParam.httpHeaderConType != null && !String.isBlank(reqParam.httpHeaderConType)) 
           && (reqParam.httpHeaderConValue != null && !String.isBlank(reqParam.httpHeaderConValue))){        
               request.setHeader(reqParam.httpHeaderConType, reqParam.httpHeaderConValue);
           }
        
        if((reqParam.httpHeaderReqId != null && !String.isBlank(reqParam.httpHeaderReqId)) &&
          (reqParam.httpHeaderReqValue != null && !String.isBlank(reqParam.httpHeaderReqValue))){        
				request.setHeader(reqParam.httpHeaderReqId, reqParam.httpHeaderReqValue);
              //request.setHeader(reqParam.httpHeaderClientId, reqParam.httpHeaderClientSecret);
           } 
        if((reqParam.httpHeaderClientId != null && !String.isBlank(reqParam.httpHeaderClientId)) &&
          (reqParam.httpHeaderClientIdValue != null && !String.isBlank(reqParam.httpHeaderClientIdValue))){        
				request.setHeader(reqParam.httpHeaderClientId, reqParam.httpHeaderClientIdValue);
              //request.setHeader(reqParam.httpHeaderClientId, reqParam.httpHeaderClientSecret);
           }
        
         if((reqParam.httpHeaderClientSecret != null && !String.isBlank(reqParam.httpHeaderClientSecret)) &&
          (reqParam.httpHeaderClientSecretValue != null && !String.isBlank(reqParam.httpHeaderClientSecretValue))){        
				request.setHeader(reqParam.httpHeaderClientSecret, reqParam.httpHeaderClientSecretValue);
              //request.setHeader(reqParam.httpHeaderClientId, reqParam.httpHeaderClientSecret);
           }
        
        if((reqParam.httpHeaderAuthz != null && !String.isBlank(reqparam.httpHeaderAuthz)) 
           && (reqParam.httpHeaderAuthVal != null && !String.isBlank(reqparam.httpHeaderAuthVal))){
               request.setHeader(reqParam.httpHeaderAuthz, reqParam.httpHeaderAuthVal);
           }
        
        if(reqParam.httpTimeout != null){ request.setTimeout(reqParam.httpTimeout); }        
        if(reqParam.httpBody != null && !String.isBlank(reqparam.httpBody)){ request.setBody(reqParam.httpBody); }
        system.debug('request>>>> '+request);     
        return request;
    }
    
    public static HttpResponse executeService(HttpRequest request){   
        system.debug('response>>>> '+request);
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        try{
            response = http.send(request);
            system.debug('response>>>> '+response.getBody());
        }
        catch(Exception ex) {
            //ALSN-199 Create log if an exception is triggered
            String errorTxt = 'RestUtility - Error Message: ' + ex.getMessage() + '\n LineNumber: ' + ex.getLineNumber();
            ATI_LogService.createLogForAccess(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,errorTxt);
            //ALSN-199 end
            throw ex;
        }
        return response;
    }
}