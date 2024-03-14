/* Name: ATI_SHP_RCV_Shipment_Override
Description : ATI_SHP_RCV_Shipment_Override for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     11-Mar-2021        INITIAL DEVELOPMENT
*/
global class ATI_SHP_RCV_Shipment_Override implements WOD_2.SHP_SaveAndShipInterface{
    global WOD_2.ResponseWrapper saveAndShipOverrideValidation(WOD_2__Shipment_Detail__c shipment){
        System.debug('>>>>>ATI_SHP_RCV_Shipment_Override');
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper();
            response.data ='';
            response.status=true;
        if(shipment.WOD_2__Carriers__c ==null || String.isEmpty(shipment.WOD_2__Carriers__c)){
            response.errormessage=Label.ATI_Carrier_is_mandatory;
            response.status = false;
        }
        if(shipment.WOD_2__Depth__c== null ||shipment.WOD_2__Height__c ==null || shipment.WOD_2__Width__c==null || String.isEmpty(shipment.WOD_2__Unit_of_Measure_Dimension__c)){
            response.errormessage=Label.ATI_Depth_Height_and_Width_are_mandatory;
            response.status = false;
        }
        if(String.isEmpty(shipment.WOD_2__Unit_of_Measure_Weight__c) || shipment.WOD_2__Weight__c == null){
            response.errormessage=Label.ATI_Unit_of_Measure_Weight_are_mandatory;
            response.status = false; 
        }
        if(shipment.WOD_2__Carriers__r.Name != 'UPS' && (shipment.WOD_2__Tracking_Number__c==null 
                                                        || String.isEmpty(shipment.WOD_2__Tracking_Number__c.trim())))
        {
            response.errormessage=Label.ATI_Tracking_Number_is_mandatory;
            response.status = false;
        }
        if(shipment.WOD_2__Shipper_Comments__c==null || String.isEmpty(shipment.WOD_2__Shipper_Comments__c.trim())){
            response.errormessage=Label.ATI_Shipper_Comments_is_mandatory;
            response.status = false;
        } 
        if(shipment.WOD_2__Depth__c<=0 ||shipment.WOD_2__Height__c<=0 || shipment.WOD_2__Width__c<=0 || shipment.WOD_2__Weight__c<=0){
            response.errormessage=Label.ATI_Depth_Height_Width_should_be_greater_then_zero;
            response.status = false;
        }
        return response;
    }
    
    global WOD_2.ResponseWrapper saveAndShipOverride(String shipmentID){
        Savepoint sp;    
        try{
            List<id> claimIdList = new List<Id>();
            List<WOD_2__Shipment_Detail__c> shipmentObjectList = 
                ATI_SHP_ShipmentDataService.fetchShipmentRecord(new List<String>{shipmentID}, 
                                                                new List<String>{'WOD_2__Status__c','WOD_2__Business_Unit__c','WOD_2__Carriers__c',
                                                                    			 'WOD_2__Depth__c','WOD_2__Height__c','WOD_2__Width__c',
                                                                    			 'WOD_2__Weight__c','WOD_2__Unit_of_Measure_Dimension__c',
                                                                                 'WOD_2__Unit_of_Measure_Weight__c','WOD_2__Tracking_Number__c',
                                                                    			 'WOD_2__Shipper_Comments__c','WOD_2__Carriers__r.Name'});
            WOD_2.ResponseWrapper response = new WOD_2.ResponseWRapper();
            if(shipmentObjectList.size()>0){
                List<WOD_2__Claim_Shipment__c> claimShipmentList = [SELECT id,WOD_2__Removed_Claim_Part__c, WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c FROM WOD_2__Claim_Shipment__c WHERE WOD_2__Shipment_Detail__c =:shipmentID];
                for(WOD_2__Claim_Shipment__c cShip : claimShipmentList){
                    if(cShip.WOD_2__Removed_Claim_Part__c!=null && cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c!=null){
                        claimIdList.add(cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c);
                    }
                }
                response =saveAndShipOverrideValidation(shipmentObjectList[0]);
                if(!response.status){
                    return response;
                }
                response.status = true;
                
                if(shipmentObjectList[0].WOD_2__Carriers__r.Name=='UPS'){
                    //call UPS when UPS is selected, update shipment to shipped if shipment label is generated successfully
                    WOD_2.ResponseWrapper shipmentResponse = callUPSforShipment(shipmentObjectList[0].Id);
                    if(shipmentResponse.Status){
                        sp = Database.setSavepoint();
                        If(!claimIdList.isEmpty()){
                            ATI_WithoutSharingService.unLockRecords(claimIdList);
                        }  
                        shipmentObjectList[0].WOD_2__Status__c = 'Shipped';
                        ATI_SHP_ShipmentDataService.upsertShipmentRecords(shipmentObjectList);
                        If(!claimIdList.isEmpty()){
                            ATI_WithoutSharingService.lockRecords(claimIdList);  
                        } 
                    }else{
                        return shipmentResponse;
                    }
                }else{
                    if(!Test.isRunningTest()){sp = Database.setSavepoint();}
                    If(!claimIdList.isEmpty()){
                        ATI_WithoutSharingService.unLockRecords(claimIdList);
                    }  
                    shipmentObjectList[0].WOD_2__Status__c = 'Shipped';
                    ATI_SHP_ShipmentDataService.upsertShipmentRecords(shipmentObjectList);
                    If(!claimIdList.isEmpty()){
                        ATI_WithoutSharingService.lockRecords(claimIdList);  
                    } 
                }
            }
            return response;
        } catch(DMLException dmle){
            if(!Test.isRunningTest()){Database.rollback(sp);}
            return new WOD_2.ResponseWrapper('',false, dmle.getDmlMessage(0));
        }catch(Exception excp){ 
            if(!Test.isRunningTest()){Database.rollback(sp);}
            return new WOD_2.ResponseWrapper('',false, excp.getMessage()); 
        }
    }

    public static WOD_2.ResponseWrapper callUPSforShipment(string shipId){
        WOD_2.SHP_ShipmentHandler shpHandlerObj = new WOD_2.SHP_ShipmentHandler();
        WOD_2.ResponseWrapper upsResponse = shpHandlerObj.shipAndGenerateLabelForUPS(shipId);
        system.debug('upsResponse--------->'+upsResponse);
        return upsResponse;
    }
}