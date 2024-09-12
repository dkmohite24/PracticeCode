public with sharing class demoCreateCartController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> retrieveProuduct(string searchKey){
       string strProductSearchKey = '%' + searchKey + '%';
       system.debug('strProductSearchKey'+strProductSearchKey);
       System.debug('query'+[SELECT id,Name, ProductCode,Brand__c,Product_Description__c, Family  from Product2 where ProductCode like :strProductSearchKey ] );
        return [SELECT id,Name, ProductCode,Brand__c,Product_Description__c, Family  from Product2  limit 100];
    
    }
}