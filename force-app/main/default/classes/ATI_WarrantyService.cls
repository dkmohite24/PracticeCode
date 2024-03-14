/* Name: ATI_WarrantyService
Description : ATI_WarrantyService, an service class for Warranty Registration and De-registraion purposes .
Author : Tavant ()
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant ()      07-DEC-2020          INITIAL DEVELOPMENT
*/
public without sharing class ATI_WarrantyService {
	/* 
     * 
     * Method Added for WR  07-DEC-2020  
     * 
     * ReRegistering the Inventory 
     * 
	*/
    //Alsn-159 converted the method to future method to reduce the cpu time limit
    @Future
    public static void reRegisterWarrantyWithStdPolicies(String inventoryListJson, String deRegistrationMsg){	
        ATI_WntyRegistrationTriggerHandler.isFuture = true;
        Map<String, WOD_2__Inventory__c> deserializedMap = (Map<String, WOD_2__Inventory__c>) JSON.deserialize(inventoryListJson,Map<String, WOD_2__Inventory__c>.class);
        Map<Id, WOD_2__Inventory__c> inventoryIdsMap = new Map<Id, WOD_2__Inventory__c>();        
        // Iterate over the entries and convert the keys back to Id type
        for (String key : deserializedMap.keySet()) {
            Id idKey = (Id) Id.valueOf(key);
            inventoryIdsMap.put(idKey, deserializedMap.get(key));
        } 
        List<WOD_2__Warranty_Registration__c> wrList = new List<WOD_2__Warranty_Registration__c>();//getWRListForInventories(inventoryIdsMap);
        List<WOD_2__Warranty_Registration__c> allWrList = getWRListForInventories(inventoryIdsMap);// Added By Mukesh 3/19/2021	
        //ALSN-106
        Map<Id,Id> invIdreplacedidMap = new Map<Id,Id>();
        Map<Id,Id> revinvIdreplacedidMap = new Map<Id,Id>();
        Map<Id,WOD_2__Inventory__c> replacedInventoriesMap = new Map<Id,WOD_2__Inventory__c>();
        Map<Id,WOD_2__Inventory__c> revreplacedInventoriesMap = new Map<Id,WOD_2__Inventory__c>();
        for(WOD_2__Warranty_Registration__c wr: allWrList){	
            if(wr.WOD_2__Inventory__r.ATI_Primary_Failure__c != null){
            	invIdreplacedidMap.put(wr.WOD_2__Inventory__c,wr.WOD_2__Inventory__r.ATI_Primary_Failure__c);
                revinvIdreplacedidMap.put(wr.WOD_2__Inventory__r.ATI_Primary_Failure__c,wr.WOD_2__Inventory__c);
            }
        }
        if(invIdreplacedidMap.size()>0){
            replacedInventoriesMap = new  Map<Id,WOD_2__Inventory__c>([Select id,WOD_2__Item__c from WOD_2__Inventory__c where id in :invIdreplacedidMap.values()]);
            revreplacedInventoriesMap = new  Map<Id,WOD_2__Inventory__c>([Select id,WOD_2__Item__c from WOD_2__Inventory__c where id in :revinvIdreplacedidMap.values()]);
        }
        //end
        
        for(WOD_2__Warranty_Registration__c wr: allWrList){	
            if(wr.WOD_2__Registration_Type__c =='Standard Registration'){	
                wrList.add(wr);	
            }	
        }	
        List<WOD_2__Warranty_Registration__c> newWRList = cloneWRsForRegistration(wrList, 'Standard Registration', false, inventoryIdsMap);	
               
       //ALSN-106 update for replaced inventories
       for (WOD_2__Warranty_Registration__c wr : newWRList){
            if(invIdreplacedidMap.get(wr.WOD_2__Inventory__c) != null){
                wr.WOD_2__Inventory__c = invIdreplacedidMap.get(wr.WOD_2__Inventory__c);
                wr.WOD_2__Warranty_Product__c = replacedInventoriesMap.get(wr.WOD_2__Inventory__c).WOD_2__Item__c;
            }
        }
        //end
        deactiveWRs(allWrList,deRegistrationMsg); // Updated by Mukesh 3/19/2021 deactiveWRs(wrList,deRegistrationMsg);	
        if(!newWRList.isEmpty()){	
            insert newWRList;
        }	

        Map<Id, WOD_2__Warranty_Registration__c> invWRMap = new Map<Id, WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c wr : newWRList){
            invWRMap.put(wr.WOD_2__Inventory__c, wr);
        }
        //ALSN-130 Active check
        List<WOD_2__Warranty_Coverages__c> coverages = [select id,WOD_2__Warranty_Registration__r.WOD_2__Inventory__c,WOD_2__Is_Active__c,WOD_2__Rollup_Warranty_Date__c,WOD_2__Policy_Definition__c,WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c,WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c in :allWrList and WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended' and WOD_2__Is_Active__c = true];
        Map<Id, WOD_2__Warranty_Coverages__c> invCoverageMap = new Map<Id, WOD_2__Warranty_Coverages__c>();
        for(WOD_2__Warranty_Coverages__c c : coverages){
            invCoverageMap.put(c.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c, c);
        }
        Map<Id, WOD_2__Warranty_Registration__c> newWRMap = new Map<Id, WOD_2__Warranty_Registration__c>(newWRList);
        WOD_2.WR_WarrantyRegistrationResponse responseWrapper = runEngine(newWRMap, 'ATI_StandardPolicyQueryOverride');
        System.debug('>>> responseWrapper :'+responseWrapper); //status
        
        //ALSN-106 update it back to correct inventory for replaced ones
        for (WOD_2__Warranty_Registration__c wr : newWRList){
            if(revinvIdreplacedidMap.get(wr.WOD_2__Inventory__c) != null){
                wr.WOD_2__Inventory__c = revinvIdreplacedidMap.get(wr.WOD_2__Inventory__c);
                wr.WOD_2__Warranty_Product__c = revreplacedInventoriesMap.get(wr.WOD_2__Inventory__c).WOD_2__Item__c;
            }
        }
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        update newWRList;
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        //end
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
        List<Id> wrIdWithCoveragesList = new List<Id>();
        for(WOD_2.WR_RegistrationResponse wr : responseWrapper.response.values()) {
            if(!wr.status){
                throw new TWoDException(wr.message + '  (' + wr.warrantyId + ')');
            }
            if(wr.warrantyCoverages.size() > 0 ){
                wrIdWithCoveragesList.add(wr.warrantyId);
                WOD_2__Warranty_Registration__c wntyReg = newWRMap.get(wr.warrantyId);
                WOD_2__Warranty_Coverages__c oldCoverage = invCoverageMap.get(wntyReg.WOD_2__Inventory__c);
                if(oldCoverage != null){
                    Date wntyStartDate = wntyReg.WOD_2__Install_Date__c;
                    WOD_2__Warranty_Coverages__c newCov = new WOD_2__Warranty_Coverages__c();
                    newCov.WOD_2__Warranty_Registration__c = wr.warrantyId;
                    newCov.WOD_2__Warranty_Start_Date__c = wntyStartDate;
                    newCov.WOD_2__Policy_Definition__c = oldCoverage.WOD_2__Policy_Definition__c;
                    //ALSN-130
                    newCov.WOD_2__Is_Active__c = oldCoverage.WOD_2__Is_Active__c;
                    newCov.WOD_2__Rollup_Warranty_Date__c = oldCoverage.WOD_2__Rollup_Warranty_Date__c;
                    //
                    newCov.ATI_isExtended__c = true;
                    if(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c != NULL) {
                        newCov.WOD_2__Warranty_End_Date__c = wntyStartDate.addMonths(Integer.valueOf(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c));
                    } else if(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c != NULL) {
                        newCov.WOD_2__Warranty_End_Date__c = wntyStartDate.addDays(Integer.valueOf(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c));
                    }
                    warrantyCoveragesList.add(newCov);
                }
                for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                    System.debug('>>> coverage :'+ coverage);
                    if(coverage.WOD_2__Policy_Definition__c != null){
                        warrantyCoveragesList.add(coverage);
                    } 
                }
            }
        }
        System.debug('>>> :warrantyCoveragesList :'+warrantyCoveragesList);
        WOD_2.ResponseWrapper res = saveCoverages(warrantyCoveragesList, wrIdWithCoveragesList);
        if(!res.status){
            throw new TWoDException(res.errormessage);
        }
        for(Id wrId : newWRMap.keySet()){
            newWRMap.get(wrId).WOD_2__Status__c = 'Registered';
        }
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        update newWRMap.values();
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        
    }
    //ALSN-207 for bulk upload
    public static void reRegisterWRForBulk(String inventoryListJson, String deRegistrationMsg){
        ATI_WntyRegistrationTriggerHandler.isFuture = true;
        Map<String, WOD_2__Inventory__c> deserializedMap = (Map<String, WOD_2__Inventory__c>) JSON.deserialize(inventoryListJson,Map<String, WOD_2__Inventory__c>.class);
        Map<Id, WOD_2__Inventory__c> inventoryIdsMap = new Map<Id, WOD_2__Inventory__c>();        
        // Iterate over the entries and convert the keys back to Id type
        for (String key : deserializedMap.keySet()) {
            Id idKey = (Id) Id.valueOf(key);
            inventoryIdsMap.put(idKey, deserializedMap.get(key));
        } 
        List<WOD_2__Warranty_Registration__c> wrList = new List<WOD_2__Warranty_Registration__c>();//getWRListForInventories(inventoryIdsMap);
        List<WOD_2__Warranty_Registration__c> allWrList = getWRListForInventories(inventoryIdsMap);// Added By Mukesh 3/19/2021	
        //ALSN-106
        Map<Id,Id> invIdreplacedidMap = new Map<Id,Id>();
        Map<Id,Id> revinvIdreplacedidMap = new Map<Id,Id>();
        Map<Id,WOD_2__Inventory__c> replacedInventoriesMap = new Map<Id,WOD_2__Inventory__c>();
        Map<Id,WOD_2__Inventory__c> revreplacedInventoriesMap = new Map<Id,WOD_2__Inventory__c>();
        for(WOD_2__Warranty_Registration__c wr: allWrList){	
            if(wr.WOD_2__Inventory__r.ATI_Primary_Failure__c != null){
                invIdreplacedidMap.put(wr.WOD_2__Inventory__c,wr.WOD_2__Inventory__r.ATI_Primary_Failure__c);
                revinvIdreplacedidMap.put(wr.WOD_2__Inventory__r.ATI_Primary_Failure__c,wr.WOD_2__Inventory__c);
            }
        }
        if(invIdreplacedidMap.size()>0){
            replacedInventoriesMap = new  Map<Id,WOD_2__Inventory__c>([Select id,WOD_2__Item__c from WOD_2__Inventory__c where id in :invIdreplacedidMap.values()]);
            revreplacedInventoriesMap = new  Map<Id,WOD_2__Inventory__c>([Select id,WOD_2__Item__c from WOD_2__Inventory__c where id in :revinvIdreplacedidMap.values()]);
        }
        //end
        
        for(WOD_2__Warranty_Registration__c wr: allWrList){	
            if(wr.WOD_2__Registration_Type__c =='Standard Registration'){	
                wrList.add(wr);	
            }	
        }	
        List<WOD_2__Warranty_Registration__c> newWRList = cloneWRsForRegistration(wrList, 'Standard Registration', false, inventoryIdsMap);	
        
        //ALSN-106 update for replaced inventories
        for (WOD_2__Warranty_Registration__c wr : newWRList){
            if(invIdreplacedidMap.get(wr.WOD_2__Inventory__c) != null){
                wr.WOD_2__Inventory__c = invIdreplacedidMap.get(wr.WOD_2__Inventory__c);
                wr.WOD_2__Warranty_Product__c = replacedInventoriesMap.get(wr.WOD_2__Inventory__c).WOD_2__Item__c;
            }
        }
        //end
        deactiveWRs(allWrList,deRegistrationMsg); // Updated by Mukesh 3/19/2021 deactiveWRs(wrList,deRegistrationMsg);	
        if(!newWRList.isEmpty()){	
            insert newWRList;
        }	
        
        Map<Id, WOD_2__Warranty_Registration__c> invWRMap = new Map<Id, WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c wr : newWRList){
            invWRMap.put(wr.WOD_2__Inventory__c, wr);
        }
        //ALSN-130 Active check
        List<WOD_2__Warranty_Coverages__c> coverages = [select id,WOD_2__Warranty_Registration__r.WOD_2__Inventory__c,WOD_2__Is_Active__c,WOD_2__Rollup_Warranty_Date__c,WOD_2__Policy_Definition__c,WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c,WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c in :allWrList and WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended' and WOD_2__Is_Active__c = true];
        Map<Id, WOD_2__Warranty_Coverages__c> invCoverageMap = new Map<Id, WOD_2__Warranty_Coverages__c>();
        for(WOD_2__Warranty_Coverages__c c : coverages){
            invCoverageMap.put(c.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c, c);
        }
        Map<Id, WOD_2__Warranty_Registration__c> newWRMap = new Map<Id, WOD_2__Warranty_Registration__c>(newWRList);
        WOD_2.WR_WarrantyRegistrationResponse responseWrapper = runEngine(newWRMap, 'ATI_StandardPolicyQueryOverride');
        System.debug('>>> responseWrapper :'+responseWrapper); //status
        
        //ALSN-106 update it back to correct inventory for replaced ones
        for (WOD_2__Warranty_Registration__c wr : newWRList){
            if(revinvIdreplacedidMap.get(wr.WOD_2__Inventory__c) != null){
                wr.WOD_2__Inventory__c = revinvIdreplacedidMap.get(wr.WOD_2__Inventory__c);
                wr.WOD_2__Warranty_Product__c = revreplacedInventoriesMap.get(wr.WOD_2__Inventory__c).WOD_2__Item__c;
            }
        }
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        update newWRList;
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        //end
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
        List<Id> wrIdWithCoveragesList = new List<Id>();
        for(WOD_2.WR_RegistrationResponse wr : responseWrapper.response.values()) {
            if(!wr.status){
                throw new TWoDException(wr.message + '  (' + wr.warrantyId + ')');
            }
            if(wr.warrantyCoverages.size() > 0 ){
                wrIdWithCoveragesList.add(wr.warrantyId);
                WOD_2__Warranty_Registration__c wntyReg = newWRMap.get(wr.warrantyId);
                WOD_2__Warranty_Coverages__c oldCoverage = invCoverageMap.get(wntyReg.WOD_2__Inventory__c);
                if(oldCoverage != null){
                    Date wntyStartDate = wntyReg.WOD_2__Install_Date__c;
                    WOD_2__Warranty_Coverages__c newCov = new WOD_2__Warranty_Coverages__c();
                    newCov.WOD_2__Warranty_Registration__c = wr.warrantyId;
                    newCov.WOD_2__Warranty_Start_Date__c = wntyStartDate;
                    newCov.WOD_2__Policy_Definition__c = oldCoverage.WOD_2__Policy_Definition__c;
                    //ALSN-130
                    newCov.WOD_2__Is_Active__c = oldCoverage.WOD_2__Is_Active__c;
                    newCov.WOD_2__Rollup_Warranty_Date__c = oldCoverage.WOD_2__Rollup_Warranty_Date__c;
                    //
                    newCov.ATI_isExtended__c = true;
                    if(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c != NULL) {
                        newCov.WOD_2__Warranty_End_Date__c = wntyStartDate.addMonths(Integer.valueOf(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c));
                    } else if(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c != NULL) {
                        newCov.WOD_2__Warranty_End_Date__c = wntyStartDate.addDays(Integer.valueOf(oldCoverage.WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c));
                    }
                    warrantyCoveragesList.add(newCov);
                }
                for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                    System.debug('>>> coverage :'+ coverage);
                    if(coverage.WOD_2__Policy_Definition__c != null){
                        warrantyCoveragesList.add(coverage);
                    } 
                }
            }
        }
        System.debug('>>> :warrantyCoveragesList :'+warrantyCoveragesList);
        WOD_2.ResponseWrapper res = saveCoverages(warrantyCoveragesList, wrIdWithCoveragesList);
        if(!res.status){
            throw new TWoDException(res.errormessage);
        }
        for(Id wrId : newWRMap.keySet()){
            newWRMap.get(wrId).WOD_2__Status__c = 'Registered';
        }
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        update newWRMap.values();
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');   
    }
    //ALSN-207 end
	/* 
     * 
     * Method Added 
     * 
     * Query the WR by Inventory for claim module.
     * 
	*/
    public static void registerWarranty(List<Id> inventoryIds){
        Map<Id, WOD_2__Warranty_Registration__c> warrantyRegistrationMap = new Map<Id, WOD_2__Warranty_Registration__c>([
        SELECT id,WOD_2__Inventory__r.Id,WOD_2__Registration_Date__c,
        WOD_2__Inventory__r.WOD_2__Business_Unit__c,
        WOD_2__Inventory__r.WOD_2__Serial_Number__c,
        WOD_2__Inventory__r.WOD_2__Install_Date__c,
        WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,ATI_isExtended__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__r.Id in :inventoryIds
        ]);
    }
	/* 
     * 
     * Method Added for WR  07-DEC-2020  
     * 
     * ReRegistering the Inventory by passing inv id List
     * 
	*/
    public static void deRegisterWarranty(List<Id> inventoryIds, String deRegistrationMsg){
        List<WOD_2__Warranty_Registration__c> wrList = 
            [SELECT id, 
             //WOD_2__De_Registration_Comments__c,WOD_2__De_Registration_date__c,WOD_2__De_Registration_Reason__c,
            WOD_2__Status__c FROM WOD_2__Warranty_Registration__c 
             WHERE WOD_2__Inventory__c in :inventoryIds AND WOD_2__Status__c = 'Registered'];
        deactiveWRs(wrList, deRegistrationMsg);
    }
    /* 
     * 
     * Method Added for WR  07-DEC-2020  
     * 
     * ReRegistering the Inventory by passing WR List
     * 
	*/
    private static void deactiveWRs(List<WOD_2__Warranty_Registration__c> wrList, String deRegistrationMsg){
        List<WOD_2__Warranty_Registration__c> warrantyRegListToUpdateList = new List<WOD_2__Warranty_Registration__c>();
        for (WOD_2__Warranty_Registration__c wntyRegToUpdate : wrList ) {
            WOD_2__Warranty_Registration__c oldWR = new WOD_2__Warranty_Registration__c();
            oldWR.id = wntyRegToUpdate.id;
            /*oldWR.WOD_2__De_Registration_Comments__c = deRegistrationMsg; 
            oldWR.WOD_2__De_Registration_date__c =  System.today();
            oldWR.WOD_2__De_Registration_Reason__c = warrantyObject.WOD_2__De_Registration_Reason__c; */
            oldWR.WOD_2__Status__c = 'InActive';
            warrantyRegListToUpdateList.add(oldWR);
        }  
        if(warrantyRegListToUpdateList.size()>0){
            update warrantyRegListToUpdateList;
        }
		
    }
    /* 
     * 
     * Method Added for WR  07-DEC-2020  
     * 
     * ReRegistering the Inventory searching the policy by Running AT
     * 
	*/
    private static void registerWRs(Map<Id, WOD_2__Warranty_Registration__c> warrantyRegistrationMap, String atQueryOverride) {
        System.debug('>>> registerWRs :');
        Map<Id, WOD_2__Warranty_Registration__c> wRMaptoUpdate = new Map<Id, WOD_2__Warranty_Registration__c>();
        List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
        WOD_2.WR_WarrantyRegistrationResponse responseWrapper = runEngine(warrantyRegistrationMap, atQueryOverride);
        System.debug('>>> responseWrapper :'+responseWrapper); //status
        for(WOD_2.WR_RegistrationResponse wr : responseWrapper.response.values()) {
            if(!wr.status){
                throw new TWoDException(wr.message + '  (' + wr.warrantyId + ')');
            }
            if(wr.warrantyCoverages.size() > 0 ){
                for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                    System.debug('>>> coverage :'+ coverage);
                    if(coverage.WOD_2__Policy_Definition__c != null){
                        WOD_2__Warranty_Registration__c wrWithCoverage = new WOD_2__Warranty_Registration__c();
                        wrWithCoverage.id = coverage.WOD_2__Warranty_Registration__c;
                        wrWithCoverage.WOD_2__Status__c = 'Registered';
                        wRMaptoUpdate.put(wrWithCoverage.id, wrWithCoverage);
                        warrantyCoveragesList.add(coverage);
                    }
                }
            }
        }
        System.debug('>>> :warrantyCoveragesList :'+warrantyCoveragesList);
        if(!warrantyCoveragesList.isEmpty()){
            updateUnitUsageForCoverages(warrantyCoveragesList);
            List<id> invIds = new List<id>();
            insert warrantyCoveragesList;
            // bypass and clearbypass added to reduce the query limit	
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');	
            update wRMaptoUpdate.values();	
            TriggerHandler.clearbypass('ATI_WntyRegistrationTriggerHandler');
        }
    }
    
    public static void updateUnitUsageForCoverages(List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList){
        Set<Id> policyIdSet = new Set<Id>();
        for(WOD_2__Warranty_Coverages__c wcObj : warrantyCoveragesList) {
            policyIdSet.add(wcObj.WOD_2__Policy_Definition__c);
        }
		Map<Id,List<WOD_2__Policy_Definition_Inventory_Usage__c> > policyIdAndPdiuMap = getPolicyDefintionInventoryUsageData(policyIdSet);
		WOD_2__Configuration_Setting__mdt configurationSettingMetaData = ATI_Utils.getConfigurationSettingMetaData('WOD_2__WarrantyCoverage_PolicyUsage_Mapping');
      	Map<String,String> usageTypeToFieldMap = (Map<String,String>) JSON.deserialize(configurationSettingMetaData.WOD_2__Configuration_Value__c, Map<String,String>.class);
      	//to update the fields
        for(WOD_2__Warranty_Coverages__c eachWCobj : warrantyCoveragesList) {
            if(policyIdAndPdiuMap.containsKey(eachWCobj.WOD_2__Policy_Definition__c)) {
                for(WOD_2__Policy_Definition_Inventory_Usage__c eachPDIU : policyIdAndPdiuMap.get(eachWCobj.WOD_2__Policy_Definition__c)) {
                    if(usageTypeToFieldMap.containsKey(eachPDIU.WOD_2__Usage_Reading_Type__c)) {
                        String warrantyCoverageFieldName =  usageTypeToFieldMap.get(eachPDIU.WOD_2__Usage_Reading_Type__c);
                        eachWCobj.put(warrantyCoverageFieldName,eachPDIU.WOD_2__Usage_Reading_Type__c);
                        List <String> splitedString = warrantyCoverageFieldName.split('_');
                        String wcUnitUsageFieldName = String.valueOf( 'WOD_2__Unit_Usage_'   + splitedString[splitedString.size()-3] + '__c' );
                        eachWCobj.put(wcUnitUsageFieldName,eachPDIU.WOD_2__Maximum_Unit__c);
                    }
                }
            }
        }
    }

    private static Map<Id,List<WOD_2__Policy_Definition_Inventory_Usage__c> > getPolicyDefintionInventoryUsageData(Set<Id> policyIdSet){
        List<String> pdiuFields = new List<String> {'WOD_2__Policy_Definition__c','WOD_2__Maximum_Unit__c','WOD_2__Usage_Reading_Type__c'};
		Map<Id,List<WOD_2__Policy_Definition_Inventory_Usage__c> > policyIdAndPdiuMap = new Map<Id,List<WOD_2__Policy_Definition_Inventory_Usage__c> >();
        ATI_Utils.checkForAccess('WOD_2__Policy_Definition_Inventory_Usage__c', 'READ', pdiuFields);
        String queryWr = 'SELECT '+String.join(pdiuFields,',')+' from WOD_2__Policy_Definition_Inventory_Usage__c where WOD_2__Policy_Definition__c IN :policyIdSet';
        List<WOD_2__Policy_Definition_Inventory_Usage__c> pdiuObjectsList = Database.query(String.escapeSingleQuotes(queryWr));
        if(pdiuObjectsList != null && pdiuObjectsList.size() > 0 ) {
            for(WOD_2__Policy_Definition_Inventory_Usage__c pdiuObject : pdiuObjectsList) {
                if(policyIdAndPdiuMap.keySet().contains(pdiuObject.WOD_2__Policy_Definition__c)) {
                    policyIdAndPdiuMap.get(pdiuObject.WOD_2__Policy_Definition__c).add(pdiuObject);
                } else {
                    policyIdAndPdiuMap.put(pdiuObject.WOD_2__Policy_Definition__c,new List<WOD_2__Policy_Definition_Inventory_Usage__c> {pdiuObject});
                }
            }
        }
        return policyIdAndPdiuMap;
    }
    
    public static List<WOD_2__Inventory__c> getInventoriesForWR(List<Id> invIdList){
        List<String>  invFields = new List<String>();
        invFields.add('WOD_2__Business_Unit__c');
        invFields.add('WOD_2__Serial_Number__c');
        invFields.add('WOD_2__Install_Date__c');
        invFields.add('WOD_2__Manufacturing_Date__c');
        invFields.add('ATI_Vocation_Code__c');
        invFields.add('WOD_2__Account__c');
        invFields.add('WOD_2__Item__c');
        invFields.add('WOD_2__Type__c');//25254 Bug
        ATI_Utils.NoAccessObjectFieldWrapper invFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Inventory__c', invFields);
        if(invFieldAccess.noAccessObjectList.isEmpty() && invFieldAccess.noAccessObjectList.isEmpty()){
            return [Select ID,WOD_2__Account__c, WOD_2__Business_Unit__c, WOD_2__Serial_Number__c, WOD_2__Install_Date__c, 
            WOD_2__Manufacturing_Date__c,ATI_Vocation_Code__c,WOD_2__Item__c,WOD_2__Type__c  from WOD_2__Inventory__c where ID in :invIdList];
        } else {
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
    }

    //ALSN-2 WOD_2__Inventory__r.WOD_2__Account__c,
    public static List<WOD_2__Warranty_Registration__c> getWRListForInventories(Map<Id, WOD_2__Inventory__c> inventoryIdsMap){
        List<String> fieldList = getWRFeildsForRegistration();
        ATI_Utils.NoAccessObjectFieldWrapper wrFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', fieldList);
        if(wrFieldAccess.noAccessObjectList.isEmpty() && wrFieldAccess.noAccessObjectList.isEmpty()){
        system.debug('inventoryIdsMap.keySet()**8'+inventoryIdsMap.keySet());
            List<WOD_2__Warranty_Registration__c> wrList = [SELECT id,Name, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
               WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Inventory__r.ATI_Active__c,
              WOD_2__Inventory__r.ATI_Primary_Failure__c, ATI_CE_Number__c,ATI_PO_Number__c,ATI_Tracking_Number__c,ATI_isExtended__c,ATI_Extended_Warranty_Purchase_Date__c,//ALSN-106
              WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Units_Usage__c,ATI_Vocation_Code__c, WOD_2__Install_Date__c,WOD_2__Inventory__r.WOD_2__Account__c,
               //WOD_2__De_Registration_Comments__c,WOD_2__De_Registration_date__c,WOD_2__De_Registration_Reason__c,
              WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c FROM WOD_2__Warranty_Registration__c 
              WHERE WOD_2__Inventory__c IN :inventoryIdsMap.keySet() AND WOD_2__Status__c = 'Registered'];
             System.debug('getWRListForInventories--->'+wrList);
	        return wrList;
        } else {
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
    }
	//ALSN-2 WOD_2__Inventory__r.WOD_2__Account__c
	public static List<WOD_2__Warranty_Registration__c> getStdWRListForInventories(Map<Id, WOD_2__Inventory__c> inventoryIdsMap){
        List<String> fieldList = getWRFeildsForRegistration();
        ATI_Utils.NoAccessObjectFieldWrapper wrFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', fieldList);
        if(wrFieldAccess.noAccessObjectList.isEmpty() && wrFieldAccess.noAccessObjectList.isEmpty()){
            system.debug('inventoryIdsMap.keySet()**8'+inventoryIdsMap.keySet());
            List<WOD_2__Warranty_Registration__c> wrList = [SELECT id,Name,WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
             	WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,
            	WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Units_Usage__c,ATI_Vocation_Code__c, WOD_2__Install_Date__c,
                                                            WOD_2__Account__r.ATI_Inactive_Date__c,WOD_2__Account__r.ATI_Active__c,WOD_2__Inventory__r.WOD_2__Account__c,
                                                            ATI_CE_Number__c,ATI_PO_Number__c,ATI_Tracking_Number__c,ATI_isExtended__c,ATI_Extended_Warranty_Purchase_Date__c,//ALSN-106
             	WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c FROM WOD_2__Warranty_Registration__c 
            	WHERE WOD_2__Inventory__c IN :inventoryIdsMap.keySet() AND WOD_2__Status__c = 'Registered' AND WOD_2__Registration_Type__c='Standard Registration'];
             System.debug('getWRListForInventories--->'+wrList);
	        return wrList;
        } else {
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
    }

    public static List<WOD_2__Warranty_Registration__c> cloneWRsForRegistration(List<WOD_2__Warranty_Registration__c> wrList, 
                String registrationType, Boolean createWR, Map<Id, WOD_2__Inventory__c>  inventoryIdsMap){
        List<WOD_2__Warranty_Registration__c> newWRList = new List<WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c wr : wrList){
            
            // Add condition for type of WR Type After TBD :  Prasad and Sunil  // Only one WR will be Cloned
            //if(wr.WOD_2__Registration_Type__c == registrationType){
            WOD_2__Warranty_Registration__c newWR = wr.clone(false, false,false,false);
            newWR.ATI_Vocation_Code__c =   inventoryIdsMap.get(WR.WOD_2__Inventory__c).ATI_Vocation_Code__c; 
            newWR.WOD_2__Warranty_Product__c = inventoryIdsMap.get(WR.WOD_2__Inventory__c).WOD_2__Item__c;
            newWR.WOD_2__Registration_Date__c =  inventoryIdsMap.get(WR.WOD_2__Inventory__c).WOD_2__Install_Date__c;
            //Added By Yamini(Start) - (08th Jan 2021)
            newWR.WOD_2__Install_Date__c =  inventoryIdsMap.get(WR.WOD_2__Inventory__c).WOD_2__Install_Date__c;
            newWR.WOD_2__Units_Usage__c = WR.WOD_2__Units_Usage__c;
            //Added By Yamini(End)
            newWR.WOD_2__Status__c = 'Draft';
            newWR.WOD_2__Customer__c = WR.WOD_2__Customer__c;
            newWR.WOD_2__Inventory__c = WR.WOD_2__Inventory__c;
            newWR.WOD_2__Registration_Comments__c = WR.WOD_2__Registration_Comments__c;                                          
            newWR.WOD_2__Registration_Type__c = registrationType;
            newWR.WOD_2__Usage_Type__c = WR.WOD_2__Usage_Type__c;
            newWR.WOD_2__Account__c = inventoryIdsMap.get(WR.WOD_2__Inventory__c).WOD_2__Account__c;//ALSN-2
            //ALSN-130
            newWR.ATI_isExtended__c = wr.ATI_isExtended__c;
            //ASLN-106 copy extended WR details if present
            if(newWR.ATI_isExtended__c == true){
                 newWR.ATI_CE_Number__c =  wr.ATI_CE_Number__c;
                 newWR.ATI_Extended_Warranty_Purchase_Date__c = wr.ATI_Extended_Warranty_Purchase_Date__c;
                 newWR.ATI_PO_Number__c = wr.ATI_PO_Number__c; 
                 newWR.ATI_Tracking_Number__c = wr.ATI_Tracking_Number__c;
            }
            else{
                newWR.ATI_CE_Number__c ='';
                newWR.ATI_PO_Number__c ='';
                newWR.ATI_Tracking_Number__c ='';
                newWR.ATI_Extended_Warranty_Purchase_Date__c =null;
            }           
            if(registrationType=='Extended'){
                newWR.WOD_2__Registration_Comments__c = '';
            }
            newWRList.add(newWR);
          //}
        }
        if(createWR){
            List<String> fieldList = getWRFieldList();
            ATI_Utils.NoAccessObjectFieldWrapper wrCreateAccess = ATI_Utils.fetchCreateAccess('WOD_2__Warranty_Registration__c', fieldList);
            if(wrCreateAccess.noAccessObjectList.isEmpty() && wrCreateAccess.noAccessObjectList.isEmpty()){
                insert newWRList;
            }
        }
        return newWRList;
    }

    private static List<String> getWRFieldList(){
        List<String> fieldList = new List<String>();
        fieldList.add('ATI_Vocation_Code__c');
        fieldList.add('WOD_2__Warranty_Product__c');
        fieldList.add('WOD_2__Registration_Date__c');
        fieldList.add('WOD_2__Status__c');
        fieldList.add('WOD_2__Customer__c');
        fieldList.add('WOD_2__Inventory__c');
        fieldList.add('WOD_2__Registration_Comments__c');
        fieldList.add('WOD_2__Registration_Type__c');
        fieldList.add('WOD_2__Usage_Type__c');
        fieldList.add('WOD_2__Account__c');
        fieldList.add('ATI_Extended_Warranty_Purchase_Date__c');
        fieldList.add('ATI_isExtended__c');
        fieldList.add('WOD_2__Units_Usage__c');
        //ALSN-106
        fieldList.add('ATI_CE_Number__c');
        fieldList.add('ATI_PO_Number__c');
        fieldList.add('ATI_Tracking_Number__c');
		return fieldList;        
    }
    
    public static WOD_2.WR_WarrantyRegistrationResponse runEngine(Map<Id, WOD_2__Warranty_Registration__c> warrantyRegistrationMap, String atQueryOverride){
        WOD_2.WR_RegistrationRequest wrRequestObject = new WOD_2.WR_RegistrationRequest();
        wrRequestObject.reduceEndDateByOne = false;
        wrRequestObject.ignorePolicyDateCheck = false;
        wrRequestObject.warrantyRegistrationMap = warrantyRegistrationMap;
        wrRequestObject.ATQueryOverride = atQueryOverride;
        WOD_2.WR_WarrantyRegistrationService warrantyServiceObject = new WOD_2.WR_WarrantyRegistrationService();
        return warrantyServiceObject.processWarrantyRegistration(wrRequestObject,false);
    }
    
    private static List<String> getWRFeildsForRegistration(){
        List<String> fieldList = new List<String>();
        fieldList.add('WOD_2__Inventory__r.Id');
        fieldList.add('WOD_2__Customer__c');
        fieldList.add('WOD_2__Registration_Comments__c');
        fieldList.add('WOD_2__Registration_Type__c');
        fieldList.add('WOD_2__Usage_Type__c');
        fieldList.add('WOD_2__Account__c');
        fieldList.add('WOD_2__Registration_Date__c');
        fieldList.add('WOD_2__Inventory__r.WOD_2__Business_Unit__c');
        fieldList.add('WOD_2__Inventory__r.WOD_2__Serial_Number__c');
        fieldList.add('WOD_2__Inventory__r.WOD_2__Install_Date__c');
		fieldList.add('WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c');
        fieldList.add('WOD_2__Status__c');
        return fieldList;
    }

    public static void registerWithStdPolicies(Id warrantyRegistrationId){
        List<String> fieldList = getWRFeildsForRegistration();
        ATI_Utils.NoAccessObjectFieldWrapper wrFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', fieldList);
        if(wrFieldAccess.noAccessObjectList.isEmpty() && wrFieldAccess.noAccessObjectList.isEmpty()){
            List<WOD_2__Warranty_Registration__c> wrList =
                [SELECT id, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
                     WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,
                    WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c, 
                     //WOD_2__De_Registration_Comments__c,WOD_2__De_Registration_date__c,WOD_2__De_Registration_Reason__c,
                    WOD_2__Status__c FROM WOD_2__Warranty_Registration__c 
                    WHERE Id = :warrantyRegistrationId];
            registerWRs(new Map<Id, WOD_2__Warranty_Registration__c>(wrList), 'ATI_StandardPolicyQueryOverride');
            for(WOD_2__Warranty_Registration__c wr : wrList){
                wr.WOD_2__Status__c = 'In Progress';
            }
            // bypass and clearbypass added to reduce the query limit	
            // Alsn-213 bypassed ATI_InventoryTriggerHandler to avoid the updates that are not necessary as a part of code optimisation
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update wrList;	
            TriggerHandler.clearbypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.clearbypass('ATI_InventoryTriggerHandler');
            WOD_2__Inventory__c registeredInv = new WOD_2__Inventory__c(Id=wrList.get(0).WOD_2__Inventory__r.Id);
            registeredInv.WOD_2__Customer__c = wrList.get(0).WOD_2__Customer__c;
			if(wrList[0].WOD_2__Registration_Type__c != 'Pre-delivery'){
				registeredInv.WOD_2__Type__c = 'Retail';
                registeredInv.WOD_2__Account__c = wrList.get(0).WOD_2__Account__c;
			}
            // Alsn-213 bypassed ATI_InventoryTriggerHandler to avoid the updates that are not necessary as a part of code optimisation
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update registeredInv;
            TriggerHandler.clearbypass('ATI_InventoryTriggerHandler');
		} else {
            throw new TWoDException(Label.ATI_Log_Insufficient_access);
        }
    }
   
    private static WOD_2__Warranty_Registration__c getDraftStdWarrantyReg(Id inventoryId){
        List<String> fieldList = getWRFieldList();
        ATI_Utils.NoAccessObjectFieldWrapper wrUpdateAccess = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Registration__c', fieldList);
        // we are checking for update access as we are going to update it later
        if(wrUpdateAccess.noAccessObjectList.isEmpty() && wrUpdateAccess.noAccessObjectList.isEmpty()){
			String query = 'select id, ' + String.join(fieldList, ',') + ' from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :inventoryId ' +
                'AND WOD_2__Registration_Type__c = \'Standard Registration\' AND WOD_2__Status__c = \'Draft\'';
            System.debug(query);
            List<WOD_2__Warranty_Registration__c> wrs = Database.query(query);
            if(!wrs.isEmpty()){
                return wrs.get(0);
            }
        }
        return new WOD_2__Warranty_Registration__c();
    }
    
    public static WOD_2.WR_InventoryRegistrationWrapper getInvRegWrapper(Id accountId, Id inventoryId, ATI_WarrantyService.WRDetailsWrapper wrWrapper){
        if(wrWrapper != null){
            WOD_2.WR_InventoryRegistrationWrapper irw = new WOD_2.WR_InventoryRegistrationWrapper();
            List<WOD_2__Inventory__c> invList = getInventoriesForWR(new List<Id>{inventoryId});
            if(!invList.isEmpty()){
                WOD_2__Inventory__c inv = invList.get(0);
				WOD_2__Warranty_Registration__c wr = getDraftStdWarrantyReg(inv.Id);
                wr.WOD_2__Inventory__c = inv.Id;
                wr.WOD_2__Warranty_Product__c = inv.WOD_2__Item__c;
                wr.WOD_2__Account__c = accountId;
                wr.WOD_2__Units_Usage__c = wrWrapper.WOD_2_Units_Usage_c;
                wr.WOD_2__Install_Date__c = wrWrapper.WOD_2_Install_Date_c;
                wr.ATI_Vocation_Code__c = wrWrapper.ATI_Vocation_Code_c;
                wr.WOD_2__Customer__c = wrWrapper.WOD_2_Customer_c;
                wr.ATI_Pre_Delivery__c = wrWrapper.ATI_Pre_Delivery_c;
                wr.WOD_2__Registration_Comments__c = 'Registering during claim';
                wr.WOD_2__Registration_Type__c = 'Standard Registration';
                wr.WOD_2__Status__c = 'Draft';
				irw.inventoryData = inv;
                irw.registrationData = wr;
                return irw;
            }        
        }        
        return null;
    }
    
    /*
     * This method is needed just to overcome the TWoD SOQL limit error, since product is not supporting 
     * bulk functionality. Product is trying to find the parent coverage to apply for child inventories even if parent id is
     *  null :(. And this functionality is not needed for ATI. Please refer to TS-223 for more info
     */
    public static Map<Id,WOD_2.WR_RegistrationResponse> runApplicablityEngine(Map<Id, WOD_2__Warranty_Registration__c> wrMap, String policyQueryOverirde){
       Map<Id,WOD_2.WR_RegistrationResponse> responseMap = new Map<Id,WOD_2.WR_RegistrationResponse>();
        WOD_2.AT_RuleEngineInputWrapper reiw = getRuleEngineWrapper(wrMap, policyQueryOverirde);
        WOD_2.AT_RuleEngineAdapter rea = new WOD_2.AT_RuleEngineAdapter();
        WOD_2.AT_RuleEngineResponseWrapper rerw = rea.runApplicabilityEngine(reiw);
        if(!rerw.isSuccess){
            throw new TWoDException(rerw.message);
        }
        Map<Id,List<Id> > warantyRegPolicyMap = rerw.ATResponseMap;
        List<Id> policyIdList = getPolicyIds(warantyRegPolicyMap);
		Map<Id,WOD_2__Policy_Definition__c> policyDefMap = getPolicyDetails(policyIdList);        
        for(Id warrantyRecord : wrMap.keySet()) {
            WOD_2.WR_RegistrationResponse wrResponse = new WOD_2.WR_RegistrationResponse();
            wrResponse.warrantyId = warrantyRecord;
            wrResponse.warrantyCoverages = new List<WOD_2__Warranty_Coverages__c>();
            if(warantyRegPolicyMap.containsKey(warrantyRecord)){
                List<Id> policyIds = warantyRegPolicyMap.get(warrantyRecord);
                if(policyIds == null || policyIds.isEmpty()) {
                    wrResponse.message = 'No Policy Found';
                    wrResponse.status = false;
                } else {
                    wrResponse.warrantyCoverages.addAll(getCoverages(wrMap.get(warrantyRecord), policyIds, policyDefMap));
                    wrResponse.message = '';
                    wrResponse.status = true;
                }
            } else {
                wrResponse.message = 'No Policy Found';
                wrResponse.status = false;
            }
            responseMap.put(warrantyRecord,wrResponse);
        }
        return responseMap;
    }
    
    @testVisible
    private static List<WOD_2__Warranty_Coverages__c> getCoverages(WOD_2__Warranty_Registration__c wr, List<Id> policyIds, Map<Id,WOD_2__Policy_Definition__c> policyDefMap){
        List<WOD_2__Warranty_Coverages__c> coverageList = new List<WOD_2__Warranty_Coverages__c>();
        Date wntyStartDate = wr.WOD_2__Inventory__r.WOD_2__Install_Date__c;
        for(Id policyId : policyIds){
            WOD_2__Warranty_Coverages__c warrantyCoverageObject = new WOD_2__Warranty_Coverages__c();
            warrantyCoverageObject.WOD_2__Warranty_Registration__c = wr.Id;
            warrantyCoverageObject.WOD_2__Warranty_Start_Date__c = wntyStartDate;
            warrantyCoverageObject.WOD_2__Policy_Definition__c = policyId;
            warrantyCoverageObject.WOD_2__Is_Active__c = true;
            if(policyDefMap.get(policyId).WOD_2__Months_Covered__c != NULL) {
                warrantyCoverageObject.WOD_2__Warranty_End_Date__c = wntyStartDate.addMonths(Integer.valueOf(policyDefMap.get(policyId).WOD_2__Months_Covered__c));
            } else if(policyDefMap.get(policyId).WOD_2__Days_Covered__c != NULL) {
                warrantyCoverageObject.WOD_2__Warranty_End_Date__c = wntyStartDate.addDays(Integer.valueOf(policyDefMap.get(policyId).WOD_2__Days_Covered__c));
            }
            coverageList.add(warrantyCoverageObject);
        }
        return coverageList;
    }
    
    @testVisible
    private static List<Id> getPolicyIds(Map<Id, List<Id>> atResponseMap){
        List<Id> policyDefIdList = new List<Id>();
        for(List<Id> policyIds : atResponseMap.values()){
            policyDefIdList.addAll(policyIds);
        }
        return policyDefIdList;
    }
   
    public static Map<Id,WOD_2__Policy_Definition__c> getPolicyDetails(List<Id> policyIdList) {
        Map<Id,WOD_2__Policy_Definition__c> policyDefListMap = new  Map<Id,WOD_2__Policy_Definition__c>();
        List<String> fieldsList =  new List<String>{'Name','WOD_2__Months_Covered__c','WOD_2__Active_From__c','WOD_2__Active_Until__c','WOD_2__Status__c','WOD_2__Sub_Type__c','WOD_2__Type__c','WOD_2__Days_Covered__c'};
		ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', fieldsList);            
        String query = 'SELECT '+String.join(fieldsList,',') + ' FROM WOD_2__Policy_Definition__c WHERE Id IN :policyIdList FOR UPDATE';
        List<WOD_2__Policy_Definition__c> policyDefList =  Database.query(String.escapeSingleQuotes(query));
        return new Map<Id,WOD_2__Policy_Definition__c>(policyDefList);
    }
    
    
    private static WOD_2.AT_RuleEngineInputWrapper getRuleEngineWrapper(Map<Id, WOD_2__Warranty_Registration__c> wrMap, String policyQueryOverirde){
        WOD_2.AT_RuleEngineInputWrapper atWrapper = new WOD_2.AT_RuleEngineInputWrapper();
        List<Id> ruleObjList = new List<Id>(wrMap.keySet());
        atWrapper.ATQueryOverride = policyQueryOverirde;
        atWrapper.baseObjectFieldName = 'Wod_2__Policy_Definition__c';
        atWrapper.ruleObjectIdList = ruleObjList;
        return atWrapper;
    }
    
    private static WOD_2.ResponseWrapper saveCoverages(List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList, List<Id> wrIdList){
        WOD_2.WR_CoverageInputWrapper covrageWrapper = new WOD_2.WR_CoverageInputWrapper();
        covrageWrapper.coverages = warrantyCoveragesList;
        covrageWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
        covrageWrapper.wrRecordIds = wrIdList;
        WOD_2.ResponseWrapper coverageWrapperObj = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);                    
        System.debug('coverageWrapperObj -> ' + coverageWrapperObj);
        return coverageWrapperObj;
    }
    
    
     public class WRDetailsWrapper {
        public String WOD_2_Type_c;
        public Decimal WOD_2_Units_Usage_c;
        public Date WOD_2_Install_Date_c;
        public Boolean ATI_Pre_Delivery_c;
        //Alsn-131
        public Id ATI_Vocation_Code_c;
        public String Vocation_WOD_2_Description_c;
        public String Vocation_Name;
        public Id WOD_2_Customer_c;
        public ATI_Vehicle_Information__c vehicleInfo;
    }
	
}