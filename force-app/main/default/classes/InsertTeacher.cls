public class InsertTeacher{
    public static void NewTeacherMeth(){
    
    Teacher__c t = New Teacher__c();
    
    t.Name = 'Krishna';
    t.Email_Address__c = 'krishna@gmail.com';
    t.Mobile_number__c = '45444555';
    t.Specialization_In_Subject__c = 'Maths';
    system.debug('ValueInt:'+t);
    insert t;
    
    
    
    
    
    
    
    }






}