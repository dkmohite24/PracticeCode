/* Name: ATI_WntyRegistrationTriggerHandler
Description : ATI_WntyRegistrationTriggerHandler - TriggerHandler for WOD_2__Warranty_Registration__c.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      24-JAN-2021          INITIAL DEVELOPMENT
*/
public class ATI_WntyRegistrationTriggerHandler extends TriggerHandler{
    public static Boolean duplicatewr = true;
    //Alsn-159 added isFuture variable
    public static Boolean isFuture = false;
    @TestVisible
    private List<WOD_2__Warranty_Registration__c> newWarrantyRegList;
    @TestVisible
    private Map<Id, WOD_2__Warranty_Registration__c> oldWarrantyRegMap;
    @TestVisible
    private Map<Id, WOD_2__Warranty_Registration__c> newWarrantyRegMap;
    public ATI_WntyRegistrationTriggerHandler() {
        this.newWarrantyRegList = (List<WOD_2__Warranty_Registration__c>)Trigger.new;
        this.oldWarrantyRegMap = (Map<Id, WOD_2__Warranty_Registration__c>)Trigger.oldMap;
        this.newWarrantyRegMap = (Map<Id, WOD_2__Warranty_Registration__c>)Trigger.newMap;
    }
    
    public override void afterUpdate() {
        //Added by dishari on 22th oct
        warrantyRuleException();
        List<Id> wrIdList = new List<Id>();
        List<Id> wrIdToDeleteList = new List<Id>();
        Set<Id> invIdsToUpdateSet = new Set<Id>();
        for(WOD_2__Warranty_Registration__c wr : [SELECT Id,WOD_2__Account__c,WOD_2__Inventory__c,ATI_isExtended__c,WOD_2__Status__c,WOD_2__Account__r.ATI_RPS_Status__c FROM WOD_2__Warranty_Registration__c WHERE Id IN:Trigger.new]){
            if((oldWarrantyRegMap.get(wr.id).WOD_2__Status__c == 'In Progress' || oldWarrantyRegMap.get(wr.id).WOD_2__Status__c == 'Pending Warranty Processor Approval') && wr.WOD_2__Account__r.ATI_RPS_Status__c && wr.WOD_2__Status__c == 'Registered'){
                wrIdList.add(wr.Id);
            } else if(oldWarrantyRegMap.get(wr.id).WOD_2__Status__c == 'Registered' && wr.WOD_2__Status__c != 'Registered'){
                wrIdToDeleteList.add(wr.Id);                       
            }else if(oldWarrantyRegMap.get(wr.id).ATI_isExtended__c && !wr.ATI_isExtended__c){
                wrIdToDeleteList.add(wr.Id);
            }
            if(oldWarrantyRegMap.get(wr.id).WOD_2__Status__c != 'Registered' && wr.WOD_2__Status__c == 'Registered'){
                invIdsToUpdateSet.add(wr.WOD_2__Inventory__c);
            }
        }
        if(!wrIdToDeleteList.isEmpty() || !wrIdList.isEmpty()){
            ATI_ExtWntyAccrualsQueueable queue = new ATI_ExtWntyAccrualsQueueable();
            if(!wrIdToDeleteList.isEmpty()){
                queue.wrIdToDeleteList = wrIdToDeleteList;
            }
            if(!wrIdList.isEmpty()){
                Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                    select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c in :wrIdList 
                    and ATI_is_Extended_Enabled__c = true
                ]);
                if(!coverages.isEmpty()){
                    queue.extWarrantyCoverageIdList = new List<Id>(coverages.keySet());
                }
            }
            if(!Test.isRunningTest()){
                if(!System.isBatch()) {
                    System.enqueueJob(queue); 
                }else{
                    queue.execute(null);
                }
            }
        }
        if(!invIdsToUpdateSet.isEmpty()){
            Map<Id,WOD_2__Inventory__c> invUpdateMap = new Map<Id,WOD_2__Inventory__c>();
            for(WOD_2__Inventory__c inv : [SELECT Id,(SELECT Id,ATI_Inventory__c,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c FROM Transmissions__r ORDER By CreatedDate DESC) FROM WOD_2__Inventory__c WHERE Id IN:invIdsToUpdateSet]){
                if(!inv.Transmissions__r.isEmpty()){
                    ATI_VIN_Transmission_Mapper__c vehicleTransMapper = inv.Transmissions__r.get(0);
                    WOD_2__Inventory__c inventory = new WOD_2__Inventory__c(Id=vehicleTransMapper.ATI_Inventory__c,WOD_2__Units_Usage__c=vehicleTransMapper.ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c);
                    invUpdateMap.put(inventory.id,inventory);
                }
            }
            if(!invUpdateMap.isEmpty()){
                //Alsn-213 bypassed ATI_WntyRegistrationTriggerHandler to avoid the updates that were not necessary as a part of code optimisation
                TriggerHandler.bypass('ATI_InventoryTriggerHandler');
                TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
                update invUpdateMap.values();
                TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
                TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');

            }
        }
    }
    /*
Method Name :   beforeUpdate
Params      :   Warranty Registration Before Update method
*/
    public override void beforeUpdate() {  
        Boolean isRegistered;
        Set<Id> wrIds = new Set<Id>();
        for(Id wrId : this.newWarrantyRegMap.keySet()){
            WOD_2__Warranty_Registration__c newWR = newWarrantyRegMap.get(wrId);
            WOD_2__Warranty_Registration__c oldWR = oldWarrantyRegMap.get(wrId);
            if(oldWR.WOD_2__Status__c != 'Registered' && newWR.WOD_2__Status__c == 'Registered'){
                newWR.ATI_Close_Date__c = System.today();
            }
            //Alsn-160
            if(duplicatewr == true){
                wrIds.add(oldWR.id);
            }
            
        }
        //Alsn -177 code optimised
        if(duplicatewr == true){
            List<WOD_2__Warranty_Registration__c> wrList = [Select Id, WOD_2__Inventory__r.WOD_2__Type__c, ATI_isExtended__c from WOD_2__Warranty_Registration__c where Id IN :wrIds];
            for(WOD_2__Warranty_Registration__c wr : wrList){
                for(Id wrId : this.newWarrantyRegMap.keySet()){
                    WOD_2__Warranty_Registration__c newWR = newWarrantyRegMap.get(wrId);
                    WOD_2__Warranty_Registration__c oldWR = oldWarrantyRegMap.get(wrId);
                    if(wr.Id == oldWR.Id && oldWR.WOD_2__Status__c == 'Registered' && newWR.WOD_2__Status__c == 'In Progress' && wr.ATI_isExtended__c == false && wr.WOD_2__Inventory__r.WOD_2__Type__c == 'Retail'){
                        newWR.addError(Label.ATI_Duplicate_WR);
                    }else if(wr.Id == oldWR.Id && (oldWR.WOD_2__Status__c == 'In Progress' || oldWR.WOD_2__Status__c == 'Registered') && newWR.WOD_2__Status__c == 'In Progress' && wr.ATI_isExtended__c == true && wr.WOD_2__Inventory__r.WOD_2__Type__c == 'Retail'){
                        newWR.addError(Label.ATI_Duplicate_WR);                        
                    }
                }
            }
        }
        //end of Alsn-160
    }
    
    /*
Method Name :   afterInsert
Params      :   Warranty Registration after Insert method
*/
    public override void afterInsert() {
        warrantyRegisAutoNumber();  
        //Added by dishari on 22th oct
        warrantyRuleException();		
        updateContractNumber(newWarrantyRegMap.keySet());
        shareWarrantyRecordsToPublicGroup();
    }
    
    private static void updateContractNumber(Set<Id> newWarrantyRegIdSet){
        ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c', 'UPDATE', new List<String>{'Name','ATI_Contract_Number__c'});
        List<WOD_2__Warranty_Registration__c> wrList = [select Id, Name, ATI_Contract_Number__c from WOD_2__Warranty_Registration__c where Id in :newWarrantyRegIdSet];
        if(!wrList.isEmpty()){
            for(WOD_2__Warranty_Registration__c wr : wrList){
                wr.ATI_Contract_Number__c = wr.Name;
            }
            //Alsn-123 bypassed ATI_InventoryTriggerHandler to avoid the updates that were not necessary as a part of code optimisation
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update wrList;
            TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        }
    }
    /*
Method Name :   warrantyRegisAutoNumber
Params      :   Set Warranty Registration Auto Number
Added by Dishari 3/17/2021 
*/
    public void warrantyRegisAutoNumber(){
        List<WOD_2__Warranty_Registration__c> lstOfWarrantyReg = New List<WOD_2__Warranty_Registration__c>();
        for(WOD_2__Warranty_Registration__c nWarrantyReg : newWarrantyRegList){
            if(nWarrantyReg.ATI_Extende_Warranty_Registration_Number__c != NULL){
                WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c();
                wr.id = nWarrantyReg.id;
                if(nWarrantyReg.WOD_2__Registration_Type__c == 'Extended'){
                    wr.Name = nWarrantyReg.ATI_Extende_Warranty_Registration_Number__c;
                }
                else{           
                    wr.Name = nWarrantyReg.ATI_Warranty_Registration_Number__c;
                }
                lstOfWarrantyReg.add(wr);
            }
        }
        if(!lstOfWarrantyReg.isEmpty()){
            //Alsn-213 bypassed ATI_InventoryTriggerHandler to avoid the updates that were not necessary as a part of code optimisation
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update lstOfWarrantyReg;
            TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
        }
    }
    
    //share wr records to parents
    public static void shareWarrantyRecordsToPublicGroup(){
        set<String> accGroupIds = new set<String>();
        set<Id> wrIds = new set<Id>();
        for(WOD_2__Warranty_Registration__c wrObj : (List<WOD_2__Warranty_Registration__c>)Trigger.New){
            accGroupIds.add('ATI_Dealer_'+ wrObj.WOD_2__Account__c);
            wrIds.add(wrObj.Id);
        }
        if(!wrIds.isEmpty() && !accGroupIds.isEmpty() && !system.isBatch() && isFuture == false){
            ATI_QueueableUtil.enqueueJob(new ATI_ShareWRToPublicGroupQueueable(accGroupIds,wrIds));
        }
        else if(!wrIds.isEmpty() && !accGroupIds.isEmpty() && system.isBatch() && isFuture == false){
            new ATI_ShareWRToPublicGroupQueueable(accGroupIds,wrIds).execute(null); 
        }
        //Alsn-159 added condition to check if the update happening from future method
        else if(!wrIds.isEmpty() && !accGroupIds.isEmpty() && !system.isBatch() && isFuture == true){
            new ATI_ShareWRToPublicGroupQueueable(accGroupIds,wrIds).execute(null); 
        }
        //end of Alsn-159
    }
        
    /*
Method Name :   warrantyRuleException
Params      :   Set Warranty Registration Rule Exception and Auto approvalChechk
Added by Dishari 10/21/2021 
*/
    public void warrantyRuleException(){
        List<WOD_2__Warranty_Registration__c> lstOfWarrantyReg = New List<WOD_2__Warranty_Registration__c>();
        
        WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject = new WOD_2.BR_BusinessRuleEngineWrapper();
        //ALSN-148 providing the BU id through label
        //WOD_2__Inventory__c inv = [select WOD_2__Business_Unit__c from WOD_2__Inventory__c where id = :newWarrantyRegList[0].WOD_2__Inventory__c];
        String buId = Label.ATI_BU_ID;
        List<WOD_2__Business_Rule__c> burRulesTriggeredLst = 
            ATI_BURulesService.runBURules(buId,'ATI_Warranty_Registration__c',new List<Id>{newWarrantyRegList[0].Id},
                                          'Warranty Registration','Registration Logic');
        // system.debug('burRulesTriggeredLst'+burRulesTriggeredLst[0].WOD_2__Message__c);
        ATI_Utils.checkForAccess('WOD_2__Business_Rule__c', 'DELETE', null);
        List<WOD_2__Business_Rule__c> oldBURules = [select id from WOD_2__Business_Rule__c where ATI_Warranty_Registration__c in :newWarrantyRegMap.keySet()];
        if(!oldBURules.isEmpty()){
            delete oldBURules;
        }
        if(burRulesTriggeredLst != null && !burRulesTriggeredLst.isEmpty()){
            List<String> buRuleFieldList = new List<String>{'WOD_2__Action__c','WOD_2__Business_Category_Configuration_Setting__c','WOD_2__Error_Type__c','ATI_Inventory__c','WOD_2__Message__c','WOD_2__Visible_to_Dealer__c','ATI_Warranty_Registration__c'};
                ATI_Utils.checkForAccess('WOD_2__Business_Rule__c', 'CREATE', buRuleFieldList);
            insert burRulesTriggeredLst;
        }
        Set<Id> setOfAccId = new Set<Id>();
        For(WOD_2__Warranty_Registration__c nWarrantyReg : newWarrantyRegList){
            setOfAccId.add(nWarrantyReg.WOD_2__Account__c);   
        }
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id,ATI_Customer_Group__c FROM Account WHERE ID =:setOfAccId]);
        
        For(WOD_2__Warranty_Registration__c nWarrantyReg : newWarrantyRegList){
            //no manual review rules are fired:
            WOD_2__Warranty_Registration__c wr = new WOD_2__Warranty_Registration__c();
            wr.id = nWarrantyReg.id;
            //-	WR created by Account customer group = 'Distributor (Main)' and no manual review rules are fired, then auto approve (auto pay)
            if(!mapAccount.isEmpty() && nWarrantyReg.ATI_Extended_Warranty_Purchase_Date__c != NULL && mapAccount.get(nWarrantyReg.WOD_2__Account__c).ATI_Customer_Group__c == '02' && burRulesTriggeredLst.size()==0){
                wr.ATI_Auto_Approval__c = True;  
                wr.ATI_NOException__c = True;
                system.debug('ATI_NOException__c'+wr.ATI_NOException__c);
            }
            //WR created by Account customer group = 'Distributor (Main)' and any manual review rules are fired
            if(!mapAccount.isEmpty() && nWarrantyReg.ATI_Extended_Warranty_Purchase_Date__c != NULL && mapAccount.get(nWarrantyReg.WOD_2__Account__c).ATI_Customer_Group__c == '02' && burRulesTriggeredLst.size()>0){
                wr.ATI_Auto_Approval__c = False;  
                wr.ATI_NOException__c = False;
                system.debug('ATI_NOException__c'+wr.ATI_NOException__c);
            }
            //-	Any other account customer group and no manual review rules are fired
            if(!mapAccount.isEmpty() && nWarrantyReg.ATI_Extended_Warranty_Purchase_Date__c != NULL && mapAccount.get(nWarrantyReg.WOD_2__Account__c).ATI_Customer_Group__c != '02' && burRulesTriggeredLst.size()==0){
                wr.ATI_Auto_Approval__c = False;  
                wr.ATI_NOException__c = True;
                system.debug('ATI_NOException__c'+wr.ATI_NOException__c);
            }
            //-	-	Any other account customer group and any of the manual review rules are fired message is generated
            if(!mapAccount.isEmpty() && nWarrantyReg.ATI_Extended_Warranty_Purchase_Date__c != NULL && mapAccount.get(nWarrantyReg.WOD_2__Account__c).ATI_Customer_Group__c != '02' && burRulesTriggeredLst.size()>0){
                wr.ATI_Auto_Approval__c = False;  
                wr.ATI_NOException__c = False;
                system.debug('ATI_NOException__c'+wr.ATI_NOException__c);
            }
            lstOfWarrantyReg.add(wr);
        }
        if(!lstOfWarrantyReg.isEmpty()){
            //Alsn-213 bypassed ATI_InventoryTriggerHandler to avoid the updates that were not necessary as a part of code optimisation
            TriggerHandler.bypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.bypass('ATI_InventoryTriggerHandler');
            update lstOfWarrantyReg;
            TriggerHandler.clearBypass('ATI_WntyRegistrationTriggerHandler');
            TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
        } 
    }
}