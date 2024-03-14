/* Name: UpdateDealerPublicGroupsQueueable
Description : UpdateDealerPublicGroupsQueueable for Account Object, gets called from Trigger Handler.
Author : Tavant ()
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant ()    	09/08/2019          INITIAL DEVELOPMENT
*/
public class ATI_UpdateDealerPublicGroupsQueueable implements Queueable {   
    
    private List<Account> accountList;
    
    public ATI_UpdateDealerPublicGroupsQueueable(List<Account> accountList) {
        this.accountList = accountList;
    }
    
    public void execute(QueueableContext context) {
        List<Id> dealerAccountList = new List<Id>();
        List<ACCOUNTSHARE> accountShareList = new List<ACCOUNTSHARE>();
        List<Id> publicGroupIds = new List<Id>();
        for(Account accountObj : accountList) {
            // Child Dealer & Parent Dealer
            dealerAccountList.add(accountObj.Id);
            if(accountObj.ATI_Alternate_Parent__c != null) {
                dealerAccountList.add(accountObj.ATI_Alternate_Parent__c);
                publicGroupIds.add(accountObj.Public_Group_Id__c);
            }
        }
        
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<Id, Account> accountIdAccountObjMap = new Map<Id, Account>([SELECT ID, ATI_Alternate_Parent__c, Public_Group_Id__c FROM ACCOUNT WHERE ID IN: dealerAccountList FOR UPDATE]);
        List<GroupMember> groupMemberLst = [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE GroupId IN:publicGroupIds];
        List<GroupMember> deleteGroupMemberLst = new List<GroupMember>();
        if(!groupMemberLst.isEmpty()){
            for(GroupMember gm : groupMemberLst){
                String publicGroupId = Id.valueOf(gm.UserOrGroupId);
                if(publicGroupId.startsWith('00G')) {
                    deleteGroupMemberLst.add(gm);
                }
            }
            if(!deleteGroupMemberLst.isEmpty()){
                delete deleteGroupMemberLst;
            }
        }
        
        for(Account dealerAccountObj : accountIdAccountObjMap.values()) {
            // Child Dealers
            if(accountIdAccountObjMap.get(dealerAccountObj.ATI_Alternate_Parent__c) != null) {
                Account parentDealerAccountObj = accountIdAccountObjMap.get(dealerAccountObj.ATI_Alternate_Parent__c);
                groupMemberList.add(new GroupMember(GroupId = dealerAccountObj.Public_Group_Id__c, UserOrGroupId = parentDealerAccountObj.Public_Group_Id__c));
            }
        }
        
        //Create group member list of Parent dealers that needs to add under child dealers
        if(!Test.isRunningTest()){
            Database.SaveResult[] saveResultGroupMemberList = Database.insert(groupMemberList, true);
        }
    }
}