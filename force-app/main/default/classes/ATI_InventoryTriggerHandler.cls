/**
-------------------------------------------------------------------------------------------------
This is Inventory Trigger handler class
* --------------------------------------------------------------------------------------------------
* @author         Punam Chakraborty
* @version        1.0
* @created        25-NOV-2020
* @modified
* @description :   Trigger Handler Class for Inventory Trigger
* --------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_InventoryTriggerHandler extends TriggerHandler{
    private List<WOD_2__Inventory__c> newInvList;
    private List<WOD_2__Inventory__c> oldInvList;
    private Map<Id, WOD_2__Inventory__c> newInvMap;
    private Map<Id, WOD_2__Inventory__c> oldInvMap;
    public static Boolean skipInvTriggerHandlerForITR = false;
    //Alsn-207 aded isBulkUpload variable
    public static Boolean isBulkUpload = false;
    //Modifed by Manoj Paul for Issue regarding blank values of vaocation code, Inservice Date etc
    Public Set<Id> invIds = new Set<Id>();
    Public Set<Id> invRetailId = new Set<Id>();
    /*
Method Name :   ATI_InventoryTriggerHandler
Method Added By Punam
Constructor Method ATI_InventoryTriggerHandler
*/
    
    public ATI_InventoryTriggerHandler(){
        this.newInvList = (List<WOD_2__Inventory__c>)Trigger.new;
        this.oldInvList= (List<WOD_2__Inventory__c>)Trigger.old;
        this.newInvMap= (Map<Id, WOD_2__Inventory__c>)Trigger.newMap;
        this.oldInvMap= (Map<Id, WOD_2__Inventory__c>)Trigger.oldMap;
    }
    
    public override void afterInsert() {
        //addInventoryShareRecords(newInvList);
    }
    public override void afterUpdate() {
        if(!skipInvTriggerHandlerForITR){
            // WR for vocation code change is needed only if the transmission is already registered, it is not needed for STOCK
            List<WOD_2__Inventory__c> invList = new List<WOD_2__Inventory__c>();
            for(WOD_2__Inventory__c inv : newInvList){
                if(inv.WOD_2__Type__c == 'Retail'){
                    invList.add(inv);
                    //Modifed by Manoj Paul for Issue regarding blank values of vaocation code, Inservice Date etc
                    invIds.add(inv.Id);
                }
            }
            if(!invList.isEmpty()){
                createNewWRonVacationCodeChange(invList,oldInvMap);
            } 
        }
    }
    
    public override void beforeUpdate() {
        for(WOD_2__Inventory__c inv : newInvList){
            if(inv.ATI_IsSynced__c && inv.WOD_2__Type__c == 'Retail'){
                inv.ATI_IsSynced__c = false;
            }
            if(inv.WOD_2__Type__c == 'Stock' && oldInvMap.get(inv.id).WOD_2__Type__c == 'Retail'){
            invRetailId.add(inv.Id);
            }
        }
        if(!skipInvTriggerHandlerForITR){
            validateUpdateByDealer(newInvList,oldInvMap);
            //updateRecordTypeforPredeliveryWR(newInvList,oldInvMap);
        //Modifed by Manoj Paul for Issue regarding blank values of vaocation code, Inservice Date etc
            //ALSN-148 if condition added for query optimization
            if(invRetailId.size()>0){
                Set<Id> deregWrIds = new Set<Id>();
                for(WOD_2__Warranty_Registration__c  wr :[SELECT id,WOD_2__Status__c, WOD_2__De_Registration_Date__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c IN:invRetailId]){
                    If(wr.WOD_2__Status__c.equalsignorecase('De-Registered')){
                        deregWrIds.add(wr.Id);
                    }
                    System.debug('>>deregWrIds :'+deregWrIds);
                }
                if(!deregWrIds.isEmpty()){
                    updateInvOnDeRegistration(newInvList,oldInvMap);
                }
            }
        //End of Modification by Manoj Paul
        //createInventoryTransHistoryOnCustomerChange(newInvMap,oldInvMap);
    }
    }
    
    public static void validateUpdateByDealer(List<WOD_2__Inventory__c> newList, Map<Id, WOD_2__Inventory__c> oldMap){
        //ALSN-148 query optimization - using network id to determine partner user
        //WOD_2.ResponseWrapper response = ATI_Utils.isPartnerUser();    
        //if(response.data=='true'){
        if(Network.getNetworkId() != null){
            for(WOD_2__Inventory__c invObj : (List<WOD_2__Inventory__c>)Trigger.New){
                if((invObj.Name != oldMap.get(invObj.Id).Name) 
                   //ALSN-59 commented the Business partner change condition for Community users
                   // || (invObj.WOD_2__Account__c != oldMap.get(invObj.Id).WOD_2__Account__c && !(invObj.WOD_2__Type__c=='Retail' 
                    //&& oldMap.get(invObj.Id).WOD_2__Type__c=='Stock') )
                  )
                {
                    invObj.addError('Editing Not Allowed!');	
                }
            }
        }
    }
    
    /* 
* 
* Method Added By Mukesh 20583 WR 12/2/2020
* 
* DeRegister and ReRegister the Inventory if Vocation code, Install Date and Model is updated 
* 
*/
    public static void createNewWRonVacationCodeChange(List<WOD_2__Inventory__c> newList, Map<Id, WOD_2__Inventory__c> oldMap){
        
        System.debug('>>> :createNewWRonVacationCodeChange ');
        List<WOD_2__Warranty_Registration__c> newWRList = new List<WOD_2__Warranty_Registration__c>();
        List<WOD_2__Warranty_Registration__c> oldWRList = new List<WOD_2__Warranty_Registration__c>();
        Map<Id,WOD_2__Inventory__c> invIdtoRecordMap = new Map<Id,WOD_2__Inventory__c>();
        Map<Id,WOD_2__Warranty_Registration__c> warrantyRegistrationMap = new Map<Id,WOD_2__Warranty_Registration__c>();
        List<WOD_2__Warranty_Coverages__c> newCoverageRecords = new List<WOD_2__Warranty_Coverages__c>();
        try {
            System.debug('>>> :newList size: '+newList.size());
           
           
            for(WOD_2__Inventory__c inv : newList){
                System.debug('>>After Update  inv.ATI_Vocation_Code__c :'+inv.ATI_Vocation_Code__c); 
                System.debug('>>After Update  oldMap.get(inv.id).Vocation_Code__c :'+oldMap.get(inv.id).ATI_Vocation_Code__c);
                System.debug('>>After Update  inv.WOD_2__Type__c :'+inv.WOD_2__Install_Date__c+ ' >>>> '+oldMap.get(inv.id).WOD_2__Install_Date__c);
                
                if((inv.ATI_Vocation_Code__c !=null && oldMap.get(inv.id).ATI_Vocation_Code__c !=null && inv.ATI_Vocation_Code__c !=oldMap.get(inv.id).ATI_Vocation_Code__c )|| 
                   (inv.WOD_2__Install_Date__c != null && oldMap.get(inv.id).WOD_2__Install_Date__c != null && inv.WOD_2__Install_Date__c != oldMap.get(inv.id).WOD_2__Install_Date__c) || 
                   (inv.WOD_2__Item__c!=null && oldMap.get(inv.id).WOD_2__Item__c!=null && inv.WOD_2__Item__c!= oldMap.get(inv.id).WOD_2__Item__c) ){
                       invIdtoRecordMap.put(inv.id,inv);
                   }
            }
            //Alsn-159 serialising the map to use it in the future method
            if(invIdtoRecordMap.keyset().size()>0){
                String inventoryListJson = JSON.serialize(invIdtoRecordMap);     
                System.debug('batch'+System.IsBatch()+'future'+ System.isFuture()+'isbulk'+isBulkUpload);
                //Alsn-159 added a check to run the method only if none of the batch or future method is in process
                if(!System.IsBatch() && !System.isFuture() && isBulkUpload == false){
                ATI_WarrantyService.reRegisterWarrantyWithStdPolicies(inventoryListJson, '');
                }
                //Alsn-207 added isBulkUpload check 
                else if(isBulkUpload == true){
                ATI_WarrantyService.reRegisterWRForBulk(inventoryListJson, '');  
                }
            }
        }catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' at LINE NUMBER ' + e.getLineNumber());
        }
    }
    
    /* 
* 
* Method Added By Mukesh 20583 WR 12/9/2020
* 
* Preventing to update the inv status is WR is preRegistration. 
* 
*/
    /*public static void updateRecordTypeforPredeliveryWR(List<WOD_2__Inventory__c> newList, Map<Id, WOD_2__Inventory__c> oldMap){
        System.debug('>>> updateRecordTypeforPredeliveryWR:');
        Id rtStockId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByName().get('Stock').getRecordTypeId();
        Id rtRetailId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByName().get('Retail').getRecordTypeId();
       	Map<id,boolean> invIdToIsPredelivery = new Map<id,boolean>();
        set<id> invIdSet = new set<id>();
        List<WOD_2__Warranty_Registration__c> wrList = new List<WOD_2__Warranty_Registration__c>();
        
        for(WOD_2__Inventory__c inv:[SELECT id, (SELECT id,ATI_Pre_Delivery__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__r ORDER BY createdDate DESC Limit 1) FROM WOD_2__Inventory__c WHERE id IN :newList]){
            
            if((!inv.WOD_2__Warranty_Registration__r.isEmpty()) && (inv.WOD_2__Warranty_Registration__r[0].ATI_Pre_Delivery__c) && inv.WOD_2__Warranty_Registration__r[0].WOD_2__Registration_Type__c != 'Pre-delivery'){
                WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c();
                wr.id = inv.WOD_2__Warranty_Registration__r[0].id;
                wr.WOD_2__Registration_Type__c = 'Pre-delivery';
                wrList.add(wr);
                System.debug('>> inv.WOD_2__Warranty_Registration__r[0] :'+inv.WOD_2__Warranty_Registration__r[0]);
                invIdToIsPredelivery.put(inv.id,inv.WOD_2__Warranty_Registration__r[0].ATI_Pre_Delivery__c);
                invIdSet.add(inv.id);
            }
        }
        System.debug('>> invIdSet :'+invIdSet);
        //Modifed by Manoj Paul for Issue regarding blank values of vaocation code, Inservice Date etc
        if(!invIdSet.isEmpty()){
            for(WOD_2__Inventory__c newInv: newList){
                if(invIdSet.contains(newInv.id) && (newInv.RecordTypeId != oldMap.get(newInv.id).RecordTypeId) && (newInv.RecordTypeId == rtRetailId) && (oldMap.get(newInv.id).RecordTypeId ==rtStockId) ){
                    newInv.RecordTypeId = rtStockId;
                    newInv.WOD_2__Type__c = 'Stock';
                }
                Modified by Anjali for PreDelivery WR to keep inventory As Stock
                if(invIdToIsPredelivery.get(newInv.Id) == true && (newInv.RecordTypeId == rtStockId))
                {
                    newInv.RecordTypeId = rtStockId;
                    newInv.WOD_2__Type__c = 'Stock';
                }
                Change complete
            }
        }
        System.debug('>> wrList :'+wrList);
        if(!wrList.isEmpty()){
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update wrList;
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        }
    }*/
    
    /* 
* 
* Method Added By Mukesh 20583 WR 1/12/2021
* 
* Update the fields on Inv in case of deregistration. 
*  
*/
    public static void updateInvOnDeRegistration(List<WOD_2__Inventory__c> newList, Map<Id, WOD_2__Inventory__c> oldMap){
        Id rtStockId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByName().get('Stock').getRecordTypeId();
        Id rtRetailId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByName().get('Retail').getRecordTypeId();
        Set<id> invIdSet = new Set<id>();
        List<WOD_2__Warranty_Registration__c> wrList = new List<WOD_2__Warranty_Registration__c>();
        List<ATI_VIN_Transmission_Mapper__c> vINList = new List<ATI_VIN_Transmission_Mapper__c>();
        for(WOD_2__Inventory__c inv :newList){
            system.debug('inv.RecordTypeId**'+inv.RecordTypeId+'**'+oldMap.get(inv.id).RecordTypeId+'**'+rtStockId+'**'+inv.RecordTypeId+'****'+rtRetailId);
            if((inv.RecordTypeId != oldMap.get(inv.id).RecordTypeId) && (inv.RecordTypeId == rtStockId) && (oldMap.get(inv.id).RecordTypeId ==rtRetailId)){
                system.debug('Inside if of Inventory Trigger---->');
                inv.ATI_Vocation_Code__c = null;
               // inv.ATI_Program_Level__c = '';
                inv.WOD_2__Install_Date__c = null;
                inv.WOD_2__Warranty_Start_Date__c = null;
                inv.WOD_2__Warranty_End_Date__c = null;
                invIdSet.add(inv.id);
            }
        }
        System.debug('>> invIdSet:'+invIdSet);
        
        if(!invIdSet.isEmpty()){
            
            for(WOD_2__Inventory__c inv : [SELECT id , (SELECT id FROM Transmissions__r),(SELECT id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__r WHERE WOD_2__Status__c = 'Registered' AND WOD_2__Registration_Type__c ='Extended') FROM WOD_2__Inventory__c WHERE Id IN : invIdSet]){
                if(!inv.Transmissions__r.isEmpty()){
                    vINList.add(inv.Transmissions__r[0]); 
                }
                if(!inv.WOD_2__Warranty_Registration__r.isEmpty()){
                    for(WOD_2__Warranty_Registration__c wrI: inv.WOD_2__Warranty_Registration__r){
                        system.debug('>> : wrI.WOD_2__Status__c'+wrI.WOD_2__Status__c);
                        WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c();
                        wr.id = wrI.id;
                        wr.WOD_2__Status__c = 'De-Registered';
                        wrList.add(wr);
                    }  
                }
            }
        }
        if(!wrList.isEmpty()){
            update wrList;
        }
        System.debug('>>> vINList :'+vINList);
        if(!vINList.isEmpty()){
            try{
                delete vINList;
            }catch(exception e){
                
            }
        }
        
    }
    
}