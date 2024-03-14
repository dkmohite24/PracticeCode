public without sharing class ATI_ClaimAction_BaseController{
    static List<WOD_2__Claim__c> claimList = new List<WOD_2__Claim__c>();
    
    // check if logged used is valid approver
    @auraEnabled
    public static WOD_2.ResponseWrapper checkIsValidApprover(String claimId) {
        Id currentUserId = UserInfo.getUserId();
        claimList = [
            SELECT WOD_2__Claim_Status__c,WOD_2__BusinessCategory__c
            FROM WOD_2__Claim__c
            WHERE Id = :claimId
        ];
        Boolean hasAccess = false;
        system.debug('claimList[0].Id----------' +claimList[0].Id);
        ProcessInstanceWorkitem workItem = getWorkItem(claimList[0].Id);
        if(claimList[0].WOD_2__Claim_Status__c == 'Submitted'){
            system.debug('workItem.ActorId----'+workItem.ActorId);
            if (workItem != null && workItem.ActorId != null) {
                // check if targeted approver is user or Queue of users
                if (String.valueof(workItem.ActorId).substring(0, 3) == '00G') {
                    hasAccess = recursionToIterateGroup(String.valueof(workItem.ActorId), currentUserId);
                } else if (String.valueof(workItem.ActorId).substring(0, 3) == '005' && currentUserId == workItem.ActorId) {
                    hasAccess = true; // logged user is valid approver
                } else {
                    List<ProcessInstanceWorkitem> workItemList = [
                        SELECT Id, ActorId
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :claimList[0].Id
                    ];
                    for (ProcessInstanceWorkitem pwi : workItemList) {
                        if (String.valueof(pwi.ActorId).substring(0, 3) == '005' && currentUserId == pwi.ActorId) {
                            hasAccess = true;
                            break;
                        }
                    }
                }
            }
        }else{
            hasAccess = true;
        }
        if(!hasAccess){
            hasAccess = checkWhiteListedProfile(claimList[0].WOD_2__BusinessCategory__c);
        }
        return new WOD_2.ResponseWrapper(JSON.serialize(hasAccess), true, '');
    }
    
    // Allow internal users and special categery users to approve - defined in Business Category Configuration Settings
    private static Boolean checkWhiteListedProfile(Id buId) {
        String profileNameString = ATI_Utils.getConfiguration(buId, 'ATI Claim Action White Listed Profile').WOD_2__Value__c;
    return isProfilesPresent(profileNameString);
    }
    private static Boolean isProfilesPresent(String profileNameString) {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        List<String> profileNameList = profileNameString.split(',');
        
        for (String profileNameLocal : profileNameList) {
            if (profileNameLocal.trim() == profileName) {
                return true;
            }
        }
        return false;
    }
    // returns the cuurent approval step details of claim if submitted for approval
    private static ProcessInstanceWorkitem getWorkItem(Id targetObjectId) {
        ProcessInstanceWorkitem workItemToReturn = new ProcessInstanceWorkitem();
        for (ProcessInstanceWorkitem workItem : [
            SELECT Id, ActorId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :targetObjectId
        ]) {
            workItemToReturn = workItem;
            break;
        }
        return workItemToReturn;
    }
    // Recursion methos to campare users from publig groups
    @TestVisible
    private static Boolean recursionToIterateGroup(String queueId, Id currentUserId) {
        List<GroupMember> groupMemberList = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueId];
        for (GroupMember groupMember : groupMemberList) {
            String userOrGroupId = String.valueof(groupMember.UserOrGroupId);
            if (userOrGroupId.substring(0, 3) == '00G') {
                // call the same methos and campare current user with all users in group
                Boolean isApprover = recursionToIterateGroup(userOrGroupId, currentUserId);
                if (isApprover) {
                    return true;
                }
            } else if (userOrGroupId.substring(0, 3) == '005' && currentUserId == userOrGroupId) {
                // logged user is valid approver
                return true;
            }
        }
        return false;
    }
}