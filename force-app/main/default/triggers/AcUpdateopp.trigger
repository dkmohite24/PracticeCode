trigger AcUpdateopp on Account (before update) {
    IF(trigger.isbefore && trigger.isupdate){
        set<id>AcId = new set<id>();
        for(account acc: trigger.new){
            AcId.add(acc.id);
        }
        
        list<opportunity> Oplist = [select id,Amount from opportunity where Id IN:AcId ];
        system.debug('Oplist'+Oplist);
        list<opportunity> newop = new list<opportunity>();
        For(opportunity opp:Oplist){
           opp.Amount = decimal.valueof('100');
            system.debug('opp.Amount'+opp.Amount);
           newop.add(opp); 
        }
        update newop;   
    }

}