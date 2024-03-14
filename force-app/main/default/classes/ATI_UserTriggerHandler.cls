/**
 -------------------------------------------------------------------------------------------------
This is User Trigger handler class
* --------------------------------------------------------------------------------------------------
* @author         Punam Chakraborty
* @version        1.0
* @created        25-NOV-2020
* @modified
* --------------------------------------------------------------------------------------------------
*/
public class ATI_UserTriggerHandler extends TriggerHandler{
    private List<User> newUserList;
    private List<User> oldUserList;
    private Map<id,User> oldUserMap;
    private Map<id,User> newUserMap;
    
    private static Id DprofileId = null;
    private static Id WAprofileId = null;
    private static Id readOnlyprofileId = null;
    
    /*
        Method Name :   ATI_UserTriggerHandler
        Method Added By Punam
        Constructor Method ATI_UserTriggerHandler
    */
    public ATI_UserTriggerHandler() {
        this.newUserList = (List<User>)Trigger.new;
        this.oldUserList = (List<User>) Trigger.old;
        this.newUserMap = (Map<Id,User>)Trigger.newMap;
        this.oldUserMap = (Map<Id,User>)Trigger.oldMap;
    }
   
    // used for updating BU and currency fields
    public override void beforeInsert(){
        Set<Id> contactIdSet = new Set<Id>();
        for(User u : this.newUserList){
            if(u.ContactId != null){
                contactIdSet.add(u.ContactId);
            }
        }
        setBUAndCurrency(contactIdSet, this.newUserList);
    }
    
    public override void beforeUpdate(){
        Set<Id> contactIdSet = new Set<Id>();
        for(User u : this.newUserList){
            if(u.contactId != this.oldUserMap.get(u.Id).ContactId){
                contactIdSet.add(u.AccountId);
            }
        }
        setBUAndCurrency(contactIdSet, this.newUserList);
    }
    
    private void setBUAndCurrency(Set<Id> contactIdSet, List<User> usersList){
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        System.debug('contactIdSet -> ' + contactIdSet);
        if(!contactIdSet.isEmpty()){
            contactMap = new Map<Id,Contact>([select Account.CurrencyISOCode, Account.WOD_2__Business_Units__c from Contact where Id = :contactIdSet]);
        }
        System.debug('contactMap -> ' + contactMap);
        for(User u : usersList){
            if(contactMap.containsKey(u.ContactId)){
                Contact c = contactMap.get(u.ContactId);
                u.DefaultCurrencyISOCode = c.Account.CurrencyISOCode;
                u.WOD_2__Business_Units__c = c.Account.WOD_2__Business_Units__c;
            } else { //internal user or account is not assigned yet
                u.WOD_2__Business_Units__c = u.WOD_2__Business_Units__c == null ? u.WOD_2__Business_Units__c : 'ATI';
            }
        }
    }
    
    public override void afterInsert() {
        addGroupMembers(newUserList);
    }
    
    public override void afterUpdate() {
        addUserinGroupAfterUpdate(newUserList,oldUserMap);
    }
    
    /*
        Method Name :   addGroupMembers
        Method Added By Punam
        Params      :   userList
        Add users to specific Account's public group 
    */
    // Vijay changes - ALSN 64
     public static void addGroupMembers(List<User> userList){
         Set < Id > userIds = new Set < Id > ();
         for(User usr:userList){
             userIds.add(usr.Id);
             
         }
         addGroupMembersFuture(userIds);
     }    
     /*
        Method Name : addGroupMembersFuture(changed to future method to avoid mixed DML Exceptions)
        Method Added By Punam
		Method Updated By Vijay
		Params      :   userIdsSet
        Add users to specific Account's public group 
    */
    
