@isTest
public class NewSalesforceUserFormClassTest {
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
        AWAARE_4WARD__c UpdateAware = new AWAARE_4WARD__c();
        UpdateAware.Username__c='223455651230';
        UpdateAware.Address__c='Address';
        UpdateAware.Company__c='Company';
        UpdateAware.City__c = 'City';
        UpdateAware.Country_Picklist__c='India';
        UpdateAware.Email__c='abc@gmail.com';
        UpdateAware.FirstName__c='First';
        UpdateAware.LastName__c='Last';
        UpdateAware.Locale__c='en_US';
        UpdateAware.Phone__c='0123456789';
        UpdateAware.State_Province__c='State/Province';
        UpdateAware.Zip__c='Zip';
        insert UpdateAware;
        
        AWAARE_4WARD_Basic__c UpdateAware1 = new AWAARE_4WARD_Basic__c();
        UpdateAware1.Username__c='176767878699';
        UpdateAware1.Address__c='Address';
        UpdateAware1.Company__c='Company';
        UpdateAware1.City__c = 'City';
        UpdateAware1.Country_Picklist__c='India';
        UpdateAware1.Email__c='abc@gmail.com';
        UpdateAware1.FirstName__c='First';
        UpdateAware1.LastName__c='Last';
        UpdateAware1.Phone__c='0123456789';
        UpdateAware1.State_Province__c='State/Province';
        UpdateAware1.Zip__c='Zip';
      //s  insert UpdateAware1;
        List<String> pickListValuesList= new List<String>();
        
        NewSalesforceUserFormClass.CreateRecord(UpdateAware.Id, 'Userupdate', UpdateAware);
        NewSalesforceUserFormClass.CreateRecordforAwaareBasic(UpdateAware1,'176767878699');
        NewSalesforceUserFormClass.getDetailsRelatedToRecord('userName123');
        NewSalesforceUserFormClass.getPickListValuesIntoList();
    }
}