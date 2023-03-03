trigger AddLineItom on Opportunity (After insert) {

    if(trigger.isAfter && trigger.isinsert){
         AddProductToOpty OpNew = new AddProductToOpty();
         OpNew.AddlineItom(trigger.new);
    }

}