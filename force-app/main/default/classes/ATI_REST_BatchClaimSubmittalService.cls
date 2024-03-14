/* Name: ATI_REST_BatchClaimSubmittalService
Description : Service Class for BatchClaimSubmittal interface
Author : Tavant (TY)
History :
VERSION      AUTHOR          DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant (TY)    09/04/2021          INITIAL DEVELOPMENT
*/
public with sharing class ATI_REST_BatchClaimSubmittalService{
    static List<WOD_2.CLM_ClaimCreateInputWrapper> machineClaimsInputWrapperList{get; set;}
    static List<WOD_2.CLM_ClaimCreateInputWrapper> partClaimsInputWrapperList{get; set;}
    static List<WOD_2.CLM_ClaimCreateOutputWrapper> machineClaimsoutputWrapperList{get; set;}
    static List<WOD_2.CLM_ClaimCreateOutputWrapper> partClaimsoutputWrapperList{get; set;}
    static List<twodcms.CampaignClaimWrapper> campaignMemberWrapperLst{get; set;}
    static Map<String,WOD_2__Claim__c> mapOfInsertedOrUpdatedClaims{get; set;}
    static Id newCustomerId{get; set;}
    static Map<Id,Account> mapOfIdWithCustomerAcc{get; set;}
    static List<Account> accInsertOrUpdateList{get; set;}
    static Set<Id> setOfWRInsertedIds{get; set;}
    static List<ATI_Vehicle_Information__c> vehInfoList{get; set;}
    static List<WOD_2__Warranty_Registration__c> wrInsertOrUpdateList{get; set;}
    static List<WOD_2__Warranty_Coverages__c> warrCoveragelist{get; set;}
    static List<Id> setOfValidateClaimIds{get; set;}
    static List<WOD_2__Claim__c> claimValidateList{get; set;}
    static List<WOD_2__Claim__c> claimSubmitList{get; set;}
    static Map<Id,WOD_2__Inventory__c> mapOfInvForUpdate{get; set;}
    static Map<string,string> invCustMap{get; set;}
    static Map<String,List<String>> mapOfFailure{get; set;}
    static ATI_REST_BatchClaimSubmittalResults batchClaimSubResults{get; set;}
    static String strBatchLogId{get; set;}
    static Set<Id> setOfRemovedPartIds{get; set;}
    static List<ATI_VIN_Transmission_Mapper__c> updateVehicleTransMapperLst{get; set;}
    static List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> claimInfoLst{get; set;}
    static Map<string,string> claimIdKeyMap{get; set;}
    static Map<string,string> campaignclaimIdKeyMap{get; set;}
    static String invId{get; set;}  
    static Map<Id,WOD_2__Inventory__c> mapOfInvToUpdateType{get; set;}
    //ALSN-146
    static string rateType;
    public static WOD_2.ResponseWrapper processClaim(List<ATI_REST_BatchClaimSubmittalRequest.ClaimInformation> claimInfoLstTemp,String strBatchLogIdTemp,
                                                     ATI_REST_BatchClaimSubmittalResults batchClaimSubResultsTemp){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper(null,false,null);
        try{
            strBatchLogId = strBatchLogIdTemp;
            String buId = '';
            mapOfFailure = new Map<String,List<String>>();
            ATI_ClaimTriggerHandler.RUN_BU_RULES = false;
            ATI_ClaimTriggerHandler.skipClaimHandlerOnClaimSaveForITR = true;
            ATI_InventoryTriggerHandler.skipInvTriggerHandlerForITR = true;
            //ALSN-23 Commented line to allow creation of sharing for Claims.
            //ATI_ClaimTriggerHandler.skipTriggerRunForBatchClaims = true;
            ATI_FinancialTriggerHandler.skipFinancialTriggerHandler = true;
            ATI_RemovedClaimPartTriggerHandler.skipRemovedPartTriggerForITR = true;
            ATI_RemovedClaimPartTriggerHandler.skipPRCForITR = true;
            ATI_FinancialLineItemTriggerHandler.skipFLITriggerHandlerForITR = true;
            machineClaimsInputWrapperList = new List<WOD_2.CLM_ClaimCreateInputWrapper>();
            partClaimsInputWrapperList = new List<WOD_2.CLM_ClaimCreateInputWrapper>();
            machineClaimsOutputWrapperList = new List<WOD_2.CLM_ClaimCreateOutputWrapper>();
            partClaimsOutputWrapperList = new List<WOD_2.CLM_ClaimCreateOutputWrapper>();
            campaignMemberWrapperLst = new List<twodcms.CampaignClaimWrapper>();
            mapOfInsertedOrUpdatedClaims = new Map<String,WOD_2__Claim__c>();
            setOfValidateClaimIds = new List<Id>();
            claimValidateList = new List<WOD_2__Claim__c>();
            claimSubmitList = new List<WOD_2__Claim__c>();
            mapOfIdWithCustomerAcc = new Map<Id,Account>();
            accInsertOrUpdateList = new List<Account>();
            setOfWRInsertedIds = new Set<Id>();
            vehInfoList = new List<ATI_Vehicle_Information__c>();
            wrInsertOrUpdateList = new List<WOD_2__Warranty_Registration__c>();
            warrCoveragelist = new List<WOD_2__Warranty_Coverages__c>();
            invCustMap = new Map<string,string>();
            mapOfInvForUpdate = new Map<Id,WOD_2__Inventory__c>();
            batchClaimSubResults = batchClaimSubResultsTemp;
            claimInfoLst = claimInfoLstTemp;
            setOfRemovedPartIds = new Set<Id>();
            updateVehicleTransMapperLst = new List<ATI_VIN_Transmission_Mapper__c>();
            claimIdKeyMap = new Map<string,string>();
            campaignclaimIdKeyMap = new Map<string,string>();
            mapOfInvToUpdateType = new Map<Id,WOD_2__Inventory__c>();
            invId = '';
            for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : claimInfoLst){
                WOD_2__Claim__c claim = new WOD_2__Claim__c();
                if(claimInfo.submittalIndicator == 'A'){
                    ATI_ClaimTriggerHandler.skipBeforeInsertForITR = true;
                    claim = batchClaimSubResults.claimMap.get(claimInfo.claimNumber.trim());
                    claim.WOD_2__Claim_Status__c = 'Reopened';
                    claim.ATI_Submittal_Indicator__c = claimInfo.submittalIndicator;
                    if(claim.WOD_2__Work_Performed_Comments__c == null){
                        claim.WOD_2__Work_Performed_Comments__c = '';
                    }
                    claim.WOD_2__Work_Performed_Comments__c += ' '+claimInfo.workPerformedComments;
                    if(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containskey(claimInfo.identifier.trim())){
                        claim.ATI_BatchClaim_Error_Messages__c = JSON.serialize(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.get(claimInfo.identifier.trim()));
                    }
                    mapOfInsertedOrUpdatedClaims.put(claimInfo.identifier.trim(),claim);
                }else{
                    claim.WOD_2__Work_Performed_Comments__c = claimInfo.workPerformedComments !=NULL ? claimInfo.workPerformedComments:'';
                    if(claimInfo.submittalIndicator == 'M'){
                        ATI_ClaimTriggerHandler.skipBeforeInsertForITR = true;
                        claim = batchClaimSubResults.claimMap.get(claimInfo.claimNumber);
                    }else{
                        ATI_ClaimTriggerHandler.skipBeforeUpdateForITR = true;
                        claim.CurrencyIsoCode = 'USD';
                        if(!String.isBlank(claimInfo.repairOutlet) && batchClaimSubResults.accMap.containskey(claimInfo.repairOutlet.trim())){
                            claim.WOD_2__Account__c = batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).Id;
                            if(!String.isBlank(batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).ATI_Currency__c)){
                                claim.CurrencyIsoCode = batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).ATI_Currency__c;
                            }
                            if(!String.isBlank(batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).ATI_Primary_Email_Id__c)){
                                claim.ATI_Account_Email__c = batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).ATI_Primary_Email_Id__c;
                            }
                        }
                        claim.WOD_2__Work_Order__c = claimInfo.repairOrder;
                    }
                    claim.ATI_Exchange_Rate__c = 1;
                    //Anjali added for 211
                    claim.ATI_Technician_Name__c = claimInfo.TechnicianName;
                    //Added by ALSN-42                   
                    if(!String.isBlank(claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber)){
                        claim.ATI_VIN__c = claimInfo.registrationInfo.vehicleInfo.vehicleIdentificationNumber;
                    }
                    // ALSN-42 Ended
                     if(!String.isBlank(claimInfo.complaintCode) && batchClaimSubResults.warCodeMap.containskey(claimInfo.complaintCode.trim()+'Complaint Codes')){
                            claim.ATI_Complaint_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.complaintCode.trim()+'Complaint Codes').Id;
                        } 
                    if(!String.isBlank(claimInfo.failureCode) && batchClaimSubResults.warCodeMap.containskey(claimInfo.failureCode.trim()+'Fault Code')){
                            claim.ATI_Failure_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.failureCode.trim()+'Fault Code').Id;
                            claim.WOD_2__Fault_Code__c = claim.ATI_Failure_Code__c;
                        } 
                    //End 
                    //ALSN-146
                    if(batchClaimSubResults.accMap.containsKey(claimInfo.repairOutlet.trim())){
                    rateType = batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).ATI_Exchange_Rate_Type__c;
                    }
                    //ALSN-117 //ALSN-146
                    if(batchClaimSubResults.exchangeRateMap.containsKey(claim.CurrencyIsoCode+'USD'+rateType)){
                        claim.ATI_Exchange_Rate__c = batchClaimSubResults.exchangeRateMap.get(claim.CurrencyIsoCode+'USD'+rateType).Value__c;
                    }
                    claim.ATI_Submittal_Indicator__c = claimInfo.submittalIndicator;
                    claim.ATI_Tracking_Number__c = claimInfo.trackingNumber;
                    claim.ATI_Identifier__c = claimInfo.identifier;
                    if(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containskey(claimInfo.identifier.trim())){
                        claim.ATI_BatchClaim_Error_Messages__c = JSON.serialize(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.get(claimInfo.identifier.trim()));
                    }
                    if(!String.isBlank(claimInfo.serialNumber) && batchClaimSubResults.inventoryMap.containskey(claimInfo.serialNumber.trim())){
                        if(claimInfo.submittalIndicator != 'M'){
                            claim.WOD_2__BusinessCategory__c = batchClaimSubResults.buMap.get(claimInfo.businessCategoryConfiguration.trim());
                            buId = claim.WOD_2__BusinessCategory__c;
                            claim.WOD_2__Inventory__c = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Id;
                            claim.WOD_2__Model_Number__c = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Item__c;
                            //Alsn -174 assigning extended base model value instead of description
                            claim.WOD_2__Description__c = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Item__r.Extended_Base_Model__c;
                        }
                        //ALSN-101 Relaxed Logic for Campaign Claim
                        //if(!claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                            getWarrantyRegistrationDetails(claimInfo,claim);
                        //}
                    }
                    claim.WOD_2__Date_Of_Repair__c = ATI_Utils.parseDate(claimInfo.laborLastAppliedDate);
                    claim.WOD_2__Date_Of_Failure__c = ATI_Utils.parseDate(claimInfo.repairOrderOpenDate);
                    //ALSN-163
                    claim.WOD_2__Date_Of_Purchase__c = ATI_Utils.parseDate(claimInfo.dateOfPurchase);
                    if(ATI_Utils.checkIsNotBlankData(claimInfo.registrationInfo.vehicleInfo.vehicleMileage)){
                        claim.WOD_2__Units_Usage__c = Decimal.valueof(claimInfo.registrationInfo.vehicleInfo.vehicleMileage);
                    }
                    if(ATI_Utils.checkIsNotBlankData(claimInfo.repairOutlet) && batchClaimSubResults.accMap.containskey(claimInfo.repairOutlet.trim()))
                      // batchClaimSubResults.accMap.get(claimInfo.repairOutlet.trim()).PRP_Participation__c)
                     {
                         
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeCustomerRequestedService)){
                           claim.ATI_Customer_Requests_Service_Date__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeCustomerRequestedService);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeDistributorScheduledService)){
                           claim.ATI_Distributor_schedules_cust_Serv_Date__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeDistributorScheduledService);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeOfVehicleArrival)){
                         claim.ATI_Vehicle_Arrival_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeOfVehicleArrival);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeLaborFirstApplied)){
                         claim.ATI_First_Labor_Applied_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeLaborFirstApplied);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeFirstPartOrdered)){
                           claim.ATI_First_Part_Ordered_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeFirstPartOrdered);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeLastPartArrived)){
                         claim.ATI_Last_Part_Arrival_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeLastPartArrived);
                         }
                         //String[] strTimeSplit = claimInfo.turnAroundData.timeLaborLastRecordedOrApplied.split(':');
                           //Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);        
                         if(!claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied.containsWhitespace() && !String.isBlank(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied)){
                             String s = claimInfo.laborLastAppliedDate + ' ' + claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied;
                             claim.ATI_Last_Labor_Recorded_Time__c = Datetime.valueOf(s);
                         }
                         else{
                             if(!String.isBlank(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied)){
                             claim.ATI_Last_Labor_Recorded_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied);
                         } 
                         }
                         //claim.ATI_Last_Labor_Recorded_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeLaborLastRecordedOrApplied);
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeRepairOrderClosed)){  
                         claim.ATI_Repair_Order_Closed_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeRepairOrderClosed);
                         }
                         if(!String.isBlank(claimInfo.turnAroundData.dateTimeCustomerNotified)){
                           claim.ATI_Completed_Repair_Cust_Noti_Date__c = Datetime.valueOf(claimInfo.turnAroundData.dateTimeCustomerNotified);
                         }
                         //strTimeSplit = claimInfo.turnAroundData.repairOrderOpenTime.split(':');
                           //timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]) ,0,0);
                         if(!claimInfo.turnAroundData.repairOrderOpenDateTime.containsWhitespace() && !String.isBlank(claimInfo.turnAroundData.repairOrderOpenDateTime)){
                             String s = claimInfo.repairOrderOpenDate + ' ' + claimInfo.turnAroundData.repairOrderOpenDateTime;
                             claim.ATI_Repair_Order_Open_Time__c = Datetime.valueOf(s);
                         }
                         else{
                             if(!String.isBlank(claimInfo.turnAroundData.repairOrderOpenDateTime)){
                             claim.ATI_Repair_Order_Open_Time__c = Datetime.valueOf(claimInfo.turnAroundData.repairOrderOpenDateTime);
                             }
                         }  
                         //claim.ATI_Repair_Order_Open_Time__c = Datetime.valueOf(claimInfo.turnAroundData.repairOrderOpenDateTime);
                           //claim.ATI_Customer_AuthorizeWork_Date_Time__c = Datetime.valueOf(claimInfo.turnAroundData.customerAuthorizeWorkDateOrTime);
                       }
                    if(!claimInfo.claimType.trim().equalsIgnoreCase('Campaign')){
                        if(!String.isBlank(claimInfo.primaryFailedPart) && batchClaimSubResults.warProdMap.containskey(claimInfo.primaryFailedPart.trim())){
                            claim.WOD_2__Causal_Part_Number__c = batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).Id;
                            claim.WOD_2__Causal_Part_Description__c = batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Description__c;
                            if(batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Track_Type__c == 'Serialized'){
                                claim.WOD_2__Causal_Part_Serial_Number__c = claimInfo.primaryFailedPartSerialNumber.trim();
                            }
                        }
                       /* if(!String.isBlank(claimInfo.failureCode) && batchClaimSubResults.warCodeMap.containskey(claimInfo.failureCode.trim()+'Fault Code')){
                            claim.ATI_Failure_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.failureCode.trim()+'Fault Code').Id;
                            claim.WOD_2__Fault_Code__c = claim.ATI_Failure_Code__c;
                        } */
                        // Added ALSN-94
                        // Alsn - 163 -- modified the condition
                        if((claimInfo.preAuthorizationRequired != null && Boolean.valueOf(claimInfo.preAuthorizationRequired)) &&
                          (claimInfo.submittalIndicator != 'M' || claimInfo.submittalIndicator == 'M'))
                           //|| claimInfo.submittalIndicator == 'I' )
                           {
                            claim.WOD_2__Is_Pre_Authorization_Required__c = true;
                             //modified by Dishari on 8/3/2021 for goodwill reason change
                               Map<String,String> mapOfPreAuth = New Map<String,String>(ATI_Utils.getPicklistOptions('WOD_2__Claim__c','WOD_2__Pre_Authorization_Reason__c'));
                               if(!mapOfPreAuth.isEmpty() &&  mapOfPreAuth.values().Contains(claimInfo.preAuthorizationReason)){
                                   for(String key : mapOfPreAuth.keySet()){ 
                                       if(mapOfPreAuth.get(key) == claimInfo.preAuthorizationReason ){
                                           claim.WOD_2__Pre_Authorization_Reason__c = key;
                                           system.debug(' claim.WOD_2__Pre_Authorization_Reason__c'+ claim.WOD_2__Pre_Authorization_Reason__c);
                                       }
                                   }
                               }
                               else{
                                   claim.WOD_2__Pre_Authorization_Reason__c = claimInfo.preAuthorizationReason;
                               }
                               
                            //claim.WOD_2__Pre_Authorization_Reason__c = 'Goodwill';
                            //End here for goodwill reason change
                            claim.WOD_2__Pre_Authorization_Comments__c = claimInfo.preAuthorizationComments;
                        }
                        //ATI_CLM_ATPolicyQueryOverrideImpl.buId = claim.WOD_2__BusinessCategory__c;
                        //ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim =  claim.WOD_2__Is_Pre_Authorization_Required__c;
                       /* if(!String.isBlank(claimInfo.complaintCode) && batchClaimSubResults.warCodeMap.containskey(claimInfo.complaintCode.trim()+'Complaint Codes')){
                            claim.ATI_Complaint_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.complaintCode.trim()+'Complaint Codes').Id;
                        } */
                      ///  claim.ATI_Technician_Name__c = claimInfo.TechnicianName;
                        if(claimInfo.claimType.trim().equalsIgnoreCase('Machine')){
                            claim.WOD_2__Claim_Type__c = 'Machine';
                            //testing for issue fix
                            //claim.RecordTypeId = '012050000008Uz2AAE';
                            if(!ATI_Utils.checkIsBlankData(claimInfo.serviceReplacementIndicator)){
                                claim.ATI_Replacement_Claims__c = true;
                                claim.ATI_Replacement_Type__c = claimInfo.serviceReplacementIndicator;
                                claim.ATI_Replaced_Inventory__c = batchClaimSubResults.inventoryMap.get(claimInfo.replacementUnitSerialNumber.trim()).Id;
                                claim.ATI_Replaced_Model__c = batchClaimSubResults.inventoryMap.get(claimInfo.replacementUnitSerialNumber.trim()).WOD_2__Item__c;
                            }
                            WOD_2.CLM_ClaimCreateInputWrapper machineClaimInputWrapper = new WOD_2.CLM_ClaimCreateInputWrapper();
                            machineClaimInputWrapper.claimObject = claim;
                            machineClaimInputWrapper.claimType = claim.WOD_2__Claim_Type__c;
                            machineClaimsInputWrapperList.add(machineClaimInputWrapper);
                        }
                        else if(claimInfo.claimType.trim().equalsIgnoreCase('Part')){
                            claim.WOD_2__Claim_Type__c = 'Part';
                            claim.WOD_2__Host_NonHost__c = 'Installed On OEM Machine';
                            if(claimInfo.submittalIndicator != 'M'){
                               claim.WOD_2__Date_Of_Purchase__c = ATI_Utils.parseDate(claimInfo.dateOfPurchase);
                                claim.WOD_2__Part__c = batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).Id;
                                claim.WOD_2__Part_Description__c = batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Description__c;                        
                                if(batchClaimSubResults.warProdMap.get(claimInfo.primaryFailedPart.trim()).WOD_2__Track_Type__c == 'Serialized'){
                                    claim.WOD_2__Part_Serial_Number__c = claimInfo.primaryFailedPartSerialNumber;
                                }
                            }
                            WOD_2.CLM_ClaimCreateInputWrapper partClaimInputWrapper = new WOD_2.CLM_ClaimCreateInputWrapper();
                            partClaimInputWrapper.claimObject = claim;
                            partClaimInputWrapper.claimType = claim.WOD_2__Claim_Type__c;
                            partClaimsInputWrapperList.add(partClaimInputWrapper);
                            //Alsn-141 
                            Integer monthDiff = claim.WOD_2__Date_Of_Purchase__c.monthsBetween(claim.WOD_2__Date_Of_Failure__c);
                            Integer daysEnd = Date.daysInMonth(claim.WOD_2__Date_Of_Failure__c.year(), claim.WOD_2__Date_Of_Failure__c.month());
                            Double day_s = claim.WOD_2__Date_Of_Purchase__c.day();
                            Double day_e = claim.WOD_2__Date_Of_Failure__c.day();
                            Double factor = 0;                    
                            factor = (day_e - day_s)/daysEnd;                 
                            Double months = monthDiff+factor;
                            ATI_CLM_ATPolicyQueryOverrideImpl.months = months;
                            System.debug('monthss'+months);
                            //end of Alsn 141
                        }
                    }else{
                        if(claimInfo.submittalIndicator != 'M'){
                            claim.WOD_2__Claim_Type__c = 'Campaign';
                            claim.WOD_2__Causal_Part_Number__c = batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim()).twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__c;
                            claim.WOD_2__Causal_Part_Description__c = batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim()).twodcms__Claim_Template__r.WOD_2__Causal_Part_Description__c;
                            claim.WOD_2__Comments__c = batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim()).twodcms__Claim_Template__r.WOD_2__Comments__c;
                            if(batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode.trim()+'-'+claimInfo.campaignTemplateName.trim()).twodcms__Claim_Template__r.WOD_2__Causal_Part_Number__r.WOD_2__Track_Type__c == 'Serialized'){
                                claim.WOD_2__Causal_Part_Serial_Number__c = claimInfo.primaryFailedPartSerialNumber;
                            }
                            twodcms.CampaignClaimWrapper campaignClaimMember = new twodcms.CampaignClaimWrapper();
                            campaignClaimMember.campaignClaimObject = claim;
                            campaignClaimMember.cctaObject = batchClaimSubResults.mapOfKeyWithCampaignClaimTempAss.get(claimInfo.specialActivityCode+'-'+claimInfo.campaignTemplateName);
                            campaignMemberWrapperLst.add(campaignClaimMember);
                        }else{
                            mapOfInsertedOrUpdatedClaims.put(claimInfo.identifier.trim(),claim);
                            claimSubmitList.add(claim);
                        }
                    }
                }
            }
            
            //validate Inventory Before ClaimSave
            List<String> errorLst = validateInventory();
            if(!errorLst.isEmpty()){
                mapOfFailure.put(claimInfoLst.get(0).identifier.trim(),errorLst);BatchClaimSubmittalWrapper batchClaimSubWrapper = new BatchClaimSubmittalWrapper();batchClaimSubWrapper.mapOfInsertedOrUpdatedClaims = mapOfInsertedOrUpdatedClaims;batchClaimSubWrapper.mapOfFailure = mapOfFailure;batchClaimSubWrapper.claimSubmitList = claimSubmitList;batchClaimSubWrapper.claimIdKeyMap = claimIdKeyMap;responseWrapperObj.data = JSON.serialize(batchClaimSubWrapper);responseWrapperObj.status = true;return responseWrapperObj;
            }
            
            if(!mapOfInsertedOrUpdatedClaims.isEmpty()){
                List<WOD_2__Claim__c> claimLst = mapOfInsertedOrUpdatedClaims.values();
                Database.SaveResult[] claimUpdateLst = Database.update(mapOfInsertedOrUpdatedClaims.values(), false);
                for(Integer i=0;i<claimUpdateLst.size();i++){
                    if(!claimUpdateLst.get(i).isSuccess()){
                        if(mapOfFailure.containsKey(claimLst[i].ATI_Identifier__c)){
                            mapOfFailure.get(claimLst[i].ATI_Identifier__c).add(claimUpdateLst.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n');
                        }else{
                            mapOfFailure.put(claimLst[i].ATI_Identifier__c,new List<String>{claimUpdateLst.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n'});
                            
                        }
                    }
                }
            }
            if(!machineClaimsInputWrapperList.isEmpty() || 
               !partClaimsInputWrapperList.isEmpty() || 
               !campaignMemberWrapperLst.isEmpty() || !claimSubmitList.isEmpty()){
                Map<Id,string> invWRStatusMap = new Map<Id,string>();
                   createCustomerInfo();
                   createVehicleInfo();
                   if(!wrInsertOrUpdateList.isEmpty()){
                       createWarrantyRegistration(buId);
                       if(!setOfWRInsertedIds.isEmpty()){
                           for(WOD_2__Warranty_Registration__c warRec : [SELECT Id,WOD_2__Status__c,WOD_2__Inventory__c FROM WOD_2__Warranty_Registration__c WHERE Id IN :setOfWRInsertedIds]){
                               invWRStatusMap.put(warRec.WOD_2__Inventory__c,warRec.WOD_2__Status__c);
                           }
                       }
                   }
                //Alsn-81
                List<WOD_2__Claim__c> claimToUpdate= new List<WOD_2__Claim__c>();
                if(!machineClaimsInputWrapperList.isEmpty()){
                    machineClaimsOutputWrapperList = WOD_2.CLM_UnmanagedUtility.saveMachineClaims(machineClaimsInputWrapperList);
                    for(integer i = 0;i<machineClaimsOutputWrapperList.size();i++){
                        WOD_2__Claim__c claimRec = machineClaimsOutputWrapperList.get(i).claimObject;
                        //Alsn-81
                        //ALSN-202 Checking if the claim is created or not before updating the customer on it
                        if(newCustomerId != null && machineClaimsOutputWrapperList.get(i).status){
                            claimRec.ATI_Customer_Info__c = newCustomerId;
                            claimToUpdate.add(claimRec);
                        }
                        // end of Alsn-81
                        String claimKey = claimRec.ATI_Identifier__c;
                        if(machineClaimsOutputWrapperList.get(i).status){
                            claimIdKeyMap.put(claimRec.Id,claimKey);
                            if(claimRec.ATI_Submittal_Indicator__c == 'M'){
                                claimSubmitList.add(claimRec);
                            }else if(claimRec.ATI_Submittal_Indicator__c == 'I'){
                                claimSubmitList.add(claimRec);
                            }else if(claimRec.ATI_Submittal_Indicator__c == 'C'){
                                claimValidateList.add(claimRec);
                                setOfValidateClaimIds.add(claimRec.Id);
                            }
                        }
                        else{
                            System.debug('machineClaimsOutputWrapperList>>>>> '+machineClaimsOutputWrapperList.get(i).msg);
                            if(!machineClaimsOutputWrapperList.get(i).msg.contains('Unable to serialize a map with a null key.')){
                                if(mapOfFailure.containsKey(claimKey)){
                                    mapOfFailure.get(claimKey).add(machineClaimsOutputWrapperList.get(i).msg);
                                }else{
                                    mapOfFailure.put(claimKey,new List<String>{machineClaimsOutputWrapperList.get(i).msg});
                                }
                            }
                        }
                    }
                }
                if(!partClaimsInputWrapperList.isEmpty()){
                    partClaimsOutputWrapperList = WOD_2.CLM_UnmanagedUtility.savePartClaims(partClaimsInputWrapperList);
                    for(integer i=0;i<partClaimsOutputWrapperList.size();i++){
                        WOD_2__Claim__c claimRec = partClaimsOutputWrapperList.get(i).claimObject;
                        //Alsn-81
                        //ALSN-202 Checking if the claim is created or not before updating the customer on it
                        if(newCustomerId != null && partClaimsOutputWrapperList.get(i).status){
                            claimRec.ATI_Customer_Info__c = newCustomerId;
                            claimToUpdate.add(claimRec);
                        }
                        //end of Alsn-81
                        if(partClaimsOutputWrapperList.get(i).status){
                            claimIdKeyMap.put(claimRec.Id,claimRec.ATI_Identifier__c);
                            if(claimRec.ATI_Submittal_Indicator__c == 'M'){
                                claimSubmitList.add(claimRec);
                            }else if(claimRec.ATI_Submittal_Indicator__c == 'I'){
                                claimSubmitList.add(claimRec);
                            }else if(claimRec.ATI_Submittal_Indicator__c == 'C'){
                                claimValidateList.add(claimRec);
                                setOfValidateClaimIds.add(claimRec.Id);
                            }
                        }
                        else{
                            if(!partClaimsOutputWrapperList.get(i).msg.contains('Unable to serialize a map with a null key.')){
                                if(mapOfFailure.containsKey(claimRec.ATI_Identifier__c)){
                                    mapOfFailure.get(claimRec.ATI_Identifier__c).add(partClaimsOutputWrapperList.get(i).msg);
                                }else{
                                    mapOfFailure.put(claimRec.ATI_Identifier__c,new List<String>{partClaimsOutputWrapperList.get(i).msg});
                                }
                            }
                        }
                    }
                }
                
                if(!campaignMemberWrapperLst.isEmpty()){
                    campaignMemberWrapperLst = twodcms.ServiceCampaignUtility.saveCampaignClaims(campaignMemberWrapperLst);
                    for(integer i=0;i<campaignMemberWrapperLst.size();i++){
                        WOD_2__Claim__c claimRec = campaignMemberWrapperLst.get(i).campaignClaimObject;
                        //Alsn-81
                        //ALSN-202 Checking if the claim is created or not before updating the customer on it
                        if(newCustomerId != null && campaignMemberWrapperLst.get(i).status){
                            claimRec.ATI_Customer_Info__c = newCustomerId;
                            claimToUpdate.add(claimRec);
                        }
                        //end of Alsn-81
                        if(campaignMemberWrapperLst.get(i).status){
                            claimIdKeyMap.put(claimRec.Id,claimRec.ATI_Identifier__c);
                            campaignclaimIdKeyMap.put(claimRec.Id,claimRec.ATI_Identifier__c);
                            if(claimRec.ATI_Submittal_Indicator__c == 'M'){
                                claimSubmitList.add(claimRec);
                            }else if(claimRec.ATI_Submittal_Indicator__c == 'I'){
                                claimSubmitList.add(claimRec);
                            }
                            else if(claimRec.ATI_Submittal_Indicator__c == 'C'){
                                claimValidateList.add(claimRec);
                                setOfValidateClaimIds.add(claimRec.Id);
                            }
                        }
                        else{
                            if(mapOfFailure.containsKey(claimRec.ATI_Identifier__c)){
                                mapOfFailure.get(claimRec.ATI_Identifier__c).add(campaignMemberWrapperLst.get(i).msg);
                            }else{
                                mapOfFailure.put(claimRec.ATI_Identifier__c,new List<String>{campaignMemberWrapperLst.get(i).msg});
                            }
                        }
                    }
                    
                }
                //Alsn-81
                if(!claimToUpdate.isEmpty()){
                TriggerHandler.Bypass('ATI_ClaimTriggerHandler');    
                update claimToUpdate;   
                TriggerHandler.ClearBypass('ATI_ClaimTriggerHandler');
                }
                //end of Alsn-81
                processChildData(buId);
                if(!claimSubmitList.isEmpty() && mapOfFailure.isEmpty() && batchClaimSubResults.mapOfFailure.isEmpty()){
                    List<WOD_2__Business_Rule__c> businessRuleLst = [SELECT Id FROM WOD_2__Business_Rule__c WHERE WOD_2__Claim__c IN:claimSubmitList];
                    if(!businessRuleLst.isEmpty()){
                        System.debug('000000000list'+businessRuleLst);
                        Delete businessRuleLst;
                    }
                }
                if(!claimValidateList.isEmpty()){
                    System.debug('claimValidateList>>> '+claimValidateList);
                    WOD_2.BR_BusinessRuleEngineOutputWrapper buRuleOutputWrapper = validateBURules(claimValidateList);
                    for(string ruleKey : buRuleOutputWrapper.ruleObjectIdToMapOfBccsObjectList.keyset()){
                        for(WOD_2__Business_Category_Configuration_Setting__c bccsRec : buRuleOutputWrapper.ruleObjectIdToMapOfBccsObjectList.get(ruleKey)){
                            if(bccsRec.WOD_2__Error_Type__c != 'Soft'){
                                if(mapOfFailure.containsKey(claimIdKeyMap.get(ruleKey))){
                                    mapOfFailure.get(claimIdKeyMap.get(ruleKey)).add(bccsRec.WOD_2__Display_Message__c);
                                }else{
                                    mapOfFailure.put(claimIdKeyMap.get(ruleKey),new List<String>{bccsRec.WOD_2__Display_Message__c});
                                }
                            }
                        }
                    }
                    WOD_2.BR_ClaimRuleEngineOtputWrapper response = WOD_2.BR_BusinessRuleEngineUtility.runClaimRuleEngine(setOfValidateClaimIds);
                }
            }
            BatchClaimSubmittalWrapper batchClaimSubWrapper = new BatchClaimSubmittalWrapper();
            batchClaimSubWrapper.mapOfInsertedOrUpdatedClaims = mapOfInsertedOrUpdatedClaims;
            batchClaimSubWrapper.mapOfFailure = mapOfFailure;
            batchClaimSubWrapper.claimSubmitList = claimSubmitList;
            batchClaimSubWrapper.claimIdKeyMap = claimIdKeyMap;
            responseWrapperObj.data = JSON.serialize(batchClaimSubWrapper);
            responseWrapperObj.status = true;
        }Catch(DMLException e){
            System.debug('errormessage>>>> '+e.getMessage()+e.getLineNumber());
            responseWrapperObj.data = '';responseWrapperObj.status = false;responseWrapperObj.errormessage = e.getMessage();
        }Catch(Exception e){
            System.debug('errormessage>>>> '+e.getMessage()+e.getLineNumber());
            responseWrapperObj.data = '';
            responseWrapperObj.status = false;
            responseWrapperObj.errormessage = e.getMessage();
        }
        return responseWrapperObj;
    }
    
    private static List<String> validateInventory(){
        List<String> errorLst = new List<String>();
        ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfoData = claimInfoLst.get(0);
        Set<String> serialNumSet = new Set<String>();
        serialNumSet.add(claimInfoData.serialNumber.trim());
        if(ATI_Utils.checkIsNotBlankData(claimInfoData.serviceReplacementIndicator) && claimInfoData.claimType.trim().equalsIgnoreCase('Machine')){
            serialNumSet.add(claimInfoData.replacementUnitSerialNumber.trim());
        }
        if(!serialNumSet.isEmpty()){ //Alsn-174 added extended base model field in query
            for(WOD_2__Inventory__c inv : [SELECT id,WOD_2__Scrapped__c,ATI_Warranty_Void__c,ATI_Active__c,WOD_2__Account__c,WOD_2__Type__c,WOD_2__Serial_Number__c,WOD_2__Business_Unit__c,WOD_2__Item__c,WOD_2__Item__r.WOD_2__Description__c,WOD_2__Item__r.Extended_Base_Model__c,
                                           (Select id,ATI_Pre_Delivery__c,WOD_2__Account__c,WOD_2__Inventory__c,ATI_Vocation_Code__c,WOD_2__Warranty_Product__c,WOD_2__Registration_Date__c,WOD_2__Status__c,WOD_2__Customer__c,
                                            WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,WOD_2__Units_Usage__c,WOD_2__Inventory__r.WOD_2__Type__c,WOD_2__Install_Date__c from WOD_2__Warranty_Registration__r 
                                            WHERE WOD_2__Registration_Type__c = 'Standard Registration' AND ((WOD_2__Status__c='Draft' AND WOD_2__Inventory__r.WOD_2__Type__c ='Stock') OR (WOD_2__Status__c IN('Registered','Pending Warranty Processor Approval','In Progress') AND WOD_2__Inventory__r.WOD_2__Type__c ='Retail')) ORDER BY CreatedDate DESC Limit 1),
                                           (SELECT Id,ATI_Vehicle_Information__c,ATI_Inventory__c,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Mileage_Usage__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c,ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Engine_Make__c,ATI_Vehicle_Information__r.ATI_Engine_Model__c,
                                            ATI_Vehicle_Information__r.ATI_Engine_Year__c,ATI_Vehicle_Information__r.ATI_Executive_order_Designation__c,ATI_Vehicle_Information__r.ATI_Vocation_Code__c FROM Transmissions__r ORDER BY CreatedDate DESC Limit 1)
                                           FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN : serialNumSet]){
                                               if(!inv.ATI_Warranty_Void__c && !inv.WOD_2__Scrapped__c && inv.ATI_Active__c){
                                                   batchClaimSubResults.inventoryMap.put(inv.WOD_2__Serial_Number__c,inv);
                                               }else{
                                                   if(inv.WOD_2__Serial_Number__c.equalsIgnoreCase(claimInfoData.serialNumber)){
                                                       errorLst.add('SerialNumber is Invalid');
                                                   }else if(ATI_Utils.checkIsNotBlankData(claimInfoData.serviceReplacementIndicator) && claimInfoData.claimType.trim().equalsIgnoreCase('Machine')
                                                            && inv.WOD_2__Serial_Number__c.equalsIgnoreCase(claimInfoData.serviceReplacementIndicator)){
                                                                errorLst.add('ReplacementUnitSerialNumber is Invalid');
                                                            }
                                               }
                                           }
        }
        return errorLst;
    }
    
    //createCustomerInfo
    private static void createCustomerInfo(){
        if(!accInsertOrUpdateList.isEmpty()){
            List<String> accfields = new List<String>{'Name','BillingCity','BillingPostalCode','BillingCountry','BillingStreet','BillingState','ATI_Primary_Email_Id__c','Phone','WOD_2__Warranty_Account_Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper accountCreateAccessCheck = ATI_Utils.fetchCreateAccess('Account',accfields);
            if(accountCreateAccessCheck.noAccessObjectList.size() == 0 && accountCreateAccessCheck.noAccessFieldList.size() == 0){    
                Database.UpsertResult[] accInsertRes = Database.upsert(accInsertOrUpdateList, false);
                Set<Id> accIdsForShare = new Set<Id>();
                for (Database.UpsertResult sr : accInsertRes) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            throw new ATI_Exception(err.getMessage());               
                        }
                    }else{
                        if(!mapOfIdWithCustomerAcc.containsKey(sr.getId())){
                            accIdsForShare.add(sr.getId());
                            //Alsn-81
                            newCustomerId=sr.getId();
                        }
                    }
                }
                if(!accIdsForShare.isEmpty()){
                    WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_DealerGroupNameForSharing');
                    if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null){
                        Group customerGroup = [SELECT Id FROM Group WHERE Name=:logRecordValue.WOD_2__Configuration_Value__c];
                        if(customerGroup != null){
                            List<AccountShare> accountShareList = new List<AccountShare>();
                            for(Id accId : accIdsForShare){
                                accountShareList.add(
                                    new AccountShare(
                                        AccountAccessLevel = 'Read',
                                        AccountId = accId,
                                        OpportunityAccessLevel = 'None',
                                        UserOrGroupId = customerGroup.id
                                    )
                                );
                            }
                            if(!accountShareList.isEmpty()){
                                Database.SaveResult[] saveResultAccountShare = Database.insert(accountShareList, true);
                                for (Database.SaveResult sr : saveResultAccountShare) {
                                    if (!sr.isSuccess()) {
                                        // Operation failed, so get all errors                
                                        for(Database.Error err : sr.getErrors()) {
                                            throw new ATI_Exception(err.getMessage());               
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                String errortext = 'Insufficient Account Create Access>> '+JSON.serialize(accountCreateAccessCheck);ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access);
            }
        }
    }    
    
    //createVehicleInfo
    private static void createVehicleInfo(){
        if(!vehInfoList.isEmpty()){
            List<String> vehFields = new List<String>{'ATI_Customer_asset_number__c','Name','ATI_Vehicle_Make__c','ATI_Vehicle_Model__c','ATI_Engine_Make__c','ATI_Engine_Model__c','ATI_Executive_order_Designation__c','ATI_Vocation_Code__c'};
                ATI_Utils.NoAccessObjectFieldWrapper vehCreateAccessCheck = ATI_Utils.fetchCreateAccess( 'ATI_Vehicle_Information__c',vehFields);
            if(vehCreateAccessCheck.noAccessObjectList.size() == 0 && vehCreateAccessCheck.noAccessFieldList.size() == 0){
                Database.UpsertResult[] vehInfoRes = Database.upsert(vehInfoList, false);
                if(!updateVehicleTransMapperLst.isEmpty()){
                    ATI_VIN_Transmission_Mapper__c vehicleTransMapper = updateVehicleTransMapperLst.get(0);
                    vehicleTransMapper.ATI_Vehicle_Information__c = vehInfoRes.get(0).getId();
                   // Alsn-210,166 - avoid updating the VIN as it is not necessary
                   // Database.update(vehicleTransMapper);
                }else{
                    Map<Id,ATI_Vehicle_Information__c> mapOfInvIdWithVehicleInfo = new Map<Id,ATI_Vehicle_Information__c>();
                    ATI_Vehicle_Information__c vehicleInfo = vehInfoList.get(0);
                    if(invId != ''){
                        mapOfInvIdWithVehicleInfo.put((Id)invId,vehicleInfo);
                        ATI_VehicleInformationController.createVehicleInfoMapper(mapOfInvIdWithVehicleInfo);
                    }
                }
            }
            else {
                String errortext = 'Insufficient Vehicle Information Create Access>> '+JSON.serialize(vehCreateAccessCheck);ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);throw new ATI_Exception('(Vehicle Information) '+Label.ATI_Log_Insufficient_access);
            } 
        }
    }
    
    //createWarrantyRegistration
    private static void createWarrantyRegistration(String buId){
        try{
            WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject = new WOD_2.BR_BusinessRuleEngineWrapper();
            brInputWrapperObject.buId = buId;
            brInputWrapperObject.configType = 'Rule';
            brInputWrapperObject.moduleName = 'Warranty Registration';
            brInputWrapperObject.ruleObjectAPIName = 'ATI_Warranty_Registration__c';
            brInputWrapperObject.configNameList = null;
            brInputWrapperObject.ruleObjectIdList = new List<Id>();
            WOD_2__Inventory__c invRec = new WOD_2__Inventory__c(); //ALSN-96 Vijay Changes
            for(WOD_2__Warranty_Registration__c wrRec : wrInsertOrUpdateList){
                if(invCustMap.containskey(wrRec.WOD_2__Inventory__c) && wrRec.WOD_2__Customer__c == null){
                    if(batchClaimSubResults.accMap.containskey(invCustMap.get(wrRec.WOD_2__Inventory__c))){
                        wrRec.WOD_2__Customer__c = batchClaimSubResults.accMap.get(invCustMap.get(wrRec.WOD_2__Inventory__c)).Id;
                        if(mapOfInvForUpdate.containsKey(wrRec.WOD_2__Inventory__c)){
                         //WOD_2__Inventory__c invRec = mapOfInvForUpdate.get(wrRec.WOD_2__Inventory__c); //ALSN-96 Vijay Changes
                            invRec = mapOfInvForUpdate.get(wrRec.WOD_2__Inventory__c);
                            invRec.WOD_2__Customer__c = wrRec.WOD_2__Customer__c;
                            mapOfInvForUpdate.put(invRec.id,invRec);
                        }
                    }
                }
            }
            List<String> wRegFields = new List<String>{'WOD_2__Registration_Date__c','WOD_2__Registration_Type__c','WOD_2__Status__c','WOD_2__Account__c','ATI_Pre_Delivery__c','WOD_2__Units_Usage__c','WOD_2__Install_Date__c','WOD_2__Inventory__c','ATI_Vocation_Code__c','WOD_2__Customer__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wRegCreateAccessCheck = ATI_Utils.fetchCreateAccess('WOD_2__Warranty_Registration__c',wRegFields);
            ATI_Utils.NoAccessObjectFieldWrapper wRegUpdateAccessCheck = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Registration__c',wRegFields);
            ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfoData = claimInfoLst.get(0); //ALSN-96 Vijay Changes
            Date inServiceDate = ATI_Utils.parseDate(claimInfoData.registrationInfo.vehicleInfo.inServiceDate); //ALSN-96 Vijay Changes
            if(wRegUpdateAccessCheck.noAccessObjectList.size() == 0 && wRegUpdateAccessCheck.noAccessFieldList.size() == 0 && wRegCreateAccessCheck.noAccessObjectList.size() == 0 && wRegCreateAccessCheck.noAccessFieldList.size() == 0 ){ 
                 //ALSN-96 Vijay Changes
               WOD_2__Inventory__c invRecord = [Select id,WOD_2__Install_Date__c,WOD_2__Manufacturing_Date__c,WOD_2__Shipment_Date__c from WOD_2__Inventory__c WHERE Id =: invRec.Id limit 1];
               Database.UpsertResult[] wrList;
                if(inServiceDate != null){//Vijay changes ALSN-119
                     if((invRecord.WOD_2__Manufacturing_Date__c != null && invRecord.WOD_2__Manufacturing_Date__c < inServiceDate) &&  
                       (invRecord.WOD_2__Shipment_Date__c != null && invRecord.WOD_2__Shipment_Date__c < inServiceDate))
                       {
                           wrList = Database.upsert(wrInsertOrUpdateList, false);
                       }
                    else if(invRecord.WOD_2__Manufacturing_Date__c != null && invRecord.WOD_2__Manufacturing_Date__c > inServiceDate) {
                         throw new TWoDException(Label.ATI_WR_InstallDateLtManufacturingDate);
                    }
                    else if(invRecord.WOD_2__Shipment_Date__c != null && invRecord.WOD_2__Shipment_Date__c > inServiceDate) {
                         throw new TWoDException(Label.ATI_WR_InstallDateLtShipmentDate);
                    }
                }else{
                    wrList = Database.upsert(wrInsertOrUpdateList, false);
                    }
                   //Vijay changes ALSN-119 end
             
               //ALSN-96 Vijay Changes -End
                updateInvDetailsOnWRSave();
                for(Database.UpsertResult wrRec : wrList){
                    if(wrRec.isSuccess()){
                        brInputWrapperObject.ruleObjectIdList.add(wrRec.getId());
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
            }else{
                String errortext = 'Insufficient Warranty Registration Create Access>> '+JSON.serialize(wRegCreateAccessCheck);ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            } 
            if(!brInputWrapperObject.ruleObjectIdList.isEmpty()){
                updateInvDetailsOnSuccessWR();
            }
        }catch(DMLException e){throw new ATI_Exception(e.getMessage());
        }catch(exception e){
            throw new ATI_Exception(e.getMessage() + e.getLineNumber());
        }
    }
    
    //updateInvDetailsOnWRSave
    private static void updateInvDetailsOnWRSave(){
        if(!mapOfInvForUpdate.isEmpty()){
            List<String> invFields = new List<String>{'ATI_Vocation_Code__c','WOD_2__Install_Date__c','WOD_2__Customer__c'};
                ATI_Utils.NoAccessObjectFieldWrapper invNoAccessObjectFieldWrapper = ATI_Utils.fetchUpdateAccess('WOD_2__Inventory__c',invFields);
            if(invNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && invNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0){
                Database.SaveResult[] invUpdateRes = Database.update(mapOfInvForUpdate.values(), false);
            }
            else {
                String errortext = 'Insufficient Inventory Update Access>> '+JSON.serialize(invNoAccessObjectFieldWrapper);ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            } 
        }
    }
    
    //updateInvDetailsOnSuccessWR
    private static void updateInvDetailsOnSuccessWR(){
        if(!mapOfInvToUpdateType.isEmpty()){
            List<String> invFields = new List<String>{'WOD_2__Type__c'};
                ATI_Utils.NoAccessObjectFieldWrapper invNoAccessObjectFieldWrapper = ATI_Utils.fetchUpdateAccess('WOD_2__Inventory__c',invFields);
            if(invNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && invNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0){
                for(WOD_2__Inventory__c inv : mapOfInvToUpdateType.values()){
                    inv.WOD_2__Type__c = 'Retail';
                }
                Database.SaveResult[] invUpdateRes = Database.update(mapOfInvToUpdateType.values(), false);
            }else{
                String errortext = 'Insufficient Inventory Update Access>> '+JSON.serialize(invNoAccessObjectFieldWrapper);ATI_LogService.createOrUpdateLogForAccess('ClaimSubmittalRequest',errortext,strBatchLogId);throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            } 
        }
    }
    
    public static List<WOD_2.TWoD_RecordOutputWrapper> validateSubmitBURules(List<WOD_2__Claim__c> claimList){
        WOD_2.BR_BusinessRuleEngineWrapper businessRuleWrapper = getBURuleEngineWrapper(claimList);
        List<WOD_2.TWoD_RecordOutputWrapper> buRuleOutputWrapper = new List<WOD_2.TWoD_RecordOutputWrapper>();
        buRuleOutputWrapper = WOD_2.BR_BusinessRuleEngineUtility.invokeRecordSubmitHandler(businessRuleWrapper);
        return buRuleOutputWrapper;
    }
    
    private static WOD_2.BR_BusinessRuleEngineOutputWrapper validateBURules(List<WOD_2__Claim__c> claimList){
        WOD_2.BR_BusinessRuleEngineWrapper businessRuleWrapper = getBURuleEngineWrapper(claimList);
        WOD_2.BR_BusinessRuleEngineOutputWrapper buRuleOutputWrapper = WOD_2.BR_BusinessRuleEngineUtility.runBusinessRuleEngine(businessRuleWrapper);
        return buRuleOutputWrapper;
    }
    
    private static WOD_2.BR_BusinessRuleEngineWrapper getBURuleEngineWrapper(List<WOD_2__Claim__c> claimList){
        WOD_2.BR_BusinessRuleEngineWrapper businessRuleWrapper = new WOD_2.BR_BusinessRuleEngineWrapper();
        businessRuleWrapper.buId = claimList[0].WOD_2__BusinessCategory__c;
        businessRuleWrapper.configType = 'Rule';
        businessRuleWrapper.moduleName = 'Claim';
        businessRuleWrapper.ruleObjectAPIName = 'WOD_2__Claim__c';
        List<Id> claimIdList = new List<Id>();
        for(WOD_2__Claim__c claimRec : claimList){
            claimIdList.add(claimRec.Id);
        }
        businessRuleWrapper.ruleObjectIdList = claimIdList;
        return businessRuleWrapper;
    }
    
    private static Map<Id,WOD_2__Claim__c> claimMap{get; private set;}
    private static Map<Id,List<String>> claimIdToErrorStrMap{get; private set;}
    private static List<ATI_Diagnostic_Code__c> diagnosticCodeLst{get; private set;}
    private static List<WOD_2__Claim_Part__c> claimInstallPartsList{get; private set;}
    private static List<WOD_2__Removed_Claim_Part__c> remPartList{get; private set;}
    private static Id partRecordTypeId{get; private set;}
    private static List<WOD_2__Claim_Service_Information__c> laborCodeLst{get; private set;}
    private static List<WOD_2__Other_Cost__c> otherCostList{get; private set;}
    private static List<WOD_2__Financial_Line_Item__c> fliUpdateList{get; private set;}
    
    private static List<ATI_Diagnostic_Code__c> diagnosticDeleteList{get; private set;}
    private static List<WOD_2__Claim_Part__c> partDeleteList{get; private set;}
    private static List<WOD_2__Removed_Claim_Part__c> removedPartDeleteList{get; private set;}
    private static List<WOD_2__Claim_Service_Information__c> laborDeleteList{get; private set;}
    private static List<WOD_2__Other_Cost__c> otherCostDeleteList{get; private set;}
    
    private static Map<String,ATI_Diagnostic_Code__c> diagCodeMap{get; private set;}
    private static Map<String,WOD_2__Claim_Part__c> partMap{get; private set;}
    private static Map<String,WOD_2__Removed_Claim_Part__c> remPartMap{get; private set;}
    private static Map<String,WOD_2__Claim_Service_Information__c> laborMap{get; private set;}
    private static Map<String,WOD_2__Other_Cost__c> otherCostMap{get; private set;}
    
    private static Set<string> diagnosticSet{get; private set;}
    private static Set<string> partSet{get; private set;}
    private static Set<string> removedPartSet{get; private set;}
    private static Set<string> laborSet{get; private set;}
    private static Set<string> otherCostSet{get; private set;}
    private static Set<String> setOfClaimTypes{get; private set;}
    private static Set<String> setOfAccountTypes{get; private set;}
    private static Set<Date> setOfDateOfFailures{get; private set;}
    private static Set<Id> setOfDealerIds{get; private set;}
    private static Set<Id> setOfPartIds{get; private set;}
    private static Map<String,List<ATI_Part_Markup__c>> partMarkUpDataMap{get; private set;}
    private static Map<String,List<WOD_2__Rates_Details__c>> landingCostMarkupMap{get; private set;}
    private static Map<String,List<WOD_2__Warranty_Product_Pricebook__c>> partCostMap{get; private set;}
    private static List<WOD_2__Claim__c> claimUpdateLst{get; private set;}
    private static void processChildData(String buId){
        try{
            //TriggerHandler.bypass('ATI_FinancialLineItemTriggerHandler');
            claimMap = new Map<Id,WOD_2__Claim__c>();
            if(!claimValidateList.isEmpty() || !claimSubmitList.isEmpty()){  //ALSN-101 added ATI_Claim_Subtype__c in query
                List<WOD_2__Claim__c> claimLst = [SELECT Id,Name,ATI_Claim_Number__c,ATI_Account_Email__c,WOD_2__Account__r.Public_Group_Id__c,WOD_2__Auto_Approved__c,WOD_2__Approved_Rejected_Date__c,WOD_2__Account__c,WOD_2__Claim_Type__c,ATI_Identifier__c,WOD_2__Model_Number__r.Part_Markup_Percentage__c,WOD_2__Account__r.Type,WOD_2__Date_Of_Failure__c,WOD_2__Account__r.SAP_ID__c,ATI_Submittal_Indicator__c,ATI_Tracking_Number__c,
                                                  ATI_BatchClaim_Error_Messages__c,WOD_2__Inventory__r.Name,WOD_2__Rate__r.WOD_2__Travel_By_Distance_Rate__c,WOD_2__Rate__r.WOD_2__Labor_Rate__c,CurrencyIsoCode,WOD_2__Work_Order__c,WOD_2__Inventory__c,WOD_2__BusinessCategory__c,WOD_2__Degradation_Modifier__c,WOD_2__Account__r.ATI_Customer_Group__c,WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c,
                                                  ATI_Total_Approved_Amount__c,ATI_Total_Requested_Amount__c,WOD_2__Warranty_Product__c,ATI_Claim_Subtype__c FROM WOD_2__Claim__c WHERE Id IN :claimValidateList OR Id IN :claimSubmitList];
                for(WOD_2__Claim__c claim : claimLst){
                    claimMap.put(claim.Id,claim);
                    if(claim.ATI_Submittal_Indicator__c == 'I' || claim.ATI_Submittal_Indicator__c == 'C'){
                        mapOfInsertedOrUpdatedClaims.put(claim.ATI_Identifier__c,claim);
                    }else{
                        mapOfInsertedOrUpdatedClaims.put(claim.ATI_Identifier__c,claim);
                    }
                }
                
            }
            if(!mapOfInsertedOrUpdatedClaims.isEmpty()){
                claimIdToErrorStrMap = new Map<Id,List<String>>();
                if(!claimMap.isEmpty()){
                    claimIdToErrorStrMap = validateClaimBURules(claimMap,'Claim UI - Basic Info');
                    List<WOD_2__Claim__c> claimsToDelete = new List<WOD_2__Claim__c>();
                    for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : batchClaimSubResults.batchClaimSubmittalReqLst){
                        if(mapOfInsertedOrUpdatedClaims.containsKey(claimInfo.identifier)){
                            if(claimIdToErrorStrMap.containsKey(mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id)){
                                if(mapOfFailure.containsKey(claimInfo.identifier)){
                                    mapOfFailure.get(claimInfo.identifier).addAll(claimIdToErrorStrMap.get(mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id));
                                }else{
                                    mapOfFailure.put(claimInfo.identifier,claimIdToErrorStrMap.get(mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id));
                                }
                                claimsToDelete.add(mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier));
                                mapOfInsertedOrUpdatedClaims.remove(claimInfo.identifier);
                            }
                        }
                    }
                    if(!claimsToDelete.isEmpty()){
                        delete claimsToDelete;
                    }
                }
                setOfClaimTypes = new Set<String>();
                setOfAccountTypes = new Set<String>();
                setOfDateOfFailures = new Set<Date>();
                setOfDealerIds = new Set<Id>();
                setOfPartIds = new Set<Id>();
                partMarkUpDataMap = new Map<String,List<ATI_Part_Markup__c>>();
                landingCostMarkupMap = new Map<String,List<WOD_2__Rates_Details__c>>();
                partCostMap = new Map<String,List<WOD_2__Warranty_Product_Pricebook__c>>();
                claimUpdateLst = new List<WOD_2__Claim__c>();
                
                diagnosticCodeLst = new List<ATI_Diagnostic_Code__c>();
                claimInstallPartsList = new List<WOD_2__Claim_Part__c>();
                remPartList = new List<WOD_2__Removed_Claim_Part__c>();
                laborCodeLst = new List<WOD_2__Claim_Service_Information__c>();
                otherCostList = new List<WOD_2__Other_Cost__c>();
                fliUpdateList = new List<WOD_2__Financial_Line_Item__c>();
                
                
                if(claimIdToErrorStrMap.isEmpty()){
                    if(!claimIdKeyMap.isEmpty() && !campaignclaimIdKeyMap.isEmpty()){
                        Set<Id> claimIdSet = new Set<Id>();
                        for(Id claimId : campaignclaimIdKeyMap.keySet()){
                            claimIdSet.add(claimId);
                        }
                        
                        Map<Id,twodcms.CampaignClaimWrapper> claimIdCampWrapper = twodcms.ServiceCampaignUtility.saveCampaginClaimRelatedList(claimIdSet,buId);
                        List<twodcms.CampaignClaimWrapper> claimCampWrapperLst = claimIdCampWrapper.values();
                        for(integer i=0;i<claimCampWrapperLst.size();i++){
                            String identifier = campaignclaimIdKeyMap.get(claimCampWrapperLst.get(i).campaignClaimObject.Id);
                            if(!claimCampWrapperLst.get(i).status){
                                if(mapOfFailure.containsKey(identifier)){
                                    mapOfFailure.get(identifier).add(claimCampWrapperLst.get(i).msg);
                                }else{
                                    mapOfFailure.put(identifier,new List<String>{claimCampWrapperLst.get(i).msg});
                                }
                            }
                        }
                    }
                    
                    partRecordTypeId = Schema.SObjectType.WOD_2__Claim_Part__c.getRecordTypeInfosByName().get('OEM Installed Parts').getRecordTypeId();
                    diagCodeMap = new Map<String,ATI_Diagnostic_Code__c>();
                    partMap = new Map<String,WOD_2__Claim_Part__c>();
                    remPartMap = new Map<String,WOD_2__Removed_Claim_Part__c>();
                    laborMap = new Map<String,WOD_2__Claim_Service_Information__c>();
                    otherCostMap = new Map<String,WOD_2__Other_Cost__c>();
                    
                    diagnosticDeleteList = new List<ATI_Diagnostic_Code__c>();
                    partDeleteList = new List<WOD_2__Claim_Part__c>();
                    removedPartDeleteList = new List<WOD_2__Removed_Claim_Part__c>();
                    laborDeleteList = new List<WOD_2__Claim_Service_Information__c>();
                    otherCostDeleteList = new List<WOD_2__Other_Cost__c>();
                    
                    diagnosticSet = new Set<String>();
                    partSet = new Set<String>();
                    removedPartSet = new Set<String>();
                    laborSet = new Set<String>();
                    otherCostSet = new Set<String>();
                    for(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo : claimInfoLst){
                        if(mapOfInsertedOrUpdatedClaims.containsKey(claimInfo.identifier.trim())){
                            getRelatedDataForAandMSubIndicator(claimInfo);
                            Decimal exchangeRateValue = 1.0;
                            String currencyCode = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier.trim()).CurrencyIsoCode;
                            //ALSN-117 //ALSN-146
                            if(currencyCode != 'USD'){
                                exchangeRateValue = batchClaimSubResults.exchangeRateMap.get(currencyCode+'USD'+rateType).Value__c;
                            }
                            getDiagnosticCodeInfoDetails(claimInfo);
                            getInstallPartsData(claimInfo,exchangeRateValue);
                            getClaimServiceInfoDetails(claimInfo,exchangeRateValue);
                            getOtherCostDetails(claimInfo,exchangeRateValue);
                        }
                    }
                    
                    if(!diagnosticDeleteList.isEmpty()){
                        delete diagnosticDeleteList;
                    }
                    if(!partDeleteList.isEmpty()){
                        delete partDeleteList;
                    }
                    if(!removedPartDeleteList.isEmpty()){
                        delete removedPartDeleteList;
                    }
                    if(!laborDeleteList.isEmpty()){
                        delete laborDeleteList;
                    }
                    if(!otherCostDeleteList.isEmpty()){
                        delete otherCostDeleteList;
                    }
                    saveDiagnosticCodes();
                    saveInstallPartsData();
                    saveRemovedPartsData();
                    saveClaimServiceInfoDetails();
                    saveOtherCostDetails();
                    if(!setOfDateOfFailures.isEmpty() && !setOfDealerIds.isEmpty() && !setOfPartIds.isEmpty()){
                        getPartMarkupDetails();
                        getLandingCostDetails();
                        getPartCostDetails();
                    }
                    if(!claimMap.isEmpty()){
                        getFinancialLineItemsForUpdate();
                    }
                    if(!fliUpdateList.isEmpty()){
                        Database.SaveResult[] fliUpdateResult = Database.update(fliUpdateList, false);
                        getFinancialDetailsForUpdate();
                        if(!claimUpdateLst.isEmpty()){
                            TriggerHandler.Bypass('ATI_ClaimTriggerHandler');
                            Database.SaveResult[] claimUpdateResult = Database.update(claimUpdateLst, false);
                            TriggerHandler.ClearBypass('ATI_ClaimTriggerHandler');
                        }
                    }
                }
                ATI_FinancialTriggerHandler.skipFinancialTriggerHandler = false;
            }
        }Catch(Exception e){
            System.debug('Exception>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    //getWarrantyRegistrationDetails
    private static void getWarrantyRegistrationDetails(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo,WOD_2__Claim__c claim){
        if(!batchClaimSubResults.accMap.containskey(claimInfo.registrationInfo.customerInfo.customerName+claimInfo.registrationInfo.customerInfo.city+claimInfo.registrationInfo.customerInfo.postalCode)){
            processCustomerInformation(claimInfo);           
        }else{
            ATI_REST_BatchClaimSubmittalRequest.CustomerInformation customerInfo = claimInfo.registrationInfo.customerInfo;
            Account customerAcc = batchClaimSubResults.accMap.get(claimInfo.registrationInfo.customerInfo.customerName+claimInfo.registrationInfo.customerInfo.city+claimInfo.registrationInfo.customerInfo.postalCode);
            //Alsn-166 added check to update the customer only if the conditions get satisfied
            if(customerInfo.email == ''){
                customerInfo.email = null;
            }
            if(customerInfo.phone == ''){
                customerInfo.phone = null;
            }
            if(customerAcc.BillingCountry != customerInfo.countryCode || customerAcc.BillingStreet != customerInfo.street || customerAcc.BillingState != customerInfo.state || customerAcc.ATI_Primary_Email_Id__c != customerInfo.email || customerAcc.Phone != customerInfo.phone){
            customerAcc.BillingCountry = customerInfo.countryCode;
            customerAcc.BillingStreet = customerInfo.street;
            customerAcc.BillingState = customerInfo.state;
            customerAcc.ATI_Primary_Email_Id__c = customerInfo.email;
            customerAcc.Phone = customerInfo.phone;
            accInsertOrUpdateList.add(customerAcc);
            }
            mapOfIdWithCustomerAcc.put(customerAcc.id,customerAcc);
            // Alsn-81
            claim.ATI_Customer_Info__c =customerAcc.id;
            invCustMap.put(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Id,claimInfo.registrationInfo.customerInfo.customerName+claimInfo.registrationInfo.customerInfo.city+claimInfo.registrationInfo.customerInfo.postalCode);
        }
        processVehicleInformation(claimInfo);
        WOD_2__Warranty_Registration__c wrRecord = new WOD_2__Warranty_Registration__c();
        WOD_2__Inventory__c invRec = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim());
        Boolean createWR = true;
        if(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Warranty_Registration__r.size()>0){
            if(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Warranty_Registration__r.get(0).WOD_2__Status__c == 'Draft'){
                wrRecord = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Warranty_Registration__r;
            }else{
                createWR = false;
            }
        }
        if(createWR){
            if(!String.isBlank(claimInfo.registrationInfo.vehicleInfo.vocationCode) && batchClaimSubResults.warCodeMap.containskey(claimInfo.registrationInfo.vehicleInfo.vocationCode.trim()+'Vocation Codes')){
                wrRecord.ATI_Vocation_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.registrationInfo.vehicleInfo.vocationCode+'Vocation Codes').Id;
                invRec.ATI_Vocation_Code__c = batchClaimSubResults.warCodeMap.get(claimInfo.registrationInfo.vehicleInfo.vocationCode+'Vocation Codes').Id;
            }
            wrRecord.WOD_2__Registration_Date__c =  System.today();
            wrRecord.WOD_2__Account__c = claim.WOD_2__Account__c;
            if(!String.isBlank(claimInfo.registrationInfo.vehicleInfo.preDelivery)){
                wrRecord.ATI_Pre_Delivery__c = Boolean.valueOf(claimInfo.registrationInfo.vehicleInfo.preDelivery); 
            }
            wrRecord.WOD_2__Units_Usage__c =  Decimal.valueOf(claimInfo.registrationInfo.vehicleInfo.vehicleMileage);
            // user time zone
            /*String userTimeZone = UserInfo.getTimeZone().getID();
            Date startDate =  Date.valueOf(claimInfo.registrationInfo.vehicleInfo.inServiceDate);
            DateTime dateTimeInGMT = (Datetime) startDate;
            String startDategmt= dateTimeInGMT.format('MM/dd/yyyy',userTimeZone);
            wrRecord.WOD_2__Install_Date__c = ATI_Utils.parseDate(startDategmt);*/
            System.debug('install date 992 '+claimInfo.registrationInfo.vehicleInfo.inServiceDate);
            wrRecord.WOD_2__Install_Date__c = ATI_Utils.parseDate(claimInfo.registrationInfo.vehicleInfo.inServiceDate);
            wrRecord.WOD_2__Warranty_Product__c = invRec.WOD_2__Item__c;
            invRec.WOD_2__Install_Date__c = wrRecord.WOD_2__Install_Date__c;
            wrRecord.WOD_2__Inventory__c = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Id;
            wrRecord.WOD_2__Status__c = 'Draft';
            if(wrRecord.ATI_Pre_Delivery__c){
                wrRecord.WOD_2__Registration_Type__c = 'Pre-delivery';
            }else{
                wrRecord.WOD_2__Registration_Type__c = 'Standard Registration';
                mapOfInvToUpdateType.put(wrRecord.WOD_2__Inventory__c,invRec);
            }
            wrInsertOrUpdateList.add(wrRecord);
            mapOfInvForUpdate.put(wrRecord.WOD_2__Inventory__c,invRec);
        }
    }
    
    //CustomerInformation
    private static void processCustomerInformation(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo){
        ATI_REST_BatchClaimSubmittalRequest.CustomerInformation customerInfo = claimInfo.registrationInfo.customerInfo;
        Account accRec = new Account();
        accRec.Name = customerInfo.customerName;
        accRec.BillingCity = customerInfo.city;
        accRec.BillingPostalCode = customerInfo.postalCode;
        accRec.BillingCountry = customerInfo.countryCode;
        accRec.BillingStreet = customerInfo.street;
        accRec.BillingState = customerInfo.state;
        accRec.ATI_Primary_Email_Id__c = customerInfo.email;
        accRec.Phone = customerInfo.phone;
        accRec.WOD_2__Warranty_Account_Type__c = 'Customer';
        accRec.ATI_Customer_Group__c = 'EU99';  
        accInsertOrUpdateList.add(accRec);
        batchClaimSubResults.accMap.put(customerInfo.customerName+customerInfo.city+customerInfo.postalCode,accRec);
        invCustMap.put(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Id,customerInfo.customerName+customerInfo.city+customerInfo.postalCode);
    }
    
    //ProcessVehicleInformation
    private static void processVehicleInformation(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo){
        ATI_REST_BatchClaimSubmittalRequest.VehicleInformation vehicleInfo = claimInfo.registrationInfo.vehicleInfo;
        ATI_Vehicle_Information__c vehInfoRecord = new ATI_Vehicle_Information__c();
        Boolean isVehicleInfo = false;
        List<ATI_Vehicle_Information__c> vehicleInfoLst = [SELECT Id FROM ATI_Vehicle_Information__c WHERE Name=:vehicleInfo.vehicleIdentificationNumber.trim() Order BY CreatedDate DESC LIMIT 1];
        if(!vehicleInfoLst.isEmpty() && batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Type__c == 'Retail'){
            vehInfoRecord.id = vehicleInfoLst.get(0).id;
            vehInfoRecord.ATI_Vehicle_Usage__c = Decimal.valueOf(vehicleInfo.vehicleMileage);
            isVehicleInfo = true;
        }else{
            if(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).WOD_2__Type__c == 'Stock'){
                vehInfoRecord.Name =  vehicleInfo.vehicleIdentificationNumber.trim();
                vehInfoRecord.ATI_Vehicle_usage_mi_km_hr__c = vehicleInfo.usageUnit;
                vehInfoRecord.ATI_Vehicle_Usage__c = Decimal.valueOf(vehicleInfo.vehicleMileage);
                if(!String.isBlank(vehicleInfo.vocationCode) && batchClaimSubResults.warCodeMap.containskey(vehicleInfo.vocationCode.trim()+'Vocation Codes')){
                    vehInfoRecord.ATI_Vocation_Code__c = batchClaimSubResults.warCodeMap.get(vehicleInfo.vocationCode+'Vocation Codes').Id;
                }
                isVehicleInfo = true;
            }
        }
        vehInfoRecord.ATI_Customer_asset_number__c =  vehicleInfo.customerAssetNumber;
        vehInfoRecord.ATI_Vehicle_Make__c =  vehicleInfo.vehicleMake;
        vehInfoRecord.ATI_Vehicle_Model__c = vehicleInfo.vehicleModel;
        vehInfoRecord.ATI_Engine_Make__c =  vehicleInfo.engineMake;
        vehInfoRecord.ATI_Engine_Model__c =  vehicleInfo.engineModel;
        if(!string.isBlank(vehicleInfo.engineYear))
            vehInfoRecord.ATI_Engine_Year__c=  vehicleInfo.engineYear;
        vehInfoRecord.ATI_Executive_order_Designation__c = vehicleInfo.executiveOrderDesignation;
        if(isVehicleInfo){
            vehInfoList.add(vehInfoRecord);
            invId = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Id;
            if(batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Transmissions__r.size()>0){
                ATI_VIN_Transmission_Mapper__c vehicleTransMapper = batchClaimSubResults.inventoryMap.get(claimInfo.serialNumber.trim()).Transmissions__r;
                updateVehicleTransMapperLst.add(vehicleTransMapper);
            }
        }
    }
    
    //getRelatedDataForAandMSubIndicator
    private static void getRelatedDataForAandMSubIndicator(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo){
        if(batchClaimSubResults.claimMap.containskey(claimInfo.claimNumber)){
            for(WOD_2__Claim_Part__c partRec : batchClaimSubResults.claimMap.get(claimInfo.claimNumber).WOD_2__Claim_Parts__r){
                if(claimInfo.submittalIndicator == 'A'){
                    partMap.put(partRec.WOD_2__Warranty_Product__r.Name,partRec);
                }
                else if(claimInfo.submittalIndicator == 'M'){
                    partDeleteList.add(partRec);
                }
            }
            for(WOD_2__Removed_Claim_Part__c removedPartRec : batchClaimSubResults.claimMap.get(claimInfo.claimNumber.trim()).WOD_2__Removed_Claim_Parts__r){
                if(claimInfo.submittalIndicator == 'A'){
                    remPartMap.put(removedPartRec.WOD_2__Warranty_Product__r.Name,removedPartRec);
                    setOfRemovedPartIds.add(removedPartRec.id);
                }
                else if(claimInfo.submittalIndicator == 'M'){
                    removedPartDeleteList.add(removedPartRec);
                }
            }
            for(ATI_Diagnostic_Code__c diagnosticRec : batchClaimSubResults.claimMap.get(claimInfo.claimNumber.trim()).Diagnostic_Codes__r){
                if(claimInfo.submittalIndicator == 'A'){
                    diagCodeMap.put(diagnosticRec.Warranty_Code__r.Name,diagnosticRec);
                }
                else if(claimInfo.submittalIndicator == 'M'){
                    diagnosticDeleteList.add(diagnosticRec);
                }
            }
            for(WOD_2__Claim_Service_Information__c laborRec : batchClaimSubResults.claimMap.get(claimInfo.claimNumber.trim()).WOD_2__Claim_Service_Informations__r){
                if(claimInfo.submittalIndicator == 'A'){
                    laborMap.put(laborRec.WOD_2__Service_Job_Code__r.Name,laborRec);
                }
                else if(claimInfo.submittalIndicator == 'M'){
                    laborDeleteList.add(laborRec);
                }
            }
            for(WOD_2__Other_Cost__c otherCostRec : batchClaimSubResults.claimMap.get(claimInfo.claimNumber.trim()).WOD_2__Other_Costs__r){
                if(claimInfo.submittalIndicator == 'A'){
                    otherCostMap.put(otherCostRec.WOD_2__Cost_Category_Type__c,otherCostRec);
                }
                else if(claimInfo.submittalIndicator == 'M'){
                    otherCostDeleteList.add(otherCostRec);
                }
            }
        }
    }
    
    
    //getDiagnosticCodeInfoDetails
    private static void getDiagnosticCodeInfoDetails(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo){
        if(batchClaimSubResults.mapOfSuccessDiagnosticCodes.containsKey(claimInfo.identifier.trim())){
            List<ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData> diagnosticCodes = batchClaimSubResults.mapOfSuccessDiagnosticCodes.get(claimInfo.identifier.trim());
            for(ATI_REST_BatchClaimSubmittalRequest.DiagnosticCodesData diagnosticCodeInfo : diagnosticCodes){
                ATI_Diagnostic_Code__c diagnosticCode = new ATI_Diagnostic_Code__c();
                if(diagCodeMap.containskey(diagnosticCodeInfo.diagnosticCode.trim())){
                    diagnosticCode = diagCodeMap.get(diagnosticCodeInfo.diagnosticCode.trim());
                    diagnosticSet.add(diagnosticCodeInfo.diagnosticCode.trim());
                }
                diagnosticCode.Claim__c = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id;
                if(batchClaimSubResults.warCodeMap.containsKey(diagnosticCodeInfo.diagnosticCode.trim()+'Diagnostics Codes')){
                    WOD_2__Warranty_Code__c warCode = batchClaimSubResults.warCodeMap.get(diagnosticCodeInfo.diagnosticCode.trim()+'Diagnostics Codes');
                    diagnosticCode.Warranty_Code__c = warCode.Id;
                    diagnosticCodeLst.add(diagnosticCode);
                }
            }
        }
        for(String warCode : diagCodeMap.keyset()){
            if(!diagnosticSet.contains(warCode)){
                diagnosticDeleteList.add(diagCodeMap.get(warCode));
            }
        }
    }
    
    //getInstallPartsData
    private static void getInstallPartsData(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo,Decimal exchangeRateValue){
        if(batchClaimSubResults.mapOfSuccessParts.containsKey(claimInfo.identifier.trim())){
            List<ATI_REST_BatchClaimSubmittalRequest.PartsInformation> serviceParts = batchClaimSubResults.mapOfSuccessParts.get(claimInfo.identifier.trim());
            for(ATI_REST_BatchClaimSubmittalRequest.PartsInformation partsInfo : serviceParts){
                WOD_2__Claim_Part__c claimPart = new WOD_2__Claim_Part__c();
                if(partMap.containskey(partsInfo.replacedPartNumber.trim())){
                    claimPart = partMap.get(partsInfo.replacedPartNumber.trim());
                    if(batchClaimSubResults.financialLineItemMap.containskey(claimPart.WOD_2__Claim__c)){
                        WOD_2__Financial_Line_Item__c lineItemRec = batchClaimSubResults.financialLineItemMap.get(claimPart.WOD_2__Claim__c);
                        lineItemRec.WOD_2__Requested_Quantity__c = Decimal.valueOf(partsInfo.partQuantity);
                        lineItemRec.WOD_2__Approved_Quantity__c = Decimal.valueOf(partsInfo.partQuantity);
                        fliUpdateList.add(lineItemRec);
                    }
                    partSet.add(partsInfo.replacedPartNumber.trim());
                }
                claimPart.WOD_2__Claim__c = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id;
                if(batchClaimSubResults.warProdMap.containsKey(partsInfo.replacedPartNumber.trim())){
                    WOD_2__Warranty_Product__c warProd = batchClaimSubResults.warProdMap.get(partsInfo.replacedPartNumber.trim());
                    if(warProd.WOD_2__Type__c == 'Item' && warProd.WOD_2__Item_Type__c == 'Part'){
                        claimPart.WOD_2__Warranty_Product__c = warProd.Id;
                        if(warProd.WOD_2__Track_Type__c == 'Serialized'){
                            claimPart.WOD_2__Serial_Number__c =  partsInfo.replacementPartSerialNumber.trim();
                        }
                        claimPart.WOD_2__Part_Description__c = warProd.WOD_2__Description__c;
                        if(batchClaimSubResults.priceBookMap.containsKey(claimPart.WOD_2__Warranty_Product__c)){
                            //WOD_2__Warranty_Product_Pricebook__c priceBookRec = batchClaimSubResults.priceBookMap.get(claimPart.WOD_2__Warranty_Product__c);
                            //ALSN-45
                            for(WOD_2__Warranty_Product_Pricebook__c priceBookRec : batchClaimSubResults.priceBookMap.get(claimPart.WOD_2__Warranty_Product__c)){
                            if(priceBookRec.Name == partsInfo.replacedPartNumber && priceBookRec.ATI_Price_Group__c == batchClaimSubResults.accMap.get(mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).WOD_2__Account__r.SAP_ID__c).ATI_Price_Group__c && priceBookRec.WOD_2__Valid_From__c<=ATI_Utils.parseDate(claimInfo.repairOrderOpenDate) && priceBookRec.WOD_2__Valid_Until__c >=ATI_Utils.parseDate(claimInfo.repairOrderOpenDate)){
                               //Added by Anjali
                                if(priceBookRec.WOD_2__Unit_Price__c != NULL){
                                    //ALSN-3 exchange rate check for local currency
                                    if(exchangeRateValue == 1){
                                        claimPart.WOD_2__Unit_Price__c = priceBookRec.WOD_2__Unit_Price__c;
                                        claimPart.ATI_Unit_Price_in_USD__c = claimPart.WOD_2__Unit_Price__c * exchangeRateValue;
                                    System.debug('exchangeRateValue'+ exchangeRateValue);
                                    }else{
                                        claimPart.WOD_2__Unit_Price__c = priceBookRec.WOD_2__Unit_Price__c / exchangeRateValue;
                                        claimPart.ATI_Unit_Price_in_USD__c = claimPart.WOD_2__Unit_Price__c * exchangeRateValue;
                                   System.debug('exchangeRateValue--1--'+ exchangeRateValue);
                                    }
                                
                            }
                            }
                            }
                        }
                    }
                }
                //Anjali Added
                if(!String.isEmpty(partsInfo.replacedPartNumber)){
                claimPart.Name = partsInfo.replacedPartNumber.trim();
                }
                //Anjali Added
                if(!String.isEmpty(partsInfo.partQuantity)){
                claimPart.WOD_2__Quantity__c = Decimal.valueOf(partsInfo.partQuantity);
                
                
                claimPart.WOD_2__Invoice_Quantity__c = claimPart.WOD_2__Quantity__c;
                
                claimPart.RecordTypeId = partRecordTypeId;
                claimInstallPartsList.add(claimPart);
                }
                
                WOD_2__Removed_Claim_Part__c remClaimPart = new WOD_2__Removed_Claim_Part__c();
                if(remPartMap.containskey(partsInfo.failedPartNumber.trim())){
                    removedPartSet.add(partsInfo.failedPartNumber.trim());
                }
                remClaimPart.WOD_2__Claim__c = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).Id;
                if(batchClaimSubResults.warProdMap.containsKey(partsInfo.failedPartNumber.trim())){
                    WOD_2__Warranty_Product__c warProd = batchClaimSubResults.warProdMap.get(partsInfo.failedPartNumber.trim());
                    if(warProd.WOD_2__Type__c == 'Item' && warProd.WOD_2__Item_Type__c == 'Part'){
                        remClaimPart.WOD_2__Warranty_Product__c = warProd.Id;
                        if(warProd.WOD_2__Track_Type__c == 'Serialized'){
                            remClaimPart.WOD_2__Serial_Number__c =  partsInfo.failedPartSerialNumber.trim();
                        }
                        remClaimPart.WOD_2__Part_Description__c = warProd.WOD_2__Description__c;
                    } 
                }
                //Anjali added
                if(!String.isEmpty(partsInfo.failedPartNumber)){
                remClaimPart.Name = partsInfo.failedPartNumber.trim();
                }
                //Anjali added
                if(!String.isEmpty(partsInfo.partQuantity)){
                remClaimPart.WOD_2__Quantity__c = Decimal.valueOf(partsInfo.partQuantity);
                }
                //Added by Anjali
                if((claimPart.WOD_2__Quantity__c) !=NULL){
                remClaimPart.WOD_2__Invoice_Quantity__c = claimPart.WOD_2__Quantity__c;
                
                remClaimPart.ATI_Claim_Email__c = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).ATI_Account_Email__c;
                remClaimPart.WOD_2__Inventory__c = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier).WOD_2__Inventory__c;
                remPartList.add(remClaimPart);
                }
            }  
        }
        
        for(String partName : partMap.keyset()){
            if(!partSet.contains(partName)){
                partDeleteList.add(partMap.get(partName));
            }
        }
        
        for(String partName : remPartMap.keyset()){
            if(!removedPartSet.contains(partName)){
                removedPartDeleteList.add(remPartMap.get(partName));
            }
        }  
    }
    
    //getClaimServiceInfoDetails
    private static void getClaimServiceInfoDetails(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo,Decimal exchangeRateValue){
        if(batchClaimSubResults.mapOfSuccessLaborCodes.containsKey(claimInfo.identifier.trim())){
            List<ATI_REST_BatchClaimSubmittalRequest.LaborInfomation> laborCodes = batchClaimSubResults.mapOfSuccessLaborCodes.get(claimInfo.identifier.trim());
            for(ATI_REST_BatchClaimSubmittalRequest.LaborInfomation laborInfo : laborCodes){
                WOD_2__Claim_Service_Information__c laborRec = new WOD_2__Claim_Service_Information__c();
                if(laborMap.containskey(laborInfo.laborOperationCode.trim())){
                    laborRec = laborMap.get(laborInfo.laborOperationCode.trim());
                    laborSet.add(laborInfo.laborOperationCode.trim());
                }
                WOD_2__Claim__c claimRec = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier);
                laborRec.WOD_2__Claim__c = claimRec.Id;
                if(batchClaimSubResults.warCodeMap.containsKey(laborInfo.laborOperationCode.trim()+'Job Code')){
                    WOD_2__Warranty_Code__c warCode = batchClaimSubResults.warCodeMap.get(laborInfo.laborOperationCode.trim()+'Job Code');
                    laborRec.WOD_2__Service_Job_Code__c = warCode.Id;
                    laborRec.WOD_2__Total_Labor_Hours__c = Decimal.valueOf(laborInfo.laborTimeActual);
                    laborRec.WOD_2__Total_Labor_Minutes__c =  (Decimal.valueOf(laborInfo.laborTimeActual)*60).setScale(4);
                    if(warCode.WOD_2__Standard_Labor_Hour__c != null){
                        laborRec.WOD_2__Standard_Labor_Hour__c = warCode.WOD_2__Standard_Labor_Hour__c;
                        laborRec.WOD_2__Additional_Labor_Hour__c = (laborRec.WOD_2__Total_Labor_Hours__c >= laborRec.WOD_2__Standard_Labor_Hour__c) ? laborRec.WOD_2__Total_Labor_Hours__c - laborRec.WOD_2__Standard_Labor_Hour__c : 0;
                    }
                    if(warCode.WOD_2__Standard_Labor_Minutes__c != null){
                        laborRec.WOD_2__Standard_Labor_Minutes__c = warCode.WOD_2__Standard_Labor_Minutes__c;
                        laborRec.WOD_2__Additional_Labor_Minutes__c = (laborRec.WOD_2__Total_Labor_Minutes__c >= laborRec.WOD_2__Standard_Labor_Minutes__c) ? laborRec.WOD_2__Total_Labor_Minutes__c - laborRec.WOD_2__Standard_Labor_Minutes__c : 0;
                    }
                    laborRec.CurrencyIsoCode = claimRec.CurrencyIsoCode;
                    if(!string.isBlank(laborInfo.reason)){
                        laborRec.WOD_2__Reason_Additional_Labor_Hour__c = laborInfo.reason.trim();
                    }
                    laborRec.Name = laborInfo.laborOperationCode.trim();
                    if(batchClaimSubResults.rateMap.containskey(claimRec.WOD_2__Account__c+'Labor Rate')){
                        laborRec.WOD_2__LaborRate__c = batchClaimSubResults.rateMap.get(claimRec.WOD_2__Account__c+'Labor Rate').WOD_2__Labor_Rate__c;//claimRec.WOD_2__Rate__r.WOD_2__Labor_Rate__c;
                        laborRec.ATI_Labor_Rate_in_USD__c = laborRec.WOD_2__LaborRate__c * exchangeRateValue;
                        laborRec.ATI_Total_Labor_Cost_in_USD__c = laborRec.ATI_Labor_Rate_in_USD__c * laborRec.WOD_2__Total_Labor_Hours__c;
                        laborCodeLst.add(laborRec);
                    }
                    else{
                        if(mapOfFailure.containsKey(claiminfo.identifier)){
                            mapOfFailure.get(claiminfo.identifier).add('Labor Rate not found');
                        }else{
                            mapOfFailure.put(claiminfo.identifier,new List<string>{'Labor Rate not found'});
                        }
                    }
                }
            }
        }
        for(String laborRec : laborMap.keyset()){
            if(!laborSet.contains(laborRec)){
                laborDeleteList.add(laborMap.get(laborRec));
            }
        }
    }
    
    //getOtherCostDetails
    private static void getOtherCostDetails(ATI_REST_BatchClaimSubmittalRequest.ClaimInformation claimInfo,Decimal exchangeRateValue){
        if(batchClaimSubResults.mapOfSuccessNetItems.containsKey(claimInfo.identifier.trim())){
            List<ATI_REST_BatchClaimSubmittalRequest.NetItemsData> netItems = batchClaimSubResults.mapOfSuccessNetItems.get(claimInfo.identifier.trim());
            for(ATI_REST_BatchClaimSubmittalRequest.NetItemsData otherCostInfo : netItems){
                WOD_2__Other_Cost__c otherCost = new WOD_2__Other_Cost__c();
                if(otherCostMap.containskey(otherCostInfo.netItemType.trim())){
                    otherCost = otherCostMap.get(otherCostInfo.netItemType.trim());
                    if(batchClaimSubResults.financialLineItemMap.containskey(otherCost.WOD_2__Claim__c)){
                        WOD_2__Financial_Line_Item__c lineItemRec = batchClaimSubResults.financialLineItemMap.get(otherCost.WOD_2__Claim__c);lineItemRec.WOD_2__Requested_Quantity__c = Integer.valueOf(otherCostInfo.netItemQuantity);lineItemRec.WOD_2__Approved_Quantity__c = Integer.valueOf(otherCostInfo.netItemQuantity);fliUpdateList.add(lineItemRec);
                    }
                    otherCostSet.add(otherCostInfo.netItemType.trim());
                }
                WOD_2__Claim__c claimRec = mapOfInsertedOrUpdatedClaims.get(claimInfo.identifier);
                otherCost.WOD_2__Claim__c = claimRec.Id;
                otherCost.WOD_2__Cost_Category_Type__c = otherCostInfo.netItemType.trim();
                //Added by Anjali
                if(!String.isEmpty(otherCostInfo.netItemQuantity)){
                otherCost.WOD_2__UnitsUsage__c = Integer.valueOf(otherCostInfo.netItemQuantity);
            }
                if(otherCost.WOD_2__Cost_Category_Type__c == 'Travel By Distance'){
                    if(batchClaimSubResults.rateMap.containskey(claimRec.WOD_2__Account__c+'Travel Rate')){
                        otherCost.WOD_2__Rate_PerUnit__c = batchClaimSubResults.rateMap.get(claimRec.WOD_2__Account__c+'Travel Rate').WOD_2__Travel_By_Distance_Rate__c;
                        //ASLN-168 Copy the save value to WOD_2__Rate_Per_Unit__c
                        otherCost.WOD_2__Rate_Per_Unit__c = otherCost.WOD_2__Rate_PerUnit__c;
                    }else{
                        if(mapOfFailure.containsKey(claiminfo.identifier)){
                            mapOfFailure.get(claiminfo.identifier).add('Travel Rate not found');
                        }else{
                            mapOfFailure.put(claiminfo.identifier,new List<string>{'Travel Rate not found'});
                        }
                    }
                }else{
                    if(!String.isEmpty(otherCostInfo.netItemUnitCost)){
                        otherCost.WOD_2__Rate_PerUnit__c = Decimal.valueOf(otherCostInfo.netItemUnitCost);
                        //ASLN-168 Copy the save value to WOD_2__Rate_Per_Unit__c
                        otherCost.WOD_2__Rate_Per_Unit__c = Decimal.valueOf(otherCostInfo.netItemUnitCost);
                    }
                }
                if(otherCost.WOD_2__Rate_PerUnit__c != null){
                    otherCost.WOD_2__Comments__c = otherCostInfo.reason.trim();
                    otherCost.WOD_2__Total_Cost__c = otherCost.WOD_2__UnitsUsage__c * otherCost.WOD_2__Rate_PerUnit__c;
                    otherCost.ATI_Unit_Price_in_USD__c = otherCost.WOD_2__Rate_PerUnit__c * exchangeRateValue;
                    otherCost.ATI_Total_Cost_in_USD__c = otherCost.ATI_Unit_Price_in_USD__c * otherCost.WOD_2__UnitsUsage__c;
                    otherCostList.add(otherCost);
                }
            }
        }
        for(String otherCostRec : otherCostMap.keyset()){
            if(!otherCostSet.contains(otherCostRec)){
                otherCostDeleteList.add(otherCostMap.get(otherCostRec));
            }
        }
    }
    
    
    //saveDiagnosticCodes
    private static void saveDiagnosticCodes(){
        if(!diagnosticCodeLst.isEmpty()){
            Database.UpsertResult[] diagnosticRes = Database.upsert(diagnosticCodeLst, false);
            for(Integer i=0;i<diagnosticRes.size();i++){
                if (!diagnosticRes.get(i).isSuccess()){
                    if(!claimIdToErrorStrMap.containsKey(diagnosticCodeLst.get(i).Claim__c)){
                        claimIdToErrorStrMap.put(diagnosticCodeLst.get(i).Claim__c,new List<String>{diagnosticRes.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n'});
                    }else{
                        List<String> errList = new List<String>();errList = claimIdToErrorStrMap.get(diagnosticCodeLst.get(i).Claim__c);errList.add(diagnosticRes.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n');claimIdToErrorStrMap.put(diagnosticCodeLst.get(i).Claim__c,errList);
                    }
                }
            }
        } 
    }
    
    //saveInstallPartsData
    private static void saveInstallPartsData(){
        if(!claimInstallPartsList.isEmpty()){
            Set<Id> claimIdsForRPDeletion = new Set<Id>();
            Set<Id> partIdsForRPDeletion = new Set<Id>();
            List<WOD_2.ResponseWrapper> partResWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimOEMInstallParts(claimInstallPartsList);
            for(integer i=0;i<partResWrapper.size();i++){
                WOD_2__Claim_Part__c partRec = (WOD_2__Claim_Part__c)Json.deserialize(partResWrapper.get(i).data, WOD_2__Claim_Part__c.class);
                WOD_2__Claim__c claim = new WOD_2__Claim__c();
                if(claimMap.containskey(partRec.WOD_2__Claim__c)){
                    claim = claimMap.get(partRec.WOD_2__Claim__c);
                }
                else if(batchClaimSubResults.claimIdMap.containskey(partRec.WOD_2__Claim__c)){
                    claim = batchClaimSubResults.claimIdMap.get(partRec.WOD_2__Claim__c);
                }
                if(!partResWrapper.get(i).status){
                    if(!mapOfFailure.containskey(claim.ATI_Identifier__c)){
                        mapOfFailure.put(claim.ATI_Identifier__c,new List<String>{partResWrapper.get(i).errormessage+' - '+partRec.Name});
                    }
                    else{
                        mapOfFailure.get(claim.ATI_Identifier__c).add(partResWrapper.get(i).errormessage+' - '+partRec.Name);
                    }
                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                    claimRelatedInfo.processCode = '99';claimRelatedInfo.processCategoryDescription = 'ServiceParts';claimRelatedInfo.processMessage = partResWrapper.get(i).errormessage+' - '+partRec.Name;
                    if(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containsKey(claim.ATI_Identifier__c)){
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.get(claim.ATI_Identifier__c).add(claimRelatedInfo);
                    }else{
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.put(claim.ATI_Identifier__c,new List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>{claimRelatedInfo});
                    }
                }else{
                    if(claim.WOD_2__Model_Number__c != null && claim.WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c != null && claim.WOD_2__Account__c != null && claim.WOD_2__Account__r.ATI_Customer_Group__c != null && claim.WOD_2__Date_Of_Failure__c != null){
                           setOfClaimTypes.add(claim.WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c);setOfAccountTypes.add(claim.WOD_2__Account__r.ATI_Customer_Group__c);setOfDateOfFailures.add(claim.WOD_2__Date_Of_Failure__c);setOfDealerIds.add(claim.WOD_2__Account__c);setOfPartIds.add(partRec.WOD_2__Warranty_Product__c);
                       }
                 //ALSN-101 added claim conditon
                    else if(claim.WOD_2__Claim_Type__c.trim().equalsIgnoreCase('Campaign') && claim.WOD_2__Model_Number__c != null && claim.ATI_Claim_Subtype__c != null && claim.WOD_2__Account__c != null && claim.WOD_2__Account__r.ATI_Customer_Group__c != null && claim.WOD_2__Date_Of_Failure__c != null){
                           setOfClaimTypes.add(claim.ATI_Claim_Subtype__c);setOfAccountTypes.add(claim.WOD_2__Account__r.ATI_Customer_Group__c);setOfDateOfFailures.add(claim.WOD_2__Date_Of_Failure__c);setOfDealerIds.add(claim.WOD_2__Account__c);setOfPartIds.add(partRec.WOD_2__Warranty_Product__c);
                       }       
                    claimIdsForRPDeletion.add(partRec.WOD_2__Claim__c);
                    partIdsForRPDeletion.add(partRec.WOD_2__Warranty_Product__c);
                }
            }
            if(!claimIdsForRPDeletion.isEmpty()){
                List<WOD_2__Removed_Claim_Part__c> removedPartLst = [SELECT Id FROM WOD_2__Removed_Claim_Part__c WHERE WOD_2__Claim__c IN:claimIdsForRPDeletion AND WOD_2__Warranty_Product__c IN:partIdsForRPDeletion AND Id NOT IN:setOfRemovedPartIds];
                if(!removedPartLst.isEmpty()){
                    delete removedPartLst;
                }
            }
        }
    }
    
    //saveRemovedPartsData
    private static void saveRemovedPartsData(){
        if(!remPartList.isEmpty()){
            Database.UpsertResult[] remPartListRes = Database.upsert(remPartList, false);
            for(Integer i=0;i<remPartListRes.size();i++){
                if (!remPartListRes.get(i).isSuccess()){
                    if(!claimIdToErrorStrMap.containsKey(remPartList.get(i).WOD_2__Claim__c)){
                        claimIdToErrorStrMap.put(remPartList.get(i).WOD_2__Claim__c,new List<String>{remPartListRes.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n'});
                    }else{
                        List<String> errList = new List<String>();errList = claimIdToErrorStrMap.get(remPartList.get(i).WOD_2__Claim__c);errList.add(remPartListRes.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n');
                        claimIdToErrorStrMap.put(remPartList.get(i).WOD_2__Claim__c,errList);
                    }
                }
            }
        }
    }
    
    //saveClaimServiceInfoDetails
    private static void saveClaimServiceInfoDetails(){
        if(!laborCodeLst.isEmpty()){
            List<WOD_2.ResponseWrapper> laborResWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimServiceInformations(laborCodeLst);
            for(integer i=0;i<laborResWrapper.size();i++){
                if(!laborResWrapper.get(i).status){
                    WOD_2__Claim_Service_Information__c laborRec = (WOD_2__Claim_Service_Information__c)Json.deserialize(laborResWrapper.get(i).data, WOD_2__Claim_Service_Information__c.class);
                    WOD_2__Claim__c claim = new WOD_2__Claim__c();
                    if(claimMap.containskey(laborRec.WOD_2__Claim__c)){
                        claim = claimMap.get(laborRec.WOD_2__Claim__c);
                    }
                    else if(batchClaimSubResults.claimIdMap.containskey(laborRec.WOD_2__Claim__c)){
                        claim = batchClaimSubResults.claimIdMap.get(laborRec.WOD_2__Claim__c);
                    }
                    string claimKey = claim.ATI_Identifier__c;
                    if(!mapOfFailure.containskey(claimKey)){
                        mapOfFailure.put(claimKey,new List<String>{laborResWrapper.get(i).errormessage+' - '+laborRec.Name+' laborOperationCode'});
                    }
                    else{
                        mapOfFailure.get(claimKey).add(laborResWrapper.get(i).errormessage+' - '+laborRec.Name+' laborOperationCode');
                    }
                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                    claimRelatedInfo.processCode = '99';claimRelatedInfo.processCategoryDescription = 'LaborCodes';claimRelatedInfo.processMessage = laborResWrapper.get(i).errormessage+' - '+laborRec.Name+' laborOperationCode';
                    if(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containsKey(claim.ATI_Identifier__c)){
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.get(claim.ATI_Identifier__c).add(claimRelatedInfo);
                    }else{
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.put(claim.ATI_Identifier__c,new List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>{claimRelatedInfo});
                    }
                }
            }
        } 
    }
    
    //saveOtherCostDetails
    private static void saveOtherCostDetails(){
        if(!otherCostList.isEmpty()){
            List<WOD_2.ResponseWrapper> otherCostResWrapper = WOD_2.CLM_UnmanagedUtility.saveClaimOtherCostData(otherCostList);
            List<WOD_2__Other_Cost__Share> otherCostShareList = new List<WOD_2__Other_Cost__Share>();
            for(integer i=0;i<otherCostResWrapper.size();i++){
                WOD_2__Other_Cost__c otherCostRec = (WOD_2__Other_Cost__c)Json.deserialize(otherCostResWrapper.get(i).data, WOD_2__Other_Cost__c.class);
                WOD_2__Claim__c claim = new WOD_2__Claim__c();
                if(claimMap.containskey(otherCostRec.WOD_2__Claim__c)){
                    claim = claimMap.get(otherCostRec.WOD_2__Claim__c);
                }else if(batchClaimSubResults.claimIdMap.containskey(otherCostRec.WOD_2__Claim__c)){
                    claim = batchClaimSubResults.claimIdMap.get(otherCostRec.WOD_2__Claim__c);
                }
                if(!otherCostResWrapper.get(i).status){
                    string claimKey = claim.ATI_Identifier__c;
                    if(!mapOfFailure.containskey(claimKey)){
                        mapOfFailure.put(claimKey,new List<String>{otherCostResWrapper.get(i).errormessage+' - '+otherCostRec.WOD_2__Cost_Category_Type__c+' netItemType'});
                        
                    }
                    else{
                        mapOfFailure.get(claimKey).add(otherCostResWrapper.get(i).errormessage+' - '+otherCostRec.WOD_2__Cost_Category_Type__c+' netItemType');
                    }
                    ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation claimRelatedInfo = new ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation();
                    claimRelatedInfo.processCode = '99';claimRelatedInfo.processCategoryDescription = 'NetItems';claimRelatedInfo.processMessage = otherCostResWrapper.get(i).errormessage+' - '+otherCostRec.WOD_2__Cost_Category_Type__c+' netItemType';
                    if(batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.containsKey(claim.ATI_Identifier__c)){
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.get(claim.ATI_Identifier__c).add(claimRelatedInfo);
                    }else{
                        batchClaimSubResults.mapOfBatchClaimRelatedErrorInfo.put(claim.ATI_Identifier__c,new List<ATI_REST_BatchClaimSubmttalRespCheck.ClaimRelatedInformation>{claimRelatedInfo});
                    }
                }
                if(claim != null && claim.WOD_2__Account__r.Public_Group_Id__c != null && otherCostRec.id != null) {
                    otherCostShareList.add(
                        new WOD_2__Other_Cost__Share(
                            AccessLevel = 'Edit',
                            ParentId = otherCostRec.id,
                            UserOrGroupId = claim.WOD_2__Account__r.Public_Group_Id__c
                        )
                    );
                }
            }
            if(!otherCostShareList.isEmpty()){
                insert otherCostShareList;
            }
        }                 
    }
    
    //getPartMarkupDetails
    private static void getPartMarkupDetails(){
        List<ATI_Part_Markup__c> partMarkupLst = [SELECT Id,ATI_Part_Markup_Percentage__c,ATI_Claim_Type__c,ATI_Customer_Group_Type__c,
                                                  ATI_Active_From__c,ATI_Active_Until__c
                                                  FROM ATI_Part_Markup__c
                                                  WHERE ATI_Claim_Type__c IN: setOfClaimTypes AND ATI_Active__c = true
                                                  AND ATI_Customer_Group_Type__c IN: setOfAccountTypes
                                                  AND ATI_Active_From__c <=: setOfDateOfFailures
                                                  AND ATI_Active_Until__c >=: setOfDateOfFailures];
        if(!partMarkupLst.isEmpty()){
            for(ATI_Part_Markup__c partMarkup : partMarkupLst){
                if(partMarkUpDataMap.containsKey(partMarkup.ATI_Claim_Type__c+':'+partMarkup.ATI_Customer_Group_Type__c)){
                    partMarkUpDataMap.get(partMarkup.ATI_Claim_Type__c+':'+partMarkup.ATI_Customer_Group_Type__c).add(partMarkup);
                }else{
                    partMarkUpDataMap.put(partMarkup.ATI_Claim_Type__c+':'+partMarkup.ATI_Customer_Group_Type__c,new List<ATI_Part_Markup__c>{partMarkup});
                }
            }
        }
    }
    
    //getLandedCostMarkupDetails
    private static void getLandingCostDetails(){
        List<WOD_2__Rates_Details__c> landingCostRateLst = [SELECT Id,ATI_Landed_Cost_Markup__c,WOD_2__Dealer__c,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c 
                                                            WHERE WOD_2__Dealer__c=:setOfDealerIds
                                                            AND WOD_2__Active_From__c <=:setOfDateOfFailures AND WOD_2__Status__c='Active'
                                                            AND WOD_2__Active_Until__c >=:setOfDateOfFailures 
                                                            AND RecordType.DeveloperName='ATI_Landing_Cost_Rate'];
        if(!landingCostRateLst.isEmpty()){
            for(WOD_2__Rates_Details__c landingCostRate : landingCostRateLst){
                if(landingCostMarkupMap.containsKey(landingCostRate.WOD_2__Dealer__c)){
                    landingCostMarkupMap.get(landingCostRate.WOD_2__Dealer__c).add(landingCostRate);
                }else{
                    landingCostMarkupMap.put(landingCostRate.WOD_2__Dealer__c,new List<WOD_2__Rates_Details__c>{landingCostRate});
                }
            }
        }
    }
    
    //getPartCostDetails
    private static void getPartCostDetails(){
        List<WOD_2__Warranty_Product_Pricebook__c> wpPriceBookLst = [SELECT Id,WOD_2__Price__c,WOD_2__Warranty_Product__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c FROM WOD_2__Warranty_Product_Pricebook__c 
                                                                     WHERE WOD_2__Warranty_Product__c IN : setOfPartIds
                                                                     AND WOD_2__Valid_From__c <=: setOfDateOfFailures AND ATI_Active__c=true
                                                                     AND WOD_2__Valid_Until__c >=: setOfDateOfFailures 
                                                                     AND RecordType.DeveloperName='ATI_Part_Cost'];
        if(!wpPriceBookLst.isEmpty()){
            for(WOD_2__Warranty_Product_Pricebook__c wpPriceBook : wpPriceBookLst){
                if(partCostMap.containsKey(wpPriceBook.WOD_2__Warranty_Product__c)){
                    partCostMap.get(wpPriceBook.WOD_2__Warranty_Product__c).add(wpPriceBook);
                }else{
                    partCostMap.put(wpPriceBook.WOD_2__Warranty_Product__c,new List<WOD_2__Warranty_Product_Pricebook__c>{wpPriceBook});
                }
            }
        }
    }
    
    //getFinancialLineItemsForUpdate
    private static void getFinancialLineItemsForUpdate(){// ALSN-101 added WOD_2__Claim__r.ATI_Claim_Subtype__c
        List<WOD_2__Financial_Line_Item__c> fliLst = [SELECT Id,ATI_Markup__c,WOD_2__Claim__r.ATI_Claim_Subtype__c,WOD_2__Claim__r.WOD_2__Claim_Type__c,WOD_2__Claim__r.WOD_2__Account__c,WOD_2__Claim__r.WOD_2__Account__r.Type,WOD_2__Claim__r.WOD_2__Date_Of_Failure__c,WOD_2__Claim__r.WOD_2__Model_Number__r.Part_Markup_Percentage__c,WOD_2__Claim__r.WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c,WOD_2__Claim__r.WOD_2__Account__r.ATI_Customer_Group__c,WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Part_Markup_Percentage__c,
                                                      WOD_2__Claim__r.ATI_Exchange_Rate__c,WOD_2__Installed_Claim_Part__c,WOD_2__Total_Approved_Amt__c,ATI_Total_Approved_Amount_in_USD__c,WOD_2__Total_Requested_Amount__c,ATI_Total_Requested_Amount_In_USD__c,ATI_Total_Requested_Amount_USD__c,ATI_Landed_Part_Markup__c,ATI_Factory_Price__c,WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__c,WOD_2__Percentage_Amount__c,ATI_Factory_Cost__c,WOD_2__Requested_Quantity__c FROM WOD_2__Financial_Line_Item__c WHERE WOD_2__Claim__c IN:claimMap.keySet()];
        
        Integer allowedDecimalPlaces = 4;
        for(WOD_2__Financial_Line_Item__c fli : fliLst){
            fli.ATI_Total_Requested_Amount_USD__c = getValue(fli.ATI_Total_Requested_Amount_In_USD__c,2);
            fli.ATI_Total_Approved_Amount_in_USD__c = fli.WOD_2__Total_Approved_Amt__c;
            fli.ATI_Markup__c = 0;
            fli.ATI_Landed_Part_Markup__c = 0;
            //ALSN-03 added getValue method calculation
            if(fli.WOD_2__Installed_Claim_Part__c != null){
                if(fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Part_Markup_Percentage__c != null){
                    fli.ATI_Markup__c = getValue((fli.WOD_2__Total_Requested_Amount__c*fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Part_Markup_Percentage__c/100),allowedDecimalPlaces);
                }  //ALSN-101
                else if (fli.WOD_2__Claim__r.WOD_2__Claim_Type__c.trim().equalsIgnoreCase('Campaign') && partMarkUpDataMap != null && !partMarkUpDataMap.isEmpty() && partMarkUpDataMap.containsKey(fli.WOD_2__Claim__r.ATI_Claim_Subtype__c+':'+fli.WOD_2__Claim__r.WOD_2__Account__r.ATI_Customer_Group__c)){
                        List<ATI_Part_Markup__c> partMarkupLst = partMarkUpDataMap.get(fli.WOD_2__Claim__r.ATI_Claim_Subtype__c+':'+fli.WOD_2__Claim__r.WOD_2__Account__r.ATI_Customer_Group__c);
                        for(ATI_Part_Markup__c partMarkup : partMarkupLst){
                            if(partMarkup.ATI_Active_From__c <= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c && partMarkup.ATI_Active_Until__c >= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c){
                                fli.ATI_Markup__c = getValue((fli.WOD_2__Total_Requested_Amount__c*partMarkup.ATI_Part_Markup_Percentage__c/100),allowedDecimalPlaces);
                            }
                        }
                    }
                    else{
                    if(partMarkUpDataMap.containsKey(fli.WOD_2__Claim__r.WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c+':'+fli.WOD_2__Claim__r.WOD_2__Account__r.ATI_Customer_Group__c)){
                        List<ATI_Part_Markup__c> partMarkupLst = partMarkUpDataMap.get(fli.WOD_2__Claim__r.WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c+':'+fli.WOD_2__Claim__r.WOD_2__Account__r.ATI_Customer_Group__c);
                        for(ATI_Part_Markup__c partMarkup : partMarkupLst){
                            if(partMarkup.ATI_Active_From__c <= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c && partMarkup.ATI_Active_Until__c >= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c){
                                fli.ATI_Markup__c = getValue((fli.WOD_2__Total_Requested_Amount__c*partMarkup.ATI_Part_Markup_Percentage__c/100),allowedDecimalPlaces);
                            }
                        }
                    }
                }
                if(landingCostMarkupMap.containsKey(fli.WOD_2__Claim__r.WOD_2__Account__c)){
                    List<WOD_2__Rates_Details__c> rateDetailsLst = landingCostMarkupMap.get(fli.WOD_2__Claim__r.WOD_2__Account__c);
                    for(WOD_2__Rates_Details__c rateDetail : rateDetailsLst){
                        if(rateDetail.WOD_2__Active_From__c <= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c && rateDetail.WOD_2__Active_Until__c >= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c){
                            fli.ATI_Landed_Part_Markup__c = getValue((fli.WOD_2__Total_Requested_Amount__c*rateDetail.ATI_Landed_Cost_Markup__c/100),allowedDecimalPlaces);
                        }
                    }
                }
                if(partCostMap.containsKey(fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__c)){
                    List<WOD_2__Warranty_Product_Pricebook__c> wpPriceBookLst = partCostMap.get(fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__c);
                    for(WOD_2__Warranty_Product_Pricebook__c wpPriceBook : wpPriceBookLst){
                        if(wpPriceBook.WOD_2__Valid_From__c <= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c && wpPriceBook.WOD_2__Valid_Until__c >= fli.WOD_2__Claim__r.WOD_2__Date_Of_Failure__c){
                            fli.ATI_Factory_Price__c = wpPriceBook.WOD_2__Price__c;
                        }
                    }
                    if(fli.ATI_Factory_Price__c != NULL && fli.WOD_2__Requested_Quantity__c != NULL){
                        fli.ATI_Factory_Cost__c = fli.ATI_Factory_Price__c * fli.WOD_2__Requested_Quantity__c;Decimal approvedPercentage = fli.WOD_2__Percentage_Amount__c == null ? 100.0 : fli.WOD_2__Percentage_Amount__c;fli.ATI_Factory_Cost__c = fli.ATI_Factory_Cost__c * approvedPercentage/100;
                    }
                }
                if(fli.WOD_2__Total_Requested_Amount__c != NULL && fli.WOD_2__Claim__r.ATI_Exchange_Rate__c != NULL){
                    fli.WOD_2__Total_Requested_Amount__c = getValue((fli.WOD_2__Total_Requested_Amount__c + fli.ATI_Markup__c + fli.ATI_Landed_Part_Markup__c),allowedDecimalPlaces);
                    fli.ATI_Total_Requested_Amount_USD__c =  getValue((fli.WOD_2__Total_Requested_Amount__c * fli.WOD_2__Claim__r.ATI_Exchange_Rate__c),2);
                }
            }
            fliUpdateList.add(fli);
        }
    }
    
    //getFinancialDetailsForUpdate
    private static void getFinancialDetailsForUpdate(){
        List<WOD_2__Financial__c> financialLst = [SELECT Id,WOD_2__Claim__c,ATI_Total_Approved_Amount_in_USD__c,ATI_Total_Requested_Amount_In_USD__c FROM WOD_2__Financial__c WHERE WOD_2__Claim__c IN:claimMap.keySet() AND ATI_Total_Requested_Amount_In_USD__c != null AND ATI_Total_Approved_Amount_in_USD__c != null];
        for(WOD_2__Financial__c financialRec :  financialLst) {
            WOD_2__Claim__c claim = claimMap.get(financialRec.WOD_2__Claim__c);
            if(financialRec.ATI_Total_Approved_Amount_in_USD__c != null){
                claim.ATI_Total_Approved_Amount__c = financialRec.ATI_Total_Approved_Amount_in_USD__c;
            }
            if(financialRec.ATI_Total_Requested_Amount_In_USD__c != null){
                claim.ATI_Total_Requested_Amount__c = financialRec.ATI_Total_Requested_Amount_In_USD__c;
            }
            claimUpdateLst.add(claim);
        }
    }
    
    //ValidateClaimBURules
    public static Map<Id,List<String>> validateClaimBURules(Map<Id, WOD_2__Claim__c> newClaimMap,String subModule){
        List<WOD_2__Business_Rule__c> burRulesTriggeredLst = 
            ATI_BURulesService.runBURules(newClaimMap.values()[0].WOD_2__BusinessCategory__c,'WOD_2__Claim__c',new List<Id>(newClaimMap.keySet()),
                                          'Claim',subModule);
        Map<Id,List<String>> claimIdToErrorStrMap = new Map<Id,List<String>>();
        for(WOD_2__Business_Rule__c buRuleObj :burRulesTriggeredLst){
            if(buRuleObj.WOD_2__Error_Type__c =='Hard' && buRuleObj.WOD_2__Message__c != NULL){
                if(!claimIdToErrorStrMap.containsKey(buRuleObj.WOD_2__Claim__c)){
                    claimIdToErrorStrMap.put(buRuleObj.WOD_2__Claim__c,new List<String>{buRuleObj.WOD_2__Message__c});
                }else{
                    List<String> errList= new List<String>();errList=claimIdToErrorStrMap.get(buRuleObj.WOD_2__Claim__c);errList.add(', '+buRuleObj.WOD_2__Message__c);claimIdToErrorStrMap.put(buRuleObj.WOD_2__Claim__c,errList);
                }
            }
        }
        return claimIdToErrorStrMap;
    }
    
    //ALSN-03
    private static Decimal getValue(Decimal origValue, Integer allowedDecimalPlaces){
        Decimal returnValue = origValue;
        returnValue = returnValue.setScale(allowedDecimalPlaces,RoundingMode.HALF_UP);
        return returnValue;
    }
    
    public class BatchClaimSubmittalWrapper{
        public Map<String,WOD_2__Claim__c> mapOfInsertedOrUpdatedClaims;
        public Map<String,List<String>> mapOfFailure;
        public List<WOD_2__Claim__c> claimSubmitList;
        public Map<string,string> claimIdKeyMap;
    }
}