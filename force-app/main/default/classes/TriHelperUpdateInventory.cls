public class TriHelperUpdateInventory {
    public Void TriUpadateAfter(list<Order_Entry__c> NewTriInventory,map<id,Order_Entry__c> Inventoryoldmap){
        Set<Id> AssociateIdSet = New Set <Id>();
        Map < String, String > orderProductMap = new Map < String, String > ();
        Map < String, integer > ProductQuantityMap = new Map < String, integer > ();
        Map < String, String > ProductAssociateMap = new Map < String, String > ();
        Map < String, String > ProductIdMap = new Map < String, String > ();
        List<Id> OrderIdList  = new List<Id>();
        List<Inventory__c> InventoryUpdationList = new List<Inventory__c>();
        for(Order_Entry__c OdEnRecord: NewTriInventory){
            if (OdEnRecord.Product__c != Inventoryoldmap.get(OdEnRecord.Id).Product__c ||
                OdEnRecord.Quantity__c != Inventoryoldmap.get(OdEnRecord.Id).Quantity__c){
                    ProductQuantityMap.put(OdEnRecord.Product__c,Integer.valueOf(OdEnRecord.Quantity__c));
                    ProductIdMap.put(OdEnRecord.Product__c,OdEnRecord.Product__c);
                    orderProductMap.put(OdEnRecord.Order__c, OdEnRecord.Product__c);
                }
        }
        List<Order__c> OrderRecordList = [select id,name from Order__c where id IN: orderProductMap.keyset()];
        
        For(Order__c OrderRecord: OrderRecordList){
            if(orderProductMap.containsKey(OrderRecord.id)){
                ProductAssociateMap.put(orderProductMap.get(OrderRecord.id), OrderRecord.Associate__c);    
                AssociateIdSet.add(OrderRecord.Associate__c);
            }
        }
        List<Inventory__c> InventorySoqlList = [select Id,Status__c from Inventory__c where 
                                                Product__c In: orderProductMap.values() AND Status__c ='Assigned' 
                                                And  Associate__c IN: AssociateIdset Order By CreatedDate];
        for(Inventory__c InventoryRecord: InventorySoqlList){
            If(InventoryRecord.Associate__c == ProductAssociateMap.get(InventoryRecord.Product__c)  ||
               InventoryRecord.Product__c ==  ProductIdMap.get(InventoryRecord.Product__c)){
                   for(integer i=0; i<ProductQuantityMap.get(InventoryRecord.Product__c); i++ ){
                       InventoryRecord.Status__c ='Sold';
                       InventoryUpdationList.add(InventoryRecord);
                   }
               }
        }
        
        update InventoryUpdationList;  
    }
}