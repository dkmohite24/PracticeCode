/**
 * @description       : This Service Class is used for the Data related operations need to be done in other classes.
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : Abhishek Mohapatra
**/
public with sharing class ATI_TAC_API_DataServices {
    public ATI_TAC_API_DataServices() {

    }

    /**
    * @description This method will return list of cases on the basis of dealer code for the last 90 days
    * @author Abhishek Mohapatra | 07-06-2023 
    * @param dealerCode [This is the dealer code which is available on Account object.]
    * @return List<Case> [These are the list of cases that are available for the account and are created in the last 90 days.]
    **/
    public static List<Case> getCaseListOnDealerCode (String dealerCode){
        List<Case> cases = [SELECT Id,
        OwnerId, 
        ATI_TAC_Case_Number__c,
        CaseNumber,
        ATI_TAC_Serial_Number__c,
        ATI_TAC_Inventory_Serial_Number__c,
        ATI_TAC_User_Primary_Queue__c,
        Status,
        ATI_TAC_Sub_Status__c,
        CreatedDate,
        ATI_TAC_Resolution_Description__c,
        ATI_TAC_Latest_Group_Owner_Name__c,
        Description FROM Case WHERE  Account.AccountNumber = :dealerCode AND CreatedDate = LAST_90_DAYS ORDER BY CreatedDate DESC];

        return cases;
    }

    /**
    * @description This method will take the filled in data of ATI_Vehicle_Information__c and it will insert the record and then it will return the record id.
    * @author Abhishek Mohapatra | 07-06-2023 
    * @param vi [The filled in Vehicle Information data should be passed here.]
    * @return String [the record id of ATI_Vehicle_Information__c record will return here.]
    **/
    public static String insertVehicleInformation (ATI_Vehicle_Information__c vi){
        Insert vi;

        return vi.Id;
    }
    
    /**
    * @description This method will populate the Vehicle Information's Warranty Protected fields whenever it is blank. If there's an existing value, it won't get updated.
    * @author Suvam Prakash Dhal | 02-15-2024
    * @param vi [The filled in NHTSA should be passed here.]
    * @param viexisting [The filled in Existing Salesforce Vehicle Information data should be passed here.]
    * @return String [the record id of ATI_Vehicle_Information__c record will return here.]
    **/
    
    public static string updateVehicleInformation (ATI_Vehicle_Information__c vi, ATI_Vehicle_Information__c viexisting){
    
        vi.ATI_Engine_Model__c = String.isBlank(viexisting.ATI_Engine_Model__c) ? vi.ATI_Engine_Model__c : viexisting.ATI_Engine_Model__c;
        vi.ATI_Vehicle_Model__c = String.isBlank(viexisting.ATI_Vehicle_Model__c) ? vi.ATI_Vehicle_Model__c : viexisting.ATI_Vehicle_Model__c;
        vi.ATI_Engine_Make__c = String.isBlank(viexisting.ATI_Engine_Make__c) ? vi.ATI_Engine_Make__c : viexisting.ATI_Engine_Make__c;
        vi.ATI_Vehicle_Make__c = String.isBlank(viexisting.ATI_Vehicle_Make__c) ? vi.ATI_Vehicle_Make__c : viexisting.ATI_Vehicle_Make__c;
        
        vi.id = viexisting.id;       
        update vi;
        return vi.id;
    }


     
   /** @description This method will return the salesfore Account Number assicoated with Case or Account id from the account object
    * @author Sudheer Kodali| 07-25-2023 
    * @param recordId (Case Record Id or Account Record ID) This is the case Id / Account Id  and it will look on the case with associated account number from the case object. OR Account Number from Account object
    * @return List<Case> 
    **/
    public static string getAcountNumber (String recordId){

        string locationId;
        List<case> CaseAccountNumber = [SELECT Account.accountNumber 
                                    FROM Case 
                                    WHERE  (Id = :recordId)];

        If(!CaseAccountNumber.isEmpty()){
            for (Case caseobj : CaseAccountNumber) {
   
                locationId = caseobj.Account.accountNumber;
               
               }
        }
        List<Account> accountNumber = [SELECT accountNumber 
                                    FROM Account 
                                    WHERE  (Id = :recordId)];

        If(!accountNumber.isEmpty()){
                    for (Account accountobj : accountNumber) {
        
                        locationId = accountobj.accountNumber;
                    
                    }
                }

        return locationId;
    }

   
}