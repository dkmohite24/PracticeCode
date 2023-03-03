trigger UploadFileOppDropbox on Attachment (before insert) {
    Set<Id> setOpportunityId = new Set<Id>(); 
    List <Opportunity> lstParentToUpdate = new List<Opportunity>();
    
    for (attachment atchmnt : trigger.new) {
        system.debug('Attachment'+atchmnt);
        String str = atchmnt.ParentId;
        system.debug('str'+str);
        if (str.startsWith('006')) {
            setOpportunityId.add(atchmnt.ParentId);
        }
    }
    
    
    List<sobject>ListParent = [select Id , name from Opportunity where id IN:setOpportunityId];
    
}