trigger ATI_UserTrigger on User (before insert,after insert, before update,after update) {       
    //TWOD_TriggerDispatcher.run(new ATI_UserTriggerHandler(),'ATI_UserTrigger');
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_UserTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_UserTriggerHandler().run();
    }
    
    // User Registration
    if(Trigger.isafter && Trigger.isinsert){
        CommunityUserLookupAutoPopulation.CommunityAutopopulation(Trigger.new);
        
        for(User u:Trigger.New)
        { String uname=u.Username;
         CommunityUserLookupAutoPopulation.userpackagelicense(uname);
        }
    }    
    
    //Deleting Package License for InActive User
    if(Trigger.isafter && Trigger.isupdate)
    {
        Map<Id,User> mapNewUser =  new Map<Id,User>(Trigger.New);
        Map<Id,User> mapOldUser = New Map<Id,User>(Trigger.Old);
        
        List<Id> IdsofDeactivatedUser = new List<Id>();
        for(User us : mapNewUser.Values())
        {
            if(us.IsActive == false && mapOldUser.get(us.Id).IsActive == true && us.usertype!='PowerPartner' )
            { 
                IdsofDeactivatedUser.add(us.Id);
            }
            
        }
        if(IdsofDeactivatedUser.size()>0){
            CommunityUserLookupAutoPopulation.removeUserPackageLicense(IdsofDeactivatedUser);
        }
    }    
}