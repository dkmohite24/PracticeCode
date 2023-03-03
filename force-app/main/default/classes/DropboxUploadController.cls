public with sharing class DropboxUploadController {
    private String apiKey;
    private String apiSecret;
    private String redirectURI;
    private String Dropbox_Account_endpoint;
    private String Dropbox_files_endpoint;
    private String Dropbox_OAuth_authorize;
    private String Dropbox_OAuth_token;
    private String authorizationCode;
    private String refreshToken;
    
    public String code { get; set; }
    public String username { get; set; }
    public String fileName { get; set; }
    public Blob fileBody { get; set; }
    public Boolean success { get; set; }
    public Boolean connected { get; set; }
    
    public DropboxUploadController() {
        connected = false;
        success = false;
        apiKey = 'kk8pvgakgi3f9qq'; //  dropbox apikey
        apiSecret = 'pfs4b72hm12pkf7'; // dropbox api secret
        redirectURI = 'https://dkmohite24-dev-ed--c.ap16.visual.force.com/apex/DropboxIntegration'; // url of the vf page
        Dropbox_Account_endpoint = 'https://api.dropboxapi.com/2/users/get_current_account';
        Dropbox_files_endpoint = 'https://content.dropboxapi.com/2/files/upload';
        Dropbox_OAuth_authorize = 'https://www.dropbox.com/oauth2/authorize';
        Dropbox_OAuth_token = 'https://api.dropboxapi.com/oauth2/token';
        
        code = ApexPages.currentPage().getParameters().get('code');
        system.debug('Code+++'+code);
        getAuthorizationCode();
        if(code != null) {
            connected = true;
            
            +
                authorizationCode = code;
            
            getRefreshToken();
            retrieveUserInfo();
        }
    }
    
    
    public PageReference getAuthorizationCode() {
        String uri = Dropbox_OAuth_authorize +
            '?client_id=' + apiKey +
            '&response_type=code' +'&token_access_type=offline'+
            '&redirect_uri=' + redirectURI;
        system.debug('Uri'+uri);
        PageReference pr = new PageReference(uri);
        pr.setRedirect(true);
        
        System.debug('uri'+uri);
        System.debug('pr'+pr);
        
        return pr;
        
    }
    
    private void getRefreshToken() {
        if(authorizationCode != null) {
            try {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint(Dropbox_OAuth_token);  
                string bodyRequest = '';
                bodyRequest = 'code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8');
                bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(apiKey, 'UTF-8');
                bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(apiSecret, 'UTF-8');
                bodyRequest+= '&redirect_uri=' + EncodingUtil.urlEncode(redirectURI, 'UTF-8');
                bodyRequest+= '&grant_type=authorization_code';
                system.debug('bodyRequest : '+bodyRequest);	
                req.setBody(bodyRequest);    
                req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setMethod('POST');
                req.setTimeout(60*1000);
                system.debug('req : '+req);
                HttpResponse res = h.send(req);  
                system.debug('Response e : '+res.getBody());
                map<string, string> jsonValues = new map<string, string>();
                jsonValues = parseJSONToMap(res.getBody());
                DropboxInteration1__c Dropbox = new DropboxInteration1__c();
                
                if(jsonValues.containsKey('error')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox 1.'));
                }
                else {
                    refreshToken = jsonValues.get('access_token');
                    system.debug('access_token'+refreshToken);
                    system.debug('refresh_token======'+jsonValues.get('refresh_token'));
                    String Name = 'QuickBooks Setting Info';
                    String accessToken = jsonValues.get('access_token');
                    String refreshToken = (String)jsonValues.get('refresh_token');
                    String expiresIn = jsonValues.get('expires_in');
                    Dropbox.Access_Token__c = accessToken;
                    Dropbox.Refresh_token__c = refreshToken;
                    Dropbox.Expired_in__c = Decimal.ValueOf(expiresIn);
                    //upsert Dropbox;
                }
            }
            catch(Exception e) {
                system.debug('Exception e'+ e);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox 2.'));
            }
        }
        else 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox 3.'));
    }
    
    
    // method that returns the username of the connected dropbox account
    private void retrieveUserInfo() {
        if(refreshToken != null) {
            try {
                system.debug('refreshToken+++'+refreshToken);
                Http h = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(Dropbox_Account_endpoint);
                req.setHeader('Authorization', 'Bearer '+refreshToken);
                req.setMethod('POST');
                req.setTimeout(60*1000);
                system.debug('req+++'+req);
                HttpResponse res = h.send(req);
                map<string, string> jsonValues = new map<string, string>();
                system.debug('res.getBody'+res.getBody());
                jsonValues = parseJSONToMap(res.getBody());
                system.debug('jsonValues'+jsonValues);
                if(jsonValues.containsKey('error')){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.4'));
                }
                else {
                    username = jsonValues.get('email');
                }
            }
            catch(Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.5'));
            }
        }
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.6'));
    }
    
    
    // method that uploads files to dropbox
    public Boolean uploadToDropBox(Blob file, String filename) {
        try {
            blob B = fileBody;
            System.debug('fileBody'+fileBody);
            System.debug('fileBody+++'+filename);
            System.debug('fileBody'+refreshToken);
            String bodyEncoded = EncodingUtil.base64Encode(fileBody);
            System.debug('fileBody'+bodyEncoded);
            System.debug('fileBody'+bodyEncoded);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://content.dropboxapi.com/2/files/upload');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'multipart/form-data');
            req.setHeader('Authorization', 'Bearer '+refreshToken);
            req.setHeader('Content-Type', 'application/octet-stream');
            req.setHeader('Dropbox-API-Arg','{"path":"/Demo/'+fileName+'.pdf","mode":"add","autorename":true,"mute":false,"strict_conflict":false}');
            req.setBodyAsBlob(B);
            req.setTimeout(120000);
            HttpResponse resp = http.send(req);
            System.debug('resp'+resp);
            System.debug('req'+req);
            System.debug('resp'+resp);
            System.debug('req'+req);
            System.debug('fileBody'+fileBody);
            System.debug('fileBody'+fileBody);            
            map<string, string> jsonValues = new map<string, string>();
            jsonValues = parseJSONToMap(resp.getBody());
            System.debug('resp'+resp);
            System.debug('req'+req);
            if(jsonValues.containsKey('error')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+jsonValues.get('error'));
                ApexPages.addMessage(myMsg);
                return false;
            }
            else
                return true;
        }
        catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Files couldn\'t be uploaded to Dropbox.7'));
            return false;
        }
    }
    
    private map<string, string> parseJSONToMap(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        
        map<string, string> jsonMap = new map<string, string>();
        string keyValue = '';
        string tempValue = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonMap.put(keyValue, tempValue); 
            }
        }
        return jsonMap;
    }
    
    public void uploadFiles(){
        success = uploadToDropBox(fileBody, fileName);
        
    }
}