@isTest
public class ATI_ClaimHeaderHandlerTest {
    
    @isTest
    static void testUpdateFieldOnStatusChangeUSD() {
        // Create test data
        ATI_C_E__c claimHeader = new ATI_C_E__c(
            //Name = 'Test Claim Header',
            Status__c = 'New', // Setting initial status to New
            CurrencyIsoCode = 'USD'
        );
        insert claimHeader;
        
        System.debug('Total Unique Claim Value before claim line' +claimHeader.Total_Unique_Claim_Value__c);
        
        Claim_Line_Item__c claimLine = new Claim_Line_Item__c(
            Price__c = 20,
            Claim__c = claimHeader.Id,
            Duplicate_Claim__c = false
        );
        
        Insert claimLine;
        
        System.debug('Total Unique Claim Value after claim line' +claimHeader.Total_Unique_Claim_Value__c);
        
        
        // Simulate an update trigger event
        claimHeader.Status__c = 'Pending Approval';
        update claimHeader;
        
        // Verify if the fields are updated correctly
        claimHeader = [SELECT Id, ATI_Approved_Ex_Rate__c, ATI_Approval_US_Dollar_Amount__c FROM ATI_C_E__c WHERE Id = :claimHeader.Id];
        
        // Check if the fields are updated as expected
        System.assertEquals(1.00000, claimHeader.ATI_Approved_Ex_Rate__c, 'Exchange rate should be 1 for USD');
        System.assertEquals(20.00, claimHeader.ATI_Approval_US_Dollar_Amount__c, 'USD Amount should be equal to total unique claim value for USD currency');
    }
   /* 
     @isTest
    static void testUpdateFieldOnStatusChangeNotUSD() {
        // Create test data
        ATI_C_E__c claimHeader1 = new ATI_C_E__c(
            //Name = 'Test Claim Header',
            Status__c = 'New', // Setting initial status to New
            CurrencyIsoCode = 'EUR'
        );
        insert claimHeader1;
        
        System.debug('Total Unique Claim Value before claim line' +claimHeader1.Total_Unique_Claim_Value__c);
        
        Claim_Line_Item__c claimLine1 = new Claim_Line_Item__c(
            Price__c = 20,
            Claim__c = claimHeader1.Id,
            Duplicate_Claim__c = false
        );
        
        Insert claimLine1;
        
        System.debug('Total Unique Claim Value after claim line' +claimHeader1.Total_Unique_Claim_Value__c);
        
        
        // Simulate an update trigger event
        claimHeader1.Status__c = 'Pending Approval';
        update claimHeader1;
        
        // Verify if the fields are updated correctly
        claimHeader1 = [SELECT Id, ATI_Approved_Ex_Rate__c, ATI_Approval_US_Dollar_Amount__c FROM ATI_C_E__c WHERE Id = :claimHeader1.Id];
        
        // Check if the fields are updated as expected
        System.assertEquals(0.9735, claimHeader1.ATI_Approved_Ex_Rate__c, 'Exchange rate should be 1 for USD');
        System.assertEquals(20.544, claimHeader1.ATI_Approval_US_Dollar_Amount__c, 'USD Amount should be equal to total unique claim value for USD currency');
    }
*/
}