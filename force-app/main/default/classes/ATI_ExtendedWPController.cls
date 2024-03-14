/* Name: ATI_ExtendedWPController
Description : This class is used to insert Extended Warranty Pricing data
Author : Tavant(TY)
History:
VERSION     AUTHOR                 DATE                   DETAIL               UserStory/Req#
1.0 -     Tavant(TY)             02/12/2020          INITIAL DEVELOPMENT            20517 
*/
public with sharing class ATI_ExtendedWPController {
    
	@AuraEnabled
    public static WOD_2.ResponseWrapper getPolicyRecord(String recordId){
        try{
            String objectName = 'WOD_2__Policy_Definition__c';
            List<String> fields = new List<String>{'WOD_2__Type__c'};
            String type = 'Extended';
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fields);
            if(sObjReadAccessCheck.noAccessObjectList.size() == 0 && sObjReadAccessCheck.noAccessFieldList.size() == 0){
                String query = 'SELECT Id,'+String.join(fields,',')+' FROM ' + objectName + ' WHERE WOD_2__Type__c=:type AND Id=\'' + recordId + '\'';
                List<sObject> sObjectLst = Database.query(query);
                return new WOD_2.ResponseWrapper(JSON.serialize(sObjectLst),true,'');
            }else{
                return new WOD_2.ResponseWrapper('[]',false,'(Policy Definition) '+Label.ATI_Log_Insufficient_access);
            }
        }catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
	
    @AuraEnabled
    public static WOD_2.ResponseWrapper getExtendedWPRecords(String objectName,List<String> fields,String recordId) { 
        try{
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fields);
            if(sObjReadAccessCheck.noAccessObjectList.size() == 0 && sObjReadAccessCheck.noAccessFieldList.size() == 0){
                String query = 'SELECT '+String.join(fields,',')+' FROM ' + objectName + ' WHERE ATI_Policy_Definition__c=\'' + recordId + '\' ORDER BY CreatedDate Desc';
                List<sObject> sObjectLst = Database.query(query);
                return new WOD_2.ResponseWrapper(JSON.serialize(sObjectLst),true,'');
            }else{
                return new WOD_2.ResponseWrapper('[]',false,'(Extended Warranty Pricing) '+Label.ATI_Log_Insufficient_access);
            }
        }catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }

    @AuraEnabled
    public static WOD_2.ResponseWrapper deleteEWPRecords(sObject record){
        try {
            Database.delete(record);
            return new WOD_2.ResponseWrapper('',true,'');
        } catch (Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
}