global class ATI_CLM_AppealIntialValidation implements WOD_2.CLM_AppealIntialValidationInterface {
	global WOD_2.ResponseWrapper doInitialValidation(String claimId) {
        WOD_2.ResponseWrapper resWrapperObject = new WOD_2.ResponseWrapper('',true,'');
        List<WOD_2__Claim__c> claimLst = new List<WOD_2__Claim__c>();
        String queryStr = 'SELECT Id, WOD_2__Claim_Status__c,WOD_2__BusinessCategory__c'
            			 +' FROM WOD_2__Claim__c WHERE Id = \''+claimId+'\'';
        claimLst = ATI_QueryRunWithoutSharing.runQuery(queryStr);
        if(!claimLst.isEmpty() && claimLst[0].WOD_2__BusinessCategory__c != null) {
            List<WOD_2__Business_Category_Configuration_Setting__c>
                bccsRecords= [SELECT Id,Name,WOD_2__Business_Category_Configuration__c,WOD_2__Value__c 
                              FROM WOD_2__Business_Category_Configuration_Setting__c 
                              WHERE Name = 'CLM_Appeal_RejectedClaimStatuses' 
                              AND WOD_2__Business_Category_Configuration__c = :claimLst[0].WOD_2__BusinessCategory__c LIMIT 1];
            
            if(!bccsRecords.isEmpty() && String.isNotBlank(bccsRecords[0].WOD_2__Value__c) 
               && bccsRecords[0].WOD_2__Value__c.containsIgnoreCase(claimLst[0].WOD_2__Claim_Status__c)) 
            {
                resWrapperObject.status = true;
                resWrapperObject.errormessage = '';
            } else {
                resWrapperObject.status = false;
                resWrapperObject.errormessage =  System.Label.ATI_Appeal_Validation_Message;
            }
        }else{
            resWrapperObject.status = false;
            resWrapperObject.errormessage =  System.Label.Please_Check_the_Business_Category_on_Claim;
        }
        return resWrapperObject;
    }
}