/**
* (c) 2020 Tavant Technology.
----------------------------------------------------------------------------------------------------
ATI_BulkWarrantyRegistrationService, service class for Bulk Warranty Registration
* --------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        31-DEC-2020
* @modified
* --------------------------------------------------------------------------------------------------
* @changes		  
* --------------------------------------------------------------------------------------------------
*/

public without sharing class ATI_BulkWarrantyRegistrationService {
    
    /*
	Method Name :   saveWarrantyRegistrationInfo
	Params      :   Method to insert WarrantyRegistration data
	*/
    public static WOD_2.ResponseWrapper saveWarrantyRegistrationInfo(sObject wrInfoObject,sObject vehicleInfoObject,sObject customerInfoObject,sObject extendedPolicy,sObject wpInfoObject){
        //System.debug('wrInfoObject>>>>>> ' + wrInfoObject);
       	//System.debug('vehicleInfoObject>>>>> ' + vehicleInfoObject);
        //System.debug('customerInfoObject>>>>> ' + customerInfoObject);
        //System.debug('extendedPolicy>>>>>> ' + extendedPolicy);
        //System.debug('wpInfoObject>>>>>> ' + wpInfoObject);
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        WOD_2.ResponseWrapper vehicleInfoResponseWrapperObj1 = new WOD_2.ResponseWrapper('',false,'');
        Savepoint sp = Database.setSavepoint();
        //TriggerHandler.byPass('ATI_WntyRegistrationTriggerHandler');
        try {
            WOD_2__Warranty_Registration__c warrantyRegistrationObject = (WOD_2__Warranty_Registration__c)wrInfoObject;
            WOD_2.ResponseWrapper performC2CReRegisterRespWrapperObj = performC2COrReRegisterInventory(wrInfoObject,customerInfoObject,vehicleInfoObject,wpInfoObject);
            //Alsn-207 
            User u = [SELECT IsPortalEnabled FROM User WHERE Id=:UserInfo.getUserId()];
            String invId = warrantyRegistrationObject.WOD_2__Inventory__c;
            WOD_2__Inventory__c inv = [Select Id,WOD_2__Type__c from WOD_2__Inventory__c where Id=:invId];
            if(!u.IsPortalEnabled || inv.WOD_2__Type__c == 'Stock'){
                vehicleInfoResponseWrapperObj1 = saveVehicleInfo(vehicleInfoObject,warrantyRegistrationObject,customerInfoObject);
            }
            //end of Alsn-207
            if(!performC2CReRegisterRespWrapperObj.status){               
                WOD_2.ResponseWrapper validateWRResponseWrapperObj = validateWarrantyRegistration(warrantyRegistrationObject.WOD_2__Inventory__c,warrantyRegistrationObject.ATI_Pre_Delivery__c);
                if(validateWRResponseWrapperObj.status){
                    if(validateWRResponseWrapperObj.data == 'Standard Registration'){
                        WOD_2.WR_InventoryRegistrationWrapper inventoryRegWrapper = new WOD_2.WR_InventoryRegistrationWrapper();
                        warrantyRegistrationObject.WOD_2__Status__c = 'Draft';
                        if(warrantyRegistrationObject.ATI_Pre_Delivery__c){
                            warrantyRegistrationObject.WOD_2__Registration_Type__c = 'Pre-Delivery';
                        }else{
                            warrantyRegistrationObject.WOD_2__Registration_Type__c = 'Standard Registration'; 
                        }
                        warrantyRegistrationObject.WOD_2__Registration_Date__c = System.today();
                        //warrantyRegistrationObject.WOD_2__Batch_Log__c = batchLogId;
                        inventoryRegWrapper.registrationData = warrantyRegistrationObject;
                        if(inventoryRegWrapper.registrationData.WOD_2__Install_Date__c > System.today()){
                            return new WOD_2.ResponseWrapper('',false,Label.ATI_WR_Future_InService_Date_ValidationMessage);
                        }
                        inventoryRegWrapper.inventoryData = new WOD_2__Inventory__c(Id=warrantyRegistrationObject.WOD_2__Inventory__c);
                        inventoryRegWrapper = WOD_2.WR_UnmanagedUtility.saveWarrantyRegistration(inventoryRegWrapper);
                        warrantyRegistrationObject.Id = inventoryRegWrapper.registrationData.Id;
                        inventoryRegWrapper.inventoryData.WOD_2__Install_Date__c = warrantyRegistrationObject.WOD_2__Install_Date__c;
                        inventoryRegWrapper.inventoryData.ATI_Vocation_Code__c   = warrantyRegistrationObject.ATI_Vocation_Code__c;
                        Database.update(inventoryRegWrapper.inventoryData);
                        //ALSN-39 WOD_2__Customer_Billing_Country__c field added to the query
                        Map<Id,WOD_2__Warranty_Registration__c> warrantyRegistrationMap = new Map<Id,WOD_2__Warranty_Registration__c>([
                            SELECT id,WOD_2__Inventory__c,WOD_2__Registration_Date__c,ATI_Extended_Warranty_Purchase_Date__c,
                            WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Account__c,
                            WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Account__r.BillingCountry,
                            WOD_2__Inventory__r.WOD_2__Install_Date__c,ATI_Vocation_Code__c,WOD_2__Customer__c,WOD_2__Customer__r.BillingCountry,
                            ATI_Pre_Delivery__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c,WOD_2__Inventory__r.Vehicle_Information__c,ATI_Vocation_Code__r.Name,
                            WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c,WOD_2__Customer_Billing_Country__c FROM WOD_2__Warranty_Registration__c WHERE Id=:inventoryRegWrapper.registrationData.Id AND WOD_2__Status__c='Draft'
                        ]);
                        //System.debug('inventoryRegWrapper>>>>> '+inventoryRegWrapper.registrationData);
                        WOD_2.ResponseWrapper customerInfoResponseWrapperObj = saveCustomerInfo(customerInfoObject);
                        if(customerInfoResponseWrapperObj.status){
                            //System.debug('customerInfoResponseWrapperObj.data>>>> '+customerInfoResponseWrapperObj.data);
                            inventoryRegWrapper.registrationData.WOD_2__Customer__c = customerInfoResponseWrapperObj.data;
                            inventoryRegWrapper = WOD_2.WR_UnmanagedUtility.saveWarrantyRegistration(inventoryRegWrapper);
                            //ALSN-39 Changed the method call to include customer info
                            //WOD_2.ResponseWrapper vehicleInfoResponseWrapperObj = saveVehicleInfo(vehicleInfoObject,warrantyRegistrationMap.values().get(0),customerInfoObject);
                            if(vehicleInfoResponseWrapperObj1.status){
                                WOD_2.ResponseWrapper coverageResponseWrapperObj = saveWarrantyCoverages(inventoryRegWrapper.inventoryData,warrantyRegistrationMap,extendedPolicy);
                                if(coverageResponseWrapperObj.status){
                                    responseWrapperObj.data = warrantyRegistrationObject.Id;
                                    responseWrapperObj.status = true;
                                    return responseWrapperObj;
                                }else{
                                    Database.rollback(sp);
                                    responseWrapperObj.data = '';
                                    responseWrapperObj.status = false;
                                    responseWrapperObj.errormessage = coverageResponseWrapperObj.errormessage;
                                    return responseWrapperObj;
                                }
                            }
                        }
                    }else{
                        if(extendedPolicy != null){
                            WOD_2__Warranty_Registration__c warrantyRegistrationObjectExt = (WOD_2__Warranty_Registration__c)wrInfoObject;
                            WOD_2.ResponseWrapper validateEWRWrapper = validateExtendedWarrantyRegistration(wrInfoObject,customerInfoObject,vehicleInfoObject);
                            if(warrantyRegistrationObject.ATI_Extended_Warranty_Purchase_Date__c != null){
                                //ALSN-2 vehicle info update
                                //WOD_2.ResponseWrapper vehicleInfoResponseWrapperObj = saveVehicleInfo(vehicleInfoObject,warrantyRegistrationObjectExt,customerInfoObject);
                                if(validateEWRWrapper.status){
                                    WOD_2.ResponseWrapper extendedWarrantyCoverageWrapper = saveExtendedWarrantyCoverages(warrantyRegistrationObject,extendedPolicy);
                                    if(extendedWarrantyCoverageWrapper.status){
                                        responseWrapperObj.data = extendedWarrantyCoverageWrapper.data;
                                        responseWrapperObj.status = true;
                                        return responseWrapperObj;
                                    }else{
                                        Database.rollback(sp);
                                        responseWrapperObj.errormessage = extendedWarrantyCoverageWrapper.errormessage;
                                        return responseWrapperObj;
                                    }
                                }else{
                                    return new WOD_2.ResponseWrapper('',false,validateEWRWrapper.errormessage);
                                }
                            }else{
                                throw new ATI_Exception(Label.ATI_BulkWR_Ext_Purchase_Date_Validation);
                            }
                        }else{
                            return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_ExtendedPolicy_ValidationMessage);
                        }
                    }
                }
                else{
                    return new WOD_2.ResponseWrapper('',false,validateWRResponseWrapperObj.errormessage);
                }
            }else{
                responseWrapperObj.data = performC2CReRegisterRespWrapperObj.data;
                responseWrapperObj.status = true;
                return responseWrapperObj;
            }
            return responseWrapperObj;
        }catch(System.DmlException e) {
            Database.rollback(sp);
            String errMsg = '';
            return new WOD_2.ResponseWrapper('',false,errMsg);
        }catch (Exception e) {
            System.debug('catch Exception>>>>>> '+e.getMessage()+' >>>>> '+e.getLineNumber());
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    
    /*
Method Name :   performC2COrReRegisterInventory
Params      :   Method to Perform C2C or ReRegister Standard Registration
*/
    private static WOD_2.ResponseWrapper performC2COrReRegisterInventory(sObject wrInfoObject,sObject customerInfoObject,sObject vehicleInfoObject,sObject wpInfoObject){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            WOD_2__Warranty_Registration__c wrObjectData = (WOD_2__Warranty_Registration__c)wrInfoObject;
            ATI_Vehicle_Information__c vehicleInfoObjectData = (ATI_Vehicle_Information__c)vehicleInfoObject;
            WOD_2__Warranty_Product__c warrantyProductData = null;
            if(wpInfoObject != null){
                warrantyProductData = (WOD_2__Warranty_Product__c)wpInfoObject;
            }
            Account accountObjectData = (Account)customerInfoObject;
            List<WOD_2__Warranty_Registration__c> wrLst = [SELECT id,WOD_2__Account__c,WOD_2__Account__r.Name,WOD_2__Install_Date__c,ATI_Vocation_Code__c,WOD_2__Inventory__r.WOD_2__Customer__r.Name,
                                                           WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity,WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode,WOD_2__Inventory__r.WOD_2__Customer__c
                                                           FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c =:wrObjectData.WOD_2__Inventory__c
                                                           AND WOD_2__Registration_Type__c='Standard Registration' AND WOD_2__Status__c='Registered' AND WOD_2__Inventory__r.WOD_2__Type__c='Retail'];
            if(!wrLst.isEmpty()){
                System.debug('wrLst---' + wrLst);
                User u = [SELECT IsPortalEnabled FROM User WHERE Id=:UserInfo.getUserId()];
                System.debug('wpInfo>>> '+u.IsPortalEnabled +' >>> '+warrantyProductData+ ' >>>> '+wrObjectData.WOD_2__Warranty_Product__c);
                if(!u.IsPortalEnabled && ((warrantyProductData != null && warrantyProductData.Id != wrObjectData.WOD_2__Warranty_Product__c) || wrObjectData.ATI_Vocation_Code__c != wrLst.get(0).ATI_Vocation_Code__c || wrObjectData.WOD_2__Install_Date__c != wrLst.get(0).WOD_2__Install_Date__c)){
                    WOD_2__Inventory__c invObject = new WOD_2__Inventory__c(Id=wrObjectData.WOD_2__Inventory__c);
                    if(warrantyProductData != null){
                        invObject.WOD_2__Item__c = warrantyProductData.id;
                    }
                    invObject.ATI_Vocation_Code__c = wrObjectData.ATI_Vocation_Code__c;
                    invObject.WOD_2__Install_Date__c = wrObjectData.WOD_2__Install_Date__c;
                    //ALSN-2 Business Partner update
                    invObject.WOD_2__Account__c = wrObjectData.WOD_2__Account__c;
                    if(wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c != null){
                        //ALSN-2
                        if(!accountObjectData.Name.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.Name) ||
                           (accountObjectData.BillingCity != null && wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity != null && !accountObjectData.BillingCity.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity)) ||
                           (accountObjectData.BillingPostalCode != null && wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode != null && !accountObjectData.BillingPostalCode.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode))){
                               WOD_2.ResponseWrapper responseWrapper = saveCustomerInfo(customerInfoObject);
                               if(responseWrapper.status){
                                   if(wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c != responseWrapper.data){
                                       invObject.WOD_2__Customer__c = responseWrapper.data;
                                       //ALSN-2
                                       wrLst[0].WOD_2__Customer__c = responseWrapper.data;
                                       WOD_2__Inventory_Transaction_History__c invTransHistory = new WOD_2__Inventory_Transaction_History__c();
                                       invTransHistory.WOD_2__Transfer_Date__c = Date.today();
                                       invTransHistory.WOD_2__Transaction_Type__c = 'Customer to Customer';
                                       invTransHistory.WOD_2__From__c = wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c;
                                       invTransHistory.WOD_2__To__c = responseWrapper.data;
                                       invTransHistory.WOD_2__Status__c = 'Approved';
                                       invTransHistory.WOD_2__Inventory__c = wrLst[0].WOD_2__Inventory__c;
                                       Database.insert(invTransHistory);
                                   }
                               }
                           }
                    }                    
                    //Alsn-207
                    ATI_InventoryTriggerHandler.isBulkUpload = true;
                    Database.update(wrLst);
                    Database.SaveResult result =  Database.update(invObject);
                      WOD_2__Warranty_Registration__c warratyReg = [SELECT Id FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c=:result.id AND WOD_2__Registration_Type__c='Standard Registration' AND WOD_2__Status__c='Registered' AND Id !=: wrLst.get(0).Id];
                    return new WOD_2.ResponseWrapper(warratyReg.id,true,'');
                }
                if(wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c != null){
                    WOD_2__Inventory__c invObject = new WOD_2__Inventory__c(Id=wrObjectData.WOD_2__Inventory__c);
                    //ALSN-2 Business Partner update
                    invObject.WOD_2__Account__c = wrObjectData.WOD_2__Account__c;
                    if(!accountObjectData.Name.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.Name) ||
                       (accountObjectData.BillingCity != null && wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity != null && !accountObjectData.BillingCity.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingCity)) ||
                       (accountObjectData.BillingPostalCode != null && wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode != null && !accountObjectData.BillingPostalCode.equalsIgnoreCase(wrLst.get(0).WOD_2__Inventory__r.WOD_2__Customer__r.BillingPostalCode))){
                           WOD_2.ResponseWrapper responseWrapper = saveCustomerInfo(customerInfoObject);
                           if(responseWrapper.status){
                               if(wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c != responseWrapper.data){
                                   invObject.WOD_2__Customer__c = responseWrapper.data;
                                   //ALSN-2
                                   wrLst[0].WOD_2__Customer__c = responseWrapper.data;
                                   WOD_2__Inventory_Transaction_History__c invTransHistory = new WOD_2__Inventory_Transaction_History__c();
                                   invTransHistory.WOD_2__Transfer_Date__c = Date.today();
                                   invTransHistory.WOD_2__Transaction_Type__c = 'Customer to Customer';
                                   invTransHistory.WOD_2__From__c = wrLst[0].WOD_2__Inventory__r.WOD_2__Customer__c;
                                   invTransHistory.WOD_2__To__c = responseWrapper.data;
                                   invTransHistory.WOD_2__Status__c = 'Approved';
                                   invTransHistory.WOD_2__Inventory__c = wrLst[0].WOD_2__Inventory__c;
                                   Database.insert(invTransHistory);
                                   //Database.update(invObject);
                                   //ALSN-2 update WR and if extended WR exists update customer data on that too.
                                   Database.update(wrLst);
                                   List<WOD_2__Warranty_Registration__c> extWarratyReg = new List<WOD_2__Warranty_Registration__c>();
                                   extWarratyReg = [SELECT Id,WOD_2__Customer__c,WOD_2__Customer_Billing_Street__c,WOD_2__Customer_Billing_City__c,WOD_2__Customer_Billing_State__c,WOD_2__Customer_Billing_Country__c,WOD_2__Customer_Billing_Zipcode__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c=:invObject.id AND WOD_2__Registration_Type__c='Extended' AND (WOD_2__Status__c='Registered'OR WOD_2__Status__c Like 'Pending%') AND Id !=: wrLst.get(0).Id limit 1];
                                   if(extWarratyReg != null && extWarratyReg.size() >0){
                                   		extWarratyReg.get(0).WOD_2__Customer__c = responseWrapper.data;
                                   		update extWarratyReg;
                                   }
                                   return new WOD_2.ResponseWrapper(wrLst.get(0).Id,false,'');
                               }
                           }
                       }
                    //ALSN-2 moving it outside the if condition for customer change to handle business partner update
                    Database.update(invObject);
                }
            }
            return responseWrapperObj;
        }catch(DmlException e){
            throw new ATI_Exception(e.getMessage());
        }catch(Exception e){
            System.debug('Catch Exception>>>>> '+e.getMessage()+' >>>>> '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   validateWarrantyRegistration
	Params      :   Method to validateWarrantyRegistration
	*/
    private static WOD_2.ResponseWrapper validateWarrantyRegistration(Id invId,Boolean preDeliveryCheck){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
        try{
            List<String> wrFields = new List<String>{'ATI_isExtended__c','WOD_2__Registration_Type__c', 'ATI_Pre_Delivery__c','WOD_2__Status__c','WOD_2__Inventory__c'};
                ATI_Utils.NoAccessObjectFieldWrapper wrNoAccessWrapper = ATI_Utils.fetchCreateAccess('WOD_2__Warranty_Registration__c',wrFields);
            if(wrNoAccessWrapper.noAccessObjectList.size() == 0 && wrNoAccessWrapper.noAccessFieldList.size() == 0) {
                
                List<WOD_2__Warranty_Registration__c> wrLst = [SELECT id,ATI_isExtended__c,WOD_2__Registration_Type__c,ATI_Pre_Delivery__c,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c 
                                                               WHERE WOD_2__Inventory__c = :invId AND (WOD_2__Status__c = 'In Progress' OR WOD_2__Status__c = 'Pending Warranty Processor Approval' OR WOD_2__Status__c = 'Registered')];
                if(!wrLst.isEmpty() && wrLst.size()>0){
                    Integer extendedRegCount = 0;
                    Integer preDeliveryWR = 0;
                    Integer standardWR = 0;
                    Integer extendedWR = 0;
                    for(WOD_2__Warranty_Registration__c wr: wrLst){
                        if(wr.ATI_Pre_Delivery__c && (wr.WOD_2__Status__c != 'Registered' || preDeliveryCheck)){
                            preDeliveryWR++;
                        }
                        if(wr.WOD_2__Registration_Type__c == 'Standard Registration' && (wr.WOD_2__Status__c != 'Registered' || (wr.WOD_2__Status__c == 'Registered' && wr.ATI_isExtended__c))){
                            standardWR++;
                        }
                        if(!wr.ATI_isExtended__c && (wr.WOD_2__Registration_Type__c == 'Standard Registration' || wr.WOD_2__Registration_Type__c == 'Extended') && wr.WOD_2__Status__c == 'Registered'){
                            extendedRegCount++;
                        }
                        if(wr.WOD_2__Registration_Type__c == 'Extended'){
                            extendedWR++;
                        }
                    }
                    if(preDeliveryWR>0){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_PreDelivery_InProgress_ValidationMessage);
                    }
                    if(preDeliveryCheck){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_PreDeliveryValidationErrorOnRetail);
                    }
                    if(standardWR>0){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_InProgress_ValidationMessage);
                    }
                    if(extendedWR>0){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_Extended_InProgress_ValidationMessage);
                    }
                    if(extendedRegCount>0){
                        responseWrapperObj.data = 'Extended';
                    }else{
                        responseWrapperObj.data = 'Standard Registration';
                    }
                    
                }else{
                    responseWrapperObj.data = 'Standard Registration';
                }
            }else{
                throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            }
            return responseWrapperObj;
        }catch(Exception e){
            //System.debug('Catch Exception>>>>> '+e.getMessage()+' >>>>> '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   validateExtendedWarrantyRegistration
	Params      :   Method to validate extended WR
	*/
    private static WOD_2.ResponseWrapper validateExtendedWarrantyRegistration(sObject wrInfoObject,sObject customerInfoObject,sObject vehicleInfoObject){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
        try{
            WOD_2__Warranty_Registration__c wrObjectData = (WOD_2__Warranty_Registration__c)wrInfoObject;
            ATI_Vehicle_Information__c vehicleInfoObjectData = (ATI_Vehicle_Information__c)vehicleInfoObject;
            Account accountObjectData = (Account)customerInfoObject;
            List<String> wrFields = new List<String>{'WOD_2__Account__c','WOD_2__Install_Date__c', 'ATI_Vocation_Code__c', 'WOD_2__Customer__r.Name','WOD_2__Customer__r.BillingCity','WOD_2__Customer__r.BillingPostalCode'};
                ATI_Utils.NoAccessObjectFieldWrapper wrNoAccessWrapper = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',wrFields);
            if(wrNoAccessWrapper.noAccessObjectList.size() == 0 && wrNoAccessWrapper.noAccessFieldList.size() == 0) {
                Account acc = [SELECT Id,Name FROM Account WHERE Id=:wrObjectData.WOD_2__Account__c];
                List<WOD_2__Warranty_Registration__c> wrLst = [SELECT id,WOD_2__Account__c,WOD_2__Account__r.Name,WOD_2__Install_Date__c,ATI_Vocation_Code__c,WOD_2__Customer__r.Name,
                                                               WOD_2__Customer__r.BillingCity,WOD_2__Customer__r.BillingPostalCode
                                                               FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c =:wrObjectData.WOD_2__Inventory__c
                                                               AND WOD_2__Registration_Type__c='Standard Registration' AND WOD_2__Status__c='Registered' AND WOD_2__Inventory__r.WOD_2__Type__c='Retail'];
                if(!wrLst.isEmpty()){
                    //ALSN-2 removing validation for customer info
                    /*if(!acc.Name.equalsIgnoreCase(wrLst.get(0).WOD_2__Account__r.Name) || 
                       wrObjectData.WOD_2__Install_Date__c != wrLst.get(0).WOD_2__Install_Date__c ||
                       wrObjectData.ATI_Vocation_Code__c != wrLst.get(0).ATI_Vocation_Code__c ||
                       !accountObjectData.Name.equalsIgnoreCase(wrLst.get(0).WOD_2__Customer__r.Name) ||
                       (accountObjectData.BillingCity != null && wrLst.get(0).WOD_2__Customer__r.BillingCity != null && !accountObjectData.BillingCity.equalsIgnoreCase(wrLst.get(0).WOD_2__Customer__r.BillingCity)) ||
                       (accountObjectData.BillingPostalCode != null && wrLst.get(0).WOD_2__Customer__r.BillingPostalCode != null && !accountObjectData.BillingPostalCode.equalsIgnoreCase(wrLst.get(0).WOD_2__Customer__r.BillingPostalCode))){
                          return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_Extended_InvalidWR_ValidationMessage);
                       }*/
                    
                    if(wrObjectData.ATI_Vocation_Code__c != wrLst.get(0).ATI_Vocation_Code__c){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_Extended_Invalid_Vocation_Code);
                    }
                    if(wrObjectData.WOD_2__Install_Date__c != wrLst.get(0).WOD_2__Install_Date__c){
                        return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_Extended_Invalid_Inservice_Date);
                    }
                }
            }else{
                throw new ATI_Exception('(Warranty Registration) '+Label.ATI_Log_Insufficient_access);
            }
            //ALSN-2 removing validation for vehicle info
            /*List<String> vehicleInfoFields = new List<String>{'ATI_Vehicle_Information__r.Name','ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c', 'ATI_Vehicle_Information__r.ATI_Vehicle_Make__c', 'ATI_Vehicle_Information__r.ATI_Vehicle_Model__c'};
                ATI_Utils.NoAccessObjectFieldWrapper vehicleInfoNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess('ATI_VIN_Transmission_Mapper__c',vehicleInfoFields);
            if(vehicleInfoNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && vehicleInfoNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                List<ATI_VIN_Transmission_Mapper__c> vehicleInfoLst = [SELECT Id,ATI_Vehicle_Information__r.Name,ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c,ATI_Vehicle_Information__r.ATI_Vehicle_Model__c,ATI_Vehicle_Information__r.ATI_Vehicle_Make__c FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:wrObjectData.WOD_2__Inventory__c];
                if(!vehicleInfoLst.isEmpty()){
                    if(!vehicleInfoObjectData.Name.equalsIgnoreCase(vehicleInfoLst.get(0).ATI_Vehicle_Information__r.Name) ||
                       vehicleInfoObjectData.ATI_Vehicle_Usage__c != vehicleInfoLst.get(0).ATI_Vehicle_Information__r.ATI_Vehicle_Usage__c ||
                       !vehicleInfoObjectData.ATI_Vehicle_Model__c.equalsIgnoreCase(vehicleInfoLst.get(0).ATI_Vehicle_Information__r.ATI_Vehicle_Model__c) ||
                       !vehicleInfoObjectData.ATI_Vehicle_Make__c.equalsIgnoreCase(vehicleInfoLst.get(0).ATI_Vehicle_Information__r.ATI_Vehicle_Make__c)){
                           return new WOD_2.ResponseWrapper('',false,Label.ATI_BulkWR_VehicleInfo_ValidationMessage);
                       }
                }
            }else{
                throw new ATI_Exception('(Vehicle Transmission Mapper) '+Label.ATI_Log_Insufficient_access);
            }*/
            return  responseWrapperObj;
        }catch(Exception e){
            //System.debug('validate exception>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   saveCustomerInfo
	Params      :   Method to insert/update customer data
	*/
    public static WOD_2.ResponseWrapper saveCustomerInfo(sObject customerInfoObject){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('', false, '');
        system.debug('Test Customer update');
        try{
            Account accInfo = (Account)customerInfoObject;
            List<Account> accData = null;
            if(accInfo.BillingCity != '' && accInfo.BillingPostalCode != ''){
                ATI_Utils.NoAccessObjectFieldWrapper accObjReadAccessCheck =  ATI_Utils.fetchReadAccess('Account',new List<String>{'Name','BillingCity','BillingPostalCode','WOD_2__Warranty_Account_Type__c'});
                if(accObjReadAccessCheck.noAccessObjectList.size() == 0 && accObjReadAccessCheck.noAccessFieldList.size() == 0) {
                    accData = [SELECT Id,Name,BillingCity,BillingPostalCode,WOD_2__Warranty_Account_Type__c FROM Account WHERE Name=:accInfo.Name AND BillingCity=:accInfo.BillingCity AND BillingPostalCode=:accInfo.BillingPostalCode AND WOD_2__Warranty_Account_Type__c='Customer' LIMIT 1];
                    if(!accData.isEmpty()){
                        return new WOD_2.ResponseWrapper(accData.get(0).id,true,'');
                    }
                }else{
                    throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access);
                }
            }
            if(accData == null || accData.isEmpty()){
                List<String> accFields = new List<String>{'Name','AccountNumber','BillingCity','BillingState',
                    'BillingStreet','BillingCountry','BillingPostalCode','ATI_Primary_Email_Id__c'};
                        ATI_Utils.NoAccessObjectFieldWrapper accObjCreateAccessCheck =  ATI_Utils.fetchCreateAccess('Account',accFields);
                if (accObjCreateAccessCheck.noAccessObjectList.size() == 0 && accObjCreateAccessCheck.noAccessFieldList.size() == 0) {
                    accInfo.ATI_Customer_Group__c = 'EU99';
                    accInfo.WOD_2__Warranty_Account_Type__c = 'Customer';
                    Database.saveResult insertData = Database.insert(accInfo);
                    if(insertData.isSuccess()){
                        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_DealerGroupNameForSharing');
                        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null){
                            Group customerGroup = [SELECT Id FROM Group WHERE Name=:logRecordValue.WOD_2__Configuration_Value__c];
                            if(customerGroup != null){
                                AccountShare acctShare = new AccountShare(
                                    AccountAccessLevel = 'Read',
                                    AccountId = insertData.getId(),
                                    OpportunityAccessLevel = 'None',
                                    UserOrGroupId = customerGroup.id
                                );
                                Database.insert(acctShare);
                            }
                        }
                        return new WOD_2.ResponseWrapper(insertData.getId(),true,'');
                    }
                }else{
                    throw new ATI_Exception('(Account) '+Label.ATI_Log_Insufficient_access);
                }
            }
            return responseWrapperObj;
        }catch(System.DmlException e) {
            System.debug('Exception>>>>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getDmlMessage(0));
        }catch(Exception e){
            System.debug('catch Exception>>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   saveVehicleInfo
	Params      :   Method to insert/update Vehicle information data
	*/
    //ALSN-39 Changed the method call
    public static WOD_2.ResponseWrapper saveVehicleInfo(sObject vehicleInformationObject,WOD_2__Warranty_Registration__c warrantyReg,sObject customerInfoObject){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            ATI_Vehicle_Information__c vehicleInfoData = (ATI_Vehicle_Information__c)vehicleInformationObject;
            Account customerAccountInfo = (Account)customerInfoObject;
            ATI_Usage_Codes__mdt usageMdt = [Select ATI_Usage_Codes__c,DeveloperName from ATI_Usage_Codes__mdt where DeveloperName='ATI_VIN_Usage_Codes']; 
            boolean usageCodeCondition = true;
            //ALSN-2
            WOD_2__Warranty_Code__c vocationCodeName = [Select Id,Name from WOD_2__Warranty_Code__c where Id =: warrantyReg.ATI_Vocation_Code__c];
            if(warrantyReg.ATI_Vocation_Code__c != null){
                usageCodeCondition = (!usageMdt.ATI_Usage_Codes__c.contains(vocationCodeName.Name));
            }
            //ALSN-39 changed the billing country check to that of Customer Country
            //ALSN-39 using the customerAccountInfo.BillingCountry to check the Country instead of warrantyReg
            if((customerAccountInfo.BillingCountry.equalsIgnoreCase('United States') ||  customerAccountInfo.BillingCountry.equalsIgnoreCase('US') ||
                customerAccountInfo.BillingCountry.equalsIgnoreCase('USA')) && usageCodeCondition &&
               !ATI_VehicleInformationController.checkRegex(vehicleInfoData.Name)){
                   throw new ATI_Exception(Label.ATI_VehicleInfoVINErrorMsg);	
               }
            
            if(Schema.getGlobalDescribe().get('ATI_Vehicle_Information__c').getDescribe().isAccessible()){
                List<ATI_Vehicle_Information__c> vehicleInfoLst = [SELECT Id,Name,ATI_Customer_asset_number__c,ATI_Vehicle_usage_mi_km_hr__c,ATI_Vehicle_Usage__c,ATI_Engine_Make__c,ATI_Vehicle_Make__c,ATI_Vehicle_Model__c,ATI_Engine_Model__c,ATI_Engine_Year__c,ATI_Executive_order_Designation__c FROM ATI_Vehicle_Information__c WHERE Name=:vehicleInfoData.Name];
                String vehicleInfoObjName = 'ATI_Vehicle_Information__c';
                List<String> vehicleInfoFields = new List<String>{'Name','ATI_Customer_asset_number__c','ATI_Vehicle_usage_mi_km_hr__c','ATI_Vehicle_Usage__c', 'ATI_Engine_Make__c', 'ATI_Vehicle_Make__c', 'ATI_Vehicle_Model__c', 'ATI_Engine_Model__c', 'ATI_Engine_Year__c', 'ATI_Executive_order_Designation__c'};
                    if(!vehicleInfoLst.isEmpty()){
                        vehicleInfoData.id = vehicleInfoLst.get(0).Id;
                        ATI_Utils.NoAccessObjectFieldWrapper vehicleInfoUpdateAccessFieldWrapper = ATI_Utils.fetchUpdateAccess(vehicleInfoObjName,vehicleInfoFields);
                        if (vehicleInfoUpdateAccessFieldWrapper.noAccessObjectList.size() == 0 && vehicleInfoUpdateAccessFieldWrapper.noAccessFieldList.size() == 0) {
                            Database.update(vehicleInfoData);
                            responseWrapperObj.data = JSON.serialize(vehicleInfoData);
                            responseWrapperObj.status=true;
                        }else{
                            throw new ATI_Exception('(Vehile Information) '+Label.ATI_Log_Insufficient_access);
                        }
                    }else{
                        ATI_Utils.NoAccessObjectFieldWrapper vehicleInfoNoAccessObjectFieldWrapper = ATI_Utils.fetchCreateAccess(vehicleInfoObjName,vehicleInfoFields);
                        if (vehicleInfoNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && vehicleInfoNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
                            Database.saveResult results = Database.insert(vehicleInformationObject);
                            vehicleInfoData.id = results.id;
                            responseWrapperObj.data = JSON.serialize(vehicleInformationObject);
                            responseWrapperObj.status=true;
                        }else{
                            throw new ATI_Exception('(Vehile Information) '+Label.ATI_Log_Insufficient_access);
                        }
                    }
                List<ATI_VIN_Transmission_Mapper__c> vinTransMapperLst = [SELECT Id,ATI_Vehicle_Information__c FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:warrantyReg.WOD_2__Inventory__c];
                if(vinTransMapperLst.isEmpty()){
                    Map<Id,ATI_Vehicle_Information__c> mapOfInvWithVehicleInfo = new Map<Id,ATI_Vehicle_Information__c>();
            		mapOfInvWithVehicleInfo.put(warrantyReg.WOD_2__Inventory__c,vehicleInfoData);
                    ATI_VehicleInformationController.createVehicleInfoMapper(mapOfInvWithVehicleInfo);
                }else{
                    vinTransMapperLst.get(0).ATI_Vehicle_Information__c = vehicleInfoData.id;
                    Database.update(vinTransMapperLst);
                }
                if(warrantyReg.WOD_2__Inventory__c != NULL){
                    ATI_Vehicle_Information__c vehicleObj = [SELECT Id,ATI_Vehicle_Mileage_Usage__c FROM ATI_Vehicle_Information__c 
                                                            	WHERE Name=:vehicleInfoData.Name ORDER BY LastModifiedDate DESC LIMIT 1];
                    WOD_2__Inventory__c invToUpdateObj = new WOD_2__Inventory__c(Id=warrantyReg.WOD_2__Inventory__c);
                    invToUpdateObj.WOD_2__Units_Usage__c = vehicleObj.ATI_Vehicle_Mileage_Usage__c; 
                    //ALSN-139
                    invToUpdateObj.Vehicle_Information__c = vehicleObj.Id;
                    //ALSN-139 END
                    TriggerHandler.bypass('ATI_InventoryTriggerHandler');
                    update invToUpdateObj;
                    TriggerHandler.clearBypass('ATI_InventoryTriggerHandler');
                }
                return responseWrapperObj;
            }else{
                throw new ATI_Exception('(Vehile Transmission Mapper) '+Label.ATI_Log_Insufficient_access);
            }
        }catch(System.DmlException e) {
            throw new ATI_Exception(e.getDmlMessage(0));
        }catch(Exception e) {
            //System.debug('Vehicle Info Exception>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   saveWarrantyCoverages
	Params      :   Method to insert/update WarrantyCoverages data and to create TMH record for Extended Policy
	*/	
    private static WOD_2.ResponseWrapper saveWarrantyCoverages(WOD_2__Inventory__c invData,Map<Id, WOD_2__Warranty_Registration__c> warrantyRegistrationMap,sObject extendedPolicy) {
        WOD_2.ResponseWrapper responseWrapperObj = new  WOD_2.ResponseWrapper('',false,'');
        //System.debug('warrantyRegistrationMap>>>> '+warrantyRegistrationMap.values().get(0));
        try{
            List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
            WOD_2__Warranty_Coverages__c extendedWarrantyCoverage = (WOD_2__Warranty_Coverages__c)extendedPolicy;
            ATI_extndWarrantyRegController.ExtendedWRPricingWrapper ewpWrapper = null;
            String policyOverrideClassName = 'ATI_BulkWRPolicyQueryOverride';
            if(extendedPolicy != null){
                ATI_BulkWRPolicyQueryOverride.policyDefList = new List<Id>{extendedWarrantyCoverage.WOD_2__Policy_Definition__c};
            }
            if(warrantyRegistrationMap.values().get(0).ATI_Pre_Delivery__c){
                policyOverrideClassName = 'ATI_PreDeliveryPolicyOverride';
                extendedPolicy = null;
            }
            WOD_2.WR_WarrantyRegistrationResponse wrATRuleEngineWrapper = ATI_WarrantyService.runEngine(warrantyRegistrationMap,policyOverrideClassName);
            List<Id> extendedPolicyIds = new List<Id>();
            for(WOD_2.WR_RegistrationResponse wr : wrATRuleEngineWrapper.response.values()) {
                if(wr.warrantyCoverages.size() > 0){
                    for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                        if(coverage.WOD_2__Policy_Definition__c != null){
                            if(extendedWarrantyCoverage != null && (coverage.WOD_2__Policy_Definition__c == extendedWarrantyCoverage.WOD_2__Policy_Definition__c)){
                                extendedPolicyIds.add(coverage.WOD_2__Policy_Definition__c);
                            }
                            warrantyCoveragesList.add(coverage);
                        } 
                    }
                }
            }
            if(!warrantyCoveragesList.isEmpty() || (extendedPolicy != null && extendedPolicyIds.size() > 0)){
                if(extendedPolicy != null && extendedPolicyIds.size()>0){
                    if(warrantyRegistrationMap.values().get(0).ATI_Extended_Warranty_Purchase_Date__c != null){
                        WOD_2.ResponseWrapper ewpResponseWrapper = ATI_extndWarrantyRegController.getExtendedWarrantyPricing(extendedPolicyIds,warrantyRegistrationMap.values().get(0).Id);
                        if(ewpResponseWrapper.status){
                            ewpWrapper = (ATI_extndWarrantyRegController.ExtendedWRPricingWrapper)JSON.deserialize(ewpResponseWrapper.data,ATI_extndWarrantyRegController.ExtendedWRPricingWrapper.class);
                            if(ewpWrapper.exPricingList.size() == 0){
                                throw new ATI_Exception(Label.ATI_ETC_Pricing_Error);
                            }
                        }else{
                            throw new ATI_Exception(ewpResponseWrapper.errormessage);
                        }
                    }else{
                        throw new ATI_Exception(Label.ATI_BulkWR_Ext_Purchase_Date_Validation);
                    }
                }  
                WOD_2.WR_CoverageInputWrapper covrageWrapper = new WOD_2.WR_CoverageInputWrapper();
                covrageWrapper.coverages = warrantyCoveragesList;
                covrageWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
                //system.debug('warrantyRegistrationMap.values()==='+covrageWrapper.coverages[0]);
                covrageWrapper.wrRecordIds = new List<Id>{warrantyRegistrationMap.values().get(0).Id};
                    WOD_2.ResponseWrapper coverageWrapperObj = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);
                //System.debug('coverageWrapperObj>>>>> '+coverageWrapperObj);
                if(coverageWrapperObj.status){
                    if(ewpWrapper != null){
                        ATI_extndWarrantyRegController.createTransaction(warrantyRegistrationMap.values().get(0).Id,JSON.serialize(ewpWrapper));
                        responseWrapperObj.status = true;
                    }else{
                        return new WOD_2.ResponseWrapper('',true,'');
                    }
                }else{
                    return new WOD_2.ResponseWrapper('',false,coverageWrapperObj.errormessage);
                }
                return responseWrapperObj;
            }else{
                throw new ATI_Exception(Label.ATI_BulkWR_NoPolicyFound_ValidationMessage);
            }
        }catch(DMLException e){
            throw new ATI_Exception(e.getDmlMessage(0));
        }catch(Exception e){
            System.debug('Exception while saving coverages>>>>>>> '+e.getMessage()+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }
    }
    
    /*
	Method Name :   saveExtendedWarrantyCoverages
	Params      :   Method to insert/update Extended WarrantyCoverages data and insert TMH Record
	*/
    private static WOD_2.ResponseWrapper saveExtendedWarrantyCoverages(WOD_2__Warranty_Registration__c wrObj,sObject extendedPolicy){
        WOD_2.ResponseWrapper responseWrapperObj = new  WOD_2.ResponseWrapper('',false,'');
        try{
            WOD_2__Warranty_Coverages__c extendedWarrantyCoverage = (WOD_2__Warranty_Coverages__c)extendedPolicy;
            Map<Id, WOD_2__Inventory__c> invMap = new Map<Id, WOD_2__Inventory__c>(ATI_WarrantyService.getInventoriesForWR(new List<Id>{wrObj.WOD_2__Inventory__c}));
            List<WOD_2__Warranty_Registration__c> wrLst = ATI_WarrantyService.getWRListForInventories(invMap);
            wrLst = ATI_WarrantyService.cloneWRsForRegistration(wrLst,'Extended', false, invMap);
            wrLst[0].ATI_Extended_Warranty_Purchase_Date__c = wrObj.ATI_Extended_Warranty_Purchase_Date__c;
            wrLst[0].ATI_Tracking_Number__c = wrObj.ATI_Tracking_Number__c != NULL ? wrObj.ATI_Tracking_Number__c : '';
            wrLst[0].ATI_CE_Number__c = wrObj.ATI_CE_Number__c != NULL ? wrObj.ATI_CE_Number__c : '';
            wrLst[0].ATI_PO_Number__c = wrObj.ATI_PO_Number__c != NULL ? wrObj.ATI_PO_Number__c : '';
            //ALSN-2
            if(wrObj.WOD_2__Account__c != null || wrObj.WOD_2__Account__c != ''){
                wrLst[0].WOD_2__Account__c = wrObj.WOD_2__Account__c;
            }
            Database.insert(wrLst);
            Map<Id,WOD_2__Warranty_Registration__c> warrantyRegistrationMap = new Map<Id,WOD_2__Warranty_Registration__c>(wrLst);
            ATI_ExtendedPolicyQueryOverride.policyDefList = new List<Id>{extendedWarrantyCoverage.WOD_2__Policy_Definition__c};
                WOD_2.WR_WarrantyRegistrationResponse responseWrapper = ATI_WarrantyService.runEngine(warrantyRegistrationMap,'ATI_ExtendedPolicyQueryOverride');
            List<Id> policyDefIdList = new List<Id>();
            List<WOD_2__Warranty_Coverages__c> warrantyCoveragesList = new List<WOD_2__Warranty_Coverages__c>();
            for(WOD_2.WR_RegistrationResponse wr : responseWrapper.response.values()) {
                if(wr.warrantyCoverages.size() > 0){
                    for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                        if(coverage.WOD_2__Policy_Definition__c != null){
                            policyDefIdList.add(coverage.WOD_2__Policy_Definition__c);
                            warrantyCoveragesList.add(coverage);
                        } 
                    }
                }
            }
            if(!warrantyCoveragesList.isEmpty()){
                WOD_2.ResponseWrapper ewpResponseWrapper = ATI_extndWarrantyRegController.getExtendedWarrantyPricing(policyDefIdList,warrantyRegistrationMap.values().get(0).Id);
                if(ewpResponseWrapper.status){
                    ATI_extndWarrantyRegController.ExtendedWRPricingWrapper ewpWrapper = (ATI_extndWarrantyRegController.ExtendedWRPricingWrapper)JSON.deserialize(ewpResponseWrapper.data,ATI_extndWarrantyRegController.ExtendedWRPricingWrapper.class);
                    if(ewpWrapper.exPricingList.size()>0){
                        WOD_2.WR_CoverageInputWrapper covrageWrapper = new WOD_2.WR_CoverageInputWrapper();
                        covrageWrapper.coverages = warrantyCoveragesList;
                        covrageWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
                        covrageWrapper.wrRecordIds = new List<Id>{warrantyRegistrationMap.values().get(0).Id};
                            WOD_2.ResponseWrapper coverageWrapperObj = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);
                        if(coverageWrapperObj.status){
                            ATI_extndWarrantyRegController.createTransaction(warrantyRegistrationMap.values().get(0).Id,JSON.serialize(ewpWrapper));
                            return new WOD_2.ResponseWrapper(warrantyRegistrationMap.values().get(0).Id,true,'');
                        }
                    }else{
                        throw new ATI_Exception(Label.ATI_ETC_Pricing_Error);
                    }
                }else{
                    throw new ATI_Exception(ewpResponseWrapper.errormessage);
                }
            }else{
                throw new ATI_Exception(Label.ATI_BulkWR_NoPolicyFound_ValidationMessage);
            }
            return responseWrapperObj;
        }catch(DMLException e){
            throw new ATI_Exception(e.getDmlMessage(0));
        }catch(Exception e){
            System.debug('message>>>> '+e.getMessage()+' : '+e.getLineNumber());
            throw new ATI_Exception(e.getMessage());
        }   
    }
}