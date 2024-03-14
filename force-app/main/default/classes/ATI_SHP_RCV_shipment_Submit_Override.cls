/* Name: ATI_SHP_RCV_Shipment_Override
Description : ATI_SHP_RCV_Shipment_Override for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     16-Mar-2021        INITIAL DEVELOPMENT
*/
global class ATI_SHP_RCV_shipment_Submit_Override implements WOD_2.SHP_RCV_ShipmentOverride_Interface {
   public WOD_2.ResponseWrapper submitShipmentValidation(WOD_2__Shipment_Detail__c shipment, List<WOD_2__Claim_Shipment__c> claimShipmentList){
       //List<WOD_2__Claim_Shipment__c> claimShipmentListNew = []; TBD Prasad Sir , Why Query again here and FS fields needs to add each time
       System.debug('>>> :shipment'+shipment);
       System.debug('>>> :shipment'+shipment);
       WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper();
       response.status=true;
       response.errormessage = '';
       
       if(shipment.WOD_2__Receiver_Comments__c==null || String.isEmpty(shipment.WOD_2__Receiver_Comments__c.trim()) ){
           response.status=false;
       	   response.errormessage = Label.ATI_Receiver_Comments_of_shipment_details_mdtry;	
           return response;
       }
       if(shipment.WOD_2__Receiver_Comments_Internal__c==null || String.isEmpty(shipment.WOD_2__Receiver_Comments_Internal__c.trim()) ){
           response.status=false;
       	   response.errormessage = Label.ATI_InternalReceiverCommentsofshipmentmdtry;	
           return response;
       }
       for(WOD_2__Claim_Shipment__c cShip : claimShipmentList){
           System.debug('>>> :cShip'+cShip);
           if(cShip.WOD_2__Receiver_Comments__c == null || String.isEmpty(cShip.WOD_2__Receiver_Comments__c.trim()) ){
               System.debug('>>cShip'+cShip);
               System.debug('>>cShip.WOD_2__Quantity__c :'+cShip.WOD_2__Quantity__c);
               System.debug('>>cShip.WOD_2__Receiver_Comments__c :'+cShip.WOD_2__Receiver_Comments__c);
               response.status=false;
               response.errormessage = Label.ATI_Receiver_Comments_each_part_mdtry;
               return response;
           }
           if(cShip.WOD_2__Received_Quantity__c ==null || cShip.WOD_2__Received_Quantity__c <0  || cShip.WOD_2__Received_Quantity__c != cShip.WOD_2__Received_Quantity__c.intValue()){
               response.status=false;
               response.errormessage = Label.ATI_Receive_Quantity_can_not_be_null;
               return response;
           }
           System.debug('>> :cShip.WOD_2__Quantity__c '+cShip.WOD_2__Quantity__c);
           System.debug('>> :cShip.WOD_2__Received_Quantity__c '+cShip.WOD_2__Received_Quantity__c);
           if(cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Invoice_Quantity__c < cShip.WOD_2__Received_Quantity__c ){
               response.status=false;
               response.errormessage = Label.ATI_Received_Quantity_can_not_be_greater_than_quantity;
               return response;
           }
       }//	*/
        return response;
    }
	
 global WOD_2.ResponseWrapper submitShipment(WOD_2__Shipment_Detail__c shipment, List<WOD_2__Claim_Shipment__c> claimShipmentList){
        Savepoint sp = Database.setSavepoint();      
        try{
            List<id> claimIdList = new List<Id>();
            List<WOD_2__Claim_Shipment__c> claimShipmentListNew = [SELECT id, Name,WOD_2__Quantity__c,WOD_2__Receiver_Comments__c,WOD_2__Received_Quantity__c,WOD_2__Removed_Claim_Part__c, WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c
                                                                   FROM WOD_2__Claim_Shipment__c WHERE Id IN :claimShipmentList];
            for(WOD_2__Claim_Shipment__c cShip : claimShipmentListNew){
                if(cShip.WOD_2__Removed_Claim_Part__c!=null && cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c!=null){
                        claimIdList.add(cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c);
                    }
            }
            WOD_2.ResponseWrapper response = new WOD_2.ResponseWRapper();
            If(!claimIdList.isEmpty()){
                   ATI_WithoutSharingService.unLockRecords(claimIdList);
              }  
            response.status = true;
            response =submitShipmentValidation(shipment,claimShipmentList);
            if(!response.status){
                return response;
            }
            shipment.WOD_2__Status__c = 'Received';
            ATI_SHP_ShipmentDataService.upsertClaimShipmentRecords(claimShipmentList);
            ATI_SHP_ShipmentDataService.upsertShipmentRecords(new List<WOD_2__Shipment_Detail__c>{shipment});  
            If(!claimIdList.isEmpty()){
                   ATI_WithoutSharingService.lockRecords(claimIdList); // 
                } 
            return response;
        } catch(DMLException dmle){
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('',false, dmle.getDmlMessage(0));

        }catch(Exception excp){ 
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('',false, excp.getMessage()); 
        }
    }

//*/
}