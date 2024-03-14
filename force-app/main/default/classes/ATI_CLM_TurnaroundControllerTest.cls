@isTest
public with sharing class ATI_CLM_TurnaroundControllerTest {
    @testSetup
    public static void testSetup(){
        List<Account> accLst = TestDataFactory.createAccount(2);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;  
            accLst[i].PRP_Participation__c = true;
        }
        accLst[0].WOD_2__Warranty_Account_Type__c='Dealer';
        accLst[1].WOD_2__Warranty_Account_Type__c='Customer';
        insert accLst;
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Stock';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        Id machineClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2);
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            //claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.RecordTypeId = machineClaimId;
        }
      //  claimLst[0].WOD_2__Account__c = accLst[0].id;
        claimLst[1].ATI_First_Labor_Applied_Date_Time__c = datetime.now()-2;
        claimLst[1].ATI_First_Part_Ordered_Date_Time__c = datetime.now()-2;
        claimLst[1].ATI_Last_Part_Arrival_Date_Time__c = datetime.now()-2;
        claimLst[1].ATI_Repair_Order_Closed_Date_Time__c = datetime.now()-2;
        claimLst[1].ATI_Vehicle_Arrival_Date_Time__c = datetime.now()-2;
        claimLst[1].ATI_Completed_Repair_Cust_Noti_Date__c = datetime.now()-2;
        claimLst[1].ATI_Distributor_schedules_cust_Serv_Date__c = datetime.now()-2;
        claimLst[1].ATI_Customer_Requests_Service_Date__c = datetime.now()-2;
        claimLst[1].RecordTypeId = machineClaimId;
        insert claimLst;
    }
    @isTest
    public static void TurnaroundTest(){
        List<WOD_2__Claim__c> claimList= [Select Id,WOD_2__Account__c,WOD_2__Causal_Part_Number__c,ATI_First_Labor_Applied_Date_Time__c,
                                          ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,
           ATI_Repair_Order_Closed_Date_Time__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,
           ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Customer_Requests_Service_Date__c from WOD_2__Claim__c];
       // ATI_Vehicle_Information__c vehicleInfoRec = new ATI_Vehicle_Information__c(Name=);
        String claimListJSON = JSON.serialize(claimList[0]);
        ATI_CLM_TurnaroundController.validateTurnAroundDate(claimListJSON);
        ATI_CLM_TurnaroundController.getClaimTurnaround(claimList[0].ID);
        ATI_CLM_TurnaroundController.getPrpAccountStatus(claimList[0].Id);
        String claimListJSONsecond = JSON.serialize(claimList[1]);
        ATI_CLM_TurnaroundController.validateTurnAroundDate(claimListJSONsecond);
    }
    
}