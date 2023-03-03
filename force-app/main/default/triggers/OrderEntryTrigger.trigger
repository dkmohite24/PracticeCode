trigger OrderEntryTrigger on Order_Entry__c (after update) {
    
    
    Set<Id> productIdSet = new Set<Id>(); 
    set<Id> orderIdSet = new Set<Id>(); 
    List<Integer> quantities = new List<Integer>();
    Set<Id> associateIdSet = new Set<Id>(); List<Inventory__c> inventoryList = new List<Inventory__c>();
    for(Order_Entry__c orderItem :trigger.New)
    { 
        if(orderItem.Product__c != trigger.oldMap.get(orderItem.Id).Product__c || orderItem.Quantity__c != trigger.oldMap.get(orderItem.Id).Quantity__c) {
            productIdSet.add(orderItem.Product__c); 
            orderIdSet.add(orderItem.Order__c); 
            quantities.add(Integer.valueof(orderItem.Quantity__c)); 
        } 
    } if(orderIdSet.size() > 0){
        for(Order__c orderObj : [Select Id, Associate__c from Order__c where Id IN :orderIdSet])
        { associateIdSet.add(orderObj.Associate__c);
        } 
    } 
    for(Inventory__c invObj : [Select Id, Status__c from Inventory__c where Product__c IN :productIdSet AND Status__c = 'Assigned' AND Associate__c IN :associateIdSet Limit :quantities[0]])
        
        
        
        
    { invObj.Status__c = 'Sold'; inventoryList.add(invObj); } if(inventoryList.size() > 0){ update inventoryList; } }