/* Name: ATI_WR_RegistrationHandler
Description : ATI_WR_RegistrationHandler - WR Handler for ATI.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      26-DEC-2020          INITIAL DEVELOPMENT
*/
global class ATI_WR_RegistrationHandler extends WOD_2.WR_RegistrationHandler{
    //Alsn-161 added duplicatewr
    public static Boolean duplicatewr = true;
    global override WOD_2.ResponseWrapper saveWarrantyRegistration(WOD_2.WR_InventoryRegistrationWrapper inventoryRegWrapper){
        WOD_2.ResponseWrapper responseObject = new WOD_2.ResponseWrapper('',true,'');
        try{
            
            WOD_2__Inventory__c inv = [select WOD_2__Install_Date__c,WOD_2__Scrapped__c,WOD_2__Customer__c, ATI_Vocation_Code__c,WOD_2__Manufacturing_Date__c from WOD_2__Inventory__c where id = :inventoryRegWrapper.inventoryData.Id];
            //ALSN-37 InventoryReplaceHistoryquery added by konda Susmitha
            List<ATI_Inventory_Replacement_History__c> irh = [SELECT Id,ATI_Failed_Inventory__c ,ATI_Failed_Inventory__r.WOD_2__Manufacturing_Date__c,ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c FROM ATI_Inventory_Replacement_History__c where ATI_Replaced_Inventory__c =:inventoryRegWrapper.inventoryData.Id ORDER BY CreatedDate DESC Limit 1];
            List<WOD_2__Warranty_Registration__c> wrLst = [SELECT Id from WOD_2__Warranty_Registration__c 
                                                           WHERE WOD_2__Inventory__c = :inventoryRegWrapper.inventoryData.Id
                                                           AND (WOD_2__Status__c='In Progress' OR WOD_2__Status__c='Pending Warranty Processor Approval')];
            if(!wrLst.isEmpty()){
                throw new TWoDException(System.Label.Please_Approve_pending_WR);
            }
            
            System.debug('>>> WOD_2__Scrapped__c :'+inv.WOD_2__Scrapped__c);
            if(inv.WOD_2__Scrapped__c== true){
                throw new TWoDException('You can\'t Register scrapped Inventory!!!');
            }
            
            // TBD : Before Load class ?
            /*User loggedInUser = [SELECT AccountId,IsPortalEnabled,UserType FROM User WHERE id =:userinfo.getUserId()];
if(loggedInUser.IsPortalEnabled){
inventoryRegWrapper.registrationData.WOD_2__Account__c = loggedInUser.AccountId;
}*/
            inventoryRegWrapper.registrationData.WOD_2__Registration_Date__c = System.today();
            if(inventoryRegWrapper.registrationData.ATI_Pre_Delivery__c !=false){
                inventoryRegWrapper.registrationData.WOD_2__Registration_Type__c ='Pre-delivery';
            }else{
                inventoryRegWrapper.registrationData.WOD_2__Registration_Type__c ='Standard Registration';
            }
            
            //inventoryRegWrapper.registrationData.WOD_2__Registration_Date__c = System.today();
            // Added By Mukesh 01/06/2021 Start
            if(inventoryRegWrapper.registrationData.ATI_Pre_Delivery__c == false){
                if(inventoryRegWrapper.registrationData.WOD_2__Install_Date__c == null){
                    throw new TWoDException(Label.ATI_WR_InstallDateMandatory); 
                    //ALSN-37 Added new condition to check against replaced inventory
                } else if(irh.size() > 0 && irh[0].ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c != null && (inventoryRegWrapper.registrationData.WOD_2__Install_Date__c < irh[0].ATI_Original_Inventory__r.WOD_2__Manufacturing_Date__c)){
                    throw new TWoDException(Label.ATI_WR_InstallDateGtManufacturingDate);
                }else if(irh.Size() == 0 && inv.WOD_2__Manufacturing_Date__c != null && inventoryRegWrapper.registrationData.WOD_2__Install_Date__c < inv.WOD_2__Manufacturing_Date__c){
                    throw new TWoDException(Label.ATI_WR_InstallDateGtManufacturingDate);
                }
            } 
            if(inventoryRegWrapper.registrationData.ATI_Pre_Delivery__c == true && inventoryRegWrapper.registrationData.WOD_2__Install_Date__c != null){
                throw new TWoDException(Label.ATI_WR_installDEmptyCheck);
            }
            
            if(String.isBlank(inventoryRegWrapper.registrationData.WOD_2__Account__c)){
                throw new TWoDException(Label.ATI_Mandatory_Account);  
            }
            
            //Added by Dishari on 07/16/21 for 27233 Throwing error if Account SAPID have 5 digit 
            List<Account> acclst = [SELECT ID,SAP_ID__c,ATI_Account_Name__c FROM Account WHERE Id =: inventoryRegWrapper.registrationData.WOD_2__Account__c];
            String accSAPId = acclst[0].SAP_ID__c;
            //ALSN-212 updated the existing regex to check if first 5 characters are 0
            //Previous regex: ^[0-9]{5}$... New regex: ^[0]{5}[0-9]{5}$            
            Pattern patternSAPId = Pattern.compile('^[0]{5}[0-9]{5}$');
            Boolean sapId = Pattern.matches('^[0]{5}[0-9]{5}$', accSAPId);
            //ALSN-212 end
            Integer intSAPId = accSAPId.length();
            System.debug('sapId'+sapId);
            String AccountName = acclst[0].ATI_Account_Name__c;
            //ALSN-142
            //ALSN-212 Updated the condition to trigger even if SAP Id length is not 10
            if(sapId || intSAPId != 10 || AccountName.Contains('Subparent')){
                throw new TWoDException(Label.ATI_Account_5_digit_SAPId);  
            }
            //ALSN-142 END
            // End here for 27233 Throwing error if Account SAPID have 5 digit
            // Alsn-161
            if(duplicatewr == true){
                List<WOD_2__Warranty_Registration__c> wrList = [SELECT Id from WOD_2__Warranty_Registration__c 
                                                                WHERE WOD_2__Inventory__c = :inventoryRegWrapper.inventoryData.Id
                                                                AND ((WOD_2__Status__c='Draft' OR WOD_2__Status__c ='Registered' or WOD_2__Status__c='Pending Distributor Approval') and ATI_Pre_Delivery__c =false)];
                List<WOD_2__Warranty_Registration__c> wrPreDel = [Select Id from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :inventoryRegWrapper.inventoryData.Id AND ((WOD_2__Status__c = 'Draft' OR WOD_2__Status__c ='Registered') and ATI_Pre_Delivery__c=true)];                                                     
                if((wrList.size()>0 && inventoryRegWrapper.registrationData.Id==null)||(wrPreDel.size()>0 && inventoryRegWrapper.registrationData.WOD_2__Install_Date__c ==null)){               
                    throw new TWoDException(Label.ATI_Duplicate_WR);
                }       
            }
            //End of Alsn-161
            if((inventoryRegWrapper.registrationData.ATI_Vocation_Code__c == null || ATI_Utils.checkIsBlankData(inventoryRegWrapper.registrationData.ATI_Vocation_Code__c)) && inventoryRegWrapper.registrationData.ATI_Pre_Delivery__c==false){
                throw new TWoDException(Label.ATI_WR_vcMandatory);
            }
            /* if( String.isBlank(inventoryRegWrapper.registrationData.WOD_2__Registration_Comments__c)){
throw new TWoDException(Label.ATI_WR_commentMandatory);
} */
            
            // Added By Mukesh 01/06/2021 End
            if(inventoryRegWrapper.registrationData.WOD_2__Install_Date__c > System.today()){
                throw new TWoDException(Label.ATI_WR_Future_InService_Date_ValidationMessage);
            }
            /*if(inventoryRegWrapper.registrationData.ATI_Extended_Warranty_Purchase_Date__c < inventoryRegWrapper.registrationData.WOD_2__Install_Date__c){
throw new TWoDException(Label.ATI_Purchase_Less_Install_Date);
}*/
            
            //WOD_2.WR_UnmanagedUtility.saveWarrantyRegistration(inventoryRegWrapper);
            inv.WOD_2__Install_Date__c = inventoryRegWrapper.registrationData.WOD_2__Install_Date__c;
            inv.ATI_Vocation_Code__c = inventoryRegWrapper.registrationData.ATI_Vocation_Code__c;
            
            WOD_2.WR_UnmanagedUtility.saveWarrantyRegistration(inventoryRegWrapper);
            update inv;
              // Alsn - 162.. previously the below logic happened before the save Warranty registration method.. now we have moved this part of code
            // after save warranty registration   
                        
            List<WOD_2.TWoD_RecordOutputWrapper> registrationOutputWrapperList = new List<WOD_2.TWoD_RecordOutputWrapper>();
            WOD_2.BR_BusinessRuleEngineWrapper brInputWrapperObject = new WOD_2.BR_BusinessRuleEngineWrapper();            
            // WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper();
            // responseWrapper.status = true;
            brInputWrapperObject.buId = inventoryRegWrapper.inventoryData.WOD_2__Business_Unit__c;
            brInputWrapperObject.configType = 'Rule';
            brInputWrapperObject.moduleName = 'Warranty Registration';
            brInputWrapperObject.ruleObjectAPIName = 'ATI_Warranty_Registration__c';
            brInputWrapperObject.configNameList =null;
            brInputWrapperObject.ruleObjectIdList = new List<Id>{inventoryRegWrapper.registrationData.Id};
            System.debug('Business Rule Engine--->'+brInputWrapperObject);
            registrationOutputWrapperList = WOD_2.BR_BusinessRuleEngineUtility.invokeRecordSubmitHandler(brInputWrapperObject);
            System.debug('Regstration Output List--->'+registrationOutputWrapperList);
            // end of Alsn -162
            responseObject.data = JSON.serialize(inventoryRegWrapper.registrationData);
            System.debug('responseObject--->'+responseObject.data);
            return responseObject;
        }
        catch(Exception excp) {
            responseObject.errormessage = excp.getMessage();
            responseObject.status = false;
            return responseObject;
        }
    }
}