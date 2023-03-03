Public class PathController {
    @AuraEnabled
    public static list<contract>getcondata(string ContractId){
        list<contract>conretrive = new list <contract>();
		System.debug('ContractId'+ContractId);
        conretrive =[select id , status from contract where Id =:ContractId ];
        system.debug('ListRetrive'+conretrive);
        return conretrive;
        
    }
    @AuraEnabled
    public static void updatestatus(string selectedStep , string ContractId){
        
        list<Contract>Conupdatelist = new list<Contract>();
        Contract Conupdate = new contract() ;
        Conupdate.Status = selectedStep;
        Conupdate.Id = ContractId ;
        system.debug('selectedStep'+selectedStep);
        system.debug('selectedStep'+ContractId);
        Conupdatelist.add(Conupdate);
        update Conupdatelist;
    }
    
   
}