/**

* @description       : 

* @author            : ChangeMeIn@UserSettingsUnder.SFDoc

* @group             : 

* @last modified on  : 03-12-2024

* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc

**/

public with sharing class ATI_ExportToExcel {
 
    /**

     * @description   : Method to fetch Claim Line Item records based on the claim header Id

     * @param claimHeaderId  : Id of the claim header record

     * @return List<Claim_Line_Item__c>  : List of Claim Line Item records

     **/

    @AuraEnabled(cacheable=true)

    public static List<Claim_Line_Item__c> getClaimLineItems(Id claimHeaderId) {

        // Check if the user has read access to the Claim_Line_Item__c object

        if (!Schema.sObjectType.Claim_Line_Item__c.isAccessible()) {

            throw new AuraHandledException('User does not have access to Claim_Line_Item__c object.');

        }
 
        // Perform the query including the desired field from the parent object

        system.debug('Query11'+[SELECT Name, ETC__c, Serial_Number__c, Product__r.name, Price__c, Duplicate_Claim__c, VIN__c, Ship_Date__c, In_Service_Date__c,

                Claim__r.ATI_Actual_Submission_Date__c

                FROM Claim_Line_Item__c

                WHERE Claim__c = :claimHeaderId]);

        return [SELECT Name, ETC__c, Serial_Number__c, Product__c,Product__r.Name ,Price__c, Duplicate_Claim__c, VIN__c, Ship_Date__c, In_Service_Date__c,

                Claim__r.ATI_Actual_Submission_Date__c

                FROM Claim_Line_Item__c

                WHERE Claim__c = :claimHeaderId];

    }
 
}