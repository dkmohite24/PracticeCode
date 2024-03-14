/* Name: ATI_SHP_ShipmentDataService
   @Description :Data Service class for SHP_ShipmentService Class
   @Author : Tavant (Manjunatha V P)
   History :
   VERSION      AUTHOR                DATE                      DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Manjunatha)    30-October-2019           INITIAL DEVELOPMENT
   @changes - Harish HB
   21-June-2020
   @changes - Prasad
   Copied from Product as this class is not global and we have to override interfaces and update shipment and RCP objects   	
   BaseControllerDataService.getPopulatedFieldApiNames - For DML access Check, added as part of security review violations
   
 */
public inherited sharing class ATI_SHP_ShipmentDataService {

    public static String className = 'ATI_SHP_ShipmentDataService';
   
   //method to Insert/Update claim shipment records
    public static void upsertClaimShipmentRecords(List<WOD_2__Claim_Shipment__c> claimShipmentRecords){
        Set<String> claimShipmentFieldSet = claimShipmentRecords[0].getPopulatedFieldsAsMap().keySet();
        //Removing this field from access checks because it's a master detail field and reparenting is not allowed for this field
        //claimShipmentFieldSet.remove('WOD_2__Shipment_Detail__c');
        //ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','CREATE', new List<String>(claimShipmentFieldSet));// TBD : Prasad
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','UPDATE', new List<String>(claimShipmentFieldSet));
        upsert claimShipmentRecords;
    }

    //Method to delete Claim shipment records given claim shipment records
    public static void deleteClaimShipmentRecords(List<WOD_2__Claim_Shipment__c> claimShipmentRecords){
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','DELETE',new List<String>());
        delete claimShipmentRecords;
    }

    //Method to delete Claim shipment records given claim shipment records ID list
    public static void deleteClaimShipmentRecords(List<Id> claimShipmentRecordIdList){
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','DELETE',new List<String>());
        List<WOD_2__Claim_Shipment__c> deleteList = [SELECT ID FROM WOD_2__Claim_Shipment__c WHERE ID IN:claimShipmentRecordIdList];
        delete deleteList; 
    }

   //Method to delete Claim shipment records given claim shipment Id
   public static void deleteClaimShipmentRecords(String shipmentId){
    ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','DELETE',new List<String>());
    List<WOD_2__Claim_Shipment__c> deleteList = [SELECT ID FROM WOD_2__Claim_Shipment__c WHERE WOD_2__Shipment_Detail__c =:shipmentId];
    delete deleteList;
   }

   //Method to insert/update Shipment Records
   public static void upsertShipmentRecords(List<WOD_2__Shipment_Detail__c> shipmentRecordList){
       List<String> shipmentFieldList = new List<String>(shipmentRecordList[0].getPopulatedFieldsAsMap().keySet());
       //ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','CREATE', shipmentFieldList); // TBD : Having issues these method
       //ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','UPDATE', shipmentFieldList); 
       upsert shipmentRecordList;
   }

   //method to fetch shipment record details given the shipment recordID
   public static List<WOD_2__Shipment_Detail__c> fetchShipmentRecord(List<Id> shipmentIdList, List<String> fieldList){
       ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','READ',fieldList);
       String shipmentQuery = 'SELECT Id,Name,'+String.join(fieldList,',')+' FROM WOD_2__Shipment_Detail__c WHERE Id IN:shipmentIdList';
       List<WOD_2__Shipment_Detail__c> resultList = Database.query(String.escapeSingleQuotes(shipmentQuery));
       return resultList;
   }

   //method to fetch BU details
   public static List<WOD_2__Business_Category_Configuration__c> fetchBUDetails(List<String> buNameList){
       List<String> businessUnitFieldList = new List<String>{'Name'};
       ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Business_Category_Configuration__c','READ',businessUnitFieldList);
       List<WOD_2__Business_Category_Configuration__c> businessUnitList = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c WHERE Name IN :buNameList];
       return businessUnitList;   
   }

   //Method to fetch Warehouse details given the BU names
   public static List<WOD_2__Warehouse__c> fetchWareHouseRecords(List<String> businessUnitsList){ 
       List<String> wareHouseFieldList = new List<String>{'WOD_2__Business_Units__c','WOD_2__Address_Line_1__c','WOD_2__Address_Line_2__c','WOD_2__Address_Line_3__c','WOD_2__Address_Line_4__c','WOD_2__Zip_Code__c','WOD_2__City__c','WOD_2__Country__c','WOD_2__State_Province__c'};
       ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Warehouse__c','READ', wareHouseFieldList);
       //Using Database.query because INCLUDES function does not support variable binding
        String wareHouseQueryString = 'SELECT ID,Name, Business_Units__c, WOD_2__Address_Line_1__c, WOD_2__Address_Line_2__c, WOD_2__Address_Line_3__c, WOD_2__Address_Line_4__c, WOD_2__Zip_Code__c,WOD_2__City__c,WOD_2__Country__c,WOD_2__State_Province__c  FROM Warehouse__c WHERE Business_Units__c INCLUDES ( \''+String.join(businessUnitsList,'\',\'') + '\')';
        System.debug('WAREHOUSE QUERY '+ wareHouseQueryString);
       //Doing Access checks on above line
        List<WOD_2__Warehouse__c> wareHouseList = (List<WOD_2__Warehouse__c>) Database.query(wareHouseQueryString); 
        return wareHouseList;

   }

   //Method to fetch Logged in User details like if he is a dealer or internal user and available Business Units for him
   public static List<User> fetchUserRecords(){
       List<String> userFieldList = new List<String>{'ContactId','WOD_2__Business_Units__c '};
       String userId = userInfo.getUserId();
       ATI_SHP_ShipmentDataService.checkForAccess('User','READ', userFieldList);
       List<User> userList = new List<User>();
       //Doing Access checks on above line
       userList = [SELECT Id, ContactId, Contact.AccountId, WOD_2__Business_Units__c FROM User WHERE Id =:userId];
       return userList;
 
   }

   //Method to fetch account Details details
   public static String fetchDealerAccountId(Id contactId){
        ATI_SHP_ShipmentDataService.checkForAccess('Contact','READ',new List<String>{'AccountId'});
       //Doing Access checks on above line
       List<Contact> contactList = [SELECT ID, AccountId FROM Contact WHERE Id =:contactId];
       String AccountId = '';
       if(contactList[0].AccountId != null){
        AccountId = contactList[0].AccountId;
       }
       return AccountId;
   }

   //Method to delete Shipments given the shipment ID
   public static void deleteShipment(String shipmentId){
    ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','DELETE',new List<String>());
    List<WOD_2__Shipment_Detail__c> deleteList = [SELECT ID FROM WOD_2__Shipment_Detail__c WHERE ID =:shipmentId];
    delete deleteList;
   }

   //Methods to fetch all Claim shipment records given the shipment Id
   public static List<WOD_2__Claim_Shipment__c> fetchRelatedClaimShipments(String shipmentId, List<String> claimShipmentFieldSet){
    ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','READ', claimShipmentFieldSet);
    Set<String> fieldsToBeQueried = new Set<String>(claimShipmentFieldSet);
    fieldsToBeQueried.add('WOD_2__Removed_Claim_Part__c');
    fieldsToBeQueried.add('WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c');
    fieldsToBeQueried.add('WOD_2__Shipment_Detail__c');
    String claimShipmentQuery = 'SELECT Id,'+String.join( new List<String>(fieldsToBeQueried), ',') +' FROM WOD_2__Claim_Shipment__c WHERE WOD_2__Shipment_Detail__c =:shipmentId'; 
    List<WOD_2__Claim_Shipment__c> resultList = Database.query(String.escapeSingleQuotes(claimShipmentQuery));
    return resultList;
   }

   //Method to fetch Claim shipment records
   public static List<WOD_2__Claim_Shipment__c> fetchClaimShipmentRecords(List<String> claimShipmentFieldSet, List<Id> rcpIdList, String shipmentId){
    ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim_Shipment__c','READ', claimShipmentFieldSet);
       Set<String> fieldsToBeQueried = new Set<String>(claimShipmentFieldSet);
       fieldsToBeQueried.add('WOD_2__Removed_Claim_Part__c');
       fieldsToBeQueried.add('WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c');
       fieldsToBeQueried.add('WOD_2__Shipment_Detail__c');
       fieldsToBeQueried.add('WOD_2__Shipment_Detail__r.WOD_2__Status__c');
       List<String> shipmentStatusList = new List<String>();
       String claimShipmentQuery = 'SELECT Id, '+String.join( new List<String>(fieldsToBeQueried), ',') +' FROM WOD_2__Claim_Shipment__c WHERE WOD_2__Removed_Claim_Part__c IN:rcpIdList'; 
    //    if(shipmentId != null){//Do no fetch the claim shipment records of the same shipment Id
    //     claimShipmentQuery += ' AND WOD_2__Shipment_Detail__c !=:shipmentId';
    //    }
        List<WOD_2__Claim_Shipment__c> resultList = Database.query(String.escapeSingleQuotes(claimShipmentQuery));
       return resultList;
   }
    //method to fetch warehouse member details
    public static List<WOD_2__Warehouse_Member__c> fetchReceiverInspectorWarehouseMembers(String warehouseId, String role){
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Warehouse_Member__c','READ', new List<String>{'WOD_2__User__c','WOD_2__Warehouse__c','WOD_2__Role__c'});
        String userId = userInfo.getUserId();
        String warehouseMemberQuery = 'SELECT ID FROM WOD_2__Warehouse_Member__c WHERE WOD_2__Warehouse__c =:warehouseId AND WOD_2__User__c =:userId AND WOD_2__Role__c INCLUDES (\''+role+'\')';
        //Doing Access checks on above line
        List<WOD_2__Warehouse_Member__c> warehouseMemberList = Database.query(warehouseMemberQuery);
        return warehouseMemberList;
    }

    //Method to return RCP list for given claim ids
    public static List<WOD_2__Removed_Claim_Part__c> fetchRCPList(List<Id> claimIdList){
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Removed_Claim_Part__c','READ', new List<String>{'WOD_2__Claim__c','WOD_2__Claim__r.WOD_2__Account__c','WOD_2__Claim__r.WOD_2__BusinessCategory__c','WOD_2__Invoice_Quantity__c','WOD_2__Return_Location__c','WOD_2__Return_Location__r.Name','WOD_2__Return_Location__r.WOD_2__Zip_Code__c','WOD_2__Return_Location__r.WOD_2__Country__c','WOD_2__Return_Location__r.WOD_2__City__c','WOD_2__Return_Location__r.WOD_2__Address_Line_4__c','WOD_2__Return_Location__r.WOD_2__Address_Line_3__c','WOD_2__Return_Location__r.WOD_2__Address_Line_2__c','WOD_2__Return_Location__r.WOD_2__Address_Line_1__c','WOD_2__Part_Return_Requested__c'});
        //Doing Access checks on above line
        List<WOD_2__Removed_Claim_Part__c> rcpList = [SELECT Id, WOD_2__Claim__c, WOD_2__Invoice_Quantity__c, WOD_2__Return_Location__c,WOD_2__Return_Location__r.WOD_2__Zip_Code__c, 
                                                      WOD_2__Return_Location__r.WOD_2__Country__c,
                                               WOD_2__Part_Return_Requested__c, WOD_2__Return_Location__r.WOD_2__City__c,  WOD_2__Claim__r.WOD_2__Account__c, WOD_2__Return_Location__r.Name, 
                                               WOD_2__Claim__r.WOD_2__BusinessCategory__c,WOD_2__Return_Location__r.WOD_2__Address_Line_4__c,WOD_2__Return_Location__r.WOD_2__Address_Line_3__c,
                                               WOD_2__Return_Location__r.WOD_2__Address_Line_2__c,WOD_2__Return_Location__r.WOD_2__Address_Line_1__c FROM WOD_2__Removed_Claim_Part__c
                                               WHERE WOD_2__Claim__c IN:claimIdList 
                                               AND WOD_2__Part_Return_Requested__c = true 
                                               AND WOD_2__Return_Location__c != null];
        return rcpList;
    }

    
    //Method to return RCP list for given claim ids
    public static List<WOD_2__Removed_Claim_Part__c> fetchRCPListWithQueryFields(List<Id> claimIdList,List<String> fieldsInFieldSet){
        List<String> additionalFieldsList = new List<String>{'WOD_2__Claim__c','WOD_2__Claim__r.WOD_2__Account__c','WOD_2__Claim__r.WOD_2__BusinessCategory__c','WOD_2__Invoice_Quantity__c','WOD_2__Return_Location__c','WOD_2__Return_Location__r.Name','WOD_2__Return_Location__r.WOD_2__Zip_Code__c','WOD_2__Return_Location__r.WOD_2__Country__c','WOD_2__Return_Location__r.WOD_2__City__c','WOD_2__Return_Location__r.WOD_2__Address_Line_4__c','WOD_2__Return_Location__r.WOD_2__Address_Line_3__c','WOD_2__Return_Location__r.WOD_2__Address_Line_2__c','WOD_2__Return_Location__r.WOD_2__Address_Line_1__c','WOD_2__Part_Return_Requested__c'};
        Set<String> allFieldsSet = new Set<String>(additionalFieldsList);
        allFieldsSet.addAll(fieldsInFieldSet);
        List<String> finalFieldsList =new List<String>(allFieldsSet);
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Removed_Claim_Part__c','READ', finalFieldsList);
        String query = 'SELECT Id,'+String.join(finalFieldsList,',')+' FROM WOD_2__Removed_Claim_Part__c WHERE WOD_2__Claim__c IN:claimIdList AND WOD_2__Part_Return_Requested__c = true AND WOD_2__Return_Location__c != null';
        List<WOD_2__Removed_Claim_Part__c> rcpList = Database.query(query);
        return rcpList;
    }
    
    public static List<WOD_2__Removed_Claim_Part__c> getRCPRecords(List<Id> rcpIdList){
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Removed_Claim_Part__c','READ', new List<String>{'WOD_2__Claim__c','WOD_2__Claim__r.WOD_2__Account__c','WOD_2__Claim__r.WOD_2__BusinessCategory__c','WOD_2__Invoice_Quantity__c','WOD_2__Return_Location__c','WOD_2__Return_Location__r.Name','WOD_2__Return_Location__r.WOD_2__Zip_Code__c','WOD_2__Return_Location__r.WOD_2__Country__c','WOD_2__Return_Location__r.WOD_2__City__c','WOD_2__Return_Location__r.WOD_2__Address_Line_4__c','WOD_2__Return_Location__r.WOD_2__Address_Line_3__c','WOD_2__Return_Location__r.WOD_2__Address_Line_2__c','WOD_2__Return_Location__r.WOD_2__Address_Line_1__c','WOD_2__Part_Return_Requested__c'});
        //Doing Access checks on above line
        List<WOD_2__Removed_Claim_Part__c> rcpList = [SELECT Id, WOD_2__Claim__c, WOD_2__Invoice_Quantity__c, WOD_2__Return_Location__c,
                                               WOD_2__Return_Location__r.WOD_2__Zip_Code__c, WOD_2__Return_Location__r.WOD_2__Country__c,
                                               WOD_2__Return_Location__r.Name, WOD_2__Part_Return_Requested__c, WOD_2__Return_Location__r.WOD_2__City__c,  
                                               WOD_2__Claim__r.WOD_2__Account__c, WOD_2__Claim__r.WOD_2__BusinessCategory__c,WOD_2__Return_Location__r.WOD_2__Address_Line_4__c,
                                               WOD_2__Return_Location__r.WOD_2__Address_Line_3__c,WOD_2__Return_Location__r.WOD_2__Address_Line_2__c,WOD_2__Return_Location__r.WOD_2__Address_Line_1__c 
                                               FROM WOD_2__Removed_Claim_Part__c
                                               WHERE Id IN:rcpIdList 
                                               AND WOD_2__Part_Return_Requested__c = true 
                                               AND WOD_2__Return_Location__c != null];
        
        return rcpList;
    }

    public static List<WOD_2__Removed_Claim_Part__c> getRCPRecords(List<Id> claimIdList, List<String> fieldApiNameList){
        List<String> rcpFieldList = new List<String>{'WOD_2__Claim__c','WOD_2__Claim__r.WOD_2__Account__c','WOD_2__Claim__r.WOD_2__BusinessCategory__c','WOD_2__Invoice_Quantity__c','WOD_2__Return_Location__c','WOD_2__Return_Location__r.Name','WOD_2__Return_Location__r.WOD_2__Zip_Code__c','WOD_2__Return_Location__r.WOD_2__Country__c','WOD_2__Return_Location__r.WOD_2__City__c','WOD_2__Return_Location__r.WOD_2__Address_Line_4__c','WOD_2__Return_Location__r.WOD_2__Address_Line_3__c','WOD_2__Return_Location__r.WOD_2__Address_Line_2__c','WOD_2__Return_Location__r.WOD_2__Address_Line_1__c','WOD_2__Part_Return_Requested__c'};
        rcpFieldList.addAll(fieldApiNameList);
        Set<String> fieldApiNameSet = new Set<String>(rcpFieldList);
        List<WOD_2__Removed_Claim_Part__c> rcpList = new List<WOD_2__Removed_Claim_Part__c>();
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Removed_Claim_Part__c','READ', new List<String>(fieldApiNameSet));
        String queryString = 'SELECT Id, '+ String.join(new List<String>(fieldApiNameSet),',')+' FROM WOD_2__Removed_Claim_Part__c WHERE WOD_2__Claim__c IN:claimIdList AND WOD_2__Part_Return_Requested__c = true AND WOD_2__Return_Location__c != null';
        rcpList = Database.query(String.escapeSingleQuotes(queryString));
        return rcpList;
    }

    public static List<WOD_2__Claim__c> getClaimDetails(List<Id> claimIdList){
        List<WOD_2__Claim__c> claimList = new List<WOD_2__Claim__c>();
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Claim__c','READ', new List<String>{'WOD_2__BusinessCategory__c','WOD_2__Claim_Status__c'});
        claimList = [SELECT ID, WOD_2__BusinessCategory__c, WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE ID IN:claimIdList];
        return claimList; 
    }

    public static List<WOD_2__Shipment_Detail__c> fetchShipmentList(Set<Id> warehouseIdSet, Id accountId, Id buId, Map<String, String> bccsNameValueMap){
        List<WOD_2__Shipment_Detail__c> shipmentList = new List<WOD_2__Shipment_Detail__c>();
        List<String> statusList = new List<String>();
        if(String.isNotBlank(bccsNameValueMap.get('SHP_CS_Shipment_Include_Status'))){
            statusList = bccsNameValueMap.get('SHP_CS_Shipment_Include_Status').split(',');
        }
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','READ', new List<String>{'Name','WOD_2__Return_Location__c','WOD_2__Dealer_Account__c','WOD_2__Business_Unit__c'});
        shipmentList = [SELECT Id, Name, WOD_2__Return_Location__c, WOD_2__Dealer_Account__c FROM WOD_2__Shipment_Detail__c WHERE WOD_2__Return_Location__c IN :warehouseIdSet AND WOD_2__Dealer_Account__c =:accountId AND WOD_2__Business_Unit__c =:buId AND WOD_2__Status__c IN:statusList LIMIT 10];
        return shipmentList;
    }

    public static List<WOD_2__Shipment_Detail__c> fetchShipmentList(Map<String, Object> parameterMap){
        List<WOD_2__Shipment_Detail__c> shipmentList = new List<WOD_2__Shipment_Detail__c>();
        List<String> statusList = new List<String>();
        ATI_SHP_ShipmentDataService.checkForAccess('WOD_2__Shipment_Detail__c','READ', new List<String>{'Name','WOD_2__Return_Location__c','WOD_2__Dealer_Account__c','WOD_2__Business_Unit__c'});
        Id accountId = (Id) parameterMap.get('accountId');
        Id buId = (Id) parameterMap.get('buId');
        Set<Id> warehouseIdSet = (set<Id>) parameterMap.get('warehouseIdSet');
        String statusString = (String)parameterMap.get('status');
        if(String.isNotBlank(statusString)){
            statusList = statusString.split(',');
        }
        String nameFilter = (String)parameterMap.get('name');
        shipmentList = [SELECT ID, Name, WOD_2__Return_Location__c, WOD_2__Dealer_Account__c FROM WOD_2__Shipment_Detail__c WHERE WOD_2__Return_Location__c IN :warehouseIdSet 
                        AND WOD_2__Dealer_Account__c =:accountId AND WOD_2__Business_Unit__c =:buId AND WOD_2__Status__c IN:statusList 
                        AND Name =:nameFilter LIMIT 10];
        return shipmentList;
    }

