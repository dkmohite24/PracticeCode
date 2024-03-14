trigger TriggerOnAwaareBasics on AWAARE_4WARD_Basic__c (before insert,after update) {
    if(trigger.isbefore && trigger.isinsert){

            TriggerHandlerForMailAwaare.AddCustomerCode(Trigger.new);
    
    }
     if(trigger.isafter && trigger.isupdate)
    {  
        
        for(AWAARE_4WARD_Basic__c ab :Trigger.new){
            
            AWAARE_4WARD_Basic__c oldab = Trigger.oldmap.get(ab.Id);
            /*if(ab.Status__c=='Rejected' && ab.Status__c!=oldab.Status__c){
            TriggerHandlerForMailAwaare.SendEmailForRejection(Trigger.new);
            }*/
            if(ab.Status__c=='Approved' && ab.Access_Request_Type__c=='Reactivation Request'){
             TriggerHandlerForMailAwaare.userreactivation(ab.Username__c,ab.Role_Picklist__c,ab.Job_Title__c);
                TriggerHandlerForMailAwaare.awaare4wardupdation(ab.Username__c.left(12),ab.Role_Picklist__c,ab.Job_Title__c);
            }
            if(ab.Status__c=='Approved' && ab.Access_Request_Type__c=='New 4WARD Account'){
            TriggerHandlerForMailAwaare.awaare4wardrecordcreation(ab);
           }
            
}
    }

}