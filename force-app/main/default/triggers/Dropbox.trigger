trigger Dropbox on ContentDocumentLink (After insert) {
    if (trigger.isafter && trigger.isinsert){
        Set<Id> setContentDocumentId = new Set<Id>(); 
        List <Opportunity> lstParentToUpdate = new List<Opportunity>();
        List<ContentDocumentLink> ContentDocumentLink = new List<ContentDocumentLink>();
        for (ContentDocumentLink atchmnt : trigger.new) {
            system.debug('Attachment'+atchmnt);
            ContentDocumentLink newFile = atchmnt.clone();
            system.debug('newFile'+newFile);
            String str = atchmnt.LinkedEntityId;
            system.debug('str'+str);
            if (str.startsWith('006')) {
                setContentDocumentId.add(atchmnt.ContentDocumentId);
            }
        }
        system.debug('setContentDocumentId.size()++++++'+setContentDocumentId);
        system.debug('setContentDocumentId.size()++++++'+setContentDocumentId.size());
        if(setContentDocumentId.size()>0){
            database.executeBatch(new DropBoxUploadBatchApex(setContentDocumentId),100);//Calling batch class.
        }
        //list<ContentVersion> contentversionlist = [SELECT ContentSize,FileExtension,FileType,Id,IsLatest,Title,VersionData FROM ContentVersion
                                                  // where ContentDocumentId IN:setContentDocumentId];

       // system.debug('contentvirsion'+contentversionlist);
        
        /*for(ContentVersion ContentFile : contentversionlist){
            
            system.debug('AccessToken'+AccessToken);
            String files_Title=ContentFile.Title;
            blob files_blob = ContentFile.VersionData;
            system.debug('files_blob'+files_blob);
            system.debug('files_blob'+files_Title);
            if (files_blob != null && files_Title != null){
                TriDropBoxFileUpload.uploadToDropBox(files_blob,files_Title,AccessToken); // call future method
            }
        }*/
    } 
    
}