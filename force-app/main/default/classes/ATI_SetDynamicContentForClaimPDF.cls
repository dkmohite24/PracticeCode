/*
	Class Name	: 	ATI_SetDynamicContentForClaimPDF
	Description	:	Extending the TWOD's TWoDGenericVirtualMethods class 
					Providing the Transmission details, customer info, vehicle info, turn around , replacement info details to claim print pdf.
					This class should be selected in BCCS configuration : Claim -> Claim Print -> CLMPDF_DynamicTabContentProviderClass
*/
global class ATI_SetDynamicContentForClaimPDF extends WOD_2.TWoDGenericVirtualMethods{
    global Override WOD_2.ResponseWrapper getDynamicContentForPdf(Map<String,String> inputMap){
        System.debug('inputMap----->'+inputMap);
        Id claimId = inputMap.get('recordId');
        List<PdfDynamicSectionData> wrapperLst = new List<PdfDynamicSectionData>();
        
        if(claimId != NULL){
            Map<String,String> transmissionDetailsFSMap = getFielSetMap('WOD_2__Claim__c','ATI_PDF_Transmission_Details_FS');
            Map<String,String> replacementDetailsFSMap = getFielSetMap('WOD_2__Claim__c','ATI_PDF_Replacement_Details_FS');
            Map<String,String> turnAroundDetailsFSMap = getFielSetMap('WOD_2__Claim__c','ATI_TURN_AROUND_FIELDSET');
            String fieldsToJoinStr = String.join(new List<String>(transmissionDetailsFSMap.keySet()), ',')+ ',' 
                					+ String.join(new List<String>(replacementDetailsFSMap.keySet()), ',') +','
                					+ String.join(new List<String>(turnAroundDetailsFSMap.keySet()), ',');
            //ALSN-133 ATI_Replaced_Inventory__c data query
            //ALSN-157 added ATI_VIN__c
            String query = 'SELECT Id,ATI_VIN__c,ATI_Replaced_Inventory__c,WOD_2__Inventory__r.WOD_2__Customer__c,WOD_2__Inventory__c,WOD_2__Claim_Type__c, ' + fieldsToJoinStr + ' FROM WOD_2__Claim__c WHERE Id=:claimId';
            System.debug('query------>'+query);
            
            List<sObject> dataLst = Database.query(query);
            if(dataLst[0].get('WOD_2__Claim_Type__c') != 'Claim Template'){
                //transmission details
                wrapperLst.add(getPDFSectionDetails(dataLst,transmissionDetailsFSMap,System.Label.ATI_Transmission_Registration_Details,'FormView'));
                //customer
                wrapperLst.add(getCustomerInfoDetails(dataLst));
                //Vehicle Information
                wrapperLst.add(getVehicleInfoDetails(dataLst));
                //replacement information
                wrapperLst.add(getPDFSectionDetails(dataLst,replacementDetailsFSMap,System.Label.ATI_Replacement_Section_Header,'FormView'));
                //turn around details
                wrapperLst.add(getPDFSectionDetails(dataLst,turnAroundDetailsFSMap,System.Label.ATI_Claim_TurnaroundHeader,'FormView'));
                //diagnostic codes
                wrapperLst.add(getDiagnosticDetails(claimId));
            }else{
                return new WOD_2.ResponseWrapper('',true,'');
            }
        }
        System.debug('wrapperLst----->'+JSON.serialize(wrapperLst));
        return new WOD_2.ResponseWrapper(JSON.serialize(wrapperLst),true,'');
    }
    
    public static Map<String,String> getFielSetMap(String objectName,String fieldSetName){
        Map<String,String> fielLabelToFieldPathMap = new Map<String,String>();
            
        Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            String fieldPath = String.valueOf(eachFieldSetMember.getFieldPath());
            if(dataType == 'reference'){
                if(fieldPath.indexOf('__c') != -1){
                    fieldPath=fieldPath.substring(0, fieldPath.lastIndexOf('__c')) + '__r.Name';
                }else{
                    fieldPath=fieldPath.substring(0, fieldPath.lastIndexOf('Id')) + '.Name';
                }
            }
            fielLabelToFieldPathMap.put(fieldPath,String.valueOf(eachFieldSetMember.getLabel()));
        }
        return fielLabelToFieldPathMap;
    }
    
    private PdfDynamicSectionData getPDFSectionDetails(List<SObject> sobjLst,Map<String,String> fielLabelToFieldPathMap,String sectionLabel,
                                                         String layoutType){
        PdfDynamicSectionData transDetailWrapperObj = new PdfDynamicSectionData();
        transDetailWrapperObj.sectionLabel = sectionLabel;
        transDetailWrapperObj.layoutType = layoutType;
        
        Map<String,String> fielValuesMap = new Map<String,String>();
        transDetailWrapperObj.fields = new List<String>(fielLabelToFieldPathMap.values());
        List<Map<String,String>> tableData = new List<Map<String,String>>();                                                     
        for(SObject recordObj : sobjLst){
            Map<String,String> fielValuesDataTableMap = new Map<String,String>();
            for(String fieldPathStr : fielLabelToFieldPathMap.keySet()){
                String value = '';
                Integer numberOfParentLevel = fieldPathStr.countMatches('.');
                if(!fieldPathStr.contains('.')){
                    value = String.valueOf(recordObj.get(fieldPathStr));
                }else{
                    SObject parentObj = recordObj;
                    String fieldPathStrTemp = fieldPathStr;
                    Boolean parentObjAssigned = false;
                    for(Integer i=1;i<=numberOfParentLevel;i++){
                        if(i == numberOfParentLevel){
                            parentObj = parentObj.getSObject(fieldPathStrTemp.substring(0,fieldPathStrTemp.indexOf('.')));
                            if(parentObj != NULL){
                                value = String.valueOf(parentObj.get(fieldPathStrTemp.substring(fieldPathStrTemp.indexOf('.')+1,fieldPathStrTemp.length())));
                            }
                        }else{  
                            parentObj = parentObj.getSObject(fieldPathStrTemp.substring(0,fieldPathStrTemp.indexOf('.')));
                            fieldPathStrTemp = fieldPathStrTemp.substring(fieldPathStrTemp.indexOf('.')+1,fieldPathStrTemp.length());
                        }
                    }
                }
                value = (value == NULL) ? '' : value;
                fielValuesMap.put(fielLabelToFieldPathMap.get(fieldPathStr),value);
                fielValuesDataTableMap.put(fielLabelToFieldPathMap.get(fieldPathStr),value);
            }
            tableData.add(fielValuesDataTableMap);
        }
        if(layoutType.equalsIgnoreCase('FormView')){
        	transDetailWrapperObj.fieldValues = fielValuesMap;                                                        
        }else if(layoutType.equalsIgnoreCase('TableView')){
            transDetailWrapperObj.tableData = tableData;
        }
        return transDetailWrapperObj;
    }
    
    private PdfDynamicSectionData getCustomerInfoDetails(List<SObject> dataLst){
        Id CustomerId = String.valueOf(dataLst[0].getSObject('WOD_2__Inventory__r').get('WOD_2__Customer__c'));
        Map<String,String> customerDetailsFSMap = getFielSetMap('Account','WOD_2__WR_Customer_DetailPageFieldset');
        String queryCustomer = 'SELECT Id, ' + String.join(new List<String>(customerDetailsFSMap.keySet()), ',') + ' FROM Account WHERE Id=:CustomerId';
        System.debug('queryCustomer------>'+queryCustomer);
        List<sObject> customerDataLst = Database.query(queryCustomer);
        return getPDFSectionDetails(customerDataLst,customerDetailsFSMap,System.Label.ConsumerInformation,'FormView');
    }
    
    private PdfDynamicSectionData getVehicleInfoDetails(List<SObject> dataLst){
        //ALSN-133 Replaced Inventory Check --- changes obsolete from ALSN-157
        /*
        Id vinMapperId;
        if(dataLst[0].get('ATI_Replaced_Inventory__c') != null &&  dataLst[0].get('ATI_Replaced_Inventory__c') != ''){
            vinMapperId = String.valueOf(dataLst[0].get('ATI_Replaced_Inventory__c'));   
        }else{
            vinMapperId = String.valueOf(dataLst[0].get('WOD_2__Inventory__c'));
        }
		*/
        //ALSN-157 Use ATI_VIN__c to query the vehicle information
        String vinName = String.valueOf(dataLst[0].get('ATI_VIN__c'));
        String queryVINMapper;
        List<sObject> vinInfoLst = new List<sObject>();
        //ASLN-157 query information directly from Vehicle information.
        //Map<String,String> vinInfoFSMap = getFielSetMap('ATI_VIN_Transmission_Mapper__c','ATI_PDF_Vehicle_Information_FS');
        Map<String,String> vinInfoFSMap = getFielSetMap('ATI_Vehicle_Information__c','ATI_PDF_Vehicle_Information_Details_FS');
        if(vinName != null){
            queryVINMapper = 'SELECT Id, ' + String.join(new List<String>(vinInfoFSMap.keySet()), ',') + ' FROM ATI_Vehicle_Information__c WHERE Name=:vinName ORDER BY LastModifiedDate DESC LIMIT 1';
            System.debug('queryVINMapper------>'+queryVINMapper);
            vinInfoLst = Database.query(queryVINMapper);
        }
        //ALSN-157 if information is found it will be shown through FormView, if not will show a blank TableView
        if(vinInfoLst.size() != 0){
            return getPDFSectionDetails(vinInfoLst,vinInfoFSMap,System.Label.ATI_VehicleInformation,'FormView');
        }else{
            return getPDFSectionDetails(vinInfoLst,vinInfoFSMap,System.Label.ATI_VehicleInformation,'TableView');
        }
    }
    
    private PdfDynamicSectionData getDiagnosticDetails(Id claimId){
        Map<String,String> diagnosticFSMap = getFielSetMap('ATI_Diagnostic_Code__c','ATI_PDF_Diagnostic_Info_FS');
        String queryDiagnosticCodes = 'SELECT Id, ' + String.join(new List<String>(diagnosticFSMap.keySet()), ',') + ' FROM ATI_Diagnostic_Code__c WHERE Claim__c=:claimId';
        System.debug('queryDiagnosticCodes------>'+queryDiagnosticCodes);
        List<sObject> DiagnosticCodesLst = Database.query(queryDiagnosticCodes);
        return getPDFSectionDetails(DiagnosticCodesLst,diagnosticFSMap,System.Label.CLAIM_DIAGNOSTIC,'TableView');
    }
    
    public class PdfDynamicSectionData{
        public String sectionLabel{get;set;}
        public String layoutType{get;set;} // allowed values - FormView, TableView
        public Map<String,String> fieldValues{get;set;} // even if data attribute value is null, all the fields list should be mapped at least with empty string
        public List<String> fields{get;set;}
        public List<Map<String,String>> tableData{get;set;} // even if data attribute value is null, all the fields list should be mapped at least with empty string
    }
}