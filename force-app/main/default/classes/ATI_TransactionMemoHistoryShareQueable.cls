/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        17-Feb-2021
* @modified
* @description :   Queable class to create sharing record for TMH
* --------------------------------------------------------------------------------------------------
*/
public class ATI_TransactionMemoHistoryShareQueable implements Queueable  {
    set<String> accGroupIds = new set<String>();
    set<Id> tmhIdsSet = new set<Id>();
    public ATI_TransactionMemoHistoryShareQueable(set<String> accGroupIds,set<Id> tmhIdsSet){
        this.accGroupIds = accGroupIds;
        this.tmhIdsSet= tmhIdsSet;
    }    
    
    public void execute(QueueableContext context) {
        try{
            Map<String, String> groupNameIdMap = new Map<String, String>();
            List<WOD_2__Transaction_Memo_History__Share> tmhShareList = new  List<WOD_2__Transaction_Memo_History__Share>();
            
            for (Group grp: [SELECT Id,Name FROM Group WHERE Name IN :accGroupIds LIMIT 50000]) {
                groupNameIdMap.put(grp.Name,grp.Id);
            }
            
            for (WOD_2__Transaction_Memo_History__c tmhRec: [SELECT Id,WOD_2__Claim__c,WOD_2__Claim__r.WOD_2__Account__c,WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c,
                                                                    ATI_Warranty_Registration__c,ATI_Warranty_Registration__r.WOD_2__Account__c,ATI_Warranty_Registration__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c
                                                                FROM WOD_2__Transaction_Memo_History__c WHERE Id IN :tmhIdsSet]) 
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
                
                if (groupNameIdMap.containsKey('ATI_' + accountType + '_' + accId)) {
                    WOD_2__Transaction_Memo_History__Share tmhShareInstance = new WOD_2__Transaction_Memo_History__Share(UserOrGroupId = groupNameIdMap.get('ATI_' + accountType + '_' + accId),AccessLevel = 'Edit',ParentId = tmhRec.Id);
                    tmhShareList.add(tmhShareInstance);
                }
            }
            if (!tmhShareList.isEmpty()) {
                Database.SaveResult[] tmhShareInsertResult = Database.insert(tmhShareList, false);
            }
            
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
    }
}