@isTest
public class TriggerforAwaareHandlerTest {
    static testMethod void testReport1() {
        
         List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
   
        

User adminUser = [Select Id, UserRoleId From User Where id=:Userinfo.getUserId()];


        System.runAs(adminUser){
             List<AWAARE_4WARD__c> awList = new List<AWAARE_4WARD__c>();
	AWAARE_4WARD__c UpdateAware = new AWAARE_4WARD__c();
        UpdateAware.Username__c='046210987459';
        UpdateAware.Customer_Code__c='0462100987';
        UpdateAware.Address__c='Address';
        UpdateAware.Company__c='Company';
        UpdateAware.City__c = 'City';
        UpdateAware.Country_Picklist__c='Afghanistan';
        UpdateAware.Email__c='abc@gmail.com';
        UpdateAware.FirstName__c='First';
        UpdateAware.LastName__c='Last';
        UpdateAware.Locale__c='en_US';
        UpdateAware.Phone__c='0123456789';
        UpdateAware.State_Province__c='State/Province';
        UpdateAware.Zip__c='Zip';
        UpdateAware.Role_Picklist__c='ATI_Distributor_and_Dealer';
        insert UpdateAware;
        awList.add(UpdateAware);
        
        
        Account accInstance = new Account();
        accInstance.Name = 'AccName';
        accInstance.Location_Name__c = 'LocationName';
        accInstance.Location_Type__c = 'D';
        accInstance.Sales_Region__c = 'North America';
        accInstance.Sales_RegionA__c = 'North America';
        accInstance.SAP_ID__c = '0462100987';
        accInstance.ShippingCity = 'City';
        accInstance.ShippingCountry = 'Country';
        accInstance.ShippingPostalCode = 'PostalCode';
        accInstance.ShippingState = 'State';
        accInstance.ShippingStreet = 'Street';
        insert accInstance;
        
        TriggerforAwaareHandler.CreatePartnerUser(awList);
        }
   }
   /*static testMethod void testReport2(){
       list<AWAARE_4WARD_Basic__c> basicList = new list<AWAARE_4WARD_Basic__c>();
        AWAARE_4WARD_Basic__c UpdateAware1 = new AWAARE_4WARD_Basic__c();
        UpdateAware1.Address__c='Address';
        UpdateAware1.Company__c='Company';
        UpdateAware1.City__c = 'City';
        UpdateAware1.Country_Picklist__c='Afghanistan';
        UpdateAware1.Email__c='abc@gmail.com';
        UpdateAware1.FirstName__c='First';
        UpdateAware1.LastName__c='Last';
        UpdateAware1.Locale__c='en_US';
        UpdateAware1.Phone__c='0123456789';
        UpdateAware1.State_Province__c='State/Province';
        UpdateAware1.Zip__c='Zip';
        UpdateAware1.Status__c = 'Rejected';
        basicList.add(UpdateAware1);
       
       insert basicList;
       
       
        
        TriggerHandlerForMailAwaare.SendEmailForRejection(basicList);*/
    
}