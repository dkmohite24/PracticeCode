/* Name: ATI_DiagnosticCode_ControllerTest
Description : Test Class for ATI_DiagnosticCode_Controller 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             		DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         01/08/2021         INITIAL DEVELOPMENT            20517                  
*/
@isTest
public class ATI_DiagnosticCode_ControllerTest {
    @testSetup
    public static void testSetup(){
        //Account Creation
        List<Account> accList = TestDataFactory.createAccount(1);
        insert accList;
        
        list<RecordType> rListMachine = [Select id 
                                         From RecordType 
                                         Where sObjectType = 'WOD_2__Claim__c'and RecordType.DeveloperName = 'Machine'];
        
        //Diagnostic Code for Extended Warranty Pricing
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createDiagnosticCode(2,false);
        insert wcLst;
        
        //Inventory Creation
        List<WOD_2__Inventory__c> invList= TestDataFactory.createInventory(1);
        invList[0].WOD_2__Account__c= accList[0].Id;
        insert invList;
        
        //Claim Creation
        List<WOD_2__Claim__c> claimList= TestDataFactory.createClaim(1);
        claimList[0].RecordTypeId= rListMachine[0].Id;
        claimList[0].WOD_2__Inventory__c= invList[0].Id;
        claimList[0].WOD_2__Account__c=accList[0].Id;
        insert claimList[0];
        
    }
    
     @isTest
    public static void saveDiagnosticCodesTest(){
        List<String> diagnosticCode = new List<String>();
        List<WOD_2__Warranty_Code__c> diagnosticCodeList = [Select Id From WOD_2__Warranty_Code__c];
        Id claimId= [Select Id From WOD_2__Claim__c].Id;
        Test.startTest();
        	List<String> fields = new List<String>();
            fields.add('Warranty_Code__c');
            ATI_DiagnosticCode_Controller.saveDiagnosticCodes(diagnosticCode,claimId);
            for(WOD_2__Warranty_Code__c code: diagnosticCodeList){
                diagnosticCode.add(code.Id);
            }
            ATI_DiagnosticCode_Controller.saveDiagnosticCodes(diagnosticCode,claimId);
            List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createDiagnosticCode(2,false);
            insert wcLst;
            diagnosticCode= new List<String>();
            for(WOD_2__Warranty_Code__c code: wcLst){
                diagnosticCode.add(code.Id);
            }
            
            ATI_DiagnosticCode_Controller.saveDiagnosticCodes(diagnosticCode,claimId);
            diagnosticCode.add(wcLst[0].Id);
        
            ATI_DiagnosticCode_Controller.saveDiagnosticCodes(diagnosticCode,claimId);
            ATI_DiagnosticCode_Controller.deleteSObjects(diagnosticCode[0]);
            ATI_DiagnosticCode_Controller.getDiagnosticCodes('ATI_Diagnostic_Code__c',fields,claimId);
        Test.stopTest();
    }

	@isTest
    public static void testGetAllowedClaimStatusMetadata(){
		Test.startTest();
        	WOD_2.ResponseWrapper response = ATI_DiagnosticCode_Controller.getAllowedClaimStatusMetadata();
        	System.assertEquals(true, response.status, 'Metadata records should be retrieved');
        Test.stopTest();
    }
}