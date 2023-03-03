public class TriDropBoxFileUpload {
    @future(callout=true)
    public static void uploadToDropBox(Blob files_blob, String files_Title,string AccessToken) {
        try {
            System.debug('fileBody'+files_blob);
            System.debug('fileBody+++'+files_Title);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://content.dropboxapi.com/2/files/upload');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'multipart/form-data');
            req.setHeader('Authorization', 'Bearer '+AccessToken);
            req.setHeader('Content-Type', 'application/octet-stream');
            req.setHeader('Dropbox-API-Arg','{"path":"/Demo/'+files_Title+'.pdf","mode":"add","autorename":true,"mute":false,"strict_conflict":false}');
            req.setBodyAsBlob(files_blob);
            req.setTimeout(120000);
            HttpResponse resp = http.send(req);
            System.debug('resp'+resp);
            System.debug('req'+req);            
            Map<String,Object> jsonValues = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());        
            system.debug('jsonResp' + jsonValues);
            System.debug('resp'+resp);
            System.debug('req'+resp.getBody());
            if(jsonValues.containsKey('error')){
                System.debug('error in jsonValues');
            }
            else
                System.debug('File uploaded successfully');
        }
        catch(Exception e) {
            System.debug('error in catch');
        }
    }
    
}