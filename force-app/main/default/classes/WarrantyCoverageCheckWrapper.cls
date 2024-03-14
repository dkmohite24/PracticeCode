/* Name: ATI_WarrantyCoverageCheck
Description : This class is used to check warranty coverage.
Author : Tavant(Mukesh)
History:
VERSION     AUTHOR                 DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(Mukesh)             12/16/2020                  INITIAL DEVELOPMENT                              
*/

public class WarrantyCoverageCheckWrapper {
   @AuraEnabled Public InventoryData invData;
   @AuraEnabled public List<CoverageData> cvrgData;
   @AuraEnabled public List<CampaignData> cmpData;
   @AuraEnabled Public WOD_2__Inventory__c inv = new WOD_2__Inventory__c();
 
    public class InventoryData{
       @AuraEnabled public id invId = null;
       @AuraEnabled public String name = '';
       @AuraEnabled public String model = '';
        public String account;
        public String unitsUsage;
        public String unitOfMeasure;
    }
    public class CoverageData{
       @AuraEnabled public String policyName = '';
       @AuraEnabled public String policyType = '';
       @AuraEnabled public Date warrantyStartDate = null;
       @AuraEnabled public Date warrantyEndDate = null;
       @AuraEnabled public Decimal priority = null;
       @AuraEnabled public String description = '';
       @AuraEnabled public Boolean activeOnCurrantDate = false;
       @AuraEnabled public Integer maxUnitUsage;
    }
    public class CampaignData{
       @AuraEnabled public String cmpName = '';
       @AuraEnabled public Boolean isActive = false;
       @AuraEnabled public Date cmpStartDate = null;
       @AuraEnabled public Date cmpEndDate = null;
    }
}