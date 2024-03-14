@IsTest
public class PRPC_DeleteDuplicateTTDistributorRecTest {
    
     @IsTest
    public static void DeleteRealData(){
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_ID__c = '1234567890';
        insert acc;
       
        TAT_Data__c tt1 = new TAT_Data__c();
            tt1.Distributor_Ship_To__c= '1234567890';
            tt1.Claim_Number__c = 'AT100000';
            tt1.repair_order_number__c = '1256';
            
             tt1.Extraction_Date__c = date.newInstance(2024, 01, 12);
             tt1.Allison_Serial__c = '12345897';
             tt1.Source_Type__c = 'Distributor';
             tt1.vin__c = 'YUJKHK88090';
             tt1.Dealer_Id__c = acc.id;
        	 tt1.Total_labor_hours__c='4';
             insert tt1;
            
             TAT_Data__c tt2 = new TAT_Data__c();
            tt2.Distributor_Ship_To__c= '1234567890';
            tt2.Claim_Number__c = 'AT100000';
            tt2.repair_order_number__c = '1256';
            
             tt2.Extraction_Date__c = date.newInstance(2024, 01, 12);
             tt2.Allison_Serial__c = '12345897';
             tt2.Source_Type__c = 'Distributor';
             tt2.vin__c = 'YUJKHK88090';
             tt2.Dealer_Id__c = acc.id;
        	 tt2.Total_labor_hours__c='4';
             insert tt2;
        
             test.startTest();
       
        PRPC_DeleteDuplicateTTDistributorRecord myBatchObject = new PRPC_DeleteDuplicateTTDistributorRecord();
        Database.executeBatch(myBatchObject);
      
        test.stopTest();
    }

}