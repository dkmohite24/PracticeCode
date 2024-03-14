/* Name: ATI_AddClaimShareRecords
Description :  Method to create claim sharing records with account's group
Author : Tavant (MB)
History :
VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)          02/04/2021          INITIAL DEVELOPMENT
*/

public without sharing class ATI_AddClaimShareRecords implements Queueable {
    set<String> accGroupIds = new set<String>();
    set<Id> claimIds = new set<Id>();
    public ATI_AddClaimShareRecords(set<String> accGroupIds,set<Id> claimIds){
        this.accGroupIds = accGroupIds;
        this.claimIds= claimIds;
    }    
	public void execute(QueueableContext context) {
        try{
            
            Map<String, String> groupNameIdMap = new Map<String, String>();
            List<WOD_2__Claim__Share> claimShareList = new  List<WOD_2__Claim__Share>();
            
            String groupObjName = 'Group';
            List<String> groupFields = new List<String>{'Name'};
                ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);
            
            if (groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (Group grp: [SELECT Id,Name FROM Group WHERE Name IN :accGroupIds LIMIT 50000]) {
                    groupNameIdMap.put(grp.Name,grp.Id);
                }
            }
            
            String claimObjName = 'WOD_2__Claim__c';
            List<String> claimFields = new List<String>{'WOD_2__Account__c'};
                ATI_Utils.NoAccessObjectFieldWrapper claimNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(claimObjName,claimFields);
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            
            if (claimNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (WOD_2__Claim__c claimRec: [SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Claim__c WHERE Id IN :claimIds]) {
                    String accountType = claimRec.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c;
                    String accountTypeconcat ='';
                    String[] warrAccType = claimRec.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c.split(' ');
                    if(warrAccType.size()>1){
                        accountTypeconcat = warrAccType[0]+warrAccType[1];
                    }else{
                        accountTypeconcat = accountType;
                    }
                    if (groupNameIdMap.containsKey('ATI_' + accountTypeconcat + '_' + claimRec.WOD_2__Account__c)) {
                        WOD_2__Claim__Share claimShareInstance = new WOD_2__Claim__Share(UserOrGroupId = groupNameIdMap.get('ATI_' + accountTypeconcat + '_' + claimRec.WOD_2__Account__c),AccessLevel = 'Edit',ParentId = claimRec.Id);
                        claimShareList.add(claimShareInstance);
                    }
                }
            }
            if (!claimShareList.isEmpty()) {
                String claimShareObjName = 'WOD_2__Claim__Share';
                List<String> claimShareFields = new List<String>{'UserOrGroupId','AccessLevel','ParentId'};
                    ATI_Utils.NoAccessObjectFieldWrapper claimShareNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(claimShareObjName,claimShareFields);
                if (claimShareNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimShareNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                    Database.SaveResult[] claimShareInsertResult = Database.insert(claimShareList, false);
                    system.debug('claimShareInsertResult'+claimShareInsertResult);
                }
            }
            
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
	 
	}
}