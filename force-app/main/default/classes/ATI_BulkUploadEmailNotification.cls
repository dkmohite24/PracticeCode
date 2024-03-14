/* Name : ATI_BulkUploadEmailNotification
Description : This class will trigger mail to user for BulkUpload Jobs
Author :Tavant(TY)
History :
VERSION      AUTHOR               DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant(TY)         20/01/2021          INITIAL DEVELOPMENT
*/
public without sharing class ATI_BulkUploadEmailNotification {
    public static void sendBulkUploadCompletedEmail(Id batchLogId){
        List<WOD_2__Batch_Log__c> batchLog = [SELECT Id,OwnerId,ATI_Status__c,(SELECT Id,Title,FileType,ContentDocumentId FROM AttachedContentDocuments WHERE (Title Like 'BulkUploadSuccess_%' OR Title Like 'BulkUploadFailure_%')) FROM WOD_2__Batch_Log__c WHERE Id=:batchLogId];
        if(!batchLog.isEmpty() && !batchLog.get(0).AttachedContentDocuments.isEmpty()) {
            List<AttachedContentDocument> attachedContentDocLst = batchLog.get(0).AttachedContentDocuments;
            Set<Id> contentDocIdsSet = new Set<Id>();
            Map<String,ContentVersion> contentDocumumentIdWithData = new Map<String,ContentVersion>();
            for(AttachedContentDocument contentdoc : attachedContentDocLst){
                contentDocIdsSet.add(contentdoc.ContentDocumentId);
            }
            List<ContentVersion> contentVersionLst = [SELECT Id,VersionData,FileType,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:contentDocIdsSet];
            for(ContentVersion conVer : contentVersionLst){
                contentDocumumentIdWithData.put(conVer.ContentDocumentId,conVer);
            }
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for(AttachedContentDocument file : attachedContentDocLst) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(file.Title+'.csv');
                if(contentDocumumentIdWithData.containsKey(file.ContentDocumentId)){
                    efa.setBody(contentDocumumentIdWithData.get(file.ContentDocumentId).VersionData);
                }
                efa.setContentType('application/vnd.ms-excel');
                attachments.add(efa);
            }
            List<EmailTemplate> bulkUploadTemplate = [SELECT Id FROM EmailTemplate WHERE Name='ATI_BulkUploadBatchLogCompletedTemplate'];
            // TASK0207905-Adding the Orgwide email address.
            String emailAdress = String.valueOf(system.Label.ATI_InternalUserEmail);
            List<OrgWideEmailAddress> fromEmailId = [select Id from OrgWideEmailAddress where Address =: emailAdress];
            
            if (!bulkUploadTemplate.isEmpty() && !fromEmailId.isEmpty()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(bulkUploadTemplate[0].Id);
                mail.setOrgWideEmailAddressId(fromEmailId[0].Id);
                mail.setWhatId(batchLog[0].Id);
                mail.setTargetObjectId(batchLog[0].OwnerId);
                mail.setFileAttachments(attachments);
                mail.setSaveAsActivity(false);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    }
}