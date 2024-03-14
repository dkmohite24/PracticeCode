/*
	Class Name	:	ATI_CancelClaimControllerTest
	Description	:	Test class for ATI_CancelClaimController
*/
@isTest
public with sharing class ATI_CancelClaimControllerTest {
/*
Method Name :   setupMethod
Description :   Method to create test data
*/
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        insert distributorAccount;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //Machine
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(200);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
        }
        insert warrantyProPartLst;
        
        //create warehouse
        List<WOD_2__Warehouse__c> whLst = TestDataFactory.createWarehouse(1);
        whLst[0].WOD_2__IsInactive__c = false;
        insert whLst;

        //create partreturnconfiguration
        List<WOD_2__Part_Return_Configuration__c> prcLst = TestDataFactory.createPartReturnConfiguration(1);
        for(WOD_2__Part_Return_Configuration__c prc : prcLst){
            prc.WOD_2__Return_Location__c = whLst[0].Id;
            prc.WOD_2__Days_Due_Within__c = 1;
        }
        insert prcLst;
               
        //create Inventory
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Retail'; 
            inventory.WOD_2__Serial_Number__c = 'Test001'; 
            inventory.WOD_2__Account__c = distributorAccount[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',WOD_2__Claim_Type__c ='Machine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c= casulaPart.get(0).id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        insert claim;
        twodcms__Member_Template_Association__c cmpgnLst = new twodcms__Member_Template_Association__c(Name='test123',twodcms__Claim__c=claim.Id);
        insert cmpgnLst;
        
        //create Removed ClaimPart
        List<WOD_2__Removed_Claim_Part__c> removedpartList = TestDataFactory.createRemovedClaimPart(1);
        Integer i = 0;
        for(WOD_2__Removed_Claim_Part__c removedpart : removedpartList) {
            removedpart.WOD_2__Claim__c = claim.Id;
            removedpart.WOD_2__Warranty_Product__c =  warrantyProPartLst[i].id;
            removedpart.WOD_2__Invoice_Quantity__c = 2;
            removedpart.WOD_2__Quantity_To_Be_Shipped__c = 1;
            removedpart.WOD_2__Part_Return_Quantity__c = 2;
            removedpart.WOD_2__Return_Location__c = null;
            i++;
        }
        //insert removedpartList;
        WOD_2__Shipment_Detail__c shpmt = new WOD_2__Shipment_Detail__c(Name='test123',WOD_2__Status__c = 'Draft',WOD_2__Claim__c=claim.Id);
        insert shpmt;
        
        //WOD_2__Claim_Shipment__c claimShipmentObj = new WOD_2__Claim_Shipment__c(WOD_2__Removed_Claim_Part__c=removedpartList[0].Id,WOD_2__Quantity__c = 1,
          //                                                                       WOD_2__Shipment_Detail__c=shpmt.Id);
        //insert claimShipmentObj;
        WOD_2__Transaction_Memo_History__c tmh = new WOD_2__Transaction_Memo_History__c(Name = claim.Name,WOD_2__Transaction_Status__c='Pending',WOD_2__Claim__c=claim.Id);
        insert tmh;
        Test.stopTest();
    }
/*
Method Name :   cancelDraftClaim
Description :   Method to test cancel claim for Draft status
*/
    @isTest
    public static void cancelDraftClaim(){       
        Test.startTest();
        WOD_2__Claim__c claim =[Select Id,WOD_2__Claim_Status__c from WOD_2__Claim__c];            
        claim.WOD_2__Claim_Status__c='Draft';
        update claim;              
        ATI_CancelClaimController.cancelClaim(claim.Id);
        Test.stopTest();
    }
    
/*
Method Name :   cancelAIRClaim
Description :   Method to test cancel claim for Appeal status

    @isTest
    public static void cancelAIRClaim(){
        Test.startTest();
        WOD_2__Claim__c claim =[Select Id,Name,WOD_2__Claim_Type__c,ATI_Total_Requested_Amount__c ,WOD_2__Claim_Status__c from WOD_2__Claim__c]; 
        claim.ATI_Total_Requested_Amount__c =100;
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        update claim;
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(claim.Id);       
        req.setProcessDefinitionNameOrId('ATI_Claim_Manual_Approval_Latest_V1');
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult processResults = Approval.process(req);
        System.debug('statusssss'+claim.WOD_2__Claim_Status__c);
        claim.WOD_2__Claim_Status__c='Additional Information Required';
        claim.WOD_2__Claim_Type__c ='Machine';
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        update claim;
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');       
        ATI_CancelClaimController.cancelClaim(claim.Id);
        Test.stopTest();
    }
*/

/*
Method Name :   cancelAppealClaimwithNoTMH
Description :   Method to test cancel campaign claim for Appeal status
*/
    @isTest
    public static void cancelAppealClaimwithNoTMH(){
        Test.startTest();
        WOD_2__Claim__c claim =[Select Id,createdById,WOD_2__Claim_Type__c,Name,WOD_2__Claim_Status__c from WOD_2__Claim__c];            
        claim.WOD_2__Claim_Status__c='Appeal';
        claim.WOD_2__Claim_Type__c ='Campaign';
        update claim;        
        ATI_CancelClaimController.cancelClaim(claim.Id);
        Test.stopTest();
    }
/*
Method Name :   cancelAppealClaimwithPaidTMH
Description :   Method to test cancel claim for Appeal status
*/
    @isTest
    public static void cancelAppealClaimwithPaidTMH(){
        Test.startTest();
        WOD_2__Claim__c claim =[Select Id,Name,WOD_2__Claim_Status__c from WOD_2__Claim__c];            
        claim.WOD_2__Claim_Status__c='Appeal';
        update claim;
        WOD_2__Transaction_Memo_History__c tmh = new WOD_2__Transaction_Memo_History__c(Name = claim.Name,WOD_2__Transaction_Status__c='Paid',WOD_2__Claim__c=claim.Id);
        insert tmh;
        WOD_2__Shipment_Detail__c shpmt = new WOD_2__Shipment_Detail__c(Name='test123',WOD_2__Status__c = 'Draft',WOD_2__Claim__c=claim.Id);
        insert shpmt;
        ATI_CancelClaimController.cancelClaim(claim.Id);
        Test.stopTest();
    }
/*
Method Name :   cancelClaimException
Description :   Method to test cancel claim for Paid status
*/
    @isTest
    public static void cancelClaimException(){
        Test.startTest();
        WOD_2__Claim__c claim =[Select Id,Name,WOD_2__Claim_Status__c from WOD_2__Claim__c];            
        claim.WOD_2__Claim_Status__c='Paid';
        update claim;
        ATI_CancelClaimController.cancelClaim(claim.Id);
        Test.stopTest();
    }
}