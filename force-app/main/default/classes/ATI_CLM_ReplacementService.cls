/* Name: ATI_CLM_ReplacementService
Description : ATI_CLM_ReplacementService - Service class which will be used for all replacement claims.
Running this class in with out sharing mode, so admin related things are handled
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      10-FEB-2021          INITIAL DEVELOPMENT
*/

public without sharing class ATI_CLM_ReplacementService {

    public static void handleReplacementForStringCorrection(Id claimId){
        if(claimId != null){
            List<WOD_2__Claim__c> claimList = getClaimList(new List<Id>{claimId});
            Map<Id, Id> transferWRInvMap = new Map<Id, Id>{claimList[0].WOD_2__Inventory__c => claimList[0].ATI_Replaced_Inventory__c};
            Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap = getVehicleInfoMap(transferWRInvMap.keySet());
            createReplacementHistory(claimList, vehicleInfoMap);
        } else {
            throw new TWoDException('Arrgument can not be null !!!');    
        }                                                   
        
    }
    
    public static void handleRetranReplacement(Id claimId){
        handleReplacement(new List<Id>{claimId});
    }

    public static void handleSwingReplacement(Id claimId){
        handleReplacement(new List<Id>{claimId});
    }
    
    public static void handleReplacement(List<Id> claimIdList){
        handleReplacement(claimIdList, false);
    }
    
    public static void handleReplacement(List<Id> claimIdList, Boolean replaceOnRejectedClaim ){
        System.debug('claimIdList--->'+claimIdList);
        List<WOD_2__Claim__c> claimList = getClaimList(claimIdList);
        if(!claimList.isEmpty()){
            List<WOD_2__Claim__c> retranedReplacementClaims = new List<WOD_2__Claim__c>();             
            List<WOD_2__Claim__c> swingReplacementClaims = new List<WOD_2__Claim__c>();
            // below map will have failed inventory as key and replaced as value
            Map<Id, Id> transferWRInvMap = new Map<Id, Id>();
            for(WOD_2__Claim__c clm : claimList){
                if(clm.ATI_Replacement_Claims__c){
                    if(clm.ATI_Replacement_Type__c == 'SWING'){
                        System.debug('In replacement Service Class');
                        swingReplacementClaims.add(clm);
                        System.debug('swingReplacementClaims--->'+swingReplacementClaims);
                    } else if(clm.ATI_Replacement_Type__c == 'RETRAN'){
                        System.debug('for retran');
                        retranedReplacementClaims.add(clm);
                    }
                    if(clm.WOD_2__Claim_Status__c != 'Rejected' || replaceOnRejectedClaim){
                    	transferWRInvMap.put(clm.WOD_2__Inventory__c, clm.ATI_Replaced_Inventory__c);    
                    }
                    System.debug('transferWRInvMap  --->'+ transferWRInvMap);
                }
            }
            Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap = getVehicleInfoMap(transferWRInvMap.keySet());
            handleRetranReplacement(retranedReplacementClaims, vehicleInfoMap, transferWRInvMap);
            handleSwingReplacement(swingReplacementClaims, vehicleInfoMap, transferWRInvMap);
        }
    } 
    
    private static Map<Id, ATI_Vehicle_Information__c> getVehicleInfoMap(Set<Id> invIdList){
        Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap = new Map<Id, ATI_Vehicle_Information__c>();
        /* Commented due to VIN Transmission Mapper Implementation 
         List<String> fieldList = new List<String>{'Name',
                'ATI_Vocation_Code__c','ATI_Vehicle_Model__c','ATI_Vehicle_Make__c','ATI_Inventory__c'};
        ATI_Utils.NoAccessObjectFieldWrapper vhReadAccess = ATI_Utils.fetchReadAccess('ATI_Vehicle_Information__c', fieldList);
        if(vhReadAccess.noAccessObjectList.isEmpty() && vhReadAccess.noAccessFieldList.isEmpty()){
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from ATI_Vehicle_Information__c where ATI_Inventory__c in :invIdList';    
            List<ATI_Vehicle_Information__c> viList = Database.query(query);
            for(ATI_Vehicle_Information__c vi : viList){
                vehicleInfoMap.put(vi.ATI_Inventory__c, vi);
            }            
        }*/
        // Added Punam 26th April --Veh Transmission Mapper implementation Start
        Set<Id> vehInfoIdSet = new Set<Id>();
        Map<Id,ATI_Vehicle_Information__c> vehInfoDetailsMap = new Map<Id,ATI_Vehicle_Information__c>();
        Map<Id,ATI_VIN_Transmission_Mapper__c> vehInfoIdMapper= mapOfVehInfoIdMapperObj(invIdList);
        if(vehInfoIdMapper!= null){
             List<String> vehFieldList = new List<String>{'Name',
                 'ATI_Vocation_Code__c','ATI_Vehicle_Model__c','ATI_Vehicle_Make__c'};
             ATI_Utils.NoAccessObjectFieldWrapper vhInfoReadAccess = ATI_Utils.fetchReadAccess('ATI_Vehicle_Information__c', vehFieldList);
             if(vhInfoReadAccess.noAccessObjectList.isEmpty() && vhInfoReadAccess.noAccessFieldList.isEmpty()){
                 vehInfoIdSet= vehInfoIdMapper.keyset();    
                 String vehInfoQuery = 'SELECT Id,' + String.join(vehFieldList, ', ') + ' from ATI_Vehicle_Information__c where Id in :vehInfoIdSet';    
                 List<ATI_Vehicle_Information__c> vInfoList = Database.query(vehInfoQuery);
                 for(ATI_Vehicle_Information__c vi: vInfoList){
                     vehInfoDetailsMap.put(vi.Id,vi);
                 }
             }
             
             for(ATI_VIN_Transmission_Mapper__c vi : vehInfoIdMapper.values()){
                vehicleInfoMap.put(vi.ATI_Inventory__c,vehInfoDetailsMap.get(vi.ATI_Vehicle_Information__c));
             }
         }
        //Added Punam 26th April --Veh Transmission Mapper implementation End
        
        return vehicleInfoMap;
    }
    
	// Added Punam 26th April --Veh Transmission Mapper implementation Start
    private static Map<Id,ATI_VIN_Transmission_Mapper__c> mapOfVehInfoIdMapperObj(Set<Id> invIdList){
        Map<Id,ATI_VIN_Transmission_Mapper__c> vehInfoIdMapper = new Map<Id,ATI_VIN_Transmission_Mapper__c>();
        List<String> fieldList = new List<String>{'Name',
            'ATI_Vehicle_Information__c','ATI_Inventory__c'};
        ATI_Utils.NoAccessObjectFieldWrapper vhReadAccess = ATI_Utils.fetchReadAccess('ATI_VIN_Transmission_Mapper__c', fieldList);
        if(vhReadAccess.noAccessObjectList.isEmpty() && vhReadAccess.noAccessFieldList.isEmpty()){
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__c in :invIdList';    
            List<ATI_VIN_Transmission_Mapper__c> viList = Database.query(query);
            for(ATI_VIN_Transmission_Mapper__c vi : viList){
                vehInfoIdMapper.put(vi.ATI_Vehicle_Information__c,vi);
            }
    	}
        return vehInfoIdMapper;
    }
    //Added Punam 26th April --Veh Transmission Mapper implementation End
    
    
    private static void updateVehicleInfo(Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap,
                                          Map<Id, Id> transferWRInvMap){
                                              //New Added for VIN Transmission Mapper
        Map<Id,ATI_VIN_Transmission_Mapper__c> vehInfoIdMapper= mapOfVehInfoIdMapperObj(vehicleInfoMap.keySet());
        
        /* Added By Anjali for Replacement Claim where replaced Inventory should be associated with one VIN of Failed Inventory */
        List<ATI_VIN_Transmission_Mapper__c> vinReplaced = [SELECT Id,ATI_Inventory__c,ATI_Vehicle_Information__c FROM ATI_VIN_Transmission_Mapper__c where ATI_Inventory__c =: transferWRInvMap.values()];
        System.debug('Vin replaced--->'+ vinReplaced);
        if(!vinReplaced.isEmpty())
        {
            delete vinReplaced;
        }       
        for(Id vhId : vehicleInfoMap.keySet()){
            //ATI_Vehicle_Information__c vhInfo = vehicleInfoMap.get(vhId);
            ATI_VIN_Transmission_Mapper__c vinMapper = vehInfoIdMapper.get(vehicleInfoMap.get(vhId).id);
            //vhInfo.ATI_Inventory__c = transferWRInvMap.get(vhInfo.ATI_Inventory__c);
            vinMapper.ATI_Inventory__c= transferWRInvMap.get(vinMapper.ATI_Inventory__c);
        }
        //update vehicleInfoMap.values();
        update vehInfoIdMapper.values();
        //alsn-139                                      
        updateInvVehInfo(vehInfoIdMapper);                                             
    }
    
    /* to update the vehicle information on to the replaced inventory */
    
    private static void updateInvVehInfo(Map<Id, ATI_VIN_Transmission_Mapper__c> vehInfoIdMapper)
    {
        for(Id mapperId : vehInfoIdMapper.KeySet()){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = [Select Id,ATI_Vehicle_Information__c,ATI_Inventory__c from ATI_VIN_Transmission_Mapper__c where Id=:vehInfoIdMapper.get(mapperId).Id];
            if(vehicleTransMapper.ATI_Inventory__c!=null){
                WOD_2__Inventory__c invToUpdateObj = new WOD_2__Inventory__c(Id=vehicleTransMapper.ATI_Inventory__c);
                invToUpdateObj.Vehicle_Information__c = vehicleTransMapper.ATI_Vehicle_Information__c;
                update invToUpdateObj;
            }
        }                                              
        
    }   
    //end of alsn-139
    private static void handleSwingReplacement(List<WOD_2__Claim__c> claimList,
                                               Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap,
                                               Map<Id, Id> transferWRInvMap){
        if(!claimList.isEmpty()){
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            deactivateActiveRegistration(transferWRInvMap.values());
            createReplacementHistory(claimList, vehicleInfoMap);
            transferWarranty(transferWRInvMap);
            deactivateInventories(transferWRInvMap);         
            updateVehicleInfo(vehicleInfoMap,transferWRInvMap);
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
            TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        }                                                   
    }

    private static void handleRetranReplacement(List<WOD_2__Claim__c> claimList,
                                               Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap,
                                               Map<Id, Id> transferWRInvMap){
        if(!claimList.isEmpty()){
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            deactivateActiveRegistration(transferWRInvMap.values());
            createReplacementHistory(claimList, vehicleInfoMap);
            transferWarranty(transferWRInvMap);
            markInventoriesAsScraped(transferWRInvMap);
            updateVehicleInfo(vehicleInfoMap, transferWRInvMap);
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
            TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
        }
    }
    
    public static void updateReplacement(Id claimId, Id oldReplacedInv){
        List<WOD_2__Claim__c> claimList = getClaimList(new List<Id>{claimId});
        Map<Id, Id> transferWRInvMap = new Map<Id, Id>{oldReplacedInv => claimList[0].ATI_Replaced_Inventory__c};
        Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap = getVehicleInfoMap(transferWRInvMap.keySet());
        TriggerHandler.bypass('ATI_InventoryTriggerHandler');
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        transferWarranty(transferWRInvMap);
        ATI_WarrantyService.deRegisterWarranty(new List<Id>{oldReplacedInv},'De-Registered and warranty moved to ' + claimList[0].ATI_Replaced_Inventory__c);
        updateReplacementHistory(claimList[0]);
        updateVehicleInfo(vehicleInfoMap, transferWRInvMap);
        Map<Id, WOD_2__Inventory__c> invMap = fetchInventoryMapForUpdate(transferWRInvMap);
        copyAttributesFromFailedToReplaced(invMap.get(oldReplacedInv), invMap.get(claimList[0].ATI_Replaced_Inventory__c));
        invMap.get(oldReplacedInv).WOD_2__Type__c = 'Stock'; 
        invMap.get(oldReplacedInv).ATI_Active__c = false;
        if(claimList[0].ATI_Replacement_Type__c == 'SWING'){
        	invMap.get(oldReplacedInv).WOD_2__Pre_Owned__c = true;    
        } else {
            invMap.get(oldReplacedInv).WOD_2__Scrapped__c = false;    
        }
        update invMap.values();
        TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
    }

    
    public static void deleteReplacement(Id claimId, Id failedInv, Id replacedInv){
        List<WOD_2__Claim__c> claimList = getClaimList(new List<Id>{claimId});
        Map<Id, Id> transferWRInvMap = new Map<Id, Id>{replacedInv => failedInv};
        Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap = getVehicleInfoMap(transferWRInvMap.keySet());
        TriggerHandler.bypass('ATI_InventoryTriggerHandler');
        TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
        deactivateActiveRegistration(transferWRInvMap.values());
        deleteReplacementHistory(claimId);
        transferWarranty(transferWRInvMap);
        updateVehicleInfo(vehicleInfoMap, transferWRInvMap);
        Map<Id, WOD_2__Inventory__c> invMap = fetchInventoryMapForUpdate(transferWRInvMap);
        copyAttributesFromFailedToReplaced(invMap.get(replacedInv), invMap.get(failedInv));
        invMap.get(failedInv).ATI_Primary_Failure__c = null;
        invMap.get(failedInv).ATI_Active__c = true;
        invMap.get(replacedInv).WOD_2__Type__c = 'Stock'; 
        invMap.get(replacedInv).ATI_Active__c = true;
        if(claimList[0].ATI_Replacement_Type__c == 'SWING'){
        	invMap.get(replacedInv).WOD_2__Pre_Owned__c = false;    
        } else {
            invMap.get(replacedInv).WOD_2__Scrapped__c = false;    
            invMap.get(failedInv).WOD_2__Scrapped__c = false;    
        }
        update invMap.values();
        TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
    }
    
    private static Map<Id, WOD_2__Inventory__c> fetchInventoryMapForUpdate(Map<Id, Id> transferWRInvMap){
        List<String> fieldList = new List<String>{'ATI_Active__c','WOD_2__Type__c','WOD_2__Account__c',
            'WOD_2__Customer__c','WOD_2__Install_Date__c','ATI_Vocation_Code__c','ATI_Warranty_Status__c',
            'WOD_2__Warranty_Start_Date__c','WOD_2__Warranty_End_Date__c','ATI_Primary_Failure__c','WOD_2__Pre_Owned__c'};
        ATI_Utils.checkForAccess('WOD_2__Inventory__c', 'UPDATE', fieldList);
        Set<Id> invIdSet = new Set<Id>(transferWRInvMap.keySet());
        invIdSet.addAll(transferWRInvMap.values());
        String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from WOD_2__Inventory__c where Id in :invIdSet';    
        List<WOD_2__Inventory__c> invList = Database.query(query);
        return new Map<Id, WOD_2__Inventory__c>(invList);
    }
    
    private static void deleteReplacementHistory(Id claimId){
        //ATI_Utils.checkForAccess('ATI_Inventory_Replacement_History__c', 'DELETE', null);
        List<ATI_Inventory_Replacement_History__c> irhList = [select id from ATI_Inventory_Replacement_History__c where ATI_Claim__c = :claimId];
        ATI_QueryRunWithoutSharing.deleteData(irhList, true);
    }

    private static void updateReplacementHistory(WOD_2__Claim__c claim){
        ATI_Utils.checkForAccess('ATI_Inventory_Replacement_History__c', 'UPDATE', new List<String>{'ATI_Claim__c', 'ATI_Replaced_Inventory__c', 'ATI_Replacement_Type__c'});
        List<ATI_Inventory_Replacement_History__c> irhList = [select id,ATI_Replaced_Inventory__c,ATI_Replacement_Type__c from ATI_Inventory_Replacement_History__c where ATI_Claim__c = :claim.Id];
        if(irhList.isEmpty()){
            throw new TWoDException('Replacement history not forund with this claim');
        }else if(irhList.size() > 1){
            throw new TWoDException('More than one Replacement history found for this claim');
        }
        irhList[0].ATI_Replaced_Inventory__c = claim.ATI_Replaced_Inventory__c;
        irhList[0].ATI_Replacement_Type__c = claim.ATI_Replacement_Type__c;
		update irhList;            
    }
    
    
    private static void deactivateInventories(Map<Id, Id> transferWRInvMap){
        List<String> fieldList = new List<String>{'ATI_Active__c','WOD_2__Type__c','WOD_2__Account__c',
            'WOD_2__Customer__c','WOD_2__Install_Date__c','ATI_Vocation_Code__c','ATI_Warranty_Status__c',
            'WOD_2__Warranty_Start_Date__c','WOD_2__Warranty_End_Date__c','ATI_Primary_Failure__c','WOD_2__Pre_Owned__c','Vehicle_Information__c'};
        ATI_Utils.NoAccessObjectFieldWrapper invUpdateAccess = ATI_Utils.fetchUpdateAccess('WOD_2__Inventory__c', fieldList);
        if(invUpdateAccess.noAccessObjectList.isEmpty() && invUpdateAccess.noAccessFieldList.isEmpty()){
            System.debug('Failed INV result---->');
            Set<Id> invIdSet = new Set<Id>(transferWRInvMap.keySet());
            invIdSet.addAll(transferWRInvMap.values());
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from WOD_2__Inventory__c where Id in :invIdSet';    
            List<WOD_2__Inventory__c> invList = Database.query(query);
            Map<Id, WOD_2__Inventory__c> invMap = new Map<Id, WOD_2__Inventory__c>(invList);
            for(Id invId : transferWRInvMap.keySet()){
                System.debug('Transfer WR inv');
                WOD_2__Inventory__c failedInv = invMap.get(invId);
                WOD_2__Inventory__c replacedInv = invMap.get(transferWRInvMap.get(invId));
                failedInv.ATI_Active__c = false;
                failedInv.WOD_2__Pre_Owned__c = true; 
                failedInv.WOD_2__Type__c = 'Stock';
                failedInv.Vehicle_Information__c =null;
                copyAttributesFromFailedToReplaced(failedInv, replacedInv);
            }
            update invList; 
            System.debug('Failed INV result---->'+invList);
        } else {
            throw new TWODException(Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Inventory__c' + ', Fields: ' + String.join(invUpdateAccess.noAccessFieldList, ','));            
        }
    }

    
    private static void markInventoriesAsScraped(Map<Id, Id> transferWRInvMap){
        List<String> fieldList = new List<String>{'WOD_2__Scrapped__c','WOD_2__Type__c','WOD_2__Account__c',
            'WOD_2__Customer__c','WOD_2__Install_Date__c','ATI_Vocation_Code__c','ATI_Warranty_Status__c',
            'WOD_2__Warranty_Start_Date__c','WOD_2__Warranty_End_Date__c','ATI_Primary_Failure__c','Vehicle_Information__c'};
        ATI_Utils.NoAccessObjectFieldWrapper invUpdateAccess = ATI_Utils.fetchUpdateAccess('WOD_2__Inventory__c', fieldList);
        if(invUpdateAccess.noAccessObjectList.isEmpty() && invUpdateAccess.noAccessFieldList.isEmpty()){
            Set<Id> invIdSet = new Set<Id>(transferWRInvMap.keySet());
            invIdSet.addAll(transferWRInvMap.values());
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from WOD_2__Inventory__c where Id in :invIdSet';    
            List<WOD_2__Inventory__c> invList = Database.query(query);
            Map<Id, WOD_2__Inventory__c> invMap = new Map<Id, WOD_2__Inventory__c>(invList);
            for(Id invId : transferWRInvMap.keySet()){
                WOD_2__Inventory__c failedInv = invMap.get(invId);
                WOD_2__Inventory__c replacedInv = invMap.get(transferWRInvMap.get(invId));
                failedInv.WOD_2__Scrapped__c = true;
                failedInv.ATI_Active__c = false;
                failedInv.WOD_2__Type__c = 'Stock';
                failedInv.Vehicle_Information__c =null;
                copyAttributesFromFailedToReplaced(failedInv, replacedInv);
            }
            update invList; 
        } else {
            throw new TWODException(Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Inventory__c' + ', Fields: ' + String.join(invUpdateAccess.noAccessFieldList, ','));            
        }
        
    }
    
    private static void copyAttributesFromFailedToReplaced(WOD_2__Inventory__c failedInv, WOD_2__Inventory__c replacedInv){
        replacedInv.WOD_2__Type__c = 'Retail';
        replacedInv.WOD_2__Account__c = failedInv.WOD_2__Account__c;
        replacedInv.WOD_2__Customer__c = failedInv.WOD_2__Customer__c;
        replacedInv.WOD_2__Install_Date__c = failedInv.WOD_2__Install_Date__c;
        replacedInv.ATI_Vocation_Code__c = failedInv.ATI_Vocation_Code__c;
        replacedInv.WOD_2__Warranty_Start_Date__c = failedInv.WOD_2__Warranty_Start_Date__c;
        replacedInv.WOD_2__Warranty_End_Date__c = failedInv.WOD_2__Warranty_End_Date__c;
        replacedInv.ATI_Warranty_Status__c = failedInv.ATI_Warranty_Status__c;
        Id primaryFailureSerialNumber = (failedInv.ATI_Primary_Failure__c == null) ? failedInv.Id : failedInv.ATI_Primary_Failure__c;
        replacedInv.ATI_Primary_Failure__c = primaryFailureSerialNumber;
    }
    
    private static void createReplacementHistory(List<WOD_2__Claim__c> claimList, Map<Id, ATI_Vehicle_Information__c> vehicleInfoMap){
        System.debug('claimList--->'+claimList);
        List<ATI_Inventory_Replacement_History__c> replacementHistory = new List<ATI_Inventory_Replacement_History__c>();
        Map<String, ATI_Inventory_Replacement_History__c> invRepHistMap = getInvReplacementHistMap(new Map<Id,ATI_Vehicle_Information__c>(vehicleInfoMap.values()).keySet());
        if(!vehicleInfoMap.isEmpty() && !claimList.isEmpty()){
            for(WOD_2__Claim__c clm : claimList){
                ATI_Inventory_Replacement_History__c irh = new ATI_Inventory_Replacement_History__c();
                irh.ATI_Claim__c = clm.Id;
                irh.ATI_Account__c = clm.WOD_2__Account__c;
                irh.ATI_Failed_Inventory__c = clm.WOD_2__Inventory__c;
                irh.ATI_Replaced_Inventory__c = clm.ATI_Replaced_Inventory__c;
                irh.ATI_Replacement_Date__c = clm.WOD_2__Date_Of_Repair__c;
                irh.ATI_Replacement_Type__c = clm.ATI_Replacement_Type__c;
                irh.ATI_Vehicle_Information__c = vehicleInfoMap.get(clm.WOD_2__Inventory__c).Id;
                String key = String.valueOf(clm.WOD_2__Inventory__c) + irh.ATI_Vehicle_Information__c;
                irh.ATI_Original_Inventory__c = 
                    (invRepHistMap.containsKey(key)) ? invRepHistMap.get(key).ATI_Original_Inventory__c : clm.WOD_2__Inventory__c;
                replacementHistory.add(irh);
            }
        }
        ATI_Utils.NoAccessObjectFieldWrapper irhCreateAccess =
            ATI_Utils.fetchCreateAccess('ATI_Inventory_Replacement_History__c', new List<String>{'ATI_Claim__c',
                'ATI_Account__c','ATI_Failed_Inventory__c','ATI_Replaced_Inventory__c','ATI_Replacement_Date__c',
                'ATI_Replacement_Type__c','ATI_Vehicle_Information__c','ATI_Original_Inventory__c'});
        if(irhCreateAccess.noAccessObjectList.isEmpty() && irhCreateAccess.noAccessFieldList.isEmpty()){
            System.debug('In Replacement Hstry');
            insert replacementHistory;
        }
    }
    
    
    // this method create a map with ATI_Inventory_Replacement_History__c as value and ATI_Replaced_Inventory__c + ATI_Vehicle_Information__c as key 
    public static Map<String, ATI_Inventory_Replacement_History__c> getInvReplacementHistMap(Set<Id> vehicleInfoIdSet){
        ATI_Utils.checkForAccess('ATI_Inventory_Replacement_History__c ', 'READ', new List<String>{'ATI_Failed_Inventory__c', 'ATI_Vehicle_Information__c','ATI_Replaced_Inventory__c','ATI_Original_Inventory__c'});
        ATI_Utils.checkForAccess('ATI_VIN_Transmission_Mapper__c', 'READ', new List<String>{'ATI_Inventory__c','ATI_Vehicle_Information__c'});
        List<ATI_Inventory_Replacement_History__c> irhList = 
            [select id, ATI_Failed_Inventory__c, ATI_Replaced_Inventory__c, ATI_Original_Inventory__c, ATI_Vehicle_Information__c  from ATI_Inventory_Replacement_History__c where 
             ATI_Vehicle_Information__c in :vehicleInfoIdSet and ATI_Replaced_Inventory__c in 
             (select ATI_Inventory__c from ATI_VIN_Transmission_Mapper__c where ATI_Vehicle_Information__c in :vehicleInfoIdSet  )];
        Map<String, ATI_Inventory_Replacement_History__c> irhMap = new Map<String, ATI_Inventory_Replacement_History__c>();
        for(ATI_Inventory_Replacement_History__c irh : irhList){
            String key = String.valueOf(irh.ATI_Replaced_Inventory__c) + irh.ATI_Vehicle_Information__c;
            irhMap.put(key, irh);
        }
        return irhMap;
    }
    
    // below method transfer's warranty from key inventory id to value inventory id
    // it is assumed that the WR to be transfered inventory is still in stock and 
    // all the coverages from key inv id will be transffered to value
    // Cancels the WR once the transfer of warranty sis complete
    private static void transferWarranty(Map<Id, Id> transferWRInvMap){
        List<WOD_2__Inventory__c> failedInvList = ATI_WarrantyService.getInventoriesForWR(new List<Id>(transferWRInvMap.keySet()));
        Map<Id, WOD_2__Inventory__c> failedInvMap = new Map<Id, WOD_2__Inventory__c>(failedInvList);
        List<WOD_2__Warranty_Registration__c> failedInvWRList = ATI_WarrantyService.getWRListForInventories(failedInvMap);
        System.debug('failedInvWRList--->'+failedInvWRList);
        Map<Id, WOD_2__Warranty_Registration__c> failedInvWRMap = new Map<Id, WOD_2__Warranty_Registration__c>(failedInvWRList);
        List<WOD_2__Warranty_Coverages__c> failedInvCoverages = fetchWarrantyCoverages(failedInvWRMap.keySet());
        Map<Id, WOD_2__Warranty_Coverages__c> failedInvCoveragesMap = new Map<Id, WOD_2__Warranty_Coverages__c>(failedInvCoverages);
        Map<Id, Id> oldWRToNewWRMap = new Map<Id, Id>();
        cloneWRsForRegistration(failedInvWRList, transferWRInvMap, oldWRToNewWRMap);
        cloneCoverages(failedInvCoveragesMap.values(), oldWRToNewWRMap);
        for(WOD_2__Warranty_Registration__c wr : failedInvWRList){
            wr.WOD_2__Status__c = 'InActive';
        }
        update failedInvWRList;
    }
    
    private static void
        cloneWRsForRegistration(List<WOD_2__Warranty_Registration__c> wrsToClone,
                                Map<Id, Id> transferWRMap,
                                Map<Id, Id> oldWRToNewWRMap){
        Map<Id,WOD_2__Inventory__c> replacedInvMap = 
            new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Item__c FROM WOD_2__Inventory__c
                                            	WHERE Id IN :transferWRMap.values()]);
        List<WOD_2__Warranty_Registration__c> clonedWRList = new List<WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c wr : wrsToClone){
            WOD_2__Warranty_Registration__c clonedWR = wr.clone(false, false, false, false);
            clonedWR.WOD_2__Inventory__c = transferWRMap.get(wr.WOD_2__Inventory__c);
            if(replacedInvMap.containsKey(clonedWR.WOD_2__Inventory__c) 
               && replacedInvMap.get(clonedWR.WOD_2__Inventory__c).WOD_2__Item__c!=NULL){
                clonedWR.WOD_2__Warranty_Product__c = replacedInvMap.get(clonedWR.WOD_2__Inventory__c).WOD_2__Item__c;
            }
            clonedWR.ATI_Vocation_Code__c = wr.ATI_Vocation_Code__c;
            //Added by Dishari Regarding Replaced WR name
            clonedWR.Name = wr.Name;
            //End Here
            clonedWR.WOD_2__Registration_Comments__c='Registered as part of replacement claim';
            clonedWR.WOD_2__Status__c = 'Registered';
            clonedWRList.add(clonedWR);
        }
        System.debug('clonedWRList--->'+clonedWRList);
        insert clonedWRList;
        for(WOD_2__Warranty_Registration__c wr : clonedWRList){
            oldWRToNewWRMap.put(wr.getCloneSourceId(), wr.Id);
        }                                                                                    
    }
    
    private static void 
        cloneCoverages(List<WOD_2__Warranty_Coverages__c> coveragesToClones, Map<Id, Id> oldWRToNewWRMap){
        List<WOD_2__Warranty_Coverages__c> clonedCoverageList = new List<WOD_2__Warranty_Coverages__c>();
        for(WOD_2__Warranty_Coverages__c c : coveragesToClones){
            //String coverageStr = JSON.serialize(c).replace(c.WOD_2__Warranty_Registration__c,oldWRToNewWRMap.get(c.WOD_2__Warranty_Registration__c));
            //WOD_2__Warranty_Coverages__c clonedCoverage = (WOD_2__Warranty_Coverages__c)JSON.deserialize(coverageStr, WOD_2__Warranty_Coverages__c.class);
            WOD_2__Warranty_Coverages__c clonedCoverage = c.clone(false,false,false,false);
            clonedCoverage.WOD_2__Warranty_Registration__c = oldWRToNewWRMap.get(c.WOD_2__Warranty_Registration__c);
            clonedCoverageList.add(clonedCoverage);
        }
        insert clonedCoverageList;             
    }
    
    public static List<WOD_2__Warranty_Coverages__c> fetchWarrantyCoverages(Set<Id> wrIds){
        List<String> fieldList = new List<String>{
            'ATI_isExtended__c',' WOD_2__Is_Active__c', 'WOD_2__Maximum_Unit__c', 'WOD_2__Policy_Definition__c', 'WOD_2__Policy_OffSeason__c', 
            'ATI_Reason__c', 'WOD_2__Rollup_Warranty_Date__c','WOD_2__Warranty_End_Date__c','WOD_2__Warranty_Registration__c', 'WOD_2__Warranty_Start_Date__c',
            'WOD_2__Unit_Type_1__c','WOD_2__Unit_Type_2__c','WOD_2__Unit_Type_3__c','WOD_2__Unit_Type_4__c','WOD_2__Unit_Type_5__c',
            'WOD_2__Unit_Usage_1__c','WOD_2__Unit_Usage_2__c','WOD_2__Unit_Usage_3__c','WOD_2__Unit_Usage_4__c','WOD_2__Unit_Usage_5__c',
			'WOD_2__Warranty_Registration__r.WOD_2__Inventory__c'                
        };
        ATI_Utils.NoAccessObjectFieldWrapper coverageAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Coverages__c', fieldList);
        if(coverageAccess.noAccessObjectList.isEmpty() && coverageAccess.noAccessFieldList.isEmpty()){
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c in :wrIds';    
            return Database.query(query);
        }
        throw new TWODException(Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Warranty_Coverages__c' + ', Fields: ' + String.join(coverageAccess.noAccessFieldList, ','));        
    }   
    
    private static List<WOD_2__Claim__c> getClaimList(List<Id> claimIdList){
        List<String> fieldList = new List<String>{
            'WOD_2__Claim_Status__c','ATI_Replacement_Claims__c','WOD_2__Account__c', 'WOD_2__Inventory__c', 'ATI_Replacement_Type__c', 
            'ATI_Replaced_Inventory__c', 'ATI_Replaced_Model__c', 'WOD_2__Date_Of_Repair__c','WOD_2__Date_Of_Failure__c','WOD_2__Inventory__r.WOD_2__Pre_Owned__c'
        };
        ATI_Utils.NoAccessObjectFieldWrapper claimAccess = ATI_Utils.fetchReadAccess('WOD_2__Claim__c', fieldList);
        if(claimAccess.noAccessObjectList.isEmpty() && claimAccess.noAccessFieldList.isEmpty()){
            String query = 'SELECT Id,' + String.join(fieldList, ', ') + ' from WOD_2__Claim__c where Id in :claimIdList';    
            return Database.query(query);
        }
        throw new TWODException(Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Claim__c' + ', Fields: ' + String.join(claimAccess.noAccessFieldList, ','));        
    }
    
    private static void deactivateActiveRegistration(List<Id> replacedInvList){
        String deregistercomment = 'Failed Inventory Deregistered Process';
        ATI_WarrantyService.deRegisterWarranty(replacedInvList,deregistercomment);
    }
}