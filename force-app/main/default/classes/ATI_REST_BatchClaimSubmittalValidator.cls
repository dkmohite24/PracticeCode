/* Name: ATI_REST_BatchClaimSubmittalValidator
Description : This Class is used to validate batchclaimsubmittal JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      08/02/2021        INITIAL DEVELOPMENT                             
*/
public with sharing class ATI_REST_BatchClaimSubmittalValidator {
    public List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> batchClaimSubmittalReqLst{get; private set;}
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation>> mapOfSuccessParts{get; private set;}
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData>> mapOfSuccessDiagnosticCodes{get; private set;}
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation>> mapOfSuccessLaborCodes{get; private set;}
    public Map<String,List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData>> mapOfSuccessNetItems{get; private set;}
    public Map<String,List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>> mapOfBatchClaimRelatedErrorInfo{get; private set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Map<String,WOD_2__Inventory__c> inventoryMap{get; private set;}
    public Map<String,string> invSeialNumMap{get; private set;}
    public Map<String,Account> accMap{get; private set;}
    public Map<String,WOD_2__Warranty_Product__c> warProdMap{get; private set;}
    public Map<String,WOD_2__Warranty_Code__c> warCodeMap{get; private set;}
    public Map<String,WOD_2__Claim__c> claimMap{get; private set;}
    //public Map<String,WOD_2__Warranty_Product_Pricebook__c> priceBookMap{get; private set;}
    public Map<String,List<WOD_2__Warranty_Product_Pricebook__c>> priceBookMap{get; private set;}//ALSN-45
    public Map<String,ATI_Exchange_Rate__c> exchangeRateMap{get; private set;}
    public Map<String,WOD_2__Financial_Line_Item__c> financialLineItemMap{get; private set;}
    public Map<string,WOD_2__Rates_Details__c> rateMap{get; private set;}
    public set<string> excludedCodeSet{get; private set;}
    public set<string> primaryCodeSet{get; private set;}
    public Map<string,string> buMap{get; private set;}
    public Map<string,WOD_2__Major_Component__c> majorCompMap{get; private set;}
    public Map<String,WOD_2__Claim__c> claimIdMap{get; private set;}
    public Set<String> setOfCurrencies{get; private set;}
    public Set<Date> setOfRepairOrderOpenDates{get; private set;}
    public static ATI_Usage_Codes__mdt usageCodesMdt{get; private set;}
    public static Set<String> modelNumberSet{get; private set;}
    public static Map<String,WOD_2__FaultCode_Mapper__c> mapOfLaborCodeWithFaultCodeMapper{get; private set;}
    public static Set<String> serviceCampaignSet{get; private set;}
    public static Set<String> campaignTemplateSet{get; private set;}
    public Map<String,twodcms__Campaign_Claim_Template_Association__c> mapOfKeyWithCampaignClaimTempAss{get; private set;}
    public Integer totalRecords;
    public Map<String, String> countryMap{get; set;}
    public ATI_REST_BatchClaimSubmittalValidator(){
        batchClaimSubmittalReqLst = new List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation>();
        mapOfSuccessParts = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation>>();
        mapOfSuccessDiagnosticCodes = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData>>();
        mapOfSuccessLaborCodes = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation>>();
        mapOfSuccessNetItems = new Map<String,List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData>>();
        mapOfBatchClaimRelatedErrorInfo = new Map<String,List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>>();
        mapOfFailure = new Map<Integer,List<String>>();
        majorCompMap = new Map<string,WOD_2__Major_Component__c>();
        buMap = new Map<string,string>();
        claimMap = new Map<String,WOD_2__Claim__c>();
        claimIdMap = new Map<String,WOD_2__Claim__c>();
        inventoryMap = new Map<String,WOD_2__Inventory__c>();
        invSeialNumMap = new Map<String,string>();
        accMap = new Map<String,Account>();
        warProdMap = new Map<String,WOD_2__Warranty_Product__c>();
        exchangeRateMap = new Map<String,ATI_Exchange_Rate__c>();
        warCodeMap = new Map<String,WOD_2__Warranty_Code__c>();
        //priceBookMap = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
        priceBookMap = new Map<String,List<WOD_2__Warranty_Product_Pricebook__c>>();//ALSN-45
        financialLineItemMap = new Map<String,WOD_2__Financial_Line_Item__c>();
        primaryCodeSet = new set<string>();
        excludedCodeSet = new set<string>();
        rateMap = new Map<string,WOD_2__Rates_Details__c>();
        setOfCurrencies = new Set<String>();
        setOfRepairOrderOpenDates = new Set<Date>();
        usageCodesMdt = new ATI_Usage_Codes__mdt();
        modelNumberSet = new Set<String>();
        mapOfLaborCodeWithFaultCodeMapper = new Map<String,WOD_2__FaultCode_Mapper__c>();
        serviceCampaignSet = new Set<String>();
        campaignTemplateSet = new Set<String>();
        countryMap = ATI_UTILS.getPicklistOptions('Account', 'ATI_Billing_Country__c');
        mapOfKeyWithCampaignClaimTempAss = new Map<String,twodcms__Campaign_Claim_Template_Association__c>();
        totalRecords = 0;
    }
    
    public void validateReqest(ATI_REST_BatchClaimSubmittalRequest batchClaimSubmittalRequestBody){
        queryCustomerMasterData(batchClaimSubmittalRequestBody);
        verifyBatchClaimSubmittalRequest(batchClaimSubmittalRequestBody);
    }
    
    private void queryCustomerMasterData(ATI_REST_BatchClaimSubmittalRequest batchClaimSubmittalRequestBody){
        set<String> serialNumSet = new set<String>();
        set<String> repairOutletSet = new set<String>();
        set<String> warProdSet = new set<String>();
        set<String> warCodeSet = new set<String>();
        set<String> fcWarCodeSet = new set<String>();//ALSN-45        
        Set<String> customerNameSet = new Set<String>();
        Set<String> customerCitySet = new Set<String>();
        Set<String> customerPostalSet = new Set<String>();
        Set<String> vocationCode = new Set<String>();
        Set<String> claimNumSet = new Set<String>();
        Set<String> trackingNumberSet = new Set<String>();
        Set<String> priceGroupSet = new Set<String>();
        Set<String> laborCodeSet = new Set<String>();
        Set<String> buSet = new Set<String>();
        Set<String> majorCompSerialNumSet = new Set<String>();
        for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : batchClaimSubmittalRequestBody.claim){
            if(!String.isBlank(claimInfo.serialNumber)){
                serialNumSet.add(claimInfo.serialNumber.trim());
            }
            if(!String.isBlank(claimInfo.businessCategoryConfiguration)){
                buSet.add(claimInfo.businessCategoryConfiguration.trim());
            }
            if(!String.isBlank(claimInfo.claimType)){
                if(!claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                    if(!String.isBlank(claimInfo.failureCode)){
                        warCodeSet.add(claimInfo.failureCode.trim());
                    }
                    if(!String.isBlank(claimInfo.complaintCode)){
                        System.debug('claimInfo.complaintCode--->'+claimInfo.complaintCode);
                        warCodeSet.add(claimInfo.complaintCode.trim());
                    } 
                    if(!String.isBlank(claimInfo.replacementUnitSerialNumber)){
                        serialNumSet.add(claimInfo.replacementUnitSerialNumber.trim());
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.vehicleInfo.vocationCode)){
                        warCodeSet.add(claimInfo.registrationInfo.vehicleInfo.vocationCode.trim());
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.customerName)){
                        customerNameSet.add(claimInfo.registrationInfo.customerInfo.customerName);
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.city)){
                        customerCitySet.add(claimInfo.registrationInfo.customerInfo.city);
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.postalCode)){
                        customerPostalSet.add(claimInfo.registrationInfo.customerInfo.postalCode);
                    }
                }else{
                    if(ATI_Utils.checkIsNotBlankData(claimInfo.specialActivityCode)){
                        serviceCampaignSet.add(claimInfo.specialActivityCode);
                    }
                    if(ATI_Utils.checkIsNotBlankData(claimInfo.campaignTemplateName)){
                        campaignTemplateSet.add(claimInfo.campaignTemplateName);
                    }
                    //Added by Anjali
                    if(!String.isBlank(claimInfo.failureCode)){
                        warCodeSet.add(claimInfo.failureCode.trim());
                    }
                    if(!String.isBlank(claimInfo.complaintCode)){
                        System.debug('claimInfo.complaintCode--->'+claimInfo.complaintCode);
                        warCodeSet.add(claimInfo.complaintCode.trim());
                    } 
                    //End 
                    //ALSN-101
                    if(!String.isBlank(claimInfo.registrationInfo.vehicleInfo.vocationCode)){
                        warCodeSet.add(claimInfo.registrationInfo.vehicleInfo.vocationCode.trim());
                    }
                    //ALSN-210 checking if customer account already exists to avoid duplicate account insertion
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.customerName)){
                        customerNameSet.add(claimInfo.registrationInfo.customerInfo.customerName);
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.city)){
                        customerCitySet.add(claimInfo.registrationInfo.customerInfo.city);
                    }
                    if(!String.isBlank(claimInfo.registrationInfo.customerInfo.postalCode)){
                        customerPostalSet.add(claimInfo.registrationInfo.customerInfo.postalCode);
                    }
                    // end of Alsn-210
                }
            }
            if(!String.isBlank(claimInfo.repairOutlet)){
                repairOutletSet.add(claimInfo.repairOutlet.trim());
            }
            if(!String.isBlank(claimInfo.repairOrderOpenDate)){
                setOfRepairOrderOpenDates.add(ATI_Utils.parseDate(claimInfo.repairOrderOpenDate.trim()));
            }
            if(!String.isBlank(claimInfo.primaryFailedPart)){
                warProdSet.add(claimInfo.primaryFailedPart.trim());
            }
            if((claimInfo.submittalIndicator == 'M'  || claimInfo.submittalIndicator == 'A') && 
               !String.isBlank(claimInfo.claimNumber) && !String.isBlank(claimInfo.trackingNumber)){
                   claimNumSet.add(claimInfo.claimNumber.trim());
                   trackingNumberSet.add(claimInfo.trackingNumber.trim());   
               }
            for(ATI_REST_BatchClaimSubmittalRequest.PartsInformation partsInfo : claimInfo.serviceParts) {
                if(!String.isBlank(partsInfo.replacedPartNumber)){
                    warProdSet.add(partsInfo.replacedPartNumber.trim());
                }
                if(!String.isBlank(partsInfo.failedPartNumber)){
                    warProdSet.add(partsInfo.failedPartNumber.trim());
                }
                if(!String.isBlank(partsInfo.failedPartSerialNumber)){
                    majorCompSerialNumSet.add(partsInfo.failedPartSerialNumber.trim());
                }
                if(!String.isBlank(partsInfo.replacementPartSerialNumber)){
                    majorCompSerialNumSet.add(partsInfo.replacementPartSerialNumber.trim());
                }
            }
            
            for(ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData diagnosticCodeInfo : claimInfo.diagnosticCodes) {
                if(!String.isBlank(diagnosticCodeInfo.diagnosticCode)){
                    warCodeSet.add(diagnosticCodeInfo.diagnosticCode.trim());
                }
            }
            
            for(ATI_REST_BatchClaimSubmittalRequest.LaborInfomation laborInfo : claimInfo.laborCodes) {
                if(!String.isBlank(laborInfo.laborOperationCode)){
                    warCodeSet.add(laborInfo.laborOperationCode.trim());
                }
                if(!String.isBlank(laborInfo.laborOperationCode)){
                    laborCodeSet.add(laborInfo.laborOperationCode.trim());
                }
            }
        }
        
        String warProdSObjName = 'WOD_2__Warranty_Product__c';
        List<String> warProdFields = new List<String>{'WOD_2__Track_Type__c','WOD_2__Units_Of_Measure__c','WOD_2__Description__c','WOD_2__Type__c','WOD_2__Item_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper warProdNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(warProdSObjName,warProdFields);
        
        if(!repairOutletSet.isEmpty() || (!customerNameSet.isEmpty() && !customerCitySet.isEmpty() && !customerPostalSet.isEmpty())){
            String accSObjName = 'Account';
            List<String> accFields = new List<String>{'PRP_Participation__c','WOD_2__Warranty_Account_Type__c','ATI_Currency__c','ATI_Price_Group__c','Name','BillingCity','BillingPostalCode','SAP_ID__c','BillingCountry','ATI_Primary_Email_Id__c'};
                ATI_Utils.NoAccessObjectFieldWrapper accNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(accSObjName,accFields);
            if(accNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && accNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0){
                //ALSN-146 ATI_Exchange_Rate_Type__c added
                //ALSN-166 added BillingStreet, BillingState, Phone in the query
                for(Account accRec : [SELECT id,ATI_Exchange_Rate_Type__c,PRP_Participation__c,WOD_2__Warranty_Account_Type__c,ATI_Currency__c,ATI_Price_Group__c,Name,BillingStreet,BillingState,Phone,BillingCity,BillingPostalCode,SAP_ID__c,BillingCountry,ATI_Primary_Email_Id__c FROM Account WHERE (Name IN: customerNameSet AND BillingCity IN: customerCitySet AND BillingPostalCode IN: customerPostalSet) OR SAP_ID__c IN : repairOutletSet]){
                    if(accRec.WOD_2__Warranty_Account_Type__c == 'Customer'){
                        accMap.put(accRec.Name+accRec.BillingCity+accRec.BillingPostalCode,accRec);
                    }
                    else{
                        accMap.put(accRec.SAP_ID__c,accRec);
                        if(accRec.ATI_Currency__c != 'USD'){
                            setOfCurrencies.add(accRec.ATI_Currency__c);
                        }
                        priceGroupSet.add(accRec.ATI_Price_Group__c);
                    }
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(accNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
            
            if(!repairOutletSet.isEmpty()){
                List<String> rateFields = new List<String>{'RecordtypeId','WOD_2__Travel_By_Distance_Rate__c','WOD_2__Active_From__c','WOD_2__Active_Until__c','WOD_2__Dealer__c','WOD_2__Status__c','WOD_2__Labor_Rate__c'};
                    ATI_Utils.NoAccessObjectFieldWrapper rateNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Rates_Details__c',rateFields);
                if(rateNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && rateNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
                    for(WOD_2__Rates_Details__c rateRec : [SELECT Id,WOD_2__Dealer__c,WOD_2__Travel_By_Distance_Rate__c,Recordtype.Name,WOD_2__Labor_Rate__c from WOD_2__Rates_Details__c where Recordtype.Name IN ('Travel Rate','Labor Rate') AND WOD_2__Dealer__r.SAP_ID__c IN : repairOutletSet AND WOD_2__Active_From__c<=:system.today() AND WOD_2__Active_Until__c>=:system.today() AND WOD_2__Status__c = 'Active']){
                        rateMap.put(rateRec.WOD_2__Dealer__c+rateRec.Recordtype.Name,rateRec); 
                    } 
                }else{
                    String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(rateNoAccessObjectFieldWrapper);
                    ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
                }
            }
        }
        
        if(!setOfRepairOrderOpenDates.isEmpty() && !setOfCurrencies.isEmpty()){
            //ALSN-117
            List<String> exchangeRateFields = new List<String>{'FromCurrency__c','Rate__c','ToCurrency__c','EffectiveDate__c','EndDate__c','Value__c'};
                ATI_Utils.NoAccessObjectFieldWrapper exchangeNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('ATI_Exchange_Rate__c',exchangeRateFields);
            if(exchangeNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && exchangeNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
                //ALSN-146 Rate Type added
                for(ATI_Exchange_Rate__c exchangeRate : [SELECT id, FromCurrency__c,Rate__c,RateType__c,ToCurrency__c,EffectiveDate__c,EndDate__c,Value__c
                                                         FROM ATI_Exchange_Rate__c  WHERE EffectiveDate__c <=: setOfRepairOrderOpenDates AND EndDate__c >=: setOfRepairOrderOpenDates AND FromCurrency__c IN:setOfCurrencies AND ToCurrency__c='USD']){
                                                             exchangeRateMap.put(exchangeRate.FromCurrency__c+exchangeRate.ToCurrency__c+exchangeRate.RateType__c,exchangeRate); 
                                                         }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(exchangeNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        if(!buSet.isEmpty()){
            List<String> buFields = new List<String>{'Name'};
                ATI_Utils.NoAccessObjectFieldWrapper buNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Business_Category_Configuration__c',buFields);
            if(buNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && buNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
                for(WOD_2__Business_Category_Configuration__c buRec : [SELECT id, Name FROM WOD_2__Business_Category_Configuration__c WHERE Name IN :buSet]){
                    buMap.put(buRec.Name,buRec.Id); 
                } 
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(buNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        if(!serialNumSet.isEmpty()){
            String invSObjName = 'WOD_2__Inventory__c';
            List<String> invFields = new List<String>{'WOD_2__Scrapped__c','ATI_Warranty_Void__c','ATI_Active__c','WOD_2__Account__c','ATI_Vocation_Code__c','WOD_2__Install_Date__c','WOD_2__Manufacturing_Date__c','WOD_2__Type__c','WOD_2__Serial_Number__c','WOD_2__Business_Unit__c','WOD_2__Item__c'};
                ATI_Utils.NoAccessObjectFieldWrapper invNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(invSObjName,invFields);
            List<String> wrfieldList = new List<String>{'ATI_Pre_Delivery__c','WOD_2__Account__c','ATI_Vocation_Code__c','WOD_2__Warranty_Product__c','WOD_2__Registration_Date__c','WOD_2__Status__c','WOD_2__Customer__c','WOD_2__Registration_Comments__c','WOD_2__Registration_Type__c','WOD_2__Usage_Type__c','WOD_2__Account__c','WOD_2__Units_Usage__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wrUpdateAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', wrfieldList);
            if(wrUpdateAccess.noAccessObjectList.size() == 0 && wrUpdateAccess.noAccessFieldList.size() == 0 && invNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && invNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(WOD_2__Inventory__c invRec : [SELECT id,WOD_2__Scrapped__c,ATI_Warranty_Void__c,ATI_Active__c,WOD_2__Account__c,WOD_2__Type__c,WOD_2__Serial_Number__c,WOD_2__Business_Unit__c,WOD_2__Item__c,WOD_2__Item__r.WOD_2__Description__c,WOD_2__Item__r.Extended_Base_Model__c,WOD_2__Item__r.WOD_2__Parent_Product__c,
                                                  (Select id,ATI_Pre_Delivery__c,WOD_2__Account__c,WOD_2__Inventory__c,ATI_Vocation_Code__c,WOD_2__Warranty_Product__c,WOD_2__Registration_Date__c,WOD_2__Status__c,WOD_2__Customer__c,
                                                   WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,WOD_2__Units_Usage__c,WOD_2__Inventory__r.WOD_2__Type__c,WOD_2__Install_Date__c from WOD_2__Warranty_Registration__r 
                                                   WHERE WOD_2__Registration_Type__c = 'Standard Registration' AND ((WOD_2__Status__c='Draft' AND WOD_2__Inventory__r.WOD_2__Type__c ='Stock') OR (WOD_2__Status__c IN('Registered','Pending Warranty Processor Approval','In Progress') AND WOD_2__Inventory__r.WOD_2__Type__c ='Retail')) ORDER BY CreatedDate DESC Limit 1),
                                                  (SELECT Id,ATI_Vehicle_Information__c,ATI_Inventory__c,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c,ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Engine_Make__c,ATI_Vehicle_Information__r.ATI_Engine_Model__c,
                                                   ATI_Vehicle_Information__r.ATI_Engine_Year__c,ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c,ATI_Vehicle_Information__r.ATI_Vocation_Code__c FROM Transmissions__r ORDER BY CreatedDate DESC Limit 1)
                                                  FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN : serialNumSet AND ATI_Warranty_Void__c=false
                                                  AND WOD_2__Scrapped__c=false AND ATI_Active__c=true]){
                                                      inventoryMap.put(invRec.WOD_2__Serial_Number__c,invRec);
                                                      modelNumberSet.add(invRec.WOD_2__Item__r.WOD_2__Parent_Product__c);
                                                      invSeialNumMap.put(invRec.Id,invRec.WOD_2__Serial_Number__c);
                                                  }//Alsn-174 added extended base model in query
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(invNoAccessObjectFieldWrapper)+' '+JSON.serialize(wrUpdateAccess)+' '+JSON.serialize(warProdNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        usageCodesMdt = [Select ATI_Usage_Codes__c,DeveloperName from ATI_Usage_Codes__mdt where DeveloperName='ATI_VIN_Usage_Codes'];
        
        if(!majorCompSerialNumSet.isEmpty()){
            List<String> majorCompFields = new List<String>{'WOD_2__Serial_number__c','WOD_2__Warranty_Product__c'};
                ATI_Utils.NoAccessObjectFieldWrapper majorCompNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Major_Component__c',majorCompFields);
            if(majorCompNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && majorCompNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ){                
                for(WOD_2__Major_Component__c majorCompRec : [SELECT Id,WOD_2__Warranty_Product__r.Name,WOD_2__Serial_number__c,WOD_2__Warranty_Product__c FROM WOD_2__Major_Component__c where WOD_2__Serial_number__c IN :majorCompSerialNumSet AND WOD_2__Warranty_Product__r.WOD_2__Item_Type__c='Part' AND WOD_2__Warranty_Product__r.WOD_2__Track_Type__c='Serialized']){
                    majorCompMap.put(majorCompRec.WOD_2__Serial_number__c,majorCompRec);
                    warProdSet.add(majorCompRec.WOD_2__Warranty_Product__r.Name);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(majorCompNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        Set<string> warProdIdSet = new Set<string>();
        if(!warProdSet.isEmpty()){
            if(warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(WOD_2__Warranty_Product__c warProdRec : [SELECT id,Name,WOD_2__Track_Type__c,WOD_2__Units_Of_Measure__c,WOD_2__Description__c,WOD_2__Type__c,WOD_2__Item_Type__c FROM WOD_2__Warranty_Product__c WHERE Name IN : warProdSet]){
                    warProdMap.put(warProdRec.Name,warProdRec);
                    if(warProdRec.WOD_2__Type__c=='Item' && warProdRec.WOD_2__Item_Type__c == 'Part'){
                        warProdIdSet.add(warProdRec.Id);
                    }
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(warProdNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        if(!priceGroupSet.isEmpty() && !warProdIdSet.isEmpty()){
            //ALSN-45
            List<WOD_2__Warranty_Product_Pricebook__c>warrantyPriceBookList = New List<WOD_2__Warranty_Product_Pricebook__c>();//ALSN-45
            List<String> priceBookFields = new List<String>{'WOD_2__Unit_Price__c','WOD_2__Valid_From__c','WOD_2__Valid_Until__c','ATI_Price_Group__c','WOD_2__Warranty_Product__c'};
                ATI_Utils.NoAccessObjectFieldWrapper priceBookNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Product_Pricebook__c',priceBookFields);
            if(priceBookNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && priceBookNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
                //ALSN-45 query Name also
                for(WOD_2__Warranty_Product_Pricebook__c wpPriceBook : [SELECT id, Name, WOD_2__Unit_Price__c, WOD_2__Valid_From__c, WOD_2__Valid_Until__c, WOD_2__Warranty_Product__c, ATI_Price_Group__c FROM WOD_2__Warranty_Product_Pricebook__c 
                                                                        WHERE WOD_2__Warranty_Product__c IN :warProdIdSet AND ATI_Price_Group__c IN :priceGroupSet AND RecordType.Name = 'Part Price' AND ATI_Active__c = true]){
                                                                            warrantyPriceBookList.add(wpPriceBook);
                                                                            //priceBookMap.put(wpPriceBook.WOD_2__Warranty_Product__c,wpPriceBook); 
                                                                            //ALSN-45
                                                                            priceBookMap.put(wpPriceBook.WOD_2__Warranty_Product__c,warrantyPriceBookList);
                                                                        } 
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(priceBookNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        if(!laborCodeSet.isEmpty() && !modelNumberSet.isEmpty()){
            List<String> faultCodeMapperFields = new List<String>{'WOD_2__Code__c','WOD_2__Code__r.Name'};
                ATI_Utils.NoAccessObjectFieldWrapper faultCodeMapperNoAccessWrapper = ATI_Utils.fetchReadAccess('WOD_2__FaultCode_Mapper__c',faultCodeMapperFields);
            if(faultCodeMapperNoAccessWrapper.noAccessObjectList.size() == 0 && faultCodeMapperNoAccessWrapper.noAccessFieldList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                //ALSN-45 fetch WOD_2__Code__c value
                for(WOD_2__FaultCode_Mapper__c fcm : [SELECT Id,WOD_2__Code__c,WOD_2__Code__r.Name 
                                                      FROM WOD_2__FaultCode_Mapper__c 
                                                      WHERE WOD_2__Code__r.Name in :laborCodeSet AND WOD_2__Status__c=true AND WOD_2__Code__r.RecordType.DeveloperName='Job_Code' AND WOD_2__Code__r.ATI_IsActive__c=true
                                                      AND WOD_2__Group__c IN (SELECT WOD_2__Group__c FROM WOD_2__Group_Member__c WHERE WOD_2__Warranty_Product__c IN :modelNumberSet)]){
                                                          mapOfLaborCodeWithFaultCodeMapper.put(fcm.WOD_2__Code__r.Name,fcm);
                                                          fcWarCodeSet.add(fcm.WOD_2__Code__c);//ALSN-45 creating a set of correct warranty code ids
                                                      }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(faultCodeMapperNoAccessWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        //ALSN-45 moving this method below fault mapper fetch to use their WOD_2__Code__c to fetch correct warranty codes
        if(!warCodeSet.isEmpty()){
            String warCodeSObjName = 'WOD_2__Warranty_Code__c';
            List<String> warCodeFields = new List<String>{'ATI_Time_Studied__c','Name','RecordTypeId','ATI_IsActive__c','WOD_2__Standard_Labor_Hour__c','WOD_2__Standard_Labor_Minutes__c'};
                ATI_Utils.NoAccessObjectFieldWrapper warCodeNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(warCodeSObjName,warCodeFields);
            if(warCodeNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warCodeNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                //ALSN-45 added a condition to use warranty code from fault mapper
                for(WOD_2__Warranty_Code__c warCodeRec : [SELECT id,ATI_Time_Studied__c,WOD_2__Standard_Labor_Hour__c,Name,WOD_2__Standard_Labor_Minutes__c,RecordType.Name,ATI_IsActive__c FROM WOD_2__Warranty_Code__c WHERE Name IN : warCodeSet AND ID IN : fcWarCodeSet]){
                    warCodeMap.put(warCodeRec.Name+warCodeRec.RecordType.Name,warCodeRec);
                }
                //ALSN-45 for other warranty codes except for labor codes
                for(WOD_2__Warranty_Code__c warCodeRec : [SELECT id,ATI_Time_Studied__c,WOD_2__Standard_Labor_Hour__c,Name,WOD_2__Standard_Labor_Minutes__c,RecordType.Name,ATI_IsActive__c FROM WOD_2__Warranty_Code__c WHERE Name IN : warCodeSet AND RecordType.Name != 'Job Code' ]){
                    warCodeMap.put(warCodeRec.Name+warCodeRec.RecordType.Name,warCodeRec);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(warCodeNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        } 
        
        if(!claimNumSet.isEmpty() && !trackingNumberSet.isEmpty()){
            Set<String> otherCostSet = new Set<String>();
            Set<String> partSet = new Set<String>();
            for(WOD_2__Claim__c claimRec : [SELECT id,WOD_2__Inventory__r.Name,ATI_Identifier__c,WOD_2__Date_Of_Failure__c,ATI_BatchClaim_Error_Messages__c,WOD_2__Account__r.Public_Group_Id__c,ATI_Tracking_Number__c,WOD_2__Work_Order__c,WOD_2__Work_Performed_Comments__c,Name,ATI_Account_Email__c,
                                            WOD_2__Claim_Status__c,CurrencyIsoCode,WOD_2__Account__r.SAP_ID__c,ATI_Submittal_Indicator__c,WOD_2__Account__c,WOD_2__Rate__r.WOD_2__Travel_By_Distance_Rate__c,WOD_2__Rate__r.WOD_2__Labor_Rate__c,WOD_2__Inventory__c,WOD_2__BusinessCategory__c,WOD_2__Degradation_Modifier__c,
                                            (SELECT id,WOD_2__Claim__c,WOD_2__Warranty_Product__r.Name FROM WOD_2__Claim_Parts__r),
                                            (SELECT id,WOD_2__Claim__c,WOD_2__Warranty_Product__r.Name FROM WOD_2__Removed_Claim_Parts__r),
                                            (SELECT id,Claim__c,Warranty_Code__r.Name FROM Diagnostic_Codes__r),
                                            (SELECT id,WOD_2__Claim__c,WOD_2__Service_Job_Code__r.Name FROM WOD_2__Claim_Service_Informations__r),
                                            (SELECT id,WOD_2__Claim__c,WOD_2__Cost_Category_Type__c FROM WOD_2__Other_Costs__r) FROM WOD_2__Claim__c WHERE Name IN : claimNumSet AND ATI_Tracking_Number__c IN:trackingNumberSet]){
                                                claimMap.put(claimRec.Name,claimRec);   
                                                claimIdMap.put(claimRec.Name,claimRec);  
                                                for(WOD_2__Claim_Part__c partRec : claimRec.WOD_2__Claim_Parts__r){
                                                    partSet.add(partRec.Id);
                                                }
                                                for(WOD_2__Other_Cost__c otherCostRec : claimRec.WOD_2__Other_Costs__r){
                                                    otherCostSet.add(otherCostRec.Id);
                                                }
                                            }
            List<String> lineItemFields = new List<String>{'WOD_2__Installed_Claim_Part__c','WOD_2__Approved_Quantity__c','WOD_2__Other_Cost__c','WOD_2__Requested_Quantity__c'};
                ATI_Utils.NoAccessObjectFieldWrapper lineItemNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('WOD_2__Financial_Line_Item__c',lineItemFields);
            if(lineItemNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && lineItemNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warProdNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(WOD_2__Financial_Line_Item__c lineItemRec : [SELECT Id,WOD_2__Installed_Claim_Part__c,WOD_2__Approved_Quantity__c,WOD_2__Other_Cost__c,WOD_2__Requested_Quantity__c FROM WOD_2__Financial_Line_Item__c WHERE WOD_2__Other_Cost__c in :otherCostSet OR WOD_2__Installed_Claim_Part__c in :partSet]){
                    if(lineItemRec.WOD_2__Other_Cost__c!=null){
                        financialLineItemMap.put(lineItemRec.WOD_2__Other_Cost__c,lineItemRec);
                    }
                    if(lineItemRec.WOD_2__Installed_Claim_Part__c!=null){
                        financialLineItemMap.put(lineItemRec.WOD_2__Installed_Claim_Part__c,lineItemRec);
                    }
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(lineItemNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
        
        if(!serviceCampaignSet.isEmpty() && !campaignTemplateSet.isEmpty()){
            List<String> campaignClaimTempAssFields = new List<String>{'twodcms__Service_Campaign__r.Name','twodcms__Claim_Template__r.Name','twodcms__Claim_Template__c','twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__c','twodcms__Claim_Template__r.WOD_2__Causal_Part_Description__c','twodcms__Claim_Template__r.WOD_2__Comments__c','twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__r.WOD_2__Track_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper campaignClaimTempNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('twodcms__Campaign_Claim_Template_Association__c',campaignClaimTempAssFields);
            if(campaignClaimTempNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && campaignClaimTempNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                List<twodcms__Campaign_Claim_Template_Association__c> campaignClaimTemplateAssLst = [SELECT Id,twodcms__Service_Campaign__r.Name,twodcms__Claim_Template__r.Name,twodcms__Claim_Template__c,twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__c,twodcms__Claim_Template__r.WOD_2__Causal_Part_Description__c,twodcms__Claim_Template__r.WOD_2__Comments__c,twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__r.WOD_2__Track_Type__c FROM twodcms__Campaign_Claim_Template_Association__c WHERE twodcms__Service_Campaign__r.Name IN:serviceCampaignSet AND twodcms__Claim_Template__r.Name IN:campaignTemplateSet AND twodcms__Service_Campaign__r.twodcms__Status__c='Active']; 
                for(twodcms__Campaign_Claim_Template_Association__c campaignClaimTemp : campaignClaimTemplateAssLst){
                    mapOfKeyWithCampaignClaimTempAss.put(campaignClaimTemp.twodcms__Service_Campaign__r.Name+'-'+campaignClaimTemp.twodcms__Claim_Template__r.Name,campaignClaimTemp);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+JSON.serialize(campaignClaimTempNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('ClaimSubmittalRequest',errortext);
            }
        }
    }
    
    public void verifyBatchClaimSubmittalRequest(ATI_REST_BatchClaimSubmittalRequest batchClaimSubmittalRequestBody){
        Integer  i = 1;
        Set<String> identifierSet = new Set<String>();
        List<String> trackDuplicate = new List<String>(); 
        Set<String> trackingNumberSets = new Set<String>();
        //Added by ALSN-97 line numbers 432,435
        Set<String> serialNumberSets = new Set<String>();
        //Alsn - 169
        Set<String> serviceCampaignSets = new Set<String>();
        for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : batchClaimSubmittalRequestBody.claim){
            trackingNumberSets.add(claimInfo.trackingNumber.trim());
            serialNumberSets.add(claimInfo.serialNumber.trim());
            serviceCampaignSets.add(claimInfo.specialActivityCode.trim());
        }
        for(WOD_2__Claim__c wc : [SELECT ATI_Tracking_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Claim__c WHERE ATI_Tracking_Number__c 
                                  in: trackingNumberSets]){
                                      trackDuplicate.add(wc.ATI_Tracking_Number__c+'_'+wc.WOD_2__Account__r.SAP_ID__c);
                                  }
        //Added by ALSN-97 line number 442
        //Alsn - 169 added service campaign check
        list<twodcms__Campaign_Members__c> cMembers = [SELECT Id, twodcms__Inventory__r.Name,twodcms__Service_Campaign__r.Name  FROM twodcms__Campaign_Members__c where twodcms__Inventory__r.WOD_2__Serial_Number__c IN: serialNumberSets and twodcms__Service_Campaign__r.Name IN:serviceCampaignSets LIMIT 1]; 	            
        Set<String> trackingNumberSAPIdSetTemp = new Set<String>();
        for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : batchClaimSubmittalRequestBody.claim){
            List<String> errorLst = new List<String>();
            List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation> claimRelatedInfoLst = new List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>();
            string billingCountryVal = '';
            Account accRec = new Account();
            
            // Added by Anjali for 27609
            
            if(ATI_Utils.checkIsBlankData(claimInfo.repairOrder)){
                errorLst.add('Repair Order is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.technicianName)){
                errorLst.add('Technician Name is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.complaintCode)){
                errorLst.add('Complaint code is mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.failureCode)){
                errorLst.add('Failure code is mandatory');
            } 
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.street)){
                errorLst.add('Street is mandatory.');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.countryCode)){
                errorLst.add('Country Code is mandatory.');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.city)){
                errorLst.add('City is mandatory.');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.state)){
                errorLst.add('State is mandatory.');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.postalCode)){
                errorLst.add('Postal Code is mandatory.');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.preDelivery)){
                errorLst.add('Pre delivery is Mandatory');
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vocationCode) && claimInfo.registrationInfo.vehicleInfo.preDelivery=='false'){
                errorLst.add('VocationCode is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber)){
                errorLst.add('VehicleIdentificationNumber is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleMileage) &&
               claimInfo.registrationInfo.vehicleInfo.preDelivery=='false'){
                   errorLst.add('VehicleMileage is Mandatory');
               }
            
            if(claimInfo.registrationInfo.vehicleInfo.preDelivery=='false'){
                if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.usageUnit) 
                  ){
                      errorLst.add('UsageUnit is Mandatory');
                  }
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleMake)){
                errorLst.add('VehicleMake is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleModel)){
                errorLst.add('VehicleModel is Mandatory');
            }
            
            if(ATI_Utils.checkIsBlankData(claimInfo.WorkPerformedComments)){
                errorLst.add('WorkPerformedComments is Mandatory');
            }
            
            
            if(ATI_Utils.checkIsBlankData(claimInfo.primaryFailedPart)){
                errorLst.add('PrimaryFailedPart is Mandatory');
            }
            else if(!warProdMap.containsKey(claimInfo.primaryFailedPart.trim())){
                errorLst.add('PrimaryFailedPart is Invalid'); 
            }
            else if(warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Track_Type__c == 'Serialized' && ATI_Utils.checkIsBlankData(claimInfo.primaryFailedPartSerialNumber)){
                errorLst.add('PrimaryFailedPartSerialNumber is mandatory for serialized PrimaryFailedPart'); 
            }
            
            // End of modification
            //Add by Dishari for WOD_2__Pre_Authorization_Reason__c,Pre-Authorization Comments validation
            Map<String,String> mapOfPreAuth = New Map<String,String>(ATI_Utils.getPicklistOptions('WOD_2__Claim__c','WOD_2__Pre_Authorization_Reason__c'));
            if(claimInfo.preAuthorizationRequired != null && Boolean.valueOf(claimInfo.preAuthorizationRequired)) {
                System.debug('------------entereee'+claimInfo.preAuthorizationRequired);
                if(mapOfPreAuth.isEmpty() || !(mapOfPreAuth.containsKey(claimInfo.preAuthorizationReason) || mapOfPreAuth.values().Contains(claimInfo.preAuthorizationReason))){
                    errorLst.add('Pre-Authorization Reason is blank or not valid');
                } 
                if(String.isBlank(claimInfo.preAuthorizationComments)){
                    errorLst.add('Pre-Authorization Comments is Mandatory');
                }
            }
            //End here  for WOD_2__Pre_Authorization_Reason__c, Pre-Authorization Comments validation
            
            //Added by Dishari for Bug-27850-I211 on 08/25/21
            if(ATI_Utils.checkIsNotBlankData(claimInfo.registrationInfo.vehicleInfo.inServiceDate) && ATI_Utils.parseDate(claimInfo.repairOrderOpenDate) < ATI_Utils.parseDate(claimInfo.registrationInfo.vehicleInfo.inServiceDate)){
                errorLst.add('Repair Order Open Date less than Inservice Date');
            }
            if(ATI_Utils.checkIsNotBlankData(claimInfo.registrationInfo.vehicleInfo.inServiceDate) && ATI_Utils.parseDate(claimInfo.laborLastAppliedDate) < ATI_Utils.parseDate(claimInfo.registrationInfo.vehicleInfo.inServiceDate)){
                errorLst.add('Last Labor Applied Date less than Inservice Date');
            }
            //Ended here Dishari for Bug-27850-I211 on 08/25/21
            
            if(String.isBlank(claimInfo.identifier)){
                errorLst.add('Identifier is Mandatory');
            }
            else if(!identifierSet.add(claimInfo.identifier.trim())){
                errorLst.add('Identifier is not unique');
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.businessCategoryConfiguration)){
                errorLst.add('BusinessCategoryConfiguration is Mandatory');
            }
            else if(!buMap.containsKey(claimInfo.businessCategoryConfiguration.trim())){
                errorLst.add('BusinessCategoryConfiguration is Invalid');
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.trackingNumber)){
                errorLst.add('TrackingNumber is Mandatory');
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.submittalIndicator)){
                errorLst.add('SubmittalIndicator is Mandatory');
            }else if(claimInfo.submittalIndicator == 'M' || claimInfo.submittalIndicator == 'A'){
                if(ATI_Utils.checkIsBlankData(claimInfo.claimNumber)){
                    errorLst.add('ClaimNumber is Mandatory for SubmittalIndicator '+claimInfo.submittalIndicator);
                }else if(!claimMap.containsKey(claimInfo.claimNumber.trim())){
                    errorLst.add('ClaimNumber is Invalid');
                }else{
                    WOD_2__Claim__c claim = claimMap.get(claimInfo.claimNumber.trim());
                    if(claimInfo.serialNumber != '' && claimInfo.serialNumber.trim() != claim.WOD_2__Inventory__r.Name){
                        errorLst.add('SerialNumber is not matching');
                    }
                }
            }
            //Added by ALSN-97
            if(cMembers.size() == 0 && claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                errorLst.add('8033-SN not eligible for specified campaign');
            }
            //ALSN-97 Ended
            if(ATI_Utils.checkIsBlankData(claimInfo.repairOutlet)){
                errorLst.add('RepairOutlet is Mandatory');
            }
            else if(!accMap.containsKey(claimInfo.repairOutlet.trim())){
                errorLst.add('RepairOutlet is Invalid'); 
            }
            else{
                accRec = accMap.get(claimInfo.repairOutlet.trim());
                billingCountryVal = accRec.BillingCountry;
                if(!ATI_Utils.checkIsBlankData(claimInfo.trackingNumber)){
                    if(trackDuplicate.contains(claimInfo.trackingNumber.trim()+'_'+claimInfo.repairOutlet.trim()) && (claimInfo.SubmittalIndicator=='I' || claimInfo.SubmittalIndicator=='C')){
                        errorLst.add('Duplicate Tracking Number is found');
                    }else if(!errorLst.contains('ClaimNumber is Invalid') && !trackDuplicate.contains(claimInfo.trackingNumber.trim()+'_'+claimInfo.repairOutlet.trim()) && claimInfo.SubmittalIndicator !='I' && claimInfo.SubmittalIndicator !='C'){
                        errorLst.add('Tracking Number is not matching');
                    }else if(trackingNumberSAPIdSetTemp.contains(claimInfo.trackingNumber.trim()+'_'+claimInfo.repairOutlet.trim())){
                        errorLst.add('Tracking number is duplicated in json');
                    }
                    trackingNumberSAPIdSetTemp.add(claimInfo.trackingNumber.trim()+'_'+claimInfo.repairOutlet.trim());
                }
            }
            if(claimInfo.submittalIndicator == 'A' && claimMap.containsKey(claimInfo.claimNumber.trim())){
                WOD_2__Claim__c claimRec = claimMap.get(claimInfo.claimNumber.trim());
                if(!claimRec.WOD_2__Claim_Status__c.equalsIgnoreCase('Paid') && 
                   !claimRec.WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected')){
                       errorLst.add('Amend is not allowed on this claim');
                   }
            }
            //Alsn-193 -- avoid editing claims other than Draft
            if(claimInfo.submittalIndicator == 'M' && claimMap.containsKey(claimInfo.claimNumber.trim())){
                WOD_2__Claim__c claimRec = claimMap.get(claimInfo.claimNumber.trim());
                if(!claimRec.WOD_2__Claim_Status__c.equalsIgnoreCase('Draft')){
                       errorLst.add('Editing is only allowed on Draft claims');
                   }
            }
            //end of Alsn-193
            if((claimInfo.submittalIndicator == 'I' || claimInfo.submittalIndicator == 'C') && ATI_Utils.checkIsNotBlankData(claimInfo.claimNumber)){
                errorLst.add('ClaimNumber should be blank on initial claim submission');
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.repairOrderOpenDate)){
                errorLst.add('RepairOrderOpenDate is Mandatory');
            }else{
                if(ATI_Utils.parseDate(claimInfo.repairOrderOpenDate.trim()) == null){
                    errorLst.add('Invalid RepairOrderOpenDate Format');
                }
                //Added by Anjali for 27609 
                else if(Date.valueOf(claimInfo.repairOrderOpenDate) > System.today()){
                    errorLst.add('RepairOrderOpenDate should not be greater than today');
                }
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.laborLastAppliedDate)){
                errorLst.add('LaborLastAppliedDate is Mandatory');
            }else{
                if(ATI_Utils.parseDate(claimInfo.laborLastAppliedDate.trim()) == null){
                    errorLst.add('Invalid LaborLastAppliedDate Format');
                }
                //Added by Anjali for 27609 
                else if(Date.valueOf(claimInfo.laborLastAppliedDate) > System.today()){
                    errorLst.add('LaborLastAppliedDate should not be greater than today');
                }
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.serialNumber)){
                errorLst.add('SerialNumber is Mandatory');
            }else{
                if(!inventoryMap.containsKey(claimInfo.serialNumber.trim())){
                    errorLst.add('SerialNumber is Invalid'); 
                }
            }
            if(ATI_Utils.checkIsBlankData(claimInfo.claimType)){
                errorLst.add('ClaimType is Mandatory');
                
                //Added By Anjali
                mapOffailure.put(i,errorLst);
            }else{
                if(!claimInfo.claimType.trim().equalsIgnoreCase('Machine') && !claimInfo.claimType.trim().equalsIgnoreCase('Part') && !claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                    errorLst.add('ClaimType is Invalid');
                }else{
                    //Machine and Part Validation
                    if(!claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                        if(claimInfo.claimType.trim().equalsIgnoreCase('Machine')){
                            if(ATI_Utils.checkIsNotBlankData(claimInfo.serviceReplacementIndicator) && ATI_Utils.checkIsNotBlankData(claimInfo.serialNumber)){
                                if(claimInfo.serviceReplacementIndicator.trim() != 'SWING' && claimInfo.serviceReplacementIndicator.trim() != 'RETRAN'){
                                    errorLst.add('ServiceReplacementIndicator is Invalid');
                                }
                                if(ATI_Utils.checkIsBlankData(claimInfo.replacementUnitSerialNumber)){
                                    errorLst.add('ReplacementUnitSerialNumber is Mandatory');
                                }else if(!inventoryMap.containsKey(claimInfo.replacementUnitSerialNumber.trim())){
                                    errorLst.add('ReplacementUnitSerialNumber is Invalid'); 
                                }else{ 
                                    if(claimInfo.replacementUnitSerialNumber.trim().equalsIgnoreCase(claimInfo.serialNumber.trim())){
                                        errorLst.add('ReplacementUnitSerialNumber cannot be same as SerialNumber');
                                    }
                                }
                            }
                        }
                        if(claimInfo.claimType.trim().equalsIgnoreCase('Part')){
                            if(ATI_Utils.checkIsBlankData(claimInfo.dateOfPurchase)){
                                errorLst.add('DateOfPurchase is Mandatory');
                            }
                        }
                        
                        /*   if(ATI_Utils.checkIsBlankData(claimInfo.primaryFailedPart)){
errorLst.add('PrimaryFailedPart is Mandatory');
}
else if(!warProdMap.containsKey(claimInfo.primaryFailedPart.trim())){
errorLst.add('PrimaryFailedPart is Invalid'); 
}
else if(warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Track_Type__c == 'Serialized' && ATI_Utils.checkIsBlankData(claimInfo.primaryFailedPartSerialNumber)){
errorLst.add('PrimaryFailedPartSerialNumber is mandatory for serialized PrimaryFailedPart'); 
} */
                        if(!ATI_Utils.checkIsBlankData(claimInfo.complaintCode)){
                            if(!warCodeMap.containsKey(claimInfo.complaintCode.trim()+'Complaint Codes')){
                                errorLst.add('ComplaintCode is Invalid'); 
                            }
                        }
                        if(!ATI_Utils.checkIsBlankData(claimInfo.failureCode)){
                            if(!warCodeMap.containsKey(claimInfo.failureCode.trim()+'Fault Code')){
                                errorLst.add('FailureCode is Invalid'); 
                            }
                        }
                        if(inventoryMap.containsKey(claimInfo.serialNumber.trim()) && inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Type__c != 'Retail'){
                            // if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber)){ 
                            if(!ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber)){    
                                //   errorLst.add('VehicleIdentificationNumber is Mandatory'); 
                                //} 
                                // else{ 
                                boolean usageCodeCondition = true;  
                                if(!ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vocationCode)){   
                                    usageCodeCondition = (!usageCodesMdt.ATI_Usage_Codes__c.contains(claimInfo.registrationInfo.vehicleInfo.vocationCode)); 
                                }  
                                //ALSN-96 Vijay Changes : null check if condition added
                                if(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber.trim() != null && billingCountryVal != null){
                                    if((billingCountryVal.equalsIgnoreCase('United States') ||  billingCountryVal.equalsIgnoreCase('US') || billingCountryVal.equalsIgnoreCase('USA')) && usageCodeCondition && !ATI_VehicleInformationController.checkRegex(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber.trim())){   
                                        errorLst.add('Invalid VehicleIdentificationNumber');    
                                    } 
                                }
                                
                            }   
                            // } 
                            /*  if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleMake)){   
errorLst.add('VehicleMake is Mandatory');   
}   
if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleModel)){    
errorLst.add('VehicleModel is Mandatory');  
} */
                            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleMileage)){
                                errorLst.add('VehicleMileage is Mandatory');
                            }
                            
                            if(!ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.usageUnit)){
                                //  errorLst.add('UsageUnit is Mandatory');
                                // }else if(!claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('mi') && !claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('km') && !claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('hrs')){
                                if(!claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('mi') && !claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('km') && !claimInfo.registrationInfo.vehicleInfo.usageUnit.equalsIgnoreCase('hrs')){
                                    errorLst.add('UsageUnit is Invalid');
                                } 
                            }         
                            
                            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.inServiceDate)){
                                if(claimInfo.registrationInfo.vehicleInfo.preDelivery=='false'){
                                    errorLst.add('InServiceDate is Mandatory');
                                }
                            }
                            else{
                                if(ATI_Utils.parseDate(claimInfo.registrationInfo.vehicleInfo.inServiceDate.trim()) == null){
                                    errorLst.add('Invalid InServiceDate Format');
                                }else{
                                    if(claimInfo.registrationInfo.vehicleInfo.preDelivery == 'true'){
                                        errorLst.add('InServiceDate should be empty for Pre-Delivery');
                                    }
                                    if(ATI_Utils.parseDate(claimInfo.registrationInfo.vehicleInfo.inServiceDate) > System.today()){
                                        errorLst.add('InServiceDate should not be greater than today');
                                    }
                                }
                            }
                            /*   if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vocationCode) && claimInfo.registrationInfo.vehicleInfo.preDelivery=='false'){
errorLst.add('VocationCode is Mandatory');
} */
                            if(!ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.vehicleInfo.vocationCode)){
                                if(warCodeMap.containsKey(claimInfo.registrationInfo.vehicleInfo.vocationCode.trim()+'Vocation Codes')){
                                    if(!warCodeMap.get(claimInfo.registrationInfo.vehicleInfo.vocationCode.trim()+'Vocation Codes').ATI_IsActive__c)
                                        errorLst.add('VocationCode is InActive'); 
                                }else{
                                    errorLst.add('VocationCode is Invalid'); 
                                }
                            }
                            if(ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.customerName)){
                                errorLst.add('CustomerName is Mandatory');
                            } //db
                            //Added by Anjali for Country code check
                            if(!ATI_Utils.checkIsBlankData(claimInfo.registrationInfo.customerInfo.countryCode)){
                                if(!countryMap.containsKey(claimInfo.registrationInfo.customerInfo.countryCode.toUpperCase()) && 
                                   !countryMap.values().contains(claimInfo.registrationInfo.customerInfo.countryCode.toUpperCase())){
                                       errorLst.add('CountryCode is invalid.');
                                   }
                            }
                        }
                        if(accMap.containsKey(claimInfo.repairOutlet.trim()) && accMap.get(claimInfo.repairOutlet.trim()).PRP_Participation__c){
                            // Added by ALSN-73
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeCustomerRequestedService)){
                                //errorLst.add('DateTimeCustomerRequestedService is Mandatory');
                            }else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeCustomerRequestedService.trim()) == null){
                                    errorLst.add('Invalid DateTimeCustomerRequestedService Format');
                                }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeCustomerRequestedService).date() > System.today()){
                                    errorLst.add('DateTimeCustomerRequestedService should not be greater than today');
                                }
                            }
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeDistributorScheduledService)){
                                //errorLst.add('DateTimeDistributorScheduledService is Mandatory');
                            }else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeDistributorScheduledService.trim()) == null){
                                    errorLst.add('Invalid DateTimeCustomerRequestedService Format');
                                }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeDistributorScheduledService).date() > System.today()){
                                    errorLst.add('DateTimeDistributorScheduledService should not be greater than today');
                                }
                            } 
                            // Ended ALSN-73
                            // ALSN-69
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeOfVehicleArrival)){
                                errorLst.add('DateTimeOfVehicleArrival is Mandatory');
                            }
                            else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeOfVehicleArrival.trim()) == null){
                                    errorLst.add('Invalid DateTimeOfVehicleArrival Format');
                                }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeOfVehicleArrival).date() > System.today()){
                                    errorLst.add('DateTimeOfVehicleArrival should not be greater than today');
                                }
                            }
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeRepairOrderClosed)){
                                errorLst.add('DateTimeRepairOrderClosed is Mandatory');
                            }else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeRepairOrderClosed.trim()) == null){
                                    errorLst.add('Invalid DateTimeRepairOrderClosed Format');
                                }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeRepairOrderClosed).date() > System.today()){
                                    errorLst.add('DateTimeRepairOrderClosed should not be greater than today');
                                }  
                            }
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeCustomerNotified)){
                                errorLst.add('DateTimeCustomerNotified is Mandatory');
                            }
                            else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeCustomerNotified.trim()) == null){
                                    errorLst.add('Invalid DateTimeCustomerNotified Format');
                                }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeCustomerNotified).date() > System.today()){
                                    errorLst.add('DateTimeCustomerNotified should not be greater than today');
                                }
                            }
                            if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.repairOrderOpenDateTime)){
                                errorLst.add('RepairOrderOpenDateTime is Mandatory');
                            }else{
                                if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.repairOrderOpenDateTime.trim()) == null
                                   && claimInfo.turnAroundData.repairOrderOpenDateTime.containsWhitespace()){
                                       errorLst.add('Invalid RepairOrderOpenDateTime Format');
                                   }/*else if(Datetime.valueOf(claimInfo.turnAroundData.repairOrderOpenDateTime).date() > System.today()){
errorLst.add('RepairOrderOpenDateTime should not be greater than today');
}*/
                            }
                            
                            //ALSN-69 Labor check
                            if(claimInfo.laborCodes.size()>0){
                                if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeLaborFirstApplied)){
                                    errorLst.add('DateTimeLaborFirstApplied is Mandatory');
                                }
                                else{
                                    if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeLaborFirstApplied.trim()) == null){
                                        errorLst.add('Invalid DateTimeLaborFirstApplied Format');
                                    }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeLaborFirstApplied).date() > System.today()){
                                        errorLst.add('DateTimeLaborFirstApplied should not be greater than today');
                                    }
                                }
                                if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied)){
                                    errorLst.add('DateTimeLaborLastRecordedOrApplied is Mandatory');
                                }else{
                                    if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied.trim()) == null 
                                       && claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied.containsWhitespace()){
                                           errorLst.add('Invalid DateTimeLaborLastRecordedOrApplied Format');
                                       } /*else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied).date() > System.today()){
errorLst.add('DateTimeLaborLastRecordedOrApplied should not be greater than today');
}  */
                                }
                            }
                            // Labor check end
                            
                            //ALSN-69 Parts check
                            if(claimInfo.serviceParts.size() > 0){
                                if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeFirstPartOrdered)){
                                    errorLst.add('DateTimeFirstPartOrdered is Mandatory');
                                }
                                else{
                                    if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeFirstPartOrdered.trim()) == null){
                                        errorLst.add('Invalid DateTimeFirstPartOrdered Format');
                                    }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeFirstPartOrdered).date() > System.today()){
                                        errorLst.add('DateTimeFirstPartOrdered should not be greater than today');
                                    }
                                }
                                if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.dateTimeLastPartArrived)){
                                    errorLst.add('DateTimeLastPartArrived is Mandatory');
                                }else{
                                    if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.dateTimeLastPartArrived.trim()) == null){
                                        errorLst.add('Invalid DateTimeLastPartArrived Format');
                                    }else if(Datetime.valueOf(claimInfo.turnAroundData.dateTimeLastPartArrived).date() > System.today()){
                                        errorLst.add('DateTimeLastPartArrived should not be greater than today');
                                    }
                                }
                            }
                            //Parts check end
                            
                            /*if(ATI_Utils.checkIsBlankData(claimInfo.turnAroundData.customerAuthorizeWorkDateOrTime)){
errorLst.add('CustomerAuthorizeWorkDateOrTime is Mandatory');
}else{
if(ATI_Utils.parseDateTime(claimInfo.turnAroundData.customerAuthorizeWorkDateOrTime.trim()) == null){
errorLst.add('Invalid CustomerAuthorizeWorkDateOrTime Format');
}else if(Datetime.valueOf(claimInfo.turnAroundData.customerAuthorizeWorkDateOrTime).date() > System.today()){
errorLst.add('CustomerAuthorizeWorkDateOrTime should not be greater than today');
}
}*/
                        }
                    }
                    else{
                        if(ATI_Utils.checkIsBlankData(claimInfo.specialActivityCode)){
                            errorLst.add('SpecialActivityCode is Mandatory');
                        }
                        if(ATI_Utils.checkIsBlankData(claimInfo.campaignTemplateName)){
                            errorLst.add('CampaignTemplateName is Mandatory');
                        }
                        //Alsn-149
                        if(claimInfo.registrationInfo.vehicleInfo.preDelivery =='true' && claimInfo.registrationInfo.vehicleInfo.inServiceDate!=''){
                            errorLst.add('InServiceDate should be empty for Pre-Delivery');
                        }
                        //Alsn -149
                       
                        if(ATI_Utils.checkIsNotBlankData(claimInfo.campaignTemplateName) && ATI_Utils.checkIsNotBlankData(claimInfo.specialActivityCode)
                           && !mapOfKeyWithCampaignClaimTempAss.containsKey(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim())){
                               errorLst.add('No Matching Campaign Claim Template Found with SpecialActivityCode - '+claimInfo.specialActivityCode+ ' and CampaignTemplateName - '+claimInfo.campaignTemplateName);
                           }
                        
                        
                        else{
                            if(ATI_Utils.checkIsBlankData(claimInfo.primaryFailedPartSerialNumber) && mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim()).twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__r.WOD_2__Track_Type__c == 'Serialized'){
                                errorLst.add('PrimaryFailedPartSerialNumber is mandatory for serialized Part');
                            }
                        }
                    }
                    
                    if(accRec.ATI_Currency__c != 'USD' && accRec.ATI_Currency__c != null){
                        //ALSN-146
                        if(exchangeRateMap.isEmpty() || !exchangeRateMap.containsKey(accRec.ATI_Currency__c+'USD'+accRec.ATI_Exchange_Rate_Type__c)){
                            errorLst.add('No exchange rate available from '+accRec.ATI_Currency__c+' to USD for '+ATI_Utils.parseDate(claimInfo.repairOrderOpenDate));
                        }
                    }
                }
                if(errorLst.size() == 0){
                    batchClaimSubmittalReqLst.add(claimInfo);
                    //Service Parts Validation
                    for(ATI_REST_BatchClaimSubmittalRequest.PartsInformation partsInfo : claimInfo.serviceParts) {
                        List<String> partErrorLst = new List<String>();
                        //Anjali added
                        if(String.isBlank(partsInfo.lineNumber) && String.isBlank(partsInfo.failedPartNumber) &&
                           String.isBlank(partsInfo.failedPartSerialNumber) && String.isBlank(partsInfo.replacedPartNumber) &&
                           String.isBlank(partsInfo.replacementPartSerialNumber) && String.isBlank(partsInfo.partQuantity) && 
                           String.isBlank(partsInfo.partUnit)){
                               System.debug('In Service Part if');
                           }
                        
                        else if(ATI_Utils.checkIsBlankData(partsInfo.lineNumber)){
                            partErrorLst.add('LineNumber is Mandatory for ServiceParts');
                            ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                            claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                            claimRelatedInfo.processCode = '7003';
                            claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                            claimRelatedInfo.processMessage = 'LineNumber is Mandatory for ServiceParts';
                            claimRelatedInfoLst.add(claimRelatedInfo);
                        }else{
                            if(ATI_Utils.checkIsBlankData(partsInfo.failedPartNumber)){
                                partErrorLst.add('FailedPartNumber is Mandatory for ServiceParts at line number '+partsInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                claimRelatedInfo.processCode = '217';
                                claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                claimRelatedInfo.processMessage = 'FailedPartNumber is Mandatory';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }
                            else if(!warProdMap.containsKey(partsInfo.failedPartNumber.trim()) || warProdMap.get(partsInfo.failedPartNumber.trim()).WOD_2__Type__c != 'Item' || 
                                    warProdMap.get(partsInfo.failedPartNumber.trim()).WOD_2__Item_Type__c != 'Part'){
                                        partErrorLst.add('FailedPartNumber is Invalid for ServiceParts at line number '+partsInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                        claimRelatedInfo.processCode = '217';
                                        claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                        claimRelatedInfo.processMessage = 'FailedPartNumber is Invalid - '+partsInfo.failedPartNumber;
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }else{
                                        WOD_2__Warranty_Product__c warProd = warProdMap.get(partsInfo.failedPartNumber.trim());
                                        if(warProd.WOD_2__Track_Type__c == 'Serialized'){
                                            if(ATI_Utils.checkIsBlankData(partsInfo.failedPartSerialNumber)){
                                                errorLst.add('FailedPartSerialNumber is Mandatory for ServiceParts at line number '+partsInfo.lineNumber);
                                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                                claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                                claimRelatedInfo.processCode = '7236';
                                                claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                                claimRelatedInfo.processMessage = 'FailedPartSerialNumber is Mandatory for Serialized Part - '+partsInfo.failedPartNumber;
                                                claimRelatedInfoLst.add(claimRelatedInfo);
                                            }else if(!majorCompMap.containsKey(partsInfo.failedPartSerialNumber.trim()) ||
                                                     !majorCompMap.get(partsInfo.failedPartSerialNumber.trim()).WOD_2__Warranty_Product__r.Name.equalsIgnoreCase(partsInfo.failedPartNumber.trim())){
                                                         partErrorLst.add('FailedPartSerialNumber '+partsInfo.failedPartSerialNumber+' is Invalid for FailedPartNumber '+partsInfo.failedPartNumber+' at line number '+partsInfo.lineNumber);
                                                         ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                                         claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                                         claimRelatedInfo.processCode = '7236';       
                                                         claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                                         claimRelatedInfo.processMessage = 'FailedPartSerialNumber '+partsInfo.failedPartSerialNumber+' is Invalid for FailedPartNumber '+partsInfo.failedPartNumber;
                                                         claimRelatedInfoLst.add(claimRelatedInfo);
                                                     }
                                        }
                                    }             
                            if(ATI_Utils.checkIsBlankData(partsInfo.replacedPartNumber)){
                                partErrorLst.add('ReplacedPartNumber is Mandatory for ServiceParts at line number '+partsInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                claimRelatedInfo.processCode = '217';
                                claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                claimRelatedInfo.processMessage = 'ReplacedPartNumber is Mandatory';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }
                            else if(!warProdMap.containsKey(partsInfo.replacedPartNumber.trim()) || warProdMap.get(partsInfo.replacedPartNumber.trim()).WOD_2__Type__c != 'Item' || 
                                    warProdMap.get(partsInfo.replacedPartNumber.trim()).WOD_2__Item_Type__c != 'Part'){
                                        partErrorLst.add('ReplacedPartNumber is Invalid for ServiceParts at line number '+partsInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                        claimRelatedInfo.processCode = '217';
                                        claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                        claimRelatedInfo.processMessage = 'ReplacedPartNumber is Invalid - '+partsInfo.replacedPartNumber;
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }
                            else{
                                WOD_2__Warranty_Product__c warProd = warProdMap.get(partsInfo.replacedPartNumber.trim());
                                if(warProd.WOD_2__Track_Type__c == 'Serialized'){
                                    if(ATI_Utils.checkIsBlankData(partsInfo.replacementPartSerialNumber)){
                                        partErrorLst.add('ReplacementPartSerialNumber is Mandatory for ServiceParts at line number '+partsInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                        claimRelatedInfo.processCode = '740';
                                        claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                        claimRelatedInfo.processMessage = 'ReplacementPartSerialNumber is Mandatory for Serialized Part - '+partsInfo.replacedPartNumber;
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }else if(!majorCompMap.containsKey(partsInfo.replacementPartSerialNumber.trim()) ||
                                             !majorCompMap.get(partsInfo.replacementPartSerialNumber.trim()).WOD_2__Warranty_Product__r.Name.equalsIgnoreCase(partsInfo.replacedPartNumber.trim())){
                                                 partErrorLst.add('ReplacementPartSerialNumber '+partsInfo.replacementPartSerialNumber+' is Invalid for ReplacementPartSerialNumber '+partsInfo.replacedPartNumber+' at line number '+partsInfo.lineNumber);
                                                 ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                                 claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                                 claimRelatedInfo.processCode = '740';
                                                 claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                                 claimRelatedInfo.processMessage = 'ReplacementPartSerialNumber '+partsInfo.replacementPartSerialNumber+' is Invalid for ReplacementPartSerialNumber '+partsInfo.replacedPartNumber;
                                                 claimRelatedInfoLst.add(claimRelatedInfo);
                                             }
                                }
                                if(!priceBookMap.containsKey(warProd.Id)){
                                    partErrorLst.add('No matching prices available in Warranty Price Book for ReplacedPartNumber at line number '+partsInfo.lineNumber);
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                    claimRelatedInfo.processCode = '99';
                                    claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                    claimRelatedInfo.processMessage = 'No matching prices available in Warranty Price Book for ReplacedPartNumber - '+partsInfo.replacedPartNumber;
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                }else{
                                    //ALSN-45
                                    //WOD_2__Warranty_Product_Pricebook__c priceBookRec = priceBookMap.get(warProd.Id);
                                    boolean found = false;
                                    For(WOD_2__Warranty_Product_Pricebook__c priceBookRec : priceBookMap.get(warProd.Id)){
                                        
                                        if((priceBookRec.Name == partsInfo.replacedPartNumber)
                                           && priceBookRec.ATI_Price_Group__c == accRec.ATI_Price_Group__c && priceBookRec.WOD_2__Valid_From__c <= ATI_Utils.parseDate(claimInfo.repairOrderOpenDate) && priceBookRec.WOD_2__Valid_Until__c >=ATI_Utils.parseDate(claimInfo.repairOrderOpenDate)){
                                               found = true;
                                           }   
                                    }
                                    
                                    if(!found){
                                        partErrorLst.add('No matching prices available in Warranty Price Book for ReplacedPartNumber at line number '+partsInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                        claimRelatedInfo.processCode = '99';
                                        claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                        claimRelatedInfo.processMessage = 'No matching prices available in Warranty Price Book for ReplacedPartNumber - '+partsInfo.replacedPartNumber;
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }
                                }
                                if(ATI_Utils.checkIsBlankData(partsInfo.partQuantity)){
                                    partErrorLst.add('PartQuantity is Mandatory for ServiceParts at line number '+partsInfo.lineNumber);
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                    claimRelatedInfo.processCode = '210';
                                    claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                    claimRelatedInfo.processMessage = 'PartQuantity is Mandatory';
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                }
                                if((ATI_Utils.checkIsNotBlankData(partsInfo.partUnit) && warProd.WOD_2__Units_Of_Measure__c == null) || (warProd.WOD_2__Units_Of_Measure__c != null && !warProd.WOD_2__Units_Of_Measure__c.equalsIgnoreCase(partsInfo.partUnit.trim()))){
                                    partErrorLst.add('PartUnit didn\'t match for ServiceParts at line number '+partsInfo.lineNumber);
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = partsInfo.lineNumber;
                                    claimRelatedInfo.processCode = '99';
                                    claimRelatedInfo.processCategoryDescription = 'ServiceParts';
                                    claimRelatedInfo.processMessage = 'PartUnit didn\'t match for FailedPartNumber '+partsInfo.failedPartNumber;
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                } 
                            }
                        }
                        if(partErrorLst.isEmpty()){
                            if(mapOfSuccessParts.containsKey(claimInfo.identifier.trim())){
                                mapOfSuccessParts.get(claimInfo.identifier.trim()).add(partsInfo);
                            }else{
                                mapOfSuccessParts.put(claimInfo.identifier.trim(),new List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation>{partsInfo}); 
                            }
                        }else{
                            if(mapOffailure.containsKey(i)){
                                mapOffailure.get(i).addAll(partErrorLst);
                            }else{
                                mapOffailure.put(i,partErrorLst);
                            }
                        }
                    }
                    
                    //DiagnosticCodes Validation
                    for(ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData diagnosticCodeInfo : claimInfo.diagnosticCodes) {
                        List<String> diagnosticCodeErrorLst = new List<String>();
                        //Anjali added
                        if(ATI_Utils.checkIsBlankData(diagnosticCodeInfo.lineNumber) && ATI_Utils.checkIsBlankData(diagnosticCodeInfo.diagnosticCode)){
                            System.debug('in Diagnostic code');
                            // diagnosticCodeErrorLst.add('');
                            // diagnosticCodeErrorLst.clear();
                        }
                        else if(ATI_Utils.checkIsBlankData(diagnosticCodeInfo.lineNumber)){
                            diagnosticCodeErrorLst.add('LineNumber is Mandatory for DiagnosticCodes');
                            ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                            claimRelatedInfo.lineNumber = diagnosticCodeInfo.lineNumber;
                            claimRelatedInfo.processCode = '7003';
                            claimRelatedInfo.processCategoryDescription = 'DiagnosticCodes';
                            claimRelatedInfo.processMessage = 'LineNumber is Mandatory for DiagnosticCodes';
                            claimRelatedInfoLst.add(claimRelatedInfo);
                        }else{
                            if(ATI_Utils.checkIsBlankData(diagnosticCodeInfo.diagnosticCode)){
                                diagnosticCodeErrorLst.add('DiagnosticCode is Mandatory for DiagnosticCodes at line number '+diagnosticCodeInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = diagnosticCodeInfo.lineNumber;
                                claimRelatedInfo.processCode = '424';
                                claimRelatedInfo.processCategoryDescription = 'DiagnosticCodes';
                                claimRelatedInfo.processMessage = 'DiagnosticCode is Mandatory';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }
                            else if(!warCodeMap.containsKey(diagnosticCodeInfo.diagnosticCode.trim()+'Diagnostics Codes')){
                                diagnosticCodeErrorLst.add('DiagnosticCode is Invalid for DiagnosticCodes at line number '+diagnosticCodeInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = diagnosticCodeInfo.lineNumber;
                                claimRelatedInfo.processCode = '7062';
                                claimRelatedInfo.processCategoryDescription = 'DiagnosticCodes';
                                claimRelatedInfo.processMessage = 'DiagnosticCode is Invalid - '+diagnosticCodeInfo.diagnosticCode.trim();
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }
                        }
                        if(diagnosticCodeErrorLst.isEmpty()){
                            if(mapOfSuccessDiagnosticCodes.containsKey(claimInfo.identifier.trim())){
                                mapOfSuccessDiagnosticCodes.get(claimInfo.identifier.trim()).add(diagnosticCodeInfo);
                            }else{
                                mapOfSuccessDiagnosticCodes.put(claimInfo.identifier.trim(),new List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData>{diagnosticCodeInfo});
                            }
                        }else{
                            if(mapOffailure.containsKey(i)){
                                mapOffailure.get(i).addAll(diagnosticCodeErrorLst);
                            }else{
                                mapOffailure.put(i,diagnosticCodeErrorLst);
                            }
                        }
                    }
                    
                    //LaborCodes Validation
                    for(ATI_REST_BatchClaimSubmittalRequest.LaborInfomation laborInfo : claimInfo.laborCodes) {
                        List<String> laborCodeErrorLst = new List<String>();
                        if(ATI_Utils.checkIsBlankData(laborInfo.lineNumber) && ATI_Utils.checkIsBlankData(laborInfo.laborOperationCode) &&
                           ATI_Utils.checkIsBlankData(laborInfo.laborTimeActual) && ATI_Utils.checkIsBlankData(laborInfo.reason)){
                               System.debug('in labour ---->'); 
                           }
                        else if(ATI_Utils.checkIsBlankData(laborInfo.lineNumber)){
                            laborCodeErrorLst.add('LineNumber is Mandatory for LaborCodes');
                            ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                            claimRelatedInfo.lineNumber = laborInfo.lineNumber;
                            claimRelatedInfo.processCode = '7003';
                            claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                            claimRelatedInfo.processMessage = 'LineNumber is Mandatory for LaborCodes';
                            claimRelatedInfoLst.add(claimRelatedInfo);
                        }else{
                            if(ATI_Utils.checkIsBlankData(laborInfo.laborOperationCode)){
                                laborCodeErrorLst.add('LaborOperationCode is Mandatory for LaborInfomation at line number '+laborInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = laborInfo.lineNumber;
                                claimRelatedInfo.processCode = '302';
                                claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                claimRelatedInfo.processMessage = 'LaborOperationCode is Mandatory';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }else if(!warCodeMap.containsKey(laborInfo.laborOperationCode.trim()+'Job Code') || !mapOfLaborCodeWithFaultCodeMapper.containsKey(laborInfo.laborOperationCode.trim())){
                                laborCodeErrorLst.add('LaborOperationCode is Invalid for LaborInfomation at line number '+laborInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = laborInfo.lineNumber;
                                claimRelatedInfo.processCode = '302';
                                claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                claimRelatedInfo.processMessage = 'LaborOperationCode is Invalid - '+laborInfo.laborOperationCode.trim();
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }else if(ATI_Utils.checkIsBlankData(laborInfo.laborTimeActual) || Decimal.valueOf(laborInfo.laborTimeActual)<=0){
                                laborCodeErrorLst.add('LaborTimeActual cannot be blank or less than or equal to zero at line number '+laborInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = laborInfo.lineNumber;
                                claimRelatedInfo.processCode = '305';
                                claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                claimRelatedInfo.processMessage = 'LaborTimeActual cannot be blank or less than or equal to zero';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }else if(!ATI_Utils.checkIsBlankData(laborInfo.laborTimeActual)){
                                WOD_2__Warranty_Code__c warCode= warCodeMap.get(laborInfo.laborOperationCode.trim()+'Job Code');
                                if(warCode.ATI_Time_Studied__c == true && Decimal.valueOf(laborInfo.laborTimeActual)>warCode.WOD_2__Standard_Labor_Hour__c){
                                    laborCodeErrorLst.add('LaborTimeActual cannot be more than Standard Labor Hour for time bound job codes.'); 
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = laborInfo.lineNumber;
                                    claimRelatedInfo.processCode = '305';
                                    claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                    claimRelatedInfo.processMessage = 'LaborTimeActual cannot be more than Standard Labor Hour for time bound job codes.';
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                }
                            }
                        }
                        if(laborCodeErrorLst.isEmpty()){
                            if(mapOfSuccessLaborCodes.containsKey(claimInfo.identifier.trim())){
                                mapOfSuccessLaborCodes.get(claimInfo.identifier.trim()).add(laborInfo);
                            }else{
                                mapOfSuccessLaborCodes.put(claimInfo.identifier.trim(),new List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation>{laborInfo});
                            }
                        }else{
                            if(mapOffailure.containsKey(i)){
                                mapOffailure.get(i).addAll(laborCodeErrorLst);
                            }else{
                                mapOffailure.put(i,laborCodeErrorLst);
                            }
                        }
                        
                    }
                    
                    //NetItems Validation
                    for(ATI_REST_BatchClaimSubmittalRequest.NetItemsData otherCostInfo : claimInfo.netItems){
                        List<String> otherCostErrorLst = new List<String>();
                        //Anjali added
                        if(ATI_Utils.checkIsBlankData(otherCostInfo.lineNumber) && ATI_Utils.checkIsBlankData(otherCostInfo.netItemType) &&
                           ATI_Utils.checkIsBlankData(otherCostInfo.netItemQuantity) && ATI_Utils.checkIsBlankData(otherCostInfo.netItemUnit) &&
                           ATI_Utils.checkIsBlankData(otherCostInfo.netItemUnitCost) && ATI_Utils.checkIsBlankData(otherCostInfo.reason)){
                               
                               System.debug('In net items if');    
                           }
                        else if(ATI_Utils.checkIsBlankData(otherCostInfo.lineNumber)){
                            otherCostErrorLst.add('LineNumber is Mandatory for NetItems');
                            ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                            claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                            claimRelatedInfo.processCode = '7003';
                            claimRelatedInfo.processCategoryDescription = 'NetItems';
                            claimRelatedInfo.processMessage = 'LineNumber is Mandatory for NetItems';
                            claimRelatedInfoLst.add(claimRelatedInfo);
                        }else{
                            if(ATI_Utils.checkIsBlankData(otherCostInfo.netItemType)){
                                otherCostErrorLst.add('NetItemType is Mandatory at line number '+otherCostInfo.lineNumber);
                                ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                                claimRelatedInfo.processCode = '596';
                                claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                claimRelatedInfo.processMessage = 'NetItemType is Mandatory';
                                claimRelatedInfoLst.add(claimRelatedInfo);
                            }else{
                                if(ATI_Utils.checkIsBlankData(otherCostInfo.netItemQuantity) || Integer.valueOf(otherCostInfo.netItemQuantity)<=0){
                                    otherCostErrorLst.add('NetItemQuantity is not Valid at line number '+otherCostInfo.lineNumber);
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                                    claimRelatedInfo.processCode = '7004';
                                    claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                    claimRelatedInfo.processMessage = 'NetItemQuantity is not Valid';
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                }
                                if(otherCostInfo.netItemType != 'Travel By Distance' && (ATI_Utils.checkIsBlankData(otherCostInfo.netItemUnitCost) || Decimal.valueOf(otherCostInfo.netItemUnitCost)<=0)){
                                    otherCostErrorLst.add('NetItemUnitCost is not Valid at line number '+otherCostInfo.lineNumber);
                                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                    claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                                    claimRelatedInfo.processCode = '401';
                                    claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                    claimRelatedInfo.processMessage = 'NetItemUnitCost is not Valid';
                                    claimRelatedInfoLst.add(claimRelatedInfo);
                                }
                                if(otherCostInfo.netItemType == 'Travel By Distance'){
                                    if(ATI_Utils.checkIsBlankData(otherCostInfo.netItemUnit)){
                                        otherCostErrorLst.add('NetItemUnit is Mandatory at line number '+otherCostInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                                        claimRelatedInfo.processCode = '401';
                                        claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                        claimRelatedInfo.processMessage = 'NetItemUnit is Mandatory for Travel By Distance';
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }else if(!otherCostInfo.netItemUnit.equalsIgnoreCase('mi') && !otherCostInfo.netItemUnit.equalsIgnoreCase('km') && !otherCostInfo.netItemUnit.equalsIgnoreCase('hrs')){
                                        otherCostErrorLst.add('NetItemUnit is Invalid at line number '+otherCostInfo.lineNumber);
                                        ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                                        claimRelatedInfo.lineNumber = otherCostInfo.lineNumber;
                                        claimRelatedInfo.processCode = '401';
                                        claimRelatedInfo.processCategoryDescription = 'LaborCodes';
                                        claimRelatedInfo.processMessage = 'NetItemUnit is Invalid for Travel By Distance';
                                        claimRelatedInfoLst.add(claimRelatedInfo);
                                    }
                                }
                            }
                        }
                        if(otherCostErrorLst.isEmpty()){
                            if(mapOfSuccessNetItems.containsKey(claimInfo.identifier.trim())){
                                mapOfSuccessNetItems.get(claimInfo.identifier.trim()).add(otherCostInfo);
                            }else{
                                mapOfSuccessNetItems.put(claimInfo.identifier.trim(),new List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData>{otherCostInfo});
                            }
                        }else{
                            if(mapOffailure.containsKey(i)){
                                mapOffailure.get(i).addAll(otherCostErrorLst);
                            }else{
                                mapOffailure.put(i,otherCostErrorLst);
                            }
                        }
                    }
                    
                    
                    if(!claimRelatedInfoLst.isEmpty()){
                        mapOfBatchClaimRelatedErrorInfo.put(claimInfo.identifier.trim(),claimRelatedInfoLst);
                    }
                }else{
                    mapOfFailure.put(i,errorLst);
                }             
            }
            
            i++;
        }
        totalRecords = i-1;
    }
}