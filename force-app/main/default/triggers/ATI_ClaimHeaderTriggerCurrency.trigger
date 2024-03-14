trigger ATI_ClaimHeaderTriggerCurrency on ATI_C_E__c (after update) {
	ATI_ClaimHeaderHandler.updateFieldOnStatusChange(Trigger.new, Trigger.oldMap);
}