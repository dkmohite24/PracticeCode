/**
-------------------------------------------------------------------------------------------------
* @author         Susmitha
* @created        11-April-2022
* @modified
* @description :   Trigger from BU rule ->AT: Turn Around Validation.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_TurnAroundValidation implements WOD_2.BR_BusinessRuleInterface{ 
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        List<WOD_2__Claim__c> clm = [SELECT WOD_2__Account__c, ATI_Vehicle_Arrival_Date_Time__c, ATI_Repair_Order_Closed_Date_Time__c, ATI_Completed_Repair_Cust_Noti_Date__c, ATI_Repair_Order_Open_Time__c, ATI_First_Labor_Applied_Date_Time__c,ATI_First_Part_Ordered_Date_Time__c,
                                     ATI_Last_Labor_Recorded_Time__c,ATI_Last_Part_Arrival_Date_Time__c 
                                     FROM WOD_2__Claim__c where Id=:wrapper.ruleObjectId];
        system.debug('clm---->'+clm);
        
        //Added to check PRP Participation
        List<Account> accPFRParticipation = new List<Account>();
        if(clm[0].WOD_2__Account__c != null){
            accPFRParticipation = [Select Id,PRP_Participation__c FROM Account Where Id=:clm[0].WOD_2__Account__c];
        }
        
        /*
        // Added for service parts
        List<WOD_2__Claim_Part__c> serviceParts = [SELECT Id FROM WOD_2__Claim_Part__c WHERE WOD_2__Claim__c = : wrapper.ruleObjectId];
        
        // Added for labor codes
        List<WOD_2__Claim_Service_Information__c> laborCodesLst = [SELECT Id FROM WOD_2__Claim_Service_Information__c WHERE WOD_2__Claim__c = : wrapper.ruleObjectId];
		*/

        //Account PRP Partcipation
        List<String> errorLst = new List<String>();
        if(!accPFRParticipation.isEmpty() && accPFRParticipation[0].PRP_Participation__c== true &&(clm[0].ATI_Vehicle_Arrival_Date_Time__c== null || clm[0].ATI_Repair_Order_Closed_Date_Time__c== null || clm[0].ATI_Completed_Repair_Cust_Noti_Date__c== null || clm[0].ATI_Repair_Order_Open_Time__c== null)){
          errorLst.add('Turnaround Dates mandatory');
        }
        
        /*
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
        //if(claimInfo.laborCodes.size()>0){
        if(!accPFRParticipation.isEmpty() && accPFRParticipation[0].PRP_Participation__c== true && laborCodesLst.size()>0){
            if((clm[0].ATI_First_Labor_Applied_Date_Time__c) == null){
                errorLst.add('DateTimeLaborFirstApplied is Mandatory');
            }
            
            else if(Datetime.valueOf(clm[0].ATI_First_Labor_Applied_Date_Time__c).date() > System.today()){
                errorLst.add('DateTimeLaborFirstApplied should not be greater than today');
            }
        
        if((clm[0].ATI_Last_Labor_Recorded_Time__c) == null){
            errorLst.add('DateTimeLaborLastRecordedOrApplied is Mandatory');
        }else if(Datetime.valueOf(clm[0].ATI_Last_Labor_Recorded_Time__c).date() > System.today()){
            errorLst.add('DateTimeLaborLastRecordedOrAppliedshould not be greater than today');
        }
        }*/
        
        if(errorLst.size()>0){
            return true;
        } else {
            return false;
        }
    }  
    
}