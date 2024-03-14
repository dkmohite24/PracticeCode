@isTest
public class PRPC_EmailForErrorDataTest {
	static testMethod void emailForErrorDataTest() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount' || rule.Name=='EndCustTrigger' || rule.Name=='TatTurntTrigger') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> distributor = new List<Account>();
        distributor = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
     	User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                         LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  		 AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT ID, Name, SAP_ID__c FROM Account where ParentId = :distributor[0].Id LIMIT 1];
        List<TAT_Turnt_staging__c> tatError = new List<TAT_Turnt_staging__c>();
        TAT_Turnt_staging__c tat = new TAT_Turnt_staging__c();
        tat.Allison_Serial__c = 'A12';
        tat.Error_Log__c = 'Sample Error';
        tat.Date_of_File_Submission__c = '10/20/2030';
        tat.Distributor_Ship_To__c = branch.SAP_ID__c;
        tatError.add(tat);
        INSERT tatError;
        
        List<End_Customer_Staging_Data__c> endError = new List<End_Customer_Staging_Data__c>();
        End_Customer_Staging_Data__c endCust = new End_Customer_Staging_Data__c();
        endCust.Customer_Email_Adress__c = 'pankhurhi.mallik@gmail.com';
        endCust.Date_Of_Submission__c = '10/20/2030';
        endCust.Language__c = 'English';
        endCust.Error_Log__c = 'Sample Error';
        endCust.Customer_Name__c = 'TestCustomer';
        endCust.Distributor_Ship_To__c = branch.SAP_ID__c;
        endError.add(endCust);
        INSERT endError;
        
        Test.startTest();
        PRPC_EmailForErrorData.sendEmail();
        PRPC_EmailForErrorData.sendEmailToCustomers();
        Test.stopTest();
    }
    @isTest static void getALLPickListValuesTest6() {
        
        Test.startTest();
        PRPC_ScheduleEmailForErrorData s = new PRPC_ScheduleEmailForErrorData();
		s.execute(null);
        Test.stopTest();
        
    }
    
}