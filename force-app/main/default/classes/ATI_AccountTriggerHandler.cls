/**
 -------------------------------------------------------------------------------------------------
This is Account Trigger handler class
* --------------------------------------------------------------------------------------------------
* @author         Punam Chakraborty
* @version        1.0
* @created        24-NOV-2020
* @modified
* @description :   Trigger Handler Class for Inventory Trigger
* --------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_AccountTriggerHandler extends TriggerHandler{
    //ALSN-212 flag created to skip queueable class call during datamovementbatch
    public static Boolean skipforDataMovementBatch = false;
	//ALSN-212 end
    
    private List<Account> newAccountList;
    private List<Account> oldAccountList;
    private Map<id,Account> oldAccountMap;
    private Map<id,Account> newAccountMap;
    
    /*
        Method Name :   ATI_AccountTriggerHandler
        Method Added By Punam
        Constructor Method ATI_AccountTriggerHandler
    */
    public ATI_AccountTriggerHandler() {
        this.newAccountList = (List<Account>)Trigger.new;
        this.oldAccountList = (List<Account>) Trigger.old;
        this.newAccountMap = (Map<Id,Account>)Trigger.newMap;
        this.oldAccountMap = (Map<Id,Account>)Trigger.oldMap;
    }
    
	
    public override void beforeInsert() {
        updateWarrantyAccountType();
		
    }
    
    public override void beforeUpdate() {
        updateWarrantyAccountType();
    }
    
    // Trigger Methods
    public override void afterInsert() {
        publicGroupsCreateDelete();
        if(!System.isBatch()){
            createAccountSharesForCustomers(JSON.serialize(newAccountList));
        }
    }
    
    public override void afterUpdate() {
        publicGroupsCreateDelete();
    }
    
    public override void beforeDelete() {
        publicGroupsCreateDelete();
    }
   
    /*  Method Name :   updateWarrantyAccountType
        Method Added By Yamini
    */
    private void updateWarrantyAccountType(){
		Boolean endUser = endUserProfileMatrix();
        for(Account acc : newAccountList){
            String customerGroup = acc.ATI_Customer_Group__c;
            if(acc.ATI_Customer_Group__c != null && (!endUser) ){
                if(customerGroup == '01' || customerGroup == '02' || customerGroup == '03' || customerGroup == '04' || customerGroup == '05' ||
                  customerGroup == '06' || customerGroup == '14' || customerGroup == '15'){
                    acc.WOD_2__Warranty_Account_Type__c = 'Dealer';
                }
                
            }else{
				if(acc.ATI_Customer_Group__c != null && (endUser)){
                if(customerGroup == 'EU99'){
                    acc.WOD_2__Warranty_Account_Type__c = 'Customer';
                }
                
			}
            }
            //ALSN-212 additional check of Warranty Account Type
            if(acc.ATI_Alternate_Parent__c == null && acc.WOD_2__Warranty_Account_Type__c == 'Dealer'){
                acc.ATI_Alternate_Parent__c = acc.ParentId;
            }
            //ALSN-212 end
        
    }
    }
    /*  Method Name :   endUserProfileMatrix
        Method Added By Manoj Paul
    */
    private static boolean endUserProfileMatrix(){
		String prof = [Select Name from Profile where Id =:UserInfo.getProfileId() LIMIT 1].Name;
        Boolean isActive = false;
		Map<String,Boolean> eumetadata = new Map<String,Boolean>();
		for(ATI_End_User_Account_Profile_Matrix__mdt eumdt :[Select MasterLabel,ATI_Active__c from ATI_End_User_Account_Profile_Matrix__mdt LIMIT 100 ]){
		  eumetadata.put(eumdt.MasterLabel,eumdt.ATI_Active__c);	
	      }
        if(eumetadata.containsKey(prof)){
            isActive = true;
          }
	   return isActive;  
    }
    /*  
        Method Name :   publicGroupsCreateDelete
        Method Added By Punam
        Create and Delete Public groups on creation of Accounts
    */
    @TestVisible
    private static void publicGroupsCreateDelete(){
         // After Insert / After UnDelete
        if(Trigger.isInsert || Trigger.isUndelete) {
            createPublicGroups(Trigger.new,false);
        }
        
        //  After Update
        //ALSN-212 additional check of skipforDataMovementBatch
        if(Trigger.isUpdate && !skipforDataMovementBatch) {
            //ALSN-212 end
            List<Account> accountList = new List<Account>();
            Map<id,Account> newAccountRecords = (Map<Id, Account>)Trigger.newMap;
            Map<id,Account> oldAccountRecords = (Map<Id, Account>)Trigger.oldMap;
     		for(Account accountNewObj : newAccountRecords.values()) {
                Account accountOldObj = oldAccountRecords.get(accountNewObj.id);
                // Child records only when the Parent Id is Changed
                if(accountNewObj.ATI_Alternate_Parent__c != null && accountOldObj.ATI_Alternate_Parent__c != accountNewObj.ATI_Alternate_Parent__c) {
                    accountList.add(accountNewObj);
                }
            }
            System.debug('Inside update -> ' + accountList);
            if(!accountList.isEmpty()) {
                createPublicGroups(accountList,true);
            }
        }
        
        // Before Delete
        if(Trigger.isDelete) {
            deletePublicGroups(JSON.serialize(Trigger.old));
        }
    }
    
    // Queueable Batch to process Public Groups & Account, Next Group Members and Account Sharing records.
    public static void createPublicGroups(List<Account> accountList,Boolean isUpdate){      
        if(!Test.isRunningTest()) {
            System.enqueueJob(new ATI_CreateDealerPublicGroupsQueueable(accountList,isUpdate));
        }
    }
    
    /*
        Method Name :   deletePublicGroups
        Delete Public groups for deleted Accounts
    */
    @future
    public static void deletePublicGroups(String accountListString){
        List<Account> accountList = (List<Account>)Json.deserialize(accountListString,List<Account>.class);
        List<Id> groupIdList = new List<Id>();
        for(Account accountObj : accountList) {
            System.debug('accountObj '+accountObj);
            if(accountObj.Public_Group_Id__c != null) {
                groupIdList.add(accountObj.Public_Group_Id__c);
            }
        }
        Database.DeleteResult[] deleteResultPublicGroupList = Database.delete(groupIdList, true);
    }
    
    /* 
     * Method Name :   createAccountSharesForCustomers
        Create AccountShare Records for Customers
    */
    @future
    public static void createAccountSharesForCustomers(String accountListString) {
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_DealerGroupNameForSharing');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null){
            Group customerGroup = [SELECT Id FROM Group WHERE Name=:logRecordValue.WOD_2__Configuration_Value__c];
            if(customerGroup != null){
                List<Account> accountList = (List<Account>)Json.deserialize(accountListString,List<Account>.class);
           		List<AccountShare> accountShareList = new List<AccountShare>();
				for(Account acc : accountList){
                    if(acc.WOD_2__Warranty_Account_Type__c == 'Customer'){
                        accountShareList.add(
                            new AccountShare(
                                AccountAccessLevel = 'Read',
                                AccountId = acc.Id,
                                OpportunityAccessLevel = 'None',
                                UserOrGroupId = customerGroup.id
                            )
                        );
                    }
                }
                if(!accountShareList.isEmpty()){
                    Database.SaveResult[] saveResultAccountShare = Database.insert(accountShareList, true);
                }
            }
        }
    } 
}