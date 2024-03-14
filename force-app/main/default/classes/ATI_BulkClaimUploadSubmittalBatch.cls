public class ATI_BulkClaimUploadSubmittalBatch implements Database.Batchable<sObject>, Database.Stateful {
    String strBatchLogId;
    ATI_BatchLogResults batchLogResultsObj;
    ATI_BulkUploadConfiguration bulkUploadConfigMdt;
    List<String> configurationObjectColumnFieldLst;
    Set<Id> successClaimsIds;
    Map<Id,WOD_2__Claim__c> claimMap;
    Map<String, String> columnHeaderWithFieldApiMap;
    Map<String, String> columnHeaderReferenceWithFieldApiMap;
    List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst;
    List<Id> claimIdsForHardRules;
    Map<Id,String> claimIdToHardErrorMap;
    Map<Id,String> claimErrorMap;
    public ATI_BulkClaimUploadSubmittalBatch(String batchLogId,ATI_BatchLogResults batchLogResultsObj,
                                             ATI_BulkUploadConfiguration bulkUploadConfigMdt,List<String> configurationObjectColumnFieldLst,
                                             List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst)
    {
        this.strBatchLogId = batchLogId;
        this.batchLogResultsObj = batchLogResultsObj;
        this.bulkUploadConfigMdt = bulkUploadConfigMdt;
        this.configurationObjectColumnFieldLst = configurationObjectColumnFieldLst;
        this.successClaimsIds = new Set<Id>();
        this.bulkUploadFieldMappingLst = bulkUploadFieldMappingLst;
        this.claimMap = new Map<Id,WOD_2__Claim__c>();
        columnHeaderWithFieldApiMap = new Map<String,String>();
        columnHeaderReferenceWithFieldApiMap = new Map<String,String>();
        claimIdsForHardRules = new List<Id>();
        claimIdToHardErrorMap = new Map<Id,String>();
        claimErrorMap = new Map<Id,String>();
    }
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        for(ATI_BulkUploadFieldMapping fieldMap : bulkUploadFieldMappingLst) {
            if(!String.isBlank(fieldMap.displayName) && fieldMap.displayName != 'ATI_Extended_Warranty_Purchase_Date__c' && fieldMap.displayName != 'Claim Template Name'
               && fieldMap.displayName != 'Service Campaign Name' && fieldMap.objectAPIName =='WOD_2__Claim__c'){
                columnHeaderWithFieldApiMap.put(fieldMap.displayName,fieldMap.columnName);
                columnHeaderReferenceWithFieldApiMap.put(fieldMap.displayName,fieldMap.type);
            }
        }
        
        // List to Set for String Join
        List<String> csvColumnDisplayNameList = new List<String>();
        csvColumnDisplayNameList.addAll(columnHeaderWithFieldApiMap.keySet());
        System.debug('csvColumnDisplayNameList---------->'+csvColumnDisplayNameList);
        Set<Id> claimIds = batchLogResultsObj.successRecordIdsSet;
        String query = 'SELECT Id,WOD_2__BusinessCategory__c,'+ String.join(csvColumnDisplayNameList,',') + ' FROM WOD_2__Claim__c WHERE Id IN:claimIds';
        System.debug('query---------->'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WOD_2__Claim__c> claimSubDataLst) {
        System.debug('claimSubDataLst>>> '+claimSubDataLst);
        for(WOD_2__Claim__c claimObj : claimSubDataLst){
            claimMap.put(claimObj.Id,claimObj);
        }
        validateSubmitBURules(claimSubDataLst);
    }
    
    public void finish(Database.BatchableContext bc) {
        if(!claimIdsForHardRules.isEmpty()){
            fetchBusinessRules(claimIdsForHardRules);
        }
        WOD_2__Batch_Log__c objBatchLog = [Select Id, OwnerId,ATI_Status__c,ATI_Error_Message__c,WOD_2__Process_Type__c From WOD_2__Batch_Log__c Where Id=: strBatchLogId];
        ATI_BulkUploadBatch.bulkUploadConfigMdt = bulkUploadConfigMdt;
        ATI_BulkUploadBatch.bulkUploadFieldMappingLst = bulkUploadFieldMappingLst;
        //if(successClaimsIds.size() > 0){
            insertSuccessRecords(strBatchLogId, batchLogResultsObj.successRecordIdsSet,bulkUploadConfigMdt.objectApiNameStr);
        //}
        //failedRecordsSaveHelper(objBatchLog);
    }
    
    public void validateSubmitBURules(List<WOD_2__Claim__c> claimSubDataLst){
        List<WOD_2.TWoD_RecordOutputWrapper> buRuleOutputWrapper = ATI_REST_BatchClaimSubmittalService.validateSubmitBURules(claimSubDataLst);
        for(integer i=0;i<buRuleOutputWrapper.size();i++){
            if(buRuleOutputWrapper.get(i).status){
                //successClaimsIds.add(buRuleOutputWrapper.get(i).recordId);
            }
            else{
                if(buRuleOutputWrapper.get(i).message.contains('Please review all hard error rules')){
                    claimIdsForHardRules.add(buRuleOutputWrapper.get(i).recordId);
                }else{
                    claimErrorMap.put(buRuleOutputWrapper.get(i).recordId,buRuleOutputWrapper.get(i).message);
                }
            }
        }
    }
    
    //fetchBusinessRules 
    private void fetchBusinessRules(List<Id> claimIds){
        for(WOD_2__Business_Rule__c businessRule : [SELECT Id,WOD_2__Message__c,WOD_2__Claim__c FROM WOD_2__Business_Rule__c WHERE WOD_2__Claim__c IN:claimIds AND WOD_2__Error_Type__c='Hard']){
            System.debug('claimIdToHardErrorMap----------->'+claimIdToHardErrorMap);
            if(!claimIdToHardErrorMap.containsKey(businessRule.WOD_2__Claim__c)){
                claimIdToHardErrorMap.put(businessRule.WOD_2__Claim__c,businessRule.WOD_2__Message__c);
            }else{
                String errorStr = claimIdToHardErrorMap.get(businessRule.WOD_2__Claim__c) + ' - ' +businessRule.WOD_2__Message__c;
                claimIdToHardErrorMap.put(businessRule.WOD_2__Claim__c,errorStr);
            }
        }
    }
    
    public void insertSuccessRecords(String batchLogId, Set<Id> successRecordIdSet, String objectName){ 
        // Map of Column API Names vs Display Name
        Map<String, String> columnHeaderWithFieldApiMap = new Map<String,String>();
        Map<String, String> columnHeaderReferenceWithFieldApiMap = new Map<String,String>();
        
        List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
        Boolean isPortalEnabled = users[0].IsPortalEnabled;
        
        columnHeaderWithFieldApiMap.put('Id','Id');
        for(ATI_BulkUploadFieldMapping fieldMap : bulkUploadFieldMappingLst) {
            if(!String.isBlank(fieldMap.displayName) && fieldMap.displayName != 'ATI_Extended_Warranty_Purchase_Date__c' && fieldMap.displayName != 'Claim Template Name' 
               && fieldMap.displayName !='Service Campaign Name' && fieldMap.objectAPIName =='WOD_2__Claim__c'){
                columnHeaderWithFieldApiMap.put(fieldMap.displayName,fieldMap.columnName);
                columnHeaderReferenceWithFieldApiMap.put(fieldMap.displayName,fieldMap.type);
            }
        }
        
        // List to Set for String Join
        List<String> csvColumnDisplayNameList = new List<String>();
        csvColumnDisplayNameList.addAll(columnHeaderWithFieldApiMap.keySet());
        
        String query = 'SELECT '+ String.join(csvColumnDisplayNameList,',') + ' FROM '+ objectName + ' WHERE Id IN: successRecordIdSet';
        System.debug('query----->'+query);
        List<sObject> successRecordListforCSV = Database.query(query);
        System.debug('successRecordListforCSV----->'+successRecordListforCSV);
        String csvFile = '';
        columnHeaderWithFieldApiMap.put('Errors','Errors');
        csvFile = String.join(columnHeaderWithFieldApiMap.values(),',');         //Column headers in CSV file
        //System.debug('csvFile>>>>>> '+csvFile);
        for(sObject successRecordObj : successRecordListforCSV) {
            List<String> successCSVRow = new List<String>();
            for(String columnDisplayName : columnHeaderWithFieldApiMap.keySet()) {
                if(columnDisplayName != 'RecordTypeId') { // Ignore RecordType fields
                    // Get the field type on the configuration setting to format
                    String fieldType = '';
                    if(columnHeaderReferenceWithFieldApiMap.containsKey(columnDisplayName)) {
                        fieldType = columnHeaderReferenceWithFieldApiMap.get(columnDisplayName);
                    }
                    if(fieldType == 'Date') {
                        Date dt = (date)successRecordObj.get(columnDisplayName);
                        if(dt != null){
                            successCSVRow.add(dt.format());
                        }else{
                            successCSVRow.add(null);
                        }
                    } else if(columnDisplayName =='Errors'){
                        if(claimIdToHardErrorMap.containsKey((Id)successRecordObj.get('Id'))){
                            successCSVRow.add(claimIdToHardErrorMap.get((Id)successRecordObj.get('Id')));
                        }else if(claimErrorMap.containsKey((Id)successRecordObj.get('Id'))){
                            successCSVRow.add(claimErrorMap.get((Id)successRecordObj.get('Id')));
                        }else{
                            successCSVRow.add(null);
                        }
                    }
                    else {
                        successCSVRow.add(ATI_BulkUploadBatch.getFieldValue(successRecordObj, columnDisplayName));
                    }
                }
            }
            csvFile = csvFile + '\n"'+ String.join(successCSVRow,'","')+'"';
            //System.debug('csvFile>>>>> '+csvFile);
        }
        // Uploaded claims data saved to file(Content Version) & attached to Batch Log
        WOD_2.ResponseWrapper objContentVersionAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
        Map<String,Object> accessCheckCVMap = (Map<String,Object>)Json.deserializeUntyped(objContentVersionAccessCheck.data);
        if(objContentVersionAccessCheck.status && ((List<Object>)accessCheckCVMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckCVMap.get('noAccessFieldList')).isEmpty()
           && String.isNotBlank(batchLogId)){  
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
            conVer.VersionData = Blob.valueOf(csvFile); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
            if(isPortalEnabled){
                String communityName = bulkUploadConfigMdt.communityName;
                List<Network> network = new List<Network>();
                if(communityName != ''){
                    network = [Select Id, Name From Network Where Name =: communityName Limit 1];
                }         
                if(network.size()>0){
                    conVer.NetworkId = network[0].Id;
                }
                
            }
            insert conVer;
            
            if(conVer.Id != null) {
                // First get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                //Create ContentDocumentLink
                ContentDocumentLink cDoc = new ContentDocumentLink();
                cDoc.ContentDocumentId = conDoc;
                cDoc.LinkedEntityId = batchLogId; // BatchLog Id
                cDoc.ShareType = 'V'; //Only View permission
                cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                insert cDoc;
            }
               
            WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=strBatchLogId,WOD_2__Batch_End_Date__c=System.now(),
                                                                                                                                          WOD_2__Success_Record_Count__c=batchLogResultsObj.successRecordCount,
                                                                                                                                          WOD_2__Failure_Record_Count__c=batchLogResultsObj.failedRecordCount,
                                                                                                                                          WOD_2__Total_Record_Count__c = batchLogResultsObj.totalRecordCount,
                                                                                                                                          ATI_Status__c='Completed')},true);
        }
    }
}