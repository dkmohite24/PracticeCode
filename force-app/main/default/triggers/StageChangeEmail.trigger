trigger StageChangeEmail on Opportunity (After update) {

    if(trigger.isAfter && trigger.isUpdate){
     SendEmailToOwnerOpTRI TRI = new  SendEmailToOwnerOpTRI();
     TRI.SendEmailOpportunity(trigger.new , trigger.old);
    }


}