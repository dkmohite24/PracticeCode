/*
	Class Name	:	ATI_CustomListViewController
	Description	:	Controller for custom list view component 
	Component 	:	aTI_CustomListViewComponent -> LWC
	Author		: 	TAVNT (RSG)
*/
public with sharing class ATI_CustomListViewController {
    //To hold the table hearders 
    public static List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
    //Field to be queried - fetched from fieldset
    public static List<String> lstFieldsToQuery = new List<String>();
    //sorting field
    public static String sortingField = '';
    //searchKeyFilter build on search key
    public static String searchKeyFilter = '';

    @AuraEnabled
    public static List<ATI_Custom_List_Views__mdt> getListViews(String objectName){
        List<ATI_Custom_List_Views__mdt> customLstViewsMdtLst = new List<ATI_Custom_List_Views__mdt>();
        for(ATI_Custom_List_Views__mdt mdtObj : ATI_Custom_List_Views__mdt.getall().values()){
            if(mdtObj.ATI_Object_Name__c != NULL && mdtObj.ATI_Object_Name__c == objectName){
                customLstViewsMdtLst.add(mdtObj);
            }
        }
        return customLstViewsMdtLst;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper getListViewOnChange(String objectName,String metadataRecord,Integer limitSize, Integer offSet,
                                                            String existingIdsSet,String sortedBy,String sortDirection,String searchKey)
    {
        Type idArrType = Type.forName('List<string>');
        List<string> existingIdsLst = new List<string>();
        if(existingIdsSet != ''){
            existingIdsLst = (List<string>) JSON.deserialize(existingIdsSet, idArrType);
        }                                                        
        ATI_Custom_List_Views__mdt metadataObj = (ATI_Custom_List_Views__mdt)JSON.deserialize(metadataRecord, ATI_Custom_List_Views__mdt.class);
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper();
        DataTableResponse dataTableresponse = new DataTableResponse();
        try {
            dataTableresponse = getTableData(metadataObj,objectName,dataTableresponse,limitSize,offSet,existingIdsLst,
                                             sortedBy,sortDirection,searchKey);
            response.status= true; 
            response.data=JSON.serialize(dataTableResponse);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static WOD_2.ResponseWrapper getListViewDataOnLoad(String objectName){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper();
        DataTableResponse dataTableresponse = new DataTableResponse();
        try {
            List<listViewWrapper> listViewWrapperLst = new List<listViewWrapper>();
            List<ATI_Custom_List_Views__mdt> customLstViewsMdtLst = new List<ATI_Custom_List_Views__mdt>();
            for(ATI_Custom_List_Views__mdt mdtObj : [SELECT Id,MasterLabel,ATI_Object_Name__c,ATI_Active__c,ATI_Fieldset__c,DeveloperName,
                                                     		ATI_Filter_Criteria__c,ATI_Priority__c
                                                     FROM ATI_Custom_List_Views__mdt WHERE ATI_Object_Name__c= :objectName
                                                     AND ATI_Active__c=true ORDER BY ATI_Priority__c ASC])
                {
                    customLstViewsMdtLst.add(mdtObj);
                    listViewWrapperLst.add(new listViewWrapper(mdtObj.MasterLabel,mdtObj.MasterLabel));
                }
            if(!customLstViewsMdtLst.isEmpty()){
                dataTableresponse.customLstViewsMdtLst = customLstViewsMdtLst;
                dataTableresponse.listViewNamesLst = listViewWrapperLst;
                dataTableresponse = getTableData(customLstViewsMdtLst[0],objectName,dataTableresponse,25,0,new List<String>(),
                                                 'Name','ASC','');
                response.status= true;
                response.data=JSON.serialize(dataTableResponse);
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void getTableColumns(String fieldSetName,String objectName,String sortedBy,String searchKey){
        //Get the fields from FieldSet
        Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        if(searchKey != '' && searchKey != NULL){
            searchKeyFilter = ' AND (';
        }
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            String fieldPath = String.valueOf(eachFieldSetMember.getFieldPath());
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            if(dataType == 'reference'){
                if(fieldPath.indexOf('__c') != -1){
                    fieldPath=fieldPath.substring(0, fieldPath.lastIndexOf('__c')) + '__r.Name';
                }else{
                    fieldPath=fieldPath.substring(0, fieldPath.lastIndexOf('Id')) + '.Name';
                }
                
                DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                    fieldPath,String.valueOf(eachFieldSetMember.getType()).toLowerCase());
                //lstDataColumns.add(datacolumns);
                lstFieldsToQuery.add(fieldPath);
            }
            if(dataType != 'datetime' && dataType != 'date'){
                //set sortedby field 
                if(String.valueOf(eachFieldSetMember.getFieldPath()) == sortedBy){
                    sortingField = fieldPath;
                }
                if(searchKeyFilter==' AND (' && searchKey != '' && searchKey != NULL){
                    searchKeyFilter = searchKeyFilter + fieldPath+ ' LIKE \'%'+searchKey+'%\'';
                }else if(searchKey != '' && searchKey != NULL){
                    searchKeyFilter = searchKeyFilter + ' OR '+ fieldPath+ ' LIKE \'%'+searchKey+'%\'';
                }
            }
            
            //Create a wrapper instance and store label, fieldname and type.
            DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                String.valueOf(eachFieldSetMember.getType()).toLowerCase() );
			lstDataColumns.add(datacolumns);
            lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
            System.debug('lstFieldsToQuery-------->'+lstFieldsToQuery);
        }
        if(searchKeyFilter != ''){
            searchKeyFilter = searchKeyFilter+')';
        }
    }

    public static DataTableResponse getTableData(ATI_Custom_List_Views__mdt customLstViewsMdtObj,String objectName,DataTableResponse dataTableresponse,
                                                 Integer limitSize, Integer offSet,List<String> existingIdsSet,String sortedBy,String sortDirection,String searchKey)
    {
        getTableColumns(customLstViewsMdtObj.ATI_FieldSet__c,objectName,sortedBy,searchKey);
        if(sortedBy.toLowerCase() == 'recordlink'){
            sortedBy = 'Name';
        }else if(sortingField!=''){
            sortedBy = sortingField;
        }
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(!lstDataColumns.isEmpty()){            
            Set<Id> accIdsSet = new Set<Id>();
            User userObj = [SELECT Id,AccountId FROM User WHERE Id=:UserInfo.getUserId()];
            accIdsSet.add(userObj.AccountId);
            Map<Id,Account> accsMap = new Map<Id,Account>([SELECT Id FROM Account WHERE ParentId =:userObj.AccountId]);
            if(!accsMap.isEmpty()){
                accIdsSet.addAll(accsMap.keySet());
            }
            
            dataTableresponse.lstDataTableColumns = lstDataColumns;
            String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM '+objectName;
            
            if(objectName=='WOD_2__Claim__c' || objectName=='WOD_2__Inventory__c'){
				query = query+' WHERE WOD_2__Account__c IN :accIdsSet';
            }
            
            if((objectName=='WOD_2__Claim__c' || objectName=='WOD_2__Inventory__c') && customLstViewsMdtObj.ATI_Filter_Criteria__c != NULL){ 
                query = query+' AND '+customLstViewsMdtObj.ATI_Filter_Criteria__c;
                query = (customLstViewsMdtObj.DeveloperName == 'Draft_Claims_CreatedBy_Me') ? query + ' AND CreatedById=\''+ UserInfo.getUserId()+'\'' : query;
            }else if(customLstViewsMdtObj.ATI_Filter_Criteria__c != NULL){
                query = query+' WHERE '+customLstViewsMdtObj.ATI_Filter_Criteria__c;
            }
            if(!existingIdsSet.isEmpty()){
                //query = query+' AND Id NOT IN :existingIdsSet';
            }
            if(searchKeyFilter != ''){
                query = query+searchKeyFilter;
            }
            query = query+' ORDER BY '+sortedBy;
            if(sortDirection=='asc'){
                query = query+' '+sortDirection+' LIMIT :limitSize OFFSET :offset';
            }else{
                query = query+' '+sortDirection+' NULLS LAST LIMIT :limitSize OFFSET :offset';
            }
            System.debug('query------------->'+query);
            dataTableresponse.lstDataTableData = Database.query(query);
            System.debug('response.lstDataTableData------------->'+dataTableresponse.lstDataTableData);
        } 
        return dataTableresponse;
    }

    //Wrapper class to hold Columns with headers
    public class listViewWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String value {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public listViewWrapper(String label, String option){
            this.label = label;
            this.value = option;
        }
    }
    
    //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;            
        }
    }
    
    //Wrapper calss to hold response - This response is used in the lightning:datatable component
    public class DataTableResponse {
        @AuraEnabled
        public List<ATI_Custom_List_Views__mdt> customLstViewsMdtLst {get;set;}
        @AuraEnabled
        public List<listViewWrapper> listViewNamesLst {get;set;}
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
        }
    }
}