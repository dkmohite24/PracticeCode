/* Name: ATI_REST_PartsMasterValidator
Description : This Class is used to validate PartsMaster JSON request data
Author : Tavant(Punam)
History:
VERSION     AUTHOR              DATE               DETAIL                   UserStory/Req#
1.0 -     Tavant(Punam)       11/01/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_PartsMasterValidator {
    public List<ATI_REST_PartsMasterRequest.WarrantyProductInformation> warrantyProductReqLst{get; set;}
    public Map<Integer,List<String>> mapOfFailure{get; private set;}
    public Map<String,WOD_2__Warranty_Product__c> mapOfProducts{get; private set;}
    public Set<String> setOfFailedProducts{get; private set;}
    public Set<String> setOfExternalIds{get; private set;}
    public Set<String> setOfSuccessRecords{get; private set;}
    public Integer totalrecords{get; set;}
    public Integer totalFailedRecords{get; set;}
    public Map<String,String> buNameIdMap{get; private set;}
    Set<String> buSet{get; private set;}
    
    public ATI_REST_PartsMasterValidator(){
        warrantyProductReqLst = new List<ATI_REST_PartsMasterRequest.WarrantyProductInformation>();
        mapOfFailure = new Map<Integer,List<String>>();
        mapOfProducts = new Map<String,WOD_2__Warranty_Product__c>();
        setOfFailedProducts = new Set<String>();
        setOfExternalIds = new Set<String>();
        setOfSuccessRecords = new Set<String>();
        buNameIdMap= new Map<String,String>();
        buSet= new Set<String>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    
    public void validateReqest(ATI_REST_PartsMasterRequest partMasterRequestBody){
        queryPartMasterData(partMasterRequestBody);
        verifyPartMasterRequest(partMasterRequestBody);
    }
    
    private void queryPartMasterData(ATI_REST_PartsMasterRequest partMasterRequestBody){
        for(ATI_REST_PartsMasterRequest.WarrantyProductInformation partMasterReq : partMasterRequestBody.warrantyProduct){
            if(!String.isBlank(partMasterReq.externalProductCode)){
                setOfExternalIds.add(partMasterReq.externalProductCode.trim());
            }
            buSet.add(partMasterReq.businessCategoryUnit);
        }
        if(!setOfExternalIds.isEmpty() && checkReadAccess()){
            List<WOD_2__Warranty_Product__c> wpLst = [SELECT Id,External_Product_Code__c,WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c WHERE External_Product_Code__c IN : setOfExternalIds AND WOD_2__Type__c IN ('Product','Model','Item')];
            for(WOD_2__Warranty_Product__c wp:wpLst){
                mapOfProducts.put(wp.External_Product_Code__c,wp);
            }
        }
    }
    
    private void verifyPartMasterRequest(ATI_REST_PartsMasterRequest partMasterRequestBody){
        Integer  i = 1;
        List<String> fieldsForBusinessUnit = new List<String> {'Name','Id'};
        String sObjName = 'WOD_2__Business_Category_Configuration__c';
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForBusinessUnit);
        if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
        {
            List<WOD_2__Business_Category_Configuration__c> buConfigList =[Select Id,Name From WOD_2__Business_Category_Configuration__c Where Name IN:buSet];
            if(buConfigList!= null && buConfigList.size()>0){
                for(WOD_2__Business_Category_Configuration__c bu: buConfigList){
                    buNameIdMap.put(bu.Name, bu.Id);
                }
            }
        }
        Set<String> identifireLst = new Set<String>();
        for(ATI_REST_PartsMasterRequest.WarrantyProductInformation partMasterReq : partMasterRequestBody.warrantyProduct){
            List<String> errorList = new List<String>();
            if(partMasterReq.identifier.trim()== ''){
                errorList.add('Identifier is mandatory.');
            }else{
                if(identifireLst.contains(partMasterReq.identifier.trim())){
                    errorList.add('Duplicate Identifier :'+partMasterReq.identifier.trim());
                }else{
                    identifireLst.add(partMasterReq.identifier.trim());
                }
            }
            
                if(String.isBlank(partMasterReq.businessCategoryUnit)){
                    errorList.add(Label.ATI_MandatoryBu);
                }else if(String.isNotBlank(partMasterReq.businessCategoryUnit)){
                    if(!buNameIdMap.containskey(partMasterReq.businessCategoryUnit) || buNameIdMap.get(partMasterReq.businessCategoryUnit)== null){
                        errorList.add(Label.ATI_ValidBuName);
                    }
                }
                if(String.isBlank(partMasterReq.description)){
                    errorList.add(Label.ATI_MandatoryProdDescription);
                }
                if(String.isBlank(partMasterReq.itemType) && String.isNOTBlank(partMasterReq.prodType) && partMasterReq.prodType=='Item'){
                    errorList.add(Label.ATI_Mandatory_Item);
                }
               /* if(String.isBlank(partMasterReq.trackType) && String.isNOTBlank(partMasterReq.prodType) && partMasterReq.prodType=='Item'){
                    errorList.add(Label.ATI_Mandatory_TrackType);
                } */
                if(String.isBlank(partMasterReq.externalProductCode)){
                    errorList.add(Label.ATI_Mandatory_ExternalId);
                }
                if(String.isBlank(partMasterReq.prodType)){
                    errorList.add(Label.ATI_Mandatory_TypeOfProduct);
                }
            //ALSN-126 Removing the validations for Active field
            /*
                if(String.isBlank(partMasterReq.active)){
                    errorList.add(Label.ATI_Mandatory_Active);
                }else if(!(partMasterReq.active.equalsIgnoreCase('true') || partMasterReq.active.equalsIgnoreCase('false'))){
                    errorList.add('Active should be set to true or false');
                }
            		*/
                if(String.isBlank(partMasterReq.unitOfMeasure) && partMasterReq.prodType=='Item'){
                    errorList.add(Label.ATI_Mandatory_UnitOfMeasure);
                }
            	if(partMasterReq.unitOfMeasure!='' && (partMasterReq.prodType=='Product' || partMasterReq.prodType=='Model')){
                    errorList.add('Unit of Measure is not required for Product or Model.');
                }
                if(String.isBlank(partMasterReq.primaryFailedPartProhibit)){
                    errorList.add(Label.ATI_Mandatory_Primary_Failed_Prohibit);
                }else if(!(partMasterReq.primaryFailedPartProhibit.equalsIgnoreCase('true') || partMasterReq.primaryFailedPartProhibit.equalsIgnoreCase('false'))){
                    errorList.add('PrimaryFailedPartProhibit should be set to true or false');
                }
            
            	if(partMasterReq.rmaPolicy!='' && !(partMasterReq.rmaPolicy.equalsIgnoreCase('true') || partMasterReq.rmaPolicy.equalsIgnoreCase('false'))){
                    errorList.add('RMA policy should be set to true or false');
                }
            
                if(String.isBlank(partMasterReq.hierarchy)){
                    errorList.add(Label.ATI_Mandatory_Hierarchy);
                }
                if(partMasterReq.prodType!='Product' && partMasterReq.prodType!='Model' && partMasterReq.prodType!='Item'){
                    errorList.add(Label.ATI_Mandatory_ValidProdType);
                }
                if(partMasterReq.itemType!='Machine' && partMasterReq.itemType!='Part' && String.isNOTBlank(partMasterReq.itemType)){
                    errorList.add(Label.ATI_Mandatory_ValidItemType);
                }
            	if(partMasterReq.prodType!='Product' && String.isBlank(partMasterReq.parentProduct)){
                    system.debug('partMasterReq.parentProduct'+partMasterReq.parentProduct);
                    errorList.add(Label.ATI_Mandatory_Parent);
                }
                if(!(partMasterReq.prodType=='Item' && partMasterReq.itemType=='Part') && String.isNOTBlank(partMasterReq.partMarkup.partMarkupPercentage)){
                        errorList.add('Part Markup Percentage is not required.');
                    }
                if((partMasterReq.prodType=='Product' || partMasterReq.prodType=='Model') && String.isNOTBlank(partMasterReq.itemType)){
                        errorList.add('Item Type is applicable only for Item.');
                    }
                    totalrecords= totalrecords++;
                if(errorList.size() == 0){
                    warrantyProductReqLst.add(partMasterReq);
                }
                else{
                    setOfFailedProducts.add(partMasterReq.externalProductCode);
                    totalFailedRecords++;
                    mapOfFailure.put(i,errorList);
                    
                }
            i++;
        }
        //totalrecords = i-1;
    }    
    
    public static Boolean checkReadAccess(){
        String productSObjName = 'WOD_2__Warranty_Product__c';
        List<String> productFields = new List<String>{'External_Product_Code__c','WOD_2__Parent_Product__c','Id','Name','WOD_2__Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper productNoAccessObjectFieldWrapper = ATI_Utils.fetchReadAccess(productSObjName,productFields);
        if(productNoAccessObjectFieldWrapper.noAccessObjectList.size() == 0 && productNoAccessObjectFieldWrapper.noAccessFieldList.size() == 0 ) {
            return true;
        }else{
            String errortext = 'Insufficient Warranty Product Read Access-->> '+JSON.serialize(productNoAccessObjectFieldWrapper);
            ATI_LogService.createLogForAccess('PartsMasterSync',errortext);
            return false;
        }
    }

}