@isTest
private class fetchFaqObjectsTest {

    @isTest
    static void testGetCustomObjectData() {

        // Test case: Search by query only
        FAQ__c faq1 = new FAQ__c(Name = 'Test FAQ', Answer__c = 'Test Answer', Question__c = 'Test Question', Language__c = 'English');
        insert faq1;

        List<FAQ__c> faqs2 = fetchFaqObjects.getCustomObjectData('Test', null);
        System.assertEquals(1, faqs2.size(), 'Should return a list with one FAQ when searching by query.');

        // Test case: Search by picklist value only
        List<FAQ__c> faqs3 = fetchFaqObjects.getCustomObjectData(null, 'English');
        System.assertEquals(1, faqs3.size(), 'Should return a list with one FAQ when searching by picklist value.');

        // Test case: Search by both query and picklist value
        List<FAQ__c> faqs4 = fetchFaqObjects.getCustomObjectData('Test', 'English');
        System.assertEquals(1, faqs4.size(), 'Should return a list with one FAQ when searching by both query and picklist value.');
    }

    @isTest
    static void testGetPicklistValues() {
        // Test case: picklist values
        List<Map<String, String>> picklistValues = fetchFaqObjects.getPicklistValues();
        System.assertNotEquals(0, picklistValues.size(), 'Should return picklist values for Language__c field.');

    }
}