public class InsertMultipleTeacher{
    public static void NewMultipleTeacherMeth(){    
    List <Teacher__c> listt = New list<Teacher__c>();
    For(integer i=1; i<=100;i++){
    
    Teacher__c t = New Teacher__c();
    
    t.Name = 'Shiv'+i;
    t.Email_Address__c = 'Shiva@gmail.com'+i;
    t.Mobile_number__c = '95489878'+i;
    t.Specialization_In_Subject__c = 'English';
    listt.add(t);
    }
    system.debug('ValueIn listt:'+listt);
    insert listt;   
    
    }
  
    
    

}