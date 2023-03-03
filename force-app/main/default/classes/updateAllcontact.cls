public class updateAllcontact {
    Public static void updateAllcontactmeth(){
    
    List<contact>Mylist = new list<contact>();
    mylist = [SELECT Email,Id,Languages__c,LastActivityDate,LastName,Name,OwnerId,Phone FROM Contact where name like 'm%'];
    
    list<contact>updatedparent = new list<contact>();
    system.debug('mylist'+mylist);
    for (contact obj: mylist){
    
        obj.LastName = obj.LastName;
        obj.Email = obj.LastName+'@gmail.com';
        //obj.Address__c = obj.name+obj.Address__c;
        updatedparent.add(obj);
        }
        system.debug('UpdatedListDAta'+updatedparent);
        if(updatedparent.size()>0)
        {system.debug('UpdatedListDAta'+updatedparent.size ());
        
        Update updatedparent;
    }
    }

}