    @future
    public static void addGroupMembersFuture(Set<Id> userIdsSet){
        
       Set < Id > userIds = new Set < Id > ();
       List<User> userList = [Select Id,AccountId,ContactId,profileId,IsPortalEnabled from User where Id IN:userIdsSet];
        List<GroupMember> gmlist = new List<GroupMember>();
        Map < String, String > groupNameIdMap = new Map < String, String > ();
        Set<String> grpName = new Set<String>();
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_DealerGroupNameForSharing');
        Group customerGroup = null;
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null){
            customerGroup = [SELECT Id FROM Group WHERE Name=:logRecordValue.WOD_2__Configuration_Value__c];
        }
        List<GroupMember> customerGroupMembersLst = new List<GroupMember>();
        set<Id> accIds = new set<Id>();
        Map<Id,String> accountIdWRAccTypeMap = new Map<Id,String>();
        //String dealerSearch = 'ATI_' + '%';
        try {
            for(User us: userList){
                accIds.add(us.AccountId);
            }
            //ALSN-93 added exception code for guest users
            String guestUserId = UserInfo.getUserId();
            List<String> guestUserExceptions = new List<String>();
            for (String exceptionUserId: System.Label.ATI_GuestUser_Exception.split(',')) {
                guestUserExceptions.add(exceptionUserId.trim());
            }
            List<String> fieldsForAccount = new List<String> {'WOD_2__Warranty_Account_Type__c','Id'};
            String sObjName = 'Account';
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForAccount);
            List<Account> accList = new List<Account>();
            //ALSN-93 added exception for guest user
            if((noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0) || guestUserExceptions.contains(guestUserId))
            {
                accList =[Select Id,WOD_2__Warranty_Account_Type__c From Account Where Id IN:accIds ];
                for(Account acc: accList){
                   String accountTypeconcat ='';
                   String[] warrAccType = acc.WOD_2__Warranty_Account_Type__c.split(' ');
                   if(warrAccType.size()>1){
                      accountTypeconcat = warrAccType[0]+warrAccType[1];
                   }else{
                        accountTypeconcat = acc.WOD_2__Warranty_Account_Type__c;
                    }
                    accountIdWRAccTypeMap.put(acc.Id,accountTypeconcat);
                }
            }
            
            for(User us: userList){
                if(accountIdWRAccTypeMap.get(us.AccountId)!= null){
                    grpName.add('ATI_'+accountIdWRAccTypeMap.get(us.AccountId)+'_'+us.AccountId);
                    //grpName.add('ATI_Warranty_Approver_'+us.AccountId);
                    if(customerGroup != null){
                        GroupMember gm = new GroupMember(UserOrGroupId = us.id,GroupId = customerGroup.id);
                        customerGroupMembersLst.add(gm);
                    }
                }else{
                    grpName.add('ATI_'+us.AccountId);
                }
            }
            
            if(!customerGroupMembersLst.isEmpty()){
                insert customerGroupMembersLst;
            }
            
