@isTest
public class PRPC_SendNotificationScheduleTest {
	static testMethod void sendNotificationScheduleTest1() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
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
        PRPC_TestDataFactory.createUser('PRP Admin');
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        KPI_Date_Settings__c KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c, File_Submission_Date__c from KPI_Date_Settings__c LIMIT 1];
        KPIfilesubmission.File_Submission_Date__c = Date.today()-1;
        UPDATE KPIfilesubmission;
        PRPC_SendNotificationSchedule b1 = new PRPC_SendNotificationSchedule();
        String sch = '0 0 23 * * ?';
        Test.startTest();
        System.Schedule('Test Territory Check', sch, b1);
        PRPC_EmailForDefaulters.monthValue = 1;
        PRPC_SendNotificationToDistributor.monthValue = 1;
        PRPC_SendNotificationForCustomerData.monthValue = 1;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 2;
        PRPC_SendNotificationToDistributor.monthValue = 2;
        PRPC_SendNotificationForCustomerData.monthValue = 2;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        Test.stopTest();
    }
    
    static testMethod void sendNotificationScheduleTest2() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
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
        PRPC_TestDataFactory.createUser('PRP Admin');
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        KPI_Date_Settings__c KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c, File_Submission_Date__c from KPI_Date_Settings__c LIMIT 1];
        KPIfilesubmission.File_Submission_Date__c = Date.newInstance(2020,10,26);
        UPDATE KPIfilesubmission;
        
        Test.startTest();
        PRPC_EmailForDefaulters.monthValue = 3;
        PRPC_SendNotificationToDistributor.monthValue = 3;
        PRPC_SendNotificationForCustomerData.monthValue = 3;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 4; 
        PRPC_SendNotificationToDistributor.monthValue = 4;
        PRPC_SendNotificationForCustomerData.monthValue = 4;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        Test.stopTest();
    }
    
    static testMethod void sendNotificationScheduleTest3() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
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
        PRPC_TestDataFactory.createUser('PRP Admin');
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        KPI_Date_Settings__c KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c, File_Submission_Date__c from KPI_Date_Settings__c LIMIT 1];
        KPIfilesubmission.File_Submission_Date__c = Date.newInstance(2020,10,26);
        UPDATE KPIfilesubmission;
        
        Test.startTest();
        PRPC_EmailForDefaulters.monthValue = 5;
        PRPC_SendNotificationToDistributor.monthValue = 5;
        PRPC_SendNotificationForCustomerData.monthValue = 5;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 6; 
        PRPC_SendNotificationToDistributor.monthValue = 6;
        PRPC_SendNotificationForCustomerData.monthValue = 6;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        Test.stopTest();
    }
    
    static testMethod void sendNotificationScheduleTest4() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
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
        PRPC_TestDataFactory.createUser('PRP Admin');
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        KPI_Date_Settings__c KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c, File_Submission_Date__c from KPI_Date_Settings__c LIMIT 1];
        KPIfilesubmission.File_Submission_Date__c = Date.newInstance(2020,10,26);
        UPDATE KPIfilesubmission;
        
        Test.startTest();
        PRPC_EmailForDefaulters.monthValue = 7;
        PRPC_SendNotificationToDistributor.monthValue = 7;
        PRPC_SendNotificationForCustomerData.monthValue = 7;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 8; 
        PRPC_SendNotificationToDistributor.monthValue = 8;
        PRPC_SendNotificationForCustomerData.monthValue = 8;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        Test.stopTest();
    }
    
    static testMethod void sendNotificationScheduleTest5() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
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
        PRPC_TestDataFactory.createUser('PRP Admin');
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        KPI_Date_Settings__c KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c, File_Submission_Date__c from KPI_Date_Settings__c LIMIT 1];
        KPIfilesubmission.File_Submission_Date__c = Date.newInstance(2020,10,26);
        UPDATE KPIfilesubmission;
        
        Test.startTest();
        PRPC_EmailForDefaulters.monthValue = 9;
        PRPC_SendNotificationToDistributor.monthValue = 9;
        PRPC_SendNotificationForCustomerData.monthValue = 9;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 11; 
        PRPC_SendNotificationToDistributor.monthValue = 11;
        PRPC_SendNotificationForCustomerData.monthValue = 11;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        PRPC_EmailForDefaulters.monthValue = 12; 
        PRPC_SendNotificationToDistributor.monthValue = 12;
        PRPC_SendNotificationForCustomerData.monthValue = 12;
        PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();
        Test.stopTest();
    }
}