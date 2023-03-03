public class updateMultipleteacher{
    public static void updateMultipleteachermeth(){
    
        list<Teacher__c>myList = new list<Teacher__c>();
        myList = [SELECT CreatedDate,Email_Address__c,Id,LastModifiedDate,Mobile_number__c,Name FROM Teacher__c 
        where Name like's%' order by createddate deSC];
        system.debug('DAta'+mylist);
        list<Teacher__c>UpdatedList =new list<Teacher__c>();
        for(Teacher__c t: myList){
        
            t.name = t.name+1;
            t.Email_Address__c = t.name+'@gmail.com';
            t.Mobile_number__c = '999999999';
            UpdatedList.add(t);
            system.debug('UpdatedListDAta'+UpdatedList);}
        if(UpdatedList.size()>0)
        {system.debug('UpdatedListDAta'+UpdatedList.size ());
        
        Update UpdatedList;
        }
    }

}