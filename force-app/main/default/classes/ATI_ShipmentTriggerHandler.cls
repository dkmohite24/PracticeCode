/* Name: ATI_ShipmentTriggerHandler
Description : 
Author : Tavant(MB)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(MB)        15/03/2021       INITIAL DEVELOPMENT                              
*/
public with sharing class ATI_ShipmentTriggerHandler extends TriggerHandler{
    public static Boolean isExecuted= false;
    private List<WOD_2__Shipment_Detail__c> newShipmentList;
    private List<WOD_2__Shipment_Detail__c> oldShipmentList;
    Private Map<Id, WOD_2__Shipment_Detail__c> newShipmentMap;
    Private Map<Id, WOD_2__Shipment_Detail__c> oldShipmentMap;
    /*
Method Name :   ATI_ShipmentTriggerHandler
Params      :   Constructor
*/
    public ATI_ShipmentTriggerHandler(){
        this.newShipmentList = (List<WOD_2__Shipment_Detail__c>)Trigger.new;
        this.oldShipmentList= (List<WOD_2__Shipment_Detail__c>)Trigger.old;
        this.newShipmentMap= (Map<Id, WOD_2__Shipment_Detail__c>)Trigger.newMap;
        this.oldShipmentMap= (Map<Id, WOD_2__Shipment_Detail__c>)Trigger.oldMap;
    }
    
    public override void afterInsert(){
        createShipmentSharing(newShipmentMap);
        shipmentAutoNumber();
        
    }
    /*
Method Name :   beforeUpdate
Params      :   Warranty Registration Before Update method
*/
    public override void beforeUpdate() {    
        system.debug('newShipmentList>>>'+newShipmentList);
        //Alsn-143
      //   updateShipmentStatus(newShipmentList);
        // shipmentAutoNumber();
    }
    public override void afterUpdate() {
        updateShipmentStatus(newShipmentList);
    }
    
    //public ATI_ShipmentTriggerHandler(){
    //   this.newShipmentList = (List<WOD_2__Shipment_Detail__c>)Trigger.new;
    //}
    
    public static void createShipmentSharing(Map<id,WOD_2__Shipment_Detail__c> newMap){
        System.debug('>>createShipmentSharing :');
        List<WOD_2__Shipment_Detail__Share> sharingListToBeInserted = new List<WOD_2__Shipment_Detail__Share>(); 
        List<WOD_2__Shipment_Detail__Share> sharingListToBeDeleted  = new List<WOD_2__Shipment_Detail__Share>();
        List<WOD_2__Shipment_Detail__c> shipmentList = [SELECT Id, Name,WOD_2__Dealer_Account__r.Public_Group_Id__c FROM WOD_2__Shipment_Detail__c WHERE ID IN :newMap.keyset()]; 
        for(WOD_2__Shipment_Detail__c shipment : shipmentList){
            if(shipment.WOD_2__Dealer_Account__c != NULL && !String.isEmpty(shipment.WOD_2__Dealer_Account__r.Public_Group_Id__c))
                sharingListToBeInserted.add(new WOD_2__Shipment_Detail__Share(AccessLevel = 'Edit', ParentId = shipment.Id, UserOrGroupId = shipment.WOD_2__Dealer_Account__r.Public_Group_Id__c));//Dealer Access //, RowCause = Schema.WOD_2__Shipment_Detail__Share.RowCause 
        }
        System.debug('>> sharingListToBeInserted :'+sharingListToBeInserted);
        if(!sharingListToBeInserted.isEmpty()){
            
            insert sharingListToBeInserted;
        }      
    }
    
    /*
Method Name :   shipmentAutoNumber
Params      :   Set Shipment AutoNumber
//added by Dishari
*/
    public void shipmentAutoNumber() {
        system.debug('>>>>>>>');
        List<WOD_2__Shipment_Detail__c> lstOfShipment = New List<WOD_2__Shipment_Detail__c>();
        for(WOD_2__Shipment_Detail__c nShipment :newShipmentList){
            // Added by Dishari 3/17/2021 Start
            if(nShipment.ATI_Shipment_Number__c != NULL){
                WOD_2__Shipment_Detail__c shipment = new WOD_2__Shipment_Detail__c();
                shipment.id = nShipment.id;
                shipment.Name = nShipment.ATI_Shipment_Number__c;   
                //ALSN-144
                shipment.UpdateCheck__c = true;  
                //
                lstOfShipment.add(shipment);                
                system.debug('lstOfShipment>>>'+lstOfShipment);
            }  
        }
        if(!lstOfShipment.isEmpty()){
            TriggerHandler.bypass('ATI_ShipmentTriggerHandler');
            update lstOfShipment;                  
            TriggerHandler.clearBypass('ATI_ShipmentTriggerHandler');
        }
        /*
shipmentUpdateCheck -ALSN-144
*/
        //ALSN-144
        List<WOD_2__Shipment_Detail__c> shpUpdateChk = [Select Id,UpdateCheck__c from WOD_2__Shipment_Detail__c where Id in:lstOfShipment];
        for(WOD_2__Shipment_Detail__c updatechk:shpUpdateChk){
            if(updatechk.UpdateCheck__c == true){
                updatechk.UpdateCheck__c = false;                   
            }
        }
        if(!shpUpdateChk.isEmpty()){
            TriggerHandler.bypass('ATI_ShipmentTriggerHandler');
            update shpUpdateChk;                  
            TriggerHandler.clearBypass('ATI_ShipmentTriggerHandler');
        }
        //end of ALSN-144   
    } 
    //Alsn -143
    public void updateShipmentStatus(List<WOD_2__Shipment_Detail__c> shpmntLst){       
        Integer inspectedParts=0;
        if(shpmntLst[0].WOD_2__Status__c == 'Inspected'){
            List<WOD_2__Shipment_Detail__c> shpLst = [Select Id,WOD_2__Status__c from WOD_2__Shipment_Detail__c where Id in:shpmntLst];
            List<WOD_2__Claim_Shipment__c> updateClmShp = new List<WOD_2__Claim_Shipment__c>();
            for(WOD_2__Claim_Shipment__c clmShp : [Select Id,WOD_2__Inspected_Quantity__c,WOD_2__Removed_Claim_Part__r.WOD_2__Inspection_Status__c,WOD_2__Removed_Claim_Part__r.WOD_2__Is_Inspected__c,WOD_2__Inspection_Status__c,WOD_2__Quantity__c,WOD_2__Shipment_Detail__c from WOD_2__Claim_Shipment__c where WOD_2__Shipment_Detail__c=:shpLst[0].Id]){
                if((clmShp.WOD_2__Inspected_Quantity__c != clmShp.WOD_2__Quantity__c && clmShp.WOD_2__Inspected_Quantity__c>=0) || (clmShp.WOD_2__Inspection_Status__c=='Rejected' && clmShp.WOD_2__Inspected_Quantity__c>=0)){
                    clmShp.WOD_2__Inspection_Status__c = 'Inspection Error';
                    clmShp.WOD_2__Is_Inspected__c =true;                   
                    inspectedParts++;
                }
                if(clmShp.WOD_2__Inspected_Quantity__c == clmShp.WOD_2__Quantity__c && clmShp.WOD_2__Inspection_Status__c=='Approved'){
                    clmShp.WOD_2__Is_Inspected__c =true;              
                }
                updateClmShp.add(clmShp);
            }
            if(!updateClmShp.isEmpty()){
                //Alsn-213 bypassed shipmenttriggerhandler to avoid the updates that were not necessary as a part of code optimisation
               TriggerHandler.bypass('ATI_ShipmentTriggerHandler');           
                update updateClmShp;
               TriggerHandler.clearBypass('ATI_ShipmentTriggerHandler');      
            }
            if(inspectedParts > 0){
                shpLst[0].WOD_2__Status__c ='Inspection Error';
            }
            TriggerHandler.bypass('ATI_ShipmentTriggerHandler');
            update shpLst;
            TriggerHandler.clearBypass('ATI_ShipmentTriggerHandler');
        }     
    }
    // end of Alsn-143    
}