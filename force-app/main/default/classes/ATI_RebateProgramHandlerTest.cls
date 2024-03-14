@isTest
public class ATI_RebateProgramHandlerTest {
    
    @isTest
    static void testUpdateFieldOnProcessingStatusChange() {
        // Create test data for USD
        RebateProgram proposal = new RebateProgram(
            Name = 'Test Proposal',
            ATI_Processing_Status__c = 'Draft', // Setting initial status to Draft
            ATI_Incentive_Proposal_Value__c = 1000.00, // Setting incentive proposal value
            Frequency = 'OnDemand',
            StartDate = Date.today(),
            EndDate = Date.today()+7,
            CurrencyIsoCode = 'USD'
        );
        insert proposal;
        
        // Simulate an update trigger event
        proposal.ATI_Processing_Status__c = 'Submitted - Waiting for Approval';
        update proposal;
        
        // Verify if the fields are updated correctly
        proposal = [SELECT Id, ATI_Approved_Ex_Rate__c, ATI_Approval_US_Dollar_Amount__c FROM RebateProgram WHERE Id = :proposal.Id];
        
        // Check if the fields are updated as expected
        System.assertEquals(1.00000, proposal.ATI_Approved_Ex_Rate__c, 'Exchange rate should be 1 for USD');
        System.assertEquals(1000.00, proposal.ATI_Approval_US_Dollar_Amount__c, 'USD Amount should be equal to incentive proposal value for USD currency');
    }
    
     @isTest
    static void testUpdateFieldOnProcessingStatusChangeNotUSD() {
    // Create test data for other currency
        RebateProgram proposal = new RebateProgram(
            Name = 'Test Proposal 1',
            ATI_Processing_Status__c = 'Draft', // Setting initial status to Draft
            ATI_Incentive_Proposal_Value__c = 900.00, // Setting incentive proposal value
            Frequency = 'OnDemand',
            StartDate = Date.today(),
            EndDate = Date.today()+7,
            CurrencyIsoCode = 'NAD'
        );
        insert proposal;
        
        // Simulate an update trigger event
        proposal.ATI_Processing_Status__c = 'Submitted - Waiting for Approval';
        update proposal;
        
        // Verify if the fields are updated correctly
        proposal = [SELECT Id, ATI_Approved_Ex_Rate__c, ATI_Approval_US_Dollar_Amount__c FROM RebateProgram WHERE Id = :proposal.Id];
        
        // Check if the fields are updated as expected
        System.assertEquals(10, proposal.ATI_Approved_Ex_Rate__c, 'Exchange rate should be 1 for USD');
        System.assertEquals(90.00, proposal.ATI_Approval_US_Dollar_Amount__c, 'USD Amount should be equal to incentive proposal value for USD currency');
    }
}