/**
* @description       :
* @author            :
* @group             :
* @last modified on  : 11-14-2023
* @last modified by  : Abhishek Mohapatra
**/
trigger PRPC_BranchCount on Account(
    before delete,
    before insert,
    before update,
    after delete,
    after insert,
    after update
) {
    String userName = userinfo.getName();
    system.debug('user name :'+userName);
    if (!ATI_Record_Bypass_Settings__c.getInstance().ATI_TAC_Trigger_Skip__c) {
        WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData(
            'ATI_AccountTrigger'
        );
        if (executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
            new ATI_AccountTriggerHandler().run();
        }
        
        if (!Disable_Rules__c.getInstance('PRPC_BranchCount').Disable__c) {
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    PRPC_BranchCount.forInsert(Trigger.new);
                    if (userName !='Svc Mulesoft' && 
                        !ATI_Record_Bypass_Settings__c.getOrgDefaults()
                        .ATI_TAC_Trigger_Skip__c
                       ) {
                           ATI_Services.accountAddressValidate(Trigger.new);
                       }
                }
                if (Trigger.isUpdate) {
                    PRPC_BranchCount.forUpdate(Trigger.new);
                    if (userName !='Svc Mulesoft' && 
                        !ATI_Record_Bypass_Settings__c.getOrgDefaults()
                        .ATI_TAC_Trigger_Skip__c
                       ) {
                           ATI_Services.accountAddressValidate(Trigger.new, Trigger.oldMap);
                       }
                }
                if (Trigger.isDelete) {
                    PRPC_BranchCount.forDelete(Trigger.old);
                }
            }
        }
    } else if (
        !ATI_Record_Bypass_Settings__c.getOrgDefaults().ATI_TAC_Trigger_Skip__c
    ) {
        if (userName !='Svc Mulesoft' && Trigger.isAfter) {
            if (Trigger.isInsert) {
                ATI_Services.accountAddressValidate(Trigger.new);
            }
            if (Trigger.isUpdate) {
                ATI_Services.accountAddressValidate(Trigger.new, Trigger.oldMap);
            }
        }
    }  
}