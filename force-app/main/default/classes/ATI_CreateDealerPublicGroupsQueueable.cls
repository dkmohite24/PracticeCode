/* Name: ATI_CreateDealerPublicGroupsQueueable
Description : ATI_CreateDealerPublicGroupsQueueable for Account Object, gets called from Trigger Handler.
Author : Tavant ()
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant ()      10-JUN-2019          INITIAL DEVELOPMENT
*/
public class ATI_CreateDealerPublicGroupsQueueable implements Queueable {
    private List<Account> accountList;
    private Boolean isUpdate = false;
    @testVisible
    private static Boolean doChainJob = true;
    
    public ATI_CreateDealerPublicGroupsQueueable(List<Account> accountList,Boolean isUpdate) {
        this.accountList = accountList;
        this.isUpdate = isUpdate;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> dealerAccountSet = new Set<Id>();
        Map<Id,List<Group>> newAccountIdGroupObjMap = new Map<Id, List<Group>>();
        List<Group> GrpLst = new List<Group>();
        List<Group> insertQueueList = new List<Group>();
        Map<String, Group> accountIdWithSupplierQueueMap = new Map<String, Group>();
        Set<Id> supplierAccountSet = new Set<Id>(); 
        System.debug('accountList under execute'+accountList);
        for(Account accountObj : accountList) {
            // Parent and Child Dealers
            if(accountObj.WOD_2__Warranty_Account_Type__c == 'Dealer'){
                GrpLst.add(new Group(Name = 'ATI_Dealer_'+accountObj.Id));
                //Added by Manoj Paul on dated 22/12/2020 for Creating a new Group for WR Approval
                //GrpLst.add(new Group(Name = 'ATI_Warranty_Approver_' + accountObj.Id));
                newAccountIdGroupObjMap.put(accountObj.id,GrpLst);
                dealerAccountSet.add(accountObj.Id);
                if(accountObj.ATI_Alternate_Parent__c != null) {
                    dealerAccountSet.add(accountObj.ATI_Alternate_Parent__c);
                }
            }
        }
        if(!isUpdate) {
            //Modified by Manoj Paul on dated 22/12/2020 for Creating a new Group for WR Approval
            Database.SaveResult[] saveResultPublicGroupList = Database.insert(GrpLst, true);
        }
        
        // Update the Account with it public group Id
        updateAccountPublicGroup(dealerAccountSet, newAccountIdGroupObjMap);
        
        // Chain the Second Job to Create GroupMembers (Setup object)
        if(!accountList.isEmpty()){
            if(!Test.isRunningTest()) {
                System.enqueueJob(new ATI_UpdateDealerPublicGroupsQueueable(accountList));
            }
        }
        
    }
    
    private void updateAccountPublicGroup(Set<Id> dealerAccountSet, Map<Id, List<Group>> newAccountIdGroupObjMap){
        List<Account> updateAccountPublicGroupIdList = new List<Account>();
        Set<Account> accset = new Set<Account>();
        List<ACCOUNTSHARE> accountShareList = new List<ACCOUNTSHARE>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Account> accountIdAccountObjMap = new Map<Id, Account>([SELECT ID, ParentId,Public_Group_Id__c,WOD_2__Warranty_Account_Type__c,ATI_Alternate_Parent__c FROM ACCOUNT WHERE ID IN: dealerAccountSet FOR UPDATE]); 
        for(Account accountObj : accountIdAccountObjMap.values()) {
            Boolean iterate = false;
            // Parent & Child Dealer
            String accountType = accountObj.WOD_2__Warranty_Account_Type__c;
            if(accountObj.WOD_2__Warranty_Account_Type__c == 'Dealer'){
                if(newAccountIdGroupObjMap.containsKey(accountObj.Id)) {
                    //Modified by Manoj Paul on dated 22/12/2020 for Creating a new Group for WR Approval
                    List<Group> groupObjlst = newAccountIdGroupObjMap.get(accountObj.Id);
                    for(Group g : groupObjlst){
                        if(iterate == false){
                            if(!isUpdate){
                                accountObj.Public_Group_Id__c = g.Id;
                                updateAccountPublicGroupIdList.add(accountObj);
                            }
                            iterate = true;
                        }
                    }
                    accountIds.add(accountObj.Id);
                	if(accountIdAccountObjMap.get(accountObj.ATI_Alternate_Parent__c) != null) {
                        Account parentDealerAccountObj = accountIdAccountObjMap.get(accountObj.ATI_Alternate_Parent__c);
                        //added to share account to the group
                        AccountShare accShareInstance = new AccountShare(UserOrGroupId = parentDealerAccountObj.Public_Group_Id__c,AccountAccessLevel = 'Read',AccountId = accountObj.id,
                                                                         OpportunityAccessLevel = 'None',CaseAccessLevel = 'None');
                        accountShareList.add(accShareInstance);
                    }
                }                
            }
        }
        
        // Update Public Group Id in Account Object - Parent & Child Dealer
        if(!isUpdate) {
            Database.UpsertResult[] saveResultAccountList = Database.upsert(updateAccountPublicGroupIdList, true);
        }
        
        List<AccountShare> existingAccountShareList = [SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,OpportunityAccessLevel,RowCause,UserOrGroupId FROM AccountShare where accountId =:accountIds and RowCause = 'Manual'];
        if(!existingAccountShareList.isEmpty()) {
            List<AccountShare> accountShareDeleteList = new List<AccountShare>();
            for(AccountShare accShare : existingAccountShareList) {
                String publicGroupId = Id.valueOf(accShare.UserOrGroupId);
                if(publicGroupId.startsWith('00G')) {
                    accountShareDeleteList.add(accShare);
                }
            }
            if(!accountShareDeleteList.isEmpty()) {
                delete accountShareDeleteList;
            }
        }
        
        //added to share account to the group
        if(!Test.isRunningTest()){
            Database.UpsertResult[] saveResultAccountShareList = Database.upsert(accountShareList, true); 
        }
        
    }
}