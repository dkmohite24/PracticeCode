/*
    Class Name  :   ATI_ClaimDetailPageUrlLocatorTest
    Description :   Test class for ATI_ClaimDetailPageUrlLocatorController
*/
@isTest
public class ATI_ClaimDetailPageUrlLocatorTest {
    /*
        Method Name :   testSetUp
        Description :   TestSetup method to create test data
    */
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
            accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accLst[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
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
        
        Id partClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id part90ClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
        Id campaignClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
        Id claimTemplateRTId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
        //create rejected claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(4); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[2].RecordTypeId = campaignClaimId;
        claimLst[2].WOD_2__Claim_Type__c = 'Campaign';
        claimLst[3].RecordTypeId = claimTemplateRTId;
        claimLst[3].WOD_2__Claim_Type__c = 'Claim Template';
        claimLst[1].WOD_2__Claim_Type__c = 'Part';
        claimLst[1].WOD_2__Part_Serial_Number__c = '12312';
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        //claimLst[2].RecordTypeId = equipmentClaimId;
        insert claimLst;
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
    
    private static testmethod void testClaimDetailGetURL(){
        User portalAccountOwner = createPortalAccountOwner();  
        User communityUser = createCommunityUser(portalAccountOwner);
        List<WOD_2__Claim__c> partClaimLst = [SELECT Id,RecordType.DeveloperName FROM WOD_2__Claim__c WHERE RecordType.DeveloperName='Machine'];
        List<WOD_2__Claim__c> part90ClaimLst = [SELECT Id,RecordType.DeveloperName FROM WOD_2__Claim__c WHERE RecordType.DeveloperName='Part'];
        List<WOD_2__Claim__c> campaignClaimLst = [SELECT Id,RecordType.DeveloperName FROM WOD_2__Claim__c WHERE RecordType.DeveloperName='Campaign'];
        
        System.runAs(communityUser){
            Test.startTest();
            WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
            String getURLForPartClaimWithoutAccess = ATI_ClaimDetailPageUrlLocatorController.getURL(partClaimLst[0].id);
            //System.assertEquals('/s/claimdetailpagewithoutaccess?page=ATI_ClaimDetailPageMachineWithoutAccess&id='+partClaimLst[0].id,getURLForPartClaimWithoutAccess,'URL Shuold be same!');
            
            String getURLForPart90ClaimWithoutAccess = ATI_ClaimDetailPageUrlLocatorController.getURL(part90ClaimLst[0].id);
            //System.assertEquals('/s/claimdetailpagewithoutaccess?page=ATI_ClaimDetailPagePartWithoutAccess&id='+part90ClaimLst[0].id,getURLForPart90ClaimWithoutAccess,'URL Shuold be same!');
            
            system.debug('campaignClaimLst'+campaignClaimLst);
            String getURLForCampaignClaimWithoutAccess = ATI_ClaimDetailPageUrlLocatorController.getURL(campaignClaimLst[0].id);
            //System.assertEquals('/s/claimdetailpagewithoutaccess?page=ATI_ClaimDetailPageCampaignWithoutAccess&id='+campaignClaimLst[0].id,getURLForCampaignClaimWithoutAccess,'URL Shuold be same!');
            Profile pro = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            
            Test.stopTest();
        }
    }
}