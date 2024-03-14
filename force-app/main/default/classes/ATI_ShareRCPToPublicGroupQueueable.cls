/*
    Description : Class to share removed claim parts to it's parents through public group id
*/
public class ATI_ShareRCPToPublicGroupQueueable implements Queueable  {
    set<String> accGroupIds = new set<String>();
    set<Id> rcpIds = new set<Id>();
    public ATI_ShareRCPToPublicGroupQueueable(set<String> accGroupIds,set<Id> rcpIds){
        this.accGroupIds = accGroupIds;
        this.rcpIds= rcpIds;
    }    
    
    public void execute(QueueableContext context) {
        try{
            Map<String, String> groupNameIdMap = new Map<String, String>();
            List<WOD_2__Removed_Claim_Part__Share> rcpShareList = new  List<WOD_2__Removed_Claim_Part__Share>();
            
            String groupObjName = 'Group';
            List<String> groupFields = new List<String>{'Name'};
                ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);
            
            if (groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (Group grp: [SELECT Id,Name FROM Group WHERE Name IN :accGroupIds LIMIT 50000]) {
                    groupNameIdMap.put(grp.Name,grp.Id);
                }
            }
            
            String wrObjName = 'WOD_2__Removed_Claim_Part__c';
            List<String> wrFields = new List<String>{'WOD_2__Account__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wrNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(wrObjName,wrFields);
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            
            if (wrNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && wrNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (WOD_2__Removed_Claim_Part__c rcpRec: [SELECT Id, WOD_2__Claim__c,WOD_2__Claim__r.WOD_2__Account__c, WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Removed_Claim_Part__c WHERE Id IN :rcpIds]) {
                    String accountType = rcpRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c;
                    if (groupNameIdMap.containsKey('ATI_' + accountType + '_' + rcpRec.WOD_2__Claim__r.WOD_2__Account__c)) {
                        WOD_2__Removed_Claim_Part__Share wrShareInstance = new WOD_2__Removed_Claim_Part__Share(UserOrGroupId = groupNameIdMap.get('ATI_' + accountType + '_' + rcpRec.WOD_2__Claim__r.WOD_2__Account__c),AccessLevel = 'Edit',ParentId = rcpRec.Id);
                        rcpShareList.add(wrShareInstance);
                    }
                }
            }
            System.debug('rcpShareList>>>> '+rcpShareList);
            if (!rcpShareList.isEmpty()) {
                String rcpShareObjName = 'WOD_2__Removed_Claim_Part__Share';
                List<String> claimShareFields = new List<String>{'UserOrGroupId','AccessLevel','ParentId'};
                    ATI_Utils.NoAccessObjectFieldWrapper wrShareNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(rcpShareObjName,claimShareFields);
                if (wrShareNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && wrShareNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                    Database.SaveResult[] wrShareInsertResult = Database.insert(rcpShareList, false);
                    system.debug('wrShareInsertResult'+wrShareInsertResult);
                }
            }
            
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
    }
}