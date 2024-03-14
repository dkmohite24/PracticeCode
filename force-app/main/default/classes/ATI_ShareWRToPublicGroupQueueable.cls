/*
	Description	: Class to share warranty registration to it's parents through public group id
*/
public class ATI_ShareWRToPublicGroupQueueable implements Queueable  {
    set<String> accGroupIds = new set<String>();
    set<Id> wrIds = new set<Id>();
    public ATI_ShareWRToPublicGroupQueueable(set<String> accGroupIds,set<Id> wrIds){
        this.accGroupIds = accGroupIds;
        this.wrIds= wrIds;
    }    
    
    public void execute(QueueableContext context) {
        try{
            Map<String, String> groupNameIdMap = new Map<String, String>();
            List<WOD_2__Warranty_Registration__Share> wrShareList = new  List<WOD_2__Warranty_Registration__Share>();
            
            String groupObjName = 'Group';
            List<String> groupFields = new List<String>{'Name'};
                ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);
            
            if (groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (Group grp: [SELECT Id,Name FROM Group WHERE Name IN :accGroupIds LIMIT 50000]) {
                    groupNameIdMap.put(grp.Name,grp.Id);
                }
            }
            
            String wrObjName = 'WOD_2__Warranty_Registration__c';
            List<String> wrFields = new List<String>{'WOD_2__Account__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wrNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(wrObjName,wrFields);
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            
            if (wrNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && wrNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (WOD_2__Warranty_Registration__c wrRec: [SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Warranty_Registration__c WHERE Id IN :wrIds]) {
                    String accountType = wrRec.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c;
                    String accountTypeconcat ='';
                    String[] warrAccType = wrRec.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c.split(' ');
                    if(warrAccType.size()>1){
                        accountTypeconcat = warrAccType[0]+warrAccType[1];
                    }else{
                        accountTypeconcat = accountType;
                    }
                    if (groupNameIdMap.containsKey('ATI_' + accountTypeconcat + '_' + wrRec.WOD_2__Account__c)) {
                        WOD_2__Warranty_Registration__Share wrShareInstance = new WOD_2__Warranty_Registration__Share(UserOrGroupId = groupNameIdMap.get('ATI_' + accountTypeconcat + '_' + wrRec.WOD_2__Account__c),AccessLevel = 'Edit',ParentId = wrRec.Id);
                        wrShareList.add(wrShareInstance);
                    }
                }
            }
            System.debug('wrShareList>>>> '+wrShareList);
            if (!wrShareList.isEmpty()) {
                String wrShareObjName = 'WOD_2__Warranty_Registration__Share';
                List<String> claimShareFields = new List<String>{'UserOrGroupId','AccessLevel','ParentId'};
                    ATI_Utils.NoAccessObjectFieldWrapper wrShareNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(wrShareObjName,claimShareFields);
                if (wrShareNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && wrShareNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                    Database.SaveResult[] wrShareInsertResult = Database.insert(wrShareList, false);
                    system.debug('wrShareInsertResult'+wrShareInsertResult);
                }
            }
            
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
    }
}