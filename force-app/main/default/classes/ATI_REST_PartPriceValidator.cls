/* Name: ATI_REST_PartPriceValidator
Description : This Class is used to validate PartPrice JSON request data
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      21/12/2020        INITIAL DEVELOPMENT              20670               
*/
public with sharing class ATI_REST_PartPriceValidator {
    public List<ATI_REST_PartPriceRequest.PartPriceInfo> partPriceReqLst{get; private set;}
    public Set<String> setOfPartNumbers{get; private set;}
    public Set<String> setOfPriceGroups{get; private set;}
    public Set<Date> setOfEffectiveDates{get; private set;}
    public Set<Date> setOfEndDates{get; private set;}
    public Set<String> setOfPriceUnits{get; private set;}
    public Set<String> partPriceFailedSet{get; private set;}
    public Set<String> partPriceSuccessSet{get; private set;}
    public Map<String,WOD_2__Warranty_Product_Pricebook__c> wpPricebookMap{get; private set;}
    public Map<String,WOD_2__Warranty_Product_Pricebook__c> wpPricebookMapnew{get; private set;}
    public List<WOD_2__Warranty_Product_Pricebook__c> wpPricebookLstnew{get; private set;}//ALSN-16
    public Map<String,WOD_2__Warranty_Product__c> warrantyProductMap{get; private set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Integer totalrecords{get; private set;}
    public Integer totalFailedRecords{get; private set;}
    
    public ATI_REST_PartPriceValidator(){
        partPriceReqLst = new List<ATI_REST_PartPriceRequest.PartPriceInfo>();
        setOfPartNumbers = new Set<String>();
        setOfPriceGroups = new Set<String>();
        setOfEffectiveDates = new Set<Date>();
        setOfEndDates = new Set<Date>();
        setOfPriceUnits = new Set<String>();
        partPriceFailedSet = new Set<String>();
        partPriceSuccessSet = new Set<String>();
        wpPricebookMap = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
        wpPricebookMapnew = new Map<String,WOD_2__Warranty_Product_Pricebook__c>();
        warrantyProductMap = new Map<String,WOD_2__Warranty_Product__c>();
        mapOfFailure = new Map<Integer,List<String>>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    
    public void validateReqest(ATI_REST_PartPriceRequest partPriceRequestBody){
        queryPartPriceData(partPriceRequestBody);
        verifyPartPriceRequest(partPriceRequestBody);
    }
    
    private void queryPartPriceData(ATI_REST_PartPriceRequest partPriceRequestBody){
        for(ATI_REST_PartPriceRequest.PartPriceInfo partPriceReq : partPriceRequestBody.partPrice){
            if(!String.isBlank(partPriceReq.manufNumber)){
                setOfPartNumbers.add(partPriceReq.manufNumber.trim());
            }
            if(!String.isBlank(partPriceReq.priceGroup)){
                setOfPriceGroups.add(partPriceReq.priceGroup.trim());
            }
            if(!String.isBlank(partPriceReq.effectiveDate)){
                setOfEffectiveDates.add(ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()));
            }
            if(!String.isBlank(partPriceReq.endDate)){
                setOfEndDates.add(ATI_Utils.parseDate(partPriceReq.endDate.trim()));
            }
            if(!String.isBlank(partPriceReq.priceUnit)){
                setOfPriceUnits.add(partPriceReq.priceUnit.trim());
            }
        }
        if(checkWPReadAccess()){
            //Alsn -180 active check included
            List<WOD_2__Warranty_Product__c> warrantyProLst = [SELECT Id,Name,WOD_2__Type__c,WOD_2__Track_Type__c,WOD_2__Item_Type__c,Active__c FROM WOD_2__Warranty_Product__c WHERE Name In:setOfPartNumbers AND WOD_2__Type__c = 'Item' AND WOD_2__Item_Type__c='Part' AND Active__c = true];
            if(!warrantyProLst.isEmpty()){
                for(WOD_2__Warranty_Product__c warrantyPro : warrantyProLst){
                    warrantyProductMap.put(warrantyPro.Name,warrantyPro);
                }
            }
        }
        if(checkWPBReadAccess()){
            List<WOD_2__Warranty_Product_Pricebook__c> wpPricebookLst = [SELECT Id,Name,RecordType.DeveloperName,WOD_2__Warranty_Product__r.Name,ATI_Price_Group__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c,ATI_Unit_of_Measure__c FROM WOD_2__Warranty_Product_Pricebook__c
                                                                         WHERE WOD_2__Warranty_Product__r.Name IN:setOfPartNumbers AND ATI_Price_Group__c IN:setOfPriceGroups AND WOD_2__Valid_From__c IN:setOfEffectiveDates
                                                                         AND WOD_2__Valid_Until__c IN:setOfEndDates AND ATI_Unit_of_Measure__c IN:setOfPriceUnits AND RecordType.DeveloperName='ATI_Part_Price' AND ATI_Active__c=true];
            
			//ALSN-16
            wpPricebookLstnew = [SELECT Id,Name,RecordType.DeveloperName,WOD_2__Warranty_Product__r.Name,ATI_Price_Group__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c,ATI_Unit_of_Measure__c FROM WOD_2__Warranty_Product_Pricebook__c
                                                                            WHERE WOD_2__Warranty_Product__r.Name IN:setOfPartNumbers AND ATI_Price_Group__c IN:setOfPriceGroups
                                                                            AND ATI_Unit_of_Measure__c IN:setOfPriceUnits AND RecordType.DeveloperName='ATI_Part_Price' AND ATI_Active__c=true ORDER BY WOD_2__Valid_Until__c DESC LIMIT 1];
            if(!wpPricebookLstnew.isEmpty()){
                for(WOD_2__Warranty_Product_Pricebook__c wpPricebook : wpPricebookLstnew){
                    String uniqueWPBnew = wpPricebook.WOD_2__Warranty_Product__r.Name.toUpperCase()+':'+wpPricebook.ATI_Price_Group__c.toUpperCase();//ALSN-16
                    wpPricebookMapnew.put(uniqueWPBnew,wpPricebook);
                }
            }
            
            if(!wpPricebookLst.isEmpty()){
                for(WOD_2__Warranty_Product_Pricebook__c wpPricebook : wpPricebookLst){
                    String uniqueWPB = wpPricebook.WOD_2__Warranty_Product__r.Name.toUpperCase()+':'+wpPricebook.ATI_Price_Group__c.toUpperCase()+':'+String.valueOf(wpPricebook.WOD_2__Valid_From__c)+':'+String.valueOf(wpPricebook.WOD_2__Valid_Until__c);
                    wpPricebookMap.put(uniqueWPB,wpPricebook);
                }
            }
        }
    }
    
    
    private void verifyPartPriceRequest(ATI_REST_PartPriceRequest partPriceRequestBody){
        Integer  i = 1;
        set<String> identifierSet = new set<String>();
        for(ATI_REST_PartPriceRequest.PartPriceInfo partPriceReq : partPriceRequestBody.partPrice){
            List<String> listOfErrors = new List<String>();
            String uniqueWPB = '';
            if(String.isBlank(partPriceReq.identifier)){
                listOfErrors.add('Identifier is Mandatory');
            }
            else if(!identifierSet.add(partPriceReq.identifier.trim())){
                listOfErrors.add('Identifier is not unique');
            }
            if(String.isBlank(partPriceReq.manufNumber)){
                listOfErrors.add('ManufacturingNumber is Mandatory');
            }else{
                uniqueWPB = partPriceReq.manufNumber.trim();
                if(warrantyProductMap.isEmpty() || !warrantyProductMap.containsKey(partPriceReq.manufNumber.trim())){
                    listOfErrors.add('Part Number is invalid');
                }
            }
            if(String.isBlank(partPriceReq.priceGroup)){
                listOfErrors.add('PriceGroup can not be empty');
            }else{
                if(uniqueWPB != ''){
                    uniqueWPB += ';'+partPriceReq.priceGroup.trim();
                }else{
                    uniqueWPB = partPriceReq.priceGroup.trim();
                }
            }
            if(String.isBlank(partPriceReq.effectiveDate)){
                listOfErrors.add('EffectiveDate can not be empty');
            }else{
                if(ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()) == null){
                    listOfErrors.add('Invalid EffectiveDate Format');
                }
                if(uniqueWPB != ''){
                    uniqueWPB += ';'+partPriceReq.effectiveDate.trim();
                }else{
                    uniqueWPB = partPriceReq.effectiveDate.trim();
                }
            }
            if(String.isBlank(partPriceReq.endDate)){
                listOfErrors.add('EndDate can not be empty');
            }else{
                if(ATI_Utils.parseDate(partPriceReq.endDate.trim()) == null){
                    listOfErrors.add('Invalid EndDate Format');
                }
                if(uniqueWPB != ''){
                    uniqueWPB += ';'+partPriceReq.endDate.trim();
                }else{
                    uniqueWPB = partPriceReq.endDate.trim();
                }
            }
            
            if(!String.isBlank(partPriceReq.effectiveDate) && !String.isBlank(partPriceReq.endDate) &&
                ATI_Utils.parseDate(partPriceReq.effectiveDate.trim()) != null && ATI_Utils.parseDate(partPriceReq.endDate.trim()) != null
                && ATI_Utils.parseDate(partPriceReq.endDate.trim()) < ATI_Utils.parseDate(partPriceReq.effectiveDate.trim())){
                listOfErrors.add('EndDate can not be less than EffectiveDate');
            }
            
            if(String.isBlank(partPriceReq.value)){
                listOfErrors.add('Value is Mandatory');
            }else{
                if(Decimal.valueOf(partPriceReq.value.trim()) < 0){
                 	listOfErrors.add('Value is invalid');   
                }
            }
            if(String.isBlank(partPriceReq.priceUnit)){
                listOfErrors.add('PriceUnit can not be empty');
            }else{
                if(uniqueWPB != ''){
                    uniqueWPB += ';'+partPriceReq.priceUnit.trim();
                }else{
                    uniqueWPB = partPriceReq.priceUnit.trim();
                }
            }
            //System.debug('uniqueWPB>>>>>> '+uniqueWPB);
            if(listOfErrors.size() == 0){
                partPriceReqLst.add(partPriceReq);
                partPriceSuccessSet.add(uniqueWPB);
            }else{
                totalFailedRecords++;
                mapOfFailure.put(i,listOfErrors);
                partPriceFailedSet.add(uniqueWPB);
            }
            i++;
        }
        totalrecords = i-1;
    }
    
    public static Boolean checkWPBReadAccess(){
        String objectName = 'WOD_2__Warranty_Product_Pricebook__c';
        List<String> fields = new List<String>{'Name','RecordType.DeveloperName','WOD_2__Warranty_Product__c','WOD_2__Warranty_Product__r.Name','ATI_Price_Group__c','WOD_2__Valid_From__c','WOD_2__Valid_Until__c','ATI_Unit_of_Measure__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient WPPricebook Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('PartPriceSync',errortext);
            return false;
        }
    }
    
    public static Boolean checkWPReadAccess(){
        String objectName = 'WOD_2__Warranty_Product__c';
        List<String> fields = new List<String>{'Name','WOD_2__Type__c','WOD_2__Track_Type__c','WOD_2__Item_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(objectName,fields);
        if(noAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapper.noAccessFieldList.size() == 0) {
            return true;
        }else{
            String errortext = 'Insufficient WP Read Access>> '+JSON.serialize(noAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('ExchangeRateSync',errortext);
            return false;
        }
    }
}