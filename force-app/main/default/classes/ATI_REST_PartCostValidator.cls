/* Name: ATI_REST_PartCostValidator
Description : This Class is used to validate PartCost JSON request data
Author : Tavant(Punam)
History:
VERSION     AUTHOR              DATE               DETAIL                   UserStory/Req#
1.0 -     Tavant(Punam)       18/01/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_PartCostValidator {
    public List<ATI_REST_PartCostRequest.PartCostInformation> partCostReqLst{get; set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Map<String,WOD_2__Warranty_Product_Pricebook__c> mapOfPriceBook{get; private set;}
    public Map<String,WOD_2__Warranty_Product__c> mapOfProducts{get; private set;}
    public Set<String> setOfFailedPartCosts{get; private set;}
    public Set<String> setOfItems{get; private set;}
    public Set<String> setOfSuccessRecords{get; private set;}
    public Integer totalrecords{get; set;}
    public Integer totalFailedRecords{get; set;}
    
    public ATI_REST_PartCostValidator(){
        partCostReqLst = new List<ATI_REST_PartCostRequest.PartCostInformation>();
        mapOfFailure = new Map<Integer,List<String>>();
        mapOfPriceBook = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
        mapOfProducts = new Map<String,WOD_2__Warranty_Product__c>();
        setOfFailedPartCosts = new Set<String>();
        setOfItems = new Set<String>();
        setOfSuccessRecords = new Set<String>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    
    public void validateReqest(ATI_REST_PartCostRequest partCostRequestBody){
        queryPartCostData(partCostRequestBody);
        verifypartCostRequest(partCostRequestBody);
    }
    
    private void queryPartCostData(ATI_REST_PartCostRequest partCostRequestBody){
        setOfItems= getItemsList(partCostRequestBody);
        Map<String,Date> partCostEffectedDateMap = new Map<String,Date>();
        for(ATI_REST_PartCostRequest.PartCostInformation partReq: partCostRequestBody.partCost){
            partCostEffectedDateMap.put(partReq.item, ATI_Utils.parseDate(partReq.effectiveDate));
        }
        
        if(!setOfItems.isEmpty() && checkReadAccess()){
            Id recordTypeId = SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
            List<WOD_2__Warranty_Product_Pricebook__c> wpPriceLst = [SELECT Id,ATI_Active__c,WOD_2__Warranty_Product__c,WOD_2__Valid_From__c,WOD_2__Warranty_Product__r.Name,WOD_2__Valid_Until__c FROM WOD_2__Warranty_Product_Pricebook__c WHERE WOD_2__Warranty_Product__r.Name IN : setOfItems AND WOD_2__Valid_Until__c >= TODAY AND RecordTypeId =:recordTypeId];
            for(WOD_2__Warranty_Product_Pricebook__c wp:wpPriceLst){
                if(wp.WOD_2__Valid_Until__c >= partCostEffectedDateMap.get(wp.WOD_2__Warranty_Product__r.Name)){
                	mapOfPriceBook.put(wp.WOD_2__Warranty_Product__r.Name,wp);
                }
            }
            
            if(ATI_REST_PartsMasterValidator.checkReadAccess()){
                //Alsn-180 added type,active and item type check 
                List<WOD_2__Warranty_Product__c> wProductLst = [SELECT Id,Name,WOD_2__Type__c,WOD_2__Track_Type__c,WOD_2__Item_Type__c,Active__c FROM WOD_2__Warranty_Product__c WHERE Name IN : setOfItems AND WOD_2__Type__c = 'Item' AND WOD_2__Item_Type__c='Part' AND Active__c=true];
                for(WOD_2__Warranty_Product__c wp:wProductLst){
                    mapOfProducts.put(wp.Name,wp);
                }
            }
        }
    }
    
    private void verifypartCostRequest(ATI_REST_PartCostRequest partCostRequestBody){
        Integer  i = 1;
        List<String> errorList = new List<String>();
        try{
            Set<String> identifireLst = new Set<String>();
            for(ATI_REST_PartCostRequest.PartCostInformation partCostReq : partCostRequestBody.partCost){
				errorList = new List<String>();
                if(partCostReq.identifier.trim()== ''){
                    errorList.add('Identifier is mandatory.');
                }else{
                    if(identifireLst.contains(partCostReq.identifier.trim())){
                        errorList.add('Duplicate Identifier :'+partCostReq.identifier.trim());
                    }else{
                        identifireLst.add(partCostReq.identifier.trim());
                    }
                }                
                if(String.isBlank(partCostReq.item)){
                    errorList.add('Item is mandatory.');
                }
                if(String.isNOTBlank(partCostReq.item) && !mapOfProducts.containsKey(partCostReq.item)){
                    errorList.add('Please enter a valid item.');
                }
                if(String.isBlank(partCostReq.value) || partCostReq.value=='0' || partCostReq.value.startswith('-')){
                    errorList.add('Part cost value can not be empty or 0 or negative.');
                }
                if(String.isBlank(partCostReq.effectiveDate)){
                    errorList.add('Start Date can not be empty');
                }
                if(String.isNOTBlank(partCostReq.effectiveDate) && ATI_Utils.parseDate(partCostReq.effectiveDate)== null){
                    errorList.add('Please enter valid effective date.');
                }
                
                if(String.isBlank(partCostReq.itemUnit)){
                    errorList.add('Unit of Measure is Mandatory');
                }
                if(String.isBlank(partCostReq.active)){
                    errorList.add('Active is Mandatory');
                }else if(!(partCostReq.active.equalsIgnoreCase('true') || partCostReq.active.equalsIgnoreCase('false'))){
                    errorList.add('Active should be set to true or false');
                }
                
                
                totalrecords= totalrecords++;
                if(errorList.size() == 0){
                    partCostReqLst.add(partCostReq);
                }
                else{
                    setOfFailedPartCosts.add(partCostReq.item);
                    totalFailedRecords++;
                    mapOfFailure.put(i,errorList);
                    
                }
                i++;
            }
        }catch(Exception e){
            system.debug('Exception'+e);
        }
    }    

    public static Set<String> getItemsList(ATI_REST_PartCostRequest partCostRequestBody){
        Set<String> itemSet= new Set<String>();
        for(ATI_REST_PartCostRequest.PartCostInformation partCostReq : partCostRequestBody.partCost){
            if(!String.isBlank(partCostReq.item)){
                itemSet.add(partCostReq.item.trim());
            }
        }
        return itemSet;
    }
    
    public static Boolean checkReadAccess(){
        String pricebookSObjName = 'WOD_2__Warranty_Product_Pricebook__c';
        List<String> partCostFields = new List<String>{'WOD_2__Warranty_Product__c','WOD_2__Price__c','WOD_2__Valid_From__c','WOD_2__Valid_Until__c',/*Pu'Active__c',*/'Id','Name'};
            ATI_Utils.NoAccessObjectFieldWrapper productNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(pricebookSObjName,partCostFields);
        if(productNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && productNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
            return true;
        }else{
            String errortext = 'Insufficient Warranty Product Pricebook Read Access-->> '+JSON.serialize(productNoAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('PartCostSync',errortext);
            return false;
        }
    }


}