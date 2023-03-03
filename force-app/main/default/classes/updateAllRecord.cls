public class updateAllRecord {
    Public static void updateAllRecordmeth(){
    
    List<parent__C>Mylist = new list<parent__c>();
    mylist = [SELECT Address__c,CreatedDate,Email_Address__c,Id,LastViewedDate,Mobile_number__c,Name FROM Parent__c];
    
    list<parent__c>updatedparent = new list<parent__C>();
    system.debug('mylist'+mylist);
    for (parent__c obj: mylist){
    
        obj.name = obj.name;
        obj.Email_Address__c = obj.name+'@gmail.com';
        obj.Address__c = obj.name+obj.Address__c;
        updatedparent.add(obj);
        }
        system.debug('UpdatedListDAta'+updatedparent);
        if(updatedparent.size()>0)
        {system.debug('UpdatedListDAta'+updatedparent.size ());
        
        Update updatedparent;
    }
    }

}