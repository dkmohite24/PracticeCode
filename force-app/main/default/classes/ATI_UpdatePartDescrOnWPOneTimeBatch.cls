public class ATI_UpdatePartDescrOnWPOneTimeBatch implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext bc) {
       	String query = 'SELECT Id,WOD_2__Description__c,ATI_Part_Description__c FROM WOD_2__Warranty_Product__c'
            			+' WHERE WOD_2__Item_Type__c =\'Part\' AND ATI_Part_Description__c = NULL';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WOD_2__Warranty_Product__c> wpLst) {
        List<WOD_2__Warranty_Product__c> wpLstToUpdate = new List<WOD_2__Warranty_Product__c>();
        for(WOD_2__Warranty_Product__c wpObj : wpLst){
            if(wpObj.WOD_2__Description__c != NULL){
                wpObj.ATI_Part_Description__c = wpObj.WOD_2__Description__c;
                wpLstToUpdate.add(wpObj);
            }
        }
        if(!wpLstToUpdate.isEmpty()){
            update wpLstToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}