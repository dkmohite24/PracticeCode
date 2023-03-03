public Class InsertMultipleHotel{
    Public static Void InsertMultipleHotelMeth(){
    
    List <Hotel__c> listh = New list<Hotel__c>();
    For(integer i=1; i<=100;i++){
    
        Hotel__c h = new Hotel__c();

        h.Name = 'JW Marroite'+i;
        h.State__c = 'Maharashtra';
        h.City__c = 'pune';
        h.Street_Address__c = 'Ramadheer Road';  
        listh.add(h);
        system.debug('Valuein h:' +h);
    
    }
    
    system.debug('Valuein listh:'+listh);
    insert listh;
    
    }


}