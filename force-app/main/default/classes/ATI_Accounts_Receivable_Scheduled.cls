/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
This class is used for scheduling Accounts Receivable batch class
* -------------------------------------------------------------------------------------------------
* @author         (Punam)
* @version        1.0
* @created        31-Mar-2021
* @modified
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
global class ATI_Accounts_Receivable_Scheduled implements schedulable{
    global void execute(SchedulableContext sc)
    {
        ATI_Accounts_ReceivableBatch batchJob = new ATI_Accounts_ReceivableBatch();
        database.executebatch(batchJob,25);
    }
}