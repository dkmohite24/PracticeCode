/*
	Class Name	:	ATI_SHP_InspectShipmentOverride
	Created On	:	19th march 2021
	Description	:	Override class for shipment inspection screen
*/
global class ATI_SHP_InspectShipmentOverride implements WOD_2.SHP_InspectShipmentOverride_Interface {
    /*
		Method Name	:	performShipmentInspectionInitialValidation
		Description	:	Method to validate on initialization
	*/
    global static WOD_2.ResponseWrapper performShipmentInspectionInitialValidation(String param0)
    {
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWRapper();
        response.status = true;
        return response;
    }
    
    /*
		Method Name	:	performShipmentInspectionInitialValidation
		Description	:	Method to called on click of submit from inspection screen, added validations, calling ATI_SHP_ShipmentDataService to update data
	*/
    global static WOD_2.ResponseWrapper performShipmentInspectionSubmission(WOD_2__Shipment_Detail__c shipmentObject, List<WOD_2__Claim_Shipment__c> claimShipmentList){
        Savepoint sp = Database.setSavepoint();
        List<id> claimIdList = new List<Id>();
        try{
            
            WOD_2.ResponseWrapper response = new WOD_2.ResponseWRapper();
            response.status = true;
            if(shipmentObject.WOD_2__Inspection_Comments_Internal__c == NULL || shipmentObject.WOD_2__Inspection_Comments_Internal__c.trim() == ''){
                response.status = false;
                response.errorMessage=System.Label.ATI_Internal_Inspection_Comments_for_shipment_is_mandatory;
                return response;
            }else if(shipmentObject.WOD_2__Inspection_Comments__c == NULL || shipmentObject.WOD_2__Inspection_Comments__c.trim() == ''){
                response.status = false;
                response.errorMessage=System.Label.ATI_Inspection_Comments_for_shipment_is_mandatory;
                return response;
            }else{
                for(WOD_2__Claim_Shipment__c claimShipObj : claimShipmentList){
                    if(claimShipObj.WOD_2__Inspection_Comments__c == NULL || claimShipObj.WOD_2__Inspection_Comments__c.trim() == '')
                    {
                        response.status = false;
                        response.errorMessage=System.Label.ATI_Inspection_Comments_for_Parts_is_mandatory;
                        return response;
                    }
                    else if(claimShipObj.WOD_2__Inspection_Comments_Internal__c == NULL || claimShipObj.WOD_2__Inspection_Comments_Internal__c.trim() == ''){
                        response.status = false;
                        response.errorMessage=System.Label.ATI_Internal_Inspection_Comments_for_Parts_is_mandatory;
                        return response; 
                    }
                    else if(claimShipObj.WOD_2__Inspected_Quantity__c == NULL || claimShipObj.WOD_2__Inspected_Quantity__c <0 
                            || claimShipObj.WOD_2__Inspected_Quantity__c > claimShipObj.WOD_2__Removed_Claim_Part__r.WOD_2__Invoice_Quantity__c
                            || claimShipObj.WOD_2__Inspected_Quantity__c != claimShipObj.WOD_2__Inspected_Quantity__c.intValue()){
                        response.status = false;
                        response.errorMessage=System.Label.ATI_Inspected_Quantity_for_Parts_should_be_valid_and_cannot_be_greater_than_actu;
                        return response;
                    }
                    else if(claimShipObj.WOD_2__Inspection_Status__c == NULL || claimShipObj.WOD_2__Inspection_Status__c.trim() == ''){
                      	response.status = false;
                        response.errorMessage=System.Label.ATI_Inspection_Status_for_Parts_is_mandatory;
                        return response;
                    }
                }
            }
            for(WOD_2__Claim_Shipment__c cShip : [SELECT id,WOD_2__Removed_Claim_Part__c,WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c FROM WOD_2__Claim_Shipment__c WHERE id IN : claimShipmentList]){
                    if(cShip.WOD_2__Removed_Claim_Part__c!=null && cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c!=null){
                        claimIdList.add(cShip.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c);
                    }
                }
            System.debug('>> claimIdList:'+claimIdList);
             If(!claimIdList.isEmpty()){
                   ATI_WithoutSharingService.unLockRecords(claimIdList);
                }  
            shipmentObject.WOD_2__Status__c = 'Inspected';
            shipmentObject.WOD_2__Inspection_Date__c = System.today();
            shipmentObject.WOD_2__Inspected_By__c = UserInfo.getUserId();
            ATI_SHP_ShipmentDataService.upsertClaimShipmentRecords(claimShipmentList);
            ATI_SHP_ShipmentDataService.upsertShipmentRecords(new List<WOD_2__Shipment_Detail__c>{shipmentObject});
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
}