/* Class Name: PRPC_surveyFormulaSetupClass
* Description: 
* Created by: Debiprasad
*/
public class PRPC_surveyFormulaSetupClass {
    
    @AuraEnabled
    public static Wrapper getALLPickListValues(){
        List<String> pickListValuesList= new List<String>();
        List<String> yearField= new List<String>();
        list<PRPMD_All_Survey_Question__mdt> QuestionsList = new list<PRPMD_All_Survey_Question__mdt>();
        list<Survey_Formula_Setup__c> SurveyRecList = new list<Survey_Formula_Setup__c>();
        
        QuestionsList = [select Question_Value__c ,	Question_Number__c,Region__c from PRPMD_All_Survey_Question__mdt];
        SurveyRecList = [select id,Owner.name,Survey_Name__c,Percentage__c,Survey_Type__c,Region_Type__c,CreatedDate,Year__c from Survey_Formula_Setup__c order by CreatedDate desc];
        
        Schema.DescribeFieldResult fieldResult = Survey_Formula_Setup__c.Question_Number__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        Integer startYear = Date.Today().Year() +2;
        for(Integer i= startYear; i>=2010; i--){
                yearField.add(string.valueOf(i));
        }
       
        Wrapper objWrapper = new Wrapper();
        objWrapper.SurveyRecList = SurveyRecList;
        objWrapper.pickListValuesList = pickListValuesList;
        objWrapper.QuestionsList = QuestionsList;
        objWrapper.yearField = yearField;
        return objWrapper;
    }
    @AuraEnabled
    public static string insertSurveyRecord(string allRecVal,string SurveyType,string RegionType,string SurYear){
        system.debug('allRecVal: '+allRecVal);
        list<Object> AllRecInsert = (list<Object>) JSON.deserializeUntyped(allRecVal);
        Map<String, Object> recMap = new  Map<String, Object>();
        List<sObject> allRecordList=new List<sObject>();
        list<Survey_Formula_Setup__c> insertSurveyRec = new list<Survey_Formula_Setup__c>();
        
       for(object obj : AllRecInsert) {
            sObject rec = Schema.getGlobalDescribe().get('Survey_Formula_Setup__c').newSObject();
          recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
           for(string surveyApi : recMap.keyset()){
               rec.put('Question_Number__c', string.valueof(recMap.get('Question')));
               rec.put('Percentage__c', Double.valueof(recMap.get('Percentage')));
               rec.put('Region_Type__c', RegionType);
               rec.put('Survey_Type__c', SurveyType);
               rec.put('Survey_Name__c', string.valueof(recMap.get('Question')) + 'value');
               rec.put('Year__c', SurYear);
               
           }
           //system.debug('recMap: '+recMap);
           allRecordList.add(rec);
           
       }
        system.debug('allRecordList: '+allRecordList);
        database.insert(allRecordList);
        
        return 'success';
    }
    @AuraEnabled
    public static void DeleteSurveyRecord(string RecordId){
        //system.debug('RecordId: '+RecordId);
        list<Survey_Formula_Setup__c> DelRec = new list<Survey_Formula_Setup__c>();
        DelRec = [select id from Survey_Formula_Setup__c where id=:RecordId];
        delete DelRec;
    }
    
    public class Wrapper{
        @AuraEnabled public list<Survey_Formula_Setup__c> SurveyRecList{get;set;}
        @AuraEnabled public List<String> pickListValuesList{get;set;}
        @AuraEnabled public list<PRPMD_All_Survey_Question__mdt> QuestionsList{get;set;}
        @AuraEnabled public list<string> yearField{get;set;}
    }
}