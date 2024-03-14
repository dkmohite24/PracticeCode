/* Name: ATI_UtilsTest
   Description : Test class for ATI_Utils
   Author : Tavant
   History :
   VERSION     AUTHOR       DATE               DETAIL                       UserStory/Req#
   1.0 -       Tavant    	02/12/2020         INITIAL DEVELOPMENT
*/

@isTest
public with sharing class ATI_UtilsTest {
    /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
    @testSetup static void testSetupMethod(){
        List<Account> accountLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accountLst.size();i++){
        	accountLst[i].Sales_RegionA__c = 'EMEA';
            accountLst[i].SAP_ID__c = '1223123'+i;
            accountLst[i].Location_Type__c = 'test'+i;    
        }
        insert accountLst;
    }
    
    /*
        Method Name :   getConfigurationSettingMetaDataTest
        Description :   Method to test getConfigurationSettingMetaData
    */
	@isTest 
    public static void getConfigurationSettingMetaDataTest(){
        System.assertEquals(true,ATI_Utils.getConfigurationSettingMetaData('ATI_ClaimTrigger')!= null,'Success');
		WOD_2.ResponseWrapper respObj= ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess('WOD_2__Claim__c','ATI_Claim_Search_Dealer');
        System.assertEquals(true,respObj.status,'Success');
        ATI_Utils.getPicklistOptions('WOD_2__Claim__c','WOD_2__Claim_Status__c');
        WOD_2.ResponseWrapper respWrap= ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess('ATI_Extended_Warranty_Pricing__c','ATI_ExtendedWarrantyPricingFieldSetName');
        System.assertEquals(true,respWrap.status,'Success');
        ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess('','');
        
        List<sObject> sobjectList= new List<sObject>();
        sobjectList.add(Schema.getGlobalDescribe().get('ATI_Extended_Warranty_Pricing__c').newSObject());
        List<String> objectFieldsAPINames = new List<String>();
        objectFieldsAPINames.add('ATI_Active_From__c');
        objectFieldsAPINames.add('ATI_Base_Price__c');
        objectFieldsAPINames.add('ATI_Country__c');
        WOD_2.ResponseWrapper respWrap2= ATI_Utils.checkReadAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
        System.assertEquals(true,respWrap2.status,'Success');
        
        objectFieldsAPINames.add('ATI_Policy_Definition__r.Name');
        ATI_Utils.NoAccessObjectFieldWrapper respWrap3= ATI_Utils.fetchCreateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
        System.assertEquals(0,respWrap3.noAccessObjectList.size(),'Success');
        
        WOD_2.ResponseWrapper respWrap4= ATI_Utils.querySObjects('Select Id,ATI_Active_From__c,ATI_Base_Price__c FROM ATI_Extended_Warranty_Pricing__c');
    	System.assertEquals(true,respWrap4.status,'Success');
        WOD_2.BaseController.getFieldsetDetailsByConfigSettingHaveReadAccess('WOD_2__Claim__c', 'WOD_2__CLM_MC_fieldset');
        WOD_2.ResponseWrapper respWrap5= ATI_Utils.checkObjectDeleteAccess('ATI_Extended_Warranty_Pricing__c');
        WOD_2.ResponseWrapper respWrap6= ATI_Utils.checkCreateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
        WOD_2.ResponseWrapper respWrap7= ATI_Utils.insertSObjects(sobjectList, false);
        WOD_2.ResponseWrapper respWrap8= ATI_Utils.checkUpdateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
        ATI_Utils.NoAccessObjectFieldWrapper respWrap9= ATI_Utils.fetchUpdateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
        Date dt= ATI_Utils.parseDate('2021-02-09');
        DateTime dtTime= ATI_Utils.parseDateTime('2021-02-09');
        Boolean isBlankCheck = ATI_Utils.checkIsBlankData('Test');
        System.assertEquals(false,isBlankCheck,'Success');
        
        Boolean isNotBlankCheck = ATI_Utils.checkIsNotBlankData('Test');
        System.assertEquals(true,isNotBlankCheck,'Success');
        System.assertEquals(0,respWrap3.noAccessObjectList.size(),'Success');
        
        ATI_Utils.isLoggedInUserAsDistributor();
        Set<String> isoCodeSet= new Set<String>();
        isoCodeSet.add('BRL');
        isoCodeSet.add('USD');
        Map<String,CurrencyType> currencyMap= ATI_Utils.getGlobalCurrencies(isoCodeSet);
    }
    
    @isTest //Test getFieldSetDataTest
    public static void buildQueryWithoutAccessCheckTest(){
        TestDataFactory.createInventory(2);
        String queryBuilderWrapperStr = '{}';
        WOD_2.QueryBuilderWrapper queryBuilderWrapperObject = (WOD_2.QueryBuilderWrapper) JSON.deserialize(queryBuilderWrapperStr, WOD_2.QueryBuilderWrapper.class);
        List<String> filedList = new List<String>{'WOD_2__Serial_Number__c','WOD_2__Type__c','WOD_2__Item__r.Name'};
        queryBuilderWrapperObject.fieldsToQuery = filedList;
        queryBuilderWrapperObject.fromObject='WOD_2__Inventory__c';
        queryBuilderWrapperObject.recordLimit = 10;
        queryBuilderWrapperObject.whereClause = 'where WOD_2__Serial_Number__c LIKE \'TestINV%\' ';
        queryBuilderWrapperObject.orderBy='WOD_2__Serial_Number__c DESC NULLS LAST';
        System.assertEquals(true,ATI_Utils.buildQuery(queryBuilderWrapperObject).length()>0);
     	System.assertEquals(true,ATI_Utils.buildQueryWithoutAccessCheck(queryBuilderWrapperObject).length()>0);
    }
    
    @isTest
	private static void testIsPartnerUser(){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        //create Portal User
        List<User> portalAccountOwner1 = TestDataFactory.createUser(1);
        portalAccountOwner1[0].UserRoleId = portalRole.Id;
        portalAccountOwner1[0].ProfileId = profile1.Id;
        Database.insert(portalAccountOwner1);
        List<Account> portalAccount1;
        List<User> user1;
        
        System.runAs (portalAccountOwner1[0]) {
            //Create account
            portalAccount1 = [SELECT Id,OwnerId,Sales_RegionA__c,SAP_ID__c FROM Account LIMIT 1];
            portalAccount1[0].OwnerId = portalAccountOwner1[0].Id;
            Database.update(portalAccount1);
            
            //Create contact
            List<Contact> contact1 = TestDataFactory.createContact(1);
            contact1[0].AccountId = portalAccount1[0].id;
            Database.insert(contact1);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile where Name = 'ATI Distributor and Dealer' Limit 1];
            user1 = TestDataFactory.createUser(1);
            user1[0].ContactId = contact1[0].Id;
            user1[0].ProfileId = portalProfile.Id;
            Database.insert(user1); 
        }
        System.runAs(user1[0]) {
            responseWrapperObj = ATI_Utils.isPartnerUser();
            List<String> objectFieldsAPINames = new List<String>();
            objectFieldsAPINames.add('ATI_Active_From__c');
            objectFieldsAPINames.add('ATI_Base_Price__c');
            objectFieldsAPINames.add('ATI_Country__c');
            WOD_2.ResponseWrapper resp = WOD_2.BaseController.getFieldsetDetailsByConfigSettingHaveReadAccess('WOD_2__Claim__c', 'ClaimDisplayFieldSet');
            System.debug('getFieldsetDetailsByConfigSettingHaveReadAccess -> ' + resp);
            WOD_2.ResponseWrapper respWrap5= ATI_Utils.checkObjectDeleteAccess('ATI_Extended_Warranty_Pricing__c');
            WOD_2.ResponseWrapper respWrap6= ATI_Utils.checkCreateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
            WOD_2.ResponseWrapper respWrap8= ATI_Utils.checkUpdateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
            ATI_Utils.NoAccessObjectFieldWrapper respWrap9= ATI_Utils.fetchUpdateAccess('ATI_Extended_Warranty_Pricing__c',objectFieldsAPINames);
            System.assertEquals('true',responseWrapperObj.data,'check whether running user is portal user or not?');
        }
    }
    
    @isTest
    private static void testupdateSObjects(){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        Test.startTest();
            List<Account> accLst = [SELECT Id FROM Account];
            responseWrapperObj = ATI_Utils.updateSObjects(new List<sObject>{accLst[0]},true);
            System.assertEquals( '[{"id":"'+accLst[0].id+'","success":true,"errors":[]}]', responseWrapperObj.data,'If user has access, check whether object has updated or not?');
        Test.stopTest();
    }
}