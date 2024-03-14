/* Name: ATI_REST_UnitHistoryUpdateBatch
Description : ATI_REST_UnitHistoryUpdateBatch - which fires update operation for unit history
History:
VERSION     AUTHOR               DATE                  DETAIL             UserStory/Req#
1.0 -     Tavant(TY)          Mar 18th 2021      INITIAL DEVELOPMENT
*/
global with sharing class ATI_REST_UnitHistoryUpdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    private String query;
    private static Integer defaultInvOrClaimUpdateDays = 1;
    private DateTime dt;
    public Set<Id> setOfSuccessInvIds;
    public Map<Id,WOD_2__Inventory__c> mapOfInventories;
    public ATI_REST_UnitHistoryUpdateBatch(){
        setOfSuccessInvIds = new Set<Id>();
        mapOfInventories = new Map<Id,WOD_2__Inventory__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_Days_Config_for_Unit_History_Update');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null){
            defaultInvOrClaimUpdateDays = Integer.valueOf(logRecordValue.WOD_2__Configuration_Value__c);
        }
        dt = DateTime.now().addDays(defaultInvOrClaimUpdateDays*(-1));
        query = 'SELECT Id,ATI_IsSynced__c FROM WOD_2__Inventory__c WHERE ATI_IsSynced__c=false AND WOD_2__Type__c=\'Retail\' AND LastModifiedDate >='+dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<WOD_2__Inventory__c> invLst){
        Set<Id> setofInvIds = new Set<Id>();
        for(WOD_2__Inventory__c inv : invLst){
            setofInvIds.add(inv.id);
            mapOfInventories.put(inv.id,inv);
        }
        if(!setofInvIds.isEmpty()) {
            Set<Id> invIdsSet = ATI_REST_UnitHistoryUpdate.unitHistoryUpdateRestCall(setofInvIds,dt);
            if(invIdsSet != null){
                setOfSuccessInvIds.addAll(invIdsSet);
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        System.debug('ATI_REST_UnitHistoryUpdate executed');
        //System.debug('setOfSuccessInvIds>>> '+setOfSuccessInvIds);
        if(!Test.isRunningTest()){
            ATI_REST_UnitHistoryUpdate.unitHistoryUpdateForMasterData(dt);
        }
        if(!setOfSuccessInvIds.isEmpty()){
            List<WOD_2__Inventory__c> invLst = new List<WOD_2__Inventory__c>();
            for(Id invId : setOfSuccessInvIds){
                if(mapOfInventories.containsKey(invId)){
                    WOD_2__Inventory__c inv = mapOfInventories.get(invId);
                    inv.ATI_IsSynced__c = true;
                    invLst.add(inv);
                }
            }
            TriggerHandler.byPass('ATI_InventoryTriggerHandler');
            update invLst;
            TriggerHandler.clearByPass('ATI_InventoryTriggerHandler');
        }
    }    
}