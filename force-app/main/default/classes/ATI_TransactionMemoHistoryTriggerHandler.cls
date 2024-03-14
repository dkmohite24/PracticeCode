/**
-------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        17-Feb-2021
* @modified
* @description :   ATI_TransactionMemoHistoryTriggerHandler handler for ATI_TransactionMemoHistoryTrigger
* --------------------------------------------------------------------------------------------------
*/
public class ATI_TransactionMemoHistoryTriggerHandler extends TriggerHandler {
    private List<WOD_2__Transaction_Memo_History__c> newTMHList;
    private List<WOD_2__Transaction_Memo_History__c> oldTMHList;
    private Map<Id, WOD_2__Transaction_Memo_History__c> newTMHMap;
    private Map<Id, WOD_2__Transaction_Memo_History__c> oldTMHMap;
    
    public ATI_TransactionMemoHistoryTriggerHandler(){
        this.newTMHList = (List<WOD_2__Transaction_Memo_History__c>)Trigger.new;
        this.oldTMHList= (List<WOD_2__Transaction_Memo_History__c>)Trigger.old;
        this.newTMHMap= (Map<Id, WOD_2__Transaction_Memo_History__c>)Trigger.newMap;
        this.oldTMHMap= (Map<Id, WOD_2__Transaction_Memo_History__c>)Trigger.oldMap;
    }
    public override void afterInsert() {
        shareTransactionMemoHistories(newTMHList);
    }
    //ALSN-116
    public override void afterUpdate() {
        createFLISnapshot(newTMHList);
    }
    //ALSN-116
    public static void createFLISnapshot(List<WOD_2__Transaction_Memo_History__c> newTMHList){
        Set<Id> claimIdSet = new Set<Id>();
        Set<Id> tmhIdSet = new Set<Id>();
        Map<Id,Id> mapOfClaimAndTMH = new Map<Id,Id>();
        List<ATI_Financial_Line_Item_Snapshot__c> fliSnapShotList = new List<ATI_Financial_Line_Item_Snapshot__c>();
        for(WOD_2__Transaction_Memo_History__c tmh : newTMHList){
            if(tmh.WOD_2__Transaction_Status__c == 'Paid'){
                tmhIdSet.add(tmh.id);
            }
        }
        if(tmhIdSet.size() > 0){
            List<WOD_2__Transaction_Memo_History_Line_Item__c> tmhliList = [Select Id, WOD_2__Financial_Line_Item__c from WOD_2__Transaction_Memo_History_Line_Item__c where WOD_2__Transaction_Memo_History__c in: tmhIdSet];
            Set<Id> fliIdSet = new Set<Id>();
            Map<Id,Id> mapOfTMHLIAndFLI = new Map<Id,Id>();
            for(WOD_2__Transaction_Memo_History_Line_Item__c tmhli : tmhliList){
                fliIdSet.add(tmhli.WOD_2__Financial_Line_Item__c);
                mapOfTMHLIAndFLI.put(tmhli.WOD_2__Financial_Line_Item__c,tmhli.Id);
            }
            List<WOD_2__Financial_Line_Item__c> fliList = [select Id,Name,RecordTypeId,ATI_Factory_Cost__c, ATI_Factory_Price__c, ATI_Total_Approved_Amount_in_USD__c, WOD_2__Total_Approved_Amt__c, WOD_2__Approved_Amount__c, WOD_2__Approved_Quantity__c, WOD_2__Cost_Category_Type__c, WOD_2__Percentage_Amount__c, 
                                                           WOD_2__Requested_Quantity__c, ATI_Total_Requested_Amount_USD__c,  WOD_2__Requested_Per_Unit_Amt__c, ATI_Markup__c, ATI_Landed_Part_Markup__c, WOD_2__System_PerUnit_Price__c, WOD_2__Total_Eligible_Amount__c, WOD_2__Total_Requested_Amount__c, WOD_2__Type__c,
                                                           ATI_Disposition_Code__c, ATI_Previous_Percentage_Amount__c, ATI_Previously_Approved_Quantity__c, ATI_Previously_Computed_Factory_Cost__c, ATI_Previously_Computed_Factory_Price__c, WOD_2__Previously_Paid_Amount__c, ATI_Previously_Paid_Amt__c, 
                                                           ATI_Previously_Paid_Landed_Part_Markup__c, ATI_Previously_Paid_Markup__c, WOD_2__Previous_Total_Approved_Amount__c, ATI_Total_Requested_Amount_In_USD__c, WOD_2__Claim_Degradation_Modifier__c, WOD_2__Claim__c, WOD_2__Claim_Service_Information__c, 
                                                           WOD_2__Installed_Claim_Part__c,WOD_2__System_Per_Unit_Price__c,WOD_2__Requested_Per_Unit_Amount__c,WOD_2__Total_Approved_Amount__c,WOD_2__Financial__c, WOD_2__Modifier_Amount__c, WOD_2__Modifier_Amt__c, WOD_2__Modifier_Value__c, WOD_2__isEligible__c, WOD_2__Other_Cost__c, WOD_2__Tax__c, WOD_2__Tax_Amount__c, WOD_2__Tax_Amt__c,WOD_2__Approved_Per_Unit_Amount__c 
                                                           from WOD_2__Financial_Line_Item__c where Id in: fliIdSet];
            
            if(fliList.size() > 0){
                for(WOD_2__Financial_Line_Item__c fli : fliList){
                    ATI_Financial_Line_Item_Snapshot__c fliSnapShot = new ATI_Financial_Line_Item_Snapshot__c();
                    fliSnapShot.ATI_Transaction_Memo_History_Line_Item__c = mapOfTMHLIAndFLI.get(fli.Id);                    
                    fliSnapShot.ATI_Factory_Cost__c = fli.ATI_Factory_Cost__c;
                    fliSnapShot.ATI_Factory_Price__c = fli.ATI_Factory_Price__c;
                    fliSnapShot.ATI_Markup__c = fli.ATI_Markup__c;
                    fliSnapShot.ATI_Landed_Part_Markup__c = fli.ATI_Landed_Part_Markup__c;
                    fliSnapShot.ATI_Total_Approved_Amount_in_USD__c = fli.ATI_Total_Approved_Amount_in_USD__c;
                    fliSnapShot.ATI_Total_Requested_Amount_USD__c= fli.ATI_Total_Requested_Amount_USD__c;
                    fliSnapShot.Name = fli.Name;
                    fliSnapShot.ATI_Total_Approved_Amt__c = fli.WOD_2__Total_Approved_Amt__c;
                    fliSnapShot.ATI_Approved_Amount__c = fli.WOD_2__Approved_Amount__c;
                    fliSnapShot.ATI_Approved_Quantity__c = fli.WOD_2__Approved_Quantity__c;
                    fliSnapShot.ATI_Cost_Category_Type__c = fli.WOD_2__Cost_Category_Type__c;
                    fliSnapShot.ATI_Percentage_Amount__c = fli.WOD_2__Percentage_Amount__c;
                    fliSnapShot.ATI_Requested_Quantity__c = fli.WOD_2__Requested_Quantity__c;
                    fliSnapShot.ATI_Requested_Per_Unit_Amt__c = fli.WOD_2__Requested_Per_Unit_Amt__c;
                    fliSnapShot.ATI_System_PerUnit_Price__c = fli.WOD_2__System_PerUnit_Price__c;
                    fliSnapShot.ATI_Total_Eligible_Amount__c = fli.WOD_2__Total_Eligible_Amount__c;
                    fliSnapShot.ATI_Total_Requested_Amount__c = fli.WOD_2__Total_Requested_Amount__c;
                    fliSnapShot.ATI_Type__c = fli.WOD_2__Type__c;
                    fliSnapShot.ATI_Disposition_Code__c = fli.ATI_Disposition_Code__c;
                    fliSnapShot.ATI_Previous_Percentage_Amount__c = fli.ATI_Previous_Percentage_Amount__c;
                    fliSnapShot.ATI_Previously_Approved_Quantity__c	= fli.ATI_Previously_Approved_Quantity__c;
                    fliSnapShot.ATI_Previously_Computed_Factory_Cost__c	= fli.ATI_Previously_Computed_Factory_Cost__c;
                    fliSnapShot.ATI_Previously_Computed_Factory_Price__c = fli.ATI_Previously_Computed_Factory_Price__c;
                    fliSnapShot.ATI_Previously_Paid_Amount__c = fli.WOD_2__Previously_Paid_Amount__c;
                    fliSnapShot.ATI_Previously_Paid_Amt__c = fli.ATI_Previously_Paid_Amt__c;
                    fliSnapShot.ATI_Previously_Paid_Landed_Part_Markup__c = fli.ATI_Previously_Paid_Landed_Part_Markup__c;
                    fliSnapShot.ATI_Previously_Paid_Markup__c = fli.ATI_Previously_Paid_Markup__c;
                    fliSnapShot.ATI_Previous_Total_Approved_Amount__c = fli.WOD_2__Previous_Total_Approved_Amount__c;
                    fliSnapShot.ATI_Total_Requested_Amount_In_USD__c = fli.ATI_Total_Requested_Amount_In_USD__c;
                    fliSnapShot.ATI_Claim_Degradation_Modifier__c = fli.WOD_2__Claim_Degradation_Modifier__c;
                    fliSnapShot.ATI_Claim_Number__c	= fli.WOD_2__Claim__c;
                    fliSnapShot.ATI_Claim_Service_Information__c = fli.WOD_2__Claim_Service_Information__c;
                    fliSnapShot.ATI_Installed_Claim_Part__c = fli.WOD_2__Installed_Claim_Part__c;
                    fliSnapShot.ATI_Financial__c = fli.WOD_2__Financial__c;
                    fliSnapShot.ATI_Modifier_Amount__c = fli.WOD_2__Modifier_Amount__c;
                    fliSnapShot.ATI_Modifier_Amt__c	= fli.WOD_2__Modifier_Amt__c;
                    fliSnapShot.ATI_Modifier_Value__c = fli.WOD_2__Modifier_Value__c;
                    fliSnapShot.ATI_is_Eligible__c = fli.WOD_2__isEligible__c;
                    fliSnapShot.ATI_Other_Cost__c = fli.WOD_2__Other_Cost__c;
                    fliSnapShot.ATI_Tax__c = fli.WOD_2__Tax__c;
                    fliSnapShot.ATI_Tax_Amount__c = fli.WOD_2__Tax_Amount__c;
                    fliSnapShot.ATI_Tax_Amt__c = fli.WOD_2__Tax_Amt__c;
                    fliSnapShot.ATI_Approved_Per_Unit_Amount__c = fli.WOD_2__Approved_Per_Unit_Amount__c;
                    fliSnapShot.ATI_Record_Type__c = fli.RecordTypeId;
                    fliSnapShotList.add(fliSnapShot);
                }
            }
            
            if(fliSnapShotList.size() > 0){
                insert fliSnapShotList;
            }
        }
    }
    
