public class AccountTriggerClass{
    public void AccountTriggerMeth(list<account> AccountlistTri ){
    
    for(Account obj:AccountlistTri){
    if (obj.Email__C==''||obj.Email__c==null){
    
    
    obj.Email__C.adderror('PLease fill Email');
    }
    }
    
    
    
    }

}