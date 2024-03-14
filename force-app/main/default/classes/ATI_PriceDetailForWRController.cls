public with sharing class ATI_PriceDetailForWRController {
    @AuraEnabled(cacheable=true)
    public static List<WOD_2__Transaction_Memo_History_Line_Item__c> getTransactionLineItems(String wrObjId) {
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemsLst = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();

        for(WOD_2__Transaction_Memo_History__c memoObj : [SELECT Id,(SELECT Id,Name,ATI_Handling_Fee__c,ATI_Late_Fee__c,WOD_2__Quantity__c,
                                                                            WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c
                                                                        FROM WOD_2__Transaction_Memo_History_Line_Items__r)
                                                            FROM WOD_2__Transaction_Memo_History__c
                                                            WHERE ATI_Warranty_Registration__c=:wrObjId]) 
        {
            lineItemsLst.addAll(memoObj.WOD_2__Transaction_Memo_History_Line_Items__r);
        }
        return lineItemsLst;
    }

    @AuraEnabled(cacheable=true)
    public static User getUserDetails(String userId) {
        return  [Select Id , Name ,Profile.Name from User where Id =:userId];
    }

    @AuraEnabled
    public static String updateTransactionLineItems(Object data){
        Set<Id> lineItemsIdsSet = new Set<Id>();
        Set<Id> memoHistoriesIdsSet = new Set<Id>();
        List<WOD_2__Transaction_Memo_History_Line_Item__c> linItemsForUpdate = 
            (List<WOD_2__Transaction_Memo_History_Line_Item__c>) 
            JSON.deserialize(JSON.serialize(data),List<WOD_2__Transaction_Memo_History_Line_Item__c>.class);
        try {
            for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemObj : linItemsForUpdate){
                lineItemsIdsSet.add(lineItemObj.Id);
            }
            Map<Id,WOD_2__Transaction_Memo_History_Line_Item__c> lineItemsMap = 
                    new Map<Id,WOD_2__Transaction_Memo_History_Line_Item__c>([SELECT Id,WOD_2__Total_Amount__c,WOD_2__Transaction_Memo_History__c,
                                                                                     WOD_2__Unit_Amount__c,ATI_Late_Fee__c,ATI_Handling_Fee__c
                                                                                FROM WOD_2__Transaction_Memo_History_Line_Item__c
                                                                                WHERE Id IN :lineItemsIdsSet]);
            for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemObj : lineItemsMap.values()){
                memoHistoriesIdsSet.add(lineItemObj.WOD_2__Transaction_Memo_History__c);
            }
			update linItemsForUpdate;

            List<WOD_2__Transaction_Memo_History__c> memoHistoriesToUpdateLst = [SELECT Id,WOD_2__Amount__c,(SELECT Id,Name,ATI_Handling_Fee__c,ATI_Late_Fee__c,WOD_2__Quantity__c,
                                                                                                                    WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c
                                                                                                                FROM WOD_2__Transaction_Memo_History_Line_Items__r)
                                                                                    FROM WOD_2__Transaction_Memo_History__c
                                                                                    WHERE Id IN :memoHistoriesIdsSet];
            for(WOD_2__Transaction_Memo_History__c memoObj : memoHistoriesToUpdateLst){
                Decimal TotalAmount = 0;
                for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemObj : memoObj.WOD_2__Transaction_Memo_History_Line_Items__r){
                    if(lineItemObj.WOD_2__Total_Amount__c != NULL){
                        TotalAmount = TotalAmount+ lineItemObj.WOD_2__Total_Amount__c;
                    }
                }
                memoObj.WOD_2__Amount__c = TotalAmount;
            }

            update memoHistoriesToUpdateLst;
            return 'Success: Price details updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
}