    public static void shareTransactionMemoHistories(List<WOD_2__Transaction_Memo_History__c> newTMHList){
        Set<Id> tmhIdsSet = new Set<Id>();
        Set<String> accGroupIds = new Set<String>();
        for (WOD_2__Transaction_Memo_History__c tmhRec: [SELECT Id,WOD_2__Claim__c,WOD_2__Claim__r.WOD_2__Account__c,WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c,
                                                         ATI_Warranty_Registration__c,ATI_Warranty_Registration__r.WOD_2__Account__c,ATI_Warranty_Registration__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c
                                                         FROM WOD_2__Transaction_Memo_History__c WHERE Id IN :newTMHList]) 
        {
            tmhIdsSet.add(tmhRec.Id);
            String accId ='';
            String accountType= '';
            String accountTypeconcat ='';
            if(tmhRec.WOD_2__Claim__c!=NULL && tmhRec.WOD_2__Claim__r.WOD_2__Account__c!=NULL && tmhRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c!=NULL){
                accId = tmhRec.WOD_2__Claim__r.WOD_2__Account__c;
                accountType = tmhRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c.deleteWhitespace();
            }else if(tmhRec.ATI_Warranty_Registration__c!=NULL && tmhRec.ATI_Warranty_Registration__r.WOD_2__Account__c!=NULL && tmhRec.ATI_Warranty_Registration__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c!=NULL){
                accId = tmhRec.ATI_Warranty_Registration__r.WOD_2__Account__c;
                accountType = tmhRec.ATI_Warranty_Registration__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c.deleteWhitespace();
            }                                                 
            accGroupIds.add('ATI_' + accountType + '_' + accId);
        }
        if(!Test.isRunningTest() && !tmhIdsSet.isEmpty() && !accGroupIds.isEmpty()){
            if(!System.isBatch()){
                ATI_QueueableUtil.enqueueJob(new ATI_TransactionMemoHistoryShareQueable(accGroupIds,tmhIdsSet));
            }else{
                new ATI_TransactionMemoHistoryShareQueable(accGroupIds,tmhIdsSet).execute(null);
            }
        }
    }
}