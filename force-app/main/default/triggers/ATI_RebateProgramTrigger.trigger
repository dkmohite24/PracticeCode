trigger ATI_RebateProgramTrigger on RebateProgram (after update) {
    ATI_RebateProgramHandler.updateFieldOnProcessingStatusChange(Trigger.new, Trigger.oldMap);
}