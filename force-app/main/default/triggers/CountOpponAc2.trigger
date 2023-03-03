trigger CountOpponAc2 on Opportunity (After insert,After update,After delete) {

    
    if(trigger.isAfter && trigger.isinsert){
    AmmountAndNoOppTRI TRI = new AmmountAndNoOppTRI();
    TRI.OpptoAc(trigger.new);
        
    }
    if(trigger.isAfter && trigger.isupdate){
    AmmountAndNoOppTRI TRI2 = new AmmountAndNoOppTRI();
    TRI2.OpptoAc(trigger.new);
    
    }
    if(trigger.isAfter && trigger.isdelete){
    AmmountAndNoOppTRI TRI2 = new AmmountAndNoOppTRI();
    TRI2.OpptoAcAfterDelete(trigger.Old);
    }
 
}