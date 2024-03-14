/* Name: ATI_SectionComponentController
Description : This class is used in ATI_CustomSectionComponent ,to fetch sections for records to show in detail page
Author : TAVANT
History:
Test Class: ATI_SectionComponentControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public without sharing class ATI_SectionComponentController {
	/*
		Method Name	:	getSectionData
		Params		:	sectionMetadataConfigName , recordId
	*/
	@AuraEnabled
	public static WOD_2.ResponseWrapper getSectionData(String sectionMetadataConfigName,String recordId) {
		System.debug('recordId--'+recordId);
		WOD_2.ResponseWrapper responseWrapperObject = new WOD_2.ResponseWrapper();
		String objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
		SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
		List<SectionComponentFieldWrapper> sectionComponentFieldsWrapperList = new List<SectionComponentFieldWrapper>();
		SectionComponentWrapper sectionComponentWrapperObject = new SectionComponentWrapper();
		try{
			// idString is a local variable of QueryRunWithSharing.runQueryIdString(-,-) method which help to append in SOQL query dynamically
			//String querySectionConfiguration='SELECT FieldsetName__c,Section_Name__c,(Select HyperLinkFieldPath__c,RedirectUrl__c from HyperLinkConfigurations__r)  FROM SectionConfiguration__mdt WHERE DeveloperName = : idString';
			//List<SectionConfiguration__mdt> sectionConfigList = (List<SectionConfiguration__mdt>)QueryRunWithSharing.runQueryIdString(querySectionConfiguration,sectionMetadataConfigName);
			List<ATI_SectionConfiguration__mdt> sectionConfigList = [SELECT ATI_FieldsetName__c,ATI_Section_Name__c,(Select HyperLinkFieldPath__c,RedirectUrl__c from HyperLinkConfigurations__r)  FROM ATI_SectionConfiguration__mdt WHERE DeveloperName = :sectionMetadataConfigName];
			if(sectionConfigList != null && sectionConfigList.size() == 1) {
				sectionComponentWrapperObject.sectionConfiguration = sectionConfigList.get(0);
				String strFieldNameonBU = sectionConfigList.get(0).ATI_FieldsetName__c;
				System.debug('strFieldNameonBU::::'+strFieldNameonBU);
				User usrInfo = [Select id,LanguageLocaleKey from User where Id =: UserInfo.getUserId() LIMIT 1];
				//Added by Hari 
				//First overide: field set name will be extended with users BU other than  (format <fieldsetAPIName>_<BU>)
				//Second overide: field set name will be again extended with users locale (format <fieldsetAPIName>_<fr> or <fieldsetAPIName>_<BU>_<fr>)
				//if you get any error on name characters extended, please change fieldset name and replace the name where ever it is refered.
				Boolean containsFieldSet = false;
				String checkFieldSetName='';
				//First overide:
				//if(usrInfo.Business_Units_Text__c != 'KTC-USA'){
					//checkFieldSetName=strFieldNameonBU+'_'+usrInfo.Business_Units_Text__c;
				//}
				//Second overide
				if(usrInfo.LanguageLocaleKey != 'en_US'){
					if(String.isNotBlank(checkFieldSetName)){
						checkFieldSetName=checkFieldSetName+'_'+usrInfo.LanguageLocaleKey;
					}else{
						checkFieldSetName=strFieldNameonBU+'_'+usrInfo.LanguageLocaleKey;
					}					
				}
				//We are checking overriden fieldset is available in database
				if(String.isNotBlank(checkFieldSetName)){
					containsFieldSet = objectType.getDescribe().fieldSets.getMap().containsKey(checkFieldSetName);
					if(containsFieldSet){
						strFieldNameonBU = checkFieldSetName;
					}
				}			
				
				List<ATI_FieldSetDetailService.FieldSetDetailsWrapper> fieldsetDetailWrapperList = ATI_FieldSetDetailService.fetchFieldSetDetails(objectName,strFieldNameonBU);
				Set<String> fields = new Set<String>();
				System.debug('-- fieldsetDetailWrapperList'+fieldsetDetailWrapperList);
				Map<String,String> fieldAndReferenceFieldMap = new Map<String,String>();
				List<String> ignoreFieldList = new List<String>{'CreatedById','LastModifiedById','OwnerId'};
				for(ATI_FieldSetDetailService.FieldSetDetailsWrapper fieldsetObject: fieldsetDetailWrapperList) {
					if(fieldsetObject.type == 'REFERENCE' && !ignoreFieldList.contains(fieldsetObject.fieldpath)) {
						String parentField = fieldsetObject.fieldpath.replace('__c','__r')+'.Name';
						fields.add(parentField);
						fieldAndReferenceFieldMap.put(fieldsetObject.fieldpath,parentField);
					}else {
						fields.add(fieldsetObject.fieldpath);
					}
				}
				List<String> fieldsList = new List<String>(fields);
				// idString is a local variable of QueryRunWithSharing.runQueryIdString(-,-) method which help to append in SOQL query dynamically
				//String query = 'SELECT ' + String.join(fieldsList,',') + ' FROM '+objectName + ' WHERE Id = : idString';
				String query = 'SELECT ' + String.join(fieldsList,',') + ' FROM '+objectName + ' WHERE Id = :recordId';
				System.debug('-- query' +query);
				if(fieldsList.size() > 0) {
					// List<sObject> recordDetailList = QueryRunWithSharing.runQueryIdString(query,recordId);
					List<sObject> recordDetailList = Database.query(query);
					System.debug('recordDetailList--'+recordDetailList);
					if(recordDetailList != null && recordDetailList.size() == 1) {
						for(ATI_FieldSetDetailService.FieldSetDetailsWrapper fieldsetObject: fieldsetDetailWrapperList) {
							SectionComponentFieldWrapper sectionComponentFieldWrapperObject = new SectionComponentFieldWrapper();
							sectionComponentFieldWrapperObject.fieldDetail = fieldsetObject;
							String data = getFieldValue(recordDetailList.get(0),fieldsetObject.fieldpath);
                            if(data == 'In Progress'){
                                data = System.Label.Pending_Distributor_Approval;
                            }
							System.debug(fieldsetObject.fieldpath + ' -- '+ data);
							if(fieldsetObject.type == 'DATE' || fieldsetObject.type == 'DATETIME') {
								String dateString = data;
								String[] dateStringArray = dateString != '' ? dateString.split(' ')[0].split('-') : null;
								data = dateStringArray != null && dateStringArray.size() == 3 ? dateStringArray[1]+'/'+dateStringArray[2]+'/'+dateStringArray[0] : '';
							}else if(fieldsetObject.type == 'REFERENCE' && !ignoreFieldList.contains(fieldsetObject.fieldpath)) {
								data = getFieldValue(recordDetailList.get(0),fieldAndReferenceFieldMap.get(fieldsetObject.fieldpath));
								sectionComponentFieldWrapperObject.refFieldRecordId = getFieldValue(recordDetailList.get(0),fieldsetObject.fieldpath);
							}else if(fieldsetObject.fieldpath.contains('CreatedBy')) {
								sectionComponentFieldWrapperObject.fieldDetail.label = 'Created By';
							}else if(fieldsetObject.fieldpath.contains('LastModifiedBy')) {
								sectionComponentFieldWrapperObject.fieldDetail.label = 'LastModified By';
							}else if(fieldsetObject.fieldpath.contains('Owner')) {
								sectionComponentFieldWrapperObject.fieldDetail.label = 'Owner';
							}
							sectionComponentFieldWrapperObject.data = data;
							sectionComponentFieldsWrapperList.add(sectionComponentFieldWrapperObject);
						}
						sectionComponentWrapperObject.sectionComponentFieldsList = sectionComponentFieldsWrapperList;
					}
					return new WOD_2.ResponseWrapper(JSON.serialize(sectionComponentWrapperObject),true,'');
				}
			}else {
				responseWrapperObject = new WOD_2.ResponseWrapper('{}',false,System.label.NoMatchSectionDataFoundErrorMessage);
			}
		}catch(Exception e) {
			system.debug('Exception in Error in getConfigurationSettingMetaData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
			responseWrapperObject = new WOD_2.ResponseWrapper('{}',false,'');
		}
		return responseWrapperObject;
	}
	
	private static String getFieldValue(SObject sObj, String fullFieldName) {
		String[] fields = fullFieldName.split('\\.');
		String fieldValue = '';
		if(fields.size() > 1) {
			fieldValue = '';
			Integer totalFields = fields.size();
			for(Integer i = 0; i < totalFields-1; i++) {
				if(sobj != null) {
					sobj = getSObjectReference(sobj,fields[i]);
				}
			}
			if(sobj != null) {
				fieldValue = String.valueOf(sobj.get(fields[totalFields-1]));
			}
		}else {
			if(sobj != null) {
				fieldValue = String.valueOf(sobj.get(fullFieldName));
			}
		}
		return fieldValue == null ? '' : fieldValue;
	}
	
	private static SObject getSObjectReference(SObject sobj,String referenceFieldName) {
		return sobj.getSObject(referenceFieldName);
	}
	
	@AuraEnabled
	public static WOD_2.ResponseWrapper getUserInformation() {
		WOD_2.ResponseWrapper responseWrapperObject = new WOD_2.ResponseWrapper();
		User usrInfo = [Select id,LanguageLocaleKey from User where Id =: UserInfo.getUserId() LIMIT 1];
		return new WOD_2.ResponseWrapper(JSON.serialize(usrInfo),true,'');
	}    
		
	class SectionComponentFieldWrapper {
	public ATI_FieldSetDetailService.FieldSetDetailsWrapper fieldDetail;
	public String data;
	public String refFieldRecordId;
	}
	class SectionComponentWrapper {
	public ATI_SectionConfiguration__mdt sectionConfiguration;
	public List<SectionComponentFieldWrapper> sectionComponentFieldsList;
	}
}