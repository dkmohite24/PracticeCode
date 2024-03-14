/* Name: ATI_ClaimTriggerHandler
Description : Trigger Handler for ATI_ClaimTrigger
Author : Tavant (Akshatha S)
History :
VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
1.0 -       Tavant (Akshatha S)    30/11/2020          INITIAL DEVELOPMENT
1.1         Tavant                 28/01/2022          Code changes for Reopen and Rejected Claims.(ATI_is_Claim_Rejected__c)
*/
public with sharing class ATI_ClaimTriggerHandler extends TriggerHandler{
    public static Boolean RUN_BU_RULES = true;
    public static Boolean isClaimShared = false;
    public static Boolean skipBeforeInsertForITR = false;
    public static Boolean skipBeforeUpdateForITR = false;
    public static Boolean skipTriggerRunForBatchClaims = false;
    public static Boolean skipClaimHandlerOnClaimSaveForITR = false;
    private static Boolean skipFLIUpdate = false;
    private List<WOD_2__Claim__c> newClaimList;
    private List<WOD_2__Claim__c> oldClaimList;
    private Map<Id, WOD_2__Claim__c> newClaimMap;
    private Map<Id, WOD_2__Claim__c> oldClaimMap;
    
    /*
Method Name :   ATI_ClaimTriggerHandler
Params      :   Constructor
*/
    public ATI_ClaimTriggerHandler(){
        this.newClaimList = (List<WOD_2__Claim__c>)Trigger.new;
        this.oldClaimList= (List<WOD_2__Claim__c>)Trigger.old;
        this.newClaimMap= (Map<Id, WOD_2__Claim__c>)Trigger.newMap;
        this.oldClaimMap= (Map<Id, WOD_2__Claim__c>)Trigger.oldMap;
    }
    /*
Method Name :   beforeInsert
Params      :   Claim beforeInsert method
*/
    
    public override void beforeInsert() {
        if(!skipBeforeInsertForITR){
            setCoveragePercentage(false);
        }
        //ALSN-37
        WOD_2.ResponseWrapper responseWrapperObj = validateInstallManufactureDates(newClaimList);
        if(!responseWrapperObj.status){
            this.newClaimList.get(0).addError(responseWrapperObj.errorMessage);
        }       
        if(!skipTriggerRunForBatchClaims){
            Map<ID,Account> accountIdToAccountRecordMap = New Map<ID,Account>();
            Set<Id> invIdsSet = new Set<Id>();
            for (WOD_2__Claim__c claimRec: newClaimList) {
                /*if(claimRec.WOD_2__Is_Pre_Authorization_Required__c == True){
claimRec.WOD_2__Pre_Authorization_Reason__c = 'Goodwill';
}*/
                // ADDED by ALSN-94
                if(claimRec.WOD_2__Is_Pre_Authorization_Required__c == FALSE){
                    claimRec.WOD_2__Pre_Authorization_Reason__c = null;
                    claimRec.WOD_2__Pre_Authorization_Comments__c = null;
                } 
                
                if(claimRec.WOD_2__Account__c != NULL){
                    accountIdToAccountRecordMap.put(claimRec.WOD_2__Account__c,NULL);  
                    system.debug('accountIdToAccountRecordMap'+accountIdToAccountRecordMap);
                }
                //Modified By Dishari on 28/09/2021 for Bug 28184: Missing Fields from Internal UI
                if(claimRec.ATI_WR_Details__c != NULL){
                    ATI_WarrantyService.WRDetailsWrapper wrWrapper = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimRec.ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
                    claimRec.ATI_VIN__c = wrWrapper.vehicleInfo.Name;
                    system.debug('claimRec.ATI_VIN__c'+claimRec.ATI_VIN__c);
                }
                //End of Modification By Dishari on 28/09/2021 for Bug 28184: Missing Fields from Internal UI
                
                if(claimRec.ATI_WR_Details__c != null){
                    invIdsSet.add(claimRec.WOD_2__Inventory__c);
                }
                //Alsn-149.......
                if(claimRec.ATI_WR_Details__c != null && claimRec.ATI_In_Service_Date__c !=null && claimRec.ATI_isPreDelivery__c == true){
                    claimRec.addError(Label.ATI_WR_installDEmptyCheck);
                }
                // end of Alsn-149........
            } 
            for(Account account : [SELECT Id,ATI_Primary_Email_Id__c FROM Account WHERE ID IN:accountIdToAccountRecordMap.keySet()]){
                accountIdToAccountRecordMap.put(account.Id,account); 
                system.debug('accountIdToAccountRecordMap'+accountIdToAccountRecordMap);
            }  
            for (WOD_2__Claim__c claimRec: newClaimList) {
                if(accountIdToAccountRecordMap.get(claimRec.WOD_2__Account__c) != NULL){
                    claimRec.ATI_Account_Email__c =  accountIdToAccountRecordMap.get(claimRec.WOD_2__Account__c).ATI_Primary_Email_Id__c;
                }   
            }
            //update customer on inventory when customer is changed
            if(!invIdsSet.isEmpty()){
                updateCustomerOnInventory(newClaimList,invIdsSet);
            }
        }
    }
    
    /*
Method Name :   afterInsert
Params      :   Claim afterInsert method
*/
    public override void afterInsert() {
        validateClaimsForBURules(newClaimMap);
        //added by dishari
        claimAutoNumber();
        if(!skipTriggerRunForBatchClaims){
            //end
            set<String> accGroupIds = new set<String>();
            set<Id> claimIds = new set<Id>();
            String claimObjName = 'WOD_2__Claim__c';
            List<String> claimFields = new List<String>{'WOD_2__Account__c'};
                ATI_Utils.NoAccessObjectFieldWrapper claimNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(claimObjName,claimFields);
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            if(claimNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                //for (WOD_2__Claim__c claimRec: [SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Claim__c WHERE Id IN :newClaimList]) {
                //Added by Yamini[25 Jan 2021] -  RecordType updated in query i.e, For ClaimTemplate Account is not Required
                for (WOD_2__Claim__c claimRec: [SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Claim__c WHERE Id IN :newClaimList AND WOD_2__Claim_Type__c IN ('Machine','Part','Campaign')]) {
                    claimIds.add(claimRec.Id);
                    String groupObjName = 'Group';
                    List<String> groupFields = new List<String>{'Name'};
                        ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);
                    if(groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                        accGroupIds.add('ATI_Dealer_'+ claimRec.WOD_2__Account__c);
                    }else{
                        throw new TWoDException(Label.ATI_Log_Insufficient_access);
                    }
                }
                if(!claimIds.isEmpty() && !accGroupIds.isEmpty() && !system.isBatch()){
                    ATI_QueueableUtil.enqueueJob(new ATI_AddClaimShareRecords(accGroupIds,claimIds)); 
                    //addClaimShareRecords(accGroupIds,claimIds); 
                } else if(!claimIds.isEmpty() && !accGroupIds.isEmpty() && System.isBatch()){
                    new ATI_AddClaimShareRecords(accGroupIds,claimIds).execute(null); 
                }
            }
        }
    }
    
    public static void validateClaimsForBURules(Map<Id, WOD_2__Claim__c> newClaimMap){
        if(RUN_BU_RULES == true){
            //System.debug('validateClaimsForBURules>>>> ');
            List<WOD_2__Business_Rule__c> burRulesTriggeredLst = 
                ATI_BURulesService.runBURules(newClaimMap.values()[0].WOD_2__BusinessCategory__c,'WOD_2__Claim__c',new List<Id>(newClaimMap.keySet()),
                                              'Claim','Claim UI - Basic Info');
            Map<Id,String> claimIdToErrorStrMap = new Map<Id,String>();
            for(WOD_2__Business_Rule__c buRuleObj :burRulesTriggeredLst){
                if(buRuleObj.WOD_2__Error_Type__c =='Hard' && buRuleObj.WOD_2__Message__c != NULL){
                    if(!claimIdToErrorStrMap.containsKey(buRuleObj.WOD_2__Claim__c)){
                        claimIdToErrorStrMap.put(buRuleObj.WOD_2__Claim__c,buRuleObj.WOD_2__Message__c);
                    }else{
                        claimIdToErrorStrMap.put(buRuleObj.WOD_2__Claim__c,claimIdToErrorStrMap.get(buRuleObj.WOD_2__Claim__c)+', '+buRuleObj.WOD_2__Message__c);
                    }
                }
            }
            for(WOD_2__Claim__c claimObj : (List<WOD_2__Claim__c>)Trigger.New){
                if(claimIdToErrorStrMap.containsKey(claimObj.Id)){
                    claimObj.addError(claimIdToErrorStrMap.get(claimObj.Id));
                }
                if(claimObj.ATI_WR_Details__c != null){
                    System.debug('pppppppp'+claimObj.ATI_WR_Details__c);
                    ATI_WarrantyService.WRDetailsWrapper wrWrapper = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimObj.ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
                    WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
                    List<WOD_2__Warranty_Registration__c> preDelWRLst = [SELECT Id FROM WOD_2__Warranty_Registration__c 
                                                                         WHERE WOD_2__Inventory__c=:claimObj.WOD_2__Inventory__c
                                                                         AND ATI_Pre_Delivery__c = true AND WOD_2__Status__c = 'Registered'];
                    if((wrWrapper.WOD_2_Type_c != 'Retail' && wrWrapper.ATI_Pre_Delivery_c==false) 
                       || (wrWrapper.ATI_Pre_Delivery_c==true && preDelWRLst.isEmpty()))
                    {
                        responseWrapperObj = validateAndCreateWR(claimObj.WOD_2__Account__c, claimObj.WOD_2__Inventory__c, wrWrapper, new WOD_2.ResponseWrapper(JSON.serialize(claimObj), true, ''));
                    }  
                    if(!responseWrapperObj.status){
                        claimObj.addError(responseWrapperObj.errorMessage);
                    } 
                }
            } 
        }
    }
    
    /*
Method Name :   validateAndCreateWR
Params      :   Method to validate and create WR for stock inventory
*/
    private static WOD_2.ResponseWrapper validateAndCreateWR(Id accountId, Id invId, ATI_WarrantyService.WRDetailsWrapper wrWrapper, WOD_2.ResponseWrapper response){
        if(String.isBlank(wrWrapper.vehicleInfo.Name) ||
           String.isBlank(wrWrapper.vehicleInfo.ATI_Vehicle_Make__c) ||
           String.isBlank(wrWrapper.vehicleInfo.ATI_Vehicle_Model__c)) {
               
               // ||  wrWrapper.vehicleInfo.ATI_Vehicle_Mileage_Usage__c == null ){
               response.status = false;
               response.errormessage = Label.TWoD_Fill_Required_Fields;
               return response;        
           }
        WOD_2.WR_InventoryRegistrationWrapper irw = ATI_WarrantyService.getInvRegWrapper(accountId, invId, wrWrapper);
        //Alsn-161
        ATI_WR_RegistrationHandler.duplicatewr = false;
        ATI_WntyRegistrationTriggerHandler.duplicatewr = false;
        //end of Alsn-161
        WOD_2.ResponseWrapper res = new ATI_WR_RegistrationHandler().saveWarrantyRegistration(irw);
        if(res.status){
            //Commented for VIN Transmission Mapper object--- wrWrapper.vehicleInfo.ATI_Inventory__c = invId;
            system.debug('JSON.serialize(wrWrapper.vehicleInfo)**'+JSON.serialize(wrWrapper.vehicleInfo));
            String vehicleInfoList = JSON.serialize(wrWrapper.vehicleInfo);
            String s = vehicleInfoList.removeEnd('}')  + ',\"ATI_Inventory__c\":\"' + invId + '\"}';
            res = ATI_VehicleInformationController.saveVehicleInfo(s);
            if(res.status){
                try{
                    ATI_WarrantyService.registerWithStdPolicies(irw.registrationData.Id);    
                }catch(DMLException e){
                    response.status = false;
                    response.errormessage = e.getDmlMessage(0);
                }catch(Exception e){
                    response.status = false;
                    response.errormessage = e.getMessage();
                }
                return response;
            }
        }
        response.status = false;
        response.errormessage = res.errormessage;
        return response;
    }
    
    /*
Method Name :   addClaimShareRecords
Params      :   Method to create claim sharing records with account's group
*/
    /* 
@future
private static void addClaimShareRecords(set<String> accGroupIds,set<Id> claimIds){
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
} */
    
    /*
Method Name :   before Update
Params      :   Claim beforeUpdate method
*/
    public override void beforeUpdate() {
        if(!skipBeforeUpdateForITR){
            setCoveragePercentage(true);
        }
        //ALSN-37
        WOD_2.ResponseWrapper responseWrapperObj = validateInstallManufactureDates(newClaimList);
        if(!responseWrapperObj.status){
            this.newClaimList.get(0).addError(responseWrapperObj.errorMessage);
        }
        //validateRCPandMarkClaim();// Added By Mukesh
        //System.debug('>> Before Updated Called: >>1');
        set<Id> claimIds = new set<Id>();
        Set<Id> invIdsSet = new Set<Id>();
        List<WOD_2__Claim__c> wrChangedClaimList = new List<WOD_2__Claim__c>();
        for(WOD_2__Claim__c nClaim : newClaimList){
            if(nClaim.ATI_WR_Details__c != null && oldClaimMap.get(nClaim.Id).ATI_WR_Details__c != nClaim.ATI_WR_Details__c){
                invIdsSet.add(nClaim.WOD_2__Inventory__c);
                wrChangedClaimList.add(nClaim);
            }
            // Added by Mukesh 3/11/2021 Start
            if(oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c == 'Draft' && nClaim.WOD_2__Claim_Status__c != oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c){
                nClaim.WOD_2__Submit_Date__c = System.today();
                nClaim.WOD_2__Submitted_By__c = UserInfo.getUserId();
                /* if(nClaim.WOD_2__Is_Pre_Authorization_Required__c == True){
nClaim.WOD_2__Pre_Authorization_Reason__c = 'Goodwill';
}*/
            }
            // Added by Mukesh 3/11/2021 end
            if(nClaim.WOD_2__Claim_Status__c != oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c && nClaim.WOD_2__Claim_Status__c == 'Additional Information Required'){
                nClaim.ATI_Additional_Info_statusDate__c = nClaim.LastModifiedDate.date();
            }
            
            //added by yamini on 04/09/2021 - BatchClaim integration
            if(nClaim.ATI_Claim_Number__c != NULL && nClaim.WOD_2__Claim_Status__c == 'Draft' && nClaim.Name != nClaim.ATI_Claim_Number__c
               && nClaim.WOD_2__Claim_Type__c == 'Campaign'){
                   nClaim.Name = nClaim.ATI_Claim_Number__c;
               }
            /*if(nClaim.WOD_2__Claim_Status__c == 'Approved'|| nClaim.WOD_2__Claim_Status__c == 'Rejected'|| nClaim.WOD_2__Claim_Status__c == 'FSM Rejected' || nClaim.WOD_2__Claim_Status__c == 'Additional Information Required'){
claimIds.add(nClaim.id);
}*/
            
            // Modification added by Anjali for Auto Approve and Update Approved/Rejected Date on Approval and Rejection of Claim
            //Modified by Manoj Paul for Task #24509 of Sprint 6
            String dispospickval = Label.ATI_Claim_AutoApproved_or_Rejected;
            if(nClaim.WOD_2__Claim_Status__c == 'Approved' && (oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c == 'Draft' || oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c == 'Additional Information Required')){
                nClaim.WOD_2__Auto_Approved__c = 'Yes';
                //Modified by Manoj Paul for Task #24509 of Sprint 6
                nClaim.ATI_Disposition_Code__c= dispospickval;
                nClaim.WOD_2__Approved_Rejected_Date__c =System.today();
                nClaim.ATI_is_Claim_Rejected__c = false;
            } else if(nClaim.WOD_2__Claim_Status__c == 'Approved' && oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c != 'Approved'){
                nClaim.ATI_Last_Approved_By__c = UserInfo.getUserId();
                nClaim.ATI_is_Claim_Rejected__c = false;                    
            }
            if(nClaim.WOD_2__Claim_Status__c == 'Rejected' && oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c == 'Draft'){
                nClaim.WOD_2__Approved_Rejected_Date__c =System.today();
                //Modified by Manoj Paul for Task #24509 of Sprint 6
                nClaim.ATI_Disposition_Code__c= dispospickval;
            } else if(nClaim.WOD_2__Claim_Status__c == 'Rejected' && oldClaimMap.get(nClaim.id).WOD_2__Claim_Status__c != 'Rejected'){
                nClaim.ATI_Rejected_By__c = UserInfo.getUserId();
                nClaim.ATI_is_Claim_Rejected__c = true; 
            }
            //End of Modification
            /*Commented By Yamini - not required to share based on status*/
            /*set<String> accGroupIds = new set<String>();
String claimObjName = 'WOD_2__Claim__c';
List<String> claimFields = new List<String>{'WOD_2__Account__c'};
ATI_Utils.NoAccessObjectFieldWrapper claimNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(claimObjName,claimFields);
String accountSObjName = 'Account';
List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
if (claimNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
for (WOD_2__Claim__c claimRec: [SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Claim__c WHERE Id IN :claimIds]) {
claimIds.add(claimRec.Id);
String groupObjName = 'Group';
List<String> groupFields = new List<String>{'Name'};
ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);

if (groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
accGroupIds.add('ATI_Dealer_' + claimRec.WOD_2__Account__c);
}else{
throw new TWoDException(Label.ATI_Log_Insufficient_access);
}
}
//System.debug('>> accGroupIds'+accGroupIds );
//System.debug('>> claimIds'+claimIds );
if(!claimIds.isEmpty() && !accGroupIds.isEmpty() && !system.isBatch() && !isClaimShared){
isClaimShared = true;
System.enqueueJob(new ATI_AddClaimShareRecords(accGroupIds,claimIds)); 
//addClaimShareRecords(accGroupIds,claimIds); 
}
} */
        }
        //update customer on inventory when customer is changed
        if(!invIdsSet.isEmpty()){
            updateCustomerOnInventory(wrChangedClaimList,invIdsSet);
        }
        
        for (WOD_2__Claim__c claimRec: (List<WOD_2__Claim__c>)Trigger.New) {
            if(claimRec.WOD_2__Claim_Status__c == 'Approved' || claimRec.WOD_2__Claim_Status__c == 'Submitted'){
                claimRec.ATI_BatchClaim_Error_Messages__c = '';
            }   
        }
    }
    
    //Added by Ravi on 01/27
    public override void afterUpdate(){
        //updateApprovedAmountForRejectAndNeedInfo(newClaimMap,oldClaimMap);
        if(!skipClaimHandlerOnClaimSaveForITR){
            setClaimSubTypeDesc();
            List<Id> approvedOrRejectedClaimIdList = new List<Id>();
            //Alsn - 143 (added pendingApprovedClaimIdList)
            List<Id> pendingApprovedClaimIdList = new List<Id>();
            List<Id> rejectedCampaignClaimIdList = new List<Id>();            
            List<Id> paidClaimIdList = new List<Id>();
            List<Id> paidRejectedClaimIdList = new List<Id>();
            List<Id> repairDateModifiedList = new List<Id>();            
            List<WOD_2__Claim__c> approvedOrRejectedClaimList = new List<WOD_2__Claim__c>();
            List<WOD_2__Claim__c> approvedClaimList = new List<WOD_2__Claim__c>();
            //List<ATI_Vehicle_Information__c> vehicleInfoList = new List<ATI_Vehicle_Information__c>();
            Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>();
            Set<Id> appealedClaimIdSet = new Set<Id>();
            Set<id> userIdsSet = new Set<id>();
            List<WOD_2__Claim__c> commentedClaimList = new List<WOD_2__Claim__c>();
            
            //map to store claim id and credited TMH - to change claim status to pending payment on rejection
            Map<Id,WOD_2__Transaction_Memo_History__c> claimIdToPaidTMHMap = new Map<Id,WOD_2__Transaction_Memo_History__c>();
            for(WOD_2__Transaction_Memo_History__c tmhObj : [SELECT Id,WOD_2__Claim__c,WOD_2__Transaction_Status__c FROM WOD_2__Transaction_Memo_History__c
                                                             WHERE WOD_2__Claim__c IN :newClaimMap.keySet()
                                                             AND WOD_2__Transaction_Type__c='Credit' ORDER BY CreatedDate ASC])
            {
                claimIdToPaidTMHMap.put(tmhObj.WOD_2__Claim__c,tmhObj);
            }
            system.debug('claimIdToPaidTMHMap-->'+claimIdToPaidTMHMap);
            // Assuming all the claims which will be updated belongs to Same BU for now            
            String dateFieldForPriceFetchStr = ATI_Utils.getConfiguration(newClaimList[0].WOD_2__BusinessCategory__c, 'CLM_Price_Fetch_ClaimField_Tobe_Compare').WOD_2__Value__c;            
            dateFieldForPriceFetchStr = String.isBlank(dateFieldForPriceFetchStr) ? 'WOD_2__Date_Of_Repair__c' : dateFieldForPriceFetchStr;
            for(WOD_2__Claim__c claimObj:newClaimMap.values()) {                
                if(claimObj.WOD_2__Claim_Status__c == 'Appeal' && oldClaimMap.get(claimObj.Id).WOD_2__Claim_Status__c != 'Appeal'){
                    appealedClaimIdSet.add(claimObj.Id);
                }
                //ALSN-72 Updating approved fields on FLI to Null for AIR too.
                if(claimObj.WOD_2__Claim_Status__c == 'Additional Information Required' && oldClaimMap.get(claimObj.Id).WOD_2__Claim_Status__c != 'Additional Information Required'){
                    appealedClaimIdSet.add(claimObj.Id);
                }
                //Alsn-143
                if( claimObj.Shipment_Status__c !=null){ 
                    if((claimObj.Shipment_Status__c == 'Shipment Completed') && claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved')){
                        approvedOrRejectedClaimIdList.add(claimObj.Id);
                    }
                    else if(claimObj.WOD_2__In_Approval_Process__c == true && claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Pending Approval') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Submitted')){
                        pendingApprovedClaimIdList.add(claimObj.Id);
                    }
                    else if(claimObj.Shipment_Status__c == 'Partial Shipment' && claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && claimObj.WOD_2__In_Approval_Process__c == false){
                        approvedOrRejectedClaimIdList.add(claimObj.Id);
                    }
                }
                else if( claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && (claimObj.WOD_2__Claim_Parts_Pending_Approval__c != oldClaimMap.get(claimObj.id).WOD_2__Claim_Parts_Pending_Approval__c && claimObj.WOD_2__Claim_Parts_Pending_Approval__c <=0 && oldClaimMap.get(claimObj.id).WOD_2__Claim_Parts_Pending_Approval__c > 0)) {
                    approvedOrRejectedClaimIdList.add(claimObj.Id);
                }
                // end of Alsn-143
                // when claim is approved without any part returns     
                // ALSN-52
                // ALSN-34 added Draft Status check to create TMH in case of auto approval
                // ALSN-172 removed the draft status condition. now it won't create the TMH on approval instead will be created from batch - ATI_AutoApprovalActionOnClaimBatch
                if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && (oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Submitted') || oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Pending Approval') || oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('FSM Pending Approval')) && claimObj.WOD_2__Claim_Parts_Pending_Approval__c <=0) {                
                    if(!approvedOrRejectedClaimIdList.contains(claimObj.Id)){
                        approvedOrRejectedClaimIdList.add(claimObj.Id);
                    } 
                }               
                Date priceFetchField = (Date)claimObj.get(dateFieldForPriceFetchStr);
                Date oldPriceFetchField = (Date)oldClaimMap.get(claimObj.Id).get(dateFieldForPriceFetchStr);
                if(priceFetchField != null && priceFetchField != oldPriceFetchField){
                    repairDateModifiedList.add(claimObj.Id);       
                }
                
                if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Paid') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Paid')
                   && claimObj.ATI_is_Claim_Rejected__c == true){
                       paidRejectedClaimIdList.add(claimObj.Id);
                   }else if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Paid') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Paid')){
                       paidClaimIdList.add(claimObj.Id);                    
                   }
                
                /*  if( claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Submitted') ){
//unlock record
ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :claimObj.Id
AND ProcessInstance.Status = 'Pending']; 
if(piWorkItems.size() > 0){
Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
pwiRequest.setAction('Removed');
pwiRequest.setWorkItemId(piWorkItems[0].Id);
Approval.ProcessResult result = Approval.process(pwiRequest);
}
}*/
                if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected')) {
                    approvedOrRejectedClaimIdList.add(claimObj.Id);
                    if(claimObj.WOD_2__Claim_Type__c == 'Campaign'){
                        rejectedCampaignClaimIdList.add(claimObj.Id);
                    }
                }
                //Added By Mukesh 3/24/2021 End 
                
                //Added by Dishari 19th feb 21
                /*if((claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') ||claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected')) && oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Draft')){
approvedOrRejectedClaimList.add(claimObj);   
system.debug('approvedOrRejectedClaimList'+approvedOrRejectedClaimList);
}*/
                //End Here
                if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Approved') && !oldClaimMap.get(claimObj.id).WOD_2__Claim_Status__c.equalsIgnoreCase('Approved')){  
                    invMap.put(claimObj.WOD_2__Inventory__c,new WOD_2__Inventory__c (Id=claimObj.WOD_2__Inventory__c,WOD_2__Units_Usage__c = claimObj.WOD_2__Units_Usage__c ));
                }
                
                if(claimObj.WOD_2__Chatter_Comments__c!='' && claimObj.WOD_2__Chatter_Comments__c!=oldClaimMap.get(claimObj.id).WOD_2__Chatter_Comments__c)//UserInfo.getUserId()!=claimObj.CreatedById && 
                {
                    if(string.isBlank(oldClaimMap.get(claimObj.id).WOD_2__Chatter_Comments__c)){
                        userIdsSet.add(claimObj.CreatedById);
                        commentedClaimList.add(claimObj);
                    }
                    else if(claimObj.WOD_2__Chatter_Comments__c.length()>oldClaimMap.get(claimObj.id).WOD_2__Chatter_Comments__c.length()){
                        userIdsSet.add(claimObj.CreatedById);
                        commentedClaimList.add(claimObj);
                    }
                }
            }
            if(!skipFLIUpdate && !paidClaimIdList.isEmpty()){
                updatePreviousAmountsonFLI(paidClaimIdList,false);                
                skipFLIUpdate = true;
            }    
            skipFLIUpdate = false;
            if(!skipFLIUpdate && !paidRejectedClaimIdList.isEmpty()){
                updatePreviousAmountsonFLI(paidRejectedClaimIdList,true);                
                skipFLIUpdate = true;
            }
            
            if(!repairDateModifiedList.isEmpty()){
                recomputePartAndLabor(repairDateModifiedList);
            }   
            if(!appealedClaimIdSet.isEmpty()){
                updateApprovedValuesToNullOnAppeal(appealedClaimIdSet);
            }
            if(!rejectedCampaignClaimIdList.isEmpty()){
                ATI_Utils.checkForAccess('twodcms__Member_Template_Association__c','READ', new List<String>{'twodcms__Campaign_Members__c','twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.twodcms__Applicable_for_all__c'});
                List<twodcms__Member_Template_Association__c> mtaList = [select Id, twodcms__Campaign_Members__c, twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.twodcms__Applicable_for_all__c from twodcms__Member_Template_Association__c where twodcms__Claim__c in :rejectedCampaignClaimIdList];    
                Set<Id> cmIdSet = new Set<Id>();
                for(twodcms__Member_Template_Association__c mta : mtaList){
                    if(mta.twodcms__Campaign_Members__c != null && mta.twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.twodcms__Applicable_for_all__c){
                        cmIdSet.add(mta.twodcms__Campaign_Members__c);    
                    }
                }
                if(!cmIdSet.isEmpty()){
                    List<twodcms__Campaign_Members__c> cmSet = [select id from twodcms__Campaign_Members__c where id in :cmIdSet];
                    ATI_QueryRunWithoutSharing.deleteData(cmSet, true);
                }
                ATI_Utils.checkForAccess('twodcms__Member_Template_Association__c','UPDATE', new List<String>{'twodcms__Campaign_Members__c','twodcms__UniqueMemberTemplateAssociation__c'});
                mtaList = [select Id, twodcms__Campaign_Members__c,twodcms__Claim__r.Name, twodcms__UniqueMemberTemplateAssociation__c from twodcms__Member_Template_Association__c where twodcms__Claim__c in :rejectedCampaignClaimIdList];
                for(twodcms__Member_Template_Association__c mta : mtaList){
                    mta.twodcms__Campaign_Members__c = null;
                    //ALSN-78 appending -1 to unique value
                    //mta.twodcms__UniqueMemberTemplateAssociation__c = mta.twodcms__UniqueMemberTemplateAssociation__c + '-' + Datetime.now().getTime(); 
                    //ALSN-178 removed appended value and added claim name to make it unique
                    //ALSN-206 we are reverting the unique value back to 36 characters and then assigning the datetime
                    if(mta.twodcms__UniqueMemberTemplateAssociation__c.length() == 36){
                        mta.twodcms__UniqueMemberTemplateAssociation__c = mta.twodcms__UniqueMemberTemplateAssociation__c+ '-' + mta.twodcms__Claim__r.Name;
                    }else if(mta.twodcms__UniqueMemberTemplateAssociation__c.length() > 36){
                        String str = mta.twodcms__UniqueMemberTemplateAssociation__c.left(36);
                        mta.twodcms__UniqueMemberTemplateAssociation__c = str+ '-' + mta.twodcms__Claim__r.Name;
                    }
                }
                update mtaList;
            }            
            
            //Modified by Mukesh for Task#24515 on Dated 25 march 2021
            List<WOD_2__Claim__c> claimToUpdate = new List<WOD_2__Claim__c>();
            List<WOD_2__Claim__c> claimToUpdateStatus = new List<WOD_2__Claim__c>();
            system.debug('approvedOrRejectedClaimIdList---->'+approvedOrRejectedClaimIdList);
            if(!approvedOrRejectedClaimIdList.isEmpty()){
                system.debug('approvedOrRejectedClaimIdList---->'+approvedOrRejectedClaimIdList);
                for(id claimid : approvedOrRejectedClaimIdList){
                    if(newClaimMap.get(claimid).WOD_2__Claim_Status__c != 'Rejected' || (newClaimMap.get(claimid).WOD_2__Claim_Status__c == 'Rejected' 
                                                                                         && claimIdToPaidTMHMap.containsKey(claimid) 
                                                                                         && claimIdToPaidTMHMap.get(claimid).WOD_2__Transaction_Status__c=='Paid'))
                    {
                        claimToUpdate.add(new WOD_2__Claim__c(id =claimid, WOD_2__Claim_Status__c = 'Pending Payment'));
                        system.debug('claimToUpdate---->'+claimToUpdate);
                    }
                }
                //End of Modification by Mukesh for Task#24515 on Dated 25 march 2021
                creditdebitMemo(approvedOrRejectedClaimIdList);
                createReplacementHistory(approvedOrRejectedClaimIdList);
            }
            //Alsn-143
            if(!pendingApprovedClaimIdList.isEmpty()){
                system.debug('pendingApprovedClaimIdList---->'+pendingApprovedClaimIdList);
                for(id claimid : pendingApprovedClaimIdList){
                    claimToUpdate.add(new WOD_2__Claim__c(id =claimid,WOD_2__In_Approval_Process__c=false));
                    system.debug('claimToUpdate---->'+claimToUpdate);
                }
                WOD_2__Claim__c clm = [SELECT Id,createdById FROM WOD_2__Claim__c WHERE Id=:pendingApprovedClaimIdList[0]];
                if(claimToUpdate.size()>0){
                    System.debug('enterdddddddddddddd');
                    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                    for(WOD_2__Claim__c workItem : claimToUpdate){
                        if(workItem.WOD_2__In_Approval_Process__c == false){
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            //Alsn-158
                            req.setSubmitterId(clm.createdById);                           
                            req.setObjectId(workItem.Id);
                            requests.add(req);
                        }
                    } 
                    Approval.ProcessResult[] processResults = Approval.process(requests);   
                }
            }
            //end of Alsn-143
            //Modified by Mukesh for Task#24515 on Dated 25 march 2021
            if(!claimToUpdate.isEmpty()){
                if(!System.isBatch()){
                    ATI_QueueableUtil.enqueueJob(new ATI_updateClaimQuable(claimToUpdate));
                }else{
                    Map<Id,WOD_2__Removed_Claim_Part__c> rcpMap = new Map<Id,WOD_2__Removed_Claim_Part__c>([SELECT Id FROM WOD_2__Removed_Claim_Part__c WHERE WOD_2__Claim__c IN:claimToUpdate]);
                    if(!rcpMap.isEmpty()){
                        List<Id> rcpIdsLst = new List<Id>();
                        rcpIdsLst.addAll(rcpMap.keySet());
                        WOD_2.PRC_Service.fetchRemovedClaimPart(rcpIdsLst);
                    }
                    new ATI_updateClaimQuable(claimToUpdate).execute(null);
                }
            }
            if(!invMap.values().isEmpty()){
                TriggerHandler.bypass('ATI_InventoryTriggerHandler');
                update invMap.values();
                TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
            }
            
            if(!userIdsSet.isEmpty()){
                Map<Id,User> userMap = new Map<Id,User>();
                //ALSN-77 query without sharing
                List<id> idList = new List<id>();
                for(id u:userIdsSet){
                    idList.add(u);
                }
                String query = 'Select Id,Email from User where Id in: idList';
                userMap = new Map<Id,User>((List<User>)ATI_QueryRunWithoutSharing.runQueryWithIds(query,idList));
                //userMap = new Map<Id,User>([Select Id,Email From User where Id in :userIdsSet]);
                //ALSN-77 end
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                List<String> sendTo = new List<String>();
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.ATI_InternalUserEmail];
                User curUser = [SELECT Id,Profile.Name FROM User where Id=:UserInfo.getUserId()];
                for(WOD_2__Claim__c claimObj: [SELECT Id,Name,CreatedById,WOD_2__Chatter_Comments__c,WOD_2__Account__r.Name,WOD_2__Account__r.AccountNumber,WOD_2__Inventory__r.Name FROM WOD_2__Claim__c WHERE Id in :commentedClaimList]){
                    List<string> commentsList = new List<string>();
                    if(claimObj.WOD_2__Chatter_Comments__c.contains('},')){
                        commentsList = claimObj.WOD_2__Chatter_Comments__c.split('},');
                    }
                    else{
                        commentsList = new List<string>{claimObj.WOD_2__Chatter_Comments__c.substringBetween('[','}]')};
                            }
                    Map<String, Object> newComment = (Map<String, Object>)JSON.deserializeUntyped(commentsList[commentsList.size()-1]+'}');
                    if(newComment.get('ind')=='EC'){
                        mail =  new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        sendTo = new List<String>();
                        if(curUser.Profile.Name=='ATI Distributor and Dealer'){
                            sendTo.add(Label.ATI_InternalUserEmail);
                        }
                        else{
                            sendTo.add(userMap.get(claimObj.CreatedById).Email);
                        }
                        mail.setToAddresses(sendTo);
                        mail.setSubject('A new comment has been added to the claim number '+ claimObj.Name);
                        String body = 'Hello,<br/><br/>';
                        body+='Comment has been added to the claim '+claimObj.Name+'<br/><br/>';
                        body+='Claim Details :<br/><br/>';
                        body+='Claim Number : '+claimObj.Name+'<br/>';
                        body+='Comment : '+newComment.get('c')+'<br/>';
                        body+='Serial Number : '+claimObj.WOD_2__Inventory__r.Name+'<br/>';
                        body+='Account Name : '+claimObj.WOD_2__Account__r.Name+'<br/>';
                        body+='Account Number : '+claimObj.WOD_2__Account__r.AccountNumber;
                        mail.setHtmlBody(body);
                        mails.add(mail);
                    }
                }
                Messaging.sendEmail(mails);
            }
            
        }
        if(!skipTriggerRunForBatchClaims){
            recallClaimFromApprovalFlowWhenNeedMoreInfo(newClaimMap, oldClaimMap);
            //on owner change manual sharing was getting deleted, so running this to share claim to public group id again
            shareClaimsToPublicGroup(newClaimList,oldClaimMap);
        }
    }
    
    //ALSN-37 Added by Konda Susmitha.
    private static WOD_2.ResponseWrapper validateInstallManufactureDates(List<WOD_2__Claim__c> newClaimList){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('',true,'');
        try{
            List<WOD_2__Inventory__c> invtry = [select Id,WOD_2__Install_Date__c,WOD_2__Manufacturing_Date__c from WOD_2__Inventory__c where Id = :newClaimList[0].WOD_2__Inventory__c LIMIT 1];
            //Vijay changes - ALSN 62 - Start
            List<ATI_Inventory_Replacement_History__c> irh;
            if(invtry.size() > 0 && invtry[0].Id != null){
                irh = [SELECT id,ATI_Claim__c,ATI_Claim__r.ATI_In_Service_Date__c,ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c FROM ATI_Inventory_Replacement_History__c where ATI_Replaced_Inventory__c =:invtry[0].Id];
            }
            if(irh != null && invtry != null && !irh.isEmpty() && !invtry.isEmpty() && irh.size()>0 && invtry.size()>0 && irh[0].ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c != null && invtry[0].WOD_2__Install_Date__c != null && invtry[0].WOD_2__Install_Date__c < irh[0].ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c){
                throw new TWoDException(Label.ATI_WR_InstallDateGtManufacturingDate);
                
            }else if(irh != null &&  invtry!= null && irh.Size() == 0 && invtry[0].WOD_2__Manufacturing_Date__c != null && invtry[0].WOD_2__Install_Date__c < invtry[0].WOD_2__Manufacturing_Date__c){
                throw new TWoDException(Label.ATI_WR_InstallDateGtManufacturingDate);
            }
            //Vijay changes - ALSN 62 - End
        }
        catch(Exception e){
            response.status = false;
            response.errormessage = e.getMessage();
        }
        return response;
    }
    //ALSN-37 End
    
    private static void updatePreviousAmountsonFLI(List<Id> paidClaimIdList,Boolean rejectedClaims){
        List<String> fliFieldList = new List<String>{'WOD_2__Previously_Paid_Amount__c','WOD_2__Total_Approved_Amt__c',
            'ATI_Previously_Computed_Factory_Cost__c','ATI_Factory_Cost__c','ATI_Previously_Computed_Factory_Price__c',
            'ATI_Factory_Price__c','ATI_Previously_Paid_Landed_Part_Markup__c','ATI_Landed_Part_Markup__c','WOD_2__Percentage_Amount__c',
            'ATI_Previously_Paid_Markup__c','ATI_Markup__c','WOD_2__Claim__c','ATI_Previously_Paid_Amt__c','ATI_Previous_Percentage_Amount__c',
            'WOD_2__Total_Approved_Amount__c','WOD_2__Approved_Quantity__c','ATI_Previously_Approved_Quantity__c'};
                ATI_Utils.checkForAccess('WOD_2__Financial_Line_Item__c', 'UPDATE', fliFieldList);          
        String fliQuery = 'select Id, ' + String.join(fliFieldList, ', ') + ' from WOD_2__Financial_Line_Item__c where WOD_2__Claim__c in :paidClaimIdList';
        List<WOD_2__Financial_Line_Item__c> fliList = Database.query(fliQuery);
        for(WOD_2__Financial_Line_Item__c fliObj : fliList){
            fliObj.ATI_Previously_Computed_Factory_Cost__c = (rejectedClaims == false) ? fliObj.ATI_Factory_Cost__c : 0.0;
            fliObj.ATI_Previously_Computed_Factory_Price__c = (rejectedClaims == false) ? fliObj.ATI_Factory_Price__c : 0.0;
            fliObj.ATI_Previously_Paid_Landed_Part_Markup__c = (rejectedClaims == false) ? fliObj.ATI_Landed_Part_Markup__c : 0.0;
            fliObj.ATI_Previously_Paid_Markup__c = (rejectedClaims == false) ? fliObj.ATI_Markup__c : 0.0;
            fliObj.ATI_Previously_Paid_Amt__c = (rejectedClaims == false) ? fliObj.WOD_2__Total_Approved_Amt__c : 0.0;
            fliObj.ATI_Previously_Approved_Quantity__c = (rejectedClaims == false) ? fliObj.WOD_2__Approved_Quantity__c : 0.0;
            fliObj.ATI_Previous_Percentage_Amount__c = (rejectedClaims == false) ? fliObj.WOD_2__Percentage_Amount__c : 0.0;
        }
        TriggerHandler.bypass('ATI_FinancialLineItemTriggerHandler');
        ATI_QueryRunWithoutSharing.updateRecordsWithoutSharing(fliList, true);
        TriggerHandler.clearBypass('ATI_FinancialLineItemTriggerHandler');
    }
    
    private static void createReplacementHistory(List<Id> approvedOrRejectedClaimIdList){
        ATI_CLM_ReplacementService.handleReplacement(approvedOrRejectedClaimIdList);
    }
    
    private static void shareClaimsToPublicGroup(List<WOD_2__Claim__c> newClaimList,Map<Id, WOD_2__Claim__c> oldClaimMap){
        set<String> accGroupIds = new set<String>();
        set<Id> claimIds = new set<Id>();
        String strClaimIdsLst = '(';
        for(WOD_2__Claim__c claimObj : newClaimList){
            strClaimIdsLst = strClaimIdsLst+ '\''+claimObj.Id+'\',';
        }
        strClaimIdsLst = strClaimIdsLst.removeEnd(','); 
        strClaimIdsLst = strClaimIdsLst + ')';
        String strQuery = 'SELECT Id, WOD_2__Account__c, WOD_2__Account__r.WOD_2__Warranty_Account_Type__c,OwnerId'
            +' FROM WOD_2__Claim__c WHERE Id IN '+strClaimIdsLst+' AND WOD_2__Claim_Type__c IN (\'Machine\',\'Part\',\'Campaign\')';
        List<WOD_2__Claim__c> claimLst = ATI_QueryRunWithoutSharing.runQuery(strQuery);
        for (WOD_2__Claim__c claimRec: claimLst) {
            if(claimRec.OwnerId != oldClaimMap.get(claimRec.Id).OwnerId){
                claimIds.add(claimRec.Id);
                accGroupIds.add('ATI_Dealer_'+ claimRec.WOD_2__Account__c);
            }
        }
        if(!claimIds.isEmpty() && !accGroupIds.isEmpty() && !System.isBatch()){
            System.enqueueJob(new ATI_AddClaimShareRecords(accGroupIds,claimIds)); 
        }else if(!claimIds.isEmpty() && !accGroupIds.isEmpty() && System.isBatch()){
            new ATI_AddClaimShareRecords(accGroupIds,claimIds).execute(null); 
        }
    }
    
    /*public static void updateApprovedAmountForRejectAndNeedInfo(Map<Id,WOD_2__Claim__c> newClaimMap,Map<Id, WOD_2__Claim__c> oldClaimMap){
List<WOD_2__Financial_Line_Item__c> FLILstToUpdate = new List<WOD_2__Financial_Line_Item__c>();
for(WOD_2__Financial_Line_Item__c fliObj : [SELECT Id,WOD_2__Total_Approved_Amt__c,WOD_2__Claim__c,
WOD_2__Claim__r.WOD_2__Claim_Status__c
FROM WOD_2__Financial_Line_Item__c
WHERE WOD_2__Claim__c IN :newClaimMap.keySet()])
{
if((fliObj.WOD_2__Claim__r.WOD_2__Claim_Status__c == 'Additional Information Required' && oldClaimMap.get(fliObj.WOD_2__Claim__c).WOD_2__Claim_Status__c != 'Additional Information Required') 
|| (fliObj.WOD_2__Claim__r.WOD_2__Claim_Status__c == 'Rejected' && oldClaimMap.get(fliObj.WOD_2__Claim__c).WOD_2__Claim_Status__c != 'Rejected'))
{
fliObj.WOD_2__Total_Approved_Amt__c = 0;
fliObj.WOD_2__Approved_Amount__c = 0;
fliObj.ATI_Total_Approved_Amount_in_USD__c = 0;
FLILstToUpdate.add(fliObj);
}
}

if(!FLILstToUpdate.isEmpty()){
System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
update FLILstToUpdate;
}
}*/
    //Name : (setDefaultTurnaroundTime)
    //Created by : Manoj Paul for Turnaround time format issues
    //invocation point : before insert
    public static void setDefaultTurnaroundTime(){
        
    }
    
    public static void recallClaimFromApprovalFlowWhenNeedMoreInfo(Map<Id,WOD_2__Claim__c> newClaimMap, Map<Id,WOD_2__Claim__c> oldClaimMap){
        //Map<Id,WOD_2__Claim__c> newClaimMapString = (Map<Id,WOD_2__Claim__c>)JSON.deserialize(newClaimString, Map<Id,WOD_2__Claim__c>.class);
        for(WOD_2__Claim__c claimObj : newClaimMap.values()){
            /*if(claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Additional Information Required')){
ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :claimObj.Id
AND ProcessInstance.Status = 'Pending']; 
if(piWorkItems.size() > 0){
Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
pwiRequest.setAction('Removed');
pwiRequest.setWorkItemId(piWorkItems[0].Id);
Approval.ProcessResult result = Approval.process(pwiRequest);
}
}*/
            // To call Approval Process when the claim status is Reopened
            if(!oldClaimMap.get(claimObj.Id).WOD_2__Claim_Status__c.equalsIgnoreCase('Reopened') && claimObj.WOD_2__Claim_Status__c.equalsIgnoreCase('Reopened') && !Test.isRunningTest()){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(claimObj.Id);
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }
    
    // For Creating Credit and Debit memo on Approval and Rejection of Claim
    public static void  creditdebitMemo(List<Id> approvedOrRejectedClaimIdList){
        System.debug('in credit debit memo--->');
        WOD_2.CRD_CreditDebitService.callTMHService(approvedOrRejectedClaimIdList);
    }
    
    /*
Method Name :  sendEmailNotificationClaimApprovedRejected
Params      :  List<WOD_2__Claim__c> approvedOrRejectedClaimList
Description : Sending email for Auto approved/rejected claim
Date : 02/19/2021(DB)
*/
    /*  public static void sendEmailNotificationClaimApprovedRejected(List<WOD_2__Claim__c> approvedOrRejectedClaimList){
// try{
Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();       
for(WOD_2__Claim__c objClaim : approvedOrRejectedClaimList){
List<User> claimUserList = [Select Id,ContactId,Email From User Where Id =:objClaim.CreatedById];

//if(claimUserList.size()>0 && (claimUserList[0].ContactId!=NULL|| claimUserList[0].ContactId!='')){
List<Contact> contactList = [Select Id,Email From Contact Where Id =: claimUserList[0].ContactId];
// if(contactList.size()>0 &&(contactList[0].Email!=NULL || contactList[0].Email!='')){
message.setTargetObjectId(claimUserList[0].id); 
system.debug('setTargetObjectId'+ message.getTargetObjectId());
//message.setSenderDisplayName(); 
//message.setReplyTo(objClaim.CreatedById);
message.setUseSignature(false); 
message.setBccSender(false); 
message.setSaveAsActivity(false); 
EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'ATI_Dealer Notification'];
message.setTemplateID(emailTemplate.Id); 
message.setWhatId(objClaim.WOD_2__Account__c); //This is important for the merge fields in template to work
// message.toAddresses = new String[] {''};
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

if (results[0].success) 
{
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: ' +  results[0].errors[0].message);
}
// }
//}
//}
}

catch (Exception e) {
System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
}
}  */
    /*
Method Name :   claimAutoNumber
Description      :   Set Claim Auto Number
*/
    // Added by Dishari 3/18/2021 
    public void claimAutoNumber(){
        List<WOD_2__Claim__c> lstOfClaim = New List<WOD_2__Claim__c>();
        for(WOD_2__Claim__c nClaim : newClaimList){
            system.debug('newClaimList'+newClaimList);
            if(nClaim.ATI_Claim_Number__c != NULL && nClaim.WOD_2__Claim_Status__c == 'Draft'){
                WOD_2__Claim__c clm = new WOD_2__Claim__c();
                clm.id = nClaim.id;
                clm.Name = nClaim.ATI_Claim_Number__c;
                lstOfClaim.add(clm);
            }   
        }
        if(!lstOfClaim.isEmpty()){
            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
            update lstOfClaim;
            TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        }
    }
    /* Method Added by Mukesh for Part info update on claim
* 
*/
    /*
private void validateRCPandMarkClaim(){
//variables
List<Id> claimIdList = new List<Id>();
Map<Id, List<WOD_2__Removed_Claim_Part__c> > claimRCPMap = new Map<Id, List<WOD_2__Removed_Claim_Part__c> >();
Map<Id, WOD_2__Claim__c> oldMap = (Map<Id, WOD_2__Claim__c>)(trigger.oldMap);
//check if the record is approved.
for(WOD_2__Claim__c claim : (List<WOD_2__Claim__c>)trigger.new) {
System.debug('validateRCPandMarkClaim>>> '+oldMap.get(claim.Id).WOD_2__Claim_Status__c+' >>> '+claim.WOD_2__Claim_Status__c);
if(claim.WOD_2__Claim_Status__c == 'Approved' //&& oldMap.get(claim.Id).WOD_2__Claim_Status__c != 'Approved'
) {
claimIdList.add(claim.Id);
}
}
if(claimIdList.size() > 0) {
//build the claim Id vs the RCP map
//get all the RCP where the payment condition is in 'Pay After Return', 'Pay Without Return', 'Pay after Inspection'
for(WOD_2__Removed_Claim_Part__c rcp : [SELECT Id, Name, WOD_2__Payment_Condition__c,WOD_2__Claim__c,WOD_2__Is_Shipped__c,WOD_2__Is_Returned__c,WOD_2__Is_Inspected__c
FROM WOD_2__Removed_Claim_Part__c
WHERE WOD_2__Claim__c IN :claimIdList
AND WOD_2__Part_Return_Requested__c = true
AND WOD_2__Payment_Condition__c IN ('Pay After Return','Pay After Ship','Pay After Inspection')]) {
if(claimRCPMap.containsKey(rcp.WOD_2__Claim__c))
claimRCPMap.get(rcp.WOD_2__CLaim__c).add(rcp);
else
claimRCPMap.put(rcp.WOD_2__CLaim__c, new List<WOD_2__Removed_Claim_Part__c> {rcp});
}
for(WOD_2__Claim__c claim : (List<WOD_2__Claim__c>)trigger.new) {
if(claimRCPMap.containskey(claim.Id)) {
Integer totalRemovedPart = claimRCPMap.get(claim.Id).size();
Integer criteriaSatisfiedRecords = 0;
for(WOD_2__Removed_Claim_Part__c rcp : claimRCPMap.get(claim.Id)) {
//System.debug('pamentCondition>>>> '+rcp.WOD_2__Payment_Condition__c+ ' >>>> '+rcp.WOD_2__Is_Returned__c);
//Modified by Mukesh for Task#24515 on Dated 25 march 2021
if(rcp.WOD_2__Payment_Condition__c == 'Pay After Ship' && rcp.WOD_2__Is_Shipped__c) {
criteriaSatisfiedRecords++;
}
if(rcp.WOD_2__Payment_Condition__c == 'Pay After Return' && rcp.WOD_2__Is_Returned__c) {
criteriaSatisfiedRecords++;
}
if(rcp.WOD_2__Payment_Condition__c == 'Pay After Inspection' && rcp.WOD_2__Is_Inspected__c) {  
criteriaSatisfiedRecords++;
}
}
//System.debug('totalRemovedPart>>>> '+totalRemovedPart+ ' >>>> '+criteriaSatisfiedRecords);
if(totalRemovedPart == criteriaSatisfiedRecords)
claim.WOD_2__Claim_Parts_Pending_Approval__c =0;
else
claim.WOD_2__Claim_Parts_Pending_Approval__c =totalRemovedPart - criteriaSatisfiedRecords;
}else {
claim.WOD_2__Claim_Parts_Pending_Approval__c =0;
}
}
}
} */
    
    // We are copying the Labor and Parts Covered cost on to claim so that any future changes
    // to policy definition doesn;t impact and show wrong values of the computed costs
    // Added Reopen logic into this method
    private void setCoveragePercentage(Boolean isUpdate){
        List<Id> applicablePolicyIdList = new List<Id>();
        if(isUpdate){
            List<Id> idList = new List<Id>();
            for(Id claimId : newClaimMap.keySet()){
                WOD_2__Claim__c newClaim = newClaimMap.get(claimId);
                WOD_2__Claim__c oldClaim = oldClaimMap.get(claimId);
                if(newClaim.WOD_2__Applicable_Policy__c != null && newClaim.WOD_2__Applicable_Policy__c != oldClaim.WOD_2__Applicable_Policy__c){
                    applicablePolicyIdList.add(newClaim.WOD_2__Applicable_Policy__c);
                }
                if(newClaim.WOD_2__Claim_Status__c == 'Reopened' || newClaim.WOD_2__Claim_Status__c == 'Appeal'){
                    newClaim.ATI_Is_Claim_Appealed_Or_Reopened__c = true;
                    newClaim.ATI_is_Claim_Rejected__c = false;
                    // if the reopen is done before the status reaches paid, we need to delete the old most recent TMH, if it's already created. 
                    if(oldClaim.WOD_2__Claim_Status__c != 'Paid'){ 
                        idList.add(newCLaim.Id);
                    }
                }
            }
            if(!idList.isEmpty()){
                // expecting only one TMH status to be in pending if the claim is not paid yet. 
                // hence we need to delete only that TMH.
                String tmhQuery = 'select id from WOD_2__Transaction_Memo_History__c where WOD_2__Claim__c in :idList and WOD_2__Transaction_Status__c = \'Pending\' order by createddate desc';
                List<sObject> tmhList = ATI_QueryRunWithoutSharing.runQueryWithIds(tmhQuery, idList);
                if(!tmhList.isEmpty()){
                    ATI_QueryRunWithoutSharing.deleteData(tmhList, true);                                                   
                }
                resetPreviousAmounts(idList);
            }
        } else {
            for(WOD_2__Claim__c newClaim : newClaimList){
                newClaim.WOD_2__Is_Template__c = (newClaim.WOD_2__Claim_Type__c == 'Claim Template');
                if(newClaim.WOD_2__Applicable_Policy__c != null){
                    applicablePolicyIdList.add(newClaim.WOD_2__Applicable_Policy__c);
                }
            }
        }
        ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', new List<String>{'ATI_Part_Covered__c','ATI_Labor_Covered__c'});
        Map<Id, WOD_2__Policy_Definition__c> policyMap = new Map<Id, WOD_2__Policy_Definition__c>(
            [select Id, ATI_Part_Covered__c, ATI_Labor_Covered__c from WOD_2__Policy_Definition__c where id in :applicablePolicyIdList]);
        for(WOD_2__Claim__c newClaim : newClaimList){
            if(policyMap.containsKey(newClaim.WOD_2__Applicable_Policy__c)){
                newClaim.ATI_Part_Covered__c = policyMap.get(newClaim.WOD_2__Applicable_Policy__c).ATI_Part_Covered__c;
                newClaim.ATI_Labor_Covered__c = policyMap.get(newClaim.WOD_2__Applicable_Policy__c).ATI_Labor_Covered__c;
            }
        }
    }
    
    //update approved values to null when appeal is raised on claim
    private void updateApprovedValuesToNullOnAppeal(Set<Id> appealedClaimIdSet){
        //ALSN-171 added new fields to the query
        List<WOD_2__Financial_Line_Item__c> flisToUpdateLst = [SELECT Id,WOD_2__Cost_Category_Type__c,WOD_2__Total_Requested_Amount__c,WOD_2__Requested_Per_Unit_Amt__c,WOD_2__Requested_Quantity__c,ATI_Landed_Part_Markup__c,
                                                               WOD_2__Approved_Amount__c,WOD_2__Approved_Quantity__c,WOD_2__Total_Approved_Amt__c,ATI_Total_Approved_Amount_in_USD__c 
                                                               FROM WOD_2__Financial_Line_Item__c 
                                                               WHERE WOD_2__Claim__c IN :appealedClaimIdSet AND (WOD_2__Approved_Amount__c!=NULL OR WOD_2__Approved_Quantity__c!=NULL
                                                                                                                 OR WOD_2__Total_Approved_Amt__c!=NULL OR ATI_Total_Approved_Amount_in_USD__c!=NULL)];
        for(WOD_2__Financial_Line_Item__c fliObj : flisToUpdateLst){
            fliObj.WOD_2__Approved_Amount__c = NULL;
            fliObj.WOD_2__Approved_Quantity__c = NULL;
            fliObj.WOD_2__Total_Approved_Amt__c = NULL;
            fliObj.ATI_Total_Approved_Amount_in_USD__c = NULL;
            //ALSN-171 recalculate the markup and update on FLI.
            if(fliObj.WOD_2__Cost_Category_Type__c == 'OEM Parts'){
                fliObj.ATI_Markup__c = fliObj.WOD_2__Total_Requested_Amount__c - (fliObj.WOD_2__Requested_Per_Unit_Amt__c * fliObj.WOD_2__Requested_Quantity__c) - fliObj.ATI_Landed_Part_Markup__c;
            }
        }
        if(!flisToUpdateLst.isEmpty()){
            update flisToUpdateLst;
        }
    }
    
    private static void resetPreviousAmounts(List<Id> idList){
        List<String> fliFieldList = new List<String>{'WOD_2__Claim__c','ATI_Previously_Paid_Amt__c','WOD_2__Previously_Paid_Amount__c'};
            ATI_Utils.checkForAccess('WOD_2__Financial_Line_Item__c', 'UPDATE', fliFieldList);
        String query = 'select ID,' + String.join(fliFieldList, ', ') + ' from WOD_2__Financial_Line_Item__c where WOD_2__Claim__c in :idList';
        List<WOD_2__Financial_Line_Item__c> fliList = Database.query(query);
        // we will be reseting WOD_2__Previously_Paid_Amount__c which is used by product to ATI_Previously_Paid_Amt__c which will be populated
        // after receiving credit notification with 717 interface. 
        if(!fliList.isEmpty()){  
            for(WOD_2__Financial_Line_Item__c fli : fliList){
                fli.WOD_2__Previously_Paid_Amount__c = fli.ATI_Previously_Paid_Amt__c;
            }            
            TriggerHandler.bypass('ATI_FinancialLineItemTriggerHandler');
            Database.update(fliList, true);
            TriggerHandler.clearBypass('ATI_FinancialLineItemTriggerHandler');
        }
    }
    
    /*
Method Name :   updateCustomerOnInventory
Description :   Updating customer on inventory if custom is updated in claim creation page
*/
    private static void updateCustomerOnInventory(List<WOD_2__Claim__c> newClaimList,Set<Id> invIdsSet){
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Customer__c 
                                                                              FROM WOD_2__Inventory__c 
                                                                              WHERE Id IN :invIdsSet]);
        Map<Id,WOD_2__Inventory__c> invsToUpdateMap = new Map<Id,WOD_2__Inventory__c>();
        for(WOD_2__Claim__c claimObj : newClaimList){
            ATI_WarrantyService.WRDetailsWrapper wrWrapper = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimObj.ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
            //Alsn-81
            if(invMap.containsKey(claimObj.WOD_2__Inventory__c) && wrWrapper.WOD_2_Customer_c != NULL){
                if((invMap.get(claimObj.WOD_2__Inventory__c).WOD_2__Customer__c == NULL ))
                {
                    invsToUpdateMap.put(claimObj.WOD_2__Inventory__c,new WOD_2__Inventory__c(Id=claimObj.WOD_2__Inventory__c,WOD_2__Customer__c=wrWrapper.WOD_2_Customer_c));
                }
            }
            
            //end of Alsn-81
        }
        if(!invsToUpdateMap.values().isEmpty()){
            update invsToUpdateMap.values();
        }
    }
    
    private static void recomputePartAndLabor(List<Id> claimIdList){
        ATI_CLM_ClaimBaseOverrideHook overrideHook = new ATI_CLM_ClaimBaseOverrideHook();
        List<String> installedPartFieldsList = new List<String>{'WOD_2__Unit_Price__c','WOD_2__Warranty_Product__c',
            'WOD_2__Warranty_Product__r.WOD_2__Product_Name__c','WOD_2__Invoice_Number__c','WOD_2__Invoice_Quantity__c',
            'WOD_2__Serial_Number__c','WOD_2__Claim__c','WOD_2__Claim__r.WOD_2__Account__c','CurrencyISOCode'};
                Map<String,List<WOD_2__Claim_Part__c>> claimInstalledPartListMap = (Map<String,List<WOD_2__Claim_Part__c>>) getClaimSObjectMap(claimIdList, 'WOD_2__Claim_Part__c',installedPartFieldsList);
        if(!claimInstalledPartListMap.get('ALL').isEmpty()){
            for(String claimId : claimInstalledPartListMap.keySet()){
                List<WOD_2__Claim_Part__c> installedPartList = claimInstalledPartListMap.get(claimId);
                Map<String, WOD_2__Claim_Part__c> clmIdCPMap = new Map<String, WOD_2__Claim_Part__c>();
                for(WOD_2__Claim_Part__c cp : installedPartList){
                    clmIdCPMap.put(''+cp.WOD_2__Claim__c+cp.WOD_2__Warranty_Product__c, cp);
                }
                List<WOD_2.CLM_PartPriceWrapper> wrapperList = WOD_2.CLM_UnmanagedUtility.fetchPartsPrice(getPartPriceWrapper(installedPartList));
                for(WOD_2.CLM_PartPriceWrapper ppw : wrapperList){
                    if(!ppw.status){
                        throw new TWoDException(ppw.msg);
                    }
                    clmIdCPMap.get(ppw.claimId+ppw.partSalesforceId).WOD_2__Unit_Price__c = Decimal.valueOf(ppw.unitPrice);
                }            
            }
            WOD_2.ResponseWrapper partResponse = overrideHook.beforeInstalledPartSave(claimInstalledPartListMap.get('ALL'));
            if(!partResponse.status){
                throw new TWoDException(partResponse.errormessage);
            }
            List<WOD_2__Claim_Part__c> installedParts = (List<WOD_2__Claim_Part__c>)JSON.deserialize(partResponse.data, List<WOD_2__Claim_Part__c>.class);
            WOD_2.CLM_UnmanagedUtility.saveClaimOEMInstallParts(installedParts);
        }
        List<String> claimServiceInfoFieldsList = new List<String>{'WOD_2__Service_Job_Code__c','WOD_2__Labor_Rate__c','WOD_2__LaborRate__c','WOD_2__Standard_Labor_Hour__c','WOD_2__Total_Labor_Hours__c','WOD_2__Reason_Additional_Labor_Hour__c','WOD_2__Claim__c','WOD_2__Additional_Labor_Hour__c'};
            Map<String,List<WOD_2__Claim_Service_Information__c>> claimServiceInfoMap = (Map<String,List<WOD_2__Claim_Service_Information__c>>) getClaimSObjectMap(claimIdList, 'WOD_2__Claim_Service_Information__c',claimServiceInfoFieldsList);    
        if(!claimServiceInfoMap.get('ALL').isEmpty()){
            Map<String, Decimal> laborRates = getRatesForClaim(claimIdList, true, false, false);            
            for(WOD_2__Claim_Service_Information__c cs : claimServiceInfoMap.get('ALL')){
                cs.WOD_2__Labor_Rate__c = laborRates.get(cs.WOD_2__Claim__c);
                cs.WOD_2__LaborRate__c = laborRates.get(cs.WOD_2__Claim__c);
            }
            WOD_2.ResponseWrapper laborResponse = overrideHook.beforeClaimServiceInformationSave(claimServiceInfoMap.get('ALL'));
            if(!laborResponse.status){
                throw new TWoDException(laborResponse.errormessage);
            }
            List<WOD_2__Claim_Service_Information__c> csiList = (List<WOD_2__Claim_Service_Information__c>)JSON.deserialize(laborResponse.data, List<WOD_2__Claim_Service_Information__c>.class);
            WOD_2.CLM_UnmanagedUtility.saveClaimServiceInformations(csiList);
        }
        
    }
    
    private static Map<String,Decimal> getRatesForClaim(List<Id> claimIdList, Boolean fetchLaborRate, Boolean fetchTravelByDistanceRate, Boolean fetchTravelByHoursRate){
        List<WOD_2.CLM_RatesOverrideInputWrapper> cciwList = new List<WOD_2.CLM_RatesOverrideInputWrapper>();
        for(String claimId : claimIdList){
            WOD_2.CLM_RatesOverrideInputWrapper cciw = new WOD_2.CLM_RatesOverrideInputWrapper(claimId, fetchLaborRate, fetchTravelByDistanceRate, fetchTravelByHoursRate);
            cciwList.add(cciw);
        }
        List<WOD_2.CLM_RatesOverrideOutputWrapper> outputList = new ATI_CLM_RatesOverride().getRates(cciwList);
        Map<String,Decimal> returnMap = new Map<String,Decimal>();
        for(WOD_2.CLM_RatesOverrideOutputWrapper ow : outputList){
            if(!ow.status){
                throw new TWoDException(ow.message);
            }
            returnMap.put(ow.claimId, ow.laborRate);
        }
        return returnMap;
    }    
    
    
    private static List<WOD_2.CLM_PartPriceWrapper> getPartPriceWrapper(List<WOD_2__Claim_Part__c> claimedPartList ) {
        List<WOD_2.CLM_PartPriceWrapper> wrapperlist = new List<WOD_2.CLM_PartPriceWrapper>();
        for(WOD_2__Claim_Part__c cp : claimedPartList){
            WOD_2.CLM_PartPriceWrapper w = new WOD_2.CLM_PartPriceWrapper();
            w.accountId = cp.WOD_2__Claim__r.WOD_2__Account__c;
            w.claimId = cp.WOD_2__Claim__c;
            w.currencyCode = cp.CurrencyISOCode;
            w.invoiceNumber = cp.WOD_2__Invoice_Number__c;
            w.partNumber = cp.WOD_2__Warranty_Product__r.WOD_2__Product_Name__c;
            w.partSalesforceId = cp.WOD_2__Warranty_Product__c;
            w.quantity = cp.WOD_2__Invoice_Quantity__c +'';
            w.serialNumber = cp.WOD_2__Serial_Number__c;
            w.status = true;
            wrapperlist.add(w);
        }
        return wrapperList;
    }
    
    private void setClaimSubTypeDesc(){
        List<WOD_2__Claim__c> claimList = [select id, ATI_Claim_Subtype__c, ATI_Claim_Subtype_Desc__c from WOD_2__Claim__c where ID in :newClaimMap.keySet()];
        for(WOD_2__Claim__c newClaim : claimList){
            if(String.isNotBlank(newClaim.ATI_Claim_Subtype__c)){
                switch on newClaim.ATI_Claim_Subtype__c{
                    when '01' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Standard'; 
                    }
                    when '02' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Extended'; 
                    }
                    when '03','27','53','83' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Goodwill'; 
                    }
                    //ALSN-203
                    when '08' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'OEM Responsibility'; 
                    }
                    when '04','25' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Campaign'; 
                    }
                    when '05' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Part'; 
                    }
                    when '09' { 
                        newClaim.ATI_Claim_Subtype_Desc__c = 'Supplemental'; 
                    }
                }
            }
        }
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        ATI_QueryRunWithoutSharing.updateRecordsWithoutSharing(claimList, true);
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        
    }
    
    private static Map<String,List<SObject>> getClaimSObjectMap(List<Id> claimIdList, String objectName, List<String> fieldsList){
        ATI_Utils.checkForAccess(objectName, 'READ', fieldsList);
        String queryString = 'SELECT '+String.join(fieldsList,',')+' FROM '+ objectName + ' WHERE WOD_2__Claim__c IN :claimIdList';        
        System.debug('queryString -> ' + queryString);
        List<SObject> queryResult = Database.query(queryString);
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        resultMap.put('ALL', queryResult);
        for(SObject s : queryResult){
            String claimId = (String) s.get('WOD_2__Claim__c');
            if(!resultMap.containsKey(claimId)){
                resultMap.put(claimId, new List<SObject>());
            }
            resultMap.get(claimId).add(s);
        }
        return resultMap;
    }
}