public class contentDocumentVersionHandler {
    public static void onAfterInsert(list<ContentVersion> fileList){
        System.debug('Check this'+fileList);
        
        list<ContentDocumentLink> insertCdl =new list<ContentDocumentLink>();
        SET<ID> contentDocumentID = new SET<ID>();
        
        for(ContentVersion c : fileList)
        {
            contentDocumentID.add(c.ContentDocumentId);   
        }
        
        try{
        ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'Incentive' LIMIT 1];
        //ContentFolder cf =[SELECT Name,ParentContentFolderId FROM ContentFolder WHERE ParentContentFolderId =:ws.RootContentFolderId];
        //System.debug('Workspace'+ws);
        //System.debug('Folder'+cf);
        ContentVersion getVersion =new ContentVersion();
        getVersion = [Select Id,ContentDocumentId,createdBy.Name,Title from ContentVersion  WHERE ContentDocumentId IN: contentDocumentID limit 1];
        List<ContentDocumentLink> cDocumentLink = new List<ContentDocumentLink>();
        
        cDocumentLink=[SELECT ID,ContentDocumentId,LinkedEntity.type,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentID];
        if(cDocumentLink!=NULL){
            for(ContentDocumentLink c : cDocumentLink)
            {
                System.debug('c.LinkedEntity.Type'+c.LinkedEntity.Type);
                System.debug('userinfo.getuserid()'+userinfo.getuserid());
                
                if(getVersion.Title.contains('Incentive'))
                {
                    ContentDocumentLink cd = new ContentDocumentLink();        
                    cd.ContentDocumentId = getVersion.ContentDocumentId;
                    cd.ShareType = 'I';
                    cd.Visibility = 'AllUsers'; 
                    cd.LinkedEntityId = ws.Id; 
                    insertCdl.add(cd);
                }
            }
        }
        
        if(insertCdl.size() > 0)
        {
            insert insertCdl; 
        }
        }
        catch(Exception e){
          System.debug(e.getMessage());
        }
    }
}