/* Name: ATI_WR_BulkDataLoad
Description : ATI_WR_BulkDataLoad - A batch helper class to do registration of the inventories
This class will pick up the Standard Policies and adds the Policy Name given without running any rules
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      15-APR-2021          INITIAL DEVELOPMENT
*/
public class ATI_WR_BulkDataLoad implements Database.Batchable<sObject>, Database.Stateful{
    
    private Map<String, WOD_2__Inventory__c> serialNoInvMap = new Map<String, WOD_2__Inventory__c>();
    private Map<String, WOD_2__Policy_Definition__c> policyNameDefMap = new Map<String, WOD_2__Policy_Definition__c>();
    private Map<String, String> serialNoPolicyNameMap = new Map<String, String>();
    private Map<String, STG_WR_Load__c> serialNoStgRecMap = new Map<String, STG_WR_Load__c>();
    List<String> serialNumberPreDelList = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT CE_Number__c,Close_Date__c,Contract_Number__c,Disposition_Code__c,EW_Purchase_Date__c,' +
            'Exchange_Rate__c,Ext_Warranty_Policy_Name__c,Failure_Message__c,PO_Number__c,Pre_Delivery__c,Registration_Date__c,' + 
            'Serial_Number__c,Status__c,Tracking_Number__c,Install_Date__c from STG_WR_Load__c where Status__c = \'New\' and IsDeleted = false order by Serial_Number__c';
        return Database.getQueryLocator(query);
    }
    
    private void clearAll(){
        serialNoInvMap.clear();
        serialNoPolicyNameMap.clear();
        serialNoStgRecMap.clear();
        serialNumberPreDelList.clear();
    }
    
    public void execute(Database.BatchableContext bc, List<STG_WR_Load__c> stgRecList) {
        clearAll();
        System.debug('Map SIze --> ' + serialNoInvMap.size());
        validateAndFetchData(stgRecList);
        List<Id> wrIds = createWRs();
        if(!wrIds.isEmpty()){
            List<String> wrFieldList = new List<String>{'WOD_2__Inventory__c','WOD_2__Customer__c','WOD_2__Registration_Comments__c','WOD_2__Registration_Type__c','WOD_2__Usage_Type__c','WOD_2__Account__c',
                'WOD_2__Registration_Date__c','WOD_2__Inventory__r.WOD_2__Business_Unit__c','WOD_2__Inventory__r.WOD_2__Serial_Number__c','WOD_2__Inventory__r.WOD_2__Install_Date__c',
                'WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c','WOD_2__Status__c','ATI_CE_Number__c','ATI_Close_Date__c',
                'ATI_Contract_Number__c','ATI_Disposition_Code__c','ATI_Exchange_Rate__c','ATI_Tracking_Number__c'};
            ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c', 'READ', wrFieldList);
            String wrQuery = 'Select ID, ' + String.join(wrFieldList, ', ') + ' from WOD_2__Warranty_Registration__c where ID in :wrIds';
            List<WOD_2__Warranty_Registration__c> wrList = Database.query(wrQuery);
            System.debug('wrList -> ' + wrList);
            Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>(wrList);
            Map<Id,WOD_2.WR_RegistrationResponse> response = ATI_WarrantyService.runApplicablityEngine(wrMap,'ATI_StandardPolicyQueryOverride');
            System.debug('response -> ' + response);
            List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
            Map<Id,WOD_2__Warranty_Registration__c> wrIdMap = new Map<Id,WOD_2__Warranty_Registration__c>();
            for(WOD_2.WR_RegistrationResponse regResponse : response.values()) {
                String sNo = wrMap.get(regResponse.warrantyId).WOD_2__Inventory__r.WOD_2__Serial_Number__c.toUpperCase();
                if(!regResponse.status){
                    serialNoStgRecMap.get(sNo).Status__c = 'Failed';
                    serialNoStgRecMap.get(sNo).Failure_Message__c = regResponse.message;
                    continue;
                } else if(regResponse.warrantyCoverages.isEmpty()){
                    serialNoStgRecMap.get(sNo).Status__c = 'Failed';
                    serialNoStgRecMap.get(sNo).Failure_Message__c = 'Standard Policies is not found';
                    continue;
                }
                for(WOD_2__Warranty_Coverages__c coverage : regResponse.warrantyCoverages){
                    System.debug('>>> coverage :'+ coverage);
                    if(coverage.WOD_2__Policy_Definition__c != null){
                        warrantyCoveragesList.add(coverage);
                        wrIdMap.put(regResponse.warrantyId, wrMap.get(regResponse.warrantyId));
                    } 
                }
                try{
                    System.debug('serialNumberPreDelList -> ' + serialNumberPreDelList);
                    System.debug('sNo -> ' + sNo);
                    if(!serialNumberPreDelList.contains(sNo) && policyNameDefMap.containsKey(serialNoPolicyNameMap.get(sNo))){
                    	warrantyCoveragesList.add(createExtCoverage(sNo, wrIdMap.get(regResponse.warrantyId)));        
                    }
                    serialNoStgRecMap.get(sNo).Status__c = 'Success';
                }catch(Exception e){
                    serialNoStgRecMap.get(sNo).Status__c = 'Failed';
                    serialNoStgRecMap.get(sNo).Failure_Message__c = e.getMessage();
                }
            }
            System.debug('wrMap -> ' + wrMap);
            System.debug('wrIdMap -> ' + wrIdMap);
            System.debug('warrantyCoveragesList -> ' + warrantyCoveragesList);
            if(!warrantyCoveragesList.isEmpty()){
                WOD_2.ResponseWrapper res = saveCoverages(warrantyCoveragesList, new List<Id>(wrIdMap.keyset()));
                if(!res.status){
                    for(String sNo : serialNoStgRecMap.keySet()){
                        serialNoStgRecMap.get(sNo).Status__c = 'Failed';
                        serialNoStgRecMap.get(sNo).Failure_Message__c = res.errormessage;
                    }
                }
            }
        }
        update serialNoStgRecMap.values();
    }
    
    private void validateAndFetchData(List<STG_WR_Load__c> stgRecList){
        List<String> serialNumberList = new List<String>();
        List<String> policyNameList = new List<String>();
        List<STG_WR_Load__c> failedRecords = new List<STG_WR_Load__c>();
        
        for(STG_WR_Load__c stgWR : stgRecList){
            boolean isValid = true;
            List<String> errorList = new List<String>();
            if(ATI_Utils.checkIsNotBlankData(stgWR.Serial_Number__c)){
                String sNo = stgWR.Serial_Number__c.trim().toUpperCase();
                serialNumberList.add(stgWR.Serial_Number__c.trim());    
                serialNoStgRecMap.put(sNo, stgWR);
                if(stgWR.Pre_Delivery__c){
                    serialNumberPreDelList.add(sNo);
                }
            } else {
                isValid = false;  
                errorList.add('Missing Serial Number');
            }
            if(ATI_Utils.checkIsNotBlankData(stgWR.Ext_Warranty_Policy_Name__c)){
                if(ATI_Utils.checkIsNotBlankData(stgWR.Serial_Number__c) && serialNumberPreDelList.contains(stgWR.Serial_Number__c.trim().toUpperCase())){
                    isValid = false;  
                    errorList.add('Policy Name is provided for pre-delivery registration.');
                } else {
                	policyNameList.add(stgWR.Ext_Warranty_Policy_Name__c.trim());        
                }
                
            }
            if(isValid){
                String sNo = stgWR.Serial_Number__c.trim().toUpperCase();
                if(ATI_Utils.checkIsNotBlankData(stgWR.Ext_Warranty_Policy_Name__c)){
                	serialNoPolicyNameMap.put(sNo, stgWR.Ext_Warranty_Policy_Name__c.trim().toUpperCase());
                }
                stgWR.Status__c = 'In Progress';
            }else {
                stgWR.Status__c = 'Failed';
                stgWR.Failure_Message__c = String.join(errorList, ', ');
                failedRecords.add(stgWR);
            }
            
        }
        update failedRecords;
        if(!serialNumberList.isEmpty()){
        	fetchAllData(serialNumberList, policyNameList);    
        }
    }

    private WOD_2.ResponseWrapper saveCoverages(List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList, List<Id> wrIdList){
        WOD_2.WR_CoverageInputWrapper covrageWrapper = new WOD_2.WR_CoverageInputWrapper();
        covrageWrapper.coverages = warrantyCoveragesList;
        covrageWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
        covrageWrapper.wrRecordIds = wrIdList;
        WOD_2.ResponseWrapper coverageWrapperObj = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);                    
        System.debug('coverageWrapperObj -> ' + coverageWrapperObj);
        return coverageWrapperObj;
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }

    private WOD_2__Warranty_Coverages__c createExtCoverage(String sNo, WOD_2__Warranty_Registration__c wr){
        WOD_2__Policy_definition__c policy = policyNameDefMap.get(serialNoPolicyNameMap.get(sNo));
        Date wntyStartDate = wr.WOD_2__Inventory__r.WOD_2__Install_Date__c;
        WOD_2__Warranty_Coverages__c warrantyCoverageObject = new WOD_2__Warranty_Coverages__c();
        warrantyCoverageObject.WOD_2__Warranty_Registration__c = wr.Id;
        warrantyCoverageObject.WOD_2__Warranty_Start_Date__c = wntyStartDate;
        warrantyCoverageObject.WOD_2__Policy_Definition__c = policy.Id;
        warrantyCoverageObject.WOD_2__Is_Active__c = true;
        warrantyCoverageObject.ATI_isExtended__c = true;
        if(policy.WOD_2__Months_Covered__c != NULL) {
            warrantyCoverageObject.WOD_2__Warranty_End_Date__c = wntyStartDate.addMonths(Integer.valueOf(policy.WOD_2__Months_Covered__c));
        } else if(policy.WOD_2__Days_Covered__c != NULL) {
            warrantyCoverageObject.WOD_2__Warranty_End_Date__c = wntyStartDate.addDays(Integer.valueOf(policy.WOD_2__Days_Covered__c));
        }
        return warrantyCoverageObject;
    }
    
    private void fetchAllData(List<String> serialNumberList,List<String> policyNameList){
        List<String>  invFields = new List<String>{'WOD_2__Business_Unit__c','WOD_2__Serial_Number__c','WOD_2__Install_Date__c',
            'WOD_2__Manufacturing_Date__c','ATI_Vocation_Code__c','WOD_2__Item__c','WOD_2__Account__c','WOD_2__Customer__c'};
		ATI_Utils.checkForAccess('WOD_2__Inventory__c', 'READ', invFields);
        String invQuery = 'SELECT ID, ' + String.join(invFields, ', ') + ' from WOD_2__Inventory__c where WOD_2__Serial_Number__c in :serialNumberList and id not in (' + 
            'select WOD_2__Inventory__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c in :serialNumberList) and IsDeleted = false';
        List<WOD_2__Inventory__c> invList = Database.query(invQuery);
        for(WOD_2__Inventory__c inv : invList){
            serialNoInvMap.put(inv.WOD_2__Serial_Number__c.toUpperCase(), inv);
        }
        List<String> policyDefFields = new List<String>{'Name','WOD_2__Months_Covered__c','WOD_2__Type__c','WOD_2__Status__c'};
        ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', policyDefFields);
        String policyQuery = 'Select Id, ' + String.join(policyDefFields, ', ') + ' FROM WOD_2__Policy_Definition__c WHERE Name IN :policyNameList AND WOD_2__Type__c=\'Extended\' AND WOD_2__Status__c=\'Active\' and IsDeleted = false';
        List<WOD_2__Policy_Definition__c> policyList = DataBase.query(policyQuery);
        for(WOD_2__Policy_Definition__c p : policyList){
            policyNameDefMap.put(p.Name.toUpperCase(), p);
        }
    }
    
    private List<Id> createWRs(){
        List<String> wrFieldList = new List<String>{'WOD_2__Registration_Type__c','ATI_isExtended__c',
            'WOD_2__Account__c','WOD_2__Inventory__c','WOD_2__Status__c','WOD_2__Customer__c'};
		ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c', 'CREATE', wrFieldList);                
        List<WOD_2__Warranty_Registration__c> wrlist = new List<WOD_2__Warranty_Registration__c>();
        Map<Id, String> invIdSNoMap = new Map<Id, String>(); 
        for(String sNo : serialNoInvMap.keySet()){
            WOD_2__Inventory__c inv = serialNoInvMap.get(sNo);
            invIdSNoMap.put(inv.Id, sNo);
            STG_WR_Load__c stgWR = serialNoStgRecMap.get(sNo);
            if(ATI_Utils.checkIsNotBlankData(stgWR.Ext_Warranty_Policy_Name__c) && !policyNameDefMap.containsKey(serialNoPolicyNameMap.get(sNo))){
                stgWR.Status__c = 'Failed';
                stgWR.Failure_Message__c = 'Given Policy Name not found !!!';
                continue;
            }
            WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c();
            if(serialNumberPreDelList.contains(sNo)){
                wr.ATI_Pre_Delivery__c = true;
                wr.ATI_isExtended__c = false;
            } else {
                wr.ATI_isExtended__c= ATI_Utils.checkIsNotBlankData(stgWR.Ext_Warranty_Policy_Name__c);
            }
            wr.WOD_2__Registration_Type__c = 'Standard Registration';
            wr.WOD_2__Account__c = inv.WOD_2__Account__c;
            wr.WOD_2__Inventory__c = inv.Id;
            wr.WOD_2__Status__c = 'Draft';
            wr.WOD_2__Customer__c = inv.WOD_2__Customer__c;
            wr.WOD_2__Install_Date__c = ATI_Utils.checkIsBlankData(stgWR.Install_Date__c) ? inv.WOD_2__Install_Date__c : ATI_Utils.parseDate(stgWR.Install_Date__c);
            wr.ATI_Extended_Warranty_Purchase_Date__c = stgWR.EW_Purchase_Date__c;
            wr.ATI_PO_Number__c = stgWR.PO_Number__c;
            wr.WOD_2__Registration_Date__c =  stgWR.Registration_Date__c == null ? System.today() : stgWR.Registration_Date__c; 
            wr.ATI_CE_Number__c = stgWR.CE_Number__c;
            wr.ATI_Close_Date__c = stgWr.Close_Date__c;
            wr.ATI_Contract_Number__c = stgWR.Contract_Number__c;
            wr.ATI_Disposition_Code__c = stgWR.Disposition_Code__c;
            wr.ATI_Exchange_Rate__c = stgWR.Exchange_Rate__c;
            wr.ATI_Tracking_Number__c = stgWR.Tracking_Number__c;
            wr.ATI_Vocation_Code__c = inv.ATI_Vocation_Code__c;
            wr.WOD_2__Warranty_Product__c = inv.WOD_2__Item__c;
            wrList.add(wr);
        }
        Database.SaveResult[] saveResultList = Database.insert(wrList, false);
        List<Id> wrIdList = new List<Id>(); 
        List<STG_WR_Load__c> failedRecords = new List<STG_WR_Load__c>();
        for(integer i =0; i < wrList.size(); i++){
            if(saveResultList[i].isSuccess()){
                wrIdList.add(saveResultList[i].getId());
            } else {
                String sNo = invIdSNoMap.get(wrList.get(i).WOD_2__Inventory__c);
                System.debug(serialNoStgRecMap);
                System.debug(serialNoInvMap);
                STG_WR_Load__c stgWR = serialNoStgRecMap.get(sNo);
                stgWR.Failure_Message__c = JSON.serialize(saveResultList[i].getErrors());
                stgWR.Status__c = 'Failed';
                failedRecords.add(stgWR);
            }
        }
		update failedRecords;         
        return wrIdList;
    }
}