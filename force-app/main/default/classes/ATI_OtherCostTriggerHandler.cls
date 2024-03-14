/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        12-Jan-2021
* @modified
* @description :   Trigger Handler Class for ATI_OtherCostTrigger 
* --------------------------------------------------------------------------------------------------
*/
public class ATI_OtherCostTriggerHandler extends TriggerHandler {
    private List<WOD_2__Other_Cost__c> newOcList;
    private List<WOD_2__Other_Cost__c> oldOcList;
    private Map<Id, WOD_2__Other_Cost__c> newOcMap;
    private Map<Id, WOD_2__Other_Cost__c> oldOcMap;
    
    public ATI_OtherCostTriggerHandler() {
        this.newOcList = (List<WOD_2__Other_Cost__c>) Trigger.new;
        this.oldOcList = (List<WOD_2__Other_Cost__c>) Trigger.old;
        this.newOcMap = (Map<Id, WOD_2__Other_Cost__c>) Trigger.newMap;
        this.oldOcMap = (Map<Id, WOD_2__Other_Cost__c>) Trigger.oldMap;
    }
    
    public override void afterInsert() {
        if(!System.isBatch()){
            List<Id> otherCostIdList = new List<Id>(newOcMap.keySet());
            otherCostAccountShare(otherCostIdList);
		}
        //Added by Dishari on 20th April 2021 related to 22797 bug
        otherCostAutoNumber();
    }
    
	// Trigger Methods
    public override void beforeInsert() {
        validateOtherCostsOnClaim(Trigger.new);
    }
    
    public static void validateOtherCostsOnClaim(List<WOD_2__Other_Cost__c> otherCostLst){
        Set<Id> claimIdsSet = new Set<Id>();
        Map<Id,List<String>> claimIdToOtherCostCCListMap = new Map<Id,List<String>>();
        
        for(WOD_2__Other_Cost__c otherCostObj : otherCostLst){
            if(otherCostObj.WOD_2__Claim__c != NULL && (otherCostObj.WOD_2__Cost_Category_Type__c == 'Overtime' 
                                                        || otherCostObj.WOD_2__Cost_Category_Type__c == 'Towing'
                                                        || otherCostObj.WOD_2__Cost_Category_Type__c == 'Sublet')){
                claimIdsSet.add(otherCostObj.WOD_2__Claim__c);
            }
        }
        for(WOD_2__Other_Cost__c otherCostObj: [SELECT Id,WOD_2__Cost_Category_Type__c,WOD_2__Claim__c
                                               		FROM WOD_2__Other_Cost__c WHERE WOD_2__Claim__c IN :claimIdsSet])
        {
            if(claimIdToOtherCostCCListMap.containsKey(otherCostObj.WOD_2__Claim__c)){
                claimIdToOtherCostCCListMap.get(otherCostObj.WOD_2__Claim__c).add(otherCostObj.WOD_2__Cost_Category_Type__c);
            }else{
                claimIdToOtherCostCCListMap.put(otherCostObj.WOD_2__Claim__c,new List<String>{otherCostObj.WOD_2__Cost_Category_Type__c});
            }
        }
        for(WOD_2__Other_Cost__c otherCostObj : otherCostLst){
            if(otherCostObj.WOD_2__Claim__c != NULL && (otherCostObj.WOD_2__Cost_Category_Type__c == 'Overtime' 
                                                        || otherCostObj.WOD_2__Cost_Category_Type__c == 'Towing'
                                                        || otherCostObj.WOD_2__Cost_Category_Type__c == 'Sublet')
              && claimIdToOtherCostCCListMap.containskey(otherCostObj.WOD_2__Claim__c)
              && claimIdToOtherCostCCListMap.get(otherCostObj.WOD_2__Claim__c).contains(otherCostObj.WOD_2__Cost_Category_Type__c))
            { 
                otherCostObj.addError(System.Label.ATI_DisAllowMultipleCostCategory);
            }
        }
    }
    
    @future
    public static void otherCostAccountShare(List<id> otherCostIdList) {
        List<WOD_2__Other_Cost__c> otherCostList = [
            SELECT id, WOD_2__Claim__r.WOD_2__Account__r.Public_Group_Id__c
            FROM WOD_2__Other_Cost__c
            WHERE id IN :otherCostIdList
        ];
        List<WOD_2__Other_Cost__Share> otherCostShareList = new List<WOD_2__Other_Cost__Share>();
        for(WOD_2__Other_Cost__c otherCost : otherCostList) {
            if(!String.isBlank(otherCost.WOD_2__Claim__r.WOD_2__Account__r.Public_Group_Id__c)) {
                otherCostShareList.add(
                    new WOD_2__Other_Cost__Share(
                        AccessLevel = 'Edit',
                        ParentId = otherCost.id,
                        UserOrGroupId = otherCost.WOD_2__Claim__r.WOD_2__Account__r.Public_Group_Id__c
                    )
                );
            }
        }
        insert otherCostShareList;
    }
	 /*
	Method Name :  OtherCostAutoNumber
	Params      :   Set OtherCost AutoNumber */
   //Added by Dishari on 20th April 2021 related to 22797 bug
	
    public void otherCostAutoNumber() {
        system.debug('>>>>>>>');
        List<WOD_2__Other_Cost__c> lstOfOthercost = New List<WOD_2__Other_Cost__c>();
        for(WOD_2__Other_Cost__c nOthercost :newOcList){
            if(nOthercost.ATI_Other_Cost_Number__c != NULL){
                WOD_2__Other_Cost__c otherCost = new WOD_2__Other_Cost__c();
                otherCost.id = nOthercost.id;
                otherCost.Name = nOthercost.ATI_Other_Cost_Number__c;
                lstOfOthercost.add(otherCost);
                system.debug('lstOfOthercost>>>'+lstOfOthercost);
            }  
        }
        if(!lstOfOthercost.isEmpty()){
            TriggerHandler.bypass('ATI_OtherCostTriggerHandler');
            update lstOfOthercost;
            TriggerHandler.clearBypass('ATI_OtherCostTriggerHandler');
        }
    }
}