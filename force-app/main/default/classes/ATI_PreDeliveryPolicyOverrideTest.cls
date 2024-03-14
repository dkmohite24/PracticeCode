/**
 -------------------------------------------------------------------------------------------------
This is ATI_BulkWRPolicyQueryOverrideTest class
* --------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        08-JAN-2021
* @modified
* --------------------------------------------------------------------------------------------------
*/
@isTest
public class ATI_PreDeliveryPolicyOverrideTest {
    @testSetup
    public static void testSetup(){
		List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Sub_Type__c = '01';
        policyDefList.get(0).WOD_2__Status__c ='Active';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        WOD_2__Applicability_Term__c atObj = new WOD_2__Applicability_Term__c(WOD_2__isValidExpression__c=true,
                                                                              WOD_2__Applicability_Term_Type__c='Inclusion',
                                                                              WOD_2__Policy_Definition__c=policyDefList.get(0).Id);
        insert atObj;
    }
    
    @isTest
    private static void testFetchApplicabilityTerm(){
        Test.startTest();
        	ATI_PreDeliveryPolicyOverride controllerObj = new ATI_PreDeliveryPolicyOverride();
        	List<WOD_2__Applicability_Term__c> atLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');
        Test.stopTest();
        System.assertEquals(1, atLst.size(),'One AT should be returned');
    }
}