/*
 * Update : CHG44908 - Adding 0176500004 Distributor as an exceptional Distributor Branch
 * Updated by : Susovan Mondal & Chinmaya Dash
 * 
 */

public without sharing class PRPC_ParticipatingPartner {
    
    @AuraEnabled
    public static List<Account> findAll(){
        ID userId = UserInfo.getUserId();
        System.debug('Current User Id - '+userId);
        User u = [select id, contact.Account.Sales_RegionA__c, contact.AccountId from User where id = : UserId];
        System.debug('Current User - '+u.contact.Account.Sales_RegionA__c);
       	String t = [Select Type from Account where id=:u.contact.AccountId].Type;
        List<Account> acc = new List<Account>();
        //CHG44908 - Adding 0176500004 Distributor as an exceptional Distributor Branch
        if(t=='Distributor Branch' || t=='Distributor' ){
              acc = [SELECT Id, Name, Parent.Number_Of_Active_Branches__c, ShippingCity, ShippingState 
                             FROM Account WHERE Sales_RegionA__c = :u.contact.Account.Sales_RegionA__c AND Type = 'Distributor Branch' AND (SAP_ID__c LIKE '%00000' OR SAP_ID__c='0176500004'OR SAP_ID__c='0102000007' OR SAP_ID__c='9856000001' OR SAP_ID__c='9312600001' ) AND (SAP_ID__c!= '0102000000' OR SAP_ID__c!= '9856000000' OR SAP_ID__c!= '9312600000') AND PRP_Participation__c = true Order By Name];
            
        
        }
       else if(t=='Direct Dealer'){
            acc = [SELECT Id, Name, Parent.Number_Of_Active_Branches__c, ShippingCity, ShippingState FROM Account WHERE Sales_RegionA__c = :u.contact.Account.Sales_RegionA__c AND Type = 'Direct Dealer' AND PRP_Participation__c = true Order By Name];
       
        }
             System.debug('distributor - '+acc);
        System.debug('List of accounts :'+acc.size());
        return acc;
    }
}