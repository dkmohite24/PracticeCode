/* Name: ATI_REST_WarrantyStatusCheck
Description : Endpoint which retrieves Inventory and Warranty Details required for filing claim purposes 
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL                  UserStory/Req#
1.0 -     Tavant(TY)       01/02/2021      INITIAL DEVELOPMENT             20656                 
*/
@RestResource(urlMapping = '/ATIRestWarrantyStatusCheck/*')
global with sharing class ATI_REST_WarrantyStatusCheck implements ATI_LoggableInterface{
    
    @HttpPost
    global Static ATI_REST_WarrantyStatusCheckResponse doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        System.debug(requestBody);
        ATI_REST_WarrantyStatusCheck warrantyStatusCheckObj = new ATI_REST_WarrantyStatusCheck();
        ATI_REST_WarrantyStatusCheckResponse warrantyStatusCheckResponse = warrantyStatusCheckObj.warrantyStatusCheck(requestBody);
        return warrantyStatusCheckResponse;
    }
    
    public ATI_REST_WarrantyStatusCheckResponse warrantyStatusCheck(String warrantyStatusCheckRequest){
        ATI_REST_WarrantyStatusCheckResponse warrantyStatusResponse = new ATI_REST_WarrantyStatusCheckResponse();
        WOD_2.ResponseWrapper response = processType(warrantyStatusCheckRequest);
        if(response != null && response.data != null && response.data != '') {
            warrantyStatusResponse = (ATI_REST_WarrantyStatusCheckResponse)Json.deserialize(response.data,ATI_REST_WarrantyStatusCheckResponse.class);
        }else {
            warrantyStatusResponse.status = 'Fail';
            warrantyStatusResponse.data = null;
            warrantyStatusResponse.message = response.errormessage;
            createLog('WarrantyStatusCheck',warrantyStatusCheckRequest,JSON.serialize(warrantyStatusResponse),'Failed',null,null,response.errormessage);
        }
        return warrantyStatusResponse;   
    }
    
    private ATI_REST_WarrantyStatusCheckValidator warrantyStatusCheckValidatorObj{get; private set;}
    public WOD_2.ResponseWrapper processType(String warrantyStatusCheckRequest){
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper(null,false,null);
        warrantyStatusCheckValidatorObj = new ATI_REST_WarrantyStatusCheckValidator();
        try{
            ATI_REST_WarrantyStatusCheckRequest warrantyStatusCheckReq = ATI_REST_WarrantyStatusCheckRequest.parse(warrantyStatusCheckRequest);
            warrantyStatusCheckValidatorObj.validateReqest(warrantyStatusCheckReq);
            ATI_REST_WarrantyStatusCheckResponse response = new ATI_REST_WarrantyStatusCheckResponse();
            response.interfaceName = 'I-716 - Warranty Status Check';
            if(!warrantyStatusCheckValidatorObj.mapOfFailure.isEmpty() && warrantyStatusCheckValidatorObj.mapOfFailure.containsKey(0)){
                response.message = String.Join(warrantyStatusCheckValidatorObj.mapOfFailure.get(0),', ') ;
                response.status = 'Failed';
                createLog('WarrantyStatusCheck',warrantyStatusCheckRequest,JSON.serialize(response),'Failed',null,null,response.message);
            }else{
                ResponseData data = new ResponseData();
                data.WarrantyStatusCheckResponse = new WarrantyStatusCheckResponse();
                data.WarrantyStatusCheckResponse.product = new InventoryInformation();
                populateInventoryDetails(warrantyStatusCheckReq.warrantyStatusCheck, data.WarrantyStatusCheckResponse.product);
                List<WOD_2__Warranty_Coverages__c> coverages;
                if(warrantyStatusCheckValidatorObj.inventoryItem.WOD_2__Type__c == 'Stock' && warrantyStatusCheckValidatorObj.shouldRegisterInventory){
                    Date oldInServiceDate = warrantyStatusCheckValidatorObj.inventoryItem.WOD_2__Install_Date__c;
                    WOD_2__Inventory__c inv = new WOD_2__Inventory__c(Id=warrantyStatusCheckValidatorObj.inventoryItem.Id, WOD_2__Install_Date__c=warrantyStatusCheckValidatorObj.inServiceDate);
                    ATI_Utils.checkForAccess('WOD_2__Inventory__c', 'UPDATE', new List<String>{'WOD_2__Install_Date__c'});
                    update inv;
                    System.debug('Inventory -> ' + inv);
                    List<WOD_2__Warranty_Registration__c> wrList = createWR(warrantyStatusCheckValidatorObj);
                    WOD_2.WR_WarrantyRegistrationResponse wrResponse = ATI_WarrantyService.runEngine(new Map<Id, WOD_2__Warranty_Registration__c>(wrList), 'ATI_StandardPolicyQueryOverride');
                    if(wrResponse.response != null && !wrResponse.response.isEmpty()){
                        WOD_2.WR_RegistrationResponse wntyRegResponse = wrResponse.response.get(wrList[0].Id);
                        if(wntyRegResponse != null && wntyRegResponse.status){
							coverages = wntyRegResponse.warrantyCoverages;
                            System.debug('coverages -> ' + coverages);
                            List<Id> policyIds = new List<Id>();
                            for(WOD_2__Warranty_Coverages__c c : coverages){
                                policyIds.add(c.WOD_2__Policy_Definition__c);
                            }
                            ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', new List<String>{'Name','WOD_2__Type__c','WOD_2__Description__c','WOD_2__Months_Covered__c','WOD_2__Priority__c'});
                            Map<Id, WOD_2__Policy_Definition__c> policyMap = new Map<Id, WOD_2__Policy_Definition__c>([select id, Name,WOD_2__Type__c,WOD_2__Description__c,WOD_2__Priority__c,WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c where id in :policyIds]);
                            for(WOD_2__Warranty_Coverages__c c : coverages){
                                WOD_2__Policy_Definition__c policy = policyMap.get(c.WOD_2__Policy_Definition__c);
                                c.WOD_2__Policy_Definition__r = policy;
                                if(policy.WOD_2__Months_Covered__c != NULL) {
                                    c.WOD_2__Warranty_End_Date__c = c.WOD_2__Warranty_Start_Date__c.addMonths(Integer.valueOf(policy.WOD_2__Months_Covered__c));
                                }                                
                            }
                        }
                        inv = new WOD_2__Inventory__c(Id=warrantyStatusCheckValidatorObj.inventoryItem.Id, WOD_2__Install_Date__c=oldInServiceDate);
                        update inv;
                        ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c', 'DELETE', null);
                        delete wrList;
                    }
                } else {
                    coverages = fetchWarrantyCoverages(warrantyStatusCheckValidatorObj.inventoryItem.Id);
                }
                data.WarrantyStatusCheckResponse.coverages.addAll(createCoverageList(coverages,warrantyStatusCheckValidatorObj));
                response.data = data;
                responseWrapper.status = true;
                response.status = 'Success';
                response.message = 'Record Retrieved Successfully';
            }
            responseWrapper.data = JSON.serialize(response);
            createLog('WarrantyStatusCheck',warrantyStatusCheckRequest,JSON.serialize(response),'Success',null,warrantyStatusCheckReq.warrantyStatusCheck.serialNumber,null);
        }catch(Exception e){
            system.debug('Error -> '+ e.getMessage() + ' -> ' + e.getLineNumber() + ' -> ' + e.getStackTraceString());
            responseWrapper.data = null;
            responseWrapper.status = false;
            responseWrapper.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return responseWrapper;
    }
    
    private List<WOD_2__Warranty_Registration__c> createWR(ATI_REST_WarrantyStatusCheckValidator validator){
        WOD_2__Warranty_Registration__c newWR = new WOD_2__Warranty_Registration__c();
        newWR.ATI_Vocation_Code__c = validator.vocationCode.Id;                                    
        newWR.WOD_2__Warranty_Product__c = validator.inventoryItem.WOD_2__Item__c;
        newWR.WOD_2__Registration_Date__c = System.today();
        newWR.WOD_2__Install_Date__c = validator.inServiceDate;
        //newWR.WOD_2__Units_Usage__c = validator.vehicleUsageValue;
        newWR.WOD_2__Status__c = 'Draft';
        newWR.WOD_2__Inventory__c = validator.inventoryItem.Id;
        newWR.WOD_2__Registration_Comments__c = 'Registered for 716 search';                                          
        newWR.WOD_2__Registration_Type__c = 'Standard Registration';
        //newWR.WOD_2__Usage_Type__c = validator.vehicleUsageUnit;
        newWR.WOD_2__Account__c = validator.inventoryItem.WOD_2__Account__c;
        ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c', 'CREATE', new List<String>{'ATI_Vocation_Code__c','WOD_2__Warranty_Product__c',
            'WOD_2__Registration_Date__c','WOD_2__Install_Date__c','WOD_2__Units_Usage__c','WOD_2__Status__c','WOD_2__Inventory__c',
            'WOD_2__Registration_Comments__c','WOD_2__Registration_Type__c','WOD_2__Usage_Type__c','WOD_2__Account__c'});
        insert newWR;
        List<WOD_2__Warranty_Registration__c> wrList =
            [SELECT id, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
             WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,
             WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c, 
             //WOD_2__De_Registration_Comments__c,WOD_2__De_Registration_date__c,WOD_2__De_Registration_Reason__c,
             WOD_2__Status__c FROM WOD_2__Warranty_Registration__c 
             WHERE Id = :newWR.Id];
        return wrList;
    }
    
    private List<WarrantyInformation> createCoverageList(List<WOD_2__Warranty_Coverages__c> coverages,ATI_REST_WarrantyStatusCheckValidator validator){
        List<WarrantyInformation> wiList = new List<WarrantyInformation>();
        Map<Id, WOD_2__Policy_Definition_Inventory_Usage__c> coverageIdUsageMap = getCoverageIdUsageMap(coverages);
        if(coverages != null){
            List<CoverageWrapper> coverageWrapperList = new List<CoverageWrapper>(); 
            for(WOD_2__Warranty_Coverages__c c : coverages){
                coverageWrapperList.add(new CoverageWrapper(c));
            }
            coverageWrapperList.sort();
            Boolean isSelected = false;
            for(CoverageWrapper coverageWrapper : coverageWrapperList){
                WOD_2__Warranty_Coverages__c c = coverageWrapper.coverage;
                WarrantyInformation wi = new WarrantyInformation();
                if(!isSelected){
                	wi.selected = getSelected(c, coverageIdUsageMap.get(c.WOD_2__Policy_Definition__c), validator);
                    isSelected = wi.selected;
                } else {
                    wi.selected = false;
                }
                wi.policyType = getPolicyType(c.WOD_2__Policy_Definition__r.WOD_2__Type__c);
                wi.policyName = c.WOD_2__Policy_Definition__r.Name;
                wi.description = c.WOD_2__Policy_Definition__r.WOD_2__Description__c;
                wi.beginDate = c.WOD_2__Warranty_Start_Date__c != null ? String.valueOf(c.WOD_2__Warranty_Start_Date__c) : '';
                wi.endDate = c.WOD_2__Warranty_End_Date__c != null ? String.valueOf(c.WOD_2__Warranty_End_Date__c) : '';
                wi.beginUsage = '1.0 mi';
                wi.endUsage = coverageIdUsageMap.containsKey(c.WOD_2__Policy_Definition__c) ? 
                    coverageIdUsageMap.get(c.WOD_2__Policy_Definition__c).WOD_2__Maximum_Unit__c + '' : 'Unlimited';
                wiList.add(wi);
            }
        }
        return wiList;
    }
    
    private boolean getSelected(WOD_2__Warranty_Coverages__c c, WOD_2__Policy_Definition_Inventory_Usage__c invUsage,
                               ATI_REST_WarrantyStatusCheckValidator validator){
        Date repairOrderOpenDate = validator.repairOrderOpenDate;
        Decimal vehicleUsage = validator.vehicleUsageValue;
        String usageUnit = validator.vehicleUsageUnit;
		if(c.WOD_2__Warranty_Start_Date__c <= repairOrderOpenDate && repairOrderOpenDate <= c.WOD_2__Warranty_End_Date__c){
            if(invUsage != null && invUsage.WOD_2__Maximum_Unit__c != null && vehicleUsage != null && usageUnit != null){
            	Decimal usageToCompare = 'KM'.equalsIgnoreCase(usageUnit) ? vehicleUsage * 0.621371 : vehicleUsage;  
                return (vehicleUsage < invUsage.WOD_2__Maximum_Unit__c);
            }
            return true;
        }                                   
        return false;
    }
    
    private Map<Id, WOD_2__Policy_Definition_Inventory_Usage__c> getCoverageIdUsageMap(List<WOD_2__Warranty_Coverages__c> coverages){
        Map<Id, WOD_2__Policy_Definition_Inventory_Usage__c> coverageIdUsageMap = new Map<Id, WOD_2__Policy_Definition_Inventory_Usage__c>();
        if(coverages != null && !coverages.isEmpty()){
            List<Id> policyDefIdList = new List<Id>();
            for(WOD_2__Warranty_Coverages__c c : coverages){
                policyDefIdList.add(c.WOD_2__Policy_Definition__c);
            }
            List<String> invUsageFields = new List<String>{'WOD_2__Minimum_Unit__c','WOD_2__Maximum_Unit__c',
                'WOD_2__Units_Of_Measure__c','WOD_2__Policy_Definition__c'};
            ATI_Utils.checkForAccess('WOD_2__Policy_Definition_Inventory_Usage__c', 'READ', invUsageFields);
            String query = 'Select ID, ' + String.join(invUsageFields, ', ') + ' from WOD_2__Policy_Definition_Inventory_Usage__c where WOD_2__Policy_Definition__c in :policyDefIdList';
            List<WOD_2__Policy_Definition_Inventory_Usage__c> usages = Database.query(query);
            for(WOD_2__Policy_Definition_Inventory_Usage__c u : usages){
                coverageIdUsageMap.put(u.WOD_2__Policy_Definition__c, u);
            }			            
        }
        return coverageIdUsageMap;
    }
    
    private String getPolicyType(String policyType){
        switch on policyType{
            WHEN 'Standard' {
                return '01';
            }
            WHEN 'Extended'{
                return '02';
            }
            WHEN 'Supplemental Coverage' {
                return '09';
            }
        }
        return '';
    }    
    
    private List<WOD_2__Warranty_Coverages__c> fetchWarrantyCoverages(Id invId){
        List<String> coverageFields = new List<String>{'WOD_2__Policy_Definition__r.Name','WOD_2__Policy_Definition__r.WOD_2__Type__c',
            'WOD_2__Policy_Definition__r.WOD_2__Description__c','WOD_2__Warranty_Start_Date__c','WOD_2__Warranty_End_Date__c','WOD_2__Policy_Definition__r.WOD_2__Priority__c'};
		ATI_Utils.checkForAccess('WOD_2__Warranty_Coverages__c', 'READ', coverageFields);                
        String query = 'select ID, ' + String.join(coverageFields, ', ') + ' from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__r.WOD_2__Inventory__c = :invId and WOD_2__Warranty_Registration__r.WOD_2__Status__c = \'Registered\'';
        return Database.query(query);
    }
    
    private void populateInventoryDetails(ATI_REST_WarrantyStatusCheckRequest.WarrantyStatusCheckRequest req, InventoryInformation product){
        Date inServiceDate = (warrantyStatusCheckValidatorObj.inventoryItem.WOD_2__Type__c == 'Stock') ?
            warrantyStatusCheckValidatorObj.inServiceDate : warrantyStatusCheckValidatorObj.inventoryItem.WOD_2__Install_Date__c;
        WOD_2__Inventory__c inventoryItem = warrantyStatusCheckValidatorObj.inventoryItem;
        product.serialNumber = inventoryItem.WOD_2__Serial_Number__c;
        product.vin = (inventoryItem.Transmissions__r != null && !inventoryItem.Transmissions__r.isEmpty()) ?
            inventoryItem.Transmissions__r[0].ATI_Vehicle_Information__r != null ? inventoryItem.Transmissions__r[0].ATI_Vehicle_Information__r.Name : '' : '';
        product.vocation = inventoryItem.ATI_Vocation_Code__c != null ? inventoryItem.ATI_Vocation_Code__r.Name : '';
        product.standardModel = inventoryItem.WOD_2__Item_Name__c;
        product.repairOrderOpenDate = req.repairOrderOpenDate;
        product.inServiceDate = inServiceDate == null ? '' : ((DateTime)inServiceDate).formatGmt('yyyy-MM-dd');
        product.vehicleUsageValue = req.vehicleUsageValue;
        product.vehicleUsageUnit = req.vehicleUsageUnit;
        product.shipToCode = inventoryItem.ATI_Ship_To__c;
        product.knownClaims = fetchClaimNumbers(inventoryItem);
    }
    
    private String fetchClaimNumbers(WOD_2__Inventory__c inventoryItem){
		List<WOD_2__Claim__c> claimList = [select Name from WOD_2__Claim__c where WOD_2__Inventory__c = :inventoryItem.Id order by Name];
        if(claimList != null && !claimList.isEmpty()){
            List<String> claimNumberList = new List<String>();
            for(WOD_2__Claim__c claim : claimList){
                claimNumberList.add(claim.Name);
            }
            return String.join(claimNumberList, ',');
        }
        return '';
    }
    
    private void createLog(String processName, String request, String response, String status, String identifier, String primaryKey,String errorMessage){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_WarrantyStatus_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            if(status == 'Success'){
                objLogSerWrp.successRecordCount = 1;
                objLogSerWrp.failureRecordCount = 0;
            }else{
                objLogSerWrp.failureRecordCount = 1;
                objLogSerWrp.successRecordCount = 0;
            }
            objLogSerWrp.errortext = errorMessage;
            objLogSerWrp.totalRecordCount = 1;
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
	Description    :   A wrapper class to capture the WarrantyStatus Rest data.
	*************************************************************************/
    global class ATI_REST_WarrantyStatusCheckResponse{
        global String status;
        global String interfaceName;
        global ResponseData data;
        global String message;
    }

    global class WarrantyStatusCheckResponse {
        global InventoryInformation product;
        global List<WarrantyInformation> coverages = new List<WarrantyInformation>();
    }
    
    global class ResponseData{
        global WarrantyStatusCheckResponse WarrantyStatusCheckResponse;
    }
    
    global class InventoryInformation{
        global String serialNumber = '';
        global String vin = '';
        global String vocation = '';
        global String standardModel = '';
        global String repairOrderOpenDate = '';
        global String inServiceDate = '';
        global String vehicleUsageValue = '';
        global String vehicleUsageUnit = '';
        global String shipToCode = '';
        global String knownClaims = '';
    }
    
    global class WarrantyInformation{
        global Boolean selected = false;
        global String policyType = '';
        global String policyName = '';
        global String description = '';
        global String beginDate = '';
        global String endDate = '';
        global String beginUsage = '';
        global String endUsage = '';
    }
    
    global class CoverageWrapper implements Comparable {
        public WOD_2__Warranty_Coverages__c coverage{get; private set;}
        public CoverageWrapper(WOD_2__Warranty_Coverages__c c){
            coverage = c;
        }
        global Integer compareTo(Object compareTo) {
            WOD_2__Warranty_Coverages__c c = ((CoverageWrapper) compareTo).coverage;
            if(c != null && c.WOD_2__Policy_Definition__c !=null && c.WOD_2__Policy_Definition__r.WOD_2__Priority__c != null){
                if(coverage.WOD_2__Policy_Definition__r.WOD_2__Priority__c == c.WOD_2__Policy_Definition__r.WOD_2__Priority__c){
                    return 0;
                }else if(coverage.WOD_2__Policy_Definition__r.WOD_2__Priority__c < c.WOD_2__Policy_Definition__r.WOD_2__Priority__c){
                    return -1;
                }else {
                    return 1;
                }
                
            }
            return 1;
        }
    }
}