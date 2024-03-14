@RestResource(urlMapping='/updateCurrencyTyperecord/*')
 
global with sharing class updateCurrencyType {
     public static string path = '/services/data/v28.0/sobjects/CurrencyType/';

    @httppost
    global Static string fetchCurrencyType(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        string jsonString=req.requestBody.tostring();
     
        List<String> extractedContent = new List<String>();
         Pattern pattern = Pattern.compile('\\{([^}]*)\\}');
         Matcher matcher = pattern.matcher(jsonString);
        while (matcher.find()) {
        extractedContent.add(matcher.group());
         }
        System.debug('extractedContent'+extractedContent);
        System.debug('extractedContent'+extractedContent.size());


      
        For(string obj : extractedContent){
                   system.debug('obj '+obj);
          Http h = new Http(); 
        HttpRequest reqst = new HttpRequest(); 
        reqst.setEndpoint(URL.getOrgDomainURL().toExternalForm() + updateCurrencyType.path); 
        reqst.setMethod('POST'); 
        reqst.setBody(obj); 
        reqst.setHeader('Authorization' , 'OAuth ' + UserInfo.getSessionId());
        reqst.setHeader('Content-Type' , 'application/json' );
        HttpResponse resp = h.send(reqst); 
        }

        return 'Success';

    }
}