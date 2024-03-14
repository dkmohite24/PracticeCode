@IsTest(seeAllData=true)

public class MessageComponentClassTest {
    @IsTest
    public static void getcategoryTest()
    {
         List<Knowledge__kav> klist=[ Select Title,Summary,PublishStatus,Category__c,LastPublishedDate,PublishDateFormula__c,Article_Validity_Date__c from Knowledge__kav where PublishStatus='Online' AND Is_Announcement__c=true ORDER BY LastPublishedDate DESC ]; 
        List<ContentDocumentLink> cdlist =[Select Id, LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId =:klist[0].id ];
        
        test.startTest();
        MessageComponentClass.getcategory();
        MessageComponentClass.GetAnnouncement();
         MessageComponentClass.GetData(klist[0].Category__c,klist[0].PublishDateFormula__c,klist[0].LastPublishedDate.date(),'a');
        MessageComponentClass.HomePageArticles();
        test.stopTest();
        
    }

}