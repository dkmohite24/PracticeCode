/**
 * @description       : 
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : Abhishek Mohapatra
**/
@RestResource(urlMapping='/caselist/*')
global with sharing class ATI_TAC_API_CaseList {


    /**
    * @description HTTP Post method used to handle the REST request from outside of Salesforce and returns the list of cases as response body on the basis of dealer number prtovided. [USER STORY 32606]
    * @author Abhishek Mohapatra | 07-06-2023 
    **/
    @HttpPost
    global static void getCases(){
        System.debug('Invoked REST getCases');
        RestRequest req = RestContext.request;
        String uriToProcess = req.requestURI;
       
        System.debug('request message'+ req);
        RestResponse res = RestContext.response;
        
        String processName = uriToProcess.substring(req.requestURI.lastIndexOf('/')+1);

        String requestBody = req.requestBody.toString();
       
        res = ATI_TAC_API_Services.getDealerCasesAPIHandler(processName, requestBody);
        
        
    }

    
}