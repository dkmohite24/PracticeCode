/**
-------------------------------------------------------------------------------------------------
* @author         Madagond Manjunath
* @created        25-Aug-2022
* @modified
* @description :   Trigger from BU rule ->AT: Turn Around Validation Part.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_TurnAroundValidation_Part implements WOD_2.BR_BusinessRuleInterface{ 
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        List<WOD_2__Claim__c> clm = [SELECT WOD_2__Account__c, ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c FROM WOD_2__Claim__c where Id=:wrapper.ruleObjectId];

        //Added to check PRP Participation
        List<Account> accPFRParticipation = new List<Account>();
        if(clm[0].WOD_2__Account__c != null){
            accPFRParticipation = [Select Id,PRP_Participation__c FROM Account Where Id=:clm[0].WOD_2__Account__c];
        }
        // Added for service parts
        List<WOD_2__Claim_Part__c> serviceParts = [SELECT Id FROM WOD_2__Claim_Part__c WHERE WOD_2__Claim__c = : wrapper.ruleObjectId];
        List<String> errorLst = new List<String>();
        
        //Parts check
        if (!accPFRParticipation.isEmpty() && accPFRParticipation[0].PRP_Participation__c== true && serviceParts.size()>0){
            if((clm[0].ATI_First_Part_Ordered_Date_Time__c) == null){
                errorLst.add('DateTimeFirstPartOrdered is Mandatory');
            }
            else if(Datetime.valueOf(clm[0].ATI_First_Part_Ordered_Date_Time__c).date() > System.today()){
                errorLst.add('DateTimeFirstPartOrdered should not be greater than today');
            }
            
            if((clm[0].ATI_Last_Part_Arrival_Date_Time__c) == null){
                errorLst.add('DateTimeLastPartArrived is Mandatory');
            }else if(Datetime.valueOf(clm[0].ATI_Last_Part_Arrival_Date_Time__c).date() > System.today()){
                errorLst.add('DateTimeLastPartArrived should not be greater than today');
            }
        }
        if(errorLst.size()>0){
            return true;
        } else {
            return false;
        }
    }  
    
}