/*
 * @Description: Apex Controller for PRPL_AnnualDealerExperience. Allow to take Annual Dealer Experience data
 * Created:  01/25/2021 – Nitish Gyansys
 * */

public class PRPC_AnnualDealerExperienceApex {
    @AuraEnabled
    public static String saveRecord(Survey_Data__c dealerSurvey) {
        try {
            Account dealer = [SELECT Id, SAP_Id__c FROM Account WHERE Id = :dealerSurvey.Customer_Dealer_Id__c];
            dealerSurvey.Ship_To__c = dealer.SAP_Id__c;
            UPSERT dealerSurvey;
        }
        catch(Exception ex) {
            return ex.getMessage();
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static Survey_Data__c findScore(Decimal year, Decimal month, String distributorId ) {
        System.debug('Check id: ' + distributorId);
        System.debug('Check year: ' + year);
        System.debug('Check month: ' + month);
        try{
            Survey_Data__c dealerSurvey = [SELECT Id, Q1_Value__c, Survey_Type__c 
                                       FROM Survey_Data__c 
                                       WHERE Customer_Dealer_Id__c =:distributorId AND Year__c = :year AND Month__c =:month AND Survey_Type__c = 'Annual Dealer Experience' LIMIT 1];
        	return dealerSurvey;
        }
        catch(Exception ex) {
            return null;
        }
    }
}