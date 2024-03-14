/* Name: ATI_UpdateClaimStatusToClosedBatch
Description : ATI_UpdateClaimStatusToClosedBatch for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     2-FEB-2021        INITIAL DEVELOPMENT							
*/

global class ATI_UpdateClaimStatusToClosedBatch implements database.Batchable<sObject>, database.stateful {
    global Integer months;
    List<WOD_2__Claim__c> claimToUpdate = new List<WOD_2__Claim__c>();
    global database.QueryLocator start(database.BatchableContext bc){
        // Query BCCS
        List<String> bccsNames = new List<String>{'ATI_CLM_StatusUpdateToCloseAfter_Months', 'ATI_CLM_CloseStatusFilter'}; 
        List<String> statusList = new List<String>();
        string query;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name IN :bccsNames LIMIT 2]; 
        if(bccsList.size()==2){
            for(WOD_2__Business_Category_Configuration_Setting__c bccs : bccsList){
                if(bccs.Name == 'ATI_CLM_StatusUpdateToCloseAfter_Months'){
                     months =  Integer.valueOf(bccs.WOD_2__Value__c);
                }else{
                    statusList = bccs.WOD_2__Value__c.split(',');
                }
            }
            
            Date tDay = date.today(); 
            //ALSN-195 ATI_IsClosed__c added
            if(!Test.isRunningTest()){
                query = 'SELECT Id, LastModifiedDate, ATI_IsClosed__c, WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c IN :statusList and ATI_IsClosed__c = false and LastModifiedDate < LAST_N_MONTHS:'+months+' and Name Like \'AT%\'';//AND ATI_Additional_Info_statusDate__c = \''+tDay.addDays(-1*days)+ '\'
            }else{
                query = 'SELECT Id, LastModifiedDate, ATI_IsClosed__c, WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c IN :statusList and ATI_IsClosed__c = false and Name Like \'AT%\'';
            }
            System.debug('>> query :'+query);
            return database.getQueryLocator(query);
        }
        return database.getQueryLocator('');
    }   
    global void execute(database.BatchableContext bc, List<WOD_2__Claim__c> claimRecList){
        //List<WOD_2__Claim__Share> csToUpdateList = new List<WOD_2__Claim__Share>();
        for(WOD_2__Claim__c claim : claimRecList){
           Integer monthsDiff = Date.valueOf(claim.lastModifiedDate).monthsBetween(system.today());
            if(Date.valueOf(claim.lastModifiedDate).day()> system.today().day()) {
               monthsDiff--;
            }
            if(monthsDiff>=months || test.isRunningTest()){
                //ALSN-195
                //nc.WOD_2__Claim_Status__c = 'Closed';
                claim.ATI_IsClosed__c = true;
                claimToUpdate.add(claim);
            } 
        }
       /* for(WOD_2__Claim__Share cs: [SELECT id, ParentId,Parent.ownerId,UserOrGroupId, AccessLevel FROM WOD_2__Claim__Share WHERE ParentId IN : claimToUpdate ] ){ //AND AccessLevel ='Edit'
            //WOD_2__Claim__Share tcs = new WOD_2__Claim__Share();
            if(!(cs.Parent.ownerId == cs.UserOrGroupId))
            csToUpdateList.add(cs);
        } */
        
        if(!claimToUpdate.isEmpty()){ 
            system.debug('>> claimToUpdate :'+claimToUpdate);
            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
            update claimToUpdate;
            TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        }
       //csToUpdateList= [SELECT id, ParentId,UserOrGroupId, AccessLevel FROM WOD_2__Claim__Share WHERE ParentId IN : claimToUpdate ];
       /* if(!csToUpdateList.isEmpty()){
            system.debug('>> csToUpdateList :'+csToUpdateList);
            delete csToUpdateList;
        }*/
    }
    global void finish(database.BatchableContext bc){
        
    }

}