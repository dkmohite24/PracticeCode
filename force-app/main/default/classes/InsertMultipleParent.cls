public class InsertMultipleParent{
    public static void NewMultipleParentMeth(){    
    List <Parent__c> listt = New list<Parent__c>();
    For(integer i=1; i<=100;i++){
    
    Parent__c t = New Parent__c();
    
    t.Name = 'KIshorlal'+i;
    t.Email_Address__c = 'Kishorlal@gmail.com'+i;
    t.Mobile_number__c = '987458455'+i;
    t.Address__c = 'KING colony kingeshpur';

    listt.add(t);
    }
    system.debug('ValueIn listt:'+listt);
    insert listt;   
    
    }
  
    
    

}