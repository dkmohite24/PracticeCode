/* Name: ATI_WRCancelController
   Description : Controller for cancelExtendedWarrantyComponent
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                 DATE               DETAIL                   UserStory/Req#
   1.0 -       Tavant (Akshatha S)    15/12/2020         INITIAL DEVELOPMENT
*/
public with sharing class ATI_WRCancelController {
    /*
        Method Name :   getWRInfo
        Params      :   Method to get Warranty registration details based on the inventory
    */	
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper getWRInfo(string invId){
        List<WOD_2__Warranty_Registration__c> wrList =  new List<WOD_2__Warranty_Registration__c>();
        try{
            List<String> fieldsForWR = new List<String> {'WOD_2__Inventory__c','WOD_2__Registration_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',fieldsForWR);
            List<String> fieldsForWRCov = new List<String> {'ATI_Reason__c','Name'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectWRCov = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Coverages__c',fieldsForWRCov);
            if(noAccessObjectWRCov.noAccessObjectList.size() == 0 && noAccessObjectWRCov.noAccessFieldList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
            {
                wrList = [SELECT Id, WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Registration_Type__c, WOD_2__Inventory__c,(SELECT Id,ATI_Reason__c,Name FROM WOD_2__Warranty_Coverages__r where WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended' AND WOD_2__Is_Active__c=true) FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__c =:invId AND WOD_2__Status__c='Registered'];	
            }
            return new WOD_2.ResponseWrapper(JSON.serialize(wrList),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    /*
        Method Name :   getReasonPickListValues
        Params      :   Method to get Reason picklist values of Warranty Coverage object
    */	
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper getReasonPickListValues(){
        try{
            List<String> reasonPickListValues= new List<String>();
            Schema.DescribeFieldResult fieldResult = WOD_2__Warranty_Coverages__c.ATI_Reason__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                reasonPickListValues.add(pickListVal.getLabel());
            }     
            return new WOD_2.ResponseWrapper(JSON.serialize(reasonPickListValues),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
   
	/*
        Method Name :   getDaysAddedDate
        Params      :   Method to add days to input date
    */	
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper getDaysAddedDate(Date inServiceDate){
        WOD_2__Business_Category_Configuration_Setting__c bccsRec = getBCCSRec();
        try{
            date compareDate=inServiceDate.addDays(integer.valueof(bccsRec.WOD_2__Value__c));
        	return new WOD_2.ResponseWrapper(JSON.serialize(compareDate),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    /*
        Method Name :   getBCCSRec
        Params      :   Method to get BCCS records 
    */	
    public static WOD_2__Business_Category_Configuration_Setting__c getBCCSRec(){
        WOD_2__Business_Category_Configuration_Setting__c bccsRec = new WOD_2__Business_Category_Configuration_Setting__c();
        try{
            List<String> fieldsForBCCS = new List<String> {'WOD_2__Value__c','Name'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess('WOD_2__Business_Category_Configuration_Setting__c',fieldsForBCCS);
            if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
            {
                bccsRec = [SELECT Id, WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name ='ATI_CancelExtendedWRWithinDays' LIMIT 1];
            }
        	return bccsRec;
        }
        catch(Exception e) {
            return new WOD_2__Business_Category_Configuration_Setting__c();
        }
    }
    /*
        Method Name :   getBCCSVal
        Params      :   Method to get number of days within which extended warranty can be cancelled
    */	
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper getBCCSVal(){
        WOD_2__Business_Category_Configuration_Setting__c bccsRec = getBCCSRec();
        integer bccsVal;
        try{
            bccsVal=integer.valueof(bccsRec.WOD_2__Value__c);
            return new WOD_2.ResponseWrapper(JSON.serialize(bccsVal),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
	/*
        Method Name :   updateWR
        Params      :   Method to update Warranty registration, coverage records and to create credit memo on cancel of registration
    */	
    @AuraEnabled
    public static WOD_2.ResponseWrapper updateWR(Id recordId,boolean updateWRRecord,string reason,string lineItemList){
        try{
            System.debug('updateWRRecord--->'+updateWRRecord);
            List<WOD_2__Warranty_Coverages__c> warCovUpdateList = new List<WOD_2__Warranty_Coverages__c>();
            List<WOD_2__Transaction_Memo_History_Line_Item__c> linItemsForUpdate =new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
            linItemsForUpdate= (List<WOD_2__Transaction_Memo_History_Line_Item__c>)JSON.deserialize(lineItemList, List<WOD_2__Transaction_Memo_History_Line_Item__c>.class);
            List<String> fieldsForWR = new List<String> {'WOD_2__Status__c'};
            if(updateWRRecord){
            	ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckWR = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Registration__c',fieldsForWR);
                if(sObjUpdateAccessCheckWR.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckWR.noAccessFieldList.size() == 0){
                        WOD_2__Warranty_Registration__c wrObj =  new WOD_2__Warranty_Registration__c();
                        wrObj.Id=recordId;
                        wrObj.WOD_2__Status__c = 'InActive';
                    	System.debug('wrObj--->'+wrObj);
                    	System.debug('wrObjWOD_2__Warranty_Start_Date__c--->'+wrObj.WOD_2__Warranty_Start_Date__c);
                    System.debug('wrObjEnd_Date__c--->'+wrObj.WOD_2__Warranty_End_Date__c);
                    	Database.SaveResult results =  Database.update(wrObj);
                }
            }
                List<String> fieldsForWRCov = new List<String> {'WOD_2__Is_Active__c','ATI_Reason__c','WOD_2__Rollup_Warranty_Date__c'};
            	ATI_Utils.NoAccessObjectFieldWrapper sObjAccessCheckWRCov = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Coverages__c',fieldsForWRCov);
                if(sObjAccessCheckWRCov.noAccessObjectList.size() == 0 && sObjAccessCheckWRCov.noAccessFieldList.size() == 0){
                    warCovUpdateList=[SELECT Id,WOD_2__Rollup_Warranty_Date__c,WOD_2__Is_Active__c,ATI_Reason__c,WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.Name FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c= :recordId AND WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended'];
                    ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckWRCov = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Coverages__c',fieldsForWRCov);
                    System.debug('sObjUpdateAccessCheckWRCov--->'+sObjUpdateAccessCheckWRCov.noAccessObjectList.size());
                     System.debug('fieldUpdateAccessCheckWRCov--->'+sObjUpdateAccessCheckWRCov.noAccessFieldList.size());
                    if(sObjUpdateAccessCheckWRCov.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckWRCov.noAccessFieldList.size() == 0){
                        for(WOD_2__Warranty_Coverages__c warCov : warCovUpdateList){
                            warCov.WOD_2__Is_Active__c = false;
                            warCov.ATI_Reason__c=reason;
                            warCov.WOD_2__Warranty_End_Date__c=system.today();
                            System.debug('warCov.WOD_2__Rollup_Warranty_Date__c--->'+warCov.WOD_2__Rollup_Warranty_Date__c);
                        }
                        Database.SaveResult[] results =  Database.update(warCovUpdateList);
                    }
                } 
            
            List<WOD_2__Transaction_Memo_History_Line_Item__c> transactionLineItemList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
            List<String> fieldsForTransacHistory = new List<String> {'WOD_2__Amount__c','WOD_2__Transaction_Type__c','Name','WOD_2__Transaction_Status__c','WOD_2__Settlement_Category__c','ATI_Type__c','ATI_Warranty_Registration__c'};
            ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckHistory = ATI_Utils.fetchCreateAccess('WOD_2__Transaction_Memo_History__c',fieldsForTransacHistory);
            if(sObjUpdateAccessCheckHistory.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckHistory.noAccessFieldList.size() == 0){
                WOD_2__Transaction_Memo_History__c transctnHistory = new WOD_2__Transaction_Memo_History__c( Name=warCovUpdateList[0].WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.Name+'-'+linItemsForUpdate[0].Name, ATI_Type__c='EWP',
                WOD_2__Amount__c =linItemsForUpdate[0].WOD_2__Total_Amount__c,WOD_2__Transaction_Type__c ='Credit', WOD_2__Transaction_Status__c ='Pending', WOD_2__Settlement_Category__c ='EWP'
                ,ATI_Warranty_Registration__c = recordId);
                Database.insert(transctnHistory);
                
                List<String> fieldsForlineItem = new List<String> {'WOD_2__Total_Amount__c','WOD_2__Unit_Amount__c','ATI_Late_Fee__c','ATI_Handling_Fee__c','Name','WOD_2__Quantity__c','WOD_2__Transaction_Type__c','WOD_2__Transaction_Memo_History__c'};
            	ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessChecklineItem = ATI_Utils.fetchCreateAccess('WOD_2__Transaction_Memo_History_Line_Item__c',fieldsForlineItem);
                if(sObjUpdateAccessChecklineItem.noAccessObjectList.size() == 0 && sObjUpdateAccessChecklineItem.noAccessFieldList.size() == 0){
                    for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec : linItemsForUpdate){
                        WOD_2__Transaction_Memo_History_Line_Item__c transactionLineItem = new WOD_2__Transaction_Memo_History_Line_Item__c(WOD_2__Transaction_Memo_History__c=transctnHistory.Id,
                        Name= lineItemRec.Name, WOD_2__Total_Amount__c= lineItemRec.WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c=lineItemRec.WOD_2__Unit_Amount__c,
                        ATI_Late_Fee__c=lineItemRec.ATI_Late_Fee__c,ATI_Handling_Fee__c=lineItemRec.ATI_Handling_Fee__c,                                   
                        WOD_2__Transaction_Type__c= 'Credit', WOD_2__Quantity__c=1);
                        transactionLineItemList.add(transactionLineItem);
                    }
                    Database.SaveResult[] lineItemRes = Database.insert(transactionLineItemList,false);
                }
            }
            return new WOD_2.ResponseWrapper(JSON.serialize(transactionLineItemList),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    /*
        Method Name :   getTransactionLineItems
        Params      :   Method to get Transaction Memo History deatails related to the warranty registration
    */	
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper getTransactionLineItems(String wrObjId) {
        try{
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemsLst = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
		List<String> fieldsForlineItem = new List<String> {'WOD_2__Total_Amount__c','WOD_2__Unit_Amount__c','ATI_Late_Fee__c','ATI_Handling_Fee__c','Name','WOD_2__Quantity__c','WOD_2__Transaction_Type__c','WOD_2__Transaction_Memo_History__c'};
        ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessChecklineItem = ATI_Utils.fetchReadAccess('WOD_2__Transaction_Memo_History_Line_Item__c',fieldsForlineItem);
        List<String> fieldsForTransacHistory = new List<String> {'WOD_2__Transaction_Status__c','WOD_2__Transaction_Type__c','ATI_Warranty_Registration__c','ATI_Type__c'}; 
        ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheckHistory = ATI_Utils.fetchReadAccess('WOD_2__Transaction_Memo_History__c',fieldsForTransacHistory);
        if(sObjReadAccessChecklineItem.noAccessObjectList.size() == 0 && sObjReadAccessChecklineItem.noAccessFieldList.size() == 0 && sObjReadAccessCheckHistory.noAccessObjectList.size() == 0 && sObjReadAccessCheckHistory.noAccessFieldList.size() == 0){
        	for(WOD_2__Transaction_Memo_History__c memoObj : [SELECT Id,(SELECT Id,Name,ATI_Late_Fee__c,ATI_Handling_Fee__c,WOD_2__Quantity__c,
                                                                            WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c
                                                                        FROM WOD_2__Transaction_Memo_History_Line_Items__r)
                                                            FROM WOD_2__Transaction_Memo_History__c
                                                            WHERE ATI_Warranty_Registration__c=:wrObjId AND WOD_2__Transaction_Status__c='Paid' AND WOD_2__Transaction_Type__c='Debit' AND ATI_Type__c='EWP']) 
            {
                lineItemsLst.addAll(memoObj.WOD_2__Transaction_Memo_History_Line_Items__r);
            }
        }
        	return new WOD_2.ResponseWrapper(JSON.serialize(lineItemsLst),true,'');
        }
        catch(Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
}