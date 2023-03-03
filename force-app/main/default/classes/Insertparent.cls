public class Insertparent{
    public static void InsertNewParentMeth(){
    
    Parent__c p = New parent__c();
    
    p.Name = 'ramanand';
    p.Email_Address__c = 'ramanand@gmail.com';
    p.Mobile_number__c = '5544455';
    p.Address__c = 'ramameshwar colony';
    system.debug('ValueIn p:'+p);
    insert p;
    }
 }