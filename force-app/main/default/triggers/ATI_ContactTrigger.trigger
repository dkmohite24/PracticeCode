/**
 * @description       : Contact Trigger.
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Abhishek Mohapatra
**/
trigger ATI_ContactTrigger on Contact (before insert, before update, after insert, after update) {

    if(!ATI_Record_Bypass_Settings__c.getOrgDefaults().ATI_TAC_Trigger_Skip__c){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                ATI_ContactTriggerHandler.forUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }

}