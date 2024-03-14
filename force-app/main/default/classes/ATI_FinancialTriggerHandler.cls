/* Name: ATI_FinancialTriggerHandler
   Description : Trigger Handler for ATI_FinancialTrigger
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    30/11/2020          INITIAL DEVELOPMENT
*/

public with sharing class ATI_FinancialTriggerHandler extends TriggerHandler {
	
    private List<WOD_2__Financial__c> newFinancialList;
	private List<WOD_2__Financial__c> oldFinancialList;
    private Map<Id, WOD_2__Financial__c> newFinancialMap;
	private Map<Id, WOD_2__Financial__c> oldFinancialMap;
	public static Boolean skipFinancialTriggerHandler = false;    
    /*
        Method Name :   ATI_FinancialTriggerHandler
        Params      :   Constructor
    */
    public ATI_FinancialTriggerHandler(){
        this.newFinancialList = (List<WOD_2__Financial__c>)Trigger.new;
        this.oldFinancialList= (List<WOD_2__Financial__c>)Trigger.old;
        this.newFinancialMap= (Map<Id, WOD_2__Financial__c>)Trigger.newMap;
        this.oldFinancialMap= (Map<Id, WOD_2__Financial__c>)Trigger.oldMap;
    }
    
    /*
        Method Name :   afterInsert
        Params      :   Financial afterInsert method
    */
    public override void afterInsert() {
        if(!skipFinancialTriggerHandler){
            updateTotalApprovedAndRequestedAmount();
        }
        addFinancialShareRecords();
    }
    
    /*
        Method Name :   afterUpdate
        Params      :   Update Claim Fields
    */
    public override void afterUpdate() {
        if(!skipFinancialTriggerHandler){
            updateTotalApprovedAndRequestedAmount();
        }
    }
    
    /*
        Method Name :   addFinancialShareRecords
        Params      :   Method to create financial sharing records with account's group
    */
    private void addFinancialShareRecords(){
        try{
            Map<String, String> groupNameIdMap = new Map<String, String>();
            List<WOD_2__Financial__Share> financialShareList = new List<WOD_2__Financial__Share>();
            set<String> accGroupIds = new set<String>();
            List<WOD_2__Financial__c> financialList = new List<WOD_2__Financial__c>();
            String claimObjName = 'WOD_2__Claim__c';
            List<String> claimFields = new List<String>{'WOD_2__Account__c'};
                ATI_Utils.NoAccessObjectFieldWrapper claimNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(claimObjName,claimFields);
            String accountSObjName = 'Account';
            List<String> accountFields = new List<String>{'WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper acountNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accountSObjName,accountFields);
            
            if (claimNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                financialList = [SELECT id, WOD_2__Claim__r.WOD_2__Account__c, WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c FROM WOD_2__Financial__c WHERE Id IN : newFinancialList];
            }
            
            for (WOD_2__Financial__c financialRec: financialList) {
                accGroupIds.add('ATI_' + financialRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c + '_' + financialRec.WOD_2__Claim__r.WOD_2__Account__c);
            }
            
            String groupObjName = 'Group';
            List<String> groupFields = new List<String>{'Name'};
                ATI_Utils.NoAccessObjectFieldWrapper groupNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(groupObjName,groupFields);
            
            if (groupNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && groupNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for (Group grp: [Select Id,Name From Group WHERE Name IN :accGroupIds LIMIT 50000]) {
                    groupNameIdMap.put(grp.Name,grp.Id);
                }
            }
            for (WOD_2__Financial__c financialRec :  financialList) {
                if (groupNameIdMap.containsKey('ATI_' + financialRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c + '_' + financialRec.WOD_2__Claim__r.WOD_2__Account__c)) {
                    WOD_2__Financial__Share financialShareInstance = new WOD_2__Financial__Share(UserOrGroupId = groupNameIdMap.get('ATI_' + financialRec.WOD_2__Claim__r.WOD_2__Account__r.WOD_2__Warranty_Account_Type__c + '_' + financialRec.WOD_2__Claim__r.WOD_2__Account__c),AccessLevel = 'Edit',ParentId = financialRec.Id);
                    financialShareList.add(financialShareInstance);
                }
            }
            if (!financialShareList.isEmpty()) {
                String claimShareObjName = 'WOD_2__Financial__Share';
                List<String> claimShareFields = new List<String>{'UserOrGroupId','AccessLevel','ParentId'};
                    ATI_Utils.NoAccessObjectFieldWrapper claimShareNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(claimShareObjName,claimShareFields);
                if (claimShareNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && claimShareNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                    Database.SaveResult[] financialShareInsertResult = Database.insert(financialShareList, false);
                }
            }
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
    }
    
    /*
        Method Name :   updateTotalApprovedAndRequestedAmount
        Params      :   Method to update fields in claim
    */
    private void updateTotalApprovedAndRequestedAmount(){
        List<Id> claimIds = new List<Id>();
        for(WOD_2__Financial__c financialRec :  newFinancialList) {
            if((financialRec.ATI_Total_Requested_Amount_In_USD__c != null || financialRec.ATI_Total_Approved_Amount_in_USD__c != null) && financialRec.WOD_2__Claim__c != null){
                claimIds.add(financialRec.WOD_2__Claim__c);
            }
        }
        Map<Id,WOD_2__Claim__c> claimsMap = new Map<Id,WOD_2__Claim__c>([SELECT Id,ATI_Total_Approved_Amount__c,ATI_Total_Requested_Amount__c FROM WOD_2__Claim__c WHERE Id IN:claimIds]);
        Boolean reqAmountIsZero = false;
        Map<Id,WOD_2__Claim__c> claimsToUpdate = new Map<Id,WOD_2__Claim__c>();
        for(WOD_2__Financial__c financialRec :  newFinancialList) {
            WOD_2__Claim__c claim = claimsMap.get(financialRec.WOD_2__Claim__c);
            if(Trigger.isInsert){
                if(financialRec.ATI_Total_Requested_Amount_In_USD__c != null){
                    claim.ATI_Total_Requested_Amount__c = financialRec.ATI_Total_Requested_Amount_In_USD__c;
                    claimsToUpdate.put(claim.Id,claim);
                }
                if(financialRec.ATI_Total_Approved_Amount_in_USD__c != null){
                    claim.ATI_Total_Approved_Amount__c = financialRec.ATI_Total_Approved_Amount_in_USD__c;
                    claimsToUpdate.put(claim.Id,claim);
                }
            }else if(Trigger.isUpdate){
                if(financialRec.ATI_Total_Requested_Amount_In_USD__c != null
                   && oldFinancialMap.get(financialRec.Id).ATI_Total_Requested_Amount_In_USD__c !=  financialRec.ATI_Total_Requested_Amount_In_USD__c)
                {
                    claim.ATI_Total_Requested_Amount__c = financialRec.ATI_Total_Requested_Amount_In_USD__c;
                    claimsToUpdate.put(claim.Id,claim);
                }
                if(financialRec.ATI_Total_Approved_Amount_in_USD__c != null
                   && oldFinancialMap.get(financialRec.Id).ATI_Total_Approved_Amount_in_USD__c !=  financialRec.ATI_Total_Approved_Amount_in_USD__c)
                {
                    claim.ATI_Total_Approved_Amount__c = financialRec.ATI_Total_Approved_Amount_in_USD__c;
                    claimsToUpdate.put(claim.Id,claim);
                }
            }
            
        }
        System.debug('claimsMap.values()--------->'+claimsMap.values());
        if(!claimsToUpdate.values().isEmpty()){
            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
            update claimsMap.values();
            TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        }
    }
}