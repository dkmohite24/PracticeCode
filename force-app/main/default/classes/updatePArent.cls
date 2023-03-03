public class updatePArent{
    public static void upateparentmeth(){
        
        List<parent__C> myList = new List<Parent__c>();
        myList = [SELECT Address__c,Email_Address__c,Id,Mobile_number__c FROM Parent__c Where Name like 'k%' limit 10];
        system.debug('Data from parents'+mylist);
        list<parent__c> updatedlist = new list<Parent__c>();
        for(parent__C obj : myList )
        {
            obj.Mobile_number__c = obj.Mobile_number__c + 99;
            obj.Address__c = obj.Address__c + 'Jalna';
            obj.id = obj.id;
            updatedlist.add(obj);
           
            
        }
        system.debug('parent updated list'+updatedlist);
        if(updatedlist.size() > 0)
        {system.debug('sizefunction'+updatedlist.size());

            update updatedlist;//this seems to just update the list. How do I actually update the custom object?
        }
        }
        }