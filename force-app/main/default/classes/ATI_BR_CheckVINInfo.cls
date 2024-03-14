/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        30-April-2021
* @modified
* @description :   Trigger from BU rule -> checking if VIN is associated with Other inventories also
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_CheckVINInfo implements WOD_2.BR_BusinessRuleInterface{
	global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());              
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Inventory__c
                                       FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = [SELECT Id,ATI_Vehicle_Information__c 
                                                                      	FROM ATI_VIN_Transmission_Mapper__c 
                                                                      	WHERE ATI_Inventory__c=:claimObj.WOD_2__Inventory__c
                                                                      	ORDER BY LastModifiedDate DESC Limit 1];
        if(!vehicleTransMapperLst.isEmpty()){
            //added extra query since not able to add ORDER BY in where clause nested query
            List<ATI_Vehicle_Information__c> vehiclesLst = [SELECT Id,(SELECT Id FROM Transmissions__r)
                                                       		FROM ATI_Vehicle_Information__c
                                                       		WHERE Id =:vehicleTransMapperLst[0].ATI_Vehicle_Information__c];
            if(!vehiclesLst.isEmpty() && !vehiclesLst[0].Transmissions__r.isEmpty() && vehiclesLst[0].Transmissions__r.size() > 1){
                System.debug('CPU Limit After -> ' + Limits.getCpuTime());              
                return true;
            }
        }
        System.debug('CPU Limit After -> ' + Limits.getCpuTime());              
        return false;
    }
}