Public Class task10valationTRI{
    Public Void Task10ValMeth(List<Task10__c>TK){
        List<Task10__c> UpdatedTk = new List<Task10__c>();
        
        For(Task10__c TKK :TK){
            
            IF(TKK.Stage__C == 'closed'){
                If(TKK.Primary_Reasons__c  == NUll || TKK.Secondary_Reasons__c == Null ){
                
                    TKK.adderror('Please fill Primary reason and Secondary reason');
                }
            
            }   
        }
    }
}