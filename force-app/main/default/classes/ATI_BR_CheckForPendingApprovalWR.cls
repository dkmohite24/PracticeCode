global class ATI_BR_CheckForPendingApprovalWR implements WOD_2.BR_BusinessRuleInterface {
    public Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Inventory__c FROM WOD_2__Claim__c 
                                            WHERE Id=:wrapper.ruleObjectId];
        if(claimLst[0].WOD_2__Inventory__c != NULL){
            List<WOD_2__Warranty_Registration__c> pendingApprovalWRLst = [SELECT Id,WOD_2__Inventory__c 
                                                                            FROM WOD_2__Warranty_Registration__c
                                                                            WHERE WOD_2__Inventory__c =: claimLst[0].WOD_2__Inventory__c
                                                                                AND (WOD_2__Status__c='In Progress'
                                                                                OR WOD_2__Status__c='Pending Warranty Processor Approval')];
            if(pendingApprovalWRLst.size() > 0){
                return true;
            }
            System.debug('pendingApprovalWRLst------>'+pendingApprovalWRLst);
        }
        return false;
    }
}