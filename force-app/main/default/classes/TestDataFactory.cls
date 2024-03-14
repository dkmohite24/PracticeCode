/* Name: TestDataFactory
Description : Test Class test data setup
Author : Tavant (Shubham Tiwari)
History :
VERSION      AUTHOR                DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (Shubham Tiwari)    29/DEC/2019          INITIAL DEVELOPMENT
*/
@isTest
public with sharing class TestDataFactory {
    public static List<WOD_2__Business_Category_Configuration_Setting__c> createBccs(WOD_2__Business_Category_Configuration__c busCategoryObj){
        String recordId = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId();
        String recordIdRule = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Rule').getRecordTypeId();
        
        List<WOD_2__Business_Category_Configuration_Setting__c> businessConfigurationSettingList = new List<WOD_2__Business_Category_Configuration_Setting__c>();
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WarrantyRegistrationDatePriority',WOD_2__Unique_Rule_Name__c = 'WarrantyRegistrationDatePriority',WOD_2__Value__c='WOD_2__Inventory__r.WOD_2__Install_Date__c,WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c',WOD_2__isActive__c = true,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_PolicyUnitsDisplayConfig',WOD_2__Unique_Rule_Name__c = 'WR_PolicyUnitsDisplayConfig',WOD_2__Value__c = 'Machine:Machine Reading,Engine:Engine Reading',WOD_2__isActive__c =TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_PolicyPickDisplayStatus',WOD_2__Unique_Rule_Name__c = 'WR_PolicyPickDisplayStatus',WOD_2__Value__c = 'Draft',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_AfterRegistrationSaveInventoryStatus',WOD_2__Unique_Rule_Name__c = 'WR_AfterRegistrationSaveInventoryStatus',WOD_2__Value__c='Retail',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Registration Logic',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_AfterRegistrationSaveStatus',WOD_2__Unique_Rule_Name__c = 'WR_AfterRegistrationSaveStatus',WOD_2__Value__c='In Progress',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Registration Logic',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'OffSeasonPolicyExtensionType',WOD_2__Unique_Rule_Name__c = 'OffSeasonPolicyExtensionType',WOD_2__Value__c = 'StartDayExtend',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Registration Logic',WOD_2__Type__c='Single Picklist'));
        //WR_Submit_For_Approval BCCS and WR_Perform_Auto_D2D are required for WR
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_Submit_For_Approval',WOD_2__Unique_Rule_Name__c='WR_Submit_For_Approval',WOD_2__Value__c = 'FALSE',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Registration Logic',WOD_2__Type__c='Boolean'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_Perform_Auto_D2D',WOD_2__Unique_Rule_Name__c='WR_Perform_Auto_D2D',WOD_2__Value__c = 'TRUE',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Registration Logic',WOD_2__Type__c='Boolean'));
        
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_ChildWRInitialSaveStatus',WOD_2__Unique_Rule_Name__c = 'WR_ChildWRInitialSaveStatus',WOD_2__Value__c='Draft',WOD_2__isActive__c = true,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Inventory Information',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'WR_ChildWRType',WOD_2__Unique_Rule_Name__c = 'WR_ChildWRType',WOD_2__Value__c='Standard Registration',WOD_2__isActive__c = true,WOD_2__Rule_Object__c='WOD_2__Claim__c;WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Inventory Information',WOD_2__Type__c='Single Picklist',WOD_2__Sub_Type__c='Field Set'));
        
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'QuestionnairePdfOverrideClassName',WOD_2__Unique_Rule_Name__c = 'QuestionnairePdfOverrideClassName',WOD_2__Value__c='QuestionnairePdfDownloadOverride',WOD_2__isActive__c = true));
        //businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordIdRule,Name = 'Test1',WOD_2__Unique_Rule_Name__c = '',WOD_2__Value__c='RetailPT',WOD_2__isActive__c = true,WOD_2__Module__c='Claim'));
        //businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordIdRule,Name = 'Test2',WOD_2__Unique_Rule_Name__c = 'Test2',WOD_2__Value__c='RetailPT',WOD_2__isActive__c = true,WOD_2__Module__c='Claim'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_CancelExtendedWRWithinDays',WOD_2__Unique_Rule_Name__c = 'ATI_CancelExtendedWRWithinDays',WOD_2__Value__c='6',WOD_2__isActive__c = true,WOD_2__Module__c='WOD_2__Warranty_Registration__c'));
        
        //Price Fetch BCCS
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_EWPLateFeeForGreaterThanOneYear',WOD_2__Unique_Rule_Name__c='ATI_EWPLateFeeForGreaterThanOneYear',WOD_2__Value__c = '10',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Text'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_EWPLateFeeForGreaterThanTwoYears',WOD_2__Unique_Rule_Name__c='ATI_EWPLateFeeForGreaterThanTwoYears',WOD_2__Value__c = '20',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Text'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_EWPLateFeeForGreaterThanThreeYears',WOD_2__Unique_Rule_Name__c='ATI_EWPLateFeeForGreaterThanThreeYears',WOD_2__Value__c = '30',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Text'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_EWPLateFeeForGreaterThanFourYears',WOD_2__Unique_Rule_Name__c='ATI_EWPLateFeeForGreaterThanFourYears',WOD_2__Value__c = '40',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Warranty_Registration__c',WOD_2__Module__c='Warranty Registration',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Text'));
       
        //Claim Action
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CA_AllowedDecimalPlaces',WOD_2__Value__c='2',WOD_2__isActive__c = true, WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim Action',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CA_ClaimFinancialRollupStatuses',WOD_2__Value__c='Approved',WOD_2__isActive__c = true, WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim Action',WOD_2__Type__c='Multi-Select Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CA_AdditionalEditableFieldsBeforeTotal',WOD_2__Value__c='Markup:ATI_Markup__c',WOD_2__isActive__c = true, WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim Action',WOD_2__Type__c='Multi-Select Picklist'));
        
        //Auto Approved
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordIdRule,Name = 'ATI_Check_For_Auto_Approval',WOD_2__Unique_Rule_Name__c='ATI_Check_For_Auto_Approval',WOD_2__Value__c = '40',WOD_2__isActive__c = TRUE,WOD_2__Error_Type__c='Soft',WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='NA',WOD_2__Type__c='Text',WOD_2__Display_Message__c='Claim will be auto approved if all the business rules are passed and total requested amount is less than 2000.'));
        
        //Manual Approval
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordIdRule,Name = 'ATI_Threshold_Amount_for_Manual_Approval',WOD_2__Unique_Rule_Name__c='ATI_Threshold_Amount_for_Manual_Approval',WOD_2__Value__c = '',WOD_2__Error_Type__c='Soft',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Summary',WOD_2__Type__c='Text',WOD_2__Display_Message__c='Total Requested Amount is greater than threshold amount.'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordIdRule,Name = 'ATI_Check_For_Pending_Approval_WR',WOD_2__Unique_Rule_Name__c='ATI_Check_For_Pending_Approval_WR',WOD_2__Value__c = '',WOD_2__Error_Type__c='Soft',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Summary',WOD_2__Type__c='Text',WOD_2__Display_Message__c='Claim cannot be submitted since warranty registration is pending for approval.'));

        //PriceFetch For Claim
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Price_Fetch_Type',WOD_2__Unique_Rule_Name__c='CLM_Price_Fetch_Type',WOD_2__Value__c = 'Custom',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Price_Fetch_Custom_Class',WOD_2__Unique_Rule_Name__c='CLM_Price_Fetch_Custom_Class',WOD_2__Value__c = 'ATI_CLM_PartPriceInterface',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Price Fetch',WOD_2__Type__c='Single Picklist'));
		
        //PoliyFetch For Claim
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_ClaimField_To_Be_Compare',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_ClaimField_To_Be_Compare',WOD_2__Value__c = 'WOD_2__Date_Of_Repair__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_WRStatus_To_Be_Compare',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_WRStatus_To_Be_Compare',WOD_2__Value__c = 'Registered',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Single Picklist'));        
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_Stock_Inv_Type',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_Stock_Inv_Type',WOD_2__Value__c = 'Stock',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_Retail_Inv_Type',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_Retail_Inv_Type',WOD_2__Value__c = 'Retail',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));        
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_Stock_Inv_RecordType',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_Stock_Inv_RecordType',WOD_2__Value__c = 'Stock',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_PolicyFetch_Retail_Inv_RecordType',WOD_2__Unique_Rule_Name__c='CLM_PolicyFetch_Retail_Inv_RecordType',WOD_2__Value__c = 'Retail',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Policy Fetch Logic',WOD_2__Type__c='Multi-Select Picklist'));        
        
        //RateFetch For Claim
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_TravelByDistance_Rate_Field',WOD_2__Unique_Rule_Name__c='CLM_TravelByDistance_Rate_Field',WOD_2__Value__c = 'WOD_2__Travel_By_Distance_Rate__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Rate Fetch',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_TravelByHours_Rate_Field',WOD_2__Unique_Rule_Name__c='CLM_TravelByHours_Rate_Field',WOD_2__Value__c = 'WOD_2__Travel_By_Hours_Rate__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Rate Fetch',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Labor_Rate_Field',WOD_2__Unique_Rule_Name__c='CLM_Labor_Rate_Field',WOD_2__Value__c = 'WOD_2__Labor_Rate__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Rate Fetch',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_RateFetch_ClaimField_To_Be_Compare',WOD_2__Unique_Rule_Name__c='CLM_RateFetch_ClaimField_To_Be_Compare',WOD_2__Value__c = 'WOD_2__Date_Of_Repair__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Rate Fetch',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Price_Fetch_ClaimField_Tobe_Compare',WOD_2__Unique_Rule_Name__c='CLM_Price_Fetch_ClaimField_Tobe_Compare',WOD_2__Value__c = 'WOD_2__Date_Of_Repair__c',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Rate Fetch',WOD_2__Type__c='Single Picklist'));
		
        //Manual Review Rules
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'Check_Cost_Category_Dollar_Limit',WOD_2__Unique_Rule_Name__c='Check_Cost_Category_Dollar_Limit',WOD_2__Value__c = '',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Text'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'ATI_RepairOrderPre_delivery',WOD_2__Unique_Rule_Name__c='ATI_RepairOrderPre_delivery',WOD_2__Value__c = '24',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Basic Info',WOD_2__Type__c='Single Picklist'));
        //Campaign Claim
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_FailureInfo_CC_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_FailureInfo_CC_FieldSet',WOD_2__Value__c = 'ATI_Campaign_FailureInfo_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Basic Info',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_BasicInfo_CT_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_BasicInfo_CT_Copy_FieldSet',WOD_2__Value__c = 'WOD_2__CLM_CT_COPY_FIELD_SET',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Basic Info',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_InstallPart_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_InstallPart_Section_Copy_FieldSet',WOD_2__Value__c = 'WOD_2__CLM_TemplateToClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_CC_RemoveParts_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_CC_RemoveParts_Section_Copy_FieldSet',WOD_2__Value__c = 'twodcms__CLM_TemplateToCampaignClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_CC_InstallPart_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_CC_InstallPart_Section_Copy_FieldSet',WOD_2__Value__c = 'twodcms__CLM_TemplateToCampaignClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_BasicInfo_CC_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_BasicInfo_CC_Copy_FieldSet',WOD_2__Value__c = 'twodcms__CLM_CC_BASICINFO_COPY_FIELDSET',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Add_RemovedPart_Aftr_InstallPart_Add',WOD_2__Unique_Rule_Name__c='CLM_Add_RemovedPart_Aftr_InstallPart_Add',WOD_2__Value__c = 'TRUE',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Boolean'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_RemoveParts_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_RemoveParts_Section_Copy_FieldSet',WOD_2__Value__c = 'WOD_2__CLM_TemplateToClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Parts',WOD_2__Type__c='Single Picklist'));
		
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_CC_Labor_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_CC_Labor_Section_Copy_FieldSet',WOD_2__Value__c = 'twodcms__CLM_TemplateToCampaignClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Labor',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Labor_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_Labor_Section_Copy_FieldSet',WOD_2__Value__c = 'WOD_2__CLM_TemplateToClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Labor',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_CC_OtherCost_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_CC_OtherCost_Section_Copy_FieldSet',WOD_2__Value__c = 'twodcms__CLM_TemplateToCampaignClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
		businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_OtherCost_Section_Copy_FieldSet',WOD_2__Unique_Rule_Name__c='CLM_OtherCost_Section_Copy_FieldSet',WOD_2__Value__c = 'WOD_2__CLM_TemplateToClaimCopy_FieldSet',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CA_ClaimFinalApprovalStatus',WOD_2__Unique_Rule_Name__c='CA_ClaimFinalApprovalStatus',WOD_2__Value__c = 'Approved',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Time_Travel',WOD_2__Unique_Rule_Name__c='CLM_Time_Travel',WOD_2__Value__c = '10',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Last_Labor_Submit_Date_exceeded',WOD_2__Unique_Rule_Name__c='CLM_Last_Labor_Submit_Date_exceeded',WOD_2__Value__c = '10',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
        businessConfigurationSettingList.add(new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Part_Quantity',WOD_2__Unique_Rule_Name__c='CLM_Part_Quantity',WOD_2__Value__c = '10',WOD_2__isActive__c = TRUE,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Type__c='Single Picklist'));
		
        return businessConfigurationSettingList; 
    }
    
    
    //Business Category Configuration Creation
    public static List<WOD_2__Business_Category_Configuration__c> createBusinessCategoryConfiguration(integer recordCount){
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigurationList = new List<WOD_2__Business_Category_Configuration__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Business_Category_Configuration__c businessCategoryConfigurationObject = new WOD_2__Business_Category_Configuration__c(Name = 'ATI');
            businessCategoryConfigurationList.add(businessCategoryConfigurationObject);
        }
        return businessCategoryConfigurationList;
    }
    
    public static List<Disable_Rules__c> createDisableRules() {
        List<Disable_Rules__c> newDisableRules = new List<Disable_Rules__c>();
        
        // For Account Object
        Disable_Rules__c disableAccountTriggers = new Disable_Rules__c();
        disableAccountTriggers.Name= 'PRPC_BranchCount';
        disableAccountTriggers.Disable__c = true;
        newDisableRules.add(disableAccountTriggers);
        insert newDisableRules;
        return newDisableRules;
        
    }    
    
    //Account Creation
    public static List<Account> createAccount(integer recordCount){
        createDisableRules();
        List<Account> lstAccount = new List<Account>();
        for(integer i=0; i<recordCount; i++) {
            Account acc = new Account(Name = 'Account'+ (i+1),AccountNumber = 'CD'+(i+1), WOD_2__Warranty_Account_Type__c='Dealer',
                                      BillingCity='New Jersey',BillingState='AL',BillingCountry='US',BillingStreet= (i+1)+'6TH Block',
                                      BillingPostalCode='56009'+i,Phone='123456789'+i,Fax='12345'+i,
                                      ShippingCity ='New Jersey',ShippingCountry ='US',ShippingState='AL',ShippingPostalCode='560095',
                                      Location_Type__c='test', SAP_ID__c='SAP_ID_'+ (i+1), Sales_RegionA__c='EMEA'
                                     );
            
            lstAccount.add(acc);
        }
        return lstAccount;
    }
    
    //Account Creation
    public static List<Account> createAccounts(integer recordCount, string dealerRecordType, string warrantyAccountType){
        createDisableRules();
        List<Account> lstAccount = new List<Account>();
        Id dealerRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(dealerRecordType).getRecordTypeId();
        for(integer i=0; i<recordCount; i++) {
            Account acc = new Account(Name = warrantyAccountType+(i+1),WOD_2__Warranty_Account_Type__c = warrantyAccountType,AccountNumber = 'CD'+(i+1),BillingCity='New Jersey',BillingState='LA',BillingCountry='US',BillingStreet='6TH Block',BillingPostalCode='560095',Phone='1234567890',Fax='12345',
                                      ShippingCity ='New Jersey',ShippingCountry ='US',ShippingState='AL',ShippingPostalCode='560095');
            lstAccount.add(acc);
        }
        return lstAccount;
    }
    
    //Inventory Creation
    public static List<WOD_2__Inventory__c> createInventory(integer recordCount){
        List<WOD_2__Inventory__c> lstInventory = new List<WOD_2__Inventory__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Inventory__c inv = new WOD_2__Inventory__c(Name = 'TestINV'+ (i+1),WOD_2__Serial_Number__c = 'TestSN-'+(i+1), WOD_2__Warranty_End_Date__c = Date.Today().addDays(45),WOD_2__Units_Usage__c = 4000+i);
            lstInventory.add(inv);
        }
        return lstInventory;
    }
    
    //Inventory Creation With RecordType - Added By Yamini(08th Jan 2021)
    public static List<WOD_2__Inventory__c> createInventoryWithRecordType(integer recordCount,String recordType){
        Id recordTypeId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        List<WOD_2__Inventory__c> lstInventory = new List<WOD_2__Inventory__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Inventory__c inv = new WOD_2__Inventory__c(Name = 'TestINV-'+(i+1),WOD_2__Serial_Number__c = 'TestINV-'+(i+1),WOD_2__Type__c=recordType,RecordTypeId=recordTypeId,
                                                              WOD_2__Manufacturing_Date__c=Date.today().addDays(-10),ATI_Program_Level__c='O');
            lstInventory.add(inv);
        }
        return lstInventory;
    }
    
    // //Account Creation
    // public static List<Account> createAccount(integer recordCount){
    //     List<Account> lstAccount = new List<Account>();
    //     for(integer i=0; i<recordCount; i++) {
    //         Account acc = new Account(Name = 'Account'+ (i+1),AccountNumber = 'CD'+(i+1), WOD_2__Warranty_Account_Type__c='Dealer',
    //                                   BillingCity='New Jersey',BillingState='AL',BillingCountry='US',BillingStreet='6TH Block',
    //                                   BillingPostalCode='560095',Phone='1234567890',Fax='12345',
    //                                   ShippingCity ='New Jersey',ShippingCountry ='US',ShippingState='AL',ShippingPostalCode='560095'
    //                                  );
    
    //         lstAccount.add(acc);
    //     }
    //     return lstAccount;
    // }
    
    //BCC Creation
    public static  WOD_2__Business_Category_Configuration__c createBcc (){
        WOD_2__Business_Category_Configuration__c bcc = new WOD_2__Business_Category_Configuration__c(Name = 'USA',WOD_2__Description__c='USA REGION');
        return bcc;
    }
    
    public static WOD_2__Warranty_Product__c createWarantyProduct(){
        WOD_2__Warranty_Product__c warrantyProduct= new     WOD_2__Warranty_Product__c(Name='casualPart',WOD_2__Item_Type__c = 'Part' ,WOD_2__Type__c='Item');
        return warrantyProduct;
    }
    
    public static List<WOD_2__Major_Component__c> createMajorComp(integer recordCount){
        List<WOD_2__Major_Component__c> majorCmpLst = new List<WOD_2__Major_Component__c>();
        for(integer i=0; i<recordCount; i++){
            WOD_2__Major_Component__c majorComp = new WOD_2__Major_Component__c(Name='BK5536N19260014E'+(i+1),WOD_2__Serial_number__c='BK5536N19260014E'+(i+1));
        	majorCmpLst.add(majorComp);
        }
        return majorCmpLst;
    }
    
    //Warranty Registration Creation
    public static List<WOD_2__Warranty_Registration__c> createWarrantyRegistration(integer recordCount){
        List<WOD_2__Warranty_Registration__c> lstWarrantyRegistration = new List<WOD_2__Warranty_Registration__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c(Name = 'TestWarranty Registration'+ (i+1),WOD_2__Registration_Date__c = Date.Today() - 30, WOD_2__Status__c = 'Registered');
            lstWarrantyRegistration.add(wr);
        }
        return lstWarrantyRegistration;
    }
    
    //Vocation Code Creation
    public static List<WOD_2__Warranty_Code__c> createVocationCode(integer recordCount, Boolean isInsert){
        Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Vocation Codes').getRecordTypeId();
        List<WOD_2__Warranty_Code__c> wrList = new List<WOD_2__Warranty_Code__c>();
        for(integer i=0; i<recordCount; i++){
            WOD_2__Warranty_Code__c vc = new WOD_2__Warranty_Code__c();
            vc.RecordTypeId = rtVCId;
            vc.name = 'UK0'+(i+1);
            vc.ATI_IsActive__c = true;
            wrList.add(vc);
        }
        if(isInsert && !wrList.isEmpty()){
            insert wrList;
            return wrList;
        }
        return wrList;
    }
    
    //Diagnostic Code Creation
    public static List<WOD_2__Warranty_Code__c> createDiagnosticCode(integer recordCount, Boolean isInsert){
        Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get('Diagnostics Codes').getRecordTypeId();
        
        List<WOD_2__Warranty_Code__c> wrList = new List<WOD_2__Warranty_Code__c>();
        for(integer i=0; i<recordCount; i++){
            WOD_2__Warranty_Code__c dc = new WOD_2__Warranty_Code__c();
            dc.RecordTypeId = rtVCId;
            dc.name = 'UK0'+(i+1);
            wrList.add(dc);
        }
        /*if(isInsert && !wrList.isEmpty()){
insert wrList;
return wrList;
}*/
        return wrList;
    }
    
    //Warranty Code Creation
    public static List<WOD_2__Warranty_Code__c> createWarrantyCode(integer recordCount, string recType){
        Id rtVCId = Schema.getGlobalDescribe().get('WOD_2__Warranty_Code__c').getDescribe().getRecordTypeInfosByName().get(recType).getRecordTypeId();
        List<WOD_2__Warranty_Code__c> wrList = new List<WOD_2__Warranty_Code__c>();
        for(integer i=0; i<recordCount; i++){
            WOD_2__Warranty_Code__c dc = new WOD_2__Warranty_Code__c();
            dc.RecordTypeId = rtVCId;
            dc.name = 'UK0'+(i+1);
            dc.ATI_IsActive__c=true;
            wrList.add(dc);
        }
        return wrList;
    }
    
    //Policy Defenition Creation
    public static List<WOD_2__Policy_Definition__c> createPolicyDefinition(integer recordCount){
        List<WOD_2__Policy_Definition__c> lstPolicyDefenition = new List<WOD_2__Policy_Definition__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Policy_Definition__c pd = new WOD_2__Policy_Definition__c(Name = 'PD'+ (i+1),WOD_2__Priority__c=(100+i),WOD_2__Months_Covered__c=12,WOD_2__Status__c = 'Active',
                                                                             WOD_2__Active_From__c = Date.today(), WOD_2__Active_Until__c = Date.today().addDays(365),WOD_2__Business_Units__c='ATI');
            lstPolicyDefenition.add(pd);
        }
        return lstPolicyDefenition;
    }
    
    //Policy OffSeason Record  Creation
    public static List<WOD_2__Policy_OffSeason__c> createPolicyOffSeasonRecord(integer recordCount){
        List<WOD_2__Policy_OffSeason__c> lstPolicyOffSeasonList = new List<WOD_2__Policy_OffSeason__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Policy_OffSeason__c pdOffSeason = new WOD_2__Policy_OffSeason__c(Name = 'OffSeasonTest'+ (i+1),WOD_2__isActive__c = false);
            lstPolicyOffSeasonList.add(pdOffSeason);
        }
        return lstPolicyOffSeasonList;
    }
    
    //Payment Definition creation
    public static List<WOD_2__Payment_Definitions__c> createPaymentDefinition(integer recordCount){
        List<WOD_2__Payment_Definitions__c> paymentDefinitionList=new List<WOD_2__Payment_Definitions__c>();
        for(integer i=0; i<recordCount; i++){
            WOD_2__Payment_Definitions__c paymentDefinitionObject =new WOD_2__Payment_Definitions__c(Name='Stock Policy Payment Definition'+(i+1),
                                                                                                     WOD_2__Is_Default__c = false, WOD_2__Status__c = null,WOD_2__Cost_Categories__c='Duty;Overtime;Labor;Travel By Distance;Misc Material;Freight;OEM Parts;Sublet;Towing;Tax;Parts');
            paymentDefinitionList.add(paymentDefinitionObject);
        }
        return paymentDefinitionList;
    }
    
    //ApplicabilityTerms Creation
    public static List<WOD_2__Applicability_Term__c> createApplicabilityTerms(integer recordCount,String type){
        List<WOD_2__Applicability_Term__c> lstApplicabilityTerms = new List<WOD_2__Applicability_Term__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Applicability_Term__c pd = new WOD_2__Applicability_Term__c(WOD_2__Applicability_Term_Type__c = type,WOD_2__Functionality__c = 'Warranty Registration',
                                                                               WOD_2__isCustomLogicalExpression__c=false,WOD_2__isValidExpression__c=true,WOD_2__Logical_Grouping__c = '1',WOD_2__Rule_Object_API_Name__c='WOD_2__Warranty_Registration__c');
            lstApplicabilityTerms.add(pd);
        }
        return lstApplicabilityTerms;
    }
    
    //ApplicabilityCriterias Creation
    public static List<WOD_2__Applicability_Criteria__c> createApplicabilityCriterias(integer recordCount,WOD_2__Applicability_Term__c at){
        List<WOD_2__Applicability_Criteria__c> lstApplicabilityCriterias = new List<WOD_2__Applicability_Criteria__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Applicability_Criteria__c pd = new WOD_2__Applicability_Criteria__c(Name='AC-000'+i,WOD_2__Applicability_Term__c=at.Id);
            lstApplicabilityCriterias.add(pd);
        }
        return lstApplicabilityCriterias;
    }
    
    //Warranty Coverage Creation
    public static List<WOD_2__Warranty_Coverages__c> createWarrantyCoverage(integer recordCount){
        List<WOD_2__Warranty_Coverages__c> lstWarrantyCoverage = new List<WOD_2__Warranty_Coverages__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c (Name = 'TestWC'+ (i+1),WOD_2__Warranty_Start_Date__c = Date.Today()- 365, WOD_2__Warranty_End_Date__c = Date.Today());
            lstWarrantyCoverage.add(wc);
        }
        return lstWarrantyCoverage;
    }
    
    //Warranty Product Item Type
    public static List<WOD_2__Warranty_Product__c> createWarrantyProductItem(integer recordCount){
        List<WOD_2__Warranty_Product__c> lstWarrantyProduct = new List<WOD_2__Warranty_Product__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Warranty_Product__c wp = new WOD_2__Warranty_Product__c(Name = 'TestWarrantyItem'+(i+1),WOD_2__Product_Name__c='TestWarrantyItem'+(i+1),WOD_2__Item_Type__c = 'Machine',
                                                                           WOD_2__Track_Type__c = 'Serialized',WOD_2__Type__c='Item',External_Product_Code__c='TestWarrantyItem'+(i+1),
                                                                           WOD_2__Description__c = 'Warranty Product Item Description');
            lstWarrantyProduct.add(wp);
        }
        return lstWarrantyProduct;
    }
    
    //Warranty Product upto 3 levels Creation
    public static List<WOD_2__Warranty_Product__c> createWarrantyProduct(integer recordCount){
        List<WOD_2__Warranty_Product__c> lstWarrantyProduct = new List<WOD_2__Warranty_Product__c>();
        WOD_2__Warranty_Product__c warrantyPro = new WOD_2__Warranty_Product__c(Name='Product', WOD_2__Product_Name__c='Product1',WOD_2__Type__c='Product', External_Product_Code__c='Product');
        lstWarrantyProduct.add(warrantyPro);
        WOD_2__Warranty_Product__c warrantyPro1=new WOD_2__Warranty_Product__c(Name='Model1', WOD_2__Product_Name__c='Model1',WOD_2__Type__c='Model', External_Product_Code__c='Model1');
        warrantyPro1.WOD_2__Parent_Product__c=warrantyPro.id;
        lstWarrantyProduct.add(warrantyPro1);
        for(integer i=2; i<recordCount; i++) {
            WOD_2__Warranty_Product__c wp = new WOD_2__Warranty_Product__c(Name = 'TestWarrantyItem'+ (i+1),WOD_2__Product_Name__c='TestWarrantyItem'+(i+1),WOD_2__Item_Type__c = 'Machine',
                                                                           WOD_2__Track_Type__c = 'Serialized',WOD_2__Type__c='Item',WOD_2__Parent_Product__c =  warrantyPro1.Id, External_Product_Code__c='TestWarrantyItem'+ (i+1),
                                                                           WOD_2__Description__c = 'Warranty Product Item Description');
            lstWarrantyProduct.add(wp);
        }
        return lstWarrantyProduct;
    }
    
    //policy Definition creation
    public static List<WOD_2__Policy_Definition__c> createPolicyDef(integer recordCount){
        List<WOD_2__Policy_Definition__c> lstPolicyDef=new List<WOD_2__Policy_Definition__c>();
        for(integer i=0; i<recordCount; i++)
        {
            WOD_2__Policy_Definition__c pd = new WOD_2__Policy_Definition__c(Name='Policy Definition'+(i+1), WOD_2__Priority__c = 15+i,WOD_2__Months_Covered__c=12);
            lstPolicyDef.add(pd);
        }
        return lstPolicyDef;
    }
    
    //standard policy Definition creation
    public static List<WOD_2__Policy_Definition__c> createStandardPolicyDef(integer recordCount){
        List<WOD_2__Policy_Definition__c> lstPolicyDef=new List<WOD_2__Policy_Definition__c>();
        for(integer i=0; i<recordCount; i++)
        {
            WOD_2__Policy_Definition__c pd=new WOD_2__Policy_Definition__c(Name='Policy Definition'+(i+1),WOD_2__Priority__c = 1, WOD_2__Type__c='Standard');
            lstPolicyDef.add(pd);
        }
        return lstPolicyDef;
    }
    
    
    //Group Member creation
    public static List<WOD_2__Group_Member__c> createGroupMember(integer recordCount,Id groupId){
        List<WOD_2__Group_Member__c> lstGroupMember=new List<WOD_2__Group_Member__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Group_Member__c gm=new WOD_2__Group_Member__c(Name='Group Member'+(i+1),WOD_2__Group__c = groupId);
            lstGroupMember.add(gm);
        }
        return lstGroupMember;
    }
    
    //Group creation
    public static List<WOD_2__Group__c> createGroup(integer recordCount){
        List<WOD_2__Group__c> lstGroup=new List<WOD_2__Group__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Group__c group1=new WOD_2__Group__c(Name='Group'+(i+1));
            lstGroup.add(group1);
        }
        return lstGroup;
    }
    //Questionaire Creation
    public static WOD_2__Questionnaire__c createQuestionnaire() {
        return new WOD_2__Questionnaire__c(
            Name='test ques',
            WOD_2__Object_Name__c='Inventory', WOD_2__Questionnaire_Guideline__c='abcd abcd',
            WOD_2__Questionnaire_Type__c='PDI'
        );
    }
    
    //ATI Account Creation
    public static List<Account> createATIDistributorAccount(Integer recordCount){
        createDisableRules();
        List<Account> lstAccount = new List<Account>();
        for(integer i=0; i<recordCount; i++) {
            Account acc = new Account(Name = 'TestDistributor'+ (i+1),AccountNumber = 'CD'+(i+1),WOD_2__Warranty_Account_Type__c='Dealer',BillingCity='WARREN',BillingState='Michigan',Type='Distributor',
                                      BillingCountry='United States',BillingStreet='24111 GROESBECK HWY.',BillingPostalCode='48089',ShippingStreet='24111 GROESBECK HWY.',ShippingCity ='WARREN',
                                      ShippingCountry ='United States',ShippingState='Michigan',ShippingPostalCode='48089',Location_Type__c='DLR',Sales_RegionA__c='North America',SAP_ID__c='02345'+(i+1),
                                      ATI_Price_Group__c='01',ATI_Account_Group__c='01',ATI_Customer_Group__c='05',ATI_Financial_BP_Code__c='BP_CODE_'+(i+1));
            
            lstAccount.add(acc);
        }
        return lstAccount;
    }
    
    //ATI Customer Account
    public static List<Account> createATICustomerAccount(Integer recordCount){
        createDisableRules();
        List<Account> lstAccount = new List<Account>();
        for(integer i=0; i<recordCount; i++) {
            Account acc = new Account(Name = 'TestCustomer'+ (i+1),AccountNumber = 'CD'+(i+1),WOD_2__Warranty_Account_Type__c='Customer',BillingCity='WARREN',BillingState='Michigan',Type='Customer',
                                      BillingCountry='United States',BillingStreet='24111 GROESBECK HWY.',BillingPostalCode='48089',ShippingStreet='24111 GROESBECK HWY.',ShippingCity ='WARREN',
                                      ShippingCountry ='United States',ShippingState='Michigan',ShippingPostalCode='48089',ATI_Customer_Group__c='EU99');
            
            lstAccount.add(acc);
        }
        return lstAccount;
    }
    
    //create User
    public static  List<User> createUser(integer recordCount){
        List<User> userList=new List<User>();
        for(Integer i=0;i<recordCount;i++){
            User userObj = new User(
                Username = System.now().millisecond() + 'unitTesting@tavant.com',
                Alias = 'test'+System.now().millisecond(),
                Email='unitTesting@tavant.com',
                EmailEncodingKey='UTF-8',
                Firstname='TWOD',
                Lastname='UnitTesting',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            userList.add(userObj);  
        }
        return userList;
    }
    
    //Contact Creation
    public static List<Contact> createContact(integer recordCount){
        List<Contact> contactList = new List<Contact>();
        for(integer i=0; i<recordCount; i++) {
            Contact contactObject = new Contact(LastName = 'TestContactLast'+(i+1));
            contactList.add(contactObject);
        }
        return contactList;
    }
    
    //Account Business Category Configuration Creation
    public static List<WOD_2__Account_Business_Category_Configuration__c> createAccountBusinessCategoryConfiguration(integer recordCount){
        List<WOD_2__Account_Business_Category_Configuration__c> lstAccBCC = new List<WOD_2__Account_Business_Category_Configuration__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Account_Business_Category_Configuration__c bcc = new WOD_2__Account_Business_Category_Configuration__c(Name = 'AccBCC'+ (i+1));
            lstAccBCC.add(bcc);
        }
        return lstAccBCC;
    }
    
    //warrranty defect code creation
    public static List<WOD_2__Warranty_Code__c> createFaultCode(integer recordCount){
        List<WOD_2__Warranty_Code__c> lstWarrantyCode=new List<WOD_2__Warranty_Code__c>();
        Id diagCode = Schema.SObjectType.WOD_2__Warranty_Code__c.getRecordTypeInfosByName().get('Diagnostics Codes').getRecordTypeId();
        Id id = [SELECT Id,Name FROM RecordType WHERE SObjectType='WOD_2__Warranty_Code__c' AND Name='Fault Code' LIMIT 1].Id;
        for(integer i=0; i<recordCount; i++) {
            
            WOD_2__Warranty_Code__c wc=new WOD_2__Warranty_Code__c(Name='FaultCode'+(i+1),RecordTypeId = id);
            lstWarrantyCode.add(wc);
        }
        return lstWarrantyCode;
    }
    
    //claim creation
    public static List<WOD_2__Claim__c> createClaim(integer recordCount){
        insert createWarrantyProduct(1);
        Id warrantyProdId =[Select Id From WOD_2__Warranty_Product__c limit 1].Id;
        //External_Product_Code__c
        Id accId= [Select Id From Account limit 1].Id;
        List<WOD_2__Claim__c> lstClaim=new List<WOD_2__Claim__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Claim__c claim=new WOD_2__Claim__c(Name='Claim'+(i+1),WOD_2__Work_Order__c = '12345',
                                                      WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProdId,WOD_2__Date_Of_Failure__c= Date.today(),
                                                      WOD_2__Model_Number__c=warrantyProdId,WOD_2__Date_Of_Repair__c=Date.today()+1);
            lstClaim.add(claim);
        }
        return lstClaim;
    }
    
   	//ExtendedWarrantyPricing Creation
    public static List<ATI_Extended_Warranty_Pricing__c> createExtendedWarrantyPricing(integer recordCount){
        List<ATI_Extended_Warranty_Pricing__c> ewpLst = new List<ATI_Extended_Warranty_Pricing__c>();
        for(Integer i=0; i<recordCount; i++){
            ATI_Extended_Warranty_Pricing__c ewp = new ATI_Extended_Warranty_Pricing__c(ATI_Program_Level__c='Test'+(i+1),ATI_Handling_Fee__c=50,ATI_Country__c='United States',
                                                                                        ATI_Base_Price__c=20,ATI_Active_From__c=Date.today(),ATI_Active_Until__c=Date.today().addDays(365));
            ewpLst.add(ewp);
        }
        return ewpLst;
    }
    
    //Labor RateDetails Creation
    public static List<WOD_2__Rates_Details__c> createLaborRateDetails(Integer recordCount){
        List<WOD_2__Rates_Details__c> laborRateDetailsLst = new List<WOD_2__Rates_Details__c>();
        Id lrRecordTypeId = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Labor_Rate').getRecordTypeId();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Rates_Details__c rd = new WOD_2__Rates_Details__c(Name='LaborRate_Test'+(i+1),RecordTypeId=lrRecordTypeId,WOD_2__Labor_Rate__c=10+(i+1),WOD_2__Rate_Type__c='Date Based',
                                                                     WOD_2__Rate_Sub_Type__c = 'Labor Rate',WOD_2__Status__c='Active');
            laborRateDetailsLst.add(rd);
        }
        return laborRateDetailsLst;
    }
    
    //Travel RateDetails Creation
    public static List<WOD_2__Rates_Details__c> createTravelRateDetails(Integer recordCount){
        List<WOD_2__Rates_Details__c> travelRateDetailsLst = new List<WOD_2__Rates_Details__c>();
        Id trRecordTypeId = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Travel_Rate').getRecordTypeId();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Rates_Details__c rd = new WOD_2__Rates_Details__c(Name='TravelRate_Test'+(i+1),RecordTypeId=trRecordTypeId,WOD_2__Travel_By_Distance_Rate__c=10+(i+1),
                                                                     WOD_2__Rate_Type__c='Date Based',WOD_2__Rate_Sub_Type__c = 'Travel Rate',WOD_2__Status__c='Active');
            travelRateDetailsLst.add(rd);
        }
        return travelRateDetailsLst;
    }
    
    //LandingCost RateDetails Creation
    public static List<WOD_2__Rates_Details__c> createLadingCostRateDetails(Integer recordCount){
        List<WOD_2__Rates_Details__c> lcRateDetailsLst = new List<WOD_2__Rates_Details__c>();
        Id lcRecordTypeId = Schema.SObjectType.WOD_2__Rates_Details__c.getRecordTypeInfosByDeveloperName().get('ATI_Landing_Cost_Rate').getRecordTypeId();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Rates_Details__c rd = new WOD_2__Rates_Details__c(Name='LandingCostRate_Test'+(i+1),RecordTypeId=lcRecordTypeId,ATI_Landing_Cost_Rate__c=10+(i+1),WOD_2__Rate_Type__c='Date Based',
                                                                     ATI_Landed_Cost_Markup__c=0.1+(i+1),WOD_2__Rate_Sub_Type__c = 'Landing Cost Rate',WOD_2__Status__c='Active',
                                                                     WOD_2__Active_From__c = Date.today(),WOD_2__Active_Until__c = Date.today().addDays(365));
            lcRateDetailsLst.add(rd);
        }
        return lcRateDetailsLst;
    }
    
    //ExchangeRate Creation
    public static List<ATI_Exchange_Rate__c> createExchangeRate(Integer recordCount){
        List<ATI_Exchange_Rate__c> exchangeRateLst = new List<ATI_Exchange_Rate__c>();
        for(Integer i=0; i<recordCount; i++){
            ATI_Exchange_Rate__c exchangeRate = new ATI_Exchange_Rate__c(RateType__c='A',FromCurrency__c='BRL',ToCurrency__c='USD',Rate__c=0.1+(i+1),
                                                                         EffectiveDate__c=Date.today(),EndDate__c=Date.today().addDays(365),Ratio__c=(i+1));
            exchangeRateLst.add(exchangeRate);
        }
        return exchangeRateLst;
    }
    
    //Transaction Memo History Creation
    public static List<WOD_2__Transaction_Memo_History__c> createTransactionMemo(Integer recordCount){
        List<WOD_2__Transaction_Memo_History__c> transacMemoList = new List<WOD_2__Transaction_Memo_History__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Transaction_Memo_History__c transacMemo = new WOD_2__Transaction_Memo_History__c(Name='Memo History'+i,WOD_2__Settlement_Type__c='Cheque');
            transacMemoList.add(transacMemo);
        }
        return transacMemoList;
    }
    
    //Transaction Memo History Line Item Creation
    public static List<WOD_2__Transaction_Memo_History_Line_Item__c> createTransactionMemoLineItem(Integer recordCount){
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec = new WOD_2__Transaction_Memo_History_Line_Item__c(Name='Line Item'+i,WOD_2__Quantity__c=1);
            lineItemList.add(lineItemRec);
        }
        return lineItemList;
    }
    
    //Batch Log Creation
    public static List<WOD_2__Batch_Log__c> createBatchLog(Integer recordCount){
        List<WOD_2__Batch_Log__c> batchLogList = new List<WOD_2__Batch_Log__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Batch_Log__c batchLogRec = new WOD_2__Batch_Log__c(ATI_Status__c='Queued');
            batchLogList.add(batchLogRec);
        }
        return batchLogList;
    }
    
    public static List<ATI_Extended_Warranty_Pricing__c> createExtWntyPricing(Integer recordCount, Id policyDefId ){
        List<ATI_Extended_Warranty_Pricing__c> extWntyPricingList = new List<ATI_Extended_Warranty_Pricing__c>();
        Date today = Date.today();
        Date activeFrom = today.addYears(-2);
        Date activeTill = today.addYears(3);
        for(Integer i=0; i < recordCount; i++){
            ATI_Extended_Warranty_Pricing__c ewp = 
                new ATI_Extended_Warranty_Pricing__c(ATI_Policy_Definition__c=policyDefId, ATI_Active_From__c= activeFrom,ATI_Active_Until__c=activeTill);
            extWntyPricingList.add(ewp);            
        }
        return extWntyPricingList;
    }
    
    
    //create VehicleInformation
    public static List<ATI_Vehicle_Information__c> createVehicleInformation(Integer recordCount){
        List<ATI_Vehicle_Information__c>  vehicleInfoLst = new  List<ATI_Vehicle_Information__c>();
        for(Integer i=0; i < recordCount; i++){
            ATI_Vehicle_Information__c vehicleInfo = new ATI_Vehicle_Information__c(Name='1J4GL58K96W180703',ATI_Vehicle_usage_mi_km_hr__c='Mi',ATI_Vehicle_Usage__c=10,ATI_Vehicle_Make__c='Allison',ATI_Vehicle_Model__c='VM-2020');
            vehicleInfoLst.add(vehicleInfo);
        }
        return vehicleInfoLst;
    }
    
    
    //Create WarrantyProductPriceBook
    public static List<WOD_2__Warranty_Product_Pricebook__c> createWarrantyProductPricebookForPartPrice(Integer recordCount,Id wpId){
        Id recordTypeId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Price').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wppLst = new List<WOD_2__Warranty_Product_Pricebook__c>();
        for(Integer i=0; i < recordCount; i++){
            WOD_2__Warranty_Product_Pricebook__c wpp = new WOD_2__Warranty_Product_Pricebook__c(Name='WPPTest'+(i+1),WOD_2__Valid_From__c=Date.today(),WOD_2__Valid_Until__c=Date.today().addDays(365),WOD_2__Warranty_Product__c=wpId,WOD_2__Price__c=10+(i+1),WOD_2__Unit_Price__c=10+(i+1),ATI_Price_Group__c='07',ATI_Unit_of_Measure__c='EA',RecordTypeId=recordTypeId,ATI_Active__c=true);
        	wppLst.add(wpp);
        }
        return wppLst;
    }
    
    //Create ServiceCampaign
    public static List<twodcms__Service_Campaign__c> createServiceCampaign(Integer recordCount,Id buId){
        List<twodcms__Service_Campaign__c> serviceCampaignLst = new  List<twodcms__Service_Campaign__c>();
        for(Integer i=0; i < recordCount; i++){
            twodcms__Service_Campaign__c serviceCampaign = new twodcms__Service_Campaign__c(Name='TestSC-'+(i+1),twodcms__Campaign_Description__c='TestSC-'+(i+1),twodcms__Start_Date__c=Date.today().addDays(-365),twodcms__End_Date__c=Date.today().addDays(365),twodcms__Status__c='Draft',twodcms__Campaign_Type__c='Field Modification',twodcms__Estimated_Budget__c=1000,twodcms__Business_Category_Configuration__c=buId);
        	serviceCampaignLst.add(serviceCampaign);
        }
        return serviceCampaignLst;
    }
    
    //Create CampaignMembers
    public static twodcms__Campaign_Members__c createCampaignMembers(Id invId,Id serviceCampId){
        twodcms__Campaign_Members__c campaignMember = new twodcms__Campaign_Members__c(Name = 'CMS-001',twodcms__Inventory__c=invId,twodcms__Service_Campaign__c=serviceCampId);
        return campaignMember;
    }
    
    //Create CampaignClaimTempAss
    public static twodcms__Campaign_Claim_Template_Association__c createCampaignClaimTempAss(Id claimTempId,Id serviceCampId,Id paymentDefId){
        twodcms__Campaign_Claim_Template_Association__c campaignClaimTempAss = new twodcms__Campaign_Claim_Template_Association__c(Name = 'CT-001',twodcms__Claim_Template__c=claimTempId,twodcms__Service_Campaign__c=serviceCampId,twodcms__Payment_Definitions__c=paymentDefId);
        return campaignClaimTempAss;
    }
    
     //claim creation - added by yamini
    public static List<WOD_2__Claim__c> createMachineClaim(integer recordCount){
        Id machineRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = new List<WOD_2__Claim__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='Claim'+(i+1),recordTypeId=machineRecordTypeId,WOD_2__Claim_Type__c='Machine',WOD_2__Date_Of_Repair__c=Date.today(),WOD_2__Date_Of_Failure__c= Date.today(),WOD_2__Units_Usage__c=(i+1));
            claimLst.add(claim);
        }
        return claimLst;
    }
    
    //claim removed part creation
    public static List<WOD_2__Removed_Claim_Part__c> createRemovedClaimPart(integer recordCount){
        List<WOD_2__Removed_Claim_Part__c>  lstRemoveClaimPart=new List<WOD_2__Removed_Claim_Part__c> ();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Removed_Claim_Part__c wcp=new WOD_2__Removed_Claim_Part__c(Name='RCP-'+(i+1),WOD_2__Invoice_Quantity__c = 1);
            lstRemoveClaimPart.add(wcp);
        }
        return lstRemoveClaimPart;
    }
    
    //Warehouse creation
    public static List<WOD_2__Warehouse__c> createWarehouse(integer recordCount){
        List<WOD_2__Warehouse__c> lstWarehouse=new List<WOD_2__Warehouse__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Warehouse__c war=new WOD_2__Warehouse__c(Name='Warehouse'+i,WOD_2__Address_Line_1__c='6 Edmondson Street', WOD_2__State_Province__c='Ontario',WOD_2__Phone__c='1234567890', 
                                                            WOD_2__Zip_Code__c='N3T 5N3',WOD_2__City__c='Brantford',WOD_2__Country__c='Canada');
            lstWarehouse.add(war);
        }
        return lstWarehouse;
        
    }
    
    //PRC Creation
    public static List<WOD_2__Part_Return_Configuration__c> createPartReturnConfiguration(integer recordCount){
        List<WOD_2__Part_Return_Configuration__c> prcLst = new List<WOD_2__Part_Return_Configuration__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Part_Return_Configuration__c prc = new WOD_2__Part_Return_Configuration__c(Name='PRC-'+(i+1),WOD_2__Applicable_From_Date__c=Date.today().addDays(-365),WOD_2__Applicable_To_Date__c=Date.today().addDays(365),WOD_2__Days_Due_Within__c=50,WOD_2__Max_Quantity_For_PRC__c=30,
                                                                                                                  WOD_2__Payment_Condition__c='Pay Without Return',WOD_2__Priority__c=i,WOD_2__IsActive__c=true);
            prcLst.add(prc);
        }
        return prcLst;
    }
    
    // installed parts creation
    public static List<WOD_2__Claim_Part__c> createInstalledParts(Integer recordCount){
        List<WOD_2__Claim_Part__c> claimInstallPartsList = new List<WOD_2__Claim_Part__c>();
        Id installedClaimPartRecordId = [SELECT ID FROM RecordType WHERE SobjectType = 'WOD_2__Claim_Part__c' AND DEVELOPERNAME = 'OEM_Installed_Parts' LIMIT 1].ID;
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Claim_Part__c installClaimPartObj = 
                new WOD_2__Claim_Part__c(Name = 'TestPartNumber' + (i + 1),WOD_2__Serial_Number__c='TEST-SN-00' + (i + 1),
                                         WOD_2__Invoice_Number__c = 'TEST-INV-00' + (i + 1),WOD_2__Unit_Price__c=100,
                                         WOD_2__Invoice_Quantity__c = 1,RecordTypeId = installedClaimPartRecordId
				);
	    	claimInstallPartsList.add(installClaimPartObj);
        }
		return claimInstallPartsList;         
    }
    
        // installed Claim Services
    public static List<WOD_2__Claim_Service_Information__c > createClaimServices(Integer recordCount){
        List<WOD_2__Claim_Service_Information__c> claimServicesList = new List<WOD_2__Claim_Service_Information__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Claim_Service_Information__c serviceInformation = 
                new WOD_2__Claim_Service_Information__c(Name='TerviceInformation'  + (i + 1),WOD_2__Additional_Labor_Hour__c=25,
					WOD_2__Reason_Additional_Labor_Hour__c='service inforamtion' +  + (i + 1),WOD_2__LaborRate__c=50,
					WOD_2__Labor_Rate__c=100,WOD_2__Total_Labor_Hours__c=35,WOD_2__Standard_Labor_Hour__c=10);
	    	claimServicesList.add(serviceInformation);
        }
		return claimServicesList;         
    }
    
    // other cost categories
    public static List<WOD_2__Other_Cost__c> createOtherCostCategoryItems(Integer recordCount){
        List<WOD_2__Other_Cost__c> otherCosts = new List<WOD_2__Other_Cost__c>();
        for(integer i=0; i<recordCount; i++) {
            WOD_2__Other_Cost__c oc = 
                new WOD_2__Other_Cost__c(Name='meals'+(i+1), WOD_2__Units_Usage__c=2,
                                         WOD_2__UnitsUsage__c=2,WOD_2__Rate_Per_Unit__c=67,WOD_2__Total_Cost__c=134,
                                         WOD_2__Cost_Category_Type__c='Meals'+(i+1));
            otherCosts.add(oc);
        }
		return otherCosts;
    }
    
    //Shipment creation
    public static List<WOD_2__Shipment_Detail__c> createShipments(integer recordCount){
        List<WOD_2__Shipment_Detail__c> shipmentLst = new List<WOD_2__Shipment_Detail__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Shipment_Detail__c shipmentObj = new WOD_2__Shipment_Detail__c(Name='Shipment'+i);
            shipmentLst.add(shipmentObj);
        }
        return shipmentLst;
    }
    
    //FaultCodeMappr Creation
    public static List<WOD_2__FaultCode_Mapper__c> createFaultCodeMappers(Integer recordCount,Id wpId){
         List<WOD_2__FaultCode_Mapper__c> faultCodeMapperLst = new List<WOD_2__FaultCode_Mapper__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__FaultCode_Mapper__c fcm = new WOD_2__FaultCode_Mapper__c(Name='fcm-'+(i+1),WOD_2__Status__c=true,WOD_2__Warranty_Product__c=wpId);
            faultCodeMapperLst.add(fcm);
        }
        return faultCodeMapperLst;
    }
    
    //VIN Transmission Mapper Creation
    public static List<ATI_VIN_Transmission_Mapper__c> createVinMappers(Integer recordCount,Id vehId){
         List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0; i<recordCount; i++){
            ATI_VIN_Transmission_Mapper__c vinMap = new ATI_VIN_Transmission_Mapper__c(Name='VinMapp'+(i+1),ATI_Vehicle_Information__c=vehId);
            vinMapperLst.add(vinMap);
        }
        return vinMapperLst;
    }
    
    //VIN Transmission Mapper Creation
    public static List<ATI_Disposition_Code_Mapper__c> createDispositionCodeMappers(Integer recordCount){
         List<ATI_Disposition_Code_Mapper__c> disCodeMapperLst = new List<ATI_Disposition_Code_Mapper__c>();
        for(Integer i=0; i<recordCount; i++){
            ATI_Disposition_Code_Mapper__c disCodeMapper = new ATI_Disposition_Code_Mapper__c(Name='DC-'+(i+1));
            disCodeMapperLst.add(disCodeMapper);
        }
        return disCodeMapperLst;
    }
    
    
    //PolicyDefinition Inv Usage
    public static List<WOD_2__Policy_Definition_Inventory_Usage__c> createPolicyDefUsage(Integer recordCount){
        List<WOD_2__Policy_Definition_Inventory_Usage__c> policyDefInvUsageLst = new List<WOD_2__Policy_Definition_Inventory_Usage__c>();
        for(Integer i=0; i<recordCount; i++){
            WOD_2__Policy_Definition_Inventory_Usage__c policyDefInvUsage = new WOD_2__Policy_Definition_Inventory_Usage__c(Name='PDIU-'+(i+1),WOD_2__Maximum_Unit__c=50000,WOD_2__Units_Of_Measure__c='mi',WOD_2__Usage_Reading_Type__c='Machine');
        	policyDefInvUsageLst.add(policyDefInvUsage);
        }
        return policyDefInvUsageLst;
    }
    
    /*public static List<ATI_Part_Markup__c> createPartMarkup(Integer recordCount){
        List<ATI_Part_Markup__c> partMarkupLst = new List<ATI_Part_Markup__c>();
        for(Integer i=0; i<recordCount; i++){
            ATI_Part_Markup__c partMarkup = new ATI_Part_Markup__c(ATI_Claim_Type__c='Machine',ATI_Customer_Group_Type__c='Service Dealer',
                                                                         ATI_Active_From__c=Date.today(),ATI_Active_Until__c=Date.today().addDays(365));
            partMarkupLst.add(partMarkup);
        }
        return partMarkupLst;
    }*/
}