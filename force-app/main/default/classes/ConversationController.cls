//CONVERSATIONCONTROLLER
//WITHOUT SHARING IS USED BECAUSE IT ALLOW TO UPDATE THE RECORD AFTER IT IS SUBMITTED FOR APPROVAL.
public without sharing class ConversationController {
    
    private static List<String> getConversationHistoryFields(){
        List<String> fieldList = new List<String>();
        fieldList.add('Name'); 
        fieldList.add('Internal_Conversations__c');
        fieldList.add('External_Conversations__c');
        return fieldList;
    }
    
   private static List<ConversationResponse> convertToResponse(List<ConversationData> conversationDataList,Boolean isInternalComment){
        List<ConversationResponse> conversationResponseList = new List<ConversationResponse>();
        Set<Id> userIds = new Set<Id>();
        System.debug('Inside convertToResponse');
        for(ConversationData conversationDataObject:conversationDataList) {
            userIds.add(conversationDataObject.u); 
        }
        System.debug('UsersIds'+userIds);
        List<String> userFields = getUserFields();
        ATI_Utils.NoAccessObjectFieldWrapper noAccessList = ATI_Utils.fetchReadAccess('User', userFields);
        if(noAccessList.noAccessObjectList.isEmpty() && noAccessList.noAccessFieldList.isEmpty()){
            List<User> usersList =  [Select Id,Name from User where Id IN :userIds];
            Map<Id,User> users = new Map<Id,User>(usersList);
            System.debug('Users'+users);
            for(ConversationData conversationDataObject:conversationDataList) {
                ConversationResponse conversationResponseObject = new ConversationResponse();
                conversationResponseObject.userName = users.get(Id.valueOf(conversationDataObject.u)).Name;
                conversationResponseObject.userAbbr = getAbbreviation(conversationResponseObject.userName);
                conversationResponseObject.chatDescription = conversationDataObject.c;
                conversationResponseObject.entryDate = conversationDataObject.d;
                conversationResponseObject.allowDelete = false;
                conversationResponseObject.selfComment = conversationDataObject.u == userInfo.getUserId() ? true : false;
                conversationResponseObject.chatId = conversationDataObject.i;
                conversationResponseObject.type = conversationDataObject.t;
                conversationResponseObject.isInternal = isInternalComment;
                conversationResponseObject.userId = conversationDataObject.u;
                conversationResponseList.add(conversationResponseObject);
            }
        }
        return conversationResponseList;
    }

    //use the createdBy name to create the Abbreviation.The method will seperate the name by space and take the first letter of the first and the last word.
    private static String getAbbreviation(String createdByName) {
        String abbr;
        if(createdByName != null) {
            List<String> nameSplitList = createdByName.split(' ');
            if(nameSplitList.size() > 1) {
                abbr = (nameSplitList[0].subString(0,1)).toUpperCase() +(nameSplitList[nameSplitList.size()-1].subString(0,1)).toUpperCase();
            }else {
                abbr = (createdByName.subString(0,1)).toUpperCase();
            }
            return abbr;
        }else {
            return null;
        }
    }

    // returns object fetched from DB
    private static SObject getConversationObject(String sObjId){
        SObject conHisObj = null;
        List<String> conversationFields = getConversationHistoryFields();
        String sObjName = Id.valueOf(sObjId).getSObjectType().getDescribe().getName();
        ATI_Utils.NoAccessObjectFieldWrapper noAccessList = ATI_Utils.fetchReadAccess(sObjName, conversationFields);
        if(noAccessList.noAccessObjectList.isEmpty() && noAccessList.noAccessFieldList.isEmpty()){
            String entityId = String.escapeSingleQuotes(sObjId);
        	String query = 'Select Id, ' + String.join(conversationFields, ',') + ' from ' + sObjName + ' where Id = :entityId';
            List<SObject> conversationsList = Database.query(query);
            if(!conversationsList.isEmpty()){
                conHisObj = conversationsList.get(0); 
            }
        } else {
            throw new TWoDException('(' + sObjName + ')' + Label.ATI_Log_Insufficient_access);
        }
        return conHisObj;
    }
    

    @AuraEnabled
    public static WOD_2.ResponseWrapper getConversations(String sObjId){
        try{
            List<ConversationResponse> conversationResponseList = new List<ConversationResponse>();
            SObject ch = getConversationObject(sObjId);
            if(ch != null){
                String internalComments = String.valueOf(ch.get('Internal_Conversations__c'));
                String externalComments = String.valueOf(ch.get('External_Conversations__c'));
                if(String.isNotBlank(internalComments)){
                    List<ConversationData> internalList = (List<ConversationData>)JSON.deserialize(internalComments,List<ConversationData>.class);
                    conversationResponseList.addAll(convertToResponse(internalList, true));
                }
                if(String.isNotBlank(externalComments)){
                    List<ConversationData> externalList = (List<ConversationData>)JSON.deserialize(externalComments,List<ConversationData>.class);
                    conversationResponseList.addAll(convertToResponse(externalList, false));
                }
            }
            return new WOD_2.ResponseWrapper(JSON.serialize(conversationResponseList),true,'');
        }catch(Exception e) {
            return new WOD_2.ResponseWrapper('',false,e.getMessage());
        }
    }
    
    //this method will form the data as per the defined structure.
    private static ConversationData processAndGetNewConversation(String comment,String type) {
        ConversationData conversationDataObject = new ConversationData();
        conversationDataObject.u = UserInfo.getUserId();
        conversationDataObject.d = Datetime.now().format();
        conversationDataObject.c = comment;
        conversationDataObject.t = type;
        conversationDataObject.i = generateChatId();
        return conversationDataObject;
    }

    private static String generateChatId() {
        Integer len = 4;
        Blob blobKey = Crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String pwd = key.substring(0,len);
        return pwd;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper saveConversation(String comment, String sObjId, Boolean isInternalComment){
        WOD_2.ResponseWrapper responseObj = new WOD_2.ResponseWrapper();
        if(isInternalComment){
            responseObj = saveConversationToSObject(comment,sObjId,'I');
        }else{
            responseObj = saveConversationToSObject(comment,sObjId,'D');
        } 
        return responseObj;
    }
    
    public static WOD_2.ResponseWrapper saveConversationToSObject(String comment, String sObjId, String typeOfUser){
        try{
            SObject conHisObj = getConversationObject(sObjId);
            String internalComments = String.valueOf(conHisObj.get('Internal_Conversations__c'));
            String externalComments = String.valueOf(conHisObj.get('External_Conversations__c'));
            List<ConversationData> conversationDataListForInternal = new List<ConversationData>();
            List<ConversationData> conversationDataListForExternal = new List<ConversationData>();
            
            if(String.isNotBlank(internalComments)) {
                conversationDataListForInternal = (List<ConversationData>)JSON.deserialize(internalComments,List<ConversationData>.class);
            }
            if(String.isNotBlank(externalComments)) {
                conversationDataListForExternal = (List<ConversationData>)JSON.deserialize(externalComments,List<ConversationData>.class);
            }
            if(typeOfUser == 'I' || typeOfUser == 'BOTH'){
                conversationDataListForInternal.add(processAndGetNewConversation(comment,'C'));
                conHisObj.put('Internal_Conversations__c',JSON.serialize(conversationDataListForInternal));
            }
            if(typeOfUser == 'D' || typeOfUser == 'BOTH'){
                conversationDataListForExternal.add(processAndGetNewConversation(comment,'C'));
                conHisObj.put('External_Conversations__c',JSON.serialize(conversationDataListForExternal));
            }
            
            Database.upsert(conHisObj);
            return new WOD_2.ResponseWrapper('',true,'');
        }catch(exception ex) {
            return new WOD_2.ResponseWrapper('',false,ex.getMessage());
        }
    }
    
    private static List<String> getUserFields(){
        List<String> userFields = new List<String>();
        userFields.add('Name');
        userFields.add('IsActive');
        userFields.add('IsPortalEnabled');
        userFields.add('LastName');
        return userFields;
    }

     @AuraEnabled
    public static WOD_2.ResponseWrapper isUserInfo() {
        List<String> userFields = getUserFields();
        ATI_Utils.NoAccessObjectFieldWrapper noAccessList = ATI_Utils.fetchReadAccess('User', userFields);
        if(noAccessList.noAccessObjectList.isEmpty() && noAccessList.noAccessFieldList.isEmpty()){
            List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
            System.debug('users '+users);
            if(users != null && users.size() != 0) {
                System.debug('Partner User');
                return new WOD_2.ResponseWrapper(JSON.serialize(users.get(0)),true,'');
            }else {
                return new WOD_2.ResponseWrapper('',false,'No User Found');
            }
        }
        return new WOD_2.ResponseWrapper('',false,'No User Found');
    }
   
    
    //Data structure for the lightning component to display and accept the data.
    public class ConversationData {
        @auraEnabled
        public String u;                //userId
        @auraEnabled
        public String c;                //chatDescription
        @auraEnabled
        public String d;                //date
        @auraEnabled
        public String i;
        @auraEnabled
        public String t;
    }
    
    public class ConversationResponse {
        @auraEnabled
        public String userAbbr;
        @auraEnabled
        public String userName;
        @auraEnabled
        public String userId;
        @auraEnabled
        public String chatDescription;
        @auraEnabled
        public String entryDate;
        @auraEnabled
        public Boolean allowDelete;
        @auraEnabled
        public Boolean selfComment;
        @AuraEnabled
        public Boolean isInternal;
        @AuraEnabled
        public String chatId;
        @AuraEnabled
        public String type;
    }
     
}