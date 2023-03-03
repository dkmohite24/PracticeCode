trigger RenewalOpty on Opportunity (before update , before insert , After insert) {

    if (trigger.isbefore && trigger.isupdate){
    RenewalOptyTRI OP = new RenewalOptyTRI();
    op.RenewalOptyMeth(Trigger.new);

    }
    
   
}