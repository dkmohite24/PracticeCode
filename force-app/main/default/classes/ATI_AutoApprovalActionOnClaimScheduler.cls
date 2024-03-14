/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        07-May-2021
* @modified
* @description :   Scheduler class for Batch ATI_AutoApprovalActionOnClaimBatch
* --------------------------------------------------------------------------------------------------
*/
global class ATI_AutoApprovalActionOnClaimScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new ATI_AutoApprovalActionOnClaimBatch(),1);
    }
}