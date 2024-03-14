/* Name: ATI_ExtWarrantyPricingTrigger
Description : ATI_ExtWarrantyPricingTrigger - Trigger on ATI_Extended_Warranty_Pricing__c to add weightage and verify for overlapping dates.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      04-JAN-2021          INITIAL DEVELOPMENT
*/
trigger ATI_ExtWarrantyPricingTrigger on ATI_Extended_Warranty_Pricing__c (before insert, before update) {
    new ATI_ExtWarrantyPricingTriggerHandler().run();
}