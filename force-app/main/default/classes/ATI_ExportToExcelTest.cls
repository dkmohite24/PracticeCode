/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ATI_ExportToExcelTest {
    @isTest
    static void testGetClaimLineItems() {
        // Create Claim Header record
        ATI_C_E__c claimHeader = new ATI_C_E__c();
        insert claimHeader;

        // Create Claim Line Item record
        Claim_Line_Item__c claimLineItem = new Claim_Line_Item__c(
            ETC__c = true, 
            Serial_Number__c = 'a3aOy111123F6rVIAS', // Example text value
            //Product__c = 'a1k2v000001', // Example Product Id
            Price__c = 1000.00, // Example currency value
            Duplicate_Claim__c = false, 
            VIN__c = 'VIN123', // Example text value
            Ship_Date__c = Date.today(), // Example date value
            In_Service_Date__c = Date.today(), // Example date value
            Claim__c = claimHeader.Id // Assign the Claim Header Id
        );

        insert claimLineItem;

        // Start test
        Test.startTest();
        
        // Call the method to test
        List<Claim_Line_Item__c> claimLineItems = ATI_ExportToExcel.getClaimLineItems(claimHeader.Id);
        
        // Stop test
        Test.stopTest();

        // Assert that the list is not empty
        System.assertNotEquals(0, claimLineItems.size(), 'Claim line items should not be empty');
    }
}