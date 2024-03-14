/* Name: ATI_CLM_ClaimBaseOverrideHook
Description : ATI_CLM_ClaimBaseOverrideHook for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     13-JAN-2021        INITIAL DEVELOPMENT
*/

global class ATI_CLM_ClaimBaseOverrideHook extends WOD_2.CLM_ClaimBaseOverrideHook{
    public static List<String> turnAroundErrLst =  new List<String>();
    global override WOD_2.ResponseWrapper beforeInstalledPartSave(List<WOD_2__Claim_Part__c> installedPartList) {
        System.debug('>>> installedPartList'+ installedPartList);
        WOD_2.ResponseWrapper rw = new WOD_2.ResponseWrapper(JSON.serialize(installedPartList),true,'');
        try{
            if(!installedPartList.isEmpty()){
                ATI_ExchangeRateService.ExchangeWrapper er = new  ATI_ExchangeRateService.ExchangeWrapper();
                Set<id> claimIdSet = new Set<id>();
                Map<id,WOD_2__Claim_Part__c> partMap = new Map<id,WOD_2__Claim_Part__c>();
                Set<Id> wpIdSet = new Set<Id>();
                for(WOD_2__Claim_Part__c part: installedPartList ){
                    if(part.Id != NULL){
                        System.debug('part------->'+part);
                        partMap.put(part.Id,part);
                    }
                    if(part.Name=='' || part.WOD_2__Warranty_Product__c ==null ){
                        rw.errormessage = 'Please add Part';
                        rw.status = false;
                        return rw;
                    }else{
                        wpIdSet.add(part.WOD_2__Warranty_Product__c);
                    }
                    claimIdSet.add(part.WOD_2__Claim__c);
                }
                WOD_2__Claim__c claim = [SELECT id, Name,WOD_2__Claim_Type__c,CurrencyIsoCode, WOD_2__Account__c,WOD_2__Date_Of_Failure__c, 
                                         WOD_2__Account__r.ATI_Currency__c,WOD_2__BusinessCategory__c,WOD_2__Inventory__c,WOD_2__Date_Of_Repair__c,
                                         WOD_2__Account__r.ATI_Exchange_Rate_Type__c
                                         FROM WOD_2__Claim__c WHERE Id IN :  claimIdSet LIMIT 1];
                
                //validate for part cost - if not present throw error
                rw = validatePartCost(wpIdSet,claim,rw);
                if(rw.status == false){
                    return rw;
                }
                
                //run BU rules and validate
                rw = validateOnBURules(claim,'Claim UI - Parts');
                if(rw.errormessage != null){
                    return rw;
                }
                
                //Major component valiadation
                List<WOD_2__Major_Component__c> majorCompsLst = new List<WOD_2__Major_Component__c>();
                if(installedPartList[0].WOD_2__Serial_Number__c != '' && installedPartList[0].WOD_2__Serial_Number__c != null && String.valueOf(installedPartList[0].WOD_2__Warranty_Product__c) != ''){
                    System.debug('installedPartList>>>> '+installedPartList);
                    if(installedPartList[0].Id != NULL){
                        majorCompsLst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Part_Number__c 
                                         FROM WOD_2__Major_Component__c
                                         WHERE WOD_2__Serial_number__c=:installedPartList[0].WOD_2__Serial_Number__c
                                         AND WOD_2__Warranty_Product__c=:installedPartList[0].WOD_2__Warranty_Product__c
                                         AND WOD_2__Inventory__c=:claim.WOD_2__Inventory__c LIMIT 1];
                    }else{ 
                        majorCompsLst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Part_Number__c 
                                         FROM WOD_2__Major_Component__c
                                         WHERE WOD_2__Serial_number__c=:installedPartList[0].WOD_2__Serial_Number__c
                                         AND WOD_2__Warranty_Product__c=:installedPartList[0].WOD_2__Warranty_Product__c
                                         AND WOD_2__Inventory__c=NULL LIMIT 1];
                    }
                   //ALSN-170 Business asked to remove validation
                   //update Inventory on Major Component if it is null and majorCompsLst is not empty
                   /* 
                    if(majorCompsLst.isEmpty()){
                        rw.status = false;
                        rw.errormessage = System.Label.ATI_Part_Serial_Number_Invalid;
                        return rw;
                    }else */
                    if(!majorCompsLst.isEmpty()){
                        if(majorCompsLst[0].WOD_2__Inventory__c == NULL){
                            majorCompsLst[0].WOD_2__Inventory__c = claim.WOD_2__Inventory__c;
                            update majorCompsLst[0];
                        }
                    }
                }
                
                
                if(claim.WOD_2__Claim_Type__c == 'Claim Template' ){ //|| claim.WOD_2__Claim_Type__c =='Campaign'
                    rw.status = true; rw.data = JSON.serialize(installedPartList); return rw;
                }else{
                    String fromCurrancy =  claim.CurrencyIsoCode;
                    String toCurrency = 'USD';
                    if(fromCurrancy != '' && fromCurrancy != toCurrency){
                        //toCurrency = claim.WOD_2__Account__r.ATI_Currency__c;
                        er = ATI_ExchangeRateService.convertCurrencyOfType(fromCurrancy, toCurrency, claim.WOD_2__Date_Of_Failure__c, claim.WOD_2__Account__r.ATI_Exchange_Rate_Type__c);
                        //er.msg = ''; 
                        //er.rate = 1;
                        
                        if(er.msg==''){
                            for(WOD_2__Claim_Part__c part: installedPartList ){
                                System.debug('>>>part.WOD_2__Unit_Price__c :'+part.WOD_2__Unit_Price__c); 
                                part.ATI_Unit_Price_in_USD__c = part.WOD_2__Unit_Price__c * er.rate; rw.data = JSON.serialize(installedPartList); rw.status = true;
                            }
                        }
                        else{
                            System.debug('>>>er.msg  :'+er.msg);
                            rw.errormessage = er.msg; rw.status = false;
                            //throw new TWoDException(er.msg);
                        }
                    }else {
                        for(WOD_2__Claim_Part__c part: installedPartList ){
                            System.debug('>>>part.WOD_2__Unit_Price__c :'+part.WOD_2__Unit_Price__c); 
                            part.ATI_Unit_Price_in_USD__c = part.WOD_2__Unit_Price__c;
                            // part.WOD_2__Unit_Price__c = part.WOD_2__Unit_Price__c ;
                            rw.data = JSON.serialize(installedPartList);
                            rw.status = true;
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('InstallPart>>>> '+e.getMessage()+' : '+e.getLineNumber());
        }
        return rw;
    } 
    
    public static WOD_2.ResponseWrapper validatePartCost(Set<Id> partIdSet,WOD_2__Claim__c claimObj,WOD_2.ResponseWrapper responseWrapper){
        String dateFieldForPriceFetchStr = ATI_Utils.getConfiguration(claimObj.WOD_2__BusinessCategory__c, 'CLM_Price_Fetch_ClaimField_Tobe_Compare').WOD_2__Value__c;
        Date dateFieldForPriceFetch = (Date) claimObj.get(dateFieldForPriceFetchStr);
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = [SELECT Id,WOD_2__Price__c,WOD_2__Warranty_Product__c FROM WOD_2__Warranty_Product_Pricebook__c 
                                                                      WHERE WOD_2__Warranty_Product__c IN :partIdSet
                                                                      AND WOD_2__Valid_From__c <=:dateFieldForPriceFetch AND ATI_Active__c=true
                                                                      AND WOD_2__Valid_Until__c >=:dateFieldForPriceFetch 
                                                                      AND RecordType.DeveloperName='ATI_Part_Cost'];
        if(wpPbLst.isEmpty()){
           responseWrapper.status = false;
           responseWrapper.errorMessage = System.Label.Part_Cost_Error;
        }
        return responseWrapper;
    }
    
    
    // This method is called from Product before claim is saved. 
    // We will be registering the invnetory if it is not already registered.
    global override WOD_2.ResponseWrapper beforeClaimSave(WOD_2__Claim__c claimObject) {
        System.debug('Inside ATI_CLM_ClaimBaseOverrideHook - before save');
        System.debug('CLM Object -> ' + claimObject);
        Boolean isDistributorDealer = ATI_Utils.isLoggedInUserAsDistributor();
        try{
        //Added by Dishari on 07/16/21 for Bug 27326 Claim Technician Name, Work Order No, and Work Performed Comments Fields blank check
            if(String.isBlank(claimObject.WOD_2__Work_Order__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template' ){
                
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Work_Order_Number_is_missing);
            }
            if(String.isBlank(claimObject.WOD_2__Work_Performed_Comments__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                
                return new WOD_2.ResponseWrapper('', false, Label.ATI_CLM_Work_Performed_Comments_Mandatory);
            }
            //Added by Dishari On 7th Oct 2021 Bug-2899
            if(String.isBlank(claimObject.ATI_Tracking_Number__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
       
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Tracking_Number_is_mandatory);
            }
            //Added by Dishari On 14th Dec 2021 Bug-29367
            /*if((claimObject.WOD_2__Units_Usage__c == Null || claimObject.WOD_2__Units_Usage__c <= 0) && claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                system.debug('claimObject.WOD_2__Units_Usage__c'+claimObject.WOD_2__Units_Usage__c);
                return new WOD_2.ResponseWrapper('', false,  Label.ATI_Unit_Usage_is_blank_or_not_valid);
            }*/
            //Added by Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
            if(claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                List<WOD_2__Claim__c> claimLst = [SELECT Id FROM WOD_2__Claim__c 
                                                  WHERE WOD_2__Account__c =:claimObject.WOD_2__Account__c 
                                                  AND ATI_Tracking_Number__c = :claimObject.ATI_Tracking_Number__c];
                if(claimLst.size() > 0 && claimLst[0].Id != claimObject.Id){
                    return new WOD_2.ResponseWrapper('', false, Label.ATI_TrackingNumberisnotvalid);
                }
             }
            //End here Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
            if(String.isBlank(claimObject.ATI_Technician_Name__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template' ){
                
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Technician_Name_is_missing);
            }
           
            //Ended here 27326 for Claim Technician Name, Work Order No, and Work Performed Comments Fields blank check
            
            //Added by Dishari on 07/21/21 for Bu Rule AT: ETC coverage denied previously for this Serial Number
            if(claimObject != NULL){
                //ALSN-148
                /*
                List<Id> invList = new List<Id>();
                invList.add(claimObject.WOD_2__Inventory__c);
                List<WOD_2__Inventory__c> invDetailsList= ATI_WarrantyService.getInventoriesForWR(invList);
                */
                //ALSN-167 additional condition to check if the Rejected status is on Standard Registration.
                List<WOD_2__Warranty_Registration__c> warrantyRegLst = [SELECT Id,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c 
                                                                        WHERE WOD_2__Status__c ='Rejected' AND WOD_2__Registration_Type__c = 'Standard Registration' AND WOD_2__Inventory__c = :claimObject.WOD_2__Inventory__c];
                    if(warrantyRegLst.size()>0){
                    return new WOD_2.ResponseWrapper('', false, Label.ATI_WR_rejected);
                }
            }
             //End here Dishari on 07/21/21 for Bu Rule AT: ETC coverage denied previously for this Serial Number
            
            if(claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                ATI_ExchangeRateService.ExchangeWrapper erObj = new  ATI_ExchangeRateService.ExchangeWrapper();
                if(claimObject.CurrencyIsoCode != NULL && claimObject.CurrencyIsoCode != 'USD'){
                    erObj = ATI_ExchangeRateService.convertCurrencyForAccount(claimObject.CurrencyIsoCode,'USD',claimObject.WOD_2__Date_Of_Failure__c, claimObject.WOD_2__Account__c);
                }
                if(claimObject.CurrencyIsoCode != 'USD'){
                    if(erObj.msg==''){
                        claimObject.ATI_Exchange_Rate__c = erObj.rate;
                    }else{
                        System.debug('>>>er.msg  :'+erObj.msg);
                        return new WOD_2.ResponseWrapper('', false, erObj.msg);
                    }
                }else{
                    claimObject.ATI_Exchange_Rate__c = 1;
                }
                WOD_2.ResponseWrapper responseWrapperObjvalidate = validateReplacementInfo(claimObject,new WOD_2.ResponseWrapper(JSON.serialize(claimObject),true,''));
                if(!responseWrapperObjvalidate.status){
                    return responseWrapperObjvalidate;
                }
                
                /*Punam AutoPopulate Dealer Currency START*/
                //ALSN-85
                /*
                String accountCurrValue= ATI_Utils.getAccountCurrencyForDealer();
                system.debug('accountCurrValue**'+accountCurrValue+'claimObject.CurrencyIsoCode**'+claimObject.CurrencyIsoCode);
                if(isDistributorDealer== true && accountCurrValue!=''){
                    if(claimObject.CurrencyIsoCode != accountCurrValue){
                        return new WOD_2.ResponseWrapper('', false, 'Please select proper currency.');
                    }
                }
                */
                
                if(claimObject.ATI_Failure_Code__c != null){
                    claimObject.WOD_2__Fault_Code__c = claimObject.ATI_Failure_Code__c;
                }                
                // set the buId and claim from claim for policy fetching
                ATI_CLM_ATPolicyQueryOverrideImpl.businessUnitId = claimObject.WOD_2__BusinessCategory__c;
                ATI_CLM_ATPolicyQueryOverrideImpl.claimType = claimObject.WOD_2__Claim_Type__c;
                
                //Alsn-141 
                if(claimObject.WOD_2__Claim_Type__c == 'Part'){
                    Integer monthDiff = claimObject.WOD_2__Date_Of_Purchase__c.monthsBetween(claimObject.WOD_2__Date_Of_Failure__c);
                    Integer daysEnd = Date.daysInMonth(claimObject.WOD_2__Date_Of_Failure__c.year(), claimObject.WOD_2__Date_Of_Failure__c.month());
                    Double day_s = claimObject.WOD_2__Date_Of_Purchase__c.day();
                    Double day_e = claimObject.WOD_2__Date_Of_Failure__c.day();
                    Double factor = 0;                    
                    factor = (day_e - day_s)/daysEnd;                 
                    Double months = monthDiff+factor;
                    ATI_CLM_ATPolicyQueryOverrideImpl.months = months;
                    System.debug('monthss'+months);
                }
                //end of Alsn 141
                
                //Punam --> Throw No Policy Found error if inventory is retail with no coverage Start
                Boolean noPolicy=false;
                List<Id> invIdList = new List<Id>();
                invIdList.add(claimObject.WOD_2__Inventory__c);
                List<WOD_2__Inventory__c> invDetails= ATI_WarrantyService.getInventoriesForWR(invIdList);
                
                if(invDetails[0].WOD_2__Type__c=='Retail'){
                    List<WOD_2__Warranty_Registration__c> warrantyRegList =[Select Id, (Select Id From WOD_2__Warranty_Coverages__r) From WOD_2__Warranty_Registration__c Where WOD_2__Inventory__c =:claimObject.WOD_2__Inventory__c /*AND WOD_2__Status__c='Registered'*/];
                    if(warrantyRegList.size()>0){
                        for(WOD_2__Warranty_Registration__c reg: warrantyRegList){
                            if(reg.WOD_2__Warranty_Coverages__r.size()>0){
                                noPolicy= true;
                            }
                        }

                        if(noPolicy==false){
                            return new WOD_2.ResponseWrapper('', false, 'No Applicable Policy found'); 
                                               }
                    }else{
                        return new WOD_2.ResponseWrapper('', false, 'No Applicable Policy found');
                    }
                    
                }
                
                
                //Punam --> Throw No Policy Found error if inventory is retail with no coverage--- End 
                
                //punam Update Veh Info while editing draft claims for Retail inventories.
                if(claimObject.ATI_WR_Details__c != null /*&& isDistributorDealer!= true*/){
                    ATI_WarrantyService.WRDetailsWrapper wrNewWrapper = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimObject.ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
                    //system.debug('****'+wrOldWrapper.vehicleInfo.ATI_Engine_Year__c+'***'+wrNewWrapper.vehicleInfo.ATI_Engine_Year__c);
                    System.debug('wrNewWrapper.vehicleInfo--->'+wrNewWrapper.vehicleInfo.Name);
                    if(wrNewWrapper.vehicleInfo.Name == null){
                        return new WOD_2.ResponseWrapper('', false, 'Vehicle Information is mandatory'); 
                    }
                    //Alsn-131 updating the fields in the wrapper when the values were null
                    WOD_2__Inventory__c inv =[Select Id,ATI_Vocation_Code__c,WOD_2__Units_Usage__c,ATI_Vocation_Code__r.Name,ATI_Vocation_Code__r.WOD_2__Description__c, WOD_2__Type__c,WOD_2__Install_Date__c,WOD_2__Customer__c from WOD_2__Inventory__c where Id=:claimObject.WOD_2__Inventory__c];
                    if(inv.WOD_2__Type__c == 'Retail' && (wrNewWrapper.WOD_2_Install_Date_c == null || (wrNewWrapper.WOD_2_Type_c == null || wrNewWrapper.WOD_2_Type_c == '') || (wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)))){
                    if(wrNewWrapper.WOD_2_Install_Date_c == null){
                        wrNewWrapper.WOD_2_Install_Date_c = inv.WOD_2__Install_Date__c;  
                    }
                    if(wrNewWrapper.WOD_2_Type_c == null || wrNewWrapper.WOD_2_Type_c == ''){
                        wrNewWrapper.WOD_2_Type_c = inv.WOD_2__Type__c;
                    }
                    if(wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)){
                        wrNewWrapper.WOD_2_Customer_c = inv.WOD_2__Customer__c;
                    }
                        wrNewWrapper.WOD_2_Units_Usage_c = claimObject.WOD_2__Units_Usage__c;
                        wrNewWrapper.Vocation_WOD_2_Description_c = inv.ATI_Vocation_Code__r.WOD_2__Description__c;
                        wrNewWrapper.Vocation_Name = inv.ATI_Vocation_Code__r.Name;
                        claimObject.ATI_WR_Details__c = System.JSON.serialize(wrNewWrapper);
                    }
                    //end of Alsn-131
                    if(wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)){
                        return new WOD_2.ResponseWrapper('', false, Label.ATI_WR_CustomerMandatory);
                    }
                    if(wrNewWrapper.ATI_Pre_Delivery_c == true){
                        ATI_CLM_ATPolicyQueryOverrideImpl.preDelivery = true;
                        ATI_CLM_ATPolicyQueryOverrideImpl.inventoryId = claimObject.WOD_2__Inventory__c;
                        claimObject.ATI_isPreDelivery__c = true;
                        //ALSN-127 Pre-Auth policy to be picked over pre-delivery
                        if(claimObject.WOD_2__Is_Pre_Authorization_Required__c){
                            ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = true;
                        }
                       //End here 
                        //Added by Dishari on 07/19/21 for Bu Rule AT:For pre-deliv. the RO date can't be 24O mos. after build date call QA if legit
                       /* if(claimObject.WOD_2__Claim_Type__c !='Claim Template' && claimObject != NULL){
                            List<Id> invList = new List<Id>();
                            invList.add(claimObject.WOD_2__Inventory__c);
                            List<WOD_2__Inventory__c> invDetailsList= ATI_WarrantyService.getInventoriesForWR(invList);
                            //List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'ATI_RepairOrderPre_delivery' LIMIT 1];   
                           // String profileNameString = ATI_Utils.getConfiguration('ATI RepairOrderPre-delivery').WOD_2__Value__c;  
                           // if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){ 
                              Integer months =  Integer.valueof(ATI_Utils.getConfiguration('ATI RepairOrderPre-delivery').WOD_2__Value__c);
                            List<WOD_2__Warranty_Registration__c> warrantyRegLst = [SELECT Id,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c 
                                                                                    WHERE ATI_Pre_Delivery__c = TRUE AND WOD_2__Inventory__c = :claimObject.WOD_2__Inventory__c];
                            
                           // if(warrantyRegLst.size()>0 &&claimObject.WOD_2__Date_Of_Failure__c>invDetailsList[0].WOD_2__Manufacturing_Date__c.addMonths(months) ){
                                if(warrantyRegLst.size()>0 &&claimObject.WOD_2__Date_Of_Failure__c>invDetailsList[0].WOD_2__Manufacturing_Date__c.addMonths(months)){
                                system.debug('claimObject.WOD_2__Date_Of_Failure__c'+claimObject.WOD_2__Date_Of_Failure__c);
                                system.debug('invDetailsList[0].WOD_2__Manufacturing_Date__c.addMonths(24)'+invDetailsList[0].WOD_2__Manufacturing_Date__c.addMonths(months));
                                return new WOD_2.ResponseWrapper('', false, Label.ATI_RoDate_BuildDate_Pre_Delivery);
                            }
                        }*/
                        //End here Dishari on 07/19/21 for Bu Rule AT: For pre-deliv. the RO date can't be 24 mos. after build date call QA if legit
                    }
                    ATI_VehicleInformationController.saveVehicleInfo(JSON.serialize(wrNewWrapper.vehicleInfo));
                }
            }
            return new WOD_2.ResponseWrapper(JSON.serialize(claimObject), true, '');
        }catch(Exception e){
            System.debug('errormessage>>>>> '+e.getMessage()+e.getLineNumber());
            return new WOD_2.ResponseWrapper('', false, e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    global override WOD_2.ResponseWrapper beforeCampaignClaimSave(String campaignClaimWrapListString) {
        List<Object> campaignDetailMap = (List<Object>)JSON.deserializeUntyped(campaignClaimWrapListString);
        //ALSN-208
        List<Id> serviceCampaignIdList = new List<Id>();
        for(Object obj : campaignDetailMap){
            Map<String,Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(Obj));
            twodcms__Campaign_Claim_Template_Association__c cctaObject = (twodcms__Campaign_Claim_Template_Association__c)JSON.deserialize(JSON.serialize(mapRes.get('cctaObject')),twodcms__Campaign_Claim_Template_Association__c.class);
            serviceCampaignIdList.add(cctaObject.twodcms__Service_Campaign__c);
        }
        Map<Id,twodcms__Service_Campaign__c> serviceCampaignMap = new Map<id,twodcms__Service_Campaign__c>([Select Id,ATI_Months_Covered__c from twodcms__Service_Campaign__c where Id in:serviceCampaignIdList]);
        //ALSN-208 end
        List<Object> wrapperLst = new List<Object>();
        for(Object obj : campaignDetailMap){
            Map<String,Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(Obj));
            WOD_2__Claim__c claimObject = (WOD_2__Claim__c)JSON.deserialize(JSON.serialize(mapRes.get('campaignClaimObject')),WOD_2__Claim__c.class);
            //Added by Dishari on 6th Oct 28999 for Tech Name field Should be Required
            if(String.isBlank(claimObject.WOD_2__Work_Order__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template' ){
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Work_Order_Number_is_missing);
            }
            if(String.isBlank(claimObject.WOD_2__Work_Performed_Comments__c)){
                return new WOD_2.ResponseWrapper('', false, Label.ATI_CLM_Work_Performed_Comments_Mandatory);
            }
            if(String.isBlank(claimObject.ATI_Tracking_Number__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Tracking_Number_is_mandatory);
            }
             //Added by Dishari On 14th Dec 2021 Bug-29367
            /*if((claimObject.WOD_2__Units_Usage__c == Null || claimObject.WOD_2__Units_Usage__c <= 0) && claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                system.debug('claimObject.WOD_2__Units_Usage__c'+claimObject.WOD_2__Units_Usage__c);
                return new WOD_2.ResponseWrapper('', false,  Label.ATI_Unit_Usage_is_blank_or_not_valid);
            }*/
            //End here Dishari on On 14th Dec 2021 Bug-29367.
            //Added by Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
            if(claimObject.WOD_2__Claim_Type__c != 'Claim Template'){
                List<WOD_2__Claim__c> claimLst = [SELECT Id FROM WOD_2__Claim__c 
                                                  WHERE WOD_2__Account__c =:claimObject.WOD_2__Account__c 
                                                  AND ATI_Tracking_Number__c = :claimObject.ATI_Tracking_Number__c];
                if(claimLst.size() > 0 && claimLst[0].Id != claimObject.Id){
                    return new WOD_2.ResponseWrapper('', false, Label.ATI_TrackingNumberisnotvalid);
                }
            }
            //End here Dishari on 8th Oct for 28999 it should be unique across the Business Partner.
            
            if(String.isBlank(claimObject.ATI_Technician_Name__c) && claimObject.WOD_2__Claim_Type__c != 'Claim Template' ){
                return new WOD_2.ResponseWrapper('', false, Label.ATI_Technician_Name_is_missing);
            }
           
            //Ended here Dishari on 6th Oct 28999 for Tech Name field Should be Required
            ATI_ExchangeRateService.ExchangeWrapper erObj = new  ATI_ExchangeRateService.ExchangeWrapper();
            if(claimObject.CurrencyIsoCode != NULL && claimObject.CurrencyIsoCode != 'USD'){
                erObj = ATI_ExchangeRateService.convertCurrencyForAccount(claimObject.CurrencyIsoCode,'USD',claimObject.WOD_2__Date_Of_Failure__c, claimObject.WOD_2__Account__c);
            }
               //Added by Dishari on 12/15/2021 Bu Rule AT:For pre-deliv. the RO date can't be 24O mos. after build date call QA if legit
            if(claimObject.ATI_WR_Details__c != null && String.isNotBlank(claimObject.ATI_WR_Details__c)/*&& isDistributorDealer!= true*/){
                ATI_WarrantyService.WRDetailsWrapper wrNewWrapper = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimObject.ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
                if(wrNewWrapper.ATI_Pre_Delivery_c == true){
                    ATI_CLM_ATPolicyQueryOverrideImpl.preDelivery = true;
                    ATI_CLM_ATPolicyQueryOverrideImpl.inventoryId = claimObject.WOD_2__Inventory__c;
                    claimObject.ATI_isPreDelivery__c = true;
                    //ALSN-127 Pre-Auth policy to be picked over pre-delivery
                    if(claimObject.WOD_2__Is_Pre_Authorization_Required__c){
                        ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = true;
                    }
                }
                //alsn-205
                 WOD_2__Inventory__c inv =[Select Id,ATI_Vocation_Code__c,WOD_2__Units_Usage__c,ATI_Vocation_Code__r.Name,ATI_Vocation_Code__r.WOD_2__Description__c, WOD_2__Type__c,WOD_2__Install_Date__c,WOD_2__Customer__c from WOD_2__Inventory__c where Id=:claimObject.WOD_2__Inventory__c];
                 if(inv.WOD_2__Type__c == 'Retail' && (wrNewWrapper.WOD_2_Install_Date_c == null || (wrNewWrapper.WOD_2_Type_c == null || wrNewWrapper.WOD_2_Type_c == '') || (wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)))){
                 if(wrNewWrapper.WOD_2_Install_Date_c == null){
                    wrNewWrapper.WOD_2_Install_Date_c = inv.WOD_2__Install_Date__c;  
                 }
                 if(wrNewWrapper.WOD_2_Type_c == null || wrNewWrapper.WOD_2_Type_c == ''){
                    wrNewWrapper.WOD_2_Type_c = inv.WOD_2__Type__c;
                 }
                 if(wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)){
                    wrNewWrapper.WOD_2_Customer_c = inv.WOD_2__Customer__c;
                 }
                    wrNewWrapper.WOD_2_Units_Usage_c = claimObject.WOD_2__Units_Usage__c;
                    wrNewWrapper.Vocation_WOD_2_Description_c = inv.ATI_Vocation_Code__r.WOD_2__Description__c;
                    wrNewWrapper.Vocation_Name = inv.ATI_Vocation_Code__r.Name;
                    claimObject.ATI_WR_Details__c = System.JSON.serialize(wrNewWrapper);
                 }
                //end of alsn-205
                //ALSN-208 new validation
                twodcms__Campaign_Claim_Template_Association__c cctaObjectCheck = (twodcms__Campaign_Claim_Template_Association__c)JSON.deserialize(JSON.serialize(mapRes.get('cctaObject')),twodcms__Campaign_Claim_Template_Association__c.class);
                if(cctaObjectCheck.twodcms__Service_Campaign__c != null && serviceCampaignMap.get(cctaObjectCheck.twodcms__Service_Campaign__c).ATI_Months_Covered__c != null && wrNewWrapper.WOD_2_Install_Date_c != null){
                    if(claimObject.WOD_2__Date_Of_Failure__c > wrNewWrapper.WOD_2_Install_Date_c.addMonths(Integer.valueOf(serviceCampaignMap.get(cctaObjectCheck.twodcms__Service_Campaign__c).ATI_Months_Covered__c)))
                        return new WOD_2.ResponseWrapper('', false, Label.ATI_RO_Date_exceeds_Campaign_time);
                }//ALSN-208 [End]
                if(wrNewWrapper.WOD_2_Customer_c == null || ATI_Utils.checkIsBlankData(wrNewWrapper.WOD_2_Customer_c)){
                    return new WOD_2.ResponseWrapper('', false, Label.ATI_WR_CustomerMandatory);
                }
            }
            if(claimObject.CurrencyIsoCode != 'USD'){
                if(erObj.msg==''){
                    claimObject.ATI_Exchange_Rate__c = erObj.rate;
                }else{
                    System.debug('>>>er.msg  :'+erObj.msg);
                    return new WOD_2.ResponseWrapper('', false, erObj.msg);
                }
            }else{
                claimObject.ATI_Exchange_Rate__c = 1;
            }
            mapRes.put('campaignClaimObject',(Object)claimObject);
            wrapperLst.add(mapRes); 
        }
        System.debug('------------>'+JSON.serialize(wrapperLst));
        return new WOD_2.ResponseWrapper(JSON.serialize(wrapperLst), true, '');
    }
    
    
    private static WOD_2.ResponseWrapper validateReplacementInfo(WOD_2__Claim__c claimObject,WOD_2.ResponseWrapper response){
        List<String> errorList = new List<String>();
        if(claimObject.ATI_Replacement_Claims__c){
            if(String.isBlank(claimObject.ATI_Replacement_Type__c)){
                errorList.add(Label.ATI_Select_Replacement_Type);
            }
            if(String.isBlank(claimObject.ATI_Replaced_Inventory__c)){
                errorList.add(Label.ATI_Select_Replaced_Inventory);
            }else{
                WOD_2__Inventory__c replaceInvLst = [SELECT ATI_Active__c,ATI_Warranty_Void__c,WOD_2__Scrapped__c FROM WOD_2__Inventory__c WHERE Id =:claimObject.ATI_Replaced_Inventory__c];
                if(replaceInvLst.ATI_Warranty_Void__c == TRUE){
                    errorList.add(System.Label.ATI_WarrantyVoid_ReplacedInv);
                }
                if(replaceInvLst.ATI_Active__c == FALSE){
                    errorList.add(System.Label.ATI_Inactive_ReplacedInv);
                }
                if(replaceInvLst.WOD_2__Scrapped__c == TRUE){
                    errorList.add(System.Label.ATI_Scrapped_ReplacedInv);
                }
            }
            if(claimObject.ATI_Replaced_Inventory__c == claimObject.WOD_2__Inventory__c){
                errorList.add(System.Label.ATI_Primary_ReplacedInv);
            }
        }
        if((claimObject.WOD_2__Claim_Type__c== 'Machine' || claimObject.WOD_2__Claim_Type__c== 'Part') && String.isBlank(claimObject.WOD_2__Causal_Part_Number__c)){
            errorList.add(System.Label.ATI_Causal_Part_is_mandatory);
        }
        List<WOD_2__Inventory__c> InvLst = [SELECT ATI_Active__c,ATI_Warranty_Void__c,WOD_2__Scrapped__c FROM WOD_2__Inventory__c WHERE Id =:claimObject.WOD_2__Inventory__c];
          
        if(!InvLst.isEmpty() && (InvLst[0].WOD_2__Scrapped__c == true || InvLst[0].ATI_Active__c == false || InvLst[0].ATI_Warranty_Void__c==true)){
            errorList.add(System.Label.ATI_Scrapped_Inactive_Inventory);
        }
        if(!errorList.isEmpty()){
            //throw new TWoDException(String.join(errorList, ', '));
            response.status = false;
            response.errormessage = String.join(errorList,',  ');
            
        }        
        return response;
    }
    
    
    // This method is called from Product before Labor is saved.
    global override WOD_2.ResponseWrapper beforeClaimServiceInformationSave(List<WOD_2__Claim_Service_Information__c> servicesList) {
        System.debug('servicesList>>>>>> '+servicesList);
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper(JSON.serialize(servicesList),true,'');
        try{
            if(!servicesList.isEmpty()){
                response.data = JSON.serialize(servicesList);
                set<string> jobCodeSet = new set<string>();
                set<string> claimIdSet = new set<string>();
                
                for(WOD_2__Claim_Service_Information__c serviceRec : servicesList) {
                    jobCodeSet.add(serviceRec.WOD_2__Service_Job_Code__c);
                    claimIdSet.add(serviceRec.WOD_2__Claim__c);
                }
                Map<string,boolean> jobCodeMap = new Map<string,boolean>();
                for(WOD_2__Warranty_Code__c jobCode : [SELECT Id,ATI_Time_Studied__c FROM WOD_2__Warranty_Code__c WHERE Id in :jobCodeSet]){
                    jobCodeMap.put(jobCode.Id,jobCode.ATI_Time_Studied__c);
                }
                set<string> existingJobCodeSet = new set<string>();
                for(WOD_2__Claim_Service_Information__c serviceRec : [SELECT Id,WOD_2__Service_Job_Code__c FROM WOD_2__Claim_Service_Information__c WHERE WOD_2__Claim__c in :claimIdSet]){
                    existingJobCodeSet.add(serviceRec.WOD_2__Service_Job_Code__c);
                }
                
                set<string> primaryCodeSet = new set<string>();
                set<string> excludedCodeSet = new set<string>();
                for(Excluded_Labor_Operations_Code__c excludedCodeRec : [SELECT Id,Excluded_Code__c,ATI_Labor_Operations_Code__c FROM Excluded_Labor_Operations_Code__c WHERE Excluded_Code__c in :jobCodeSet OR ATI_Labor_Operations_Code__c in :jobCodeSet]){
                    primaryCodeSet.add(excludedCodeRec.ATI_Labor_Operations_Code__c);
                    excludedCodeSet.add(excludedCodeRec.Excluded_Code__c);
                }
                
                ATI_ExchangeRateService.ExchangeWrapper erObj = new  ATI_ExchangeRateService.ExchangeWrapper();
                WOD_2__Claim__c claimRec = [SELECT Id,WOD_2__Account__r.ATI_Exchange_Rate_Type__c, CurrencyIsoCode,WOD_2__Date_Of_Failure__c,WOD_2__BusinessCategory__c FROM WOD_2__Claim__c WHERE Id in :claimIdSet LIMIT 1];
                
                if(claimRec.CurrencyIsoCode != NULL && claimRec.CurrencyIsoCode != 'USD'){
                    erObj = ATI_ExchangeRateService.convertCurrencyOfType(claimRec.CurrencyIsoCode,'USD',claimRec.WOD_2__Date_Of_Failure__c, claimRec.WOD_2__Account__r.ATI_Exchange_Rate_Type__c);
                }
                for(WOD_2__Claim_Service_Information__c serviceRec : servicesList) {
                    if(serviceRec.WOD_2__Total_Labor_Hours__c ==null || serviceRec.WOD_2__Total_Labor_Hours__c <= 0){
                        response.status = false;
                        response.errormessage = System.Label.ATI_ActualLaborHourValidationMsg;
                        return response;
                    }
                    else if(jobCodeMap.get(serviceRec.WOD_2__Service_Job_Code__c) && serviceRec.WOD_2__Total_Labor_Hours__c>serviceRec.WOD_2__Standard_Labor_Hour__c){
                        response.status = false;
                        response.errormessage = System.Label.ATI_TimeBoundJobCodeLaborErr;
                    }
                    else if(serviceRec.Id== null){
                        if(existingJobCodeSet.contains(serviceRec.WOD_2__Service_Job_Code__c)){
                            response.status = false;
                            response.errormessage = System.Label.ATI_LaborDuplicateJobCodeErr;
                        }
                        else{
                            for(string jobCode : primaryCodeSet){
                                if(existingJobCodeSet.contains(jobCode)){
                                    response.status = false;
                                    response.errormessage = System.Label.ATI_PrimaryLaborCodeExists;
                                }
                            }
                            for(string jobCode : excludedCodeSet){
                                if(existingJobCodeSet.contains(jobCode)){
                                    response.status = false;
                                    response.errormessage = System.Label.ATI_ExcludedLaborCodeExists;
                                }
                            }
                        }
                    }
                    /*if(serviceRec.WOD_2__Total_Labor_Hours__c<=serviceRec.WOD_2__Standard_Labor_Hour__c && !string.isBlank(serviceRec.WOD_2__Reason_Additional_Labor_Hour__c)){
                        serviceRec.WOD_2__Reason_Additional_Labor_Hour__c='';
                        response.data = JSON.serialize(servicesList);
                    }*/
                    Decimal rateInUSD = 1;
                    if(erObj != NULL && erObj.rate != NULL) rateInUSD = erObj.rate;
                    if(serviceRec.WOD_2__LaborRate__c != NULL){
                        serviceRec.ATI_Labor_Rate_in_USD__c = serviceRec.WOD_2__LaborRate__c * rateInUSD;
                        serviceRec.ATI_Total_Labor_Cost_in_USD__c = serviceRec.ATI_Labor_Rate_in_USD__c * serviceRec.WOD_2__Total_Labor_Hours__c;
                        response.data = JSON.serialize(servicesList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('Labor>>> '+e.getMessage()+ ' : '+e.getLineNumber());
        }
        return response;

    }
    
    // This method is called from Product before Other Cost is saved.
    global override WOD_2.ResponseWrapper beforeSaveClaimOtherCostObject(List<WOD_2__Other_Cost__c> otherCostList) {
        System.debug('otherCostList>>>>>> '+otherCostList);
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper(JSON.serialize(otherCostList),true,'');
        try{
            if(!otherCostList.isEmpty()){
                Set<Id> claimIdsSet = new Set<Id>();
                Map<id,WOD_2__Other_Cost__c> otherCostMap = new Map<id,WOD_2__Other_Cost__c>();
                for(WOD_2__Other_Cost__c otherCostObj: otherCostList ){
                    otherCostObj.WOD_2__Rate_PerUnit__c = (otherCostObj.WOD_2__Rate_Per_Unit__c != null) ? otherCostObj.WOD_2__Rate_Per_Unit__c : otherCostObj.WOD_2__Rate_PerUnit__c;
                    //ASLN-168 Copy the save value to WOD_2__Rate_Per_Unit__c
                    otherCostObj.WOD_2__Rate_Per_Unit__c = otherCostObj.WOD_2__Rate_PerUnit__c;
                    if(otherCostObj.WOD_2__UnitsUsage__c == NULL || otherCostObj.WOD_2__UnitsUsage__c <= 0|| otherCostObj.WOD_2__UnitsUsage__c != otherCostObj.WOD_2__UnitsUsage__c.intValue()){
                        response.status = false;
                        response.errormessage = System.Label.ATI_Unit_Quantity_Not_Valid;
                        return response;
                    }
                    if(otherCostObj.WOD_2__Rate_PerUnit__c == NULL || otherCostObj.WOD_2__Rate_PerUnit__c <= 0){
                        response.status = false;
                        response.errormessage = System.Label.ATI_Unit_Price_not_valid;
                        return response;
                    }
                    if(String.isBlank(otherCostObj.WOD_2__Comments__c)){
                        response.status = false;
                        response.errormessage = System.Label.Other_Cost_Comments_Mandatory;
                        return response;
                    }
                    claimIdsSet.add(otherCostObj.WOD_2__Claim__c);
                    if(otherCostObj.Id != NULL){
                        otherCostMap.put(otherCostObj.Id,otherCostObj);
                    }
                }
                
                ATI_ExchangeRateService.ExchangeWrapper erObj = new  ATI_ExchangeRateService.ExchangeWrapper();
                WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Account__r.ATI_Exchange_Rate_Type__c, CurrencyIsoCode,WOD_2__Date_Of_Failure__c,WOD_2__BusinessCategory__c FROM WOD_2__Claim__c WHERE Id in :claimIdsSet LIMIT 1];
                
                //run BU rules and validate
                response = validateOnBURules(claimObj,'Claim UI - Other Cost');
                System.debug('response------>'+response);
                if(response.errormessage != null){
                    return response;
                }
                
                if(claimObj.CurrencyIsoCode != NULL && claimObj.CurrencyIsoCode != 'USD'){
                    erObj = ATI_ExchangeRateService.convertCurrencyOfType(claimObj.CurrencyIsoCode,'USD',claimObj.WOD_2__Date_Of_Failure__c, claimObj.WOD_2__Account__r.ATI_Exchange_Rate_Type__c);
                }
                
                for(WOD_2__Other_Cost__c otherCostObj : otherCostList) {
                    Decimal rateInUSD = 1;
                    if(erObj != NULL && erObj.rate != NULL) rateInUSD = erObj.rate;
                    if(otherCostObj.WOD_2__Total_Cost__c != NULL){
                        otherCostObj.ATI_Total_Cost_in_USD__c = otherCostObj.WOD_2__Total_Cost__c * rateInUSD;
                    }
                    if(otherCostObj.WOD_2__Rate_PerUnit__c != NULL && otherCostObj.WOD_2__UnitsUsage__c != NULL){
                        otherCostObj.ATI_Unit_Price_in_USD__c = otherCostObj.WOD_2__Rate_PerUnit__c * rateInUSD;
                        otherCostObj.ATI_Total_Cost_in_USD__c = otherCostObj.ATI_Unit_Price_in_USD__c * otherCostObj.WOD_2__UnitsUsage__c;
                    }
                    else if(otherCostObj.WOD_2__Rate_PerUnit__c != NULL){
                        otherCostObj.ATI_Unit_Price_in_USD__c = otherCostObj.WOD_2__Rate_PerUnit__c * rateInUSD;
                    }
                    response.data = JSON.serialize(otherCostList);
                    response.status = true;
                }
            }
        }catch(Exception e){
            System.debug('Other Cost>>> '+e.getMessage()+ ' : '+e.getLineNumber());
        }
        return response;
    }
    
    public static WOD_2.ResponseWrapper validateOnBURules(WOD_2__Claim__c claimObj,String subModule){
        WOD_2.ResponseWrapper wrapper = new WOD_2.ResponseWrapper();
        List<WOD_2__Business_Rule__c> burRulesTriggeredLst = 
            ATI_BURulesService.runBURules(claimObj.WOD_2__BusinessCategory__c,'WOD_2__Claim__c',new List<Id>{claimObj.Id},
                                          'Claim',subModule);
        String errorStr = '';
        for(WOD_2__Business_Rule__c buRuleObj : burRulesTriggeredLst){
            if(buRuleObj.WOD_2__Error_Type__c =='Hard' && buRuleObj.WOD_2__Message__c != NULL){
                errorStr = errorStr + buRuleObj.WOD_2__Message__c+'\n';
            }
        }
        if(errorStr != ''){
            return new WOD_2.ResponseWrapper('', false, errorStr);
        }
        return wrapper;
    }
    
    /*Modification by Anjali for turnaround data */
   /* public static WOD_2.ResponseWrapper validateTurnAroundDate(WOD_2__Claim__c claimObj,WOD_2.ResponseWrapper response){
        System.debug('ClaimObj---->'+claimObj);
        if(claimObj.ATI_First_Labor_Applied_Date_Time__c == null && claimObj.ATI_First_Part_Ordered_Date_Time__c == null && claimObj.ATI_Last_Part_Arrival_Date_Time__c == null
           && claimObj.ATI_Repair_Order_Closed_Date_Time__c == null && claimObj.ATI_Vehicle_Arrival_Date_Time__c == null && claimObj.ATI_Completed_Repair_Cust_Noti_Date__c == null
           && claimObj.ATI_Distributor_schedules_cust_Serv_Date__c == null && claimObj.ATI_Customer_Requests_Service_Date__c == null){
               response.status = false;
               response.errormessage = System.label.ATI_Claim_FillTurnAroundField;
               return response;
           }
        
        validateDate(claimObj.ATI_First_Labor_Applied_Date_Time__c, System.Label.ATI_Exception_FirstLaborAppliedDate_Time,System.Label.ATI_FirstLaborApplied_greaterToday);
        validateDate(claimObj.ATI_First_Part_Ordered_Date_Time__c, System.Label.ATI_FirstOrderDate_Time_null,System.Label.ATI_FirstOrder_greaterToday);
        validateDate(claimObj.ATI_Last_Part_Arrival_Date_Time__c, System.Label.ATI_LastPartArrivalDate_Time_nullcheck,System.Label.ATI_LastPartArrival_greaterToday);
        validateDate(claimObj.ATI_Repair_Order_Closed_Date_Time__c,System.Label.ATI_RepairOrderClosedDate_Time_nullCheck, System.Label.ATI_RepairClosedOrder_greaterToday);
        validateDate(claimObj.ATI_Vehicle_Arrival_Date_Time__c,System.Label.ATI_VehicleArrivalDate_Time_nullcheck,System.Label.ATI_VehicleArrivalDate_greaterToday);
        validateDate(claimObj.ATI_Completed_Repair_Cust_Noti_Date__c,System.Label.ATI_CompletedRepairCustomerNoticeDate_Time_nullcheck,System.Label.ATI_CustomerNotfcDate_greaterToday);
        validateDate(claimObj.ATI_Distributor_schedules_cust_Serv_Date__c,System.Label.ATI_DistributorScheduleDate_Time_nullcheck,System.Label.ATI_DistributorProvideDate_greaterToday);
        validateDate(claimObj.ATI_Customer_Requests_Service_Date__c,System.Label.ATI_CustomerRequestServiceDate_Time_nullcheck,System.Label.ATI_CustomerRequestDate_greaterToday);
        validateDate(claimObj.ATI_Customer_AuthorizeWork_Date_Time__c,System.Label.ATI_CustomerAuthorizeWork_nullcheck,System.Label.ATI_CustomerAuthorizeDate_greaterToday);
        if(claimObj.ATI_Repair_Order_Open_Time__c== null){
            turnAroundErrLst.add(System.label.ATI_RepairOrderOpenTime_nullcheck);
        }
        if(claimObj.ATI_Last_Labor_Recorded_Time__c== null){
            turnAroundErrLst.add(System.label.ATI_LastLaborRecordedTime_nullcheck);
        }
        if(!turnAroundErrLst.isEmpty()){
            response.status = false;
            response.errormessage = String.join(turnAroundErrLst,',  ');
        }
        return response;
        
    }
    
    public static void validateDate(DateTime dateTimeVal, String nullMsg, String afterToday){
        System.debug('inVlaidate Date--->'+dateTimeVal+'---> Null msg--->'+nullMsg+'---> afterToday--->'+afterToday);
        if(dateTimeVal == null){
            turnAroundErrLst.add(nullMsg);
        } else if (dateTimeVal.date() > System.today() && afterToday!=''){
            turnAroundErrLst.add(afterToday);
        } 
    }
    /*modification end*/
    
    /*
        Method Name :   beforeClaimSubmit
        Description :   1) Claim Submitter will be the owner of claim
    */
    global override WOD_2.ResponseWrapper beforeClaimSubmit(WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject) {
        System.debug('brInputWrapperObject------>'+brInputWrapperObject);
        try{
            if(brInputWrapperObject.ruleObjectIdList != NULL && !brInputWrapperObject.ruleObjectIdList.isEmpty()){
                WOD_2__Claim__c claimObj = [SELECT Id,OwnerId FROM WOD_2__Claim__c WHERE Id=:brInputWrapperObject.ruleObjectIdList[0]];
                if(claimObj.OwnerId != UserInfo.getUserId()){
                    claimObj.OwnerId = UserInfo.getUserId();
                    update claimObj;
                }
            }
        }catch(DMLException e){
            System.debug('errormessage>>>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('', false, e.getDMLMessage(0) + ' ' + e.getStackTraceString());
        }
        return new WOD_2.ResponseWrapper(JSON.serialize(brInputWrapperObject), true, '');
    }
}