public class ATI_updateClaimQuable implements Queueable{
    List<WOD_2__Claim__c> claimToUpdate ;
    public ATI_updateClaimQuable(List<WOD_2__Claim__c> claimToUpdate){
        this.claimToUpdate = claimToUpdate;
    }
	public void execute(QueueableContext context) {
        Map<Id,WOD_2__Claim__c> claimMap = new Map<Id,WOD_2__Claim__c>(claimToUpdate);
        Map<Id,List<WOD_2__Transaction_Memo_History__c>> claimIdToPaidTMHMap = new Map<Id,List<WOD_2__Transaction_Memo_History__c>>();
        for(WOD_2__Transaction_Memo_History__c tmhObj : [SELECT Id,WOD_2__Claim__c,WOD_2__Transaction_Status__c FROM WOD_2__Transaction_Memo_History__c
                                                         WHERE WOD_2__Claim__c IN :claimMap.keySet()])
        {
            if(claimIdToPaidTMHMap.containsKey(tmhObj.WOD_2__Claim__c)){
                claimIdToPaidTMHMap.get(tmhObj.WOD_2__Claim__c).add(tmhObj);
            }else{
                claimIdToPaidTMHMap.put(tmhObj.WOD_2__Claim__c,new List<WOD_2__Transaction_Memo_History__c>{tmhObj});
            }
        }
        
		
        for(WOD_2__Claim__c claimObj : claimToUpdate){
            Boolean tobePaid = false;
            if(claimIdToPaidTMHMap.containsKey(claimObj.Id)){
                for(WOD_2__Transaction_Memo_History__c tmhObj :claimIdToPaidTMHMap.get(claimObj.Id)){
                    if(tmhObj.WOD_2__Transaction_Status__c == 'Paid'){
                        tobePaid = true;
                    }else{
                        tobePaid = false;
                        break;
                    }
                }
            }
            if(tobePaid){
                claimObj.WOD_2__Claim_Status__c = 'Paid';
            }
        }
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        	update claimToUpdate;
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
    }
}