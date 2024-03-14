@isTest(seeAllData = false)
private class PRPC_FacilityAudit_Test {
    @testSetup static void setup() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        // Create common test data that will be used across the test class
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
        Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        PRPCO_Facility_Audit__c audi = new PRPCO_Facility_Audit__c();
        audi = PRPC_TestDataFactory.insertAudit(acclist[0].Id,acclistBranch.Id,acclist[0].SAP_ID__C);
        //PRPC_TestDataFactory.createAccount();
        Attachment atc = new Attachment();
        atc.Name = 'test';
        atc.ParentId = audi.Id;
        atc.body = Blob.valueof('test');
        insert atc;
    }
    
    @isTest static void getALLPickListValuesTest() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        list<Account> acc = new list<Account>([select id,CitySAPField__c from Account]);
        list<Attachment> att = new list<Attachment>([select id from Attachment]);
        list<PRPCO_Facility_Audit__c> audi = new list <PRPCO_Facility_Audit__c>([select Audit_Date__c,Facility_Audit_Status__c,Distributor__c,Distributor_SAP_Number__c,Location__c,Location_SAP_Number__c,Score__c from PRPCO_Facility_Audit__c]);
        for(PRPCO_Facility_Audit__c aud:audi){
            aud.Distributor__c = acc[0].Id;
        }
        PRPCO_Facility_Audit__c fac = new PRPCO_Facility_Audit__c();
        Test.startTest();
        PRPC_FacilityAudit.Recorddatafetch(audi[0].Id);
        PRPC_FacilityAudit.Recorddatafetchdynamically(audi[0].Distributor__c,acc[0].CitySAPField__c,audi[0].Audit_Date__c);
        PRPC_FacilityAudit.Recordcreatewithoutattachment(acc[0].CitySAPField__c,acc[0].Id,audi[0].Audit_Date__c,Double.valueof(audi[0].Score__c),fac,'Pass');
        PRPC_FacilityAudit.saveChunk(acc[0].CitySAPField__c,acc[0].Id,audi[0].Audit_Date__c,Double.valueof(audi[0].Score__c),fac, 'fileName', 'base64Data', 'contentType', '','Pass');
        PRPC_FacilityAudit.appendToFile(att[0].Id,'base64Data');
        Test.stopTest();
        
    }
    @isTest static void RestrictedTabTest() {
        user u = PRPC_TestDataFactory.createUser('Minimum Access - Salesforce');
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();    
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest2() {
        user u = PRPC_TestDataFactory.createUser('PRP Admin');
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest3() {
        user u = PRPC_TestDataFactory.createUser('System Administrator');
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }   
    }
    @isTest static void RestrictedTabTest6() {
        user u = PRPC_TestDataFactory.createUser('Standard Platform User');
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest7() {
        user u = PRPC_TestDataFactory.createUser('Custom Platform User');
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest8() {
        user u = PRPC_TestDataFactory.createUser('Custom Platform User');
         PermissionSetAssignment psAssignment = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE name = 'ATI_PRP_CSM_Permission_Set'].Id
        );
        insert psAssignment;
        //PermissionSetAssignment per= [select id,AssigneeId, Assignee.name from PermissionSetAssignment where PermissionSet.name='ATI_PRP_CSM_Permission_Set'];
        //user u = [select id from user where id =:per.AssigneeId ];
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest9() {
        user u = PRPC_TestDataFactory.createUser('PRP Admin');
         PermissionSetAssignment psAssignment = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE name = 'ATI_PRP_Admin_Permission_Set'].Id
        );
        insert psAssignment;
        //PermissionSetAssignment per= [select id,AssigneeId, Assignee.name from PermissionSetAssignment where PermissionSet.name='ATI_PRP_Admin_Permission_Set'];
        //user u = [select id from user where id =:per.AssigneeId ];
        System.runAs(u) {
            Test.startTest();
            PRPC_RestrictTab.CommunityTab();
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    /*
    @isTest static void getStandardReport() {
       String DeveloperName='CE_Data_iQc';
        Test.startTest();
        PRPC_RestrictTab.getStandardReport(DeveloperName);            
        Test.stopTest();
    }   
	*/
    @isTest static void fakeMethod() {
        PRPC_RestrictTab.fakeMethod();
    }
    
}