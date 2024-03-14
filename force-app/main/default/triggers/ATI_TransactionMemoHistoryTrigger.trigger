/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        17-Feb-2021
* @modified
* @description :   Trigger on  WOD_2__Transaction_Memo_History__c
* --------------------------------------------------------------------------------------------------
*/
//ALSN-116 added after update
trigger ATI_TransactionMemoHistoryTrigger on WOD_2__Transaction_Memo_History__c (before insert,after insert,after update) {
	WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_TransactionMemoHistoryTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_TransactionMemoHistoryTriggerHandler().run();
    }
}