/* Name: ATI_extndWarrantyRegController
Description : This class is used to save and submit Extended Warranty Registrations. 
Author : Tavant(Punam Chakraborty)
History:
VERSION     AUTHOR                                DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(Punam Chakraborty)            15/12/2020                  INITIAL DEVELOPMENT                              
*/

public without sharing class ATI_extndWarrantyRegController {

    /*
        Method Name :   getPolicyDetails
        Method Added By Punam
        Description: fetch all extended policies to display.
    */
    @AuraEnabled(cacheable=true)
    public static List<WOD_2__Policy_Definition__c> getPolicyDetails(){
        try {
            List<String> fieldsForPolicy = new List<String> {'Id','Name','WOD_2__Type__c','WOD_2__Months_Covered__c', 'WOD_2__Active_From__c','WOD_2__Active_Until__c'};
            String sObjName = 'WOD_2__Policy_Definition__c';
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForPolicy);
            List<WOD_2__Policy_Definition__c> policyDetails = new List<WOD_2__Policy_Definition__c>();
            if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
            {
                policyDetails =[Select Id,Name,WOD_2__Type__c   ,WOD_2__Months_Covered__c, WOD_2__Active_From__c,
                WOD_2__Active_Until__c From WOD_2__Policy_Definition__c Where WOD_2__Type__c='Extended'];
            }
            if(policyDetails!= null && policyDetails.size()>0){
                return policyDetails;
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     /*
        Method Name :   saveTransactionHistory
        Method Added By Punam
        Params      :   extendedWRpricing, policyId
        Description: Save method action after submitting Warranty Registration. Create transaction History, Line Item and Warranty Coverage  
    */
    @AuraEnabled
    public static void saveTransactionHistory(List<ExtendedWRWrapper> extendedWRpricing, List<String> policyId, Id inventoryId){
        String transctnHistoryName ;
        Decimal TotalPrice=0;
        List<WOD_2__Warranty_Coverages__c> WrCoverageList = new List<WOD_2__Warranty_Coverages__c>();
        
        List<String> fieldsForInv = new List<String> {'Id','Name','WOD_2__Install_Date__c'};
        List<String> fieldsForRegistration = new List<String> {'Id','WOD_2__Warranty_End_Date__c','WOD_2__Inventory__c','WOD_2__Warranty_Start_Date__c'};
        String sObjName = 'WOD_2__Inventory__c';
        String sObjName2 = 'WOD_2__Warranty_Registration__c';
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForInv);
        WOD_2__Inventory__c invData;
        if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
        {
            invData= [Select Id,Name, WOD_2__Install_Date__c From WOD_2__Inventory__c Where id=: inventoryId];
        }
        List<WOD_2__Transaction_Memo_History_Line_Item__c> transactionLineItemList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
        
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject2 = ATI_Utils.fetchReadAccess(sObjName2,fieldsForRegistration);
        WOD_2__Warranty_Registration__c regDetails;
        if(noAccessObjectFieldWrapperObject2.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject2.noAccessFieldList.size() == 0)
        {
            regDetails = [Select Id, WOD_2__Inventory__c,WOD_2__Status__c,WOD_2__Warranty_End_Date__c, WOD_2__Warranty_Start_Date__c From WOD_2__Warranty_Registration__c Where WOD_2__Inventory__c=:invData.Id];
        }
        if(extendedWRpricing.size()>0){
            for(ExtendedWRWrapper wrapObj: extendedWRpricing){
                if(transctnHistoryName == null){
                    transctnHistoryName= wrapObj.policyName;
                }else if(!wrapObj.policyName.contains('Total Price :')){
                    transctnHistoryName= transctnHistoryName+'-'+wrapObj.policyName;
                }
                TotalPrice = TotalPrice+ wrapObj.finalPrice;
            }
            transctnHistoryName= invData.Name+'-'+transctnHistoryName;
            WOD_2__Transaction_Memo_History__c transctnHistory = new WOD_2__Transaction_Memo_History__c(ATI_Type__c='EWP', Name= transctnHistoryName,WOD_2__Amount__c =TotalPrice,
            WOD_2__Transaction_Type__c ='Debit', WOD_2__Transaction_Status__c ='Pending', WOD_2__Settlement_Category__c ='EWP',
            ATI_Warranty_Registration__c = regDetails.Id);

            Database.insert(transctnHistory,false);

            Map<String,ExtendedWRWrapper> wrapObjMap = new Map<String,ExtendedWRWrapper>();
            for(ExtendedWRWrapper wrapObj: extendedWRpricing){
                if(!wrapObj.policyName.contains('Total Price :')){
                    WOD_2__Transaction_Memo_History_Line_Item__c transactionLineItem = new WOD_2__Transaction_Memo_History_Line_Item__c(WOD_2__Transaction_Memo_History__c=transctnHistory.Id,
                    Name= wrapObj.policyName, WOD_2__Total_Amount__c= wrapObj.finalPrice, WOD_2__Unit_Amount__c= wrapObj.basePrice,
                    ATI_Handling_Fee__c= wrapObj.handlingFee, ATI_Late_Fee__c= wrapObj.lateFee,WOD_2__Transaction_Type__c= 'Debit', WOD_2__Quantity__c=1
                    );
                    transactionLineItemList.add(transactionLineItem);
                }
                wrapObjMap.put(wrapObj.policyName, wrapObj);

            }
            Database.insert(transactionLineItemList,false);

            Map<Id,WOD_2__Policy_Definition__c> policyIdObjMap = new Map<Id,WOD_2__Policy_Definition__c>();
            List<WOD_2__Policy_Definition__c> policies =[Select Id, Name,WOD_2__Months_Covered__c From WOD_2__Policy_Definition__c Where Id IN: policyId];
            for(WOD_2__Policy_Definition__c pol: policies){
                policyIdObjMap.put(pol.Id, pol);
            }
            for(String pol: policyId){
                if(policyIdObjMap.containsKey(pol) && wrapObjMap.get(policyIdObjMap.get(pol).Name)!= null){
                    WOD_2__Warranty_Coverages__c WRCoverage = new WOD_2__Warranty_Coverages__c();
                    WRCoverage.WOD_2__Warranty_Registration__c = regDetails.Id;
                    WRCoverage.WOD_2__Policy_Definition__c = pol;
                    WRCoverage.WOD_2__Is_Active__c = true;
                    WRCoverage.WOD_2__Warranty_Start_Date__c= invData.WOD_2__Install_Date__c;
                    WRCoverage.WOD_2__Warranty_End_Date__c = (invData.WOD_2__Install_Date__c).addMonths(Integer.valueOf(policyIdObjMap.get(pol).WOD_2__Months_Covered__c));
                    WRCoverage.ATI_isExtended__c = true;
                    WrCoverageList.add(WRCoverage);
                }
            }
            Database.insert(WrCoverageList,false);
            regDetails.WOD_2__Status__c= 'In Progress';
            Database.update(regDetails, false);
        }
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper registerExtWarrantyCoverages(String wcInputString,String wrId, String purchasedCoverageDetails){
        try{
            System.debug('wcInputString -> ' + wcInputString);
            WOD_2.ResponseWrapper responseWrapper = saveWarrantyCoverages(wcInputString);
            System.debug('responseWrapper -> ' + responseWrapper);
            if(responseWrapper.status){
                responseWrapper = createTransaction(wrId, purchasedCoverageDetails);
            }
            return responseWrapper;
        }catch(Exception e){
            return new WOD_2.ResponseWrapper('', false, e.getMessage() + ' -> ' + e.getLineNumber()); 
        }
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper saveWarrantyCoverages(String wcInputString){
        try {
          WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('',true, '');
            //deserialize wcInputSting
            WOD_2.WR_CoverageInputWrapper covrageWrapper = (WOD_2.WR_CoverageInputWrapper)JSON.deserialize(wcInputString, WOD_2.WR_CoverageInputWrapper.class);
            //ALSN-160 calling validateWarrantyRegistration and conditional check of the response
            responseWrapper = validateWarrantyRegistration(covrageWrapper.wrRecordIds);
            if(responseWrapper.status == false){
                return responseWrapper;
            }else{
                responseWrapper = WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(covrageWrapper);
            }
            return responseWrapper;
        }catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    //ALSN-160
    public static WOD_2.ResponseWrapper validateWarrantyRegistration(List<String> wrId){
        try{
          WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('',true, '');
          List<WOD_2__Warranty_Registration__c> wrList =[Select Id,WOD_2__Status__c from WOD_2__Warranty_Registration__c where Id=:wrId ];
          
            if(wrList[0].WOD_2__Status__c == 'Draft'){
                responseWrapper.status = true;
            }else {
                responseWrapper.status = false;
                responseWrapper.errormessage = Label.ATI_Saving_Duplicate_Warranty_Registration;
            }
            return responseWrapper;

        }catch(Exception e){
            return new WOD_2.ResponseWrapper('',false,e.getMessage());  
        }
    }//ALSN-160 [End]
    @AuraEnabled
    public static WOD_2.ResponseWrapper createTransaction(String wrId, String purchasedCoverageDetails){
        try {
            WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('',true, '');
            ExtendedWRPricingWrapper coveragePrices = (ExtendedWRPricingWrapper)JSON.deserialize(purchasedCoverageDetails, ExtendedWRPricingWrapper.class);
            List<String> wrFields = new List<String>{'WOD_2__Inventory__r.WOD_2__Business_Unit__c','WOD_2__Inventory__r.WOD_2__Install_Date__c','WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c',
                'WOD_2__Inventory__r.ATI_Vocation_Code__c',/*'WOD_2__Inventory__r.ATI_Program_Level__c',*/'WOD_2__Inventory__r.WOD_2__Account__r.Country__c',
                'WOD_2__Inventory__r.WOD_2__Serial_Number__c','WOD_2__Status__c'};
            system.debug('wrFields' + wrFields);
            ATI_Utils.NoAccessObjectFieldWrapper wrFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',wrFields);
            System.debug('readAccess check -- '+wrFieldAccess);
            if(wrFieldAccess.noAccessFieldList.isEmpty() && wrFieldAccess.noAccessObjectList.isEmpty()){
                System.debug('trueeeeeeee');
                String wrQuery = 'select id, ' + String.join(wrFields, ',') + ' from WOD_2__Warranty_Registration__c where id = :wrId';
                WOD_2__Warranty_Registration__c wr = DataBase.query(wrQuery);
                WOD_2__Transaction_Memo_History__c transctnHistory = new WOD_2__Transaction_Memo_History__c(ATI_Type__c='EWP', Name= wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c,
                                                                                                            WOD_2__Amount__c = coveragePrices.totalPrice, WOD_2__Transaction_Type__c ='Debit', WOD_2__Transaction_Status__c ='Pending', WOD_2__Settlement_Category__c ='EWP',
                                                                                                            ATI_Warranty_Registration__c = wrId);
                if(wr.WOD_2__Status__c == 'In Progress'){
                    transctnHistory.WOD_2__Transaction_Status__c ='Draft';
                }
                insert transctnHistory;
                List<WOD_2__Transaction_Memo_History_Line_Item__c> transactionLineItemList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
                for(ExtendedWRWrapper wrapObj: coveragePrices.exPricingList){
                    WOD_2__Transaction_Memo_History_Line_Item__c transactionLineItem = new WOD_2__Transaction_Memo_History_Line_Item__c(WOD_2__Transaction_Memo_History__c=transctnHistory.Id,
                                                                                                                                        Name= wrapObj.policyName, WOD_2__Total_Amount__c= wrapObj.finalPrice, WOD_2__Unit_Amount__c= wrapObj.basePrice,
                                                                                                                                        ATI_Handling_Fee__c= wrapObj.handlingFee, ATI_Late_Fee__c= wrapObj.lateFee,WOD_2__Transaction_Type__c= 'Debit', WOD_2__Quantity__c=1);
                    transactionLineItemList.add(transactionLineItem);
                }
                insert transactionLineItemList;
                responseWrapper.data = JSON.serialize(transactionLineItemList);
                if(wr.WOD_2__Status__c == 'Registered' && !Test.isRunningTest() && !System.isBatch()){
                    Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                        select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c=:wr.id 
                        and WOD_2__Policy_Definition__r.WOD_2__Type__c = 'Extended'
                    ]);
                    if(!coverages.isEmpty()){
                        if(!System.isBatch()){
                            System.enqueueJob(new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet())));
                        }else{
                            new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet())).execute(null);
                        }
                    }
                }
            } else {
                //ALSN-57 added fields in error message.
                return new WOD_2.ResponseWrapper('', false, '(Warranty Registration) TMH not created due to ' + Label.ATI_Log_Insufficient_access+' : '+wrFieldAccess.noAccessFieldList);
            }
            return responseWrapper;
        }catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    

    /*
        Method Name :   getExtendedWarrantyPricing
        Method Added By Punam
        Params      :  policy
        Description: fetch the right extended warranty pricing record for a policy and display it in a table.
    */
    @AuraEnabled
    public static WOD_2.ResponseWrapper getExtendedWarrantyPricing(List<String> policyList, Id wrId){
        ExtendedWRPricingWrapper extendedWRPricing = new ExtendedWRPricingWrapper();
        List<String> wrInventoryFields = new List<String>{'WOD_2__Inventory__r.WOD_2__Business_Unit__c','ATI_Extended_Warranty_Purchase_Date__c','WOD_2__Inventory__r.WOD_2__Install_Date__c',
            'WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c','WOD_2__Inventory__r.ATI_Active__c','WOD_2__Inventory__r.ATI_Vocation_Code__c','WOD_2__Install_Date__c','WOD_2__Inventory__r.ATI_Program_Level__c',
            'WOD_2__Inventory__r.WOD_2__Account__r.Country__c','ATI_CE_Number__c','WOD_2__Account__r.ATI_Currency__c','ATI_Exchange_Rate__c','WOD_2__Account__r.ATI_Exchange_Rate_Type__c'};
        ATI_Utils.NoAccessObjectFieldWrapper invFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',wrInventoryFields);
        if(invFieldAccess.noAccessFieldList.isEmpty() && invFieldAccess.noAccessObjectList.isEmpty()){
            List<String> extWarrantyPricingFields = new List<String>{'ATI_Active_From__c','ATI_Active_Until__c','ATI_Base_Price__c',
                'ATI_Country__c','ATI_Handling_Fee__c','ATI_Policy_Definition__c','ATI_Program_Level__c','ATI_Vocation_Code__c','ATI_Warranty_Product__c',
                'ATI_Policy_Definition__r.Name'};
            ATI_Utils.NoAccessObjectFieldWrapper extWPFieldAccess = ATI_Utils.fetchReadAccess('ATI_Extended_Warranty_Pricing__c',extWarrantyPricingFields);                    
            if(extWPFieldAccess.noAccessFieldList.isEmpty() && extWPFieldAccess.noAccessObjectList.isEmpty()){
                String wrQuery = 'select id,WOD_2__Account__r.ATI_Active__c,WOD_2__Account__r.ATI_Inactive_Date__c,ATI_PO_Number__c, ' + String.join(wrInventoryFields, ',') + ' from WOD_2__Warranty_Registration__c where id = :wrId';
                WOD_2__Warranty_Registration__c wr = DataBase.query(wrQuery);
                String errorMsg = validateWRForExtPurchase(wr);
                system.debug('errorMsg'+errorMsg);
                if(String.isNotBlank(errorMsg) && errorMsg!=Label.ATI_Purchase_Less_Install_Date){
                    return new WOD_2.ResponseWrapper(JSON.serialize(extendedWRPricing), false,errorMsg);
                }
                String model = String.valueof(wr.WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c); 
                String programLvl = wr.WOD_2__Inventory__r.ATI_Program_Level__c;
                 String country = wr.WOD_2__Inventory__r.WOD_2__Account__r.Country__c;
                  String vocationCode = String.valueof(wr.WOD_2__Inventory__r.ATI_Vocation_Code__c);
                Date inServiceDate = wr.WOD_2__Inventory__r.WOD_2__Install_Date__c;
                //Added By Punam--
                Date purchaseDate;
                if(wr.ATI_Extended_Warranty_Purchase_Date__c!= null) {
                    purchaseDate= wr.ATI_Extended_Warranty_Purchase_Date__c;
                }else{
                    purchaseDate= inServiceDate;
                }
                System.debug('model----->'+model +'vocationCode---->'+vocationCode + 'country----->'+country);                
                if(wr.ATI_Extended_Warranty_Purchase_Date__c!= null){
                String extWrPricingQuery = 'select id, ' + String.join(extWarrantyPricingFields, ',') + ' from ATI_Extended_Warranty_Pricing__c where ' +
                    ' ATI_Policy_Definition__c in :policyList AND ATI_Policy_Definition__r.WOD_2__Type__c = \'Extended\''+
                    ' AND (ATI_Warranty_Product__c = :model) '+
                    ' AND (ATI_Vocation_Code__c = :vocationCode) ' +
                    ' AND (ATI_Program_Level__c = null or ATI_Program_Level__c = :programLvl) ' +
                    ' AND (ATI_Country__c = null or ATI_Country__c = :country) ' +
                    ' AND (ATI_Active_From__c <= :purchaseDate AND ATI_Active_Until__c >= :purchaseDate)' ;   
                    System.debug('extWrPricingQuery -> ' + extWrPricingQuery);
                    System.debug('policyList -> ' + policyList);
                    System.debug('model -> ' + model);
                    System.debug('vocationCode -> ' + vocationCode+'**purchaseDate**'+purchaseDate);
                    System.debug('programLvl -> ' + programLvl);
                    System.debug('query------- -> ' + extWrPricingQuery);
                List<ATI_Extended_Warranty_Pricing__c> ectWrPricingList = Database.query(extWrPricingQuery);
                System.debug('ectWrPricingList -> ' + ectWrPricingList);
                if(!ectWrPricingList.isEmpty()){
                    List<WOD_2__Business_Category_Configuration_Setting__c> bccsRecords= [SELECT Id,Name,RecordTypeId,WOD_2__Business_Category_Configuration__c,WOD_2__Module__c,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE (Name = 'ATI_EWPLateFeeForGreaterThanThreeYears' OR Name = 'ATI_EWPLateFeeForGreaterThanOneYear' OR Name = 'ATI_EWPLateFeeForGreaterThanTwoYears' OR Name = 'ATI_EWPLateFeeForGreaterThanFourYears') AND WOD_2__Business_Category_Configuration__c = :wr.WOD_2__Inventory__r.WOD_2__Business_Unit__c];
                    Map<String,Decimal> bccRecordMap = new Map<String,Decimal>();
                    for(WOD_2__Business_Category_Configuration_Setting__c bcc : bccsRecords){
                        bccRecordMap.put(bcc.Name,Decimal.valueOf(bcc.WOD_2__Value__c));
                    }
                    ATI_ExchangeRateService.ExchangeWrapper exchangeRate = null;
                    System.debug('Dealer Currency --> ' + wr.WOD_2__Account__r.ATI_Currency__c);
                    if(String.isNotBlank(wr.WOD_2__Account__r.ATI_Currency__c) && !'USD'.equalsIgnoreCase(wr.WOD_2__Account__r.ATI_Currency__c)){
                        exchangeRate = ATI_ExchangeRateService.convertCurrencyOfType(wr.WOD_2__Account__r.ATI_Currency__c, 'USD', purchaseDate, wr.WOD_2__Account__r.ATI_Exchange_Rate_Type__c);     
                        extendedWRPricing.showLocalCurrency = true;
                        if(exchangeRate != null && exchangeRate.rate != null){
                            //ALSN-120 exchange rate reversed for conversion to LocalCurrency
                            exchangeRate.rate = 1/exchangeRate.rate;
                            WOD_2__Warranty_Registration__c wrToUpdate = new WOD_2__Warranty_Registration__c(Id=wr.Id, ATI_Exchange_Rate__c=exchangeRate.rate);
                            update wrToUpdate;
                        }
                    }
                    Boolean WP50K = False;
                    for(ATI_Extended_Warranty_Pricing__c extndPrice : ectWrPricingList){
                        Decimal lateFee = 0, finalPrice = 0;
                        ExtendedWRWrapper wrapperObj = new ExtendedWRWrapper();
                        wrapperObj.policyName = extndPrice.ATI_Policy_Definition__r.Name;
                        wrapperObj.basePrice = extndPrice.ATI_Base_Price__c;
                        wrapperObj.handlingFee =  extndPrice.ATI_Handling_Fee__c;
                        Integer monthsBetween = inServiceDate.monthsBetween(System.today());
                        if((monthsBetween > 12 && monthsBetween < 24) || (monthsBetween==12 && System.today().day() >= inServiceDate.day()) 
                            ||(monthsBetween == 24 && System.today().day() < inServiceDate.day())){
                            lateFee = extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanOneYear'))/100;
                        } else if((monthsBetween > 24 && monthsBetween < 36) || (monthsBetween==24 && System.today().day() >= inServiceDate.day()) 
                            ||(monthsBetween == 36 && System.today().day() < inServiceDate.day())){
                            lateFee = extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanTwoYears'))/100;
                        } else if(monthsBetween > 36 || (monthsBetween==36 && System.today().day() >= inServiceDate.day())){
                            lateFee= extndPrice.ATI_Base_Price__c * (bccRecordMap.get('ATI_EWPLateFeeForGreaterThanThreeYears'))/100;
                        }
                        finalPrice = (extndPrice.ATI_Base_Price__c + lateFee) - extndPrice.ATI_Handling_Fee__c;
                        wrapperObj.lateFee =  lateFee;   
                        wrapperObj.finalPrice =  finalPrice;
                        if(exchangeRate != null && exchangeRate.rate != null){
                            wrapperObj.finalPriceInLocalCurrency = wr.WOD_2__Account__r.ATI_Currency__c + ' ' + (exchangeRate.rate * finalPrice); 
                        } else {
                            wrapperObj.finalPriceInLocalCurrency = 'Currency Conversion Not Found';
                        }
                        extendedWRPricing.totalPrice = extendedWRPricing.totalPrice + finalPrice;
                        extendedWRPricing.exPricingList.add(wrapperObj);
                        if(!WP50K && extndPrice.ATI_Base_Price__c >= 50000){
                            WP50K= True;
                        }
                    }
                    if(WP50K){
                        return new WOD_2.ResponseWrapper(JSON.serialize(extendedWRPricing), true, Label.ATI_Selected_ETC_Suggested_Selling_Price_is_50K);
                    }
                }
                return new WOD_2.ResponseWrapper(JSON.serialize(extendedWRPricing), true, ''); 
                }else{
                    return new WOD_2.ResponseWrapper(JSON.serialize(extendedWRPricing), true,Label.ATI_Mandatory_Extnd_Purchase_Dt);
                }
            } else {
                return new WOD_2.ResponseWrapper('', false, '(Ext. Warranty Pricing)' + Label.ATI_Log_Insufficient_access); 
            }
        } else {
            return new WOD_2.ResponseWrapper('', false, '(Inventory)' + Label.ATI_Log_Insufficient_access); 
        }
        
    }
    
    private static String validateWRForExtPurchase(WOD_2__Warranty_Registration__c wr){
        String errorMessage = null;
        if(wr.ATI_Extended_Warranty_Purchase_Date__c == null){
            errorMessage = Label.ATI_Mandatory_Extnd_Purchase_Dt;
        }else if(wr.ATI_Extended_Warranty_Purchase_Date__c > system.today()){
            errorMessage = System.Label.ATI_Extended_purchase_date_cannot_be_in_future;
        }else if(wr.ATI_Extended_Warranty_Purchase_Date__c < wr.WOD_2__Install_Date__c){
            errorMessage = Label.ATI_Purchase_Less_Install_Date;
        }
         else if(wr.WOD_2__Inventory__r != NULL && wr.WOD_2__Inventory__r.ATI_Active__c == False){
            errorMessage = Label.ATI_Inventory_must_be_active_ETC;
        }
        else if(wr.ATI_PO_Number__c == NULL){
            errorMessage = Label.ATI_ETC_PONumber;
        }else if(wr.WOD_2__Account__r.ATI_Active__c == 'No' && wr.ATI_Extended_Warranty_Purchase_Date__c > wr.WOD_2__Account__r.ATI_Inactive_Date__c){
            errorMessage = Label.ATI_Repairing_Location_code_Status;
        }
       
        return errorMessage;
    }

    @AuraEnabled
    public static String getWarrantyCoverages(String wntyCoveragesParam){
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(wntyCoveragesParam);
        Id invId = (Id) params.get('invId'), accountId = (Id) params.get('accountId');
        String purchaseDt = (String)params.get('purchaseDt'), ceNumber = (String)params.get('ceNumber'), 
            trackingNumber = (String)params.get('trackingNumber'), poNumber = (String)params.get('poNumber');
        Map<Id,WOD_2__Warranty_Registration__c> warrantyRegistrationMap = null;
        WntyCoverageWrapper wrapper = new WntyCoverageWrapper();
        List<WOD_2__Warranty_Registration__c> wrs = 
            [SELECT id,WOD_2__Inventory__r.ATI_Active__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c,ATI_Extended_Warranty_Purchase_Date__c, WOD_2__Inventory__r.Id,WOD_2__Customer__c,WOD_2__Registration_Comments__c,WOD_2__Registration_Type__c,WOD_2__Usage_Type__c,
             WOD_2__Account__c,WOD_2__Registration_Date__c, WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c,
            WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c, WOD_2__Install_Date__c,ATI_PO_Number__c,WOD_2__Account__r.ATI_Inactive_Date__c,
            WOD_2__Status__c,WOD_2__Account__r.ATI_Active__c FROM WOD_2__Warranty_Registration__c 
            WHERE WOD_2__Inventory__c = :invId AND (WOD_2__Registration_Type__c = 'Extended' OR  (WOD_2__Registration_Type__c = 'Standard Registration' and ATI_isExtended__c = true)) order by Createddate desc];
        if(wrs.isEmpty()|| wrs.get(0).WOD_2__Status__c == 'InActive'|| wrs.get(0).WOD_2__Status__c == 'De-Registered' || wrs.get(0).WOD_2__Status__c == 'Rejected'){
            Map<Id, WOD_2__Inventory__c> invMap = new Map<Id, WOD_2__Inventory__c>(ATI_WarrantyService.getInventoriesForWR(new List<Id>{invId}));
            wrs = ATI_WarrantyService.getStdWRListForInventories(invMap);
            validateWR(wrapper, wrs[0], purchaseDt,poNumber);
            if(!wrapper.status && wrapper.errorMsg!=Label.ATI_Purchase_Less_Install_Date){
                return JSON.serialize(wrapper);
            }
            wrs = ATI_WarrantyService.cloneWRsForRegistration(wrs, 'Extended', false, invMap); //Change true to false Punam
            wrs[0].ATI_Extended_Warranty_Purchase_Date__c = Date.valueOf(purchaseDt) ;//Added by Punam
            wrs[0].ATI_CE_Number__c = ceNumber;
            wrs[0].ATI_Tracking_Number__c = trackingNumber;
            wrs[0].ATI_PO_Number__c = poNumber;
            wrs[0].WOD_2__Registration_Date__c= Date.today();
            wrs[0].WOD_2__Account__c = accountId;
            insert wrs;//Added by Punam
            warrantyRegistrationMap = new Map<Id,WOD_2__Warranty_Registration__c>(wrs);
        }else if(wrs.get(0).WOD_2__Status__c == 'Draft' ){
            //Added by Punam
            validateWR(wrapper, wrs[0], purchaseDt,poNumber);
            if(!wrapper.status && wrapper.errorMsg!=Label.ATI_Purchase_Less_Install_Date){
                return JSON.serialize(wrapper);
            }
            wrs[0].ATI_Extended_Warranty_Purchase_Date__c = Date.valueOf(purchaseDt) ;
            wrs[0].ATI_CE_Number__c = ceNumber;
            wrs[0].ATI_Tracking_Number__c = trackingNumber;
            wrs[0].ATI_PO_Number__c = poNumber;
            wrs[0].WOD_2__Account__c = accountId;
             update wrs[0]; // need to update only Draft WR, else we will be updating old, rejected WR as well
            warrantyRegistrationMap = new Map<Id,WOD_2__Warranty_Registration__c>(new List<WOD_2__Warranty_Registration__c>{wrs[0]});
        } else {
            wrapper.status = false;
            wrapper.errorMsg = 'Extended Warranty is already submitted.';
            return JSON.serialize(wrapper);
        }

        system.debug('warrantyRegistrationMap***'+warrantyRegistrationMap);
        WOD_2.WR_WarrantyRegistrationResponse responseWrapper = ATI_WarrantyService.runEngine(warrantyRegistrationMap, 'ATI_ExtendedPolicyQueryOverride');
        System.debug('responseWrapper -> ' + responseWrapper);
        wrapper.warrantyCoverages = new List<WOD_2__Warranty_Coverages__c>();
        List<Id> policyDefIdList = new List<Id>();
        for(WOD_2.WR_RegistrationResponse wr : responseWrapper.response.values()) {
            if(wr.warrantyCoverages.size() > 0 ){
                for(WOD_2__Warranty_Coverages__c coverage : wr.warrantyCoverages){
                    System.debug('>>> coverage :'+ coverage);
                    if(coverage.WOD_2__Policy_Definition__c != null){
                        wrapper.warrantyCoverages.add(coverage);
                        policyDefIdList.add(coverage.WOD_2__Policy_Definition__c);
                    } 
                }
            }
        }
        wrapper.policyDetails = [select Name,WOD_2__Type__c, WOD_2__Months_Covered__c, WOD_2__Active_From__c, WOD_2__Active_Until__c from WOD_2__Policy_Definition__c where id in :policyDefIdList];
        if(wrapper.policyDetails.size() > 0){
            wrapper.wr = wrs[0];
            wrapper.status = true;
            return JSON.serialize(wrapper);
        }else{
            wrapper.status = false;
            wrapper.errorMsg = System.Label.ATI_No_extended_policies_found;
            return JSON.serialize(wrapper);
        }
    }
    
    private static void validateWR(WntyCoverageWrapper wrapper, WOD_2__Warranty_Registration__c wr, String purchaseDt,String poNumber){
        Date purchaseDate = Date.valueOf(purchaseDt);
        String errorMessage = null;
        if(purchaseDate == null){
            errorMessage = Label.ATI_Mandatory_Extnd_Purchase_Dt;
        }else if(purchaseDate > system.today()){
            errorMessage = System.Label.ATI_Extended_purchase_date_cannot_be_in_future;
        }else if(purchaseDate < wr.WOD_2__Install_Date__c){
            errorMessage = Label.ATI_Purchase_Less_Install_Date;
        }
        else if(wr.WOD_2__Account__r.ATI_Active__c == 'No' && purchaseDate > wr.WOD_2__Account__r.ATI_Inactive_Date__c){
            errorMessage = Label.ATI_Repairing_Location_code_Status;
        }
        else if(wr.WOD_2__Inventory__r != NULL && wr.WOD_2__Inventory__r.ATI_Active__c == False){
            errorMessage = Label.ATI_Inventory_must_be_active_ETC;
        }
        else if(poNumber == NULL || poNumber == ''){
            errorMessage = Label.ATI_ETC_PONumber;
        }
         

        if(String.isNotBlank(errorMessage)){
            wrapper.status = false;
            wrapper.errorMsg = errorMessage;
        }
    }
    
    //This method is to check community user or not..
    //i.e,Extended Warranty Pricing details should be editable only by internal users[Standard+Extended WR]
    @AuraEnabled
    public static WOD_2.ResponseWrapper isPartnerUser(){
        return ATI_Utils.isPartnerUser();
    }
    
    //Method to check if purchase date is less than In-service date
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkPurchaseDate(Id wrId){
        String errorMsg = '';
        List<String> wrInventoryFields = new List<String>{'ATI_Extended_Warranty_Purchase_Date__c','WOD_2__Install_Date__c'};
        ATI_Utils.NoAccessObjectFieldWrapper invFieldAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',wrInventoryFields);
        if(invFieldAccess.noAccessFieldList.isEmpty() && invFieldAccess.noAccessObjectList.isEmpty()){
            String wrQuery = 'select id, ' + String.join(wrInventoryFields, ',') + ' from WOD_2__Warranty_Registration__c where id = :wrId';
            WOD_2__Warranty_Registration__c wr = DataBase.query(wrQuery);
            if(wr.ATI_Extended_Warranty_Purchase_Date__c < wr.WOD_2__Install_Date__c){
                errorMsg = Label.ATI_Agreement_date_Less_Install_Date;
            }
        }
        return new WOD_2.ResponseWrapper('', true, errorMsg);
    }
    
    public class WntyCoverageWrapper {
        public Boolean status = true;
        public String errorMsg;
        public List<WOD_2__Warranty_Coverages__c> warrantyCoverages;
        public List<WOD_2__Policy_Definition__c> policyDetails;
        public WOD_2__Warranty_Registration__c wr;
    }
    
    
    
    public class ExtendedWRPricingWrapper{
        
        public ExtendedWRPricingWrapper(){
            exPricingList = new List<ExtendedWRWrapper>();
            totalPrice = 0;
            basePrice = 0;
        }
        @AuraEnabled
        public List<ExtendedWRWrapper> exPricingList{get;set;}
        @AuraEnabled
        public Decimal totalPrice{get;set;}
        @AuraEnabled
        public Decimal basePrice{get;set;}
        @AuraEnabled
        public Boolean showLocalCurrency{get;set;}
    }
    
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ExtendedWRWrapper{
        @AuraEnabled
        public String policyName{get;set;}
        @AuraEnabled
        public Decimal basePrice{get;set;}
        @AuraEnabled
        public Decimal handlingFee{get;set;}
        @AuraEnabled
        public Decimal lateFee{get;set;}
        @AuraEnabled
        public Decimal finalPrice{get;set;}
        @AuraEnabled
        public String finalPriceInLocalCurrency{get;set;}
    }
    
