/* Name: ATI_ExtendedWarrantyPricingControllerTest
Description : Test Class for ATI_ExtendedWarrantyPricingController 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)         12/11/2020         INITIAL DEVELOPMENT            20517                  
*/
@isTest
public class ATI_ExtendedWPControllerTest {
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigLst = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert businessCategoryConfigLst;

        //Payment Definition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;

        //Policy Definition - Extended
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        policyDefLst[0].WOD_2__Type__c = 'Extended';
        insert policyDefLst;

        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> wpLst = TestDataFactory.createWarrantyProduct(1);
        insert wpLst;
        
        //Vocation Code for Extended Warranty Pricing
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createVocationCode(1,false);
        insert wcLst;

        //Extended Warranty Pricing
        List<ATI_Extended_Warranty_Pricing__c> ewpLst = TestDataFactory.createExtendedWarrantyPricing(1);
        ewpLst[0].ATI_Vocation_Code__c = wcLst.get(0).id;
        ewpLst[0].ATI_Warranty_Product__c = wpLst.get(0).id;
        ewpLst[0].ATI_Policy_Definition__c = policyDefLst.get(0).id;
        insert ewpLst;

        Test.stopTest();
    }

    @isTest
    private static void testGetPolicyData(){
        Test.startTest();
        WOD_2__Policy_Definition__c policyDef = [SELECT Id,WOD_2__Type__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended' LIMIT 1];
        WOD_2.ResponseWrapper responseWrapperObj = ATI_ExtendedWPController.getPolicyRecord(policyDef.id);
        System.assert(true,responseWrapperObj.status);
        List<WOD_2__Policy_Definition__c> policyDefReturnedResult = (List<WOD_2__Policy_Definition__c>)JSON.deserialize(responseWrapperObj.data,List<WOD_2__Policy_Definition__c>.class);
        System.assertEquals(1,policyDefReturnedResult.size(),'Extended Policy Record Check..!!!');
        responseWrapperObj = ATI_ExtendedWPController.getPolicyRecord('12345');
        System.assertEquals(false,responseWrapperObj.status,'Extended Policy Catch Exception Check..!!!');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetExtendedWPRecords(){
        Test.startTest();
        WOD_2__Policy_Definition__c policyDef = [SELECT Id,WOD_2__Type__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended' LIMIT 1];
        WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess('ATI_Extended_Warranty_Pricing__c','ATI_ExtendedWarrantyPricingFieldSetName');
        System.assert(true,responseWrapperObj.status);
        List<String> fields = new List<String>();
        List<ATI_Utils.FieldSetDetailsWrapper> fieldSetWrapperObj = (List<ATI_Utils.FieldSetDetailsWrapper>)JSON.deserialize(responseWrapperObj.data,List<ATI_Utils.FieldSetDetailsWrapper>.class);
        for(ATI_Utils.FieldSetDetailsWrapper wrapper : fieldSetWrapperObj){
            fields.add(wrapper.fieldpath);    
        }
        responseWrapperObj = ATI_ExtendedWPController.getExtendedWPRecords('ATI_Extended_Warranty_Pricing__c',fields,policyDef.id);
        System.assert(true,responseWrapperObj.status);
        List<ATI_Extended_Warranty_Pricing__c> ewpDataLst = (List<ATI_Extended_Warranty_Pricing__c>)JSON.deserialize(responseWrapperObj.data,List<ATI_Extended_Warranty_Pricing__c>.class);
        System.assertEquals(1,ewpDataLst.size(),'Number of Extended Warranty Pricing records are returned..!!!');
        responseWrapperObj = ATI_ExtendedWPController.getExtendedWPRecords('Extended_Warranty_Pricing__c',fields,'12345');
       	System.assertEquals(false,responseWrapperObj.status,'Catch Exception Check while fetching Extended Warranty Pricing Records..!!!');
        Test.stopTest();
    }
    
    @isTest
    private static void testDeleteExtendedWPRecords(){
        Test.startTest();
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id FROM ATI_Extended_Warranty_Pricing__c LIMIT 1];
        WOD_2.ResponseWrapper responseWrapperObj = ATI_ExtendedWPController.deleteEWPRecords(ewp);
        System.assert(true,responseWrapperObj.status);
        ATI_Extended_Warranty_Pricing__c deletedEWPRecord = [SELECT Id,IsDeleted FROM ATI_Extended_Warranty_Pricing__c WHERE Id=:ewp.id ALL ROWS];
        System.assertEquals(deletedEWPRecord.IsDeleted, true,'Extended Warranty Pricing Delete Record Check...!!!');
        responseWrapperObj = ATI_ExtendedWPController.deleteEWPRecords(new ATI_Extended_Warranty_Pricing__c());
        System.assertEquals(false,responseWrapperObj.status,'Catch Exception Check While Deleting Extended Warranty Pricing Records...!!!');
        Test.stopTest();
    }
}