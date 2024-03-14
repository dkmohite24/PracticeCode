/**
** Created By : Sapna Kumari
**/
public with sharing class PRPC_FacilityAudit {
    @AuraEnabled
    public static PRPCO_Facility_Audit__c Recorddatafetch(String FetchrecordId){
        PRPCO_Facility_Audit__c FACAUD = [select Id,Name,Audit_Date__c,Score__c,Distributor__c,Location__c from PRPCO_Facility_Audit__c where Id=:FetchrecordId];
        return FACAUD;
    } 
    
    @AuraEnabled
    public static PRPCO_Facility_Audit__c Recorddatafetchdynamically(String Distributorr,String locationn,Date AuditDatee){
        System.debug('Location'+locationn+' DisLocation'+Distributorr+AuditDatee+'AuditDatee');
        Account acc = [select Id,Name from Account where CitySAPField__c =: locationn];
        List<PRPCO_Facility_Audit__c> FACAUD = new List<PRPCO_Facility_Audit__c>();
        FACAUD = [select Id,Name,Audit_Date__c,Score__c,Distributor__c,(SELECT Id, Name,ParentId FROM Attachments),Location__c from PRPCO_Facility_Audit__c where Location__c=:acc.Id AND Distributor__c=:Distributorr AND Audit_Date__c=:AuditDatee limit 1];
        System.debug(FACAUD);
        if(FACAUD.size()>0){
            return FACAUD[0];
        }
        else{
            return null;
        }
    } 
    
    @AuraEnabled
    public static void Recordcreatewithoutattachment(String Location,String DisLocation,Date Audit,Double Score,PRPCO_Facility_Audit__c fac, String status){
        System.debug('Location'+Location+' DisLocation'+DisLocation+' fac' +fac); 
        Account acc = new Account();
        if(Location!= ''){
            acc= [select Id,Name,SAP_ID__c from Account where CitySAPField__c =: Location];
            fac.Location__c =acc.Id;
            fac.Location_SAP_Number__c = acc.SAP_ID__c;
        }
        if(DisLocation!= ''){
            acc = [select Id,Name,SAP_ID__c from Account where Id=:DisLocation];
            fac.Distributor__c = DisLocation;
            fac.Distributor_SAP_Number__c = acc.SAP_ID__c;
        }
        fac.Audit_Date__c = Audit;
        fac.Score__c = Score;
        fac.Facility_Audit_Status__c=status;
        upsert fac;
    } 
    
    @AuraEnabled
    public static Id saveChunk(String Location,String DisLocation,Date Auditdate,Double Score,PRPCO_Facility_Audit__c fac,String fileName, String base64Data, String contentType, String fileId,String status) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks
        System.debug('Location'+Location+' DisLocation'+DisLocation+' Score' +Score + 'fac'+fac + 'fileId'+fileId);
         //upsert the facility record
        Account acc = new Account();
        if(Location!= ''){
            acc= [select Id,Name,SAP_ID__c from Account where CitySAPField__c =: Location];
            fac.Location__c =acc.Id;
            fac.Location_SAP_Number__c = acc.SAP_ID__c;
        }
        if(DisLocation!= ''){
            acc = [select Id,Name,SAP_ID__c from Account where Id=:DisLocation];
            fac.Distributor__c = DisLocation;
            fac.Distributor_SAP_Number__c = acc.SAP_ID__c;
        }
        fac.Audit_Date__c = Auditdate;
        fac.Score__c = Score;
        fac.Facility_Audit_Status__c = status;
        upsert fac;
        //delete the existing file from record
        if(fileName != ''){
            List<Attachment> prevattach = [Select Id, Name from Attachment where parentId=:fac.Id];
            if(prevattach.size() > 0){
                if(fileId == ''){
                    DELETE prevattach;
                }
            }
        }
       
        
        //attachment upload
        String parentId=fac.Id;
        System.debug('parentId'+parentId);
        System.debug('fileId'+fileId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(String parentId, String fileName, String base64Data, String contentType) {
        System.debug('parentId'+parentId+' base64Data'+base64Data+' contentType' +contentType);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        
        return oAttachment.Id;
    }
    
   @TestVisible private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
}