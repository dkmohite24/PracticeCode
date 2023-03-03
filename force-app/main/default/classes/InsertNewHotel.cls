Public class InsertNewHotel{
    public Static void InsertNewHotelmeth(){
    
    Hotel__c h = new Hotel__c();

    h.Name = 'Pride';
    h.State__c = 'Maharashtra';
    h.City__c = 'pune';
    h.Street_Address__c = 'Ramadheer Road';  
    
    system.debug('Valuein h:' +h);
    insert h;
    }
}