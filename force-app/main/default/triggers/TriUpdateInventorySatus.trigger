trigger TriUpdateInventorySatus on Order_Entry__c (after update) {
    If(trigger.isafter && trigger.isupdate){
        TriHelperUpdateInventory TriInventory =  new TriHelperUpdateInventory();
        TriInventory.TriUpadateAfter(trigger.New,Trigger.oldMap);
    }
}