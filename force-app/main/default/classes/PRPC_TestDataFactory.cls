@isTest
public class PRPC_TestDataFactory {
    private static Map<String, String> locationTypeMap = new Map<String, String>{'D' => 'Distributor', 
        'DB' => 'Distributor Branch',
        'DDLR' => 'Direct Dealer'};
            private static Map<String, String> regionMap = new Map<String, String>{'North America' => '1111', 
                'Latin America' => '2222',
                'Asia Pacific' => '3333',
                'EMEA' => '4444'};
                    private static Map<String, List<String>> regionKPITypeMap = new Map<String, List<String>>{'North America' => new List<String>{'TPS','Training', 'Turnaround Time I', 'Turnaround Time O', 'Turnaround Time M','Extended Transmission Coverage'}};
                        private static Map<String, List<String>> regionKPITypeMap2 = new Map<String, List<String>>{'North America' => new List<String>{'TPS','Training','Turnaround Time O','Turnaround Time I','Turnaround Time M','Total Parts Sold ReTran','CSI Service','CSI Parts','Extended Transmission Coverage'},
                            'Latin America'=> new List<String>{'Parts Ordering','TPS','Training','CSI','Turnaround Time O','Turnaround Time I','Facility Audit'}};
                                private static Map<String, String> regionPRPTypeMap = new Map<String, String>{'North America' => ',TPS,TPS ReTran,Turn Around Time I,Training,CSI Parts, CSI Service,Annual Dealer Experience,Annual Dealer Experience, TPS New,Extended Transmission Coverage',
                                    'EMEA' => ',CSI,Facility Audit,Parts Ordering,TPS,Turn Around Time I,Turn Around Time O,Training'};
                                        
                                        
                                        public static String ddlrSapId = '9310800000';
    
   public static List<Disable_Rules__c> createDisableRules() {
        List<Disable_Rules__c> newDisableRules = new List<Disable_Rules__c>();
        
        // For Account Object
        Disable_Rules__c disableAccountTriggers = new Disable_Rules__c();
        disableAccountTriggers.Name= 'PRPC_BranchCount';
        disableAccountTriggers.Disable__c = false;
         newDisableRules.add(disableAccountTriggers);
        
       //TAT TURNT TRIGGER
       Disable_Rules__c disableTatTurntTriggers = new Disable_Rules__c();
        disableTatTurntTriggers.Name= 'TatTurntTrigger';
        disableTatTurntTriggers.Disable__c = false;
         newDisableRules.add(disableTatTurntTriggers);
       
       //END CUSTOMER TRIGGER
       Disable_Rules__c disableEndCustTriggers = new Disable_Rules__c();
        disableEndCustTriggers.Name= 'EndCustTrigger';
        disableEndCustTriggers.Disable__c = false;
         newDisableRules.add(disableEndCustTriggers);
       
       //Trigger ON AWAARE
        Disable_Rules__c disableAWAARETriggers = new Disable_Rules__c();
        disableAWAARETriggers.Name= 'TriggerforAwaare';
        disableAWAARETriggers.Disable__c = false;
         newDisableRules.add(disableAWAARETriggers);
        
       return newDisableRules;
        
    }
    public static List<Account> createAccount(String locationType, String region,Integer count, Boolean createContact, Boolean createUser){
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'PRP_Admin' Limit 1];
        
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        User adminUser = [Select Id, UserRoleId,isActive From User Where Profile.Name='System Administrator' AND UserRoleId=:userrole.Id AND isActive= True  Limit 1];
        