//}
    /*
    Method Name :   warrantyRuleException
    Params      :   Set Warranty Registration Rule Exception
    Added by Dishari 10/21/2021 
    */
    
    @AuraEnabled
    public static  WOD_2.ResponseWrapper warrantyRuleException(Id wrId){
        system.debug('wrId in apex'+wrId);
        String errorMsg = '';
        List<String> wrInventoryFields = new List<String>{'WOD_2__Inventory__c'};
            String wrQuery = 'select id, ' + String.join(wrInventoryFields, ',') + ' from WOD_2__Warranty_Registration__c where id = :wrId';
        WOD_2__Warranty_Registration__c wr = DataBase.query(wrQuery);
        WOD_2__Inventory__c inv = [select WOD_2__Business_Unit__c from WOD_2__Inventory__c where id = :wr.WOD_2__Inventory__c];
        Set<Id> bCCSSet = New Set<Id>();
        List<WOD_2__Business_Rule__c> burRulesTriggeredLst = 
            ATI_BURulesService.runBURules(inv.WOD_2__Business_Unit__c,'ATI_Warranty_Registration__c',new List<Id>{wr.Id},
                                          'Warranty Registration','Registration Logic');
        ATI_Utils.checkForAccess('WOD_2__Business_Rule__c', 'DELETE', null);
        List<WOD_2__Business_Rule__c> oldBURules = [select id from WOD_2__Business_Rule__c where ATI_Warranty_Registration__c = :wrId];
        if(!oldBURules.isEmpty()){
            delete oldBURules;
        }
        if(burRulesTriggeredLst != null && burRulesTriggeredLst.size()>0){
            List<String> buRuleFieldList = new List<String>{'WOD_2__Action__c','WOD_2__Business_Category_Configuration_Setting__c','WOD_2__Error_Type__c','ATI_Inventory__c','WOD_2__Message__c','WOD_2__Visible_to_Dealer__c','ATI_Warranty_Registration__c'};
            ATI_Utils.checkForAccess('WOD_2__Business_Rule__c', 'CREATE', buRuleFieldList);
            insert burRulesTriggeredLst;
            for(WOD_2__Business_Rule__c buObj : burRulesTriggeredLst){
                bCCSSet.add(buObj.WOD_2__Business_Category_Configuration_Setting__c);
            }
            for(WOD_2__Business_Category_Configuration_Setting__c bccsObj : [SELECT Id,WOD_2__Display_Message__c  FROM  WOD_2__Business_Category_Configuration_Setting__c WHERE  Id IN :bCCSSet]){
                for(WOD_2__Business_Rule__c bu : burRulesTriggeredLst){
                    if(bu.WOD_2__Error_Type__c == 'Soft' && bu.WOD_2__Business_Category_Configuration_Setting__c == bccsObj.Id){
                        errorMsg = errorMsg + bccsObj.WOD_2__Display_Message__c + ', ';
                      
                        
                    }
                }
            }
        }
         
        return new WOD_2.ResponseWrapper('', true, errorMsg);
    }
   
}