/* Name: ATI_UpdateClaimStatusToCancelledBatch
Description : ATI_UpdateClaimStatusToCancelledBatch for ATI.
User Story : CLM/ADJ/US01
Author : Tavant (DB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (DB)     16-FEB-2021        INITIAL DEVELOPMENT							
*/
global class ATI_UpdateClaimStatusToCancelledBatch implements database.Batchable<sObject>, database.stateful {
     global Integer months;
    global database.QueryLocator start(database.BatchableContext bc){
       List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'CLM_StatusUpdateToCancelledAfter_Months' LIMIT 1]; 
        if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){
            months =  Integer.valueOf(bccsList[0].WOD_2__Value__c);
            Date tDay = date.today(); 
            string query = 'SELECT id, WOD_2__Claim_Status__c,lastModifiedDate FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c = \'Draft\' ';
            
           // string query = 'SELECT id, WOD_2__Claim_Status__c,lastModifiedDate FROM WOD_2__Claim__c WHERE id = \'\' ';
            return database.getQueryLocator(query); 
            
        }
        return database.getQueryLocator('');
    }   
    global void execute(database.BatchableContext bc, List<WOD_2__Claim__c> claimRecList){
       
        List<WOD_2__Claim__c> claimToUpdate = new List<WOD_2__Claim__c>();
        for(WOD_2__Claim__c claim : claimRecList){
           Integer monthsDiff = Date.valueOf(claim.lastModifiedDate).monthsBetween(system.today());
           if(Date.valueOf(claim.lastModifiedDate).day()> system.today().day()) monthsDiff--;
            system.debug('>> claim.lastModifiedDate :'+claim.lastModifiedDate);
            system.debug('>> system.today() :'+system.today());
            system.debug('>> monthsDiff :'+monthsDiff);
            if(monthsDiff>=months || test.isRunningTest()){
                WOD_2__Claim__c nc = new WOD_2__Claim__c();
                nc.id = claim.id;
                nc.WOD_2__Claim_Status__c = 'Cancelled';  
                claimToUpdate.add(nc);
            } 
            
        }
        
        if(!claimToUpdate.isEmpty()){ 
            system.debug('>> claimToUpdate :'+claimToUpdate);
            update claimToUpdate;
        }

    }
    global void finish(database.BatchableContext bc){
        
    }

}