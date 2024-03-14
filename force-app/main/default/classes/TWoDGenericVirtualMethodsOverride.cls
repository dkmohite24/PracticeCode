global with sharing class TWoDGenericVirtualMethodsOverride extends WOD_2.TWoDGenericVirtualMethods{
    global override WOD_2.ResponseWrapper postProcessOverride(String type, WOD_2.ResponseWrapper inputResponseWrapper) { 
        Map<Id,String> strMap = (Map<Id,String>)JSON.deserialize(inputResponseWrapper.data, Map<Id,String>.class);
        Set<Id> idSet = strMap.keyset();
        List<Id> idLst = new List<Id>(idSet);
        Id recordId = idLst[0];
        if(recordId.getsobjecttype() == WOD_2__Warranty_Registration__c.sObjectType){
            WOD_2__Warranty_Registration__c wrList = [Select Id,WOD_2__Chatter_Comments__c from WOD_2__Warranty_Registration__c where Id=:recordId LIMIT 1];
        }else if(recordId.getsobjecttype() == WOD_2__Claim__c.sObjectType){
            WOD_2__Claim__c clmList = [Select Id,WOD_2__Comments__c,WOD_2__Reopen_Description__c,WOD_2__Appeal_Description__c from WOD_2__Claim__c where Id=:recordId LIMIT 1];
        }
        Map<String,List<ConversationResponseOne>> conversationResponseList = (Map<String,List<ConversationResponseOne>>)JSON.deserialize(strMap.get(recordId), map<String,List<ConversationResponseOne>>.class);
        Set<String> typetest = conversationResponseList.keyset();
        List<String> typeList = new List<String>(typetest);
        String str = typeList[0];
        System.debug('The indicator is '+ str);
        List<ConversationResponseOne> newList = conversationResponseList.get(str);
        String isDealer=Network.getNetworkId();
        List<Id> idList = new List<Id>();
        //ALSN-156 reversing the way comments are shown
        List<ConversationResponseOne> reversedList= new LIst<ConversationResponseOne>();
        for(integer I= newList.size()-1; i>=0; i--){
            reversedList.add(newList.get(I));
        }
        newList=reversedList;
        for(ConversationResponseOne var:newList){
            idList.add(var.userId);
            System.debug('idList'+idList);
        }
        String query = 'Select Id,Name,CommunityNickname,ContactId from User where Id in: idList';
        List<User> usrLst = ATI_QueryRunWithoutSharing.runQueryWithIds(query,idList);
        if(isDealer!= null || Test.isRunningTest()){          
            for(ConversationResponseOne var:newList){
                for(User u:usrLst){
                    if(u.Id == var.userId){
                        if(u.ContactId!=null){
                            var.userName = u.Name; 
                        }else{
                            var.userName = u.CommunityNickname;  
                            var.userAbbr = 'U';
                        } 
                    }
                }
            }
        }   
        WOD_2.ResponseWrapper resp = new WOD_2.ResponseWrapper(JSON.serialize(newList),true,'');            
        return resp;       
    }
    
    public class ConversationResponseOne {
        @AuraEnabled
        public String userAbbr;
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public String chatDescription;
        @AuraEnabled
        public String entryDate;
        @AuraEnabled
        public Boolean allowDelete;
        @AuraEnabled
        public Boolean selfComment;        
        @AuraEnabled
        public String chatId;       
        @AuraEnabled
        public String helpTextIconName;
        @AuraEnabled
        public String helpTextContent;
    }
}