/**
* (c) 2020 Tavant Technology.
----------------------------------------------------------------------------------------------------
ATI_BulkClaimService, service class for Bulk Claim Creation
* --------------------------------------------------------------------------------------------------
* @author         (Tavant)
* @version        1.0
* @created        08-FEB-2021
* @modified
* --------------------------------------------------------------------------------------------------
* @changes        
* --------------------------------------------------------------------------------------------------
*/

public without sharing class ATI_BulkClaimService {
    static List<WOD_2.CLM_ClaimCreateInputWrapper> cciwList= new List<WOD_2.CLM_ClaimCreateInputWrapper>();
    static List<WOD_2.CLM_ClaimCreateOutputWrapper> ccowList = new List<WOD_2.CLM_ClaimCreateOutputWrapper>();
    static ATI_CLM_ClaimBaseOverrideHook claimbaseOverrideHookObj = new ATI_CLM_ClaimBaseOverrideHook();
    static List<twodcms.CampaignClaimWrapper> campaignMemberWrapperLst{get; set;}
    public static String errorStr ='';
    
    private static List<ATI_Diagnostic_Code__c> diagnosticCodeLst{get; private set;}
    private static List<WOD_2__Claim_Part__c> claimInstallPartsList{get; private set;}
    //private static List<WOD_2__Removed_Claim_Part__c> remPartList{get; private set;}
    private static List<WOD_2__Claim_Service_Information__c> laborCodeLst{get; private set;}
    private static List<WOD_2__Other_Cost__c> otherCostList{get; private set;}
    
    private static Map<String,ATI_Diagnostic_Code__c> diagCodeMap{get; private set;}
    private static Map<String,WOD_2__Claim_Part__c> partMap{get; private set;}
    //private static Map<String,WOD_2__Removed_Claim_Part__c> remPartMap{get; private set;}
    private static Map<String,WOD_2__Claim_Service_Information__c> laborMap{get; private set;}
    private static Map<String,WOD_2__Other_Cost__c> otherCostMap{get; private set;}
    
    private static Set<string> diagnosticSet{get; private set;}
    private static Set<string> partSet{get; private set;}
    //private static Set<string> removedPartSet{get; private set;}
    private static Set<string> laborSet{get; private set;}
    private static Set<string> otherCostSet{get; private set;}
    
    private static List<ATI_Diagnostic_Code__c> diagnosticDeleteList{get; private set;}
    private static List<WOD_2__Claim_Part__c> partDeleteList{get; private set;}
    //private static List<WOD_2__Removed_Claim_Part__c> removedPartDeleteList{get; private set;}
    private static List<WOD_2__Claim_Service_Information__c> laborDeleteList{get; private set;}
    private static List<WOD_2__Other_Cost__c> otherCostDeleteList{get; private set;}
    
    private static Map<Id,WOD_2__Inventory__c> inventoryMap{get; private set;}
    
    
    private static void processChildData(WOD_2__Claim__c claimObj, List<WOD_2__Claim_Part__c> partList, List<WOD_2__Claim_Service_Information__c> laborList, List<WOD_2__Other_Cost__c> ocList, List<ATI_Diagnostic_Code__c> dcList){
        for(WOD_2__Claim_Part__c partRec : claimObj.WOD_2__Claim_Parts__r){
            partMap.put(partRec.WOD_2__Warranty_Product__r.Name,partRec);
        }
        /*for(WOD_2__Removed_Claim_Part__c removedPartRec : claimObj.WOD_2__Removed_Claim_Parts__r){
remPartMap.put(removedPartRec.WOD_2__Warranty_Product__r.Name,removedPartRec);
}*/
        for(ATI_Diagnostic_Code__c diagnosticRec : claimObj.Diagnostic_Codes__r){
            diagCodeMap.put(diagnosticRec.Warranty_Code__r.Name,diagnosticRec);
        }
        for(WOD_2__Claim_Service_Information__c laborRec : claimObj.WOD_2__Claim_Service_Informations__r){
            laborMap.put(laborRec.WOD_2__Service_Job_Code__r.Name,laborRec);
        }
        for(WOD_2__Other_Cost__c otherCostRec : claimObj.WOD_2__Other_Costs__r){
            otherCostMap.put(otherCostRec.WOD_2__Cost_Category_Type__c,otherCostRec);
        }
        
        getInstallPartsData(claimObj, partList);
        getClaimServiceInfoDetails(claimObj, laborList);
        getOtherCostDetails(claimObj, ocList);
        getDiagnosticCodeInfoDetails(claimObj, dcList);
        
        if(!diagnosticDeleteList.isEmpty()){
            delete diagnosticDeleteList;
        }
        if(!partDeleteList.isEmpty()){
            delete partDeleteList;
        }
        /*if(!removedPartDeleteList.isEmpty()){
delete removedPartDeleteList;
}*/
        if(!laborDeleteList.isEmpty()){
            delete laborDeleteList;
        }
        if(!otherCostDeleteList.isEmpty()){
            delete otherCostDeleteList;
        }
        
    }
    
    private static void getDiagnosticCodeInfoDetails(WOD_2__Claim__c claimObj, List<ATI_Diagnostic_Code__c> dcList){
        for(ATI_Diagnostic_Code__c dcObj : dcList){
            if(!diagCodeMap.containsKey(dcObj.Warranty_Code__r.Name)){
                diagnosticCodeLst.add(dcObj);
            }
            diagnosticSet.add(dcObj.Warranty_Code__r.Name);
        }
        
        for(String dcName : diagCodeMap.keyset()){
            if(!diagnosticSet.contains(dcName)){
                diagnosticDeleteList.add(diagCodeMap.get(dcName));
            }
        }
    }
    
    private static void getInstallPartsData(WOD_2__Claim__c claimObj, List<WOD_2__Claim_Part__c> partList){
        for(WOD_2__Claim_Part__c installedPartObj : partList){
            if(partMap.containsKey(installedPartObj.Name)){
                installedPartObj.Id = partMap.get(installedPartObj.Name).Id;
            }
            partSet.add(installedPartObj.Name);
            claimInstallPartsList.add(installedPartObj);
        }
        for(String partName : partMap.keyset()){
            if(!partSet.contains(partName)){
                partDeleteList.add(partMap.get(partName));
            }
        }
    }
    
    private static void getClaimServiceInfoDetails(WOD_2__Claim__c claimObj, List<WOD_2__Claim_Service_Information__c> laborList){
        for(WOD_2__Claim_Service_Information__c laborObj : laborList){
            if(laborMap.containsKey(laborObj.Name)){
                laborObj.Id = laborMap.get(laborObj.Name).Id;
            }
            laborSet.add(laborObj.Name);
            laborCodeLst.add(laborObj);
        }
        
        for(String laborName : laborMap.keyset()){
            if(!laborSet.contains(laborName)){
                laborDeleteList.add(laborMap.get(laborName));
            }
        }
    }
    
    private static void getOtherCostDetails(WOD_2__Claim__c claimObj, List<WOD_2__Other_Cost__c> ocList){
        for(WOD_2__Other_Cost__c ocObj : ocList){
            if(otherCostMap.containsKey(ocObj.WOD_2__Cost_Category_Type__c)){
                ocObj.Id = otherCostMap.get(ocObj.WOD_2__Cost_Category_Type__c).Id;
            }
            otherCostSet.add(ocObj.WOD_2__Cost_Category_Type__c);
            otherCostList.add(ocObj);
        }
        
        for(String ocName : otherCostMap.keyset()){
            if(!otherCostSet.contains(ocName)){
                otherCostDeleteList.add(otherCostMap.get(ocName));
            }
        }
    }
    
    public static WOD_2.ResponseWrapper saveClaimInfo(String batchLogId,sObject claimObject, List<WOD_2__Claim_Part__c> partList, 
                                                      List<WOD_2__Claim_Service_Information__c> laborList, List<WOD_2__Other_Cost__c> ocList, 
                                                      List<ATI_Diagnostic_Code__c> dcList,sObject ServiceCampaign,sObject claimTemplate,
                                                      sObject customerInfoSObject,sObject vehicleInfoSObject,sObject wrInfoSObject)
    {
        System.debug('claimObject>>>> '+claimObject);
        System.debug('claimObject>>>> '+partList);
        System.debug('claimObject>>>> '+laborList);
        System.debug('claimObject>>>> '+ocList);
        System.debug('claimObject>>>> '+dcList);
        System.debug('customerInfoSObject>>>> '+customerInfoSObject);
        System.debug('vehicleInfoSObject>>>> '+vehicleInfoSObject);
        System.debug('wrInfoSObject>>>> '+wrInfoSObject);
        System.debug('claimObject>>>> '+claimTemplate);
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        WOD_2.CLM_ClaimCreateInputWrapper cciw = new WOD_2.CLM_ClaimCreateInputWrapper();
        campaignMemberWrapperLst = new List<twodcms.CampaignClaimWrapper>();
        
        Map<Id, Map<String, List<WOD_2__Rates_Details__c>>> accountRatesMap = new Map<Id, Map<String, List<WOD_2__Rates_Details__c>>>();
        Savepoint sp = Database.setSavepoint();
        try{
            inventoryMap = new Map<Id,WOD_2__Inventory__c>();
            WOD_2__Claim__c claim = (WOD_2__Claim__c)claimObject;
            WOD_2__Claim__c claimTemplateObj = (WOD_2__Claim__c)claimTemplate;
            ATI_Vehicle_Information__c vehicleInfoObj = (ATI_Vehicle_Information__c)vehicleInfoSObject;
            Account customerInfoObj = (Account)customerInfoSObject;
            WOD_2__Warranty_Registration__c wrInfoObj = (WOD_2__Warranty_Registration__c)wrInfoSObject;
            
            twodcms__Service_Campaign__c serviceClaim = (twodcms__Service_Campaign__c)ServiceCampaign;
            System.debug('>>> claim.Name :'+claim.Name);
            
            //assign replacement model
            if(claim.ATI_Replacement_Claims__c == true){
                WOD_2__Inventory__c replaceInv = [SELECT Id,WOD_2__Item__c FROM WOD_2__Inventory__c WHERE Id=:claim.ATI_Replaced_Inventory__c];
                claim.ATI_Replaced_Model__c = replaceInv.WOD_2__Item__c;
            }else{
                claim.ATI_Replaced_Model__c = NULL;
                claim.ATI_Replaced_Inventory__c = NULL;
                claim.ATI_Replacement_Type__c = NULL;
            }
            //Alsn-182   
            Set<Id> instwrprdt =new Set<Id>();
            for(WOD_2__Claim_Part__c clmprt:partList){
                instwrprdt.add(clmprt.WOD_2__Warranty_Product__c);
            }                       
            List<WOD_2__Warranty_Product__c> wrprd = [Select id,WOD_2__Item_Type__c,WOD_2__Track_Type__c from WOD_2__Warranty_Product__c where (Id=:claim.WOD_2__Causal_Part_Number__c or Id in:instwrprdt)];
            for(WOD_2__Warranty_Product__c wprod:wrprd){
                if(wprod.WOD_2__Item_Type__c == 'Part' && wprod.WOD_2__Track_Type__c == 'Non-Serialized'){
                    claim.WOD_2__Causal_Part_Serial_Number__c =NULL; 
                    claim.WOD_2__Part_Serial_Number__c =NULL;
                    for(WOD_2__Claim_Part__c partLst:partList){
                        partLst.WOD_2__Serial_Number__c =NULL;
                    }         
                }
            }           
            //end of Alsn-182
           
            //System.debug('>>> claim.WOD_2__Claim_Status__c :'+claim.WOD_2__Claim_Status__c);
            if(claim.Name !='' && claim.Name !=null){ // && claim.WOD_2__Claim_Status__c =='Draft'
                System.debug('>>> Update Claim Case :'); 
                List<WOD_2__Claim__c> claimList = [SELECT id,WOD_2__Claim_Status__c,WOD_2__Date_Of_Repair__c,WOD_2__Inventory__c,WOD_2__Units_Usage__c,WOD_2__Date_Of_Failure__c,
                                                   Name,WOD_2__Account__c,WOD_2__BusinessCategory__c,WOD_2__Rate__c,WOD_2__Model_Number__c,WOD_2__Work_Performed_Comments__c,ATI_Replaced_Inventory__c,
                                                   CurrencyIsoCode,ATI_Complaint_Code__c,ATI_Failure_Code__c,ATI_Failure_Location__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Replacement_Type__c,
                                                   ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Vehicle_Arrival_Date_Time__c,
                                                   ATI_Completed_Repair_Cust_Noti_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Customer_Requests_Service_Date__c,
                                                   ATI_Repair_Order_Open_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Claim_Type__c,
                                                   ATI_Exchange_Rate__c,ATI_Replacement_Claims__c,WOD_2__Causal_Part_Number__c,ATI_WR_Details__c,ATI_Tracking_Number__c,
                                                   (SELECT id,WOD_2__Warranty_Product__r.Name FROM WOD_2__Claim_Parts__r),
                                                   (SELECT id,WOD_2__Warranty_Product__r.Name FROM WOD_2__Removed_Claim_Parts__r),
                                                   (SELECT id,Warranty_Code__r.Name FROM Diagnostic_Codes__r),
                                                   (SELECT id,WOD_2__Service_Job_Code__r.Name FROM WOD_2__Claim_Service_Informations__r),
                                                   (SELECT id,WOD_2__Cost_Category_Type__c FROM WOD_2__Other_Costs__r)  
                                                   FROM WOD_2__Claim__c WHERE Name =: claim.Name];
                
                if(claimList.isEmpty()){
                    responseWrapperObj.status = false;
                    responseWrapperObj.errormessage = 'Claim Number is not valid.';
                    return responseWrapperObj;
                }else{
                    if(!claimList.isEmpty() && !claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Draft') && 
                       !claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Paid') &&
                       !claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Rejected') &&
                       !claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Submitted') &&
                       !claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Additional Information Required'))
                    {
                        responseWrapperObj.status = false;
                        responseWrapperObj.errormessage = 'You cannot edit this claim.';
                        return responseWrapperObj;
                    }else if(!claimList.isEmpty() && claimList[0].WOD_2__Inventory__c != claim.WOD_2__Inventory__c){
                        responseWrapperObj.status = false;
                        responseWrapperObj.errormessage = 'SerialNumber is not matching.';
                        return responseWrapperObj;
                    }else if(claimList[0].ATI_Tracking_Number__c!= NULL && claimList[0].ATI_Tracking_Number__c!= claim.ATI_Tracking_Number__c){
                        responseWrapperObj.status = false;
                        responseWrapperObj.errormessage = 'Tracking Number is not matching.';
                        return responseWrapperObj;
                    }
                    else{
                        System.debug('queries before reopen ' + Limits.getQueries());
                        accountRatesMap = ATI_CLM_RatesOverride.getAccountRatesMap(new Set<Id>{claimList[0].WOD_2__Account__c});
                        if(claim.WOD_2__Units_Usage__c != NULL) claimList[0].WOD_2__Units_Usage__c  = claim.WOD_2__Units_Usage__c;
                        if(claim.WOD_2__Work_Performed_Comments__c != NULL) claimList[0].WOD_2__Work_Performed_Comments__c  = claim.WOD_2__Work_Performed_Comments__c;
                        if(claim.WOD_2__Date_Of_Failure__c != NULL) claimList[0].WOD_2__Date_Of_Failure__c  = claim.WOD_2__Date_Of_Failure__c;
                        if(claim.WOD_2__Date_Of_Repair__c != NULL) claimList[0].WOD_2__Date_Of_Repair__c  = claim.WOD_2__Date_Of_Repair__c;
                        if(claim.ATI_Complaint_Code__c != NULL) claimList[0].ATI_Complaint_Code__c  = claim.ATI_Complaint_Code__c;
                        if(claim.ATI_Failure_Code__c != NULL) claimList[0].ATI_Failure_Code__c  = claim.ATI_Failure_Code__c;
                        if(claim.ATI_Failure_Location__c != NULL) claimList[0].ATI_Failure_Location__c  = claim.ATI_Failure_Location__c;
                        
                        if(claim.ATI_First_Labor_Applied_Date_Time__c != NULL) claimList[0].ATI_First_Labor_Applied_Date_Time__c  = claim.ATI_First_Labor_Applied_Date_Time__c;
                        if(claim.ATI_First_Part_Ordered_Date_Time__c != NULL) claimList[0].ATI_First_Part_Ordered_Date_Time__c  = claim.ATI_First_Part_Ordered_Date_Time__c;
                        if(claim.ATI_Last_Part_Arrival_Date_Time__c != NULL) claimList[0].ATI_Last_Part_Arrival_Date_Time__c  = claim.ATI_Last_Part_Arrival_Date_Time__c;
                        if(claim.ATI_Repair_Order_Closed_Date_Time__c != NULL) claimList[0].ATI_Repair_Order_Closed_Date_Time__c  = claim.ATI_Repair_Order_Closed_Date_Time__c;
                        if(claim.ATI_Vehicle_Arrival_Date_Time__c != NULL) claimList[0].ATI_Vehicle_Arrival_Date_Time__c  = claim.ATI_Vehicle_Arrival_Date_Time__c;
                        if(claim.ATI_Completed_Repair_Cust_Noti_Date__c != NULL) claimList[0].ATI_Completed_Repair_Cust_Noti_Date__c  = claim.ATI_Completed_Repair_Cust_Noti_Date__c;
                        if(claim.ATI_Distributor_schedules_cust_Serv_Date__c != NULL) claimList[0].ATI_Distributor_schedules_cust_Serv_Date__c  = claim.ATI_Distributor_schedules_cust_Serv_Date__c;
                        if(claim.ATI_Customer_Requests_Service_Date__c != NULL) claimList[0].ATI_Customer_Requests_Service_Date__c  = claim.ATI_Customer_Requests_Service_Date__c;
                        if(claim.ATI_Repair_Order_Open_Time__c != NULL) claimList[0].ATI_Repair_Order_Open_Time__c  = claim.ATI_Repair_Order_Open_Time__c;
                        if(claim.ATI_Last_Labor_Recorded_Time__c != NULL) claimList[0].ATI_Last_Labor_Recorded_Time__c  = claim.ATI_Last_Labor_Recorded_Time__c;
                        if(claimList[0].WOD_2__Claim_Status__c.equalsIgnoreCase('Paid')){
                            claimList[0].WOD_2__Claim_Status__c = 'Reopened';
                            claimList[0].ATI_Is_Claim_Appealed_Or_Reopened__c = true;
                        }
                        
                        inventoryMap = new Map<Id,WOD_2__Inventory__c>([SELECT id,WOD_2__Scrapped__c,ATI_Warranty_Void__c,ATI_Active__c,WOD_2__Account__c,WOD_2__Type__c,WOD_2__Serial_Number__c,WOD_2__Business_Unit__c,WOD_2__Item__c,WOD_2__Item__r.WOD_2__Description__c,WOD_2__Item__r.WOD_2__Parent_Product__c,WOD_2__Customer__c,
                                                                        (SELECT Id,ATI_Vehicle_Information__c,ATI_Inventory__c,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c,ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Engine_Make__c,ATI_Vehicle_Information__r.ATI_Engine_Model__c,
                                                                         ATI_Vehicle_Information__r.ATI_Engine_Year__c,ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c,ATI_Vehicle_Information__r.ATI_Vocation_Code__c FROM Transmissions__r ORDER BY CreatedDate DESC Limit 1)
                                                                        FROM WOD_2__Inventory__c WHERE Id =:claim.WOD_2__Inventory__c]);
                        
                        if(!inventoryMap.values().isEmpty() && inventoryMap.values()[0].Transmissions__r.size() > 0){
                            ATI_Vehicle_Information__c vehicleInfoToUpdateObj = new ATI_Vehicle_Information__c(Id=inventoryMap.values()[0].Transmissions__r[0].ATI_Vehicle_Information__c);
                            if(vehicleInfoObj.ATI_Vehicle_Model__c != NULL) vehicleInfoToUpdateObj.ATI_Vehicle_Model__c  = vehicleInfoObj.ATI_Vehicle_Model__c;
                            if(vehicleInfoObj.ATI_Vehicle_Make__c != NULL) vehicleInfoToUpdateObj.ATI_Vehicle_Make__c  = vehicleInfoObj.ATI_Vehicle_Make__c;
                            if(vehicleInfoObj.ATI_Engine_Make__c != NULL) vehicleInfoToUpdateObj.ATI_Engine_Make__c  = vehicleInfoObj.ATI_Engine_Make__c;
                            if(vehicleInfoObj.ATI_Engine_Year__c != NULL) vehicleInfoToUpdateObj.ATI_Engine_Year__c  = vehicleInfoObj.ATI_Engine_Year__c;
                            if(vehicleInfoObj.ATI_Engine_Model__c != NULL) vehicleInfoToUpdateObj.ATI_Engine_Model__c  = vehicleInfoObj.ATI_Engine_Model__c;
                            if(vehicleInfoObj.ATI_Customer_asset_number__c != NULL) vehicleInfoToUpdateObj.ATI_Customer_asset_number__c  = vehicleInfoObj.ATI_Customer_asset_number__c;
                            if(vehicleInfoObj.ATI_Executive_order_Designation__c != NULL) vehicleInfoToUpdateObj.ATI_Executive_order_Designation__c  = vehicleInfoObj.ATI_Executive_order_Designation__c;
                            
                            TriggerHandler.bypass('ATI_VehicleInformationController');
                            update vehicleInfoToUpdateObj;
                            TriggerHandler.clearBypass('ATI_VehicleInformationController');
                        }
                        
                        WOD_2.ResponseWrapper beforeClaimSaveWrapper = claimbaseOverrideHookObj.beforeClaimSave(claimList[0]);
                        System.debug('queries after hook ' + Limits.getQueries());
                        if(beforeClaimSaveWrapper.status){
                            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
                            update claimList[0];
                            TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
                            System.debug('queries after reopen ' + Limits.getQueries());
                            diagCodeMap = new Map<String,ATI_Diagnostic_Code__c>();
                            partMap = new Map<String,WOD_2__Claim_Part__c>();
                            //remPartMap = new Map<String,WOD_2__Removed_Claim_Part__c>();
                            laborMap = new Map<String,WOD_2__Claim_Service_Information__c>();
                            otherCostMap = new Map<String,WOD_2__Other_Cost__c>();
                            
                            diagnosticCodeLst = new List<ATI_Diagnostic_Code__c>();
                            claimInstallPartsList = new List<WOD_2__Claim_Part__c>();
                            //remPartList = new List<WOD_2__Removed_Claim_Part__c>();
                            laborCodeLst = new List<WOD_2__Claim_Service_Information__c>();
                            otherCostList = new List<WOD_2__Other_Cost__c>();
                            
                            diagnosticSet = new Set<String>();
                            partSet = new Set<String>();
                            //removedPartSet = new Set<String>();
                            laborSet = new Set<String>();
                            otherCostSet = new Set<String>();
                            
                            diagnosticDeleteList = new List<ATI_Diagnostic_Code__c>();
                            partDeleteList = new List<WOD_2__Claim_Part__c>();
                            //removedPartDeleteList = new List<WOD_2__Removed_Claim_Part__c>();
                            laborDeleteList = new List<WOD_2__Claim_Service_Information__c>();
                            otherCostDeleteList = new List<WOD_2__Other_Cost__c>();
                            
                            processChildData(claimList[0],partList,laborList,ocList,dcList);
                            System.debug('queries processChildData ' + Limits.getQueries());
                            System.debug('claimList[0].id>>>>> '+claimList[0].id);
                            
                            ATI_BulkClaimService.saveDiagnosticCodes(diagnosticCodeLst, claimList[0]);
                            System.debug('queries saveDiagnosticCodes ' + Limits.getQueries());
                            
                            ATI_BulkClaimService.saveParts(claimInstallPartsList, claimList[0]);
                            System.debug('queries saveParts ' + Limits.getQueries());
                            
                            ATI_BulkClaimService.saveLabors(laborCodeLst, claimList[0],accountRatesMap);
                            System.debug('queries saveLabors ' + Limits.getQueries());
                            
                            saveOtherCosts(otherCostList, claimList[0]);
                            System.debug('queries saveOtherCosts ' + Limits.getQueries());
                            if(errorStr !=''){
                                Database.rollback(sp);
                                responseWrapperObj.status = false;
                                responseWrapperObj.data = String.valueOf(claimList[0].id).substring(0, 15);
                                responseWrapperObj.errormessage =errorStr;
                            }else{
                                responseWrapperObj.status = true;
                                responseWrapperObj.data = claimList[0].Id;
                            }  
                        }else{
                            Database.rollback(sp);
                            responseWrapperObj.status = false;
                            responseWrapperObj.errormessage = beforeClaimSaveWrapper.errormessage;
                        }              
                    }
                }
            }
            else{
                cciw.claimObject = claim;
                cciw.claimType =  claim.WOD_2__Claim_Type__c;
                WOD_2.ResponseWrapper beforeClaimSaveWrapper = claimbaseOverrideHookObj.beforeClaimSave(claim);
                
                //Warranty registration for stock claim
                processWRForStockInventory(claim, vehicleInfoObj,customerInfoObj,wrInfoObj);
                claim.ATI_isPreDelivery__c = (wrInfoObj.ATI_Pre_Delivery__c == true) ? true : false;
                //Anjali added
                if(claim.WOD_2__Claim_Type__c =='Campaign'){
                    twodcms.CampaignClaimWrapper campaignClaimMember = new twodcms.CampaignClaimWrapper();
                    Set<Id> campaignclaimIdSet = new Set<Id>();
                    String buId;
                    campaignClaimMember.campaignClaimObject = claim;
                    
                    //Added by Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
                    List<WOD_2__Claim__c> claimLst = [SELECT Id FROM WOD_2__Claim__c 
                                                      WHERE WOD_2__Account__c =:claim.WOD_2__Account__c 
                                                      AND ATI_Tracking_Number__c = :claim.ATI_Tracking_Number__c];
                    if(claimLst.size() > 0 && claimLst[0].Id != claim.Id){
                        return new WOD_2.ResponseWrapper('', false, Label.ATI_TrackingNumberisnotvalid);
                    }
                    //End here by Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
                    List<twodcms__Campaign_Claim_Template_Association__c> mapservice= [SELECT Id,twodcms__Service_Campaign__r.twodcms__Status__c,twodcms__Claim_Template__r.name,twodcms__Service_Campaign__r.name,twodcms__Service_Campaign__r.twodcms__Applicable_for_all__c FROM twodcms__Campaign_Claim_Template_Association__c
                                                                                       WHERE twodcms__Claim_Template__r.name =: claimTemplateObj.Name AND twodcms__Service_Campaign__r.name =:serviceClaim.Name];
                    
                    if(!mapservice.isEmpty()){
                        if(mapservice[0].twodcms__Service_Campaign__r.twodcms__Status__c=='Active'){
                            for(twodcms__Campaign_Claim_Template_Association__c campaignClaimTemp : mapservice){
                                campaignClaimMember.cctaObject =campaignClaimTemp;
                            }
                            campaignMemberWrapperLst.add(campaignClaimMember);
                            campaignMemberWrapperLst = twodcms.ServiceCampaignUtility.saveCampaignClaims(campaignMemberWrapperLst);
                        }
                        else if(mapservice[0].twodcms__Service_Campaign__r.twodcms__Status__c=='Inactive'){
                            responseWrapperObj.errormessage = errorStr +'Inactive Service Campaign';
                            System.debug('response Inactve--->'+responseWrapperObj.errormessage);  
                        }
                        else if(mapservice[0].twodcms__Service_Campaign__r.twodcms__Status__c=='Draft'){
                            responseWrapperObj.errormessage = errorStr +'Draft Service Campaign';
                        }
                        else
                        {
                            responseWrapperObj.errormessage = errorStr +'Invalid Campaign Details';
                        }
                    }
                    else{
                        responseWrapperObj.errormessage = errorStr +'Invalid Campaign Mapping';
                    }
                    
                    WOD_2__Claim__c claimRec = new WOD_2__Claim__c();
                    if(!campaignMemberWrapperLst.isEmpty()){
                        for(integer i=0;i<campaignMemberWrapperLst.size();i++){
                            claimRec = campaignMemberWrapperLst.get(i).campaignClaimObject;
                            if(campaignMemberWrapperLst.get(i).status){
                                campaignclaimIdSet.add(claimRec.Id);
                                buId = claimRec.WOD_2__BusinessCategory__c;
                            }
                        }
                        Map<Id,twodcms.CampaignClaimWrapper> claimIdCampWrapper = twodcms.ServiceCampaignUtility.saveCampaginClaimRelatedList(campaignclaimIdSet,buId);
                        
                    }       
                    
                    if(!campaignMemberWrapperLst.isEmpty() && campaignMemberWrapperLst[0].status && claim.WOD_2__Claim_Type__c =='Campaign'){
                        accountRatesMap = ATI_CLM_RatesOverride.getAccountRatesMap(new Set<Id>{campaignMemberWrapperLst[0].campaignClaimObject.WOD_2__Account__c});
                        if(!dcList.isEmpty()){
                            ATI_BulkClaimService.saveDiagnosticCodes(dcList, campaignMemberWrapperLst[0].campaignClaimObject);
                        }
                        if(!partList.isEmpty()){
                            ATI_BulkClaimService.saveParts(partList, campaignMemberWrapperLst[0].campaignClaimObject);
                        }
                        if(!laborList.isEmpty()){
                            ATI_BulkClaimService.saveLabors(laborList, campaignMemberWrapperLst[0].campaignClaimObject,accountRatesMap);
                        }
                        if(!ocList.isEmpty()){
                            saveOtherCosts(ocList, campaignMemberWrapperLst[0].campaignClaimObject);
                        }
                        if(errorStr!=''){
                            Database.rollback(sp);
                            responseWrapperObj.status = false;
                            responseWrapperObj.data = String.valueOf(campaignMemberWrapperLst[0].campaignClaimObject.Id).substring(0, 15);
                            responseWrapperObj.errormessage = errorStr;
                        }else{
                            responseWrapperObj.status = true;
                            responseWrapperObj.data = campaignMemberWrapperLst[0].campaignClaimObject.Id;
                        }
                    }
                    else{
                        if(!campaignMemberWrapperLst.isEmpty() && claim.WOD_2__Claim_Type__c =='Campaign'){
                            responseWrapperObj.errormessage = campaignMemberWrapperLst[0].msg;
                            Database.rollback(sp);
                        }
                    }
                }
                //End of modification
                
                else if(beforeClaimSaveWrapper.status){
                    if(claim.WOD_2__Claim_Type__c =='Machine'){
                        cciwList.add(cciw);
                        ccowList = WOD_2.CLM_UnmanagedUtility.saveMachineClaims(cciwList);
                    } 
                    else if(claim.WOD_2__Claim_Type__c =='Part'){
                        System.debug('claim>>>>> '+claim);
                        cciwList.add(cciw);
                        ccowList = WOD_2.CLM_UnmanagedUtility.savePartClaims(cciwList);   //savePartClaim(cciwList);
                    }
                    
                    if(!ccowList.isEmpty() && ccowList[0].status && claim.WOD_2__Claim_Type__c !='Campaign'){
                        accountRatesMap = ATI_CLM_RatesOverride.getAccountRatesMap(new Set<Id>{ccowList[0].claimObject.WOD_2__Account__c});
                        System.debug('ccowList>>>>> '+ccowList[0].claimObject.Id);
                        ATI_BulkClaimService.saveDiagnosticCodes(dcList, ccowList[0].claimObject);
                        ATI_BulkClaimService.saveParts(partList, ccowList[0].claimObject);
                        ATI_BulkClaimService.saveLabors(laborList, ccowList[0].claimObject,accountRatesMap);
                        saveOtherCosts(ocList, ccowList[0].claimObject);
                        if(errorStr!=''){
                            Database.rollback(sp);
                            System.debug('ccowList[0].claimObject>>>>> '+ccowList[0].claimObject);
                            System.debug('ccowList[0].claimObject.Name>>>>> '+String.valueOf(ccowList[0].claimObject.Id).substring(0, 15));
                            //System.debug('ccowList[0].claimObject.Id>>>>> '+ccowList[0].claimObject.Id);
                            responseWrapperObj.status = false;
                            responseWrapperObj.data = String.valueOf(ccowList[0].claimObject.Id).substring(0, 15);
                            responseWrapperObj.errormessage = errorStr;
                        }else{
                            
                            responseWrapperObj.status = true;
                            responseWrapperObj.data = ccowList[0].claimObject.Id;
                        }
                    }
                    
                    else{
                        if(!ccowList.isEmpty() && claim.WOD_2__Claim_Status__c !='Campaign'){
                            responseWrapperObj.errormessage = ccowList[0].msg;
                            Database.rollback(sp);
                        }
                        else{
                            responseWrapperObj.errormessage = campaignMemberWrapperLst[0].msg;
                            Database.rollback(sp);
                        }
                    }
                }
                
                else{
                    Database.rollback(sp);
                    responseWrapperObj.errormessage = beforeClaimSaveWrapper.errormessage;
                }
            }
            System.debug('responseWrapperObj---in after all if--'+responseWrapperObj);
            return responseWrapperObj;
            
        }catch(System.DmlException e) {
            system.debug('DmlException>>> '+e);
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('',false,e.getDmlMessage(0));
        }catch (Exception e) {
            System.debug('catch Exception>>>>>> '+e.getMessage()+' >>>>> '+e.getLineNumber());
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    
    private static void processWRForStockInventory(WOD_2__Claim__c claimObj, ATI_Vehicle_Information__c vehicleInfoObj, Account customerInfoObj, WOD_2__Warranty_Registration__c wrInfoObj){
        String registrationType = (wrInfoObj.ATI_Pre_Delivery__c == false) ? 'Standard Registration' : 'Pre-Delivery';
        String invType = (wrInfoObj.ATI_Pre_Delivery__c == false) ? 'Retail' : 'Stock';
        inventoryMap = new Map<Id,WOD_2__Inventory__c>([SELECT id,WOD_2__Scrapped__c,ATI_Warranty_Void__c,ATI_Active__c,WOD_2__Account__c,WOD_2__Type__c,WOD_2__Serial_Number__c,WOD_2__Business_Unit__c,WOD_2__Item__c,WOD_2__Item__r.WOD_2__Description__c,WOD_2__Item__r.WOD_2__Parent_Product__c,WOD_2__Customer__c,
                                                        (Select id,ATI_Pre_Delivery__c,WOD_2__Account__c,WOD_2__Inventory__c,ATI_Vocation_Code__c,WOD_2__Warranty_Product__c,WOD_2__Registration_Date__c,WOD_2__Status__c,WOD_2__Customer__c,
                                                         WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,WOD_2__Units_Usage__c,WOD_2__Inventory__r.WOD_2__Type__c,WOD_2__Install_Date__c from WOD_2__Warranty_Registration__r 
                                                         WHERE WOD_2__Registration_Type__c = :registrationType AND ((WOD_2__Status__c='Draft' AND WOD_2__Inventory__r.WOD_2__Type__c ='Stock') OR (WOD_2__Status__c ='Registered' AND WOD_2__Inventory__r.WOD_2__Type__c =:invType)) ORDER BY CreatedDate DESC Limit 2),
                                                        (SELECT Id,ATI_Vehicle_Information__c,ATI_Inventory__c,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c,ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Engine_Make__c,ATI_Vehicle_Information__r.ATI_Engine_Model__c,
                                                         ATI_Vehicle_Information__r.ATI_Engine_Year__c,ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c,ATI_Vehicle_Information__r.ATI_Vocation_Code__c FROM Transmissions__r ORDER BY CreatedDate DESC Limit 1)
                                                        FROM WOD_2__Inventory__c WHERE Id =:claimObj.WOD_2__Inventory__c AND ATI_Warranty_Void__c=false
                                                        AND WOD_2__Scrapped__c=false AND ATI_Active__c=true]);
        
        if(!inventoryMap.values().isEmpty()){
            //process customer info
            customerInfoObj = processCustomerInfo(customerInfoObj);        
            if(inventoryMap.values()[0].WOD_2__Type__c == 'Stock'){
                //process vehicle info
                processVehicleInfo(vehicleInfoObj);
                //process warranty registration
                processWarrantyRegistration(claimObj,customerInfoObj, wrInfoObj);
            }
        }
        //Alsn-81
        claimObj.ATI_Customer_Info__c = customerInfoObj.Id;
    }
    
    private static void processVehicleInfo(ATI_Vehicle_Information__c vehicleInfoObj){
        List<ATI_Vehicle_Information__c> vehicleInfoLst = [SELECT Id FROM ATI_Vehicle_Information__c WHERE Name=:vehicleInfoObj.Name Order BY CreatedDate DESC LIMIT 1];
        if(!vehicleInfoLst.isEmpty()){
            vehicleInfoObj.Id = vehicleInfoLst[0].Id;
        }
        upsert vehicleInfoObj;
        
        //insert or update VIN transmission mapper
        if(inventoryMap.values()[0].Transmissions__r.size() > 0){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = inventoryMap.values()[0].Transmissions__r;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoObj.Id;
            update vehicleTransMapper;
        }else{
            ATI_VehicleInformationController.createVehicleInfoMapper(new Map<Id,ATI_Vehicle_Information__c>{inventoryMap.values()[0].Id => vehicleInfoObj});
        }
    }
    
    @testvisible
    private static Account processCustomerInfo(Account customerInfoObj){
        //make name,billingcity, postalcode and other fields aswell mandatory in fieldmapping
        List<Account> accountLst = [SELECT id,WOD_2__Warranty_Account_Type__c,Name,BillingCity,BillingPostalCode,
                                    ATI_Primary_Email_Id__c,BillingCountry,BillingStreet,Phone,AccountNumber,BillingState
                                    FROM Account WHERE Name =:customerInfoObj.Name AND BillingCity =:customerInfoObj.BillingCity 
                                    AND BillingPostalCode =:customerInfoObj.BillingPostalCode 
                                    AND WOD_2__Warranty_Account_Type__c = 'Customer' LIMIT 1];
        if(!accountLst.isEmpty() && (accountLst[0].ATI_Primary_Email_Id__c != customerInfoObj.ATI_Primary_Email_Id__c || accountLst[0].BillingCountry != customerInfoObj.BillingCountry || accountLst[0].BillingStreet != customerInfoObj.BillingStreet || accountLst[0].Phone != customerInfoObj.Phone || accountLst[0].AccountNumber != customerInfoObj.AccountNumber || accountLst[0].BillingState != customerInfoObj.BillingState))
        {
            accountLst[0].ATI_Primary_Email_Id__c = customerInfoObj.ATI_Primary_Email_Id__c;
            accountLst[0].BillingCountry = customerInfoObj.BillingCountry;
            accountLst[0].BillingStreet = customerInfoObj.BillingStreet;
            accountLst[0].Phone = customerInfoObj.Phone;
            accountLst[0].AccountNumber = customerInfoObj.AccountNumber;
            accountLst[0].BillingState = customerInfoObj.BillingState;
            update accountLst[0];
            customerInfoObj = accountLst[0];
        }else if(accountLst.isEmpty()){
            customerInfoObj.ATI_Customer_Group__c = 'EU99';
            customerInfoObj.WOD_2__Warranty_Account_Type__c = 'Customer';
            insert customerInfoObj;
        }
        setCustomerOnInv(customerInfoObj.Id);
        return customerInfoObj;
    }
    
    private static void setCustomerOnInv(Id customerId){
        //Alsn-81 modified the condition to map customer only if the customer is blank on inventory
        if(inventoryMap.values()[0].WOD_2__Customer__c == NULL){
            inventoryMap.values()[0].WOD_2__Customer__c = customerId;
            update inventoryMap.values()[0];
        }
    }
    @testvisible
    private static void processWarrantyRegistration(WOD_2__Claim__c claimObj,Account customerInfoObj,WOD_2__Warranty_Registration__c wrInfoObj){
        //pre-delivery is remaining
        Boolean createWR = true;
        WOD_2__Warranty_Registration__c wrRecord = new WOD_2__Warranty_Registration__c();
        if(inventoryMap.values()[0].WOD_2__Warranty_Registration__r.size()>0){
            for(WOD_2__Warranty_Registration__c wrObj : inventoryMap.values()[0].WOD_2__Warranty_Registration__r){
                if(wrObj.WOD_2__Status__c == 'Draft'){
                    wrRecord = inventoryMap.values()[0].WOD_2__Warranty_Registration__r;
                }else{
                    createWR = false;
                    break;
                }
            }
        }
        
        if(createWR){
            wrRecord.ATI_Vocation_Code__c = wrInfoObj.ATI_Vocation_Code__c;
            inventoryMap.values()[0].ATI_Vocation_Code__c = wrInfoObj.ATI_Vocation_Code__c;
            wrRecord.WOD_2__Registration_Date__c =  System.today();
            wrRecord.WOD_2__Account__c = claimObj.WOD_2__Account__c;
            wrRecord.ATI_Pre_Delivery__c = wrInfoObj.ATI_Pre_Delivery__c; 
            //wrRecord.WOD_2__Units_Usage__c =  Decimal.valueOf(claimInfo.registrationInfo.vehicleInfo.vehicleMileage);
            wrRecord.WOD_2__Warranty_Product__c = inventoryMap.values()[0].WOD_2__Item__c;
            wrRecord.WOD_2__Inventory__c = inventoryMap.values()[0].Id;
            wrRecord.WOD_2__Status__c = 'Draft';
            if(wrRecord.ATI_Pre_Delivery__c){
                wrRecord.WOD_2__Registration_Type__c = 'Pre-delivery';
                ATI_CLM_ATPolicyQueryOverrideImpl.businessUnitId = inventoryMap.values()[0].WOD_2__Business_Unit__c;
                ATI_CLM_ATPolicyQueryOverrideImpl.preDelivery = true;
                ATI_CLM_ATPolicyQueryOverrideImpl.inventoryId = claimObj.WOD_2__Inventory__c;
                //ALSN-127 Pre-Auth policy to be picked over pre-delivery
                if(claimObj.WOD_2__Is_Pre_Authorization_Required__c){
                    ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = true;
                }
            }else{
                wrRecord.WOD_2__Registration_Type__c = 'Standard Registration';
                wrRecord.WOD_2__Install_Date__c = wrInfoObj.WOD_2__Install_Date__c;
                inventoryMap.values()[0].WOD_2__Install_Date__c = wrRecord.WOD_2__Install_Date__c;
            }
            wrRecord.WOD_2__Customer__c = customerInfoObj.Id;
            
            createWarrantyRegistration(wrRecord);
        }
    }
    
    private static void createWarrantyRegistration(WOD_2__Warranty_Registration__c wrRecord){
        WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject = new WOD_2.BR_BusinessRuleEngineWrapper();
        brInputWrapperObject.buId = inventoryMap.values()[0].WOD_2__Business_Unit__c;
        brInputWrapperObject.configType = 'Rule';
        brInputWrapperObject.moduleName = 'Warranty Registration';
        brInputWrapperObject.ruleObjectAPIName = 'ATI_Warranty_Registration__c';
        brInputWrapperObject.configNameList = null;
        brInputWrapperObject.ruleObjectIdList = new List<Id>();
        
        Database.UpsertResult[] wrList = Database.upsert(new List<WOD_2__Warranty_Registration__c>{wrRecord}, false);
        update inventoryMap.values()[0];
        for(Database.UpsertResult wrRec : wrList){
            if(wrRec.isSuccess()){
                brInputWrapperObject.ruleObjectIdList.add(wrRec.getId());
            }else{
                throw new ATI_Exception(wrRec.getErrors().get(0).getMessage());
            }
        }
        if(!brInputWrapperObject.ruleObjectIdList.isEmpty()){
            List<WOD_2.TWoD_RecordOutputWrapper> registrationOutputWrapperList = WOD_2.BR_BusinessRuleEngineUtility.invokeRecordSubmitHandler(brInputWrapperObject);
            
            List<WOD_2__Warranty_Registration__c> insertedWRList = [SELECT id, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
                                                                    WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,
                                                                    WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Units_Usage__c, 
                                                                    WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE Id IN : brInputWrapperObject.ruleObjectIdList];
            WOD_2.WR_WarrantyRegistrationResponse wrResponseWrapper = ATI_WarrantyService.runEngine(new Map<Id, WOD_2__Warranty_Registration__c>(insertedWRList), 'ATI_StandardPolicyQueryOverride');
            Map<Id, WOD_2__Warranty_Registration__c> wRMaptoUpdate = new Map<Id, WOD_2__Warranty_Registration__c>();
            List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
            for(WOD_2.WR_RegistrationResponse wr : wrResponseWrapper.response.values()) {
                if(!wr.status){
                    throw new ATI_Exception(wr.message + '  (' + wr.warrantyId + ')');
                }
                else if(wr.warrantyCoverages.size() > 0 ){
                    for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                        if(coverage.WOD_2__Policy_Definition__c != null){
                            WOD_2__Warranty_Registration__c wrWithCoverage = new WOD_2__Warranty_Registration__c();
                            wrWithCoverage.id = coverage.WOD_2__Warranty_Registration__c;
                            wrWithCoverage.WOD_2__Status__c = 'In Progress';
                            wRMaptoUpdate.put(wrWithCoverage.id, wrWithCoverage);
                            warrantyCoveragesList.add(coverage);
                        } 
                    }
                }
            }
            
            if(!warrantyCoveragesList.isEmpty()){
                Database.SaveResult[] warCovRes = Database.insert(warrantyCoveragesList, false);
                for (Database.SaveResult sr : warCovRes) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            throw new ATI_Exception(err.getMessage());               
                        }
                    }
                }
                Database.SaveResult[] wrUpdateRes = Database.update(wRMaptoUpdate.values(), false);
                for (Database.SaveResult sr : wrUpdateRes) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            throw new ATI_Exception(err.getMessage());               
                        }
                    }
                }
            }
        }
        if(!brInputWrapperObject.ruleObjectIdList.isEmpty() && wrRecord.ATI_Pre_Delivery__c == false){
            inventoryMap.values()[0].WOD_2__Type__c = 'Retail';
            inventoryMap.values()[0].WOD_2__Account__c = wrRecord.WOD_2__Account__c;
            update inventoryMap.values()[0];
        }
    }
    
    //Save DiagnosticCodes
    public static void saveDiagnosticCodes(List<ATI_Diagnostic_Code__c> dcList,WOD_2__Claim__c claim){
        if(!dcList.isEmpty()){
            system.debug('>>> dcList inMethod: '+dcList);
            Map<String,id> diaCodeNameToProductIdMap = new Map<String,id>();
            for(ATI_Diagnostic_Code__c dc : dcList){
                if(dc.Warranty_Code__c != null){
                    diaCodeNameToProductIdMap.put(dc.Warranty_Code__c, null);
                }
            }
            system.debug('>>> diaCodeNameToProductIdMap  before:'+diaCodeNameToProductIdMap);
            for(WOD_2__Warranty_Code__c wc : [SELECT id, Name FROM WOD_2__Warranty_Code__c WHERE name IN : diaCodeNameToProductIdMap.keyset() AND RecordType.DeveloperName = 'Diagnostics_Codes']){
                if(diaCodeNameToProductIdMap.containsKey(wc.Name)){
                    diaCodeNameToProductIdMap.put(wc.Name, wc.id);
                }
            }
            system.debug('>>> diaCodeNameToProductIdMap After:'+diaCodeNameToProductIdMap);
            for(ATI_Diagnostic_Code__c dc : dcList){
                if(diaCodeNameToProductIdMap.containsKey(dc.Warranty_Code__c)){
                    dc.Warranty_Code__c = diaCodeNameToProductIdMap.get(dc.Warranty_Code__c);
                    dc.Claim__c = claim.id;
                }
                else{
                    system.debug('>>> dc :'+dc);
                    errorStr+='Invalid Diagnostic Code -'+dc.Warranty_Code__c+'\n';
                    return;
                }
            }
            if(!dcList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(dcList, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {                
                        for(Database.Error err : sr.getErrors()) {
                            errorStr+=err.getMessage()+'\n';
                        }
                    }
                }
            }         
        }
    }  
    
    //Save Part
    public static void saveParts(List<WOD_2__Claim_Part__c> partList,WOD_2__Claim__c claim){
        System.debug('partList>>>> '+partList+ ' >>>> '+claim);
        if(!partList.isEmpty()){
            Map<String,id> partNameToProductIdMap = new Map<String,id>();
            //Added by Konda Susmitha ALSN-25
            Map<String,String> partNameToProductDescriptionMap = new Map<String,String>();
            for(WOD_2__Claim_Part__c part : partList){
                if(part.Name != null){
                    partNameToProductIdMap.put(part.Name, null);
                }
            }
            for(WOD_2__Warranty_Product__c wp : [SELECT id, Name, WOD_2__Description__c FROM WOD_2__Warranty_Product__c WHERE name IN : partNameToProductIdMap.keyset() AND WOD_2__Type__c='Item' AND WOD_2__Item_Type__c ='Part']){
                if(partNameToProductIdMap.containsKey(wp.Name)){
                    partNameToProductIdMap.put(wp.Name, wp.id);
                    partNameToProductDescriptionMap.put(wp.Name, wp.WOD_2__Description__c);
                }
            }
            system.debug('>>>partNameToProductDescriptionMap>>>'+partNameToProductDescriptionMap);
            Integer i =0;
            List<WOD_2.CLM_PartPriceWrapper> priceFetchList = new List<WOD_2.CLM_PartPriceWrapper>();
            ATI_CLM_PartPriceInterface partPriceInterfaceObj = new ATI_CLM_PartPriceInterface();
            for(WOD_2__Claim_Part__c part : partList){
                if(partNameToProductIdMap.containsKey(part.Name)){
                    part.WOD_2__Warranty_Product__c = partNameToProductIdMap.get(part.Name);
                    part.WOD_2__Claim__c = claim.id;
                    //Added Description by Konda Susmitha ALSN-25
                    part.WOD_2__Part_Description__c = partNameToProductDescriptionMap.get(part.Name);
                    WOD_2.CLM_PartPriceWrapper priceWrapper = new WOD_2.CLM_PartPriceWrapper();
                    priceWrapper.accountId = claim.WOD_2__Account__c; 
                    priceWrapper.claimId = claim.id;
                    priceWrapper.currencyCode = claim.CurrencyIsoCode;
                    priceWrapper.partNumber = part.Name;
                    priceWrapper.status =false;
                    priceWrapper.quantity = String.valueOf(part.WOD_2__Invoice_Quantity__c);
                    priceWrapper.partSalesforceId = partNameToProductIdMap.get(part.Name);
                    priceFetchList.add(priceWrapper);
                    List<WOD_2.CLM_PartPriceWrapper> responseData = partPriceInterfaceObj.fetchPartPrice(priceFetchList);
                    System.debug('responseData>>>> '+responseData);
                    if(responseData.get(0).status){
                        String str = responseData.get(0).unitPrice;
                        if(str.length() > 3 && str.charAt(str.length()-3) == 44){
                            String intValue = str.subString(0,str.length()-3);
                            String decValue = str.subString(str.length()-2,str.length());
                            str = intValue.replaceAll('[^0-9]', '') +'.'+ decValue;
                        }else if(str.length() > 2 && str.charAt(str.length()-2) == 44){
                            String intValue = str.subString(0,str.length()-2);
                            String decValue = str.subString(str.length()-1,str.length());
                            str = intValue.replaceAll('[^0-9]', '') +'.'+ decValue;
                        }else {
                            str =str.replaceAll('[^.0-9]', '');
                        }
                        part.WOD_2__Unit_Price__c = Decimal.valueOf(str);
                    }else{
                        errorStr+=responseData.get(0).msg+'\n';
                        return;
                    }
                }else{
                    errorStr+='Invalid Part Number -'+part.Name+' \n';
                    return;
                }
                priceFetchList.clear();
            }
            if(!partList.isEmpty()){
                WOD_2.ResponseWrapper beforeSaveInstallPartWrapper = claimbaseOverrideHookObj.beforeInstalledPartSave(partList);
                if(beforeSaveInstallPartWrapper.status){
                    List<WOD_2.ResponseWrapper> responseWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimOEMInstallParts(partList);
                    for(WOD_2.ResponseWrapper resWrap : responseWrapper){
                        if(!resWrap.status){
                            errorStr+=resWrap.errormessage+'\n';
                        }
                    }
                }else{
                    errorStr+=beforeSaveInstallPartWrapper.errormessage+'\n';
                }
            }  
        }
    }
    
    //Save Labor 
    public static void saveLabors(List<WOD_2__Claim_Service_Information__c> laborList,WOD_2__Claim__c claim,Map<Id, Map<String, List<WOD_2__Rates_Details__c>>> accountRatesMap){
        if(!laborList.isEmpty()){
            system.debug('>>> laborList: Method:'+laborList);
            system.debug('>>> laborList: claim:'+claim);
            WOD_2__Business_Category_Configuration_Setting__c dateFieldToCompareConfigSetting = ATI_Utils.getConfiguration(claim.WOD_2__BusinessCategory__c, 'CLM_RateFetch_ClaimField_To_Be_Compare');
            String dateFieldToCompare = (dateFieldToCompareConfigSetting == null || dateFieldToCompareConfigSetting.Id == null) ? 'WOD_2__Date_Of_Repair__c' : dateFieldToCompareConfigSetting.WOD_2__Value__c;
            WOD_2__Rates_Details__c rateDetail =new WOD_2__Rates_Details__c();
            if(accountRatesMap.containsKey(claim.WOD_2__Account__c) && accountRatesMap.get(claim.WOD_2__Account__c).containsKey('ATI_Labor_Rate') && dateFieldToCompare != NULL){
                rateDetail = ATI_CLM_RatesOverride.getRateAmount(accountRatesMap.get(claim.WOD_2__Account__c).get('ATI_Labor_Rate'),(Date)claim.get(dateFieldToCompare));
            }
            
            if(rateDetail == NULL || rateDetail.WOD_2__Labor_Rate__c==NULL){
                errorStr+='No Labor Rate found \n';
            }else{
                List<WOD_2__Warranty_Product__c> wpList = [SELECT Id,WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c 
                                                           WHERE Id=:claim.WOD_2__Model_Number__c];
                
                Set<String> laborCodeSet = new Set<String>();
                for(WOD_2__Claim_Service_Information__c labor : laborList){
                    if(labor.Name != null){
                        laborCodeSet.add(labor.Name);
                    }
                }
                
                Map<String,WOD_2__FaultCode_Mapper__c> mapOfLaborCodeWithFaultCodeMapper = new Map<String,WOD_2__FaultCode_Mapper__c>();
                for(WOD_2__FaultCode_Mapper__c fcm : [SELECT Id,WOD_2__Code__c,WOD_2__Code__r.Name,WOD_2__Code__r.WOD_2__Standard_Labor_Hour__c
                                                      FROM WOD_2__FaultCode_Mapper__c 
                                                      WHERE WOD_2__Code__r.Name in :laborCodeSet AND WOD_2__Status__c=true AND WOD_2__Code__r.RecordType.DeveloperName='Job_Code' AND WOD_2__Code__r.ATI_IsActive__c=true
                                                      AND WOD_2__Group__c IN (SELECT WOD_2__Group__c FROM WOD_2__Group_Member__c WHERE WOD_2__Warranty_Product__c =:wpList[0].WOD_2__Parent_Product__c)]){
                                                          mapOfLaborCodeWithFaultCodeMapper.put(fcm.WOD_2__Code__r.Name,fcm);
                                                      }
                
                for(WOD_2__Claim_Service_Information__c labor : laborList){
                    if(!mapOfLaborCodeWithFaultCodeMapper.isEmpty() && mapOfLaborCodeWithFaultCodeMapper.containsKey(labor.Name)){
                        labor.WOD_2__Service_Job_Code__c  = mapOfLaborCodeWithFaultCodeMapper.get(labor.Name).WOD_2__Code__c;
                        labor.WOD_2__Claim__c = claim.id;
                        labor.WOD_2__Standard_Labor_Hour__c = mapOfLaborCodeWithFaultCodeMapper.get(labor.Name).WOD_2__Code__r.WOD_2__Standard_Labor_Hour__c;
                        //labor.WOD_2__Total_Labor_Hours__c = labor.WOD_2__Additional_Labor_Hour__c != NULL ? labor.WOD_2__Additional_Labor_Hour__c+labor.WOD_2__Standard_Labor_Hour__c:labor.WOD_2__Standard_Labor_Hour__c;
                        if(labor.WOD_2__Total_Labor_Hours__c != NULL){
                            //labor.WOD_2__Total_Labor_Hours__c = labor.WOD_2__Additional_Labor_Hour__c != NULL ? labor.WOD_2__Additional_Labor_Hour__c:labor.WOD_2__Standard_Labor_Hour__c;
                            if(labor.WOD_2__Total_Labor_Hours__c > labor.WOD_2__Standard_Labor_Hour__c){
                                if(labor.WOD_2__Reason_Additional_Labor_Hour__c == null ){
                                    errorStr+='Reason for Additional Labor Hrs is required \n';
                                }else{
                                    labor.WOD_2__Additional_Labor_Hour__c = labor.WOD_2__Total_Labor_Hours__c - labor.WOD_2__Standard_Labor_Hour__c; 
                                }
                            }else{
                                labor.WOD_2__Additional_Labor_Hour__c = 0.00;
                            }
                            labor.WOD_2__Total_Labor_Minutes__c =  (labor.WOD_2__Total_Labor_Hours__c*60).setScale(4);
                        }else{
                            errorStr+='Total Labor Hrs is required \n';
                        }
                        labor.CurrencyIsoCode = 'USD';
                        labor.WOD_2__LaborRate__c = rateDetail.WOD_2__Labor_Rate__c;
                    }
                    else{
                        errorStr+='Invalid Job Code -'+labor.Name+' \n';
                        return;
                    }
                }
                if(!laborList.isEmpty()){
                    List<WOD_2.ResponseWrapper> responseWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimServiceInformations(laborList);
                    System.debug('responseWrapper in labour code---->'+responseWrapper);
                    for(WOD_2.ResponseWrapper resWrap : responseWrapper){
                        if(!resWrap.status){
                            errorStr+=resWrap.errormessage+'\n';
                        }
                    }
                }
            } 
        }
    }
    
    //Save OtherCosts
    public static void saveOtherCosts(List<WOD_2__Other_Cost__c> ocList,WOD_2__Claim__c claim){
        if(!ocList.isEmpty()){
            System.debug('-claim.Id---->'+claim);
            List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Account__r.Public_Group_Id__c FROM WOD_2__Claim__c WHERE Id=:claim.Id];
            List<WOD_2__Other_Cost__Share> otherCostShareList = new List<WOD_2__Other_Cost__Share>();
            for(WOD_2__Other_Cost__c oc :ocList){
                oc.WOD_2__Claim__c = claim.Id;
            }
            WOD_2.ResponseWrapper beforeSaveOtherCostWrapper  = claimbaseOverrideHookObj.beforeSaveClaimOtherCostObject(ocList);
            //System.debug('beforeSaveOtherCostWrapper>>>>> '+beforeSaveOtherCostWrapper);
            if(beforeSaveOtherCostWrapper.status){   
                List<WOD_2.ResponseWrapper> responseWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimOtherCostData(ocList);
                for(WOD_2.ResponseWrapper resWrap : responseWrapper){
                    if(!resWrap.status){
                        errorStr+=resWrap.errormessage+'\n';
                    }else if(resWrap.data != NUll){
                        WOD_2__Other_Cost__c ocObj = (WOD_2__Other_Cost__c)JSON.deserialize(resWrap.data,WOD_2__Other_Cost__c.class);
                        if(claimLst[0].WOD_2__Account__r.Public_Group_Id__c != null && ocObj.id != null) {
                            otherCostShareList.add(
                                new WOD_2__Other_Cost__Share(
                                    AccessLevel = 'Edit',
                                    ParentId = ocObj.id,
                                    UserOrGroupId = claimLst[0].WOD_2__Account__r.Public_Group_Id__c
                                )
                            );
                        }
                    }
                }
                if(!otherCostShareList.isEmpty()){
                    insert otherCostShareList;
                }
            }else{
                errorStr+=beforeSaveOtherCostWrapper.errormessage+'\n';
            }
        }
    }  
    
    //validate BURules
    /*public static List<WOD_2.TWoD_RecordOutputWrapper> validateBURules(WOD_2__Claim__c claim){
WOD_2.BR_BusinessRuleEngineWrapper businessRuleWrapper = new WOD_2.BR_BusinessRuleEngineWrapper();
businessRuleWrapper.buId = claim.WOD_2__BusinessCategory__c;
businessRuleWrapper.configType = 'Rule';
businessRuleWrapper.moduleName = 'Claim';
businessRuleWrapper.ruleObjectAPIName = 'WOD_2__Claim__c';
businessRuleWrapper.ruleObjectIdList = new List<Id>{claim.Id};
List<WOD_2.TWoD_RecordOutputWrapper> buRuleOutputWrapper = WOD_2.BR_BusinessRuleEngineUtility.invokeRecordSubmitHandler(businessRuleWrapper);
return buRuleOutputWrapper;
}*/
}