trigger phoneChangeAc on Contact (After update) {

    list<Account> updateAc = new list<account>();
    Set<Id> SetID = new Set<id>();
    system.debug(''+SetID);
    
        for(contact conold: Trigger.old){
        system.debug('conold;:::::'+conold.phone);
            for(Contact Con: Trigger.new){
                system.debug('con;:::::'+con.phone);
                if(con.phone != conold.phone){
                    system.debug('con.phone;:::::'+con.phone);
                    system.debug('conold.phone;:::::'+conold.phone);
                    SetID.add(Con.Accountid);
                    system.debug('SetID;:::::'+SetID);
                    }
               } 
        }
        
        if (setID.size() > 0){
            
           List<Account> Acc = [select id, phone from account where id in:SetId];
           system.debug('Acc Soql;:::::'+Acc);
           for(contact con2:trigger.new){
               for(Account Aco: Acc ){
                   
                   Aco.phone = con2.phone;
                   updateAc.add(Aco);
                   }
               }
               system.debug('updateAc;:::::'+updateAc);
               update updateAc;
            
           }
    

}