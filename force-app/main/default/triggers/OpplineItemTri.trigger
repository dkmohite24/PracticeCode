trigger OpplineItemTri on Opportunity (after insert) {
    If(trigger.isafter && trigger.isinsert){
        
        oppLineItemTriHandler oppHandler = new oppLineItemTriHandler();
        oppHandler.oppInsertProdectAfterInsert(trigger.new);
    }
}