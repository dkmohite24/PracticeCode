/* Name: ATI_UpdateClaimStatusToRejectBatch
Description : ATI_UpdateClaimStatusToRejectBatch for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     21-JAN-2021        INITIAL DEVELOPMENT							
*/

global class ATI_UpdateClaimStatusToRejectBatch implements database.Batchable<sObject>, database.stateful {
     global Integer days;
    global database.QueryLocator start(database.BatchableContext bc){
        // Query BCCS
       
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'CLM_StatusUpdateToRejectAfter_Days' LIMIT 1]; 
        if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){
            days =  Integer.valueOf(bccsList[0].WOD_2__Value__c);
            Date tDay = date.today(); 
            string query = 'SELECT id, WOD_2__Claim_Status__c,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c = \'Additional Information Required\' ' ;//AND ATI_Additional_Info_statusDate__c = \''+tDay.addDays(-1*days)+ '\'
            System.debug('>> query :'+query);
            return database.getQueryLocator(query); 
        }
        return database.getQueryLocator('');
    }   
    global void execute(database.BatchableContext bc, List<WOD_2__Claim__c> claimRecList){
        System.debug('>>claimRecList :'+claimRecList);
        List<WOD_2__Claim__c> claimToUpdate = new List<WOD_2__Claim__c>();
        for(WOD_2__Claim__c claim : claimRecList){
            if(claim.ATI_Additional_Info_statusDate__c.daysBetween(system.today())>=days){
                WOD_2__Claim__c nc = new WOD_2__Claim__c();
                nc.id = claim.id;
                nc.WOD_2__Claim_Status__c = 'Rejected';
                claimToUpdate.add(nc);
            }
            
        }
        if(!claimToUpdate.isEmpty()){
            update claimToUpdate;
        }
    }
    global void finish(database.BatchableContext bc){
        
    }

}