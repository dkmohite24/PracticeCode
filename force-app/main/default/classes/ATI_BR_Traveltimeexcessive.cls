/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: Travel time excessive.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_Traveltimeexcessive implements WOD_2.BR_BusinessRuleInterface{
    global Integer travel;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'CLM_Time_Travel' LIMIT 1];
        system.debug('bccsList'+bccsList);
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){
            travel =  Integer.valueOf(bccsList[0].WOD_2__Value__c);
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Account__r.ATI_Distance_Per_Hour__c,WOD_2__Account__c
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.Size()>0){
            
            List<WOD_2__Claim_Service_Information__c> serviceLst = [SELECT Id,WOD_2__Claim__c,WOD_2__Additional_Labor_Hour__c,
                                                                    WOD_2__Service_Job_Code__r.Name
                                                                    FROM WOD_2__Claim_Service_Information__c WHERE 
                                                                    WOD_2__Claim__c = : claimlst[0].Id
                                                                    AND WOD_2__Service_Job_Code__r.Name = :'11111111'];
            system.debug('serviceLst'+serviceLst);
            if(serviceLst.Size()>0 && serviceLst[0].WOD_2__Additional_Labor_Hour__c >travel){
                system.debug('Inside If');
                
                return true;  
            }
        }
        }
        return false;
        
    }
}