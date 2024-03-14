/* Name: ATI_CLM_ClaimBaseOverrideHookTest
Description : ATI_CLM_ClaimBaseOverrideHookTest - Test Class for ATI_CLM_ClaimBaseOverrideHook
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      9-Mar-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_CLM_ClaimBaseOverrideHookTest {

    @testSetup
    static void testSetup(){
        
        List<WOD_2__Business_Category_Configuration__c> bccs = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccs;
        
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer'; 
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bccs[0]);
        insert bccsList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(4);
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        warrantyProductList[3].WOD_2__Type__c = 'Item';
        warrantyProductList[3].WOD_2__Item_Type__c = 'Part';
        warrantyProductList[3].WOD_2__Track_Type__c = 'Non-Serialized';
              insert warrantyProductList;

                             //Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,warrantyProductList[3].Id);
        wpPbLst[0].RecordTypeId = partCostRTId;
        wpPbLst[0].WOD_2__Price__c = 100;
        insert wpPbLst;
                                     
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(2);
        inventoryList[0].Name = inventoryList[0].WOD_2__Serial_Number__c = 'FailedInvSerialNumber';
        inventoryList[0].WOD_2__Install_Date__c = System.today();
        inventoryList[0].WOD_2__Warranty_Start_Date__c = System.today();
        inventoryList[1].Name = inventoryList[1].WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber';
        inventoryList[0].WOD_2__Type__c = 'Retail';
        inventoryList[1].WOD_2__Type__c = 'Retail';
        for(WOD_2__Inventory__c inv : inventoryList){
            inv.WOD_2__Business_Unit__c = busCategoryList[0].Id;
            inv.WOD_2__Account__c = accList[0].Id;
            inv.WOD_2__Item__c = warrantyProductList[2].Id;
        }
        insert inventoryList;
        
        //Create MajorComponent
        List<WOD_2__Major_Component__c> majorCmpLst = TestDataFactory.createMajorComp(1);
        majorCmpLst.get(0).WOD_2__Serial_number__c = 'BK5536N19260014E';
        majorCmpLst.get(0).ATI_Type__c = 'ECU';
        majorCmpLst.get(0).WOD_2__Warranty_Product__c = warrantyProductList.get(3).id;
       // majorCmpLst.get(0).WOD_2__Inventory__c = inventoryList[0].id;
        insert majorCmpLst;
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        //viList[0].ATI_Inventory__c = inventoryList[0].Id;
        insert viList;
                
        /** Created as part of VIN Transmission Mapper*/
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryList[0].Id;
        insert vinMapperLst;
        
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = inventoryList[0].id;
        lstWR[0].WOD_2__Account__c = accList[0].Id;
        lstWR[0].WOD_2__Customer__c = accList[1].Id;
        insert lstWR;
        
        List<WOD_2__Policy_Definition__c> lstPol = TestDataFactory.createPolicyDef(1);
        lstPol[0].WOD_2__Payment_Definition__c = 'a153h0000084vWlAAI';
        lstPol[0].WOD_2__Active_From__c = Date.today();
        lstPol[0].WOD_2__Active_Until__c = Date.today();
        insert lstPol;
        
        List<WOD_2__Warranty_Coverages__c> lstWC = TestDataFactory.createWarrantyCoverage(1);
        lstWC[0].WOD_2__Warranty_Registration__c = lstWR[0].Id;
        lstWC[0].WOD_2__Policy_Definition__c = lstPol[0].Id;
        insert lstWC;
        
        ATI_WarrantyService.WRDetailsWrapper wrWrapper = new ATI_WarrantyService.WRDetailsWrapper();
        wrWrapper.ATI_Vocation_Code_c = lstWR[0].ATI_Vocation_Code__c;
        wrWrapper.WOD_2_Units_Usage_c = 200;
        wrWrapper.WOD_2_Customer_c = null;
        wrWrapper.vehicleInfo = viList[0];
        
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,bccs[0].id);
        serviceCampaignLst[0].Name = 'SC001';
        serviceCampaignLst[0].ATI_Months_Covered__c = 2;
        insert serviceCampaignLst;
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='MachineClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today(),
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id,WOD_2__Work_Performed_Comments__c='Test',
                                                  ATI_Technician_Name__c='Test',ATI_Tracking_Number__c='1000');
        claim.WOD_2__BusinessCategory__c = bccs[0].Id;
        claim.ATI_WR_Details__c = JSON.serialize(wrWrapper);
        insert claim;
        
        List<ATI_Exchange_Rate__c> exchangeRates = TestDataFactory.createExchangeRate(1);
        insert exchangeRates;
        
        
        List<WOD_2__Warranty_Code__c> failureCodes = TestDataFactory.createWarrantyCode(1, 'Failure Codes');
        insert failureCodes;

        List<WOD_2__Warranty_Code__c> jobCodes = TestDataFactory.createWarrantyCode(3, 'Labor Operations Codes');
        insert jobCodes;
                             
        /*List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Claim__c = claim.Id;
        installedClaimParts[0].WOD_2__Warranty_Product__c = warrantyProductList[3].Id;
        insert installedClaimParts;*/
            

    }

    @isTest
    static void testBeforeSaveClaimOtherCostObject(){
        WOD_2__Claim__c claim = [select id, CurrencyIsoCode from WOD_2__Claim__c];
        List<WOD_2__Other_Cost__c> otherCosts = TestDataFactory.createOtherCostCategoryItems(3);
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        update claim;
        for(Integer i = 0 ; i < otherCosts.size(); i++){
            otherCosts[i].WOD_2__Claim__c = claim.Id;
                                           otherCosts[i].WOD_2__Comments__c = 'Test';
        }
        otherCosts[0].WOD_2__Cost_Category_Type__c = 'Overtime';
        insert otherCosts[0];
        ATI_CLM_ClaimBaseOverrideHook hookClass = new ATI_CLM_ClaimBaseOverrideHook();
        Test.startTest();
        System.assertEquals(true, hookClass.beforeSaveClaimOtherCostObject(otherCosts).status, 'Status is set to false which is not expected!!!');        
        otherCosts[0].WOD_2__UnitsUsage__c = null;
        System.assertEquals(false, hookClass.beforeSaveClaimOtherCostObject(otherCosts).status, 'Status is set to true which is not expected!!!');        
        otherCosts[0].WOD_2__UnitsUsage__c = 45;
        otherCosts[0].WOD_2__Comments__c = '';
        System.assertEquals(false, hookClass.beforeSaveClaimOtherCostObject(otherCosts).status, 'Status is set to true which is not expected!!!');
        otherCosts[0].WOD_2__Rate_Per_Unit__c = null;
        otherCosts[0].WOD_2__Rate_PerUnit__c = null;
        System.assertEquals(false, hookClass.beforeSaveClaimOtherCostObject(otherCosts).status, 'Status is set to true which is not expected!!!');        
       Test.stopTest();
    }
    

    @isTest
    static void testExcludedJobCodes(){
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(3);
                             Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Labor Operations Codes').getRecordTypeId();
        List<WOD_2__Warranty_Code__c> jobCodes = [select id from WOD_2__Warranty_Code__c where RecordTypeId = :rtVCId];
        WOD_2__Claim__c claim = [select id, CurrencyIsoCode from WOD_2__Claim__c];
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        update claim;
        for(integer i = 0 ; i  < jobCodes.size(); i++){
            WOD_2__Claim_Service_Information__c csi = claimServices[i];
            csi.WOD_2__Service_Job_Code__c = jobCodes[i].Id;
            csi.WOD_2__Claim__c = claim.Id;
        }
        List<WOD_2__Claim_Service_Information__c> clmServices = TestDataFactory.createClaimServices(2);
                             clmServices[0].WOD_2__Service_Job_Code__c = jobCodes[1].Id;
        clmServices[0].WOD_2__Claim__c = claim.Id;
        clmServices[0].WOD_2__Total_Labor_Minutes__c = 20;
                             clmServices[1].WOD_2__Service_Job_Code__c = jobCodes[2].Id;
        clmServices[1].WOD_2__Claim__c = claim.Id;
        clmServices[1].WOD_2__Total_Labor_Minutes__c = 20;
        insert clmServices;
        ATI_CLM_ClaimBaseOverrideHook hookClass = new ATI_CLM_ClaimBaseOverrideHook();
        Test.startTest();
        Excluded_Labor_Operations_Code__c eloc = 
            new Excluded_Labor_Operations_Code__c(ATI_Labor_Operations_Code__c=jobCodes[1].Id,
                                                  Excluded_Code__c=jobCodes[2].Id);
        insert eloc;
        claimServices[0].WOD_2__Reason_Additional_Labor_Hour__c = 'Reason for extra labor';
        claimServices[0].WOD_2__Total_Labor_Hours__c = 10;
        claimServices[0].WOD_2__Standard_Labor_Hour__c = 10;
              System.assertEquals(false,hookClass.beforeClaimServiceInformationSave(claimServices).status,'Expected error not thrown');        
        Test.stopTest();
        
    }
    @isTest
    static void beforeClaimServiceInformationSave(){
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(3);
                             Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Labor Operations Codes').getRecordTypeId();
        List<WOD_2__Warranty_Code__c> jobCodes = [select id from WOD_2__Warranty_Code__c where RecordTypeId = :rtVCId];
        WOD_2__Claim__c claim = [select id, CurrencyIsoCode from WOD_2__Claim__c];
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        update claim;
        for(integer i = 0 ; i  < jobCodes.size(); i++){
            WOD_2__Claim_Service_Information__c csi = claimServices[i];
            csi.WOD_2__Service_Job_Code__c = jobCodes[i].Id;
            csi.WOD_2__Claim__c = claim.Id;
        }
        ATI_CLM_ClaimBaseOverrideHook hookClass = new ATI_CLM_ClaimBaseOverrideHook();
        Test.startTest();
        claimServices[0].WOD_2__Total_Labor_Hours__c = 0;
        hookClass.beforeClaimServiceInformationSave(claimServices);        
        claimServices[0].WOD_2__Total_Labor_Hours__c = 35;
        List<WOD_2__Claim_Service_Information__c> clmServices = TestDataFactory.createClaimServices(1);
                             clmServices[0].WOD_2__Service_Job_Code__c = claimServices[0].WOD_2__Service_Job_Code__c;
        clmServices[0].WOD_2__Total_Labor_Minutes__c=20;
        clmServices[0].WOD_2__Claim__c = claim.Id;
        insert clmServices;
        System.assertEquals(false,hookClass.beforeClaimServiceInformationSave(claimServices).status,'Expected error not thrown');
        jobCodes[0].ATI_Time_Studied__c = true;
        update jobCodes[0];
        System.assertEquals(false,hookClass.beforeClaimServiceInformationSave(claimServices).status,'Expected error not thrown');
        Test.stopTest();
        
    }
  

    @isTest
    static void beforeClaimSave(){
        WOD_2__Inventory__c invObj = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c='ReplacedInvSerialNumber'];
        WOD_2__Claim__c claim = [select id,WOD_2__Account__c,ATI_Tracking_Number__c,WOD_2__Inventory__c, WOD_2__Claim_Type__c,ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c,
                                                                                      ATI_First_Labor_Applied_Date_Time__c, ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,ATI_WR_Details__c,
                                 ATI_Repair_Order_Closed_Date_Time__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c,WOD_2__Units_Usage__c,
                                 ATI_Distributor_schedules_cust_Serv_Date__c, ATI_Customer_Requests_Service_Date__c,CurrencyIsoCode,WOD_2__Causal_Part_Number__c,
                                 ATI_Last_Labor_Recorded_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Work_Performed_Comments__c,WOD_2__Work_Order__c,ATI_Technician_Name__c,
                                 ATI_Failure_Code__c, WOD_2__Fault_Code__c, WOD_2__BusinessCategory__c, WOD_2__Pre_Authorization_Reason__c from WOD_2__Claim__c];
        claim.ATI_Replacement_Claims__c = true;
        claim.ATI_Replacement_Type__c = 'SWING';
        claim.ATI_Replaced_Inventory__c = invObj.Id;
        claim.ATI_Tracking_Number__c = 'newTrackingNumber';
        claim.WOD_2__Units_Usage__c = 100;
        User portalAccountOwner = createPortalAccountOwner();  
        User communityUser = createCommunityUser(portalAccountOwner);          
        Test.startTest();
        System.runAs(communityUser){
            claim.ATI_First_Labor_Applied_Date_Time__c = DateTime.now();
            claim.ATI_First_Part_Ordered_Date_Time__c = DateTime.now();
            claim.ATI_Last_Part_Arrival_Date_Time__c = DateTime.now();
            claim.ATI_Repair_Order_Closed_Date_Time__c = DateTime.now();
            claim.ATI_Vehicle_Arrival_Date_Time__c = DateTime.now();
            claim.ATI_Completed_Repair_Cust_Noti_Date__c = DateTime.now();
            claim.ATI_Distributor_schedules_cust_Serv_Date__c = DateTime.now();
            claim.ATI_Customer_Requests_Service_Date__c = DateTime.now();
            //claim.ATI_Customer_AuthorizeWork_Date_Time__c = DateTime.now();
            //claim.ATI_Repair_Order_Open_Time__c = Time.newInstance(1, 0, 0, 0);
            //claim.ATI_Last_Labor_Recorded_Time__c = Time.newInstance(1, 0, 0, 0);
            Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Failure Codes').getRecordTypeId();
              claim.ATI_Failure_Code__c = [select Id from WOD_2__Warranty_Code__c  where RecordTypeId = :rtVCId].Id;
            WOD_2.ResponseWrapper res = new ATI_CLM_ClaimBaseOverrideHook().beforeClaimSave(claim);
            System.assertEquals(false,res.status,'Expected false as error thrown'); //Pun
        }
        Test.stopTest();
    }
    
     @isTest
    static void beforeClaimSave2(){
        WOD_2__Inventory__c invObj = [SELECT Id FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c='ReplacedInvSerialNumber'];
        WOD_2__Claim__c claim = [select id,WOD_2__Account__c,ATI_Tracking_Number__c,WOD_2__Inventory__c, WOD_2__Claim_Type__c,ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c,
                                                                                      ATI_First_Labor_Applied_Date_Time__c, ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,ATI_WR_Details__c,
                                 ATI_Repair_Order_Closed_Date_Time__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c,WOD_2__Units_Usage__c,
                                 ATI_Distributor_schedules_cust_Serv_Date__c, ATI_Customer_Requests_Service_Date__c,CurrencyIsoCode,WOD_2__Causal_Part_Number__c,
                                 ATI_Last_Labor_Recorded_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Work_Performed_Comments__c,WOD_2__Work_Order__c,ATI_Technician_Name__c,
                                 ATI_Failure_Code__c, WOD_2__Fault_Code__c, WOD_2__BusinessCategory__c, WOD_2__Pre_Authorization_Reason__c from WOD_2__Claim__c];
        WOD_2__Inventory__c inv = [SELECT Id, WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id =: claim.WOD_2__Inventory__c];
        inv.WOD_2__Type__c = 'Retail';
        update inv;
        List<Account> accountList = [Select id,name,Sales_RegionA__c,SAP_ID__c,Location_Type__c,WOD_2__Warranty_Account_Type__c,Type from Account];
        for(Integer i=0;i<accountList.size();i++){
            accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'Type'+i;
            accountList[i].WOD_2__Warranty_Account_Type__c='Dealer';
            accountList[i].Type='Service Dealer';
        }
        accountList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        update accountList;
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=inv.Id;
            wrRec.WOD_2__Account__c = accountList[0].Id;
            wrRec.WOD_2__Customer__c = accountList[1].Id;
            wrRec.WOD_2__Status__c='Registered';
        }
        insert wrList;
        claim.ATI_Replacement_Claims__c = true;
        claim.ATI_Replacement_Type__c = 'SWING';
        claim.ATI_Replaced_Inventory__c = invObj.Id;
        claim.ATI_Tracking_Number__c = 'newTrackingNumber';
        claim.WOD_2__Units_Usage__c = 100;
        //User portalAccountOwner = createPortalAccountOwner();  
        //User communityUser = createCommunityUser(portalAccountOwner);          
        Test.startTest();
        //System.runAs(communityUser){
            claim.ATI_First_Labor_Applied_Date_Time__c = DateTime.now();
            claim.ATI_First_Part_Ordered_Date_Time__c = DateTime.now();
            claim.ATI_Last_Part_Arrival_Date_Time__c = DateTime.now();
            claim.ATI_Repair_Order_Closed_Date_Time__c = DateTime.now();
            claim.ATI_Vehicle_Arrival_Date_Time__c = DateTime.now();
            claim.ATI_Completed_Repair_Cust_Noti_Date__c = DateTime.now();
            claim.ATI_Distributor_schedules_cust_Serv_Date__c = DateTime.now();
            claim.ATI_Customer_Requests_Service_Date__c = DateTime.now();
            //claim.ATI_Customer_AuthorizeWork_Date_Time__c = DateTime.now();
            //claim.ATI_Repair_Order_Open_Time__c = Time.newInstance(1, 0, 0, 0);
            //claim.ATI_Last_Labor_Recorded_Time__c = Time.newInstance(1, 0, 0, 0);
            Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Failure Codes').getRecordTypeId();
              claim.ATI_Failure_Code__c = [select Id from WOD_2__Warranty_Code__c  where RecordTypeId = :rtVCId].Id;
            WOD_2.ResponseWrapper res = new ATI_CLM_ClaimBaseOverrideHook().beforeClaimSave(claim);
            //System.assertEquals(true,res.status,'Expected true but error not thrown'); //Pun
        //}
        Test.stopTest();
    }
    
    
    @isTest
    static void testValidateTurnaroundDates(){
        WOD_2__Inventory__c invObj = [SELECT Id FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c='ReplacedInvSerialNumber'];
        WOD_2__Claim__c claim = [select id, WOD_2__Inventory__c, WOD_2__Claim_Type__c,ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c,
                                                                                      ATI_First_Labor_Applied_Date_Time__c, ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,
                                 ATI_Repair_Order_Closed_Date_Time__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c,
                                 ATI_Distributor_schedules_cust_Serv_Date__c, ATI_Customer_Requests_Service_Date__c,CurrencyIsoCode,WOD_2__Causal_Part_Number__c,
                                 ATI_Last_Labor_Recorded_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Work_Performed_Comments__c,WOD_2__Work_Order__c,ATI_Technician_Name__c,
                                 ATI_Failure_Code__c, WOD_2__Fault_Code__c, WOD_2__BusinessCategory__c, WOD_2__Pre_Authorization_Reason__c from WOD_2__Claim__c];
        claim.ATI_Replacement_Claims__c = true;
        claim.ATI_Replacement_Type__c = 'SWING';
        claim.ATI_Replaced_Inventory__c = invObj.Id;
        User portalAccountOwner = createPortalAccountOwner();  
        User communityUser = createCommunityUser(portalAccountOwner);          
        ATI_CLM_ClaimBaseOverrideHook hookClass = new ATI_CLM_ClaimBaseOverrideHook();
        Test.startTest();
        System.runAs(communityUser){
            System.assertEquals(false,hookClass.beforeClaimSave(claim).status,'Expected error not thrown');        
            claim.ATI_Repair_Order_Closed_Date_Time__c = DateTime.now();
            claim.ATI_First_Part_Ordered_Date_Time__c = DateTime.now().addDays(1);
            System.assertEquals(false,hookClass.beforeClaimSave(claim).status,'Expected error not thrown');        
        }
        Test.stopTest();
    }

    
    @isTest
    static void testValidateReplacementClaim(){
        WOD_2__Claim__c claim = [select id, WOD_2__Inventory__c, WOD_2__Claim_Type__c,ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c,
                                                                                      ATI_First_Labor_Applied_Date_Time__c, ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,CurrencyIsoCode,
                                 ATI_Repair_Order_Closed_Date_Time__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c,WOD_2__Causal_Part_Number__c,
                                 ATI_Distributor_schedules_cust_Serv_Date__c, ATI_Customer_Requests_Service_Date__c,WOD_2__Work_Performed_Comments__c,WOD_2__Work_Order__c,ATI_Technician_Name__c,
                                 ATI_Failure_Code__c, WOD_2__Fault_Code__c, WOD_2__BusinessCategory__c, WOD_2__Pre_Authorization_Reason__c from WOD_2__Claim__c];
        claim.ATI_Replacement_Claims__c = true;
        User portalAccountOwner = createPortalAccountOwner();  
        User communityUser = createCommunityUser(portalAccountOwner);          
        Test.startTest();
        System.runAs(communityUser){
                                           System.assertEquals(false,new ATI_CLM_ClaimBaseOverrideHook().beforeClaimSave(claim).status,'Expected error not thrown');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeInstalledPartSave(){
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Warranty_Product__c = [select id from WOD_2__Warranty_Product__c where WOD_2__Item_Type__c = 'Part'].Id;
        installedClaimParts[0].WOD_2__Claim__c = [select id from WOD_2__Claim__c].Id;
        installedClaimParts[0].WOD_2__Serial_Number__c ='BK5536N19260014E';
        List<WOD_2__Major_Component__c> majorCmpLst1 = [Select Id from WOD_2__Major_Component__c];
        Test.startTest();
        System.assertEquals(true,new ATI_CLM_ClaimBaseOverrideHook().beforeInstalledPartSave(installedClaimParts).status,'Expected Success, but error not thrown');//Pun
        Test.stopTest();
    }

    @isTest
    static void testBeforeInstalledPartSaveWithCurConversion(){
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Warranty_Product__c = [select id from WOD_2__Warranty_Product__c where WOD_2__Item_Type__c = 'Part'].Id;
        WOD_2__Claim__c claim = [select id, CurrencyISOCode from WOD_2__Claim__c];
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        update claim;
        List<ATI_Exchange_Rate__c> exchangeRates = [select id, FromCurrency__c from ATI_Exchange_Rate__c];
        exchangeRates[0].FromCurrency__c = currencyCode;
        update exchangeRates;
        installedClaimParts[0].WOD_2__Claim__c = claim.Id;
        Test.startTest();
        System.assertEquals(false,new ATI_CLM_ClaimBaseOverrideHook().beforeInstalledPartSave(installedClaimParts).status,'Expected Success, but error not thrown');//Pun
        Test.stopTest();
    }


    @isTest
    static void testBeforeInstalledPartSaveWithInvalidConversion(){
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Warranty_Product__c = [select id from WOD_2__Warranty_Product__c where WOD_2__Item_Type__c = 'Part'].Id;
        WOD_2__Claim__c claim = [select id, CurrencyISOCode from WOD_2__Claim__c];
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        update claim;
        List<ATI_Exchange_Rate__c> exchangeRates = [select id, FromCurrency__c from ATI_Exchange_Rate__c];
        exchangeRates[0].FromCurrency__c = 'INR';
        update exchangeRates;
        installedClaimParts[0].WOD_2__Claim__c = claim.Id;
        Test.startTest();
        System.assertEquals(false,new ATI_CLM_ClaimBaseOverrideHook().beforeInstalledPartSave(installedClaimParts).status,'Expected error not thrown');
        Test.stopTest();
    }

    @isTest
    static void testBeforeInstalledPartSaveForInvalidPart(){
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        WOD_2__Claim__c claim = [select id, CurrencyISOCode from WOD_2__Claim__c];
        installedClaimParts[0].WOD_2__Claim__c = claim.Id;
        Test.startTest();
        System.assertEquals(false,new ATI_CLM_ClaimBaseOverrideHook().beforeInstalledPartSave(installedClaimParts).status,'Expected error not thrown');
        Test.stopTest();
    }

   
    @isTest
    static void testBeforeInstalledPartSaveForClaimTemplate(){
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
                             installedClaimParts[0].WOD_2__Warranty_Product__c = [select id from WOD_2__Warranty_Product__c where WOD_2__Item_Type__c = 'Part'].Id;
        WOD_2__Claim__c claim = [select id, WOD_2__Claim_Type__c from WOD_2__Claim__c];
        claim.WOD_2__Claim_Type__c = 'Claim Template';
        update claim;
        installedClaimParts[0].WOD_2__Claim__c = claim.Id;
        Test.startTest();
        new ATI_CLM_ClaimBaseOverrideHook().beforeInstalledPartSave(installedClaimParts);
        Test.stopTest();
    }
   
    private static User createPortalAccountOwner() {  
        UserRole portalRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role', PortalType='None' );  
        insert portalRole;  
        System.debug('portalRole is ' + portalRole);  
        Profile sysAdminProfile = [Select Id from Profile where name = 'System Administrator'];  
        User portalAccountOwner = new User(  
            UserRoleId = portalRole.Id,  
            ProfileId = sysAdminProfile.Id,  
            Username = 'portalOwner' + System.currentTimeMillis() + '@test.com',  
            Alias = 'Alias',  
            Email='portal.owner@test.com',  
            EmailEncodingKey='UTF-8',  
            Firstname='Portal',  
            Lastname='Owner',  
            LanguageLocaleKey='en_US',  
            LocaleSidKey='en_US',  
            TimeZoneSidKey = 'America/Los_Angeles'  
        );  
        Database.insert(portalAccountOwner);  
        return portalAccountOwner;  
    }  
    
    private static User createCommunityUser(User portalAccountOwner) {  
        User communityUser = null;
        System.runAs ( portalAccountOwner ) {  
            //Create account  
            Account portalAccount = new Account(  
                Name = 'portalAccount',  
                WOD_2__Warranty_Account_Type__c ='Dealer', 
                Type = 'Distributor',
                OwnerId = portalAccountOwner.Id  
            );  
            Database.insert(portalAccount);  
            //Create contact  
            Contact portalContact = new Contact(  
                FirstName = 'portalContactFirst',  
                Lastname = 'portalContactLast',  
                AccountId = portalAccount.Id,  
                Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
            );  
            Database.insert(portalContact);  
            communityUser = new User(  
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ATI Distributor and Dealer'].Id,  
                FirstName = 'CommunityUserFirst',  
                LastName = 'CommunityUserLast',  
                Email = 'community.user@test.com',  
                Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
                Title = 'Title',  
                Alias = 'Alias',  
                TimeZoneSidKey = 'America/Los_Angeles',  
                EmailEncodingKey = 'UTF-8',  
                LanguageLocaleKey = 'en_US',  
                LocaleSidKey = 'en_US',  
                ContactId = portalContact.id  
            );  
            Database.insert(communityUser);  
        }  
        return communityUser;
    }       
    
    private static String getCurrencyCode(){
        Set<String> validCurrency = new Set<String>();
        Schema.DescribeFieldResult f = Pricebook2.CurrencyIsoCode.getDescribe();
        for (Schema.PicklistEntry pick:f.getPicklistValues()){
            if(pick.getValue() != 'USD'){
                return pick.getValue(); 
            }
        }
        return 'USD';
    } 

    @isTest
    static void testBeforeCampaignClaimSave(){
        try{
            twodcms__Service_Campaign__c sc = [Select Id,ATI_Months_Covered__c from twodcms__Service_Campaign__c];
            WOD_2__Claim__c claim = [select id,ATI_WR_Details__c, WOD_2__Inventory__c, WOD_2__Claim_Type__c,ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c,
                                                                                      ATI_First_Labor_Applied_Date_Time__c, ATI_First_Part_Ordered_Date_Time__c, ATI_Last_Part_Arrival_Date_Time__c,ATI_Tracking_Number__c,
                                 ATI_Repair_Order_Closed_Date_Time__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c,
                                 ATI_Distributor_schedules_cust_Serv_Date__c, ATI_Customer_Requests_Service_Date__c,CurrencyIsoCode,WOD_2__Causal_Part_Number__c,
                                 ATI_Last_Labor_Recorded_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Work_Performed_Comments__c,WOD_2__Work_Order__c,ATI_Technician_Name__c,
                                 ATI_Failure_Code__c, WOD_2__Fault_Code__c, WOD_2__BusinessCategory__c, WOD_2__Pre_Authorization_Reason__c from WOD_2__Claim__c];
            claim.WOD_2__Claim_Type__c = 'Campaign';
            claim.WOD_2__Units_Usage__c = 100;
            //String str = '[{"campaignClaimObject":{"WOD_2__Date_Of_Failure__c":"2021-08-03","CurrencyIsoCode":"USD"},"msg":"","status":true}]';
            String str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
            claim.ATI_Tracking_Number__c = 'TrackingNumber';
            claim.WOD_2__Work_Order__c = '';
            str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
            claim.WOD_2__Work_Order__c = 'ASD';
            claim.WOD_2__Work_Performed_Comments__c = '';
            str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
            claim.WOD_2__Work_Performed_Comments__c = 'ASD';
            str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
            claim.ATI_Tracking_Number__c = '';
            str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
            claim.ATI_Tracking_Number__c = 'TrackingNumber';
            str = '[{"campaignClaimObject":'+ JSON.serialize(claim) + ',"cctaObject":{"twodcms__Service_Campaign__c":'+JSON.serialize(sc.Id)+'},"msg":"","status":true}]';
            new ATI_CLM_ClaimBaseOverrideHook().beforeCampaignClaimSave(str);
        }catch(Exception e){
            
        }
    }
              
              @isTest
    static void testBeforeClaimSubmit(){
        WOD_2__Claim__c claim = [SELECT Id FROM WOD_2__Claim__c LIMIT 1];
        WOD_2__Business_Category_Configuration__c bccsObj = [SELECT Id FROM WOD_2__Business_Category_Configuration__c LIMIT 1];
        WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject = new WOD_2.BR_BusinessRuleEngineWrapper();
        brInputWrapperObject.ruleObjectIdList = new List<Id>{claim.Id};
        brInputWrapperObject.ruleObjectAPIName = 'WOD_2__Claim__c';
        brInputWrapperObject.buId = bccsObj.Id;
        
		Profile p = [Select Id from Profile WHERE Name = 'System Administrator'];
		User usr = new User();
        usr.FirstName = 'Test User';
        usr.LastName = 'Number One';
        usr.Email = 'testing222111@sesaco.com';
        usr.Username = 'testing222111@sesaco.com';
        usr.Alias = 'tester';
        //usr.ContactId = con.Id;
        usr.ProfileId = p.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
        User portalAccountOwner = createPortalAccountOwner();  
        User communityUser = createCommunityUser(portalAccountOwner);
		System.runAs(usr){
            WOD_2__Claim__Share claimShareRec = new WOD_2__Claim__Share(ParentId=claim.Id,UserOrGroupId=communityUser.Id,AccessLevel = 'Edit');
       		insert claimShareRec;
            Test.startTest();
            	System.runAs(communityUser){
                    System.assertNotEquals(UserInfo.getUserId(),[SELECT Id,OwnerId FROM WOD_2__Claim__c LIMIT 1].OwnerId, 'Owner should not be current user');
                    new ATI_CLM_ClaimBaseOverrideHook().beforeClaimSubmit(brInputWrapperObject);
                    System.assertEquals(UserInfo.getUserId(),[SELECT Id,OwnerId FROM WOD_2__Claim__c LIMIT 1].OwnerId, 'Owner should be changed to current user');
                }
            Test.stopTest();
        }
     }
}