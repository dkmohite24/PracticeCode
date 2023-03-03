trigger TriUpdateInventoryStatus1 on Order_Entry__c (after update) {
    list<Id> ProductIdList = New List <Id>();
    list<Id> AssociateIdList = New List <Id>();
    Integer Quantity;
    List<Id> OrderEntryIdList  = new List<Id>();
    
    List<Inventory__c> InventoryUpdation = new List<Inventory__c>();
    for(Order_Entry__c OdEnRecord: trigger.new){
        OrderEntryIdList.Add(OdEnRecord.id);
    }
    List<Order_Entry__c> OrderEntrySoqlList = new List<Order_Entry__c>();
    OrderEntrySoqlList = [select Quantity__c,Product__c,id,Order__r.name from Order_Entry__c where id IN:OrderEntryIdList];
    for(Order_Entry__c OderEntryRecord: OrderEntrySoqlList){
        AssociateIdList.Add(OderEntryRecord.Order__r.name);
        ProductIdList.add(OderEntryRecord.Product__c);
        Quantity = Integer.valueOf(OderEntryRecord.Quantity__c);
        
    }

}