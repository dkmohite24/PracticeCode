/* Name: ATI_ExtWarrantyPricingTriggerHandler
Description : ATI_ExtWarrantyPricingTriggerHandler - Handler class for ATI_ExtWarrantyPricingTrigger Trigger.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      04-JAN-2021          INITIAL DEVELOPMENT
*/
public with sharing class ATI_ExtWarrantyPricingTriggerHandler extends TriggerHandler{

    @TestVisible
    private List<ATI_Extended_Warranty_Pricing__c> newExtWarrantyPricingList;
    @TestVisible
    private List<ATI_Extended_Warranty_Pricing__c> oldExtWarrantyPricingList;
    @TestVisible
    private Map<Id,ATI_Extended_Warranty_Pricing__c> oldExtWarrantyPricingMap;
    @TestVisible
    private Map<Id,ATI_Extended_Warranty_Pricing__c> newExtWarrantyPricingMap;


    public ATI_ExtWarrantyPricingTriggerHandler() {
        this.newExtWarrantyPricingList = (List<ATI_Extended_Warranty_Pricing__c>)Trigger.new;
        this.oldExtWarrantyPricingList = (List<ATI_Extended_Warranty_Pricing__c>)Trigger.old;
        this.newExtWarrantyPricingMap = (Map<Id, ATI_Extended_Warranty_Pricing__c>)Trigger.newMap;
        this.oldExtWarrantyPricingMap = (Map<Id, ATI_Extended_Warranty_Pricing__c>)Trigger.newMap;
    }

    public override void beforeInsert() {
        Set<Integer> weightageSet = calculateWeightage(newExtWarrantyPricingList);
        validateForOverlappingDates(newExtWarrantyPricingList, weightageSet);
    }
    
    public override void beforeUpdate() {
        Set<Integer> weightageSet = calculateWeightage(newExtWarrantyPricingList);
        validateForOverlappingDates(newExtWarrantyPricingList, weightageSet);
    }
    
    private String getKey(ATI_Extended_Warranty_Pricing__c extWarrantyPrice){
        String key = '';
        if(String.isNotEmpty(extWarrantyPrice.ATI_Warranty_Product__c)){
            key += extWarrantyPrice.ATI_Warranty_Product__c;
        }
        if(String.isNotEmpty(extWarrantyPrice.ATI_Country__c)){
            key += extWarrantyPrice.ATI_Country__c;
        }
        if(String.isNotEmpty(extWarrantyPrice.ATI_Vocation_Code__c)){
            key += extWarrantyPrice.ATI_Vocation_Code__c;
        }
        if(String.isNotEmpty(extWarrantyPrice.ATI_Program_Level__c)){
            key += extWarrantyPrice.ATI_Program_Level__c;
        }
        if(String.isNotEmpty(extWarrantyPrice.ATI_Policy_Definition__c)){
            key += extWarrantyPrice.ATI_Policy_Definition__c;
        }

        return key;
    }

    @TestVisible
    private Boolean validateForOverlappingDates(List<ATI_Extended_Warranty_Pricing__c> extWarrantyPricingList, Set<Integer> weightageSet){
        Boolean isValid = true;
        Map<String, ATI_Extended_Warranty_Pricing__c> extWPMap = new Map<String,ATI_Extended_Warranty_Pricing__c>();
        Set<Id> policyDefIdSet = new Set<Id>();
        Set<Id> vocationCodeIdSet = new Set<Id>();
        Set<Id> modelIdSet = new Set<Id>();
        for(ATI_Extended_Warranty_Pricing__c extWarrantyPrice : extWarrantyPricingList){
            String key = getKey(extWarrantyPrice);
            if(String.isNotEmpty(extWarrantyPrice.ATI_Policy_Definition__c)){
                policyDefIdSet.add(extWarrantyPrice.ATI_Policy_Definition__c);
                vocationCodeIdSet.add(extWarrantyPrice.ATI_Vocation_Code__c);
                modelIdSet.add(extWarrantyPrice.ATI_Warranty_Product__c);
            }
            extWPMap.put(key, extWarrantyPrice);
        }
        System.debug('Existing WP Map -> ' + extWPMap);
        // not doing access check,as we are in trigger, if Update/Create access is there then read will be avilable
        List<ATI_Extended_Warranty_Pricing__c> oldExtWPList = 
            [select Id, ATI_Warranty_Product__c, ATI_Country__c, ATI_Vocation_Code__c,ATI_Program_Level__c,
             ATI_Policy_Definition__c, ATI_Weightage__c,ATI_Active_From__c,ATI_Active_Until__c from
             ATI_Extended_Warranty_Pricing__c where ATI_Policy_Definition__c in :policyDefIdSet AND
             ATI_Vocation_Code__c in :vocationCodeIdSet AND ATI_Warranty_Product__c in :modelIdSet
             and ATI_Weightage__c in :weightageSet];
        System.debug('oldExtWPList -> ' + oldExtWPList);
        System.debug('oldExtWPList.size() -> ' + oldExtWPList.size());
        for(ATI_Extended_Warranty_Pricing__c oldExtWarrantyPrice : oldExtWPList){
            String key = getKey(oldExtWarrantyPrice);
            ATI_Extended_Warranty_Pricing__c newExtWP = extWPMap.get(key);
            System.debug('key -> ' + key);
            if(newExtWP != null && oldExtWarrantyPrice.Id != newExtWP.Id && newExtWP.ATI_Weightage__c == oldExtWarrantyPrice.ATI_Weightage__c && 
              newExtWP.ATI_Program_Level__c == oldExtWarrantyPrice.ATI_Program_Level__c){
                  System.debug('first Fail');
                  System.debug('newExtWP -> ' + newExtWP);
                  System.debug('oldExtWarrantyPrice -> ' + oldExtWarrantyPrice);
                  if((newExtWP.ATI_Active_From__c >= oldExtWarrantyPrice.ATI_Active_From__c && newExtWP.ATI_Active_From__c <= oldExtWarrantyPrice.ATI_Active_Until__c) ||
                     (newExtWP.ATI_Active_Until__c >= oldExtWarrantyPrice.ATI_Active_From__c && newExtWP.ATI_Active_Until__c <= oldExtWarrantyPrice.ATI_Active_Until__c)){
                         newExtWP.addError(Label.ATI_EWP_Pricing_with_Overlapping_Dates);                       
                         isValid = false;
                     }
            }
        }
        return isValid;
    }

    @TestVisible
    private Set<Integer> calculateWeightage(List<ATI_Extended_Warranty_Pricing__c> extWarrantyPricingList){
		Set<Integer> weightageSet = new Set<Integer>();
        for(ATI_Extended_Warranty_Pricing__c extWarrantyPrice : extWarrantyPricingList){
            Integer weightage = 0;
            if(extWarrantyPrice.ATI_Warranty_Product__c != null){
                weightage += 16;
            }
            if(extWarrantyPrice.ATI_Vocation_Code__c != null){
                weightage += 8;
            }
            if(extWarrantyPrice.ATI_Program_Level__c != null){
                weightage += 4;
            }
            if(extWarrantyPrice.ATI_Country__c != null){
                weightage += 2;
            }
            weightageSet.add(weightage);
            extWarrantyPrice.ATI_Weightage__c = weightage;
        }
        return weightageSet;
    }

}