//Method to check all kinds of access like READ, EDIT, DELETE and throws error if required permissions do not exist
   public static void checkForAccess(String objectName, String accessCheckType, List<String> fieldList){
       
       If(fieldList != null && !fieldList.isEmpty()){
           Set<String> fieldSet= new Set<String>(fieldList);
           fieldSet.remove('id');
           fieldSet.remove('Id');
           if(fieldSet.contains('WOD_2__Removed_Claim_Part__r')){
               fieldSet.remove('WOD_2__Removed_Claim_Part__r');
           }
           fieldList = new List<String>(fieldSet);
           
           //fieldList = new List<String>(new Set<String(fieldList).remove('Id'));
       }
       ATI_Utils.NoAccessObjectFieldWrapper noAccessWrapper = new ATI_Utils.NoAccessObjectFieldWrapper();
       String errorMessage = '';
       switch on  accessCheckType {
           when  'CREATE'{
               noAccessWrapper = ATI_Utils.fetchCreateAccess(objectName, fieldList);          
           }
           when 'UPDATE' {
               noAccessWrapper = ATI_Utils.fetchUpdateAccess(objectName, fieldList);
           }
           when 'READ'{
               noAccessWrapper = ATI_Utils.fetchReadAccess(objectName, fieldList);
           }
           when 'DELETE'{
               /*if( !ATI_Utils.checkObjectDeleteAccess(objectName)){
                   errorMessage = System.Label.ATI_Log_Insufficient_access + ' for Object(s) '+objectName+' for Delete operation';
                   throw new TWoDException(errorMessage);
               }*/
           }
       } 
       if( accessCheckType.toUpperCase() != 'DELETE'){
           if(noAccessWrapper != null && (noAccessWrapper.noAccessObjectList.size() > 0 || noAccessWrapper.noAccessFieldList.size() > 0)){
               errorMessage = System.Label.ATI_Log_Insufficient_access + ' for Object(s) '+objectName;
               if(noAccessWrapper.noAccessFieldList.size() > 0){
                   errorMessage += ' for Fields '+String.join(noAccessWrapper.noAccessFieldList, ',') + ' For operation: '+accessCheckType;
               }
               throw new TWoDException(errorMessage); 
           }
       }
   } 
}