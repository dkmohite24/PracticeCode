/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: Travel requires manual review.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_TravelRequiresReview implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Account__r.ATI_Distance_Per_Hour__c,WOD_2__Account__c
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.Size()>0){
            List<WOD_2__Other_Cost__c> otherList = [SELECT Id,WOD_2__Claim__c,WOD_2__Cost_Category_Type__c,WOD_2__UnitsUsage__c 
                                                    FROM WOD_2__Other_Cost__c WHERE 
                                                    WOD_2__Claim__c = : claimlst[0].Id
                                                   AND WOD_2__Cost_Category_Type__c = 'Travel By Distance'];
            system.debug('otherList'+otherList);
            
            List<WOD_2__Claim_Service_Information__c> serviceLst = [SELECT Id,WOD_2__Claim__c,WOD_2__Additional_Labor_Hour__c,
                                                                    WOD_2__Service_Job_Code__r.Name
                                                                    FROM WOD_2__Claim_Service_Information__c WHERE 
                                                                    WOD_2__Claim__c = : claimlst[0].Id
                                                                    AND WOD_2__Service_Job_Code__r.Name = :'11111111'];
            system.debug('serviceLst'+serviceLst);
            if(otherList.size() > 0 && serviceLst.Size()>0 && serviceLst[0].WOD_2__Additional_Labor_Hour__c >0 && otherList[0].WOD_2__UnitsUsage__c>0){
                 system.debug('Inside If');
            Decimal distance = otherList[0].WOD_2__UnitsUsage__c/serviceLst[0].WOD_2__Additional_Labor_Hour__c;
            system.debug('distance'+distance);         
            if(distance >claimlst[0].WOD_2__Account__r.ATI_Distance_Per_Hour__c){
                return true;  
            }
        }
        }
        return false;
        
    }
}