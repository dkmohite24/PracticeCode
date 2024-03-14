public with sharing class ATI_REST_CreditDebitNotifnValidator {
    public static Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> validClaimCreditDebitNotfnMap {get; private set;} 
    public static Map<String, String> erroredClaimData{get; private set;}
    public static Map<Integer,List<String>> mapOfFailure{get; private set;}
    public static Integer totalrecords{get; private set;}
    public static Integer totalFailedRecords{get; private set;}
    
    public ATI_REST_CreditDebitNotifnValidator(){
        validClaimCreditDebitNotfnMap = new Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification>();
        erroredClaimData = new Map<String, String>();
        mapOfFailure = new Map<Integer,List<String>>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }

    public void validateRequest(List<ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> creditNtfnReqLst){
        system.debug('creditNtfnReqObj------>'+creditNtfnReqLst);
        Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> allClaimCreditDebitNotfnMap = 
                                    new Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification>();
        Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification> pendingPaymentClaimsMap = 
                                    new Map<String,ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification>();
        Set<String> claimValidTMHSet = new Set<String>();
        for(ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification creditNtfnReqObj :creditNtfnReqLst){
            if(creditNtfnReqObj.claim.trim() != NULL){
                allClaimCreditDebitNotfnMap.put(creditNtfnReqObj.claim.trim(),creditNtfnReqObj);
            }
        }
        for(WOD_2__Claim__c claimObj : [SELECT Id,Name,
                                            (SELECT Id FROM WOD_2__Transaction_Memo_Historys__r WHERE WOD_2__Transaction_Status__c='Waiting for Payment Confirmation')
                                            FROM WOD_2__Claim__c WHERE Name IN :allClaimCreditDebitNotfnMap.keySet()
                                       		AND WOD_2__Claim_Status__c='Pending Payment Confirmation']){
            pendingPaymentClaimsMap.put(claimObj.Name,allClaimCreditDebitNotfnMap.get(claimObj.Name));
            if(!claimObj.WOD_2__Transaction_Memo_Historys__r.isEmpty()){
                claimValidTMHSet.add(claimObj.Name);
            }
        }
        for(WOD_2__Warranty_Registration__c wrObj : [SELECT Id,Name,
                                            (SELECT Id FROM Transaction_Memo_Histories__r WHERE WOD_2__Transaction_Status__c='Waiting for Payment Confirmation')
                                            FROM WOD_2__Warranty_Registration__c WHERE Name IN :allClaimCreditDebitNotfnMap.keySet()]){
            pendingPaymentClaimsMap.put(wrObj.Name,allClaimCreditDebitNotfnMap.get(wrObj.Name));
            if(!wrObj.Transaction_Memo_Histories__r.isEmpty()){
                claimValidTMHSet.add(wrObj.Name);
            }
        }
        Integer  i = 1;
        for(ATI_REST_CreditDebitNotificationRequest.CreditDebitNotification creditNtfnReqObj :creditNtfnReqLst){
            List<String> strErrorLst = new List<String>();
            if(String.isBlank(creditNtfnReqObj.claim)){
                strErrorLst.add(System.Label.ATI_Claim_Number_is_Mandatory); 
            }
            if(String.isBlank(creditNtfnReqObj.transactionNumber)){
                strErrorLst.add(System.Label.ATI_Transaction_Number_is_Mandatory);
            }
            if(!String.isBlank(creditNtfnReqObj.claim) && !pendingPaymentClaimsMap.keySet().contains(creditNtfnReqObj.claim.trim())){
                strErrorLst.add(System.Label.ATI_Claim_Number_does_not_exist);
            } 
            if(String.isBlank(creditNtfnReqObj.transactionDate)){
                strErrorLst.add(System.Label.ATI_Transaction_Date_is_mandatory);
            }
            if(String.isBlank(creditNtfnReqObj.transactionStatus)){
                strErrorLst.add(System.Label.ATI_Transaction_Status_is_Mandatory);
            }
            if(!String.isBlank(creditNtfnReqObj.transactionStatus) && !creditNtfnReqObj.transactionStatus.equalsIgnoreCase('Paid')){
                strErrorLst.add('Transaction status must be Paid');
            }
            if(!String.isBlank(creditNtfnReqObj.transactionDate)){
                Date transactionDateTemp = ATI_Utils.parseDate(creditNtfnReqObj.transactionDate.trim());
                if(transactionDateTemp == NULL){
                    strErrorLst.add(System.Label.ATI_Transaction_Date_is_Invalid);
                }
            }
            if(!String.isBlank(creditNtfnReqObj.claim) && !claimValidTMHSet.contains(creditNtfnReqObj.claim.trim())){
                strErrorLst.add('Transaction Memo History is not in Waiting For Payment Confirmation Status!');
            }
            String commaSepratedList='';
            for(String str : strErrorLst)
            {
                commaSepratedList += str + ',' ;
            }

            if(strErrorLst.isEmpty()){
                validClaimCreditDebitNotfnMap.put(creditNtfnReqObj.claim.trim(), creditNtfnReqObj);
            } else{
                commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length()-1);
                mapOfFailure.put(i,strErrorLst);
                totalFailedRecords++;
                if(!String.isBlank(creditNtfnReqObj.claim.trim())){
                    erroredClaimData.put(creditNtfnReqObj.claim.trim(), commaSepratedList);
                }
            }
            i++;
        }
        totalrecords = i-1;
    }
}