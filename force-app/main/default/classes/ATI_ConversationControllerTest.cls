@isTest
public class ATI_ConversationControllerTest {
    @isTest
	public static void getConversationsTest(){
        List<Account> accLst = TestDataFactory.createAccount(2);
            for(Integer i=0;i<accLst.size();i++){
                accLst[i].Sales_RegionA__c = 'EMEA';
                accLst[i].SAP_ID__c = '1223123'+i;
                accLst[i].Location_Type__c = 'test'+i;    
            }
            accLst[0].WOD_2__Warranty_Account_Type__c='Dealer';
            accLst[0].ATI_RPS_Status__c=true;
            accLst[1].WOD_2__Warranty_Account_Type__c='Customer';
            insert accLst;
        	List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
            insert warrantyProLst;
        	List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
            for(WOD_2__Inventory__c inventory : inventoryLst){
                inventory.WOD_2__Type__c = 'Stock';
                inventory.WOD_2__Account__c = accLst[0].id;
                inventory.WOD_2__Item__c = warrantyProLst[2].id;
                inventory.put('ATI_Internal_Conversations__c','[{"u":"00505000000SjxyAAC","t":"C","i":"1b04","d":"2/9/2021, 2:24 AM","c":"cdd"}]');
                inventory.put('ATI_External_Conversations__c','[{"u":"00505000000SjxyAAC","t":"C","i":"f6f7","d":"2/9/2021, 2:24 AM","c":"cdd"}]');
            }
            insert inventoryLst;
        	String inventoryId = inventoryLst[0].Id;
        	WOD_2.ResponseWrapper response = ATI_ConversationController.getConversations(inventoryId);
        	WOD_2.ResponseWrapper response1 = ATI_ConversationController.saveConversation('Comment1',inventoryId,TRUE);
        	WOD_2.ResponseWrapper response2 = ATI_ConversationController.saveConversation('Comment1',inventoryId,FALSE);
        	WOD_2.ResponseWrapper response3 = ATI_ConversationController.isUserInfo();
	}
}