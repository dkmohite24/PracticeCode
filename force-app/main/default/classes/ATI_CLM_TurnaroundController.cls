public class ATI_CLM_TurnaroundController {
    public static List<String> turnAroundErrLst =  new List<String>();
    @AuraEnabled
    public static WOD_2.ResponseWrapper validateTurnAroundDate(String claimObjJSON){
        WOD_2__Claim__c claimObj = (WOD_2__Claim__c)JSON.deserialize(claimObjJSON, WOD_2__Claim__c.class);
        List<Account> accPFRParticipation = new List<Account>();
        if(claimObj.WOD_2__Account__c != null){
        accPFRParticipation = [Select Id,PRP_Participation__c FROM Account Where Id=:claimObj.WOD_2__Account__c];
        }
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('',false,'');
        
        //ALSN-69 MM Moving all turnaround time validation to BR.
        /*
        if(!accPFRParticipation.isEmpty() && accPFRParticipation[0].PRP_Participation__c== true && 
           //claimObj.ATI_First_Labor_Applied_Date_Time__c == null && claimObj.ATI_First_Part_Ordered_Date_Time__c == null && claimObj.ATI_Last_Part_Arrival_Date_Time__c == null
           claimObj.ATI_Repair_Order_Open_Time__c == null && claimObj.ATI_Repair_Order_Closed_Date_Time__c == null && claimObj.ATI_Vehicle_Arrival_Date_Time__c == null && claimObj.ATI_Completed_Repair_Cust_Noti_Date__c == null
           //&& claimObj.ATI_Distributor_schedules_cust_Serv_Date__c == null && claimObj.ATI_Customer_Requests_Service_Date__c == null
           ){
               return new WOD_2.ResponseWrapper('',true,System.label.ATI_Claim_FillTurnAroundField);
           }
        if(!accPFRParticipation.isEmpty() && accPFRParticipation[0].PRP_Participation__c== true){
            //ALSN-69 null checks MM
            if(claimObj.ATI_First_Labor_Applied_Date_Time__c != null){
            validateDate(claimObj.ATI_First_Labor_Applied_Date_Time__c, System.Label.ATI_Exception_FirstLaborAppliedDate_Time,System.Label.ATI_FirstLaborApplied_greaterToday);
            }
            if(claimObj.ATI_First_Part_Ordered_Date_Time__c != null){
            validateDate(claimObj.ATI_First_Part_Ordered_Date_Time__c, System.Label.ATI_FirstOrderDate_Time_null,System.Label.ATI_FirstOrder_greaterToday);
            }
            if(claimObj.ATI_Last_Part_Arrival_Date_Time__c != null){
            validateDate(claimObj.ATI_Last_Part_Arrival_Date_Time__c, System.Label.ATI_LastPartArrivalDate_Time_nullcheck,System.Label.ATI_LastPartArrival_greaterToday);
            }
            validateDate(claimObj.ATI_Repair_Order_Closed_Date_Time__c,System.Label.ATI_RepairOrderClosedDate_Time_nullCheck, System.Label.ATI_RepairClosedOrder_greaterToday);
            validateDate(claimObj.ATI_Vehicle_Arrival_Date_Time__c,System.Label.ATI_VehicleArrivalDate_Time_nullcheck,System.Label.ATI_VehicleArrivalDate_greaterToday);
            validateDate(claimObj.ATI_Completed_Repair_Cust_Noti_Date__c,System.Label.ATI_CompletedRepairCustomerNoticeDate_Time_nullcheck,System.Label.ATI_CustomerNotfcDate_greaterToday);
            //validateDate(claimObj.ATI_Distributor_schedules_cust_Serv_Date__c,System.Label.ATI_DistributorScheduleDate_Time_nullcheck,System.Label.ATI_DistributorProvideDate_greaterToday);
            //validateDate(claimObj.ATI_Customer_Requests_Service_Date__c,System.Label.ATI_CustomerRequestServiceDate_Time_nullcheck,System.Label.ATI_CustomerRequestDate_greaterToday);
            // validateDate(claimObj.ATI_Customer_AuthorizeWork_Date_Time__c,System.Label.ATI_CustomerAuthorizeWork_nullcheck,System.Label.ATI_CustomerAuthorizeDate_greaterToday);
            //alsn-69 MM
            if(claimObj.ATI_Repair_Order_Open_Time__c== null){
                turnAroundErrLst.add(System.label.ATI_RepairOrderOpenTime_nullcheck);
            }*/
            /*
if(claimObj.ATI_Last_Labor_Recorded_Time__c== null){
turnAroundErrLst.add(System.label.ATI_LastLaborRecordedTime_nullcheck);
} */
        
        //}
        if(!turnAroundErrLst.isEmpty()){
            return new WOD_2.ResponseWrapper('',true,String.join(turnAroundErrLst,',  '));
        }
        
        else{
            
            // WOD_2__Claim__c claimList = [Select ATI_First_Labor_Applied_Date_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Customer_Requests_Service_Date__c,ATI_Repair_Order_Open_Time__c,ATI_Last_Labor_Recorded_Time__c from WOD_2__Claim__c where id=:claimObj.Id limit 1];
            List<WOD_2__Claim__c> claimList = ClaimList(claimObj.Id);   
            if(!claimList.isEmpty()){
                claimList[0].ATI_First_Labor_Applied_Date_Time__c=claimObj.ATI_First_Labor_Applied_Date_Time__c;
                claimList[0].ATI_First_Part_Ordered_Date_Time__c=claimObj.ATI_First_Part_Ordered_Date_Time__c;
                claimList[0].ATI_Last_Part_Arrival_Date_Time__c=claimObj.ATI_Last_Part_Arrival_Date_Time__c;
                claimList[0].ATI_Repair_Order_Closed_Date_Time__c=claimObj.ATI_Repair_Order_Closed_Date_Time__c;
                claimList[0].ATI_Vehicle_Arrival_Date_Time__c=claimObj.ATI_Vehicle_Arrival_Date_Time__c;
                claimList[0].ATI_Completed_Repair_Cust_Noti_Date__c=claimObj.ATI_Completed_Repair_Cust_Noti_Date__c;
                claimList[0].ATI_Distributor_schedules_cust_Serv_Date__c=claimObj.ATI_Distributor_schedules_cust_Serv_Date__c;
                claimList[0].ATI_Customer_Requests_Service_Date__c=claimObj.ATI_Customer_Requests_Service_Date__c;
                // claimList.ATI_Customer_AuthorizeWork_Date_Time__c=claimObj.ATI_Customer_AuthorizeWork_Date_Time__c;
                claimList[0].ATI_Repair_Order_Open_Time__c=claimObj.ATI_Repair_Order_Open_Time__c;
                claimList[0].ATI_Last_Labor_Recorded_Time__c=claimObj.ATI_Last_Labor_Recorded_Time__c;
                update claimList;
            }
            return new WOD_2.ResponseWrapper(JSON.serialize(claimList),true,'');
        }
        
    }
    //ALSN-69
    /*
    public static void validateDate(DateTime dateTimeVal, String nullMsg, String afterToday){
        System.debug('inVlaidate Date--->'+dateTimeVal+'---> Null msg--->'+nullMsg+'---> afterToday--->'+afterToday);
        if(dateTimeVal == null){
            turnAroundErrLst.add(nullMsg);
        } else if (dateTimeVal.date() > System.today() && afterToday!=''){
            turnAroundErrLst.add(afterToday);
        } 
    }*/
    
    public static List<WOD_2__Claim__c> ClaimList(Id claimId){
        List<String> fieldNames = new List<String>{'ATI_First_Labor_Applied_Date_Time__c','ATI_First_Part_Ordered_Date_Time__c','ATI_Last_Part_Arrival_Date_Time__c',
            'ATI_Repair_Order_Closed_Date_Time__c','ATI_Vehicle_Arrival_Date_Time__c','ATI_Completed_Repair_Cust_Noti_Date__c','ATI_Distributor_schedules_cust_Serv_Date__c',
            'ATI_Customer_Requests_Service_Date__c','ATI_Repair_Order_Open_Time__c','ATI_Last_Labor_Recorded_Time__c','WOD_2__Date_Of_Failure__c','WOD_2__Date_Of_Repair__c'};
                String query = 'select Id, ' + String.join(fieldNames, ',') + ' from WOD_2__Claim__c where Id = :claimId';
        List<WOD_2__Claim__c> claimturnaroundList = Database.query(query);
        return claimturnaroundList;
    }
    
    //ALSN-69
    @AuraEnabled
    public static WOD_2.ResponseWrapper getPrpAccountStatus(Id claimId){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
        WOD_2__Claim__c clm = [Select id, WOD_2__Account__r.PRP_Participation__c from WOD_2__Claim__c where Id =: claimId];
        if(clm.WOD_2__Account__r.PRP_Participation__c != null){
            responseWrapperObj.data = string.valueof(clm.WOD_2__Account__r.PRP_Participation__c);
        }
        return responseWrapperObj;
    }
    @AuraEnabled
    public static WOD_2.ResponseWrapper getClaimTurnaround(Id claimId){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',true,'');
        List<WOD_2__Claim__c> claimTurnaroundList = ClaimList(claimId);
        Map<String,WOD_2__Claim__c> allowedStatusesToClaiMap = new Map<String,WOD_2__Claim__c>();
        WOD_2__Configuration_Setting__mdt confSettingMdtObj = WOD_2__Configuration_Setting__mdt.getInstance('ATI_Allowed_Claim_Statuses_To_Edit_Claim');
        if(!claimTurnaroundList.isEmpty() && confSettingMdtObj.WOD_2__Configuration_Value__c != NULL){
            allowedStatusesToClaiMap.put(confSettingMdtObj.WOD_2__Configuration_Value__c,claimTurnaroundList[0]);
            responseWrapperObj.data = JSON.serialize(allowedStatusesToClaiMap);
        }
        return responseWrapperObj;
    }
}