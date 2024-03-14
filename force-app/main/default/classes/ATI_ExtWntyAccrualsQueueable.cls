/* Name: ATI_ExtWntyAccrualsQueueable
Description : ATI_ExtWntyAccrualsQueueable - Class which does the Ext. warranty accrual calcualtion.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      24-JAN-2021          INITIAL DEVELOPMENT
*/
public class ATI_ExtWntyAccrualsQueueable implements Queueable{
    
    public List<Id> extWarrantyCoverageIdList;
    public List<Id> wrIdToDeleteList;
    
    public ATI_ExtWntyAccrualsQueueable(){
        
    }
    
    public ATI_ExtWntyAccrualsQueueable(List<Id> extWarrantyCoverageIdList){
        this.extWarrantyCoverageIdList = extWarrantyCoverageIdList;
    }
    
    private Map<String, Decimal> getCoverageIdAmtMap(List<Id> wrIdList, List<String> policyNameList){
        List<String> fieldList = new List<String>();
        fieldList.add('Name');
        fieldList.add('WOD_2__Total_Amount__c');
        fieldList.add('WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c');
        ATI_Utils.NoAccessObjectFieldWrapper tmhAccess = ATI_Utils.fetchReadAccess('WOD_2__Transaction_Memo_History_Line_Item__c', fieldList);
        Map<String, Decimal> coverageAmtMap = new Map<String, Decimal>();
        if(tmhAccess.noAccessObjectList.isEmpty() && tmhAccess.noAccessFieldList.isEmpty()){
            List<WOD_2__Transaction_Memo_History_Line_Item__c> tmhLineItemsList =
                [select id, Name, WOD_2__Total_Amount__c, WOD_2__Transaction_Memo_History__c, 
                 WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c from WOD_2__Transaction_Memo_History_Line_Item__c 
                 where name in :policyNameList and WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c in :wrIdList];
            for(WOD_2__Transaction_Memo_History_Line_Item__c tmhli : tmhLineItemsList){
            	String key = tmhli.WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c + tmhli.Name;
                coverageAmtMap.put(key, tmhli.WOD_2__Total_Amount__c);
            }
            return coverageAmtMap;
        }        
		throw new TWoDException(Label.ATI_Log_Insufficient_access);
        
    }
    
    public void execute(QueueableContext context) {
        if(wrIdToDeleteList != null && !wrIdToDeleteList.isEmpty()){
            //update the accurals and delete/ inactivate any accurals after the policy end date
            List<ATI_Ext_Warranty_Accrual__c> accrualList = getAccuralListToUpdate();
            for(ATI_Ext_Warranty_Accrual__c wcAccrual : accrualList){
                wcAccrual.ATI_Is_Active__c = false;				                
            }
            if(!accrualList.isEmpty()){
                update accrualList;    
            }
        } 
        if(extWarrantyCoverageIdList != null && !extWarrantyCoverageIdList.isEmpty()){
            List<WOD_2__Warranty_Coverages__c> wcList = getCoverageList();
            List<Id> invIdList = new List<Id>();
            List<Id> wrIdList = new List<Id>();
            List<String> policyNameList = new List<String>();
            for(WOD_2__Warranty_Coverages__c wc : wcList){
                invIdList.add(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c);
                wrIdList.add(wc.WOD_2__Warranty_Registration__c);
                policyNameList.add(wc.WOD_2__Policy_Definition__r.Name);
            }
            Map<Id, Date> invIdStdWntyEndDateMap = getInvIdStdWntyEndDateMap(invIdList);
            Map<String, Decimal> coverageIdAmtMap = getCoverageIdAmtMap(wrIdList, policyNameList);
			createAccrualRecords(wcList, invIdStdWntyEndDateMap, coverageIdAmtMap);
        }
    }
    
    private List<ATI_Ext_Warranty_Accrual__c> getAccuralListToUpdate(){
        List<String> fieldList = getExtWntyAccrualFieldList();
        ATI_Utils.NoAccessObjectFieldWrapper wntyAccrualAccess = ATI_Utils.fetchUpdateAccess('ATI_Ext_Warranty_Accrual__c', fieldList);
        if(wntyAccrualAccess.noAccessObjectList.isEmpty() && wntyAccrualAccess.noAccessFieldList.isEmpty()){
            String query = 'select id, ' + String.join(fieldList, ',') + ' from ATI_Ext_Warranty_Accrual__c where ' +
                'ATI_Warranty_Coverage__r.WOD_2__Warranty_Registration__c in :wrIdToDeleteList';
            return Database.query(query);
        }        
        throw new TWoDException(Label.ATI_Log_Insufficient_access);                
    }

