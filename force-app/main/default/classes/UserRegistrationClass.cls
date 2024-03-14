public without sharing class UserRegistrationClass {
    
    @AuraEnabled
    public static List<UserWrapper> GetData(String username)
    { 
        System.debug('USERNAME'+username);
        String existingUser = '';
        String flag='';
        String customercode='';
        Boolean disabledusercheck;
        Boolean isactive;
        List<AWAARE_4WARD__c> userList= new List<AWAARE_4WARD__c> ();
        try{
            userList=[Select Id,Username__c,FirstName__c,LastName__c,Community_User__c,Email__c,Customer_Code__c,Role_Picklist__c,Company__c,Locale__c from AWAARE_4WARD__c  where Username__c =:username LIMIT 1];
            
            if(userList.size()!= 0){
                customercode=userList[0].Customer_Code__c;
                String userNameOfAwaareRecord = userList[0].Username__c + '@Allison4WARD%';
                string disableduser ='_'+username+'@Allison4WARD.com%';
                List<User> disulist = [SELECT Id,Username,Name,Profile.Name,Email,IsActive,ContactId FROM User WHERE Username LIKE :disableduser  AND ContactId=null LIMIT 1];
                if(disulist.size()!=0){
                    existingUser=disulist[0].Username;
                    disabledusercheck=true;
                }
                List<User> ulist = [SELECT Id,Username,Name,Profile.Name,Email,IsActive,ContactId FROM User WHERE Username LIKE :userNameOfAwaareRecord AND ContactId!=null LIMIT 1];
                if(ulist.size()!= 0){
                    existingUser = ulist[0].Username; 
                    if(ulist[0].IsActive==true){
                        isactive=true;
                    }
                    else if(ulist[0].IsActive==false){
                        isactive=false;
                    }
                    
                }
                
            }
            else{
                String firstnine = username.left(9);
                String sixth = firstnine.left(6).right(1);   
                if(sixth=='9'){
                    customercode = firstnine.left(5) + '9' + firstnine.right(4) ;
                }
                else{
                    customercode = firstnine.left(5) + '0' + firstnine.right(4) ;   
                }
                
            }
            List<Account> acclist=[SELECT id,SAP_ID__c from Account where SAP_ID__c=:customercode LIMIT 1];
            system.debug('ACCLIST'+acclist);
            system.debug('ACCLIST SIZE'+acclist.size());
            
            if(acclist.size()==0){
                flag='NO';
            }
            else{
                system.debug('YES');
                flag='YES';             
            }
        }
        catch(Exception e){
            System.debug('Message is :'+e.getMessage());
        }
        List<UserWrapper> records = new List<UserWrapper>();
        UserWrapper uw = new UserWrapper();
        uw.awareList = userList;
        uw.existingUserName = existingUser; 
        uw.isValidcode = flag;
        uw.ccode= customercode;
        uw.isactive = isactive;
        uw.disabledusercheck= disabledusercheck;
        records.add(uw);
        
        if(userList.size()!=0 && existingUser == '' && userList[0].Community_User__c==null){
            System.debug('Inside Line 28');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {userList[0].Email__c};
                String s='Allison 4WARD Account Registration';
            message.setSubject(s);
            List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address='warranty@allisontransmission.com' ];
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            
            Id siteUrl = [SELECT Id FROM Site Where UrlPathPrefix = 'userconfirmation' Limit 1].Id;
            List<SiteDetail> SdLst = [SELECT secureUrl FROM SiteDetail Where DurableId =: siteUrl];
            String c='';
            String d='';
            
            c=userList[0].Company__c;
            d=c.replaceAll('/|-| |&|,','_');
            //prod
            // message.setPlainTextBody('Hi '+userList[0].FirstName__c+' '+userList[0].LastName__c+',\n\nClick on the link to update the details of your Allison 4WARD account and create a new Salesforce user: \nhttps://prod-dealercommunity.secure.force.com/userconfirmation/?username='+userList[0].Username__c+'&recid='+userList[0].id+'&code='+userList[0].Customer_Code__c+'&role='+userList[0].Role_Picklist__c+'&Fname='+userList[0].FirstName__c+'&Lname='+userList[0].LastName__c+'&Loc='+userList[0].Locale__c+'&Email='+userList[0].Email__c+'&Com='+d+'\n\n\nRegards,\nAllison Transmission Warranty\nwarranty@allisontransmission.com\nOne Allison Way\nIndianapolis, IN 46222-3271\n');
            // uat
            message.setPlainTextBody('Hi '+userList[0].FirstName__c+' '+userList[0].LastName__c+',\n\nClick on the link to update the details of your Allison 4WARD account and create a new Salesforce user: \n' + SdLst[0].secureUrl + '/?username='+userList[0].Username__c+'&recid='+userList[0].id+'&code='+userList[0].Customer_Code__c+'&role='+userList[0].Role_Picklist__c+'&Fname='+userList[0].FirstName__c+'&Lname='+userList[0].LastName__c+'&Loc='+userList[0].Locale__c+'&Email='+userList[0].Email__c+'&Com='+d+'\n\n\nRegards,\nAllison Transmission Warranty\nwarranty@allisontransmission.com\nOne Allison Way\nIndianapolis, IN 46222-3271\n');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        } 
        return records;
    }
    
    
    @TestVisible public class UserWrapper{
        @AuraEnabled public List<AWAARE_4WARD__c> awareList{get;set;}
        @AuraEnabled public String existingUserName{get;set;}
        @AuraEnabled public String isValidcode{get;set;}
        @AuraEnabled public String ccode{get;set;}
        @AuraEnabled public boolean disabledusercheck{get;set;}
        @AuraEnabled public Boolean isactive{get;set;}
        
        
    }
    
    
    @AuraEnabled
    public static id CreateReactivateRecord(String username){
        //  String uname= username+'@allison4ward.com.inactive';
        String uname= username+'@allison4ward%';
        
        List<User> uslist = [select id,ProfileId,name,firstname,lastname,username,email,Profile.Name,Country,CompanyName,State,Street,Phone,City,title,IsActive from User where username LIKE:uname AND IsActive= false LIMIT 1];
        List<AWAARE_Role__mdt> metalist = [Select id,AWAARE_role__c,Profile__c from AWAARE_Role__mdt];
        Map<String,String> metamap = new  Map<String,String>();
        for(AWAARE_Role__mdt m:metalist ){
            metamap.put( m.Profile__c,m.AWAARE_role__c);
        }
        AWAARE_4WARD_Basic__c   ruser = new AWAARE_4WARD_Basic__c();
        ruser.Username__c=uslist[0].username;
        ruser.FirstName__c= uslist[0].firstname;
        ruser.LastName__c= uslist[0].lastname;
        ruser.Email__c=uslist[0].email; 
        ruser.Status__c='Submitted For Approval';
        ruser.Phone__c=uslist[0].Phone; 
        //ruser.City__c=uslist[0].City; 
        //ruser.Address__c=uslist[0].Street; 
        //ruser.Country_Picklist__c=uslist[0].Country; 
        ruser.Company__c=uslist[0].CompanyName; 
        //ruser.State_Province__c=uslist[0].State; 
        ruser.Role_Picklist__c=metamap.get(uslist[0].ProfileId);
        ruser.Access_Request_Type__c='Reactivation Request';
        ruser.Job_Title__c = uslist[0].title;
        insert ruser;
        return ruser.id;
    }
}