global class DropBoxUploadBatchApex implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Set<Id> setContentDocumentIdBatch = new Set<Id>();
    global DropBoxUploadBatchApex(Set<Id> setContentDocumentId){
        this.setContentDocumentIdBatch = setContentDocumentId;
        system.debug('setContentDocumentIdBatch'+setContentDocumentIdBatch);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('setContentDocumentIdBatch'+setContentDocumentIdBatch);
        String soqlQuery = 'SELECT ContentSize,FileExtension,FileType,Id,IsLatest,Title,VersionData FROM ContentVersion where ContentDocumentId IN: setContentDocumentIdBatch';
        system.debug('soqlQuery'+soqlQuery);
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<ContentVersion> scope){
        //list<IntBox__c> BoxList = [SELECT id,Access_Token__c, Refresh_Token__c,ClientID__c,ClientSecret__c FROM IntBox__c 
                                //   where name='DropBox' limit 1];
       // String AccessToken = BoxList[0].Access_Token__c; 
       String AccessToken = 'sl.A90WDwenTx0CanBVzlTTtlGdMK6F7ki4lfLmK8-s2mCEU0guexVREBZMExVPAFueqfkVyw36zjfgn4Lq3wrajTnxyUN0TykBXjeosgIgIoSaN_QuDL9matBlhS6bnqLFZ6MsCLU';
        for (ContentVersion ContentFile : scope){	
            
            try{
                
                String files_Title=ContentFile.Title;
                blob files_blob = ContentFile.VersionData;
                system.debug('files_blob'+files_blob);
                system.debug('files_blob'+files_Title);
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
            catch(Exception e){
                System.debug('Error-' );   
            }
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}