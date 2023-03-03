public class bbb {
    /*
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
public class ContentDocumentTriggerHandler {
    //After insert Functionality
    public static void afterInsert(List<ContentDocument> newList){
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocument cd : newList)
            contentDocumentIds.add(cd.Id);
        
        if(!contentDocumentIds.isEmpty()) 
            gettingParentIdOnInsertion(contentDocumentIds);
    }
    
    //Before delete functionality
    public static void beforeDelete(List<ContentDocument> newList){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> ContractIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        
        for(ContentDocument cd : newList){
            //if(cd.FileType.equalsIgnoreCase('pdf'))
                contentDocumentIds.add(cd.Id);
        }
        
        if(!contentDocumentIds.isEmpty()){
            for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){
                String linkedEntityId = cdLink.LinkedEntityId+'';
                
                if(linkedEntityId.startsWith('006') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')) {
                    oppIds.add(cdLink.LinkedEntityId);
                }
                else if(linkedEntityId.startsWith('800') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')) {
                    ContractIds.add(cdLink.LinkedEntityId);
                }
            }
            
            if(!oppIds.isEmpty() || !ContractIds.isEmpty()) {
                if(!oppIds.isEmpty()){
                    updateOpportunityCountFuture(oppIds);
                }
                if(!ContractIds.isEmpty()){
                     updateContractCountFuture(ContractIds);
                }
            }
        }
    }
    
    @future
    public static void gettingParentIdOnInsertion(Set<Id> contentDocumentIds){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> ContractIds = new Set<Id>();
        for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){
            String linkedEntityId = cdLink.LinkedEntityId+'';
            System.debug(linkedEntityId);
            if(linkedEntityId.startsWith('006') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')) {
                oppIds.add(cdLink.LinkedEntityId);
            }
            else If((linkedEntityId.startsWith('800') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf'))){
                ContractIds.add(cdLink.LinkedEntityId);
            }
        }
        
        if(oppIds.size() > 0){
            updateOpportunityCount(oppIds);
        }
        if(ContractIds.size() > 0){
           updateContractCount(ContractIds); 
        }
    }
    
    //Updating count value on Opportunity
    @future
    static void updateOpportunityCountFuture(Set<Id> oppIds){
        updateOpportunityCount(oppIds);
    }
    
    static void updateOpportunityCount(Set<Id> oppIds){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Decimal> mapOppIdCount = new Map<Id,Decimal>();
        for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId IN :oppIds]){
            if(cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')){
                Decimal count = mapOppIdCount.containskey(cdLink.LinkedEntityId) ? mapOppIdCount.get(cdLink.LinkedEntityId) : 0;
                mapOppIdCount.put(cdLink.LinkedEntityId,count+1);
            }
        }
        
        for(Id oppId : oppIds){
            Opportunity opp = new Opportunity(Id=oppId);
            opp.Attached_Documents__c = mapOppIdCount.containskey(oppId) ? mapOppIdCount.get(oppId) : 0;
            oppList.add(opp);
        }
        
        UPDATE oppList;
        System.debug(oppList);
    }
    
    
   //Updating count value on Contract
    @future
    static void updateContractCountFuture(Set<Id> ContractIds){
        updateContractCount(ContractIds);
    }
    
    static void updateContractCount(Set<Id> ContractIds){
        List<Contract> ContractList = new List<Contract>();
        Map<Id,Decimal> mapContractIdCount = new Map<Id,Decimal>();
        for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId IN :ContractIds]){
            if(cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')){
                Decimal count = mapContractIdCount.containskey(cdLink.LinkedEntityId) ? mapContractIdCount.get(cdLink.LinkedEntityId) : 0;
                mapContractIdCount.put(cdLink.LinkedEntityId,count+1);
            }
        }
        
        for(Id ContrctId : ContractIds){
            Contract Contrct = new Contract(Id=ContrctId);
            Contrct.Attached_Documents__c = mapContractIdCount.containskey(ContrctId) ? mapContractIdCount.get(ContrctId) : 0;
            ContractList.add(Contrct);
        }
        
        UPDATE ContractList;
        System.debug(ContractList);
    }

    
}
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     
public class ContentDocumentTriggerHandler {
    //After insert Functionality
    public static void afterInsert(List<ContentDocument> newList){
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocument cd : newList)
            contentDocumentIds.add(cd.Id);
        
        if(!contentDocumentIds.isEmpty()) 
            gettingParentIdOnInsertion(contentDocumentIds);
    }
    
    //Before delete functionality
    public static void beforeDelete(List<ContentDocument> newList){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        
        for(ContentDocument cd : newList){
            //if(cd.FileType.equalsIgnoreCase('pdf'))
                contentDocumentIds.add(cd.Id);
        }
        
        if(!contentDocumentIds.isEmpty()){
            for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){
                String linkedEntityId = cdLink.LinkedEntityId+'';
                if(linkedEntityId.startsWith('006') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')) 
                    oppIds.add(cdLink.LinkedEntityId);
            }
            
            if(!oppIds.isEmpty()) 
                updateOpportunityCountFuture(oppIds);
        }
    }
    
    @future
    public static void gettingParentIdOnInsertion(Set<Id> contentDocumentIds){
        Set<Id> oppIds = new Set<Id>();
        for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){
            String linkedEntityId = cdLink.LinkedEntityId+'';
            System.debug(linkedEntityId);
            if(linkedEntityId.startsWith('006') && cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')) 
                oppIds.add(cdLink.LinkedEntityId);
        }
        
        if(oppIds.size() > 0)
            updateOpportunityCount(oppIds);
    }
    
    //Updating count value on Opportunity 
    @future
    static void updateOpportunityCountFuture(Set<Id> oppIds){
        updateOpportunityCount(oppIds);
    }
    
    static void updateOpportunityCount(Set<Id> oppIds){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Decimal> mapOppIdCount = new Map<Id,Decimal>();
        for(ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId IN :oppIds]){
            if(cdLink.ContentDocument.FileType.equalsIgnoreCase('pdf')){
                Decimal count = mapOppIdCount.containskey(cdLink.LinkedEntityId) ? mapOppIdCount.get(cdLink.LinkedEntityId) : 0;
                mapOppIdCount.put(cdLink.LinkedEntityId,count+1);
            }
        }
        
        for(Id oppId : oppIds){
            Opportunity opp = new Opportunity(Id=oppId);
            opp.Attached_Documents__c = mapOppIdCount.containskey(oppId) ? mapOppIdCount.get(oppId) : 0;
            oppList.add(opp);
        }
        
        UPDATE oppList;
        System.debug(oppList);
    }
}
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     
public class OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity> newLst){
        List<Opportunity> newList = new List<Opportunity>();
        
        if(newLst != NULL && newLst.size()>0){
            
            Set<Id> userIds = new Set<Id>();
            User usrData = [SELECT Id, CompanyName FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType =:'Opportunity']);
            String companyName = usrData.CompanyName != NULL ? usrData.CompanyName : ''; 
            
            Boolean isContainsRec = false;
            for(Id rt : recordTypeMap.keySet()){
                if(companyName.containsIgnoreCase(recordTypeMap.get(rt).Name)){
                    isContainsRec = true;
                    break;
                }
            }
            
            for(Opportunity opp : newLst){
                String recordTypeName = recordTypeMap.get(opp.RecordTypeId).Name;
                if(String.isBlank(companyName) || !isContainsRec || companyName.containsIgnoreCase(recordTypeName) || Test.isRunningTest()){
                    newList.add(opp);
                }
                else {
                    opp.addError('Your record type should be '+ companyName);
                }
            }
        }
        if(newList != NULL && newList.size()>0){
            for(Opportunity opp : newList){
                opp.Negotiation_Stage__c = 'Incomplete Documentation';
            }  
        }
    }
    
    // Case Managemennt Sales Step Functionality
    public static void onAfter(List<Opportunity> newList, Map<Id,Opportunity> oldMap) 
    {
        List<Case> insertCase = new List<Case>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType =:'Opportunity']);
       
        List<User> usersList = UtilityController.getUserFromUserRole('Service Delivery');
        
        for(Opportunity opp : newList) {
            if((opp.StageName != NULL && opp.StageName == 'Closed Won' && (oldMap == NULL || oldMap.get(opp.Id).StageName != opp.StageName)) || oldMap != NULL && oldMap.get(opp.Id).OwnerId != opp.OwnerId) {
                oppIds.add(opp.Id);
            }
        }
        if(usersList != NULL && usersList.size() > 0) {
            for(Opportunity opp : [Select Id, StageName, AccountId, Owner.Email, RecordTypeId From Opportunity WHERE Id IN: oppIds]) {
                if(oldMap == NULL || oldMap.get(opp.Id).StageName != opp.StageName) {
                    for(User usr : usersList) {
                        if(usr.CompanyName.containsIgnoreCase(recordTypeMap.get(opp.RecordTypeId).Name)) {
                            insertCase.add(new Case(AccountId = opp.AccountId, Opportunity_Owner_Email__c = opp.Owner.Email, OwnerId = usr.Id, Opportunity__c = opp.Id, Status = 'New', Reason = 'Installation request', Origin = 'Salesforce Opportunity', Priority = 'Medium', CurrencyIsoCode = 'USD'));
                            break;
                        }
                    }
                } else if(oldMap != NULL && oldMap.get(opp.Id).OwnerId != opp.OwnerId) {
                    opportunityMap.put(opp.Id,opp);
                }
            }
            if(!insertCase.isEmpty()) {
                INSERT insertCase;
            }
        }
        List<Case> updateCaseEmailData = new List<Case>();
        if(!opportunityMap.isEmpty()) {
            for(Case cse : [SELECT Id, Opportunity__c, Opportunity_Owner_Email__c FROM Case WHERE Opportunity__c IN: opportunityMap.keySet()]) {
                updateCaseEmailData.add(new Case(Id = cse.Id, Opportunity_Owner_Email__c = opportunityMap.get(cse.Opportunity__c).Owner.Email));
            }
            if(!updateCaseEmailData.isEmpty()) {
                Update updateCaseEmailData;
            }
        }
    }
    public static void beforeUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        Set<Id> oppIdsApproval = new Set<Id>();
        for(Opportunity opp : newList){
            if(opp.Attached_Documents__c != NULL && opp.Attached_Documents__c > 0 && opp.Negotiation_Stage__c != 'Completed Documentation')
                opp.Negotiation_Stage__c = 'Completed Documentation';
            else if(opp.StageName != NULL && opp.StageName == 'Closed Won' && (opp.Attached_Documents__c == NULL || opp.Attached_Documents__c == 0) && oldMap != NULL && opp.StageName != oldMap.get(opp.Id).StageName){
                opp.StageName='Negotiation/Review';
                opp.Negotiation_Stage__c = 'Incomplete Documentation';
                oppIdsApproval.add(opp.Id);
            }
            if(opp.Negotiation_Stage__c == NULL || (oldMap != NULL && opp.Attached_Documents__c != NULL && oldMap.get(opp.Id).Attached_Documents__c != NULL && opp.Attached_Documents__c == 0 && opp.Attached_Documents__c != oldMap.get(opp.Id).Attached_Documents__c))
                opp.Negotiation_Stage__c = 'Incomplete Documentation';
        }
        if(!oppIdsApproval.isEmpty())
            invokeApprovalProcess(oppIdsApproval);
    }
    
    @future
    static void invokeApprovalProcess(Set<Id> oppIds){
        for(Id oppId : oppIds){
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(oppId);
            System.debug(UserInfo.getUserId());
            approvalRequest.setSubmitterId(UserInfo.getUserId());
            approvalRequest.setProcessDefinitionNameOrId('Approval_on_Close_Won_Deal');
            Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
        }
    }
    
    // After sent for approval submission lock record
    public static void approvalSubmission(List<Opportunity> oppNewList, Map<Id,Opportunity> oppOldMap)
    {
        for(Opportunity opp : oppNewList)
        {
            if(opp.Negotiation_Stage__c != NULL && oppOldMap.get(opp.Id).Negotiation_Stage__c != NULL && opp.Negotiation_Stage__c == 'Sent for Approval' && opp.Negotiation_Stage__c == oppOldMap.get(opp.Id).Negotiation_Stage__c){
                opp.addError(System.Label.Record_Lock_Error);
            }
        }
    }
}
     */

}