    private void createAccrualRecords(List<WOD_2__Warranty_Coverages__c> wcList, 
                                      Map<Id, Date> invIdStdWntyEndDateMap, Map<String, Decimal> coverageIdAmtMap){
        List<ATI_Ext_Warranty_Accrual__c> extWntyAccrualList = new List<ATI_Ext_Warranty_Accrual__c>();
        for(WOD_2__Warranty_Coverages__c wc : wcList){
            Date stdWntyEndDate = invIdStdWntyEndDateMap.get(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c);
            System.debug('stdWntyEndDate -> ' + stdWntyEndDate);
            if(stdWntyEndDate != null && wc.WOD_2__Warranty_End_Date__c != null){
                Integer monthsDifference = stdWntyEndDate.monthsBetween(wc.WOD_2__Warranty_End_Date__c);
                stdWntyEndDate = stdWntyEndDate.addMonths(1);
                if(monthsDifference > 0){ // just in case if Extended has lesser or equal coverage as standard warranty
                    String key = wc.WOD_2__Warranty_Registration__c + wc.WOD_2__Policy_Definition__r.Name;
                    Decimal policyAmount = coverageIdAmtMap.get(key);
                    if(policyAmount != null){
                        Decimal monthlyAmount = policyAmount / monthsDifference;
                        for(Integer i = 0; i < monthsDifference; i++ ){
                            ATI_Ext_Warranty_Accrual__c extWntyAccrual =
                                new ATI_Ext_Warranty_Accrual__c(ATI_Accrual_Date__c=stdWntyEndDate.addMonths(i),
                                                                ATI_Amount__c=monthlyAmount,
                                                                ATI_Inventory__c=wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c,
                                                                ATI_Is_Active__c=true,
                                                                ATI_Warranty_Coverage__c=wc.Id);
                            extWntyAccrualList.add(extWntyAccrual);
                        }
                    }
                }
            }
        }
        insertAccrualRecords(extWntyAccrualList);
                                          system.debug('insertAccrualRecords'+extWntyAccrualList);
    }
    
    private List<String> getExtWntyAccrualFieldList(){
        List<String> fieldList = new List<String>();
        fieldList.add('ATI_Accrual_Date__c');
        fieldList.add('ATI_Amount__c');
        fieldList.add('ATI_Inventory__c');
        fieldList.add('ATI_Is_Active__c');
        fieldList.add('ATI_Warranty_Coverage__c');
		return fieldList ;         
    }
    
    private void insertAccrualRecords(List<ATI_Ext_Warranty_Accrual__c> extWntyAccrualList){
        if(!extWntyAccrualList.isEmpty()){
            List<String> fieldList = getExtWntyAccrualFieldList();
            ATI_Utils.NoAccessObjectFieldWrapper wntyAccrualAccess = ATI_Utils.fetchCreateAccess('ATI_Ext_Warranty_Accrual__c', fieldList);
            if(wntyAccrualAccess.noAccessObjectList.isEmpty() && wntyAccrualAccess.noAccessFieldList.isEmpty()){
                insert extWntyAccrualList;
            } else {
            	throw new TWoDException(Label.ATI_Log_Insufficient_access);    
            }        
                            
        }
    }    
    
    
    // This method returns the standard warranty end date to inventory map
    private Map<Id, Date> getInvIdStdWntyEndDateMap(List<Id> invIdList){
        Map<Id, Date> invIdStdWntyEndDateMap = new Map<Id, Date>();
        List<String> fieldList = new List<String>();
        fieldList.add('WOD_2__Inventory__r.Id');
        fieldList.add('WOD_2__Status__c');
        fieldList.add('ATI_Standard_Warranty_End_Date__c');
        ATI_Utils.NoAccessObjectFieldWrapper wrAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', fieldList);
        if(wrAccess.noAccessObjectList.isEmpty() && wrAccess.noAccessFieldList.isEmpty()){
        	AggregateResult[] groupedResults =
                [select WOD_2__Inventory__r.Id, MAX(ATI_Standard_Warranty_End_Date__c) stdWntyEndDate from WOD_2__Warranty_Registration__c where 
                 WOD_2__Status__c = 'Registered' and WOD_2__Registration_Type__c='Standard Registration' and WOD_2__Inventory__r.Id in :invIdList group by WOD_2__Inventory__r.Id]; 
            for (AggregateResult ar : groupedResults)  {
				invIdStdWntyEndDateMap.put((Id)ar.get('Id'),(Date) ar.get('stdWntyEndDate'));
            }
            return invIdStdWntyEndDateMap;
        }        
		throw new TWoDException(Label.ATI_Log_Insufficient_access);
    }
    
    private List<WOD_2__Warranty_Coverages__c> getCoverageList(){
        List<String> wcFieldList = new List<String>();
        wcFieldList.add('WOD_2__Warranty_End_Date__c');
        wcFieldList.add('WOD_2__Is_Active__c');
        wcFieldList.add('WOD_2__Warranty_Registration__c');
        wcFieldList.add('WOD_2__Policy_Definition__r.Name');
        wcFieldList.add('WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c');
        wcFieldList.add('WOD_2__Policy_Definition__r.WOD_2__Days_Covered__c');
        wcFieldList.add('WOD_2__Warranty_Registration__r.WOD_2__Inventory__c');
        wcFieldList.add('WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c');
        ATI_Utils.NoAccessObjectFieldWrapper wcAccess = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Coverages__c', wcFieldList);
        if(wcAccess.noAccessObjectList.isEmpty() && wcAccess.noAccessFieldList.isEmpty()){
            String query = 'select id, ' + String.join(wcFieldList, ',') + ' from WOD_2__Warranty_Coverages__c where id in:extWarrantyCoverageIdList';
            return Database.query(query);
        }
        throw new TWoDException(Label.ATI_Log_Insufficient_access);
    }
    
}