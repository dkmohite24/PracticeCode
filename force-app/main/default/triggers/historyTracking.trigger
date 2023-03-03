trigger historyTracking on Account (After update) {
    if (trigger.isAfter && trigger.isupdate){
        list<AccountHistory> trackingSoql = [SELECT AccountId, OldValue, NewValue, IsDeleted, Id, Field, CreatedBy.Name From AccountHistory 
                                             WHERE AccountId IN:trigger.new AND field= 'owner' ORDER BY CreatedDate DESC];
       system.debug('trigger.new'+trigger.new);
        system.debug('trackingSoql'+trackingSoql);
        for(AccountHistory tList : trackingSoql){
            system.debug(tList);
        }
    }

}