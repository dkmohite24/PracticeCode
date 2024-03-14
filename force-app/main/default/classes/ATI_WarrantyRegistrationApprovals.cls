/* Name: ATI_WarrantyRegistrationApprovals
Description : This class is used to for both Auto & Manual Approval of warranty Registration  
Author : Manoj Paul(MP)
History:
VERSION     AUTHOR                 DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(MP)             04/12/2020                  INITIAL DEVELOPMENT                              
*/
public without sharing class ATI_WarrantyRegistrationApprovals{
    @InvocableMethod
    public static void wrAutoManualApproval(List<WOD_2__Warranty_Registration__c> wodwrlst){
        System.debug('WR Record ----> '+wodwrlst);
        assignDistribtorApprovalGroup(wodwrlst);
    }
     
    public static void assignDistribtorApprovalGroup(List<WOD_2__Warranty_Registration__c> wodwrlst){
        /*List<WOD_2__Warranty_Registration__Share> wRShareToInsertLst = new  List<WOD_2__Warranty_Registration__Share>();

        Set<String> accIdSet = new Set<String>();
        for(WOD_2__Warranty_Registration__c wrObj : wodwrlst){
            accIdSet.add(wrObj.WOD_2__Account__c);
        }
        
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,ATI_Alternate_Parent__c
                                                        FROM Account
                                                        WHERE Id IN : accIdSet]);*/
        List<WOD_2__Inventory__c> inventoriesToUpdateLst = new List<WOD_2__Inventory__c>();
        List<WOD_2__Warranty_Registration__c> wrToUpdateLst = new List<WOD_2__Warranty_Registration__c>();
        //Map<Id,Id> accIdToWarrantyApproverGroupMap =  getWarrantyApproverGroups(accMap);
        for(WOD_2__Warranty_Registration__c wrObj : wodwrlst){
            /*if(accMap.get(wrObj.WOD_2__Account__c).ATI_Alternate_Parent__c != NULL
                && accIdToWarrantyApproverGroupMap.containsKey(accMap.get(wrObj.WOD_2__Account__c).ATI_Alternate_Parent__c)){
                wRShareToInsertLst.add(new WOD_2__Warranty_Registration__Share(AccessLevel = 'Edit',        
                                                                                ParentId = wrObj.Id,        
                                                                                UserOrGroupId  = accIdToWarrantyApproverGroupMap.get(accMap.get(wrObj.WOD_2__Account__c).ATI_Alternate_Parent__c)        
                                                                              ));
            }*/
            WOD_2__Inventory__c  invObj = new WOD_2__Inventory__c(Id=wrObj.WOD_2__Inventory__c,ATI_Warranty_Status__c='Pending Distributor Approval');
            if(wrObj.ATI_Pre_Delivery__c){
                invObj.WOD_2__Type__c='Stock';
                wrToUpdateLst.add(new WOD_2__Warranty_Registration__c(Id=wrObj.Id,
                                                                      WOD_2__Registration_Type__c = 'Pre-Delivery'));
            }
            inventoriesToUpdateLst.add(invObj);
        }
        
        if(!wrToUpdateLst.isEmpty()){
            update wrToUpdateLst;
        }
        
        if(!inventoriesToUpdateLst.isEmpty()){
            /*ATI_Utils.NoAccessObjectFieldWrapper sObjCreateAccessCheck = ATI_Utils.fetchCreateAccess('WOD_2__Warranty_Registration__Share',new List<String>{'AccessLevel',
                                                                                                                                                            'ATI_Alternate_Parent__c',
                                                                                                                                                            'UserOrGroupId'});
            if(sObjCreateAccessCheck.noAccessObjectList.size() == 0 && sObjCreateAccessCheck.noAccessFieldList.size() == 0){
                insert wRShareToInsertLst;
            }*/ 
            ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheck = ATI_Utils.fetchUpdateAccess('WOD_2__Inventory__c',new List<String>{'ATI_Warranty_Status__c'});
            if(sObjUpdateAccessCheck.noAccessObjectList.size() == 0 && sObjUpdateAccessCheck.noAccessFieldList.size() == 0){
                TriggerHandler.bypass('ATI_InventoryTriggerHandler');
                update inventoriesToUpdateLst;
                TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
            }
        }
    }

    /*private static Map<Id,Id> getWarrantyApproverGroups(Map<Id,Account> accMap){
        Map<Id,Id> accIdToGroupIdMap = new Map<Id,Id>();
        Set<String> accKeySet = new Set<String>();
        for(Account acc : accMap.values()){
            accKeySet.add('ATI_Warranty_Approver_'+acc.ATI_Alternate_Parent__c);
        }
        System.debug('accKeySet---------->'+accKeySet);
        for(Group groupObj : [SELECT Id,Name FROM Group WHERE Name IN :accKeySet]){
            accIdToGroupIdMap.put(groupObj.Name.subString(groupObj.Name.lastIndexOf('_')+1),groupObj.Id);
        }
        return accIdToGroupIdMap;
    }*/
    
    /*public static void assignClaimProcessorGroup(Id recordId,Id groupId){
        WOD_2__Warranty_Registration__Share wrShareObj = new WOD_2__Warranty_Registration__Share(AccessLevel = 'Edit',        
                                                                                                 ParentId = recordId,        
                                                                                                 UserOrGroupId  = groupId        
                                                                                                );
        ATI_Utils.NoAccessObjectFieldWrapper sObjCreateAccessCheck = ATI_Utils.fetchCreateAccess('WOD_2__Warranty_Registration__Share',new List<String>{'AccessLevel',
                                                                                                                                                        'ParentId',
                                                                                                                                                        'UserOrGroupId'});
        if(sObjCreateAccessCheck.noAccessObjectList.size() == 0 && sObjCreateAccessCheck.noAccessFieldList.size() == 0){
            ATI_QueryRunWithoutSharing.insertData(new List<SObject>{wrShareObj});
        } 
    }*/
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper updateWRANDINV(String action,Id recordId,String regComments, String dispCode){
        try{
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            List<String> fieldsForWR = new List<String> {'WOD_2__Registration_Type__c','WOD_2__Status__c','WOD_2__Inventory__c',
                                                        'ATI_Pre_Delivery__c','CreatedBy.Name','WOD_2__Inventory__r.Name','WOD_2__Account__r.twodcms__Primary_Email_Id__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',fieldsForWR);
            WOD_2__Warranty_Registration__c wrObj =  new WOD_2__Warranty_Registration__c();
            if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
            {
                wrObj = [SELECT Id,WOD_2__Registration_Type__c,WOD_2__Status__c,WOD_2__Warranty_Start_Date__c,WOD_2__Warranty_End_Date__c,ATI_NOException__c,
                                WOD_2__Inventory__c,ATI_Pre_Delivery__c,CreatedBy.Name,WOD_2__Registration_Comments__c,WOD_2__Account__r.ATI_Primary_Email_Id__c,
                                WOD_2__Inventory__r.Name,WOD_2__Account__r.twodcms__Primary_Email_Id__c,(SELECT Id,WOD_2__Transaction_Status__c
                                FROM Transaction_Memo_Histories__r WHERE WOD_2__Transaction_Status__c='Draft')
                        FROM WOD_2__Warranty_Registration__c
                        WHERE Id=:recordId];
                //wrObj.WOD_2__Registration_Comments__c = regComments;
                if(profileName == 'ATI Dealer Warranty Approver'){
                    ATI_ConversationController.saveConversationToSObject(regComments,wrObj.WOD_2__Inventory__c,'D');
                }else{
                    ATI_ConversationController.saveConversationToSObject(regComments,wrObj.WOD_2__Inventory__c,'BOTH');
                }
            
                ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObjectInv = ATI_Utils.fetchReadAccess('WOD_2__Inventory__c',new List<String>{'WOD_2__Type__c'});
                List<SObject> invLst =  new List<SObject>();
                if(noAccessObjectFieldWrapperObjectInv.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObjectInv.noAccessFieldList.size() == 0)
                {
                    String queryStr = 'SELECT Id,WOD_2__Type__c,ATI_Warranty_Status__c,WOD_2__Warranty_Start_Date__c,WOD_2__Warranty_End_Date__c FROM WOD_2__Inventory__c WHERE Id=\''+wrObj.WOD_2__Inventory__c+'\'';
                    invLst = ATI_QueryRunWithoutSharing.runQuery(queryStr);
                }
                String status ='';
                List<Id> groupMemsLst = new List<Id>();
                Id groupId;
                for(GroupMember gpMemberObj : [SELECT Id, UserOrGroupId,GroupId
                                                FROM GroupMember
                                                WHERE Group.DeveloperName = 'ATI_Warranty_Processor_Group'])
                {   
                    groupId = gpMemberObj.GroupId;
                    groupMemsLst.add(gpMemberObj.UserOrGroupId);
                } 

                WOD_2__Transaction_Memo_History__c tmhToUpdateObj = new WOD_2__Transaction_Memo_History__c();
                //List<SObject> wrSharedRecsToDeleteLst = getWRSharedRecords(recordId);
                WOD_2__Warranty_Registration__c wrObjTemp = new WOD_2__Warranty_Registration__c();
                if(action == 'Approve'){
                    if((groupMemsLst.contains(UserInfo.getUserId())) 
                       || profileName == 'ATI Warranty Admin'
                       || profileName == 'System Administrator'
                       || profileName == 'ATI Warranty PRP Admin'
                       || profileName == 'ATI PRP Warranty Admin')
                    {  
                        wrObj.WOD_2__Status__c = 'Registered';
                        //invLst[0].put('WOD_2__Type__c','Retail');
                        wrObjTemp = wrObj;
                        if(wrObj.ATI_Pre_Delivery__c == true){
                            Id retailRTId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
                            invLst[0].put('WOD_2__Type__c','Stock');
                            invLst[0].put('RecordTypeId',retailRTId);
                        }
                        if(wrObj.WOD_2__Warranty_Start_Date__c != NULL && wrObj.WOD_2__Warranty_End_Date__c != NULL){
                            invLst[0].put('WOD_2__Warranty_Start_Date__c',wrObj.WOD_2__Warranty_Start_Date__c);
                            invLst[0].put('WOD_2__Warranty_End_Date__c',wrObj.WOD_2__Warranty_End_Date__c);
                        }
                        invLst[0].put('ATI_Warranty_Status__c','Approved');
                        if(wrObj.Transaction_Memo_Histories__r.size() > 0){
                            tmhToUpdateObj = wrObj.Transaction_Memo_Histories__r[0];
                            tmhToUpdateObj.WOD_2__Transaction_Status__c = 'Pending';
                        }
                    }else if(profileName == 'ATI Dealer Warranty Approver'){ //if(groupId != NULL)
                        //assignClaimProcessorGroup(recordId,groupId);
                        if(wrObj.ATI_NOException__c == True){
                            //ALSN-18 Adding the TMH and Inventory update on approval from Dealer too.
                            wrObj.WOD_2__Status__c = 'Registered'; 
                            wrObjTemp = wrObj;
                            if(wrObj.ATI_Pre_Delivery__c == true){
                                Id retailRTId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
                                invLst[0].put('WOD_2__Type__c','Stock');
                                invLst[0].put('RecordTypeId',retailRTId);
                            }
                            if(wrObj.WOD_2__Warranty_Start_Date__c != NULL && wrObj.WOD_2__Warranty_End_Date__c != NULL){
                                invLst[0].put('WOD_2__Warranty_Start_Date__c',wrObj.WOD_2__Warranty_Start_Date__c);
                                invLst[0].put('WOD_2__Warranty_End_Date__c',wrObj.WOD_2__Warranty_End_Date__c);
                            }
                            invLst[0].put('ATI_Warranty_Status__c','Approved');
                            if(wrObj.Transaction_Memo_Histories__r.size() > 0){
                                tmhToUpdateObj = wrObj.Transaction_Memo_Histories__r[0];
                                tmhToUpdateObj.WOD_2__Transaction_Status__c = 'Pending';
                            }
                        }
                        else{
                        wrObj.WOD_2__Status__c = 'Pending Warranty Processor Approval';
                        invLst[0].put('ATI_Warranty_Status__c','Pending Warranty Processor Approval');
                        }
                    }else{
                        return new WOD_2.ResponseWrapper('[]',false,System.Label.ATI_You_are_not_allowed_to_approve_reject_Warranty_Registration);
                    }
                }
                else if(action == 'Reject'){ 
                    wrObj.WOD_2__Status__c = 'Rejected';
                    wrObj.ATI_Disposition_Code__c = dispCode;
                    List<WOD_2__Warranty_Registration__c> registeredWRLst = [SELECT Id FROM WOD_2__Warranty_Registration__c
                                                                                WHERE WOD_2__Inventory__c=:wrObj.WOD_2__Inventory__c
                                                                                    AND WOD_2__Status__c = 'Registered' AND ATI_Pre_Delivery__c = False];
                    if(registeredWRLst.isEmpty()){
                        Id stockRTId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
                        invLst[0].put('WOD_2__Type__c','Stock');
                        invLst[0].put('RecordTypeId',stockRTId);
                    }
                    invLst[0].put('ATI_Warranty_Status__c','Rejected');
                    wrObjTemp = wrObj;
                }
                
                ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckWR = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Registration__c',new List<String>{'WOD_2__Status__c'});
                if(sObjUpdateAccessCheckWR.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckWR.noAccessFieldList.size() == 0){
                    update wrObj;
                    if(tmhToUpdateObj.Id != NULL){
                        update tmhToUpdateObj;
                    }
                    if(wrObjTemp != NULL && (wrObjTemp.WOD_2__Status__c == 'Registered' || wrObjTemp.WOD_2__Status__c == 'Rejected') ){
                        sendEmailToCustomer(wrObjTemp);
                    }
                }

                ATI_QueryRunWithoutSharing.updateRecordsWithoutSharing(invLst,false);
                /*if(!wrSharedRecsToDeleteLst.isEmpty()){
                    ATI_QueryRunWithoutSharing.deleteData(wrSharedRecsToDeleteLst,false);
                }*/
            }
            return new WOD_2.ResponseWrapper('',true,'');
        }
        catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
    private static void sendEmailToCustomer(WOD_2__Warranty_Registration__c wrObj){
        String templateName;
        if(wrObj.WOD_2__Status__c == 'Registered'){
            templateName = 'Warranty Registration Approved Template';
        }else if(wrObj.WOD_2__Status__c == 'Rejected'){
            templateName = 'Warranty Registration Rejection Template';
        }
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body 
                                        FROM EmailTemplate 
                                        WHERE Name =:templateName]; 
        if(wrObj.WOD_2__Account__r.ATI_Primary_Email_Id__c != NULL){
            String subject = emailTemplate.Subject;
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!WOD_2__Warranty_Registration__c.CreatedBy}', wrObj.CreatedBy.Name);
            plainBody = plainBody.replace('{!WOD_2__Warranty_Registration__c.WOD_2__Inventory__r.Name}', wrObj.WOD_2__Inventory__r.Name);

            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

            email.setReplyTo(wrObj.WOD_2__Account__r.ATI_Primary_Email_Id__c);
            email.setSenderDisplayName(wrObj.WOD_2__Account__r.ATI_Primary_Email_Id__c);
            //email.setTargetObjectId(wrObj.Id);
            email.setSaveAsActivity(true);
            email.setToAddresses(new List<String>{wrObj.WOD_2__Account__r.ATI_Primary_Email_Id__c});

            email.setSubject(subject);
            //email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);

            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
        }
    }


    /*private static List<WOD_2__Warranty_Registration__Share> getWRSharedRecords(Id recordId){
        List<WOD_2__Warranty_Registration__Share> wrShareRecordsLst = [SELECT Id,RowCause
                                                                        FROM WOD_2__Warranty_Registration__Share
                                                                        WHERE ParentId=:recordId
                                                                            AND RowCause != 'Owner'];
        return wrShareRecordsLst;
    }*/

    @AuraEnabled
    public static WOD_2.ResponseWrapper getWRForApprovalAndCheckEditAccess(String recordId,String objType){
        try {
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            String queryStr = 'SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE (WOD_2__Status__c = \'In Progress\' OR WOD_2__Status__c = \'Pending Warranty Processor Approval\') AND  ';
            if(objType == 'WOD_2__Inventory__c'){
                queryStr = queryStr+' WOD_2__Inventory__c= \''+recordId+'\'';
            }else if(objType == 'WOD_2__Warranty_Registration__c'){
                queryStr = queryStr+' Id= \''+recordId+'\'';
            }
            List<WOD_2__Warranty_Registration__c> wrLst = Database.query(queryStr);
            
            List<Id> groupMemsLst = new List<Id>();
            for(GroupMember gpMemberObj : [SELECT Id, UserOrGroupId,GroupId
                                           FROM GroupMember
                                           WHERE Group.DeveloperName = 'ATI_Warranty_Processor_Group'])
            {   
                groupMemsLst.add(gpMemberObj.UserOrGroupId);
            }
            
            UserRecordAccess userRecAccessObj = new UserRecordAccess();
            if(!wrLst.isEmpty()){
                userRecAccessObj = [SELECT RecordId,HasEditAccess 
                                        FROM UserRecordAccess 
                                        WHERE UserId=:UserInfo.getUserId() 
                                            AND RecordId=:wrLst[0].Id];
                if(userRecAccessObj.HasEditAccess == true && (profileName == 'ATI Warranty Admin' || profileName == 'ATI PRP Warranty Admin' || profileName == 'ATI Warranty PRP Admin'
                                                             || (groupMemsLst.contains(UserInfo.getUserId()))
                                                             || (profileName == 'ATI Dealer Warranty Approver' && wrLst[0].WOD_2__Status__c=='In Progress')
                                                             || profileName == 'System Administrator')){
                    return new WOD_2.ResponseWrapper(JSON.serialize(wrLst[0]),true,'');
                } else{
                    return new WOD_2.ResponseWrapper('No Access to edit.',false,'');
                }
            }
            return new WOD_2.ResponseWrapper('No Records.',false,'');                                         
        } catch (Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
}