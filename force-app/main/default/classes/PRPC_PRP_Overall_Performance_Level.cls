/*
 * Update : CHG44065 - Revoke the use of PRP_Profile__mdt metadata.
 * Update By : Susovan Mondal & Chinmaya Das
 * Update Date : 08/23/2023
 */



public class PRPC_PRP_Overall_Performance_Level {
    
    public static Integer testMonth;
    
    @AuraEnabled
    public static PRPandRegion prpCalculation(String region, String type){
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        // CHG44065  Revoke the use of PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               profileName=pmap.get(s);
            }
        }*/
        User u = new User();
        if(profileName == 'PRP Partner'){
            ID userId = UserInfo.getUserId();
            System.debug('Current User Id - '+userId);
            u = [select id, contact.Account.Sales_RegionA__c, contact.Account.Type, contact.AccountId from User where id = : UserId];
            System.debug('Region- ' + u.contact.Account.Sales_RegionA__c);
            region = u.contact.Account.Sales_RegionA__c;
            type = u.contact.Account.Type;
        }
        
       
        Integer Month = Date.Today().Month();
        Integer year = Date.Today().Year();
        if(Test.isRunningTest()){
            Month = testMonth;
        }
        if(Month == 1){
            Month = 12;
            year = year-1;
        }
        else{
            Month = Month-1;
        }
        String yearText = String.valueOf(year);
        Double kpiInst;
        if(!Test.isRunningTest()){
         kpiInst = [SELECT Month__c FROM KPI__c WHERE Released__c = 'X' AND Customer__r.Sales_RegionA__c = :region AND Year__c = :year ORDER BY createdDate DESC Limit 1].Month__c;
        }else{
         kpiInst = [SELECT Month__c FROM KPI__c WHERE Released__c = 'X' ORDER BY createdDate DESC Limit 1].Month__c;
        }
        String monthName = '';
        if(kpiInst == 1)
            monthName = 'January';
        else if(kpiInst == 2)
            monthName = 'February';
        else if(kpiInst == 3)
            monthName = 'March';
        else if(kpiInst == 4)
            monthName = 'April';
        else if(kpiInst == 5)
            monthName = 'May';
        else if(kpiInst == 6)
            monthName = 'June';
        else if(kpiInst == 7)
            monthName = 'July';
        else if(kpiInst == 8)
            monthName = 'August';
        else if(kpiInst == 9)
            monthName = 'September';
        else if(kpiInst == 10)
            monthName = 'October';
        else if(kpiInst == 11)
            monthName = 'November';
        else
            monthName = 'December';
        System.debug('Region__c :'+region+'Partner_Type__c :'+type+'monthName :'+monthName+'yearText :'+yearText);
        List<PRP_Setup__c> prp = new List<PRP_Setup__c>();
            prp = [SELECT Month__c, Year__c, Create_Date__c, Region__c,
                                  (SELECT id, Name, Alloation__c, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                                  ORDER BY createdDate DESC LIMIT 3) 
                                  FROM PRP_Setup__c WHERE Region__c = :region AND Partner_Type__c = :type AND Month__c = :monthName AND Year__c = :yearText ORDER BY createdDate DESC LIMIT 1];
            if(prp.size()<=0){
               prp = [SELECT Month__c, Year__c, Create_Date__c, Region__c,
                                  (SELECT id, Name, Alloation__c, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                                  ORDER BY createdDate DESC LIMIT 3) 
                                  FROM PRP_Setup__c WHERE Region__c = :region AND Partner_Type__c = :type AND Month__c = :monthName AND Year__c = :String.valueOf(Integer.valueOf(yearText)-1) ORDER BY createdDate DESC LIMIT 1]; 
            }
        System.debug('prp- ' + prp);
        system.debug('region: '+region);
        system.debug('type: '+type);
        List<KPI_Calculation__mdt> kpiSelection = new List<KPI_Calculation__mdt>();
        if(region == 'North America' && type == 'Distributor'){
            kpiSelection = [select MasterLabel, KPI__c, Region__c, Type__c FROM KPI_Calculation__mdt WHERE Region__c = 'North America' AND Type__c = 'Distributor'];
        }
        else if(region != 'North America' && type == 'Direct Dealer'){
            kpiSelection = [select MasterLabel, KPI__c, Region__c, Type__c FROM KPI_Calculation__mdt WHERE Region__c != 'North America' AND Type__c = 'Direct Dealer'];
        }
        else if(region != 'North America' && type == 'Distributor'){
            kpiSelection = [select MasterLabel, KPI__c, Region__c, Type__c FROM KPI_Calculation__mdt WHERE Region__c != 'North America' AND Type__c = 'Distributor'];
        }
        return new PRPandRegion(prp, profileName, region, kpiSelection);

    }
    
    public Class PRPandRegion{
        @AuraEnabled public List<PRP_Setup__c> prp;
        @AuraEnabled public String profileName;
        @AuraEnabled public String region;
        @AuraEnabled public List<KPI_Calculation__mdt> kpiSelection;
        public PRPandRegion(List<PRP_Setup__c> prp,String profileName, String region, List<KPI_Calculation__mdt> kpiSelection){
            this.prp=prp;
            this.profileName = profileName;         
            this.region = region;
            this.kpiSelection = kpiSelection;
        }
    }

}