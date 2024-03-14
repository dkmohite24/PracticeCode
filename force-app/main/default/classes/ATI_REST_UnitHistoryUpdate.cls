/* Name: ATI_REST_UnitHistoryUpdate
Description : ATI_REST_UnitHistoryUpdate - callout to push unit history details
History:
VERSION     AUTHOR               DATE                  DETAIL             UserStory/Req#
1.0 -     Tavant(TY)          Mar 15th 2021      INITIAL DEVELOPMENT
*/
global with sharing class ATI_REST_UnitHistoryUpdate {
    public static Set<Id> unitHistoryUpdateRestCall(Set<Id> inventoryIds,DateTime dt){
        //System.debug('inventoryIds>>>> '+inventoryIds);
        ATI_REST_UnitHistoryUpdateResponse unitHistoryUpdateResp = new ATI_REST_UnitHistoryUpdateResponse();
        try{
            String endpointUrl =  ATI_GetEndpoint.getURL('Unit History Update');
            String invSObjName = 'WOD_2__Inventory__c';
            List<String> invFields = new List<String>{'Name','WOD_2__Serial_Number__c','ATI_Vocation_Code__c','ATI_Vocation_Code__r.Name','ATI_Program_Level__c','WOD_2__Customer__c','WOD_2__Customer__r.Name','WOD_2__Customer__r.BillingStreet',
                'WOD_2__Customer__r.BillingState','WOD_2__Customer__r.BillingCountry','WOD_2__Customer__r.BillingPostalCode','WOD_2__Customer__r.BillingCity'};
                    ATI_Utils.NoAccessObjectFieldWrapper invNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(invSObjName,invFields);
            if(invNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && invNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                List<WOD_2__Inventory__c> invLst = [SELECT Id,Name,WOD_2__Serial_Number__c,ATI_Vocation_Code__c,ATI_Vocation_Code__r.Name,ATI_Program_Level__c,WOD_2__Install_Date__c,WOD_2__Customer__c,
                                                    WOD_2__Customer__r.Name,WOD_2__Customer__r.BillingStreet,WOD_2__Customer__r.BillingState,WOD_2__Customer__r.BillingCountry,
                                                    WOD_2__Customer__r.BillingPostalCode,WOD_2__Customer__r.BillingCity,
                                                    (SELECT Id,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Customer_asset_number__c FROM Transmissions__r WHERE LastModifiedDate>=:dt ORDER BY CreatedDate ASC LIMIT 1),
                                                    (SELECT Id,Name,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__r WHERE WOD_2__Status__c='Registered' AND LastModifiedDate>=:dt)
                                                    FROM WOD_2__Inventory__c WHERE Id IN:inventoryIds];
               List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Warranty_Registration__r.WOD_2__Inventory__c,WOD_2__Policy_Definition__r.Name,WOD_2__Policy_Definition__r.WOD_2__Priority__c,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Is_Active__c=TRUE AND WOD_2__Policy_Definition__r.WOD_2__Status__c='Active' AND (WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Standard' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Supplemental Coverage') AND WOD_2__Warranty_Registration__r.WOD_2__Status__c='Registered' AND WOD_2__Warranty_Registration__r.WOD_2__Inventory__c IN:inventoryIds AND LastModifiedDate>=:dt ORDER BY WOD_2__Policy_Definition__r.WOD_2__Priority__c ASC];
               Map<Id,List<WOD_2__Warranty_Coverages__c>> mapOfInvWithWcs = new Map<Id,List<WOD_2__Warranty_Coverages__c>>();
                if(!wcLst.isEmpty()){
                    for(WOD_2__Warranty_Coverages__c wc : wcLst){
                        if(mapOfInvWithWcs.containsKey(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c)){
                            mapOfInvWithWcs.get(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c).add(wc);
                        }else{
                            mapOfInvWithWcs.put(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c,new List<WOD_2__Warranty_Coverages__c>{wc});
                        }
                    }
                }
                ATI_REST_UnitHistoryUpdateRequest unitHistorUpdateReq = new ATI_REST_UnitHistoryUpdateRequest();
                List<ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE> unitHistoryDetailsLst = new List<ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE>();
                ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE unitHistoryInfo = new ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_TRANS_HISTORY> invDataDetailsLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_TRANS_HISTORY>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT> bomReplaceComponentsLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS> bomCampaignsLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL> bomCampaignsToSerialLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES> bomCoveragesLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY> bomMessageCopyLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY>();
                List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES> bomMessagesLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES>();
                for(WOD_2__Inventory__c inv:invLst){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_TRANS_HISTORY invData = new ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_TRANS_HISTORY();
                    invData.serialNumber = inv.WOD_2__Serial_Number__c;
                    if(inv.WOD_2__Install_Date__c != null){
                        invData.customerDeliveryDate = String.valueOf(inv.WOD_2__Install_Date__c);
                    }
                    if(inv.ATI_Vocation_Code__c != null){
                        invData.vocationCode = inv.ATI_Vocation_Code__r.Name;
                    }
                    if(!inv.Transmissions__r.isEmpty()){
                        invData.vin = inv.Transmissions__r.get(0).ATI_Vehicle_Information__r.Name;
                        if(inv.Transmissions__r.get(0).ATI_Vehicle_Information__r.ATI_Customer_asset_number__c != null){
                            invData.assetNumber = inv.Transmissions__r.get(0).ATI_Vehicle_Information__r.ATI_Customer_asset_number__c;
                        }
                    }
                    if(inv.WOD_2__Customer__c != null){
                        invData.endCustomerName = inv.WOD_2__Customer__r.Name;
                        if(inv.WOD_2__Customer__r.BillingStreet != null){
                            invData.endCustomerStreet = inv.WOD_2__Customer__r.BillingStreet;
                        }
                        if(inv.WOD_2__Customer__r.BillingCity  != null){
                            invData.endCustomerCity = inv.WOD_2__Customer__r.BillingCity;
                        }
                        if(inv.WOD_2__Customer__r.BillingState != null){
                            invData.EndCustomerState = inv.WOD_2__Customer__r.BillingState;
                        }
                        if(inv.WOD_2__Customer__r.BillingCountry != null){
                            invData.EndCustomerCountry = inv.WOD_2__Customer__r.BillingCountry;
                        }
                        if(inv.WOD_2__Customer__r.BillingPostalCode != null){
                            invData.EndCustomerZip = inv.WOD_2__Customer__r.BillingPostalCode;
                        }
                    }
                    if(inv.ATI_Program_Level__c != null){
                        invData.currentProgramLevel = inv.ATI_Program_Level__c;
                    }
                    if(mapOfInvWithWcs.containsKey(inv.id)){
                        Decimal priority;
                        for(WOD_2__Warranty_Coverages__c wcs : mapOfInvWithWcs.get(inv.id)){
                            if(wcs.WOD_2__Policy_Definition__r.WOD_2__Type__c.equalsIgnoreCase('Standard') && invData.warrantyCode == ''){
                                invData.warrantyCode = wcs.WOD_2__Policy_Definition__r.Name;
                            }
                            if(wcs.WOD_2__Policy_Definition__r.WOD_2__Type__c.equalsIgnoreCase('Extended') && invData.etcCode == ''){
                                invData.etcCode = wcs.WOD_2__Policy_Definition__r.Name;
                            }
                        }
                    }
                    invDataDetailsLst.add(invData);
                    unitHistoryInfo.bomAwaareTransHistory = invDataDetailsLst;
                    unitHistoryInfo.bomAwaareReplaceComponent = bomReplaceComponentsLst;
                    unitHistoryInfo.bomCampaigns = bomCampaignsLst;
                    unitHistoryInfo.bomCampaignsToSerial = bomCampaignsToSerialLst;
                    unitHistoryInfo.bomAwaareMessageCopy = bomMessageCopyLst;
                    unitHistoryInfo.bomAwaareMessages = bomMessagesLst;
                    unitHistoryInfo.bomAwaareCoverages = bomCoveragesLst;
                    unitHistoryDetailsLst.add(unitHistoryInfo);
                    System.debug('Request For UnitHistoryUpdate>>> '+unitHistoryDetailsLst);
                    if(!invDataDetailsLst.isEmpty()){
                        unitHistorUpdateReq.unitHistoryUpdate = unitHistoryDetailsLst;
                        String jsonBody = JSON.serialize(unitHistorUpdateReq);
                        //Http call to end point
                        Integer randomNumber = Integer.valueof((Math.random() * 100));
                        
                        ATI_HttpRequestParameter httpReqparm = new ATI_HttpRequestParameter();
                        httpReqparm.endPoint = endpointUrl;
                        httpReqparm.httpMethod = ATI_UtilConstants.i203Method;
                        httpReqparm.httpHeaderReqId=ATI_UtilConstants.httpHeaderReqId;
                        httpReqparm.httpHeaderReqValue=String.valueOf(randomNumber);
                        httpReqparm.httpHeaderClientId=ATI_UtilConstants.httpHeaderClientId;
                        httpReqparm.httpHeaderClientIdValue=ATI_UtilConstants.httpHeaderClientIdValue;
                        httpReqparm.httpHeaderClientSecret=ATI_UtilConstants.httpHeaderClientSecret;
                        httpReqparm.httpHeaderClientSecretValue=ATI_UtilConstants.httpHeaderClientSecretValue;
                        httpReqparm.httpBody = jsonBody;
                        
                        HttpRequest httpReq = ATI_RESTUtility.buildHttpRequest(httpReqparm);
                        HttpResponse response = ATI_RESTUtility.executeService(httpReq);
                        System.debug('Response For UnitHistoryUpdate>>> '+response);
                        unitHistoryUpdateResp.statusCode = String.valueOf(response.getStatusCode());
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        List<Object> objLst = (List<Object>)results.get('errors');
                        if(response.getStatusCode() == Integer.valueOf(ATI_Accounts_Receivable_Interface__c.getValues('Status Code').ATI_Values__c)
                          && objLst.isEmpty()){
                            unitHistoryUpdateResp.message = 'Success';
                            createLog('UnitHistoryUpdate',jsonBody,JSON.serialize(unitHistoryUpdateResp),'Success',null);
                            return inventoryIds;
                        }else{
                            if(!objLst.isEmpty()){
                                unitHistoryUpdateResp.message = JSON.serialize(objLst);
                            }else{
                                unitHistoryUpdateResp.message = response.getStatus();
                            }
                            createLog('UnitHistoryUpdate',jsonBody,JSON.serialize(unitHistoryUpdateResp),'Failed',null);
                        }
                    }
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(invNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
        }Catch(Exception e) {
            System.debug('errormessage>>> '+e.getMessage()+ ' : '+e.getLineNumber());
            unitHistoryUpdateResp.statusCode = '500';
            unitHistoryUpdateResp.message = 'Failed';
            createLog('UnitHistoryUpdate',null,JSON.serialize(unitHistoryUpdateResp),'Failed',e.getMessage()+e.getStackTraceString());
        }
        return null;
    }
    
    public static void unitHistoryUpdateForMasterData(DateTime dt){
        try{
            ATI_REST_UnitHistoryUpdateRequest unitHistorUpdateReq = new ATI_REST_UnitHistoryUpdateRequest();
            List<ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE> unitHistoryDetailsLst = new List<ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE>();
            ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE unitHistoryInfo = new ATI_REST_UnitHistoryUpdateRequest.UNIT_HISTORY_UPDATE();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY> bomMessageCopyLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY>();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES> bomMessagesLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES>();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS> bomCampaignsLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS>();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT> bomReplaceComponentsLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT>();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL> bomCampaignsToSerialLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL>();
            List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES> bomCoveragesLst = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES>();
            unitHistoryInfo.bomAwaareTransHistory = new List<ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_TRANS_HISTORY>();
            List<WOD_2__Policy_Definition__c> policyDefLst = new List<WOD_2__Policy_Definition__c>();
            List<WOD_2__Major_Component__c> majorCmpUpdateLst = new List<WOD_2__Major_Component__c>();
            List<twodcms__Member_Template_Association__c> memberTempUpdateLst = new List<twodcms__Member_Template_Association__c>();
            List<twodcms__Service_Campaign__c> serviceCampaignUpdateLst = new List<twodcms__Service_Campaign__c>();
            List<WOD_2__Warranty_Code__c> disCodeUpdateLst = new List<WOD_2__Warranty_Code__c>();
            List<ATI_Disposition_Code_Mapper__c> disCodeMapperUpdateLst = new List<ATI_Disposition_Code_Mapper__c>();
            Map<String,WOD_2__Major_Component__c> mapOfSerialNumberWithMajorCmp = new Map<String,WOD_2__Major_Component__c>();
            String policyDefSObjName = 'WOD_2__Policy_Definition__c';
            List<String> policyDefFields = new List<String>{'Name','ATI_IsSynced__c','WOD_2__Type__c','WOD_2__Description__c'};
                ATI_Utils.NoAccessObjectFieldWrapper policyDefNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(policyDefSObjName,policyDefFields);
            if(policyDefNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && policyDefNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(WOD_2__Policy_Definition__c policyDef : [SELECT Id,Name,WOD_2__Type__c,ATI_IsSynced__c,WOD_2__Description__c FROM WOD_2__Policy_Definition__c WHERE ATI_IsSynced__c=false AND CreatedDate>=:dt AND WOD_2__Status__c='Active']){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES bomCoverages = new ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_COVERAGES();
                    bomCoverages.coverage = policyDef.Name;
                    bomCoverages.coverageType = policyDef.WOD_2__Type__c;
                    if(policyDef.WOD_2__Description__c != null){
                        bomCoverages.coverageDescription = policyDef.WOD_2__Description__c;
                    }
                    bomCoveragesLst.add(bomCoverages);
                    policyDef.ATI_IsSynced__c = true;
                    policyDefLst.add(policyDef);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(policyDefNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
            String memTempSObjName = 'twodcms__Member_Template_Association__c';
            List<String> memTempFields = new List<String>{'ATI_IsSynced__c','twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.Name','twodcms__Claim__r.WOD_2__Inventory__r.Name'};
                ATI_Utils.NoAccessObjectFieldWrapper memTempNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(memTempSObjName,memTempFields);
            if(memTempNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && memTempNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(twodcms__Member_Template_Association__c memberTempAssociation : [SELECT Id,Name,twodcms__Claim__r.WOD_2__Inventory__r.Name,twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.Name,ATI_IsSynced__c,LastModifiedDate FROM twodcms__Member_Template_Association__c WHERE twodcms__Campaign_Members__c != null AND twodcms__Claim__c != null AND twodcms__Claim__r.WOD_2__Claim_Status__c = 'Approved' AND ATI_IsSynced__c=false AND LastModifiedDate>=:dt]){
                    if(memberTempAssociation.twodcms__Campaign_Members__r.twodcms__Service_Campaign__c != null && memberTempAssociation.twodcms__Claim__r.WOD_2__Inventory__c != null){
                        ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL bomCampaignToSerial = new ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNSTOSERIAL();
                        bomCampaignToSerial.campaignCodeRequired = memberTempAssociation.twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.Name;
                        bomCampaignToSerial.serialNumber = memberTempAssociation.twodcms__Claim__r.WOD_2__Inventory__r.Name;
                        bomCampaignToSerial.campaignCodeCompleteDate = String.valueOf(Date.valueOf(memberTempAssociation.LastModifiedDate));
                        bomCampaignsToSerialLst.add(bomCampaignToSerial);
                        memberTempAssociation.ATI_IsSynced__c = true;
                        memberTempUpdateLst.add(memberTempAssociation);
                    }
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(memTempNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
            Set<String> serialNumberSet = new Set<String>();
            for(WOD_2__Claim_Part__c claimPart : [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Warranty_Product__c,WOD_2__Claim__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Claim__r.WOD_2__Date_Of_Failure__c FROM WOD_2__Claim_Part__c WHERE WOD_2__Warranty_Product__r.WOD_2__Track_Type__c = 'Serialized' AND WOD_2__Serial_Number__c != null AND WOD_2__Claim__c != null AND CreatedDate>=:dt]){
                serialNumberSet.add(claimPart.WOD_2__Serial_Number__c);
            }
            if(!serialNumberSet.isEmpty()){
                for(WOD_2__Major_Component__c majorCmp : [SELECT Id,ATI_Type__c,WOD_2__Warranty_Product__c,WOD_2__Serial_number__c,
                                                          		 WOD_2__Inventory__r.Name,LastModifiedDate,WOD_2__Warranty_Product__r.WOD_2__Description__c
                                                          	FROM WOD_2__Major_Component__c 
                                                          	WHERE WOD_2__Serial_number__c IN:serialNumberSet AND WOD_2__Inventory__c != null 
                                                          		  AND ATI_IsSynced__c=false AND LastModifiedDate>=:dt]){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT bomReplaceCmp = new ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_REPLACECOMPONENT();
                    bomReplaceCmp.replaceComponentSerial = majorCmp.WOD_2__Serial_number__c;
                    bomReplaceCmp.replaceComponentType = majorCmp.WOD_2__Warranty_Product__r.WOD_2__Description__c != NULL ? majorCmp.WOD_2__Warranty_Product__r.WOD_2__Description__c:'';
                    bomReplaceCmp.serialNumber = majorCmp.WOD_2__Inventory__r.Name;
                    bomReplaceCmp.replCompSNRODate = String.valueOf(Date.valueOf(majorCmp.LastModifiedDate));
                    bomReplaceComponentsLst.add(bomReplaceCmp);
                    majorCmp.ATI_IsSynced__c = true;
                    majorCmpUpdateLst.add(majorCmp);
                }
            }
            String campaignMemberSObjName = 'twodcms__Service_Campaign__c';
            List<String> campaignMemberFields = new List<String>{'Name','twodcms__Campaign_Description__c','ATI_IsSynced__c'};
                ATI_Utils.NoAccessObjectFieldWrapper campaignMemNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(campaignMemberSObjName,campaignMemberFields);
            if(campaignMemNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && campaignMemNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(twodcms__Service_Campaign__c serviceCampaign : [SELECT Id,Name,twodcms__Campaign_Description__c,ATI_IsSynced__c FROM twodcms__Service_Campaign__c WHERE ATI_IsSynced__c=false AND twodcms__Status__c='Active' AND LastModifiedDate>=:dt]){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS bomCampaigns = new ATI_REST_UnitHistoryUpdateRequest.BOM_CAMPAIGNS();
                    bomCampaigns.campaignCodeRequired = serviceCampaign.Name;
                    if(serviceCampaign.twodcms__Campaign_Description__c != null){
                        bomCampaigns.description = serviceCampaign.twodcms__Campaign_Description__c;
                    }
                    bomCampaignsLst.add(bomCampaigns);
                    serviceCampaign.ATI_IsSynced__c = true;
                    serviceCampaignUpdateLst.add(serviceCampaign);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(campaignMemNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
            String warrantyCodeObjName = 'WOD_2__Warranty_Code__c';
            List<String> warrantyCodeSObjFields = new List<String>{'Name','WOD_2__Description__c','ATI_IsSynced__c'};
                ATI_Utils.NoAccessObjectFieldWrapper warrantyCodeNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(warrantyCodeObjName,warrantyCodeSObjFields);
            if(warrantyCodeNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && warrantyCodeNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(WOD_2__Warranty_Code__c warrantyCode : [SELECT Id,Name,WOD_2__Description__c,ATI_IsSynced__c FROM WOD_2__Warranty_Code__c WHERE RecordType.DeveloperName='ATI_Disposition_Codes' AND ATI_IsSynced__c = false AND CreatedDate>=:dt]){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY bomMessageCopy = new ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGE_COPY();
                    bomMessageCopy.dispositionCodeId = warrantyCode.Name;
                    if(warrantyCode.WOD_2__Description__c != null){
                        bomMessageCopy.dispositionMessage = warrantyCode.WOD_2__Description__c;
                    }
                    bomMessageCopyLst.add(bomMessageCopy);
                    warrantyCode.ATI_IsSynced__c = true;
                    disCodeUpdateLst.add(warrantyCode);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(warrantyCodeNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
            String dispositionCodeMapperObjName = 'ATI_Disposition_Code_Mapper__c';
            List<String> dispositionCodeMapperFields = new List<String>{'ATI_Inventory__r.Name','ATI_Warranty_Code__r.Name','ATI_Active__c','ATI_IsSynced__c'};
                ATI_Utils.NoAccessObjectFieldWrapper disCodeMapperNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(dispositionCodeMapperObjName,dispositionCodeMapperFields);
            if(disCodeMapperNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && disCodeMapperNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                for(ATI_Disposition_Code_Mapper__c dispositionCodeMapper : [SELECT Id,ATI_Warranty_Code__r.Name,ATI_Inventory__r.Name,ATI_Active__c,ATI_IsSynced__c FROM ATI_Disposition_Code_Mapper__c WHERE ATI_IsSynced__c=false AND CreatedDate>=:dt]){
                    ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES bomMessages = new ATI_REST_UnitHistoryUpdateRequest.BOM_AWAARE_MESSAGES();
                    bomMessages.dispositionCodeId = dispositionCodeMapper.ATI_Warranty_Code__r.Name;
                    bomMessages.serialNumber = dispositionCodeMapper.ATI_Inventory__r.Name;
                    if(!dispositionCodeMapper.ATI_Active__c){
                        bomMessages.updateDelete = 'D';
                    }else{
                        bomMessages.updateDelete = 'U';
                    }
                    bomMessagesLst.add(bomMessages);
                    dispositionCodeMapper.ATI_IsSynced__c = true;
                    disCodeMapperUpdateLst.add(dispositionCodeMapper);
                }
            }else{
                String errortext = Label.ATI_Log_Insufficient_access+' >>> '+JSON.serialize(disCodeMapperNoAccessObjectFieldWrapper);
                ATI_LogService.createLogForAccess('UnitHistoryUpdate',errortext);
            }
            unitHistoryInfo.bomCampaignsToSerial = bomCampaignsToSerialLst;
            unitHistoryInfo.bomAwaareReplaceComponent = bomReplaceComponentsLst;
            unitHistoryInfo.bomCampaigns = bomCampaignsLst;
            unitHistoryInfo.bomAwaareMessageCopy = bomMessageCopyLst;
            unitHistoryInfo.bomAwaareMessages = bomMessagesLst;
            unitHistoryInfo.bomAwaareCoverages = bomCoveragesLst;
            unitHistoryDetailsLst.add(unitHistoryInfo);
            System.debug('Request For Disposition Codes>>> '+unitHistoryDetailsLst);
            if(!bomMessagesLst.isEmpty() || !bomMessageCopyLst.isEmpty() || !bomCampaignsLst.isEmpty()
               || !bomCampaignsToSerialLst.isEmpty() || !bomReplaceComponentsLst.isEmpty()
               || !bomCoveragesLst.isEmpty()){
                ATI_REST_UnitHistoryUpdateResponse unitHistoryUpdateResp = new ATI_REST_UnitHistoryUpdateResponse();
                String endpointUrl =  ATI_GetEndpoint.getURL('Unit History Update');
                unitHistorUpdateReq.unitHistoryUpdate = unitHistoryDetailsLst;
                String jsonBody = JSON.serialize(unitHistorUpdateReq);
                //Http call to end point
                Integer randomNumber = Integer.valueof((Math.random() * 100));
                
                ATI_HttpRequestParameter httpReqparm = new ATI_HttpRequestParameter();
                httpReqparm.endPoint = endpointUrl;
                httpReqparm.httpMethod = ATI_UtilConstants.i203Method;
                httpReqparm.httpHeaderReqId = ATI_UtilConstants.httpHeaderReqId;
                httpReqparm.httpHeaderReqValue = String.valueOf(randomNumber);
                httpReqparm.httpHeaderClientId = ATI_UtilConstants.httpHeaderClientId;
                httpReqparm.httpHeaderClientIdValue = ATI_UtilConstants.httpHeaderClientIdValue;
                httpReqparm.httpHeaderClientSecret = ATI_UtilConstants.httpHeaderClientSecret;
                httpReqparm.httpHeaderClientSecretValue = ATI_UtilConstants.httpHeaderClientSecretValue;
                httpReqparm.httpBody = jsonBody;
                HttpRequest httpReq = ATI_RESTUtility.buildHttpRequest(httpReqparm);
                HttpResponse response = ATI_RESTUtility.executeService(httpReq);
                System.debug('Response For Disposition Codes>>> '+response);
                unitHistoryUpdateResp.statusCode = String.valueOf(response.getStatusCode());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> objLst = (List<Object>)results.get('errors');
				if(response.getStatusCode() == Integer.valueOf(ATI_Accounts_Receivable_Interface__c.getValues('Status Code').ATI_Values__c)
                  && objLst.isEmpty()){
                    unitHistoryUpdateResp.message = 'Success';
                    if(!policyDefLst.isEmpty()){
                        update policyDefLst;
                    }
                    if(!majorCmpUpdateLst.isEmpty()){
                        update majorCmpUpdateLst;
                    }
                    if(!memberTempUpdateLst.isEmpty()){
                        update memberTempUpdateLst;
                    }
                    if(!serviceCampaignUpdateLst.isEmpty()){
                        update serviceCampaignUpdateLst;
                    }
                    if(!disCodeUpdateLst.isEmpty()){
                        update disCodeUpdateLst;
                    }
                    if(!disCodeMapperUpdateLst.isEmpty()){
                        update disCodeMapperUpdateLst;
                    }
                    createLog('UnitHistoryUpdate',jsonBody,JSON.serialize(unitHistoryUpdateResp),'Success',null);
                }else{
                    if(!objLst.isEmpty()){
                        unitHistoryUpdateResp.message = JSON.serialize(objLst);
                    }else{
                        unitHistoryUpdateResp.message = response.getStatus();
                    }
                    createLog('UnitHistoryUpdate',jsonBody,JSON.serialize(unitHistoryUpdateResp),'Failed',null);
                }
            }
        }Catch(Exception e) {
            System.debug('errormessage>>> '+e.getMessage()+ ' : '+e.getLineNumber());
            createLog('UnitHistoryUpdate',null,null,'Failed',e.getMessage()+e.getStackTraceString());
        }
    }
    
    public static void createLog(String processName, String request, String response, String status, String errormsg){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_UnitHistoryUpdate_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            if(errormsg != null){
                objLogSerWrp.errortext = errormsg;
            }
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    /************************************************************************
	Description    :   A wrapper class to capture the CustomerMaster Rest data.
	*************************************************************************/
    global class ATI_REST_UnitHistoryUpdateResponse{
        public String statusCode;
        public String message;
    }
}