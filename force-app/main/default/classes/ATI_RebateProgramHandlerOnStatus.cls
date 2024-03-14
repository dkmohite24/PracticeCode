public class ATI_RebateProgramHandlerOnStatus {
    public static void handleProcessingStatusChange(List<RebateProgram> newRecords) {
        for (RebateProgram rebateProgram : newRecords) {
            // Check if the Processing Status is being set to 'Submitted - Waiting for Approval' without approval
            if (rebateProgram.ATI_Processing_Status__c == 'Submitted - Waiting for Approval' && !isSubmittedForApproval(rebateProgram)) {
                // Prevent manual changes to Processing Status without approval
                rebateProgram.addError('Incentive cannot be set to Submitted - Waiting for Approval without being submitted for approval.');
            }
        }
    }

    
    private static Boolean isSubmittedForApproval(RebateProgram rebateProgram) {
  
    List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :rebateProgram.Id AND Status = 'Pending'];
    return !processInstances.isEmpty();
}




}