        List<Account> DistributorToBeInserted = new List<Account>();
        System.runAs(adminUser){
            
            List<Account> branchInserted = new List<Account>();
            List<Contact> contactToBeInserted = new List<Contact>();
            List<User> userToBeInserted = new List<User>();
            for(Integer index = 0; index < count; index++) {
                Account accountRec = new Account();
                accountRec.Name = 'Test '+locationTypeMap.get(locationType) + index;
                accountRec.Type = locationTypeMap.containsKey(locationType)?locationTypeMap.get(locationType):'';
                accountRec.Location_Type__c = locationType;
                if(locationType == 'D' && regionMap.containsKey(region)) accountRec.SAP_ID__c = regionMap.get(region)+index;
                //9310800000
                if(locationType == 'DDLR' && regionMap.containsKey(region)) accountRec.SAP_ID__C = ddlrSapId;
                accountRec.Sales_RegionA__c = region;
                accountRec.ShippingCity = 'City';
                accountRec.ShippingCountry = 'Country';
                accountRec.ShippingState = 'State';
                accountRec.ShippingPostalCode = '765432';
                accountRec.ShippingStreet = 'Street'+index;
                accountRec.PRP_Participation__c = true;
                DistributorToBeInserted.add(accountRec);
            }
            if(DistributorToBeInserted.size() > 0) INSERT DistributorToBeInserted;
            Id test= [select id, ownerId from account where Id in:DistributorToBeInserted limit 1].ownerId;
            for(Account acct : DistributorToBeInserted) {
                if(createContact) contactToBeInserted.add(createContact(acct, false));
                if(locationType == 'D') branchInserted.add(createBranch(acct, false, 1));
                
            }
            
            if(contactToBeInserted.size() > 0) {
                INSERT contactToBeInserted;
                if(createUser) {
                    Id profileId = [SELECT Id FROM Profile WHERE Name='PRP Partner'].Id; 
                    for(Contact conRec : contactToBeInserted) userToBeInserted.add(createPartnerUser(conRec.Id, profileId,null, false)); 
                    System.debug('Check 46: '+UserInfo.getUserRoleId());
                    if(userToBeInserted.size() > 0) INSERT userToBeInserted;
                }
            }
            if(branchInserted.size() > 0) INSERT branchInserted;
        }
        return DistributorToBeInserted;
    }
    
    public static Contact createContact(Account acct, Boolean doInsert) {
        Contact conRec = new Contact();
        conRec.FirstName = 'Test Contact';
        conRec.LastName = acct.SAP_ID__c;
        conRec.AccountId = acct.Id;
        conRec.IsPrimary__c = true;
        if(doInsert) INSERT conRec;
        return conRec;
    }
    
    
    public static Account createBranch(Account acct, Boolean doInsert, Integer sequence) {
        Account accountRec = new Account();
        accountRec.Name = 'Test Branch ' + acct.SAP_ID__c + sequence;
        accountRec.Type = 'Distributor Branch';
        accountRec.Location_Type__c = 'DB';
        accountRec.SAP_ID__c = acct.SAP_ID__c +String.valueOf(sequence).leftPad(5,'0');
        accountRec.Sales_RegionA__c = acct.Sales_RegionA__c;
        accountRec.ShippingCity = 'City';
        accountRec.ShippingCountry = 'Country';
        accountRec.ShippingState = 'State';
        accountRec.ShippingPostalCode = '765432';
        accountRec.ShippingStreet = 'Street';
        accountRec.PRP_Participation__c = true;
        accountRec.ParentId = acct.Id;
        if(doInsert) INSERT accountRec;
        return accountRec;
    }
    
    public static User createPartnerUser(Id conId, Id profileId, Id userRoleId, Boolean doInsert) {
        User userRec = new User(Alias = 'testu', Email='testUser9@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = profileId, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+profileId+conId+userRoleId+'@testorg.com');
        if(conId != null)userRec.ContactId = conId;
        if(userRoleId != null)userRec.UserRoleId = userRoleId;
        if(doInsert) INSERT userRec;
        return userRec;
    }
    
    
    
    /*public static List<Account> createAccount(){
List<Account> distributor = new List<Account>();
List<String> SalesRegion = new List<String>();
SalesRegion.add('North America');
SalesRegion.add('Latin America');
SalesRegion.add('Asia Pacific');
SalesRegion.add('EMEA');

for(Integer i = 0; i<4; i++){
Account a = new Account();
a.Name = 'D'+i;
a.Type = 'Distributor';
a.Location_Type__c = 'D';
a.SAP_ID__c = '1111'+i;
a.Sales_RegionA__c = SalesRegion[i];
a.ShippingCity = 'City'+i;
a.ShippingCountry = 'Country'+i;
a.ShippingState = 'State'+i;
a.ShippingPostalCode = '765432';
a.ShippingStreet = 'Street'+i;
a.PRP_Participation__c = true;
distributor.add(a);
}
INSERT distributor;

distributor.clear();
distributor = [SELECT ID,Name, ParentId, Type, Location_Type__c, SAP_ID__c, Sales_RegionA__c, ShippingCity, ShippingCountry,ShippingState,ShippingPostalCode,ShippingStreet, PRP_Participation__c FROM Account WHERE Type = 'Distributor'];
List<Account> branch = new List<Account>();
for(Account acc : distributor){
Account a = new Account();
a.ParentId = acc.Id;
a.Name= acc.Name;
a.Type = 'Distributor Branch';
a.Location_Type__c = 'DB';
a.SAP_ID__c = acc.SAP_ID__c + '00001';
a.Sales_RegionA__c = acc.Sales_RegionA__c;
a.ShippingCity = acc.ShippingCity;
a.ShippingCountry = acc.ShippingCountry;
a.ShippingState = acc.ShippingState;
a.ShippingPostalCode = acc.ShippingPostalCode;
a.ShippingStreet = acc.ShippingStreet;
a.PRP_Participation__c = true;
branch.add(a);
}
INSERT branch;
List<Account> accounts = [SELECT ID,Name, ParentId, Type, Location_Type__c, SAP_ID__c, Sales_RegionA__c, ShippingCity, ShippingCountry,ShippingState,ShippingPostalCode,ShippingStreet, PRP_Participation__c FROM Account];
for(Account acc : accounts){
acc.Name= acc.Name + 'test';
}
Update accounts;
return accounts;
}

public static List<Contact> createContact(){
List<Account> accounts = new List<Account>();
accounts = PRPC_TestDataFactory.createAccount();
List<Contact> contacts = new List<Contact>();
for(Account acc : accounts){
if(acc.ParentId == null){
Contact con = new Contact();
con.AccountId = acc.Id;
con.LastName = acc.Name;
con.IsPrimary__c = true;
contacts.add(con);
}
}
INSERT contacts;
return contacts;
}*/
    
    public static User createUser(String profileName) {
        User u = new User();
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName]; 
        u = new User(Alias = 'standt', Email='testUser1@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName=profileName.replace(' ','')+'testUser1@testorg.com');
        
        INSERT u;
        return u;
    }
    
    public static PRPCO_Facility_Audit__c insertAudit(Id acc,id accloc,string sapid){
        PRPCO_Facility_Audit__c aud = new PRPCO_Facility_Audit__c();
        aud.Distributor__c = acc;
        aud.Location__c = accloc;
        aud.Distributor_SAP_Number__c = sapid;
        aud.Score__c = 22;
        aud.Audit_Date__c= system.today();
        aud.Facility_Audit_Status__c='Pass';
        insert aud;
        return aud;
    }
    public static Reporting_Type__c insertReport(string Name,string Rpobject,string column,string region,string Ptype){
        Reporting_Type__c rp = new Reporting_Type__c();
        rp.Name = Name;
        rp.Partner_Type__c = Ptype;
        rp.Report_Columns__c = column;
        rp.Report_Object__c = Rpobject;
        rp.Report_Region__c = region;
        insert rp;
        return rp;
    }
    public static KPI__C insertKpiRec(Id Acc,Double sapid,string level,string region){
        KPI__C kp = new KPI__C();
        kp.Customer__c = Acc;
        kp.CSI__c = 8;
        kp.CSI_Parts__c = 7.5;
        kp.CSI_Service__c = 5;
        kp.Customer_SAP_Id__c = sapid;
        kp.isPartOfPRP__c = true;
        kp.PRP_Level__c = level;
        kp.Region__c= region;
        kp.Parts_Ordering__c=7;
        kp.Turnaround_Time_I__c=5.6;
        kp.Turnaround_Time_M__c=6;
        kp.Turnaround_Time_O__c =9;
        Kp.Year__c = 2020;
        kp.Month__c = 8;
        kp.Period__c='YTD';
        kp.Released__c = 'X';
        insert kp;
        return kp;
    }
    public static TPS_Data__C insertTPSdata(id accnt,string shipto,string PStype, Date stordate){
        TPS_Data__c tp = new TPS_Data__c();
        tp.Customer__c = accnt;
        tp.Distributor_Ship_To__c=shipto;
        tp.Extraction_Date__c=stordate;
        tp.Invoice_Amount__c =123456;
        tp.Parts_Sold_Type__c=PStype;
        insert tp;
        return tp;
    }
     public static ETC_Data__c insertETCdata(id accnt,string shipto, Date stordate){
        ETC_Data__c etc = new ETC_Data__c();
        etc.Customer__c = accnt;
        etc.Distributor_Code__c=shipto;
        etc.Date__c=stordate;
        etc.Retail_Amount_ETC__c =1234;
        insert etc;
        return etc;
    }
    
    public static List<TPS_International_staging__c> createTpsIntStage(String sapId) {
        List<TPS_International_staging__c> tpsInt = new List<TPS_International_staging__c>();
        for(Integer i = 0; i<4; i++){
            TPS_International_staging__c t = new TPS_International_staging__c();
            t.Distributor_Ship_To__c = sapId;
            t.Extraction_Date__c = '10/11/2020';
            t.Invoice_Amount__c = '10000';
            tpsInt.add(t);
        }
        INSERT tpsInt;
        return tpsInt;   
    }
    
    public static List<TPS_Retran_staging__c> createTpsRetStage(String sapId) {
        List<TPS_Retran_staging__c> tpsRet = new List<TPS_Retran_staging__c>();
        for(Integer i = 0; i<4; i++){
            TPS_Retran_staging__c t = new TPS_Retran_staging__c();
            t.Distributor_Ship_To__c = sapId;
            t.Extraction_Date__c = '10/11/2020';
            t.Invoice_Amount__c = '10000';
            tpsRet.add(t);
        }
        INSERT tpsRet;
        return tpsRet;   
    }
    
    public static List<TPS_Staging_Data__c> createTpsStage(String sapId) {
        List<TPS_Staging_Data__c> tps = new List<TPS_Staging_Data__c>();
        for(Integer i = 0; i<4; i++){
            TPS_Staging_Data__c t = new TPS_Staging_Data__c();
            t.Distributor_Ship_To__c = sapId;
            t.Extraction_Date__c = '10/11/2020';
            t.Invoice_Amount__c = '10000';
            tps.add(t);
        }
        INSERT tps;
        return tps;   
    }
    
    public static List<TAT_Data__c> createTat(String dist){
        List<TAT_Data__c> tatList = new List<TAT_Data__c>();
        List<Account> accounts = new List<Account>();
        accounts = [SELECT ID,Name, ParentId, Type, Location_Type__c, SAP_ID__c, Sales_RegionA__c, ShippingCity, ShippingCountry,ShippingState,ShippingPostalCode,ShippingStreet, PRP_Participation__c FROM Account WHERE parentId=:dist];
        for(Account acc : accounts){
            if(acc.Type == 'Distributor Branch'){
                TAT_Data__c tatAwaare = new TAT_Data__c();
                TAT_Data__c tatTurnt = new TAT_Data__c();
                tatAwaare.Allison_Serial__c = 'A123';
                tatAwaare.Dealer_Id__c = acc.Id;
                tatAwaare.Distributor_Ship_To__c = acc.SAP_ID__c;
                tatAwaare.Claim_Number__c = '1234';
                tatAwaare.Extraction_Date__c= Date.newInstance(2020,1,10);
                tatAwaare.Repair_Order__c = '1234';
                tatAwaare.Repair_Type__c = 'I';
                tatAwaare.Partner_Code__c = acc.SAP_ID__c;
                tatAwaare.Source_Type__c = 'AWARE';
                tatAwaare.Transmission_serial_number__c = 'A123';
                tatAwaare.vin__c = 'v123';
                tatAwaare.Repair_Payment__c= 'C';
                tatList.add(tatAwaare);
                
                
                tatTurnt.Allison_Serial__c = 'A123';
                tatTurnt.Dealer_Id__c = acc.Id;
                tatTurnt.Distributor_Ship_To__c = acc.SAP_ID__c;
                tatTurnt.Claim_Number__c = '1234';
                tatTurnt.Extraction_Date__c= Date.newInstance(2020,1,10);
                tatTurnt.Repair_Order__c = '1234';
                tatTurnt.Repair_Type__c = 'O';
                tatTurnt.Partner_Code__c = acc.SAP_ID__c;
                tatTurnt.Source_Type__c = 'Distributor';
                tatTurnt.Transmission_serial_number__c = 'A123';
                tatTurnt.vin__c = 'v123';
                tatTurnt.Repair_Payment__c= 'C';
                tatList.add(tatTurnt);
                
                
            }            
        }
        INSERT tatList;
        return tatList;
    }
    
    public static List<End_Customer__c> createEndCust(String dist){
        List<End_Customer__c> endList = new List<End_Customer__c>();
        List<Account> accounts = new List<Account>();
        accounts = [SELECT ID,Name, ParentId, Type, Location_Type__c, SAP_ID__c, Sales_RegionA__c, ShippingCity, ShippingCountry,ShippingState,ShippingPostalCode,ShippingStreet, PRP_Participation__c FROM Account WHERE parentId=:dist];
        for(Account acc : accounts){
            if(acc.Type == 'Distributor Branch'){
                
                End_Customer__c ec = new End_Customer__c();
                ec.City__c = 'Delhi';
                ec.Country__c = 'India';
                ec.Customer__c = acc.Id;
                ec.Date_Of_Submission__c = Date.newInstance(2020,1,10);
             }            
        }
        INSERT endList;
        return endList;
    }
    
    public static List<Survey_Formula_Setup__c> insertSurveySetup(string surType,string region){
        List<Survey_Formula_Setup__c> surveySetUpList = new List<Survey_Formula_Setup__c>();
        for(Integer index = 0; index < 4; index++) {
            Survey_Formula_Setup__c sur = new Survey_Formula_Setup__c();
            sur.Survey_Type__c = surType;
            sur.Region_Type__c = region;
            sur.Question_Number__c='Q'+(index+1);
            sur.Percentage__c = 25;
            sur.Year__c = '2020';
            surveySetUpList.add(sur);
        }
        insert surveySetUpList;
        return surveySetUpList;
    }
    
    public static void insertSurveyData(List<Account> allBranchList,String surveyType, Integer surveyCOunt){
        List<Survey_Data__c> allSurveyData = new List<Survey_Data__c>();
        for(Account acct : allBranchList) {
            for(Integer index = 0; index < surveyCOunt; index++) {
                Survey_Data__c surveyRec = new Survey_Data__c();
                surveyRec.Customer_Dealer_Id__c = acct.Id;
                surveyRec.Ship_To__c = acct.SAP_ID__c;
                surveyRec.Survey_Type__c = surveyType;
                surveyRec.Q1_Value__c = 10.0;
                surveyRec.Q2_Value__c = 9.0;
                surveyRec.Q3_Value__c = 9.0;
                surveyRec.Q4_Value__c = 9.0;
                surveyRec.Q5_Value__c = 9.0;
                surveyRec.Q6_Value__c = 1;
                /*if(index != 1) surveyRec.Q8_Value__c = 10.0;
                if(surveyType == 'CSI') {
                    surveyRec.Q6_Value__c = 10.0;
                    surveyRec.Q9_Value__c = 9.0;
                }
                if(surveyType == 'Parts') {
                    surveyRec.Q4_Value__c = 9.0;
                    surveyRec.Q9_Value__c = 9.0;
                }
                if(surveyType == 'Service') {
                    surveyRec.Q4_Value__c = 9.0;
                    surveyRec.Q10_Value__c = 9.0;
                }*/
                
                surveyRec.Date_Taken__c = Date.newInstance(2020,1,18);
                allSurveyData.add(surveyRec);
            }
        }
        INSERT allSurveyData;
    }
    
    
    public static Account_Staging__c insertaccstage(string locType ,string shipto){
        Account_Staging__c acc = new Account_Staging__c();
        acc.Address_1__c='TestAd';
        acc.Name='TestName';
        acc.City__c='RKL';
        acc.Country__c='IND';
        acc.Company_Name__c='TestCom';
        acc.Error_Log__c='';
        acc.Location_Type__c=locType;
        acc.Phone_Number__c='1234567890';
        acc.Postal_Code__c='769012';
        acc.Sales_RegionA__c='North America';
        acc.Service_Location_ID__c=shipto;
        acc.State_Province__c='NZ';
        insert acc;
        return acc;
    }
    
    public static List<KPI_Setup__c > insertKPISetup(String region, String year, String PartnerType){
        List<KPI_Setup__c > KPIList = new List<KPI_Setup__c >();
        List<KPI_Range_Settings__c> KPIRangeList = new List<KPI_Range_Settings__c>();
        List<KPI_Date_Settings__c> KPIDateList = new List<KPI_Date_Settings__c>();
        for(String kpiType : regionKPITypeMap.get(region)) {
            KPI_Setup__c keyPerformanceIndicatorSetup = new KPI_Setup__c();
            keyPerformanceIndicatorSetup.Region__c = region;
            keyPerformanceIndicatorSetup.Year__c = year;
            keyPerformanceIndicatorSetup.KPI_Type__c = kpiType;
            keyPerformanceIndicatorSetup.Partner_Type__c = PartnerType;
            KPIList.add(keyPerformanceIndicatorSetup);
            
        }
        
        insert KPIList;
        for(KPI_Setup__c kpi : KPIList) {
            KPI_Range_Settings__c KPIRange1 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange2 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange3 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange4 = new KPI_Range_Settings__c();
            KPI_Date_Settings__c KPIDate = new KPI_Date_Settings__c();
            
            KPIRange1.Name = 'Reward Level 1';
            KPIRange1.Low_Range_Value__c = 9.1;
            KPIRange1.High_Range_Value__c = 100;
            KPIRange1.Points__c = 10;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange1.X2_Tech__c = False;
            KPIRange1.KPI_Setup__c = kpi.Id;
            KPIRangeList.add(KPIRange1);
            
            KPIRange2.Name = 'Reward Level 2';
            KPIRange2.Low_Range_Value__c = 1.1;
            KPIRange2.High_Range_Value__c = 9.0;
            KPIRange2.Points__c = 8.5;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange2.X2_Tech__c = False;
            KPIRange2.KPI_Setup__c = kpi.Id;
            KPIRangeList.add(KPIRange2);
            
            KPIRange3.Name = 'Reward Level 3';
            KPIRange3.Low_Range_Value__c = 0.1;
            KPIRange3.High_Range_Value__c = 1;
            KPIRange3.Points__c = 7;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange3.X2_Tech__c = False;
            KPIRange3.KPI_Setup__c = kpi.Id;
            KPIRangeList.add(KPIRange3);
            
            KPIRange4.Name = 'Reward Level 4';
            KPIRange4.Low_Range_Value__c = 0;
            KPIRange4.High_Range_Value__c = 0;
            KPIRange4.Points__c = 0;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange4.X2_Tech__c = False;
            KPIRange4.KPI_Setup__c = kpi.Id;
            KPIRangeList.add(KPIRange4);
            
            KPIDate.Name = 'January';
            KPIDate.KPI_Setup__c = kpi.Id;
            KPIDate.File_Submission_Date__c = Date.newInstance(2020,1,8);
            KPIDate.KPI_Calculation_Date__c = Date.newInstance(2020,1,12);
            //KPIDate.No_Of_Days_To_File_Submission_Date__c = -1;
            KPIDateList.add(KPIDate);
        }
        if(KPIRangeList.size() > 0) INSERT KPIRangeList;
        if(KPIDateList.size() > 0) INSERT KPIDateList;
        return KPIList;
    }
    public static void insertPRPSetup(String region, String year, String PartnerType, String month){
        List<PRP_Setup__c> PRPList = new List<PRP_Setup__c>();
        List<PRP_Range_Settings__c> PRPRangeList = new List<PRP_Range_Settings__c>();
        
        PRP_Setup__c performanceRewardProgramSetup = new PRP_Setup__c();
        performanceRewardProgramSetup.Year__c = year;
        performanceRewardProgramSetup.Region__c = region;
        performanceRewardProgramSetup.Partner_Type__c = PartnerType;
        performanceRewardProgramSetup.Month__c = month;
        performanceRewardProgramSetup.KPI_Selection__c = regionPRPTypeMap.get(region);
        performanceRewardProgramSetup.Manual_Override__c = False;
        PRPList.add(performanceRewardProgramSetup);
        
        insert PRPList;
        for(PRP_Setup__c prp : PRPList) {
            PRP_Range_Settings__c PRPRangeGold = new PRP_Range_Settings__c();
            PRP_Range_Settings__c PRPRangeSilver = new PRP_Range_Settings__c();
            PRP_Range_Settings__c PRPRangeBronze = new PRP_Range_Settings__c();
            
            PRPRangeGold.Name = 'Gold';
            PRPRangeGold.High_Range__c = 100;
            PRPRangeGold.Low_Range__c = 50.30;
            PRPRangeGold.Level_Discount__c = 8.00;
            PRPRangeGold.Functional_Comp_Range__c = 4.00;
            PRPRangeList.add(PRPRangeGold);
            
            PRPRangeSilver.Name = 'Silver';
            PRPRangeSilver.High_Range__c = 50.29;
            PRPRangeSilver.Low_Range__c = 29.00;
            PRPRangeSilver.Level_Discount__c = 5.00;
            PRPRangeSilver.Functional_Comp_Range__c = 2.00;
            PRPRangeList.add(PRPRangeSilver);
            
            PRPRangeSilver.Name = 'Bronze';
            PRPRangeSilver.High_Range__c = 28.99;
            PRPRangeSilver.Low_Range__c = 0.00;
            PRPRangeSilver.Level_Discount__c = 0.00;
            PRPRangeSilver.Functional_Comp_Range__c = 0.00;
            PRPRangeList.add(PRPRangeBronze);
            
            
        }
        //return PRPList;
    }
    public static TAT_Turnt_staging__c insertTATturnt( string sapid){
        TAT_Turnt_staging__c tat = new TAT_Turnt_staging__c();
        tat.Allison_Serial__c='29544858XX';
        tat.date_cust_request_service__c='06/25/2020';
        tat.customer_notified__c='06/25/2020';
        tat.Date_Distributor_schedules_for_service__c='06/25/2020';
        tat.Date_first_labor_applied__c='06/25/2020';
        tat.Date_First_Part_Ordered__c='06/25/2020';
        tat.Date_last_labor_applied__c='06/25/2020';
        tat.Date_of_File_Submission__c='02/28/2025';
        tat.PART_ARRIVAL_DATE__c='06/25/2020';
        tat.date_vehicle_first_arrived__c='06/25/2020';
        tat.Distributor_Ship_To__c=Sapid;
        tat.Error_Log__c='';
        tat.repair_order_number__c='R1080166';
        tat.Repair_Order_closed_date__c='06/25/2020';
        tat.Repair_Order_closed_time_of_day__c='09:28';
        tat.Repair_Order_open_date__c='06/25/2020';
        tat.Repair_Order_open_time_of_day__c='09:28';
        tat.Repair_Payment__c='C';
        tat.Repair_Type__c='I';
        tat.Technician_Name__c='Fuller Cody';
        tat.Time_customer_desires_service_to_begin__c='09:28';
        tat.Time_customer_notified_vehicle_available__c='09:28';
        tat.Time_Distributor_schedules_for_service__c ='09:28';
        tat.Time_of_day_first_labor_applied__c='09:28';
        tat.Time_of_day_last_labor_applied__c='09:28';
        tat.Time_of_day_vehicle_first_arrived__c='09:28';
        tat.Total_labor_hours__c='7';
        tat.vin__c='314606XXXXXXXXXXX';
        insert tat;
        return tat;
    }	
    
    public static List<Incentive__c> createIncentiveRec(id accId, String perfLevel, Decimal VFCAmount, Decimal TRPSAmount) {
        List<Incentive__c> instList = new List<Incentive__c>();
        Incentive__c Inceinst = new Incentive__c();
        Inceinst.IncentiveAcc__c = accId;
        Inceinst.Incentive_Amount__c = VFCAmount; 
        Inceinst.PerformanceLevel__c = perfLevel;
        Inceinst.TRPS_Amount__c = TRPSAmount ;
        Inceinst.Release_Incentive__c = 'X';
        instList.add(Inceinst);
        return instList;
    }
    public static void addFuncCompToDistributor(Account acc, Integer month,Integer year){
        List<Double> amounts = new List<Double>{2261.31,320280.51,7082.69};
            //Creating funcComp for all months till given one for the given year
            List<Functional_Comp_Data__c> funcComps = new List<Functional_Comp_Data__c>();
        for(Integer index = 1; index <= month; Index++){
            Date extrctDate = Date.newInstance(year, Math.mod((index+1),12), 5);
            for(Double amount : amounts){
                Functional_Comp_Data__c cmp = new Functional_Comp_Data__c();
                cmp.Invoice_amount__c = amount;
                cmp.Extraction_Date__c = extrctDate;
                cmp.Customer__c = acc.id;
                funcComps.add(cmp);
            }
        }
        insert funcComps;
    }
    public static Account createServiceDealer(Account acct, Boolean doInsert, Integer sequence) {
        Account accountRec = new Account();
        accountRec.Name = 'Test Branch ' + acct.SAP_ID__c + sequence;
        accountRec.Type = 'Service Dealer';
        accountRec.Location_Type__c = 'DB';
        accountRec.SAP_ID__c = acct.SAP_ID__c +String.valueOf(sequence).leftPad(5,'0');
        accountRec.Sales_RegionA__c = acct.Sales_RegionA__c;
        accountRec.ShippingCity = 'City';
        accountRec.ShippingCountry = 'Country';
        accountRec.ShippingState = 'State';
        accountRec.ShippingPostalCode = '765432';
        accountRec.ShippingStreet = 'Street';
        accountRec.PRP_Participation__c = true;
        accountRec.ParentId = acct.Id;
        if(doInsert) INSERT accountRec;
        return accountRec;
    }
    public static void addKPIsToBranch(List<Account> accounts, Integer month, Integer Year){
        List<Double> scores = new List<Double>{42.00,52.00,62.00,39.80,35.50,52.00,56.30,47.50};
            List<String> levels = new List<String>{'Silver','Gold','Gold','Silver','Silver','Gold','Gold','Silver'};
                List<Kpi__c> kpisToInsert = new List<Kpi__c>();
        Integer i =0 ;
        for(Account acc : accounts){
            Kpi__c tmp = new Kpi__c();
            tmp.Customer__c = acc.id;
            tmp.PRP_Score__c = scores.get(Math.mod(i,8));
            tmp.PRP_Level__c = levels.get(Math.mod(i,8));
            tmp.Partner_Type__c = 'Distributor';
            tmp.Year__c = year;
            tmp.Month__c = month;
            tmp.Region__c = 'North America';
            tmp.Period__c = 'YTD';
            tmp.isPartOfPRP__c = true;
            kpisToInsert.add(tmp);
        }
        insert kpisToInsert;
    }
    public static void createTPSDataForAccounts(List<Account> accounts,Integer year){
        Integer index = 1;
        List<TPS_Data__c> tpsData = new List<TPS_Data__c>();
        for(Account acc : accounts){
            for(Integer i=1; i<3;i++){
                Date extrctDate = Date.newInstance(year, Math.mod((i+1),12), 5);
                
                TPS_Data__c WPC 	= 	new TPS_Data__c();
                TPS_Data__c TPS 	= 	new TPS_Data__c();
                TPS_Data__c RET 	= 	new TPS_Data__c();
                TPS_Data__c CE 		= 	new TPS_Data__c();
                
                WPC.Invoice_Amount__c = 10000;
                WPC.Parts_Sold_Type__c = 'WPC';
                WPC.Extraction_Date__c = extrctDate;
                WPC.Customer__c = acc.id;
                WPC.Distributor_Ship_To__c = 'TEST SHIPPING';
                tpsData.add(WPC);
                
                CE.Invoice_Amount__c = 10000;
                CE.Parts_Sold_Type__c = 'CE';
                CE.Extraction_Date__c = extrctDate;
                CE.Customer__c = acc.id;
                CE.Distributor_Ship_To__c = 'TEST SHIPPING';
                tpsData.add(CE);
                
                RET.Invoice_Amount__c = 10000;
                RET.Parts_Sold_Type__c = 'RET';
                RET.Extraction_Date__c = extrctDate;
                RET.Customer__c = acc.id;
                RET.Distributor_Ship_To__c = 'TEST SHIPPING';
                tpsData.add(RET);
                
                TPS.Invoice_Amount__c = 10000;
                TPS.Parts_Sold_Type__c = 'TPS';
                TPS.Extraction_Date__c = extrctDate;
                TPS.Customer__c = acc.id;
                TPS.Distributor_Ship_To__c = 'TEST SHIPPING';
                tpsData.add(TPS);
            }    
        }
        insert tpsData;
    }
    private static Map<String, List<String>> regionPRPTypeMap2 = new Map<String, List<String>>{'North America' => new List<String>{'TPS','Training','Turnaround Time O','Turnaround Time I','Turnaround Time M','Total Parts Sold ReTran','CSI Service','CSI Parts'},
        'Latin America'=> new List<String>{'Parts Ordering','TPS','Training','CSI','Turnaround Time O','Turnaround Time I','Facility Audit'}};
            public static List<PRP_Setup__c> insertPRPSetupAndRange(String region, String year, String PartnerType, String month){
                List<PRP_Setup__c> PRPList = new List<PRP_Setup__c>();
                List<PRP_Range_Settings__c> PRPRangeList = new List<PRP_Range_Settings__c>();
                
                for(String prpType : regionPRPTypeMap2.get(region)) {
                    PRP_Setup__c performanceRewardProgramSetup = new PRP_Setup__c();
                    performanceRewardProgramSetup.Year__c = year;
                    performanceRewardProgramSetup.Region__c = region;
                    performanceRewardProgramSetup.Partner_Type__c = PartnerType;
                    performanceRewardProgramSetup.Month__c = month;
                    performanceRewardProgramSetup.KPI_Selection__c = prpType;
                    performanceRewardProgramSetup.Manual_Override__c = False;
                    PRPList.add(performanceRewardProgramSetup);
                    
                }
                insert PRPList;
                for(PRP_Setup__c prp : PRPList) {
                    PRP_Range_Settings__c PRPRangeGold = new PRP_Range_Settings__c();
                    PRP_Range_Settings__c PRPRangeSilver = new PRP_Range_Settings__c();
                    PRP_Range_Settings__c PRPRangeBronze = new PRP_Range_Settings__c();
                    
                    PRPRangeGold.Name = 'Gold';
                    PRPRangeGold.High_Range__c = 100;
                    PRPRangeGold.Low_Range__c = 50.30;
                    PRPRangeGold.Level_Discount__c = 8.00;
                    PRPRangeGold.Functional_Comp_Range__c = 4.00;
                    PRPRangeGold.PRP_Setup__c = prp.id;
                    PRPRangeList.add(PRPRangeGold);
                    
                    PRPRangeSilver.Name = 'Silver';
                    PRPRangeSilver.High_Range__c = 50.29;
                    PRPRangeSilver.Low_Range__c = 29.00;
                    PRPRangeSilver.Level_Discount__c = 5.00;
                    PRPRangeSilver.Functional_Comp_Range__c = 2.00;
                    PRPRangeSilver.PRP_Setup__c = prp.id;
                    PRPRangeList.add(PRPRangeSilver);
                    
                    PRPRangeBronze.Name = 'Bronze';
                    PRPRangeBronze.High_Range__c = 28.99;
                    PRPRangeBronze.Low_Range__c = 0.00;
                    PRPRangeBronze.Level_Discount__c = 0.00;
                    PRPRangeBronze.Functional_Comp_Range__c = 0.00;
                    PRPRangeBronze.PRP_Setup__c = prp.id;
                    PRPRangeList.add(PRPRangeBronze);
                    
                    
                }
                insert PRPRangeList;
                return PRPList;
            }
    public static void createKPI(Account acc){
        KPI__c tmp = new KPI__C();
        tmp.Facility_Audit__c = 5.0;
        tmp.Facility_Audit__c = 5.0;
        tmp.CSI__c = 5.0;
        tmp.PRP_Score__c = 5.0;
        tmp.PRP_Level__c = 'Gold';
        tmp.Turnaround_Time_I__c = 20.0;
        tmp.Turnaround_Time_M__c = 15.0;
        tmp.Turnaround_Time_O__c = 5.0;
        tmp.CSI_Dealer__c = 5.0;
        tmp.CSI_Parts__c = 5.0;
        tmp.CSI_Service__c = 5.0;
        tmp.Parts_Ordering__c = 5.0;
        tmp.Total_Parts_Sold__c = 5.0;
        tmp.Total_Parts_Sold_ReTran__c = 5.0;
        tmp.TPS__c = 5.0;
        tmp.Training__c = 5.0;
        tmp.Region__c = 'North America';
        tmp.Year__c = 2020;
        tmp.Month__c = 1;
        tmp.Customer__c = acc.id;
        tmp.Period__c = 'YTD';
        tmp.isPartOfPRP__c = true;
        tmp.Released__c = 'X';
        tmp.KPI_Calculation_Date__c = Date.newInstance(2020,1, 12);
        insert tmp;
        
    }
    public static List<KPI_Setup__c > insertKPISetupAndRange(String region, String year, String PartnerType){
        List<KPI_Setup__c > KPIList = new List<KPI_Setup__c >();
        List<KPI_Range_Settings__c> KPIRangeList = new List<KPI_Range_Settings__c>();
        List<KPI_Date_Settings__c> KPIDateList = new List<KPI_Date_Settings__c>();
        for(String kpiType : regionKPITypeMap2.get(region)) {
            KPI_Setup__c keyPerformanceIndicatorSetup = new KPI_Setup__c();
            keyPerformanceIndicatorSetup.Region__c = region;
            keyPerformanceIndicatorSetup.Year__c = year;
            keyPerformanceIndicatorSetup.KPI_Type__c = kpiType;
            keyPerformanceIndicatorSetup.Partner_Type__c = PartnerType;
            KPIList.add(keyPerformanceIndicatorSetup);
            
        }
        
        insert KPIList;
        for(KPI_Setup__c kpi : KPIList) {
            KPI_Range_Settings__c KPIRange1 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange2 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange3 = new KPI_Range_Settings__c();
            KPI_Range_Settings__c KPIRange4 = new KPI_Range_Settings__c();
            KPI_Date_Settings__c KPIDate = new KPI_Date_Settings__c();
            
            KPIRange1.Name = 'Reward Level 1';
            KPIRange1.Low_Range_Value__c = 0;
            KPIRange1.High_Range_Value__c = 100;
            KPIRange1.Points__c = 5.0;
            KPIRange1.Points__c = 10;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange1.X2_Tech__c = False;
            KPIRange1.KPI_Setup__c = kpi.id;
            KPIRangeList.add(KPIRange1);
            
            KPIRange2.Name = 'Reward Level 2';
            KPIRange2.Low_Range_Value__c = 0;
            KPIRange2.High_Range_Value__c = 100;
            KPIRange2.Points__c = 5.0;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange2.X2_Tech__c = False;
            KPIRange2.KPI_Setup__c = kpi.id;
            KPIRangeList.add(KPIRange2);
            
            KPIRange3.Name = 'Reward Level 3';
            KPIRange3.Low_Range_Value__c = 0;
            KPIRange3.High_Range_Value__c = 100;
            KPIRange3.Points__c = 5.0;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange3.X2_Tech__c = False;
            KPIRange3.KPI_Setup__c = kpi.id;
            KPIRangeList.add(KPIRange3);
            
            KPIRange4.Name = 'Reward Level 4';
            KPIRange4.Low_Range_Value__c = 0;
            KPIRange4.High_Range_Value__c = 100;
            KPIRange4.Points__c = 5.0;
            //KPIRange.Reward_Level__c = 'RL1';
            KPIRange4.X2_Tech__c = False;
            KPIRange4.KPI_Setup__c = kpi.id;
            KPIRangeList.add(KPIRange4);
            
            KPIDate.Name = 'January';
            KPIDate.File_Submission_Date__c = date.newInstance(2020, 1, 8);
            KPIDate.KPI_Calculation_Date__c = date.newInstance(2020,1,12);
            KPIDate.KPI_Setup__c = kpi.id;
            //KPIDate.No_Of_Days_To_File_Submission_Date__c = -1;
            KPIDateList.add(KPIDate);
        }
        insert KPIRangeList;
        insert KPIDateList;
        
        return KPIList;
    }
}