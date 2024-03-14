/*
* Class Name: PRPC_DataMovementBatchForETCData
* Description: Batch to move data from WOD_2__Transaction_Memo_History__c Object to ETC Staging Object for the last month.
* Developer Name: Susovan Mondal and Chinmaya Dash
*/

public class PRPC_DataMovementBatchForETCData implements Database.Batchable<sObject>,Schedulable{
    public list<Sobject> start(Database.BatchableContext BC){
        Integer Month = Date.Today().Month();
        Integer Year =Date.Today().Year();
        Integer ActualMonth = Month-1;
        if(Month == 1) 
        {
            ActualMonth = 12;  
            Year--;
        }
        system.debug('ActualMonth' +ActualMonth);
        system.debug('Year' +Year);
        String Query;
        
        if(!test.isRunningTest()){
            Query = 'SELECT id, WOD_2__Amount__c, WOD_2__Transaction_Date__c, ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c, ATI_Type__c, WOD_2__Transaction_Status__c, ATI_Warranty_Registration__r.WOD_2__Account__r.PRP_Participation__c, ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c,Name,WOD_2__Transaction_Number__c,ATI_Warranty_Registration__r.ATI_PO_Number__c,ATI_Warranty_Registration__r.Name from WOD_2__Transaction_Memo_History__c where  CALENDAR_MONTH(WOD_2__Transaction_Date__c)=:ActualMonth  AND  CALENDAR_YEAR(WOD_2__Transaction_Date__c)=:Year and ATI_Type__c =\'EWP\' and WOD_2__Transaction_Status__c =\'Paid\' and ATI_Warranty_Registration__r.WOD_2__Account__r.PRP_Participation__c = true and (ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c like \'910%\' OR ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c like \'0%\') AND ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c != \'0500500000\' and (ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'63%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'65%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'66%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'96%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'97%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'98%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'93%\' OR ATI_Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c like \'94%\') and WOD_2__Transaction_Type__c =\'Debit\'';
        }
        else{
            Query = 'SELECT id, WOD_2__Amount__c, WOD_2__Transaction_Date__c, ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c,Name, WOD_2__Transaction_Number__c, ATI_Warranty_Registration__r.ATI_PO_Number__c, ATI_Warranty_Registration__r.Name from WOD_2__Transaction_Memo_History__c';
        }
        list<Sobject> returnQuery = Database.query(Query);
        system.debug('RETURN QUERY****'+returnQuery);
        
        return returnQuery;
    }
    
    public void execute(SchedulableContext sc){
        PRPC_DataMovementBatchForETCData tatmb =new PRPC_DataMovementBatchForETCData();
        Database.executebatch(tatmb,700);
    }
    
    public void execute(Database.BatchableContext bc,  List<WOD_2__Transaction_Memo_History__c> returnQuery ){
        list<ETC_Staging_Data__c> ETCList = new list<ETC_Staging_Data__c>();  
        
        for(WOD_2__Transaction_Memo_History__c transactionHistory: returnQuery){
            System.debug('line 45 : '+returnQuery);
            ETC_Staging_Data__c etc = new ETC_Staging_Data__c();
            etc.Retail_Amount_ETC__c = transactionHistory.WOD_2__Amount__c != null ? String.valueOf(transactionHistory.WOD_2__Amount__c):null;
            etc.Date__c = transactionHistory.WOD_2__Transaction_Date__c!=null ? String.valueof(transactionHistory.WOD_2__Transaction_Date__c):null;
            etc.Distributor_Code__c = transactionHistory.ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c != null ? String.valueOf(transactionHistory.ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c):null;
            etc.PO_Number__c = transactionHistory.ATI_Warranty_Registration__r.ATI_PO_Number__c != null ? String.valueOf(transactionHistory.ATI_Warranty_Registration__r.ATI_PO_Number__c): null;
            etc.Warranty_Registration_Code__c = transactionHistory.ATI_Warranty_Registration__r.Name != null ? String.valueOf(transactionHistory.ATI_Warranty_Registration__r.Name): null;
            etc.Transaction_Memo_History_Name__c = transactionHistory.Name != null ? String.valueOf(transactionHistory.Name): null;
            etc.Transaction_Number__c = transactionHistory.WOD_2__Transaction_Number__c != null ? String.valueOf(transactionHistory.WOD_2__Transaction_Number__c): null;
            ETCList.add(etc);
        }
        if(ETCList.size()>0){
            insert ETCList;
        } 
    }
    public void finish(Database.BatchableContext bc){
    }
}