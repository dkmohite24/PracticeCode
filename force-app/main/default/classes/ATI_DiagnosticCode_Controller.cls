/* Name: ATI_DiagnosticCode_Controller
Description : Class for Diagnostic Code component 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             		DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         01/03/2021         INITIAL DEVELOPMENT            20517                  
*/
public with sharing class ATI_DiagnosticCode_Controller {
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper saveDiagnosticCodes(List<String> diagnosticCodes, String claimId){
        try {
            system.debug('diagnosticCodes%%'+diagnosticCodes);
            List<ATI_Diagnostic_Code__c> diagnosticCodeList = new List<ATI_Diagnostic_Code__c>();
            List<ATI_Diagnostic_Code__c> deleteDiagnosticCodeList = new List<ATI_Diagnostic_Code__c>();
            Set<String> diagnosticCodeSet = new Set<String>();
            Map<String,String> diagnosticCodeIdWcMap = new Map<String,String>();
            Integer count=0;
            Boolean isSaveRecord;
            List<ATI_Diagnostic_Code__c> existingDiagnosticCodeList =[Select Id,Warranty_Code__c From ATI_Diagnostic_Code__c Where Claim__c=: claimId limit 50000];
            if(existingDiagnosticCodeList.size()>0 && existingDiagnosticCodeList!= null){
                for(ATI_Diagnostic_Code__c diag: existingDiagnosticCodeList){
                    diagnosticCodeIdWcMap.put(diag.Warranty_Code__c,diag.Id);
                }
            }
            
            if(diagnosticCodes.size()>0){
                for(String idValue: diagnosticCodes){
                    count= count+1;
                    diagnosticCodeSet.add(idValue);
                    if(diagnosticCodeSet.size()<count){
                        isSaveRecord= false;
                        throw new classException(Label.ATI_Duplicate_Diagnostic_Code);
                    }else{
                        isSaveRecord= true;
                    }
                }
                if(isSaveRecord){
                    for(String idValue: diagnosticCodeSet){
                        if(diagnosticCodeIdWcMap== null || !diagnosticCodeIdWcMap.containsKey(idValue)){
                        	ATI_Diagnostic_Code__c diagnosticCd = new ATI_Diagnostic_Code__c(Warranty_Code__c=idValue,
                                                                                        Claim__c= claimId);
                        	diagnosticCodeList.add(diagnosticCd);
                        }
                    }
                    for(String wCode:diagnosticCodeIdWcMap.keyset()){
                        system.debug('wCode'+wCode);
                        if(!diagnosticCodeSet.contains(wCode)){
                            system.debug('diagnosticCodeIdWcMap.get(wCode)**'+diagnosticCodeIdWcMap.get(wCode));
                            ATI_Diagnostic_Code__c codeObj= new ATI_Diagnostic_Code__c(Id=diagnosticCodeIdWcMap.get(wCode));
                            deleteDiagnosticCodeList.add(codeObj);
                        }
                    }
                    if(deleteDiagnosticCodeList.size()>0){
                        Database.delete(deleteDiagnosticCodeList,false);
                    }
                    if(diagnosticCodeList.size()>0){
                        Database.insert(diagnosticCodeList, false);
                    }
                }
            }else{
                Database.delete(existingDiagnosticCodeList,false);
            }
            return new WOD_2.ResponseWrapper('',true,'');
        } catch (Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper deleteSObjects(String recordId){
        try {
             ATI_Diagnostic_Code__c diagnosticCd =[Select Id From ATI_Diagnostic_Code__c Where Warranty_Code__c=:recordId];
            WOD_2.ResponseWrapper response= ATI_ExtendedWPController.deleteEWPRecords(diagnosticCd);
            return response;
        } catch (Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = false)
    public static WOD_2.ResponseWrapper getDiagnosticCodes(String objectName,List<String> fields,String claimId) { 
        try{
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fields);
            if(sObjReadAccessCheck.noAccessObjectList.size() == 0 && sObjReadAccessCheck.noAccessFieldList.size() == 0){
                String query = 'SELECT '+String.join(fields,',')+' FROM ' + objectName + ' WHERE Claim__c=\'' + claimId + '\'';
                System.debug('query@@@@@@----->'+query);
                List<sObject> sObjectLst = Database.query(query);
                return new WOD_2.ResponseWrapper(JSON.serialize(sObjectLst),true,'');
            }else{
                return new WOD_2.ResponseWrapper('[]',false,'Insufficient Access '+sObjReadAccessCheck);
            }
        }catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
    
    public class classException extends Exception {
        
    }
        
    @AuraEnabled
    public static WOD_2.ResponseWrapper getAllowedClaimStatusMetadata(){
        try {
            WOD_2.ResponseWrapper response= new WOD_2.ResponseWrapper();
            WOD_2__Configuration_Setting__mdt confSettingMdtObj = WOD_2__Configuration_Setting__mdt.getInstance('ATI_Allowed_Claim_Statuses_To_Edit_Claim');
            if(confSettingMdtObj.WOD_2__Configuration_Value__c != NULL){
                response.status = true;
                response.data = confSettingMdtObj.WOD_2__Configuration_Value__c;
            }
            return response;
        } catch (Exception e) {
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }  
    
    @AuraEnabled
    public static User getUserDetails(String userId) {
        return  [Select Id , Name ,Profile.Name from User where Id =:userId];
    }
}