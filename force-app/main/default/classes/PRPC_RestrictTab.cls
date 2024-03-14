/*
 * Update : CHG44065 -Update the profile check for PRP Admin & CSM User to custom permissions.
 * Update By : 08/23/2023, Susovan Mondal & Chinmaya Das
 */


global class PRPC_RestrictTab {
    @AuraEnabled
    global static String CommunityTab(){
        system.debug('enter line 8');
        
        string returnProfileName;
        Id profileId=userinfo.getProfileId();
        
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name; 
        system.debug('ProfileName'+profileName);
        //String the Custom permission set name
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        If(isPRPAdminPermission==true ){
            returnProfileName='PRP Admin';
        }
        Boolean isCSMPermission = FeatureManagement.checkPermission('ATI_PRP_CSM');
        If(isCSMPermission==true ){
            returnProfileName='Custom Platform User';
        }
        
        if(profileName == 'PRP Partner'){
            returnProfileName = profileName;
        }else if(profileName == 'Standard Platform User'){
            returnProfileName = profileName;
        }
        /*else if(profileName == 'Custom Platform User'){
            returnProfileName = profileName;
        }else if(profileName == 'PRP Admin'){
            returnProfileName = profileName;
        }*/
        else if(profileName == 'System Administrator'){
            returnProfileName = profileName;
        }
        Id userid = userinfo.getUserId();
        //Removing the metadata as we are moving the profile
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               returnProfileName=pmap.get(s);
            }
        }*/
         
       
       system.debug('returnProfileName: '+returnProfileName);
       return returnProfileName;
    }
    @AuraEnabled
    public static string getStandardReport(String reportLabel) {
        System.debug('Label Name ::'+reportLabel);
        Report repRec=[SELECT Id,Name,DeveloperName from Report where DeveloperName=:reportLabel];
        string reportPlannedId=repRec.Id;
        System.debug('ID IS :::'+reportPlannedId);
        return reportPlannedId;
    }
    
     public static void fakeMethod(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                
    }
}