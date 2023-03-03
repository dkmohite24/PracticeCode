public Class Task6AccountPhoneTri{
    public void AccountPhoneContact(list<contact> NewCon,list<contact> OldCon,Map<Id,Contact> newMapContact,
                                Map<Id,Contact> oldMapContact){
    //list<Account> AcsoqlMap = [select Id, name, phone from account where id In:  ];
    //system.debug('New newMapContact:::'+newMapContac);                       
    system.debug('New newMapContact:::'+newMapContact);
    system.debug('New OLdMapContact::::'+OldMapContact);
    list<Account>UpAc = new list<account>();
    List<Id> AcId = new list<Id>();
    system.debug('New NewCon'+NewCon);
    system.debug('New OldCon'+OldCon);
    for(Contact AcIdNew: NewCon){
        AcId.add(acIdNew.AccountId);
        
        }
     system.debug('New AcId'+AcId);
     
     list<Account> Acsoql = [select Id, name, phone from account where id In: AcId ];
     system.debug('New Acsoql'+Acsoql);
     for(Contact ConPh: NewCon){
         for(Account Ac: Acsoql){
             Ac.Phone = ConPh.phone;
             UpAc.Add(Ac);
             }
             update UpAc;
             system.debug('New update UpAc'+UpAc);
         }
        
    } 
    
}