            List<String> fieldsForGroup = new List<String> {'Name','Id'};
            String sObjName2 = 'Group';
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject2 = ATI_Utils.fetchReadAccess(sObjName2,fieldsForGroup);
            List<Group> groupTotalList = new List<Group>();
            //ALSN-93 added exception for guest user
            if((noAccessObjectFieldWrapperObject2.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject2.noAccessFieldList.size() == 0) || guestUserExceptions.contains(guestUserId))
            {
                groupTotalList =[Select Id,Name From Group WHERE Name IN: grpName limit 50000];
            }
            if(groupTotalList!= null){
                for(Group grp: groupTotalList){
                    groupNameIdMap.put(grp.Name,grp.Id);
                }
                
                List<String> fieldsForProfile = new List<String> {'Id'};
                String sObjName3 = 'Profile';
                ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject3 = ATI_Utils.fetchReadAccess(sObjName3,fieldsForProfile);
                getPortalProfileIds();
                //ALSN-93 added exception for guest user
                if((noAccessObjectFieldWrapperObject3.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject3.noAccessFieldList.size() == 0) || guestUserExceptions.contains(guestUserId))
                {
                    for(User us: userList){
                        if(us.ContactId!= null && (us.profileId==DprofileId || us.profileId==WAprofileId || us.ProfileId == readOnlyprofileId) 
                           && us.IsPortalEnabled == true)
                        {
                            if(groupNameIdMap.containsKey('ATI_'+accountIdWRAccTypeMap.get(us.AccountId)+'_'+us.AccountId)){
                                gmlist.add(new GroupMember(GroupId=groupNameIdMap.get('ATI_'+accountIdWRAccTypeMap.get(us.AccountId)+'_'+us.AccountId), UserOrGroupId = us.Id));
                            }
                        }
                    }
                }
                if (!gmlist.isEmpty()) {
                    List<String> fieldsForGrpMember = new List<String> {'GroupId','UserOrGroupId'};
                    String sObjName4 = 'GroupMember';
                    ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject4 = ATI_Utils.fetchCreateAccess(sObjName4,fieldsForGrpMember);
                    //ALSN-93 added exception for guest user
                    if((noAccessObjectFieldWrapperObject4.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject4.noAccessFieldList.size() == 0) || guestUserExceptions.contains(guestUserId))
                    {
                        insert gmlist;
                    }
                }
            }
        } catch (exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
         
    }
    
    private static void getPortalProfileIds(){
        List<String> profilename = new List<String>();
        for(ATI_ProfileManager__mdt pm:[SELECT Id,ATI_Profiles__c FROM ATI_ProfileManager__mdt]){
            profilename =(pm.ATI_Profiles__c.split(',')); 
        }
        for(Profile pid :[SELECT Id,Name FROM Profile WHERE Name IN: profilename]){
            if(pid.Name.equalsignorecase(Label.ATI_WarrantyApprover)){
                WAprofileId = pid.Id;
            }
            if(pid.Name.equalsignorecase(Label.ATI_DealerDistributor)){
                DprofileId = pid.Id;  
            }
            if(pid.Name.equalsignorecase(Label.ATI_ReadOnlyDealerProfile)){
                readOnlyprofileId = pid.Id;  
            } 
        }
    }
    
    private static void addUserinGroupAfterUpdate(List<User> newUserList,Map<id,User> oldUserMap){
        getPortalProfileIds();
        Map<Id,User> usersToAddInGroupMap = new Map<Id,User>();
        for(User userObj : newUserList){
            if((userObj.ProfileId == WAprofileId || userObj.ProfileId == DprofileId || userObj.ProfileId == readOnlyprofileId) 
               && (oldUserMap.get(userObj.Id).ProfileId != WAprofileId && oldUserMap.get(userObj.Id).ProfileId != DprofileId
                   && oldUserMap.get(userObj.Id).ProfileId != readOnlyprofileId))
            {
                usersToAddInGroupMap.put(userObj.Id,userObj);
            }
        }
        
        Set<String> strKeySet = new Set<String>();
        for(GroupMember gpMemObj : [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE UserOrGroupId IN :usersToAddInGroupMap.keySet()]){
            strKeySet.add(gpMemObj.GroupId+'-'+gpMemObj.UserOrGroupId);
        }
        
        List<GroupMember> groupMemberList = new List<GroupMember>();
        for(User userObj : [SELECT AccountId,Account.Public_Group_Id__c FROM User
                            WHERE Account.Public_Group_Id__c != NULL AND Id IN :usersToAddInGroupMap.keySet()])
        {
            if(!strKeySet.contains(userObj.Account.Public_Group_Id__c+'-'+userObj.Id)){
                groupMemberList.add(new GroupMember(GroupId = userObj.Account.Public_Group_Id__c, 
                                                    UserOrGroupId = userObj.Id));
            }
        }
        if(!groupMemberList.isEmpty()){
            Database.UpsertResult[] saveResultBaccountShareList = Database.upsert(groupMemberList, true);
        }
    }
}