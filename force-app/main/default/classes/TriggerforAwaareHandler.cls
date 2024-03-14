public class TriggerforAwaareHandler {
    
  public static void CreatePartnerUser(List<AWAARE_4WARD__c> awaare){ 
      
      for(AWAARE_4WARD__c awr:awaare){
          String salesforceusername = awr.Username__c +'@Allison4WARD.com';
          List<User> userlist= [Select id,Username from User where Username=:salesforceusername LIMIT 1];
          if(userlist.size()==0 && awr.Community_User__c==null) {
    
      List<AWAARE_4WARD__c> listOfAwareeRecords = new List<AWAARE_4WARD__c> ();
      listOfAwareeRecords=[Select Id,Username__c,FirstName__c,LastName__c,Email__c,Role_Picklist__c,Address__c,City__c,Company__c,Country_Picklist__c,Customer_Code__c,Locale__c,Phone__c,State_Province__c,Zip__c,Job_Title__c from AWAARE_4WARD__c where Username__c=:awr.Username__c LIMIT 1];
        String ccode =(listOfAwareeRecords[0].Customer_Code__c);
     
        List<Account> acclist= new List<Account>();
        acclist=[SELECT id,SAP_ID__c from Account where SAP_ID__c=:ccode LIMIT 1];
              if(acclist.size()!=0)
              {
              for(Account acc: acclist)
        		{
        		
            	
       			 	//Create Associated Contact
                	Contact partnerContact= new Contact();
                    Integer IntrandomNumber1 = Integer.valueof((Math.random() * 99));

        			partnerContact.FirstName = listOfAwareeRecords[0].FirstName__c;
        			partnerContact.LastName = listOfAwareeRecords[0].LastName__c;
        			partnerContact.AccountId = acc.id;
        			//partnerContact.Email=listOfAwareeRecords[0].Email__c;
        			insert(partnerContact);
        
        list<AWAARE_Role__mdt> metadata = new list<AWAARE_Role__mdt>();
       metadata = [select id,AWAARE_role__c,Profile__c from AWAARE_Role__mdt where AWAARE_role__c =: listOfAwareeRecords[0].Role_Picklist__c LIMIT 1  ];
      		String md=metadata[0].Profile__c;
     				/*Profile profile = [SELECT id FROM Profile WHERE Name='PRP Partner'];*/
    				//Create Portal User    
    				User portalUser = new User();
        			Integer IntrandomNumber = Integer.valueof((Math.random() * 99));

    				portalUser.Username = listOfAwareeRecords[0].Username__c + '@Allison4WARD.com';
    				portalUser.ContactId = partnerContact.Id;
    				portalUser.IsActive = true;
    				portalUser.ProfileId =md ;
    				portalUser.FirstName =  listOfAwareeRecords[0].FirstName__c;
    				portalUser.LastName = listOfAwareeRecords[0].LastName__c;
                    portalUser.Phone=listOfAwareeRecords[0].Phone__c;
                    portalUser.title = listOfAwareeRecords[0].Job_Title__c;
                    portalUser.City=listOfAwareeRecords[0].City__c;
                    portalUser.Country= listOfAwareeRecords[0].Country_Picklist__c;
                    portalUser.Street= listOfAwareeRecords[0].Address__c;
                    portalUser.CompanyName=listOfAwareeRecords[0].Company__c;
                    portalUser.State= listOfAwareeRecords[0].State_Province__c;
    				portalUser.Alias =   portalUser.FirstName.left(3) +IntrandomNumber+ portalUser.LastName.left(3);
    				portalUser.Email = listOfAwareeRecords[0].Email__c;
    				portalUser.EmailEncodingKey = 'UTF-8';
    				portalUser.CommunityNickname =  portalUser.FirstName.left(3)+ IntrandomNumber+ portalUser.LastName.left(3);
    			//	portalUser.TimeZoneSidKey = '(GMT-07:00) Pacific Daylight Time (America/Los_Angeles)' ;
    				portalUser.TimeZoneSidKey = 'America/New_York';
    				portalUser.LocaleSidKey = 'en_US';
    				portalUser.LanguageLocaleKey =  'en_US' ;
    				insert(portalUser);
                    System.resetpassword( portalUser.id ,True);
            
        }
          }
              
        
      }
      }
     
        
} 
}