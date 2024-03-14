/* Class Name: PRPC_metricResultCustomReportClass
 * Description: 
 * Created by: Debiprasad
 *
 * Update : CHG44065 -Update the profile check for PRP Admin & CSM User to custom permissions.
 * Update By : 08/23/2024, Susovan Mondal & Chinmaya Dash
 * 
 * Update : ENHC0011584 -Make all the reports under the “All Metric Result” tab as dynamic reports that based on the year the ETC or SDM metric will be visible.
 * Update By : 12/10/2024, Susovan Mondal & Chinmaya Dash
 */


public without sharing class PRPC_metricResultCustomReportClass {
    @AuraEnabled
    public static regionAndFields onLoadValue(string SelectedReportName,string RegionType,string PartnerType){
        system.debug('SelectedReportName: '+SelectedReportName);
        system.debug('RegionType: '+RegionType);
        system.debug('PartnerType: '+PartnerType);
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name =:SelectedReportName And Report_Region__c=:RegionType And Partner_Type__c=:PartnerType LIMIT 1];
        system.debug('rp: 5 '+rp);
        List<String> defaultColumns = rp[0].Report_Columns__c.split(',');
        System.debug('defaultColumns- ' + defaultColumns);
        List<String> fields = new List<String>();
        Schema.SObjectType RefParObj;
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType objType = globalDescription.get(rp[0].Report_Object__c); 
        Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
        
        Map<String , Schema.SObjectField> fieldMap = r1.fields.getMap(); 
        //System.debug('fieldMap- ' + fieldMap);
        List<pickListWrapper> wrapfieldsList = new List<pickListWrapper>();
        //List<All_Regions__mdt> allRegionList = new List<All_Regions__mdt>([Select id,MasterLabel,IsInternational__c,DeveloperName from All_Regions__mdt]);
        //List<pickListWrapper> regionNames = new List<pickListWrapper>();
        /*for(All_Regions__mdt  reg : allRegionList){
if(SelectedReportName.contains('International')){
if(reg.IsInternational__c == TRUE){
regionNames.add(new pickListWrapper(reg.DeveloperName,reg.MasterLabel));                      
}
}
else{
if(reg.IsInternational__c == FALSE){
regionNames.add(new pickListWrapper(reg.DeveloperName,reg.MasterLabel));                      
}
}
}*/
        List<pickListWrapper> regionNames = new List<pickListWrapper>();
        
        List<String> reg = new List<String>{'North America','Latin America','EMEA','Asia Pacific'};
            for(String m : reg){
                regionNames.add(new pickListWrapper(m,m));
            }
        
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            Schema.DisplayType FldType = sfield.getDescribe().getType();
            wrapfieldsList.add(new pickListWrapper(dfield.getname(),dfield.getLabel()));
            if(sfield.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                // system.debug('sfield.getDescribe().getReferenceTo()'+sfield.getDescribe().getReferenceTo());
                if(String.valueof(sfield.getDescribe().getReferenceTo()[0]) == 'Account'){
                    Map<String , Schema.SObjectType> globalDescriptionP = Schema.getGlobalDescribe();
                    Schema.sObjectType objTypeP = globalDescription.get('Account'); 
                    Schema.DescribeSObjectResult r2 = objTypeP.getDescribe(); 
                    Map<String , Schema.SObjectField> fieldMap1 = r2.fields.getMap(); 
                    for(Schema.SObjectField sfield1 : fieldMap1.Values())
                    {
                        schema.describefieldresult dfield1 = sfield1.getDescribe();
                        wrapfieldsList.add(new pickListWrapper(String.valueOf('Customer__r.'+dfield1.getname()),dfield1.getLabel()));
                        //system.debug('wrapfieldsList'+wrapfieldsList);
                    }
                } 
                
            }
            
        }
        List<pickListWrapper> defaultfieldsList = new List<pickListWrapper>();
        for(String defaults : defaultColumns){
            for(pickListWrapper field1 : wrapfieldsList){
                if(field1.Id == defaults){
                    defaultfieldsList.add(field1);
                }
            }
        }
        list<Metric_Detail__mdt> Metric = new list<Metric_Detail__mdt>([select API_name__c,MasterLabel from Metric_Detail__mdt order by MasterLabel]);
        List<pickListWrapper> MetricValue = new List<pickListWrapper>();
        for(Metric_Detail__mdt mtr : Metric){
            MetricValue.add(new pickListWrapper(mtr.API_name__c,mtr.MasterLabel));
        }
        
        //System.debug('Default Fields- ' + defaultfieldsList);
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, rp[0].Report_Object__c,MetricValue);
    }
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion) 
    {
        system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,SAP_ID__c,Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Distributor' ORDER BY name]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.name+'('+acc.SAP_ID__c+')'));
        }
        //system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    @AuraEnabled
    public static List<pickListWrapper> fetchDirectDealer(List<String> selectedRegion) 
    {
        //system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,SAP_ID__c,Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Direct Dealer' ORDER BY name]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.name+'('+acc.SAP_ID__c+')'));
        }
         return AccountNames;
    }
    @AuraEnabled
    public static List<pickListWrapper> FetchDealerLocation(List<String> SelectDealer) 
    {
        //system.debug('SelectDealer'+SelectDealer);
        List<Account> accountList = new List<Account>([Select id,name,SAP_ID__c,ShippingCity from Account where Id IN: SelectDealer and (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY ShippingCity]);
        //system.debug('accountList'+accountList);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.ShippingCity+'('+acc.SAP_ID__c+')'));
        }
        return AccountNames;
    }
    @AuraEnabled
    public static List<pickListWrapper> FetchDistBranch(List<String> DistributorList) 
    {
        //system.debug('DistributorList'+DistributorList);
        List<Account> accountList = new List<Account>([Select id,name,SAP_ID__c,ShippingCity from Account where parent.Id IN: DistributorList and (Type='Distributor Branch' or Type='Distributor') and (Sales_RegionA__c !=null or Location_Type__c !=null)  ORDER BY ShippingCity]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.ShippingCity+'('+acc.SAP_ID__c+')'));
        }
        return AccountNames;
    }
    /* @AuraEnabled
public static List<pickListWrapper> FetchBranch(List<String> serviceLocationList) 
{
system.debug('serviceLocationList'+serviceLocationList);
List<Account> accountList = new List<Account>([Select id,name,Type  from Account where SAP_ID__c IN: serviceLocationList]);
List<pickListWrapper> AccountNames = new List<pickListWrapper>();
for(Account acc : accountList){
AccountNames.add(new pickListWrapper(acc.id,acc.name));
}
return AccountNames;
}

@AuraEnabled
public static List<pickListWrapper> fetchMonth(List<String> DistributorBranch) 
{
system.debug('DistributorBranch'+DistributorBranch);
List<TPS_Data__c> tpsList = new List<TPS_Data__c>([Select id,name,month__c  from TPS_Data__c where customer__r.name IN: DistributorBranch]);
MAP<String, id> tps = new Map<String, Id>();
for(Tps_Data__c t : tpsList){
tps.put(String.valueOf(t.month__c), t.Id);
}
List<pickListWrapper> months = new List<pickListWrapper>();
for(String tp : tps.keySet()){
months.add(new pickListWrapper(tps.get(tp),tp));
}
return months;
}*/
    @AuraEnabled
    public static string CommunityTabReport(){
        system.debug('enter line 8');
        string returnProfileName;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //CHG44065 Check the Custom permission.
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        If(isPRPAdminPermission==true ){
            returnProfileName='PRP Admin';
        }
        Boolean isCSMPermission = FeatureManagement.checkPermission('ATI_PRP_CSM');
        If(isCSMPermission==true ){
            returnProfileName='Custom Platform User';
        }
        system.debug('ProfileName'+profileName);
        if(profileName == 'PRP Partner'){
            returnProfileName = profileName;
        }
        /*else if(profileName == 'Custom Platform User'){
            returnProfileName = profileName;
        }else if(profileName == 'PRP Admin'){
            returnProfileName = profileName;
        }*/
        else if(profileName == 'System Administrator'){
            returnProfileName = profileName;
        }
        //CHG44065 Removing the PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               returnProfileName=pmap.get(s);
            }
        }*/
        system.debug('returnProfileName: '+returnProfileName);
        return returnProfileName;
    }
    @AuraEnabled
    public static List<Sobject> FetchRecordsforTable(List<string> MetricDetail,List<String> DistributorList,List<String> BranchList,List<String> regionList,String columns,String SelectedObject,string DateRangeFrom,string DateRangeTo,string selectedReportName,list<string>DirectDealerLocation,list<string>DirectDealer,string SelectedPartnerType,string PeriodType) 
    {
        system.debug('regionList: '+regionList);
        system.debug('DirectDealerLocation: '+DirectDealerLocation);
        system.debug('DateRangeFrom: '+DateRangeFrom+' DateRangeTo : '+DateRangeTo);
        system.debug('SelectedObject : '+SelectedObject);
        system.debug('MetricDetail : '+MetricDetail+' DistributorList: '+DistributorList+' selectedReportName : '+selectedReportName+' SelectedPartnerType: '+SelectedPartnerType+' PeriodType : '+PeriodType);

        list<sobject> tableData = new list<sobject>();
        Datetime dtFrom = Date.ValueOf(DateRangeFrom);
        dtFrom = dtFrom.addDays(1);
        Integer FromDateMonth = dtFrom.Month();
        Integer FromDateYear = dtFrom.Year();
        Integer dayFrom = dtFrom.Day();
        //String FromDate = dtFrom.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        Datetime dtTo = Date.ValueOf(DateRangeTo);
        dtTo = dtTo.addDays(1);
        Integer ToDateMonth = dtTo.Month();
        Integer ToDateYear = dtTo.Year();
        Integer dayTo = dtTo.Day();
        
        Id profileId=userinfo.getProfileId(); 
        String profileName=[Select Id,Name from Profile where Id=: profileId].Name;
        //CHG44065 Removing the PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               profileName=pmap.get(s);
            }
        }*/
        //CHG44065 Check the Custom permission
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        If(isPRPAdminPermission==true ){
            profileName='PRP Admin';
        }
        Boolean isCSMPermission = FeatureManagement.checkPermission('ATI_PRP_CSM');
        If(isCSMPermission==true ){
            profileName='Custom Platform User';
        }
        
        Set<string> Metricset = new Set<string>();
        Set<ID> DistributorSet = new Set<ID>();
        list<string> BranchSet = new list<string>();
        Set<String> regionSet = new Set<String>();
        if(MetricDetail != null){
            for(String str : MetricDetail){
                Metricset.add(str);
            }
        }
        if(DistributorList != null){
            for(String str : DistributorList){
                DistributorSet.add(str);
            }
        }
        if(BranchList != null){
            for(String str : BranchList){
                BranchSet.add(str.substring(0, str.length()-12));
            }
        }
        if(regionList != null){
            for(String str : regionList){
                regionSet.add(str);
            }
        }
        string releaseKpi = 'X';
        system.debug('BranchSet: '+BranchSet);
         system.debug('DistributorSet: '+BranchSet);
        
        List<SObject> DisplayFinalList = new List<SObject>();
        
        //system.debug('selectedReportName'+selectedReportName);
        system.debug('DistributorSet: '+DistributorSet);
        String query = 'Select ' +columns +',';
        if(columns != null){
            if(selectedReportName != 'Performance Comparison Summary Report'){
                for(integer i = 0; i<MetricDetail.size();i++){
                    query += MetricDetail[i]+',';
                }
            }
            //}
            query += 'Total_Score__c,CreatedDate';
            //query = query.substring(0,query.length()-1);
            if(profileName == 'PRP Partner' || profileName == 'Custom Platform User'){
            if(regionList.contains('North America')){
                system.debug('line 245');
                if(selectedReportName == 'Individual Metric Summary' && SelectedPartnerType == 'Distributor'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true And Released__c =\''+releaseKpi+'\'  and Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && selectedReportName == 'Individual Metric Summary'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and  Released__c =\''+releaseKpi+'\'  and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }
                else if((selectedReportName == 'Metrics Total with Performance Level' || selectedReportName =='Metrics Total' ||selectedReportName == 'Training Data')&& SelectedPartnerType == 'Distributor'){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true And  Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && (selectedReportName == 'Metrics Total' ||selectedReportName == 'Metrics Total with Performance Level' || selectedReportName == 'Training Data')){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And And Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Distributor'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Direct Dealer'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,CSI_Dealer_Score__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }
            }else{
                if(selectedReportName == 'Individual Metric Summary' && SelectedPartnerType == 'Distributor'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN: DistributorSet AND isPartOfPRP__c= true And Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && selectedReportName == 'Individual Metric Summary'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }
                else if((selectedReportName == 'Metrics Total with Performance Level' || selectedReportName =='Metrics Total' ||selectedReportName == 'Training Data')&& SelectedPartnerType == 'Distributor'){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN: DistributorSet AND isPartOfPRP__c= true And Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && (selectedReportName == 'Metrics Total' ||selectedReportName == 'Metrics Total with Performance Level' || selectedReportName == 'Training Data')){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Released__c =\''+releaseKpi+'\' and Period__c =\''+PeriodType+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Distributor'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' And Released__c =\''+releaseKpi+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' And Released__c =\''+releaseKpi+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' And Released__c =\''+releaseKpi+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Direct Dealer'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND Released__c =\''+releaseKpi+'\' and  isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }
            }
            }else if(profileName == 'PRP Admin' || profileName == 'System Administrator'){
                if(regionList.contains('North America')){
                if(selectedReportName == 'Individual Metric Summary' && SelectedPartnerType == 'Distributor'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && selectedReportName == 'Individual Metric Summary'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }
                else if((selectedReportName == 'Metrics Total with Performance Level' || selectedReportName =='Metrics Total' ||selectedReportName == 'Training Data')&& SelectedPartnerType == 'Distributor'){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && (selectedReportName == 'Metrics Total' ||selectedReportName == 'Metrics Total with Performance Level' || selectedReportName == 'Training Data')){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Distributor'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Direct Dealer'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }
            }else{
                if(selectedReportName == 'Individual Metric Summary' && SelectedPartnerType == 'Distributor'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN: DistributorSet AND Period__c =\''+PeriodType+'\' And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && selectedReportName == 'Individual Metric Summary'){
                    
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }
                else if((selectedReportName == 'Metrics Total with Performance Level' || selectedReportName =='Metrics Total' ||selectedReportName == 'Training Data')&& SelectedPartnerType == 'Distributor'){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN: DistributorSet AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if(SelectedPartnerType == 'Direct Dealer' && (selectedReportName == 'Metrics Total' ||selectedReportName == 'Metrics Total with Performance Level' || selectedReportName == 'Training Data')){
                    query +=  ',Month__c,Customer_ParentId__c,Year__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and  Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Distributor'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where (Customer__r.parent.Id IN: DistributorSet)  AND Period__c =\''+PeriodType+'\' and Customer__r.ShippingCity IN:BranchSet And Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }else if((selectedReportName == 'Metric Comparison Summary' ||selectedReportName == 'Performance Comparison Summary Report') && SelectedPartnerType == 'Direct Dealer'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        query +=  ',Facility_Audit__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        query +=  ',Facility_Audit__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                    else{
                        query +=  ',Facility_Audit__c,ETC_Score__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,Parts_Ordering__c,CSI_Dealer__c,CSI__c,CSI_Score__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,Region__c,Customer_ParentId__c,CSI_Parts__c,CSI_Service__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c,Training__c,Total_Parts_Sold_ReTran__c,TPS__c from ' + SelectedObject + ' where Customer__r.Id IN:DirectDealer AND isPartOfPRP__c= true And Period__c =\''+PeriodType+'\' and Year__c<='+ToDateYear +' And Year__c >='+FromDateYear+' ORDER BY Customer_SAP_Id__c\'';
                    }
                }
            }
            }
        }
        query = query.substring(0,query.length()-1);
        //query+= ' where Customer__r.parent.name IN: DistributorSet  AND Customer__r.parent.SAP_Id__c IN: locationset  AND Customer__r.parent.Sales_Region__c IN:regionSet';
        system.debug('query'+query); 
        DisplayFinalList = database.query(query);
        
        //system.debug('tableData: '+DisplayFinalList);
        system.debug('tableData279: '+DisplayFinalList.size());
        for(SObject chng : DisplayFinalList){
            
            if(FromDateYear < integer.valueof(chng.get('Year__c'))&& integer.valueof(chng.get('Year__c')) < ToDateYear){
                tableData.add(chng);
            }else if(FromDateYear == integer.valueof(chng.get('Year__c')) && FromDateYear!=ToDateYear){
                if(FromDateMonth <= integer.valueof(chng.get('Month__c'))){
                    tableData.add(chng);
                }
            }else if(integer.valueof(chng.get('Year__c')) == ToDateYear && FromDateYear!=ToDateYear){
                if(ToDateMonth >= integer.valueof(chng.get('Month__c'))){
                    tableData.add(chng);
                }
            }else if(FromDateYear == integer.valueof(chng.get('Year__c'))&& FromDateYear==ToDateYear){
                if(FromDateMonth <= integer.valueof(chng.get('Month__c')) && ToDateMonth>=integer.valueof(chng.get('Month__c'))){
                    tableData.add(chng);
                }
            }else if(integer.valueof(chng.get('Year__c')) == ToDateYear && FromDateYear==ToDateYear){
                if(ToDateMonth >= integer.valueof(chng.get('Month__c')) && FromDateMonth<=integer.valueof(chng.get('Month__c'))){
                    tableData.add(chng);
                }
            }
        }
        system.debug('tableData 302: '+tableData.size());
        map<string,sobject> mapOffilterRes = new map<string,sobject>();
        set<integer> monthValue = new set<Integer>();
        set<integer> YearValue = new set<Integer>();
        for(SObject chng : tableData){
            string StoreDate = string.valueof(chng.get('Month__c'));
            string StoreYear = string.valueof(chng.get('Year__c'));
            String Month;
            string TotalMonthYear;
            if(StoreDate == '1'){
                Month = 'Jan';
            }else if(StoreDate== '2'){
                Month = 'Feb';
            }else if(StoreDate== '3'){
                Month = 'Mar';
            }else if(StoreDate== '4'){
                Month = 'Apr';
            }else if(StoreDate== '5'){
                Month = 'May';
            }else if(StoreDate== '6'){
                Month = 'Jun';
            }else if(StoreDate== '7'){
                Month = 'Jul';
            }else if(StoreDate== '8'){
                Month = 'Aug';
            }else if(StoreDate== '9'){
                Month = 'Sep';
            }else if(StoreDate== '10'){
                Month = 'Oct';
            }else if(StoreDate== '11'){
                Month = 'Nov';
            }else if(StoreDate== '12'){
                Month = 'Dec';
            }
            TotalMonthYear = Month +' '+StoreYear;
            //DateTime dt = Date.valueOf(StoreDate);
            //string ChangeFormat = dt.format('MMM yyyy');
            chng.put('Month_String__c',TotalMonthYear);
            
            
            
            monthValue.add(Integer.valueof(chng.get('Month__C')));
            YearValue.add(Integer.valueof(chng.get('Year__c')));
            //if(SelectedPartnerType == 'Direct Dealer'){
                //chng.put('Customer__r.Sold_To_Code__c',chng.get('Customer_SAP_Id__c'));
            //if(SelectedPartnerType == 'Distributor' && !regionList.contains('North America')){
                // mapOffilterRes.put(string.valueof(chng.get('Customer__c')),chng);
            //}else{
                mapOffilterRes.put(string.valueof(chng.get('Customer_ParentId__c')),chng);
            //}
            //}
        }
        //system.debug('tableData:line 320 '+tableData);
        map<string,list<string>> countBranchofrgn = new map<string,list<string>>();
        list<Account> idwithRgn = new list<Account>([select id,Sales_RegionA__c from Account where Type='Distributor Branch']);
        for(Account acc:idwithRgn){
            if(countBranchofrgn.keyset().contains(string.valueof(acc.Sales_RegionA__c))){
                list<string>newlst = new list<string>();
                newlst = countBranchofrgn.get(string.valueof(acc.Sales_RegionA__c));
                newlst.add(string.valueof(acc.id));
                countBranchofrgn.put(string.valueof(acc.Sales_RegionA__c),newlst);
            }else{
                list<string>DBid = new list<string>();
                DBid.add(string.valueof(acc.id));
                countBranchofrgn.put(string.valueof(acc.Sales_RegionA__c),DBid);
            }
        }
        map<string,list<string>> DistributorBranchCount = new map<string,list<string>>();
        //list<Account> idWithBranch = new list<Account>([select id from Account where Type='Distributor']);
        list<Account> lstOfbranch =  new list<Account>([select id,parentId from Account where Type = 'Distributor Branch']);
        for(Account acc: lstOfbranch){
            if(DistributorBranchCount.keyset().contains(string.valueof(acc.parentId))){
                list<string>newlst = new list<string>();
                newlst = DistributorBranchCount.get(string.valueof(acc.parentId));
                newlst.add(string.valueof(acc.id));
                DistributorBranchCount.put(string.valueof(acc.parentId),newlst);
            }else{
                list<string>DBid = new list<string>();
                DBid.add(string.valueof(acc.id));
                DistributorBranchCount.put(string.valueof(acc.parentId),DBid);
            }
        }
        //system.debug('DistributorBranchCount: '+DistributorBranchCount);
        //system.debug('lstOfbranch: '+lstOfbranch);
        
        //map<string,map<string,list<Double>>> StoreAllAvergeValue = new map<string,map<string,list<Double>>>();
        map<string,map<string,map<string,list<Double>>>> StoreAllAvergeValue2 = new map<string,map<string,map<string,list<Double>>>>();
        map<string,map<string,map<string,map<string,list<Double>>>>> StoreRegionAvgValData = new map<string,map<string,map<string,map<string,list<Double>>>>>();
        list<sobject>AllRecord = new list<sobject>();
        list<sobject>kpiRecord = new list<sobject>();
        //AllRecord = [SELECT CSI__c,Facility_Audit__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c];
        //kpiRecord = [SELECT CSI__c,Facility_Audit__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear ];
        if(!Test.isRunningTest()){
            if(regionList.contains('North America')){
                if(FromDateYear <=2023 && ToDateYear <= 2023){
                	kpiRecord = [SELECT CSI__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true and Customer__r.ShippingCity IN:BranchSet];
                }
                else if(FromDateYear <=2023 && ToDateYear >= 2024){
                    kpiRecord = [SELECT CSI__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true and Customer__r.ShippingCity IN:BranchSet];
                }
                else{
                	kpiRecord = [SELECT CSI__c,ETC_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet AND isPartOfPRP__c= true and Customer__r.ShippingCity IN:BranchSet];
                }
            }else{
                if(SelectedPartnerType == 'Distributor'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        kpiRecord = [SELECT CSI__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet];
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        kpiRecord = [SELECT CSI__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet];
                    }
                    else{
                        kpiRecord = [SELECT CSI__c,ETC_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.parent.Id IN: DistributorSet];
                    }
                }else if(SelectedPartnerType == 'Direct Dealer'){
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        kpiRecord = [SELECT CSI__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.Id IN: DirectDealer];
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        kpiRecord = [SELECT CSI__c,ETC_Score__c,ETC__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.Id IN: DirectDealer];
                    }
                    else{
                        kpiRecord = [SELECT CSI__c,ETC_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,ETC__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType and Year__c<=:ToDateYear And Year__c >=:FromDateYear and Customer__r.Id IN: DirectDealer];
                    }
                }
            }
        }else{
                kpiRecord = [SELECT CSI__c,Service_Dealer_Development_Score__c,Facility_Audit__c,CSI_Dealer_Score__c,Service_Dealer_Development__c,Facility_Audit_Score__c,Parts_Ordering_Score__c,CSI_Score__c,Branch_Score__c,Period__c,CSI_Parts_Score__c,CSI_Service_Score__c,Total_Parts_Sold_ReTran_Score__c,TPS_Score__c,Training_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_M_Score__c,Turnaround_Time_O_Score__c,Month__c,Year__c,CSI_Dealer__c,CreatedDate,CSI_Parts__c,CSI_Service__c,Customer_ParentId__c,Customer_SAP_Id__c,Customer__c,Distributor_Avg__c,Metric_Detail__c,Month_String__c,North_America_Avg__c,Partner_Type__c,Parts_Ordering__c,PRP_Level__c,PRP_Score__c,Region_Avg__c,Region__c,TAT__c,Total_Parts_Sold_ReTran__c,Total_Parts_Sold__c,Total_Score__c,TPS__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_M__c,Turnaround_Time_O__c FROM KPI__c where Period__c =:PeriodType];
        }
        system.debug('kpiRecord: '+kpiRecord.size());
        for(SObject chng : kpiRecord){
            
            if(FromDateYear < integer.valueof(chng.get('Year__c'))&& integer.valueof(chng.get('Year__c')) < ToDateYear){
                AllRecord.add(chng);
            }else if(FromDateYear == integer.valueof(chng.get('Year__c')) && FromDateYear!=ToDateYear){
                if(FromDateMonth <= integer.valueof(chng.get('Month__c'))){
                    AllRecord.add(chng);
                }
            }else if(integer.valueof(chng.get('Year__c')) == ToDateYear && FromDateYear!=ToDateYear){
                if(ToDateMonth >= integer.valueof(chng.get('Month__c'))){
                    AllRecord.add(chng);
                }
            }else if(FromDateYear == integer.valueof(chng.get('Year__c'))&& FromDateYear==ToDateYear){
                if(FromDateMonth <= integer.valueof(chng.get('Month__c')) && ToDateMonth>=integer.valueof(chng.get('Month__c'))){
                    AllRecord.add(chng);
                }
            }else if(integer.valueof(chng.get('Year__c')) == ToDateYear && FromDateYear==ToDateYear){
                if(ToDateMonth >= integer.valueof(chng.get('Month__c')) && FromDateMonth<=integer.valueof(chng.get('Month__c'))){
                    AllRecord.add(chng);
                }
            }
        }
        
        system.debug('line 411: '+AllRecord.size());
        if(selectedReportName == 'Metric Comparison Summary'){
            list<string> StoreAllDistList = new list<string>();
            Double WholeBranchesOfdist;
            //Double TotalAllDistBranch = 0;
            list<Account> AllDistList = new list<Account>([select id from Account where Type='Distributor' And Sales_RegionA__c IN: regionList]);
            
            list<Sobject> ReturncompData = new list<Sobject>();
            //list<string> AllBranch = new list<string>();
            //For calculating Region avg
            list<Sobject> AllKpirecord = new list<sobject>();
            list<Sobject> AllrecWithDetail = new list<Sobject>();
            
            //system.debug('mapOffilterRes: '+mapOffilterRes);
            //for calculating Distributor avg
            map<string,map<string,list<sobject>>> newMap = new map<string,map<string,list<sobject>>>();
            map<string,map<string,list<sobject>>> RegionMap = new map<string,map<string,list<sobject>>>();
            Decimal rgnAvg1 =0;
                Decimal rgnAvg2 =0;
                Decimal rgnAvg3=0;
                Decimal rgnAvg4=0;
                Decimal rgnAvg5=0;
                Decimal rgnAvg6=0;
                Decimal rgnAvg7=0;
                Decimal rgnAvg8=0;
                Decimal rgnAvg9=0;
                Decimal rgnAvg10=0;
                Decimal rgnAvg11=0;
                Decimal rgnAvg12=0;
                Decimal rgnAvg13=0;
            	Decimal rgnAvg14=0;
                AggregateResult[] groupedResults;
                AggregateResult[] groupedResults2;
                AggregateResult[] groupedResults3;
                AggregateResult[] groupedResults4;
                AggregateResult[] groupedResults5;
                AggregateResult[] groupedResults6;
                AggregateResult[] groupedResults7;
                AggregateResult[] groupedResults8;
                AggregateResult[] groupedResults9;
                AggregateResult[] groupedResults10;
                AggregateResult[] groupedResults11;
                AggregateResult[] groupedResults12;
                AggregateResult[] groupedResults13;
            	AggregateResult[] groupedResults14;
            
            if(regionList.contains('North America')){
                groupedResults= [Select AVG(CSI_Parts__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults2= [Select AVG(CSI_Service__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults3= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults4= [Select AVG(TPS__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults5= [Select AVG(Training__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults6= [Select AVG(Turnaround_Time_I__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults7= [Select AVG(Turnaround_Time_M__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults8= [Select AVG(Turnaround_Time_O__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults9= [Select AVG(CSI_Dealer__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults11= [Select AVG(CSI__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults12= [Select AVG(Facility_Audit__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                groupedResults13= [Select AVG(Parts_Ordering__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
            	if(FromDateYear <=2023 && ToDateYear <= 2023){
                    groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                }
                else if(FromDateYear <=2023 && ToDateYear >= 2024){
                    groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                }
                else{
                    groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                }
            }else{
                if(SelectedPartnerType == 'Distributor'){
                    groupedResults= [Select AVG(CSI_Parts__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults2= [Select AVG(CSI_Service__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults3= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults4= [Select AVG(TPS__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults5= [Select AVG(Training__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults6= [Select AVG(Turnaround_Time_I__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults7= [Select AVG(Turnaround_Time_M__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults8= [Select AVG(Turnaround_Time_O__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults9= [Select AVG(CSI_Dealer__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults11= [Select AVG(CSI__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults12= [Select AVG(Facility_Audit__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    groupedResults13= [Select AVG(Parts_Ordering__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                	if(FromDateYear <=2023 && ToDateYear <= 2023){
                        groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];                       
                        groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    }
                    else{
                        groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                    }
                }else{
                    groupedResults= [Select AVG(CSI_Parts__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults2= [Select AVG(CSI_Service__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults3= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults4= [Select AVG(TPS__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults5= [Select AVG(Training__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults6= [Select AVG(Turnaround_Time_I__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults7= [Select AVG(Turnaround_Time_M__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults8= [Select AVG(Turnaround_Time_O__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults9= [Select AVG(CSI_Dealer__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults11= [Select AVG(CSI__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults12= [Select AVG(Facility_Audit__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    groupedResults13= [Select AVG(Parts_Ordering__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        groupedResults10= [Select AVG(Service_Dealer_Development__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    }
                    else{
                        groupedResults14= [Select AVG(ETC__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                    }
                }
            }
                if(groupedResults[0].get('expr0') !=null){
                  rgnAvg1=Double.valueOf(groupedResults[0].get('expr0'));
 
                }
                if(groupedResults2[0].get('expr0') !=null){
                    rgnAvg2=Double.valueOf(groupedResults2[0].get('expr0'));
                }
                if(groupedResults3[0].get('expr0') !=null){
                    rgnAvg3=Double.valueOf(groupedResults3[0].get('expr0'));
                }
                if(groupedResults4[0].get('expr0') !=null){
                    rgnAvg4=Double.valueOf(groupedResults4[0].get('expr0'));
                }
                if(groupedResults5[0].get('expr0') !=null){
                    rgnAvg5=Double.valueOf(groupedResults5[0].get('expr0'));
                }
                if(groupedResults6[0].get('expr0') !=null){
                    rgnAvg6=Double.valueOf(groupedResults6[0].get('expr0'));
                }
                if(groupedResults7[0].get('expr0') !=null){
                    rgnAvg7=Double.valueOf(groupedResults7[0].get('expr0'));
                }
                if(groupedResults8[0].get('expr0') !=null){
                    rgnAvg8=Double.valueOf(groupedResults8[0].get('expr0'));
                }
                if(groupedResults9[0].get('expr0') !=null){
                    rgnAvg9=Double.valueOf(groupedResults9[0].get('expr0'));
                }
            	if(FromDateYear <=2023 && ToDateYear <= 2023){
                	if(groupedResults10[0].get('expr0') !=null){
                     	rgnAvg10=Double.valueOf(groupedResults10[0].get('expr0'));
                	}
                }
                if(groupedResults11[0].get('expr0') !=null){
                     rgnAvg11=Double.valueOf(groupedResults11[0].get('expr0'));
                }
                if(groupedResults12[0].get('expr0') !=null){
                     rgnAvg12=Double.valueOf(groupedResults12[0].get('expr0'));
                }
                if(groupedResults13[0].get('expr0') !=null){
                     rgnAvg13=Double.valueOf(groupedResults13[0].get('expr0'));
                }
            	if(FromDateYear >=2024 && ToDateYear >= 2024){
           			if(groupedResults14[0].get('expr0') !=null){
                     	rgnAvg14=Double.valueOf(groupedResults14[0].get('expr0'));
                    }
                }
            	if(FromDateYear <=2023 && ToDateYear >= 2024){
                	if(groupedResults14[0].get('expr0') !=null){
                     	rgnAvg14=Double.valueOf(groupedResults14[0].get('expr0'));
                    }
                    if(groupedResults10[0].get('expr0') !=null){
                     	rgnAvg10=Double.valueOf(groupedResults10[0].get('expr0'));
                	}
            	}
            //list<Sobject>StoreDistData = new list<Sobject>();
            for(sobject sob : AllRecord){
                string ChangeFormat;
                string StoreDate = string.valueof(sob.get('Month__c'));
                string StoreYear = string.valueof(sob.get('Year__c'));
                //DateTime dt = Date.valueOf(StoreDate);
                //string ChangeFormat;
                String Month;
                string TotalMonthYear;
                if(StoreDate == '1'){
                    Month = 'Jan';
                }else if(StoreDate== '2'){
                    Month = 'Feb';
                }else if(StoreDate== '3'){
                    Month = 'Mar';
                }else if(StoreDate== '4'){
                    Month = 'Apr';
                }else if(StoreDate== '5'){
                    Month = 'May';
                }else if(StoreDate== '6'){
                    Month = 'Jun';
                }else if(StoreDate== '7'){
                    Month = 'Jul';
                }else if(StoreDate== '8'){
                    Month = 'Aug';
                }else if(StoreDate== '9'){
                    Month = 'Sep';
                }else if(StoreDate== '10'){
                    Month = 'Oct';
                }else if(StoreDate== '11'){
                    Month = 'Nov';
                }else if(StoreDate== '12'){
                    Month = 'Dec';
                }
                ChangeFormat = Month +' '+StoreYear;
               
                
                if(mapOffilterRes.keyset().contains(string.valueof(sob.get('Customer_ParentId__c'))) && monthValue.contains(Integer.valueof(sob.get('Month__c'))) && YearValue.contains(Integer.valueof(sob.get('Year__c'))) && String.valueof(sob.get('Period__c')) == PeriodType){
                    
                    //StoreDistData.add(sob);
                    if(newMap.keyset().contains(string.valueof(sob.get('Customer_ParentId__c')))){
                        map<string,list<sobject>> newmap2 = new map<string,list<sobject>>();
                        newmap2 = newMap.get(string.valueof(sob.get('Customer_ParentId__c')));
                        if(newmap2.keyset().contains(ChangeFormat)){
                            list<sobject>storeData = new list<sobject>();
                            storeData = newMap2.get(ChangeFormat);
                            storeData.add(sob);
                            newMap2.put(ChangeFormat,storeData);
                            newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                        }else{
                            list<sobject>storeData = new list<sobject>();
                            storeData.add(sob);
                            newMap2.put(ChangeFormat,storeData);
                            newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                            
                        }
                    }else{
                        map<string,list<sobject>> newmap2 = new map<string,list<sobject>>();
                        list<sobject>storeData2 = new list<sobject>();
                        storeData2.add(sob);
                        newMap2.put(ChangeFormat,storeData2);
                        newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                    }
                    //newMap.put(ChangeFormat,sob);
                }
                if(regionList.contains(string.valueof(sob.get('Region__c'))) && String.valueof(sob.get('Period__c')) == PeriodType && monthValue.contains(Integer.valueof(sob.get('Month__c'))) && YearValue.contains(Integer.valueof(sob.get('Year__c')))){
                    if(RegionMap.keyset().contains(string.valueof(sob.get('Region__c')))){ 
                        map<string,list<sobject>>RegionMap2 = RegionMap.get(string.valueof(sob.get('Region__c')));
                        if(RegionMap2.keyset().contains(ChangeFormat)){
                            list<sobject>storeData = new list<sobject>();
                            storeData = RegionMap2.get(ChangeFormat);
                            storeData.add(sob);
                            RegionMap2.put(ChangeFormat,storeData);
                            RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                        }else{
                            list<sobject>storeData = new list<sobject>();
                            storeData.add(sob);
                            RegionMap2.put(ChangeFormat,storeData);
                            RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                        }
                    }else{
                        map<string,list<sobject>>RegionMap2 = new map<string,list<sobject>>();
                        list<sobject>storeData = new list<sobject>();
                        storeData.add(sob);
                        RegionMap2.put(ChangeFormat,storeData);
                        RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                    }
                }
            }
            //system.debug('newMap: '+newMap);
            
            
            for(sObject tbl : tableData){
                //system.debug('tbl: '+tbl.get('Month_String__c'));
                if(RegionMap.keyset().contains(string.valueof(tbl.get('Region__c')))){
                    map<string,list<sobject>>RegionMap2 = RegionMap.get(string.valueof(tbl.get('Region__c')));
                    if(RegionMap2.keyset().contains(string.valueof(tbl.get('Month_String__c')))){
                       /* Decimal TotalrgnValue1 = 0;
                        Decimal TotalrgnValue2 = 0;
                        Decimal TotalrgnValue3 = 0;
                        Decimal TotalrgnValue4 = 0;
                        Decimal TotalrgnValue5 = 0;
                        Decimal TotalrgnValue6 = 0;
                        Decimal TotalrgnValue7 = 0;
                        Decimal TotalrgnValue8 = 0;
                        Decimal TotalrgnValue9 = 0;
                        Decimal TotalrgnValue10 = 0;*/
                        /*Decimal rgnAvg1;
                        Decimal rgnAvg2;
                        Decimal rgnAvg3;
                        Decimal rgnAvg4;
                        Decimal rgnAvg5;
                        Decimal rgnAvg6;
                        Decimal rgnAvg7;
                        Decimal rgnAvg8;
                        Decimal rgnAvg9;
                        Decimal rgnAvg10;*/
                        
                        //list<sobject>totalBranch = RegionMap2.get(string.valueof(tbl.get('Month_String__c')));
                        //system.debug('StoreRgntData: '+totalBranch.size());
                        /*for(sobject sob: totalBranch){
                            if(sob.get('CSI_Parts__c') !=null){
                                TotalrgnValue1 += Double.valueof(sob.get('CSI_Parts__c'));
                            }
                            if(sob.get('CSI_Service__c') !=null){
                                TotalrgnValue2 += Double.valueof(sob.get('CSI_Service__c'));
                            }
                            if(sob.get('Total_Parts_Sold_ReTran__c') != null){
                                TotalrgnValue3 += Double.valueof(sob.get('Total_Parts_Sold_ReTran__c'));
                            }
                            if(sob.get('TPS__c')!= null){
                                TotalrgnValue4 += Double.valueof(sob.get('TPS__c'));
                            }
                            if(sob.get('Training__c') !=null){
                                TotalrgnValue5 += Double.valueof(sob.get('Training__c'));
                            }
                            if(sob.get('Turnaround_Time_I__c')!=null){
                                TotalrgnValue6 += Double.valueof(sob.get('Turnaround_Time_I__c'));
                            }
                            if(sob.get('Turnaround_Time_M__c')!=null){
                                TotalrgnValue7 += Double.valueof(sob.get('Turnaround_Time_M__c'));
                            }
                            if(sob.get('Turnaround_Time_O__c')!=null){
                                TotalrgnValue8 += Double.valueof(sob.get('Turnaround_Time_O__c'));
                            }
                            if(sob.get('CSI_Dealer__c')!=null){
                                TotalrgnValue9 += Double.valueof(sob.get('CSI_Dealer__c'));
                            }
                            if(sob.get('Service_Dealer_Development__c')!=null){
                                TotalrgnValue10 += Double.valueof(sob.get('Service_Dealer_Development__c'));
                            }
                            //TotalValue9 += Double.valueof(sob.get('CSI_Parts__c'));
                            
                        }*/
                        
                        /*rgnAvg1 = TotalrgnValue1/totalBranch.size();
                        rgnAvg2 = TotalrgnValue2/totalBranch.size();
                        rgnAvg3 = TotalrgnValue3/totalBranch.size();
                        rgnAvg4 = TotalrgnValue4/totalBranch.size();
                        rgnAvg5 = TotalrgnValue5/totalBranch.size();
                        rgnAvg6 = TotalrgnValue6/totalBranch.size();
                        rgnAvg7 = TotalrgnValue7/totalBranch.size();
                        rgnAvg8 = TotalrgnValue8/totalBranch.size();
                        rgnAvg9 = TotalrgnValue9/totalBranch.size();
                        rgnAvg10 = TotalrgnValue10/totalBranch.size();*/
                        
                        if(newMap.keyset().contains(string.valueof(tbl.get('Customer_ParentId__c')))){
                            map<string,list<sobject>> newmap2 = newMap.get(string.valueof(tbl.get('Customer_ParentId__c')));
                            if(newMap2.keyset().contains(string.valueof(tbl.get('Month_String__c')))){
                                Decimal TotalValue1 = 0;
                                Decimal TotalValue2 = 0;
                                Decimal TotalValue3 = 0;
                                Decimal TotalValue4 = 0;
                                Decimal TotalValue5 = 0;
                                Decimal TotalValue6 = 0;
                                Decimal TotalValue7 = 0;
                                Decimal TotalValue8 = 0;
                                Decimal TotalValue9 = 0;
                                Decimal TotalValue10 = 0;
                                Decimal TotalValue11 = 0;
                                Decimal TotalValue12 = 0;
                                Decimal TotalValue13 = 0;
                                Decimal TotalValue14 = 0;
                                
                                list<sobject>StoreDistData = newmap2.get(string.valueof(tbl.get('Month_String__c')));
                                for(sobject sob: StoreDistData){
                                    if(sob.get('CSI_Parts__c')!=null){
                                        TotalValue1 += Double.valueof(sob.get('CSI_Parts__c'));
                                    }
                                    if(sob.get('CSI_Service__c')!=null){
                                        TotalValue2 += Double.valueof(sob.get('CSI_Service__c'));
                                    }
                                    if(sob.get('Total_Parts_Sold_ReTran__c')!=null){
                                        TotalValue3 += Double.valueof(sob.get('Total_Parts_Sold_ReTran__c'));
                                    }
                                    if(sob.get('TPS__c')!=null){
                                        TotalValue4 += Double.valueof(sob.get('TPS__c'));
                                    }
                                    if(sob.get('Training__c')!=null){
                                        TotalValue5 += Double.valueof(sob.get('Training__c'));
                                    }
                                    if(sob.get('Turnaround_Time_I__c')!=null){
                                        TotalValue6 += Double.valueof(sob.get('Turnaround_Time_I__c'));
                                    }
                                    if(sob.get('Turnaround_Time_M__c')!=null){
                                        TotalValue7 += Double.valueof(sob.get('Turnaround_Time_M__c'));
                                    }
                                    if(sob.get('Turnaround_Time_O__c')!=null){
                                        TotalValue8 += Double.valueof(sob.get('Turnaround_Time_O__c'));
                                    }
                                    if(sob.get('CSI_Dealer__c')!=null){
                                        TotalValue9 += Double.valueof(sob.get('CSI_Dealer__c'));
                                    }
                                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                                        if(sob.get('Service_Dealer_Development__c')!=null){
                                            TotalValue10 += Double.valueof(sob.get('Service_Dealer_Development__c'));
                                        }
                                    }
                                    if(FromDateYear >=2024 && ToDateYear >= 2024){
                                        if(sob.get('ETC__c')!=null){
                                            TotalValue14 += Double.valueof(sob.get('ETC__c'));
                                        }
                                    }
                                    if(FromDateYear <=2023 && ToDateYear >= 2024){
                                        if(sob.get('Service_Dealer_Development__c')!=null){
                                            TotalValue10 += Double.valueof(sob.get('Service_Dealer_Development__c'));
                                        }
                                        if(sob.get('ETC__c')!=null){
                                            TotalValue14 += Double.valueof(sob.get('ETC__c'));
                                        }
                                    }
                                    if(sob.get('CSI__c')!=null){
                                        TotalValue11 += Double.valueof(sob.get('CSI__c'));
                                    }
                                    if(sob.get('Facility_Audit__c')!=null){
                                        TotalValue12 += Double.valueof(sob.get('Facility_Audit__c'));
                                    }
                                    if(sob.get('Parts_Ordering__c')!=null){
                                        TotalValue13 += Double.valueof(sob.get('Parts_Ordering__c'));
                                    }
                                    //TotalValue9 += Double.valueof(sob.get('CSI_Parts__c'));
                                    
                                }
                                Decimal DistAvg1 = TotalValue1/StoreDistData.size();
                                Decimal DistAvg2 = TotalValue2/StoreDistData.size();
                                Decimal DistAvg3 = TotalValue3/StoreDistData.size();
                                Decimal DistAvg4 = TotalValue4/StoreDistData.size();
                                Decimal DistAvg5 = TotalValue5/StoreDistData.size();
                                Decimal DistAvg6 = TotalValue6/StoreDistData.size();
                                Decimal DistAvg7 = TotalValue7/StoreDistData.size();
                                Decimal DistAvg8 = TotalValue8/StoreDistData.size();
                                Decimal DistAvg9 = TotalValue9/StoreDistData.size();
                                Decimal DistAvg10 = TotalValue10/StoreDistData.size();
                                Decimal DistAvg11 = TotalValue11/StoreDistData.size();
                                Decimal DistAvg12 = TotalValue12/StoreDistData.size();
                                Decimal DistAvg13 = TotalValue13/StoreDistData.size();
                                Decimal DistAvg14 = TotalValue14/StoreDistData.size();
                                
                                sObject cloneRec14 = tbl.clone(false,false,false,false);
                                cloneRec14.put('Metric_Detail__c', 'CSI');
                                cloneRec14.put('Branch_Score__c', string.valueof(cloneRec14.get('CSI__c')));
                                cloneRec14.put('Distributor_Avg__c', DistAvg11.setScale(2,RoundingMode.HALF_UP));
                                cloneRec14.put('Region_Avg__c', string.valueof(rgnAvg11.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec12 = tbl.clone(false,false,false,false);
                                cloneRec12.put('Metric_Detail__c', 'Facility Audit');
                                cloneRec12.put('Branch_Score__c', string.valueof(cloneRec12.get('Facility_Audit__c')));
                                cloneRec12.put('Distributor_Avg__c', DistAvg12.setScale(2,RoundingMode.HALF_UP));
                                cloneRec12.put('Region_Avg__c', string.valueof(rgnAvg12.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec13 = tbl.clone(false,false,false,false);
                                cloneRec13.put('Metric_Detail__c', 'Parts Ordering');
                                cloneRec13.put('Branch_Score__c', string.valueof(cloneRec13.get('Parts_Ordering__c')));
                                cloneRec13.put('Distributor_Avg__c', DistAvg13.setScale(2,RoundingMode.HALF_UP));
                                cloneRec13.put('Region_Avg__c', string.valueof(rgnAvg13.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec = tbl.clone(false,false,false,false);
                                cloneRec.put('Metric_Detail__c', 'CSI Parts');
                                cloneRec.put('Branch_Score__c', string.valueof(cloneRec.get('CSI_Parts__c')));
                                cloneRec.put('Distributor_Avg__c', DistAvg1.setScale(2,RoundingMode.HALF_UP));
                                cloneRec.put('Region_Avg__c', string.valueof(rgnAvg1.setScale(2,RoundingMode.HALF_UP)));
                                
                                
                                sObject cloneRec2 = tbl.clone(false,false,false,false);
                                cloneRec2.put('Metric_Detail__c', 'CSI Service');
                                cloneRec2.put('Branch_Score__c', string.valueof(cloneRec2.get('CSI_Service__c')));
                                cloneRec2.put('Distributor_Avg__c', DistAvg2.setScale(2,RoundingMode.HALF_UP));
                                cloneRec2.put('Region_Avg__c', string.valueof(rgnAvg2.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec4 = tbl.clone(false,false,false,false);
                                cloneRec4.put('Metric_Detail__c', 'Total Parts ReTran Sold');
                                cloneRec4.put('Branch_Score__c', string.valueof(cloneRec4.get('Total_Parts_Sold_ReTran__c')));
                                cloneRec4.put('Distributor_Avg__c', DistAvg3.setScale(2,RoundingMode.HALF_UP));
                                cloneRec4.put('Region_Avg__c', string.valueof(rgnAvg3.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec5 = tbl.clone(false,false,false,false);
                                cloneRec5.put('Metric_Detail__c', 'Total Parts Sold');
                                cloneRec5.put('Branch_Score__c', string.valueof(cloneRec5.get('TPS__c')));
                                cloneRec5.put('Distributor_Avg__c', DistAvg4.setScale(2,RoundingMode.HALF_UP));
                                cloneRec5.put('Region_Avg__c', string.valueof(rgnAvg4.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec6 = tbl.clone(false,false,false,false);
                                cloneRec6.put('Metric_Detail__c', 'Training');
                                cloneRec6.put('Branch_Score__c', string.valueof(cloneRec6.get('Training__c')));
                                cloneRec6.put('Distributor_Avg__c', DistAvg5.setScale(2,RoundingMode.HALF_UP));
                                cloneRec6.put('Region_Avg__c', string.valueof(rgnAvg5.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec7 = tbl.clone(false,false,false,false);
                                cloneRec7.put('Metric_Detail__c', 'TT - In-Chassis');
                                cloneRec7.put('Branch_Score__c', string.valueof(cloneRec7.get('Turnaround_Time_I__c')));
                                cloneRec7.put('Distributor_Avg__c', DistAvg6.setScale(2,RoundingMode.HALF_UP));
                                cloneRec7.put('Region_Avg__c', string.valueof(rgnAvg6.setScale(2,RoundingMode.HALF_UP)));
                                
                                sObject cloneRec8= tbl.clone(false,false,false,false);
                                cloneRec8.put('Metric_Detail__c', 'TT - Maintenance');
                                cloneRec8.put('Branch_Score__c', string.valueof(cloneRec8.get('Turnaround_Time_M__c')));
                                cloneRec8.put('Distributor_Avg__c', DistAvg7.setScale(2,RoundingMode.HALF_UP));
                                cloneRec8.put('Region_Avg__c', string.valueof(rgnAvg7.setScale(2,RoundingMode.HALF_UP)));
                                
                                
                                sObject cloneRec9 = tbl.clone(false,false,false,false);
                                cloneRec9.put('Metric_Detail__c', 'TT - Out-of-Chassis');
                                cloneRec9.put('Branch_Score__c', string.valueof(cloneRec9.get('Turnaround_Time_O__c')));
                                cloneRec9.put('Distributor_Avg__c', DistAvg8.setScale(2,RoundingMode.HALF_UP));
                                cloneRec9.put('Region_Avg__c', string.valueof(rgnAvg8.setScale(2,RoundingMode.HALF_UP)));
                                
                                
                                sObject cloneRec10 = tbl.clone(false,false,false,false);
                                cloneRec10.put('Metric_Detail__c', 'Annual Dealer Experience');
                                cloneRec10.put('Branch_Score__c', string.valueof(cloneRec10.get('CSI_Dealer__c')));
                                cloneRec10.put('Distributor_Avg__c', DistAvg9.setScale(2,RoundingMode.HALF_UP));
                                cloneRec10.put('Region_Avg__c', string.valueof(rgnAvg9.setScale(2,RoundingMode.HALF_UP)));
                                
                                
                                sObject cloneRec11 = tbl.clone(false,false,false,false);
                                if(FromDateYear <=2023 && ToDateYear <= 2023){
                                    cloneRec11.put('Metric_Detail__c', 'Service Dealer Development');
                                    cloneRec11.put('Branch_Score__c', string.valueof(cloneRec11.get('Service_Dealer_Development__c')));
                                    cloneRec11.put('Distributor_Avg__c', DistAvg10.setScale(2,RoundingMode.HALF_UP));
                                    cloneRec11.put('Region_Avg__c', string.valueof(rgnAvg10.setScale(2,RoundingMode.HALF_UP)));
                                }
                                
                                sObject cloneRec15 = tbl.clone(false,false,false,false);
                                if(FromDateYear >=2024 && rgnAvg14!= null && ToDateYear >= 2024){
                                    cloneRec15.put('Metric_Detail__c', 'ETC Data');
                                    cloneRec15.put('Branch_Score__c', string.valueof(cloneRec15.get('ETC__c')));
                                    cloneRec15.put('Distributor_Avg__c', DistAvg14.setScale(2,RoundingMode.HALF_UP));
                                    cloneRec15.put('Region_Avg__c', string.valueof(rgnAvg14.setScale(2,RoundingMode.HALF_UP)));
                                }
                                
                                if(FromDateYear <=2023 && ToDateYear >= 2024){
                                    cloneRec11.put('Metric_Detail__c', 'Service Dealer Development');
                                    cloneRec11.put('Branch_Score__c', string.valueof(cloneRec11.get('Service_Dealer_Development__c')));
                                    cloneRec11.put('Distributor_Avg__c', DistAvg10.setScale(2,RoundingMode.HALF_UP));
                                    cloneRec11.put('Region_Avg__c', string.valueof(rgnAvg10.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    cloneRec15.put('Metric_Detail__c', 'ETC Data');
                                    cloneRec15.put('Branch_Score__c', string.valueof(cloneRec15.get('ETC__c')));
                                    cloneRec15.put('Distributor_Avg__c', DistAvg14.setScale(2,RoundingMode.HALF_UP));
                                    cloneRec15.put('Region_Avg__c', string.valueof(rgnAvg14.setScale(2,RoundingMode.HALF_UP)));
                                }
                                
                                ReturncompData.add(cloneRec14);
                                ReturncompData.add(cloneRec);
                                ReturncompData.add(cloneRec2);
                                //ReturncompData.add(cloneRec3);
                                ReturncompData.add(cloneRec4);
                                ReturncompData.add(cloneRec5);
                                ReturncompData.add(cloneRec6);
                                ReturncompData.add(cloneRec7);
                                ReturncompData.add(cloneRec8);
                                ReturncompData.add(cloneRec9);
                                ReturncompData.add(cloneRec10);
                                if(FromDateYear <=2023 && ToDateYear <= 2023){
                                    ReturncompData.add(cloneRec11);
                                }
                                ReturncompData.add(cloneRec12);
                                ReturncompData.add(cloneRec13);
                                if(FromDateYear >=2024 && ToDateYear >= 2024){
                                    ReturncompData.add(cloneRec15);
                                }
                                if(FromDateYear <=2023 && ToDateYear >= 2024){
                                    ReturncompData.add(cloneRec11);
                                    ReturncompData.add(cloneRec15);
                                }
                                
                                //ReturncompData.add(cloneRec);
                            }
                        }
                    }
                }
            }
            
           system.debug('ReturncompData: '+ReturncompData.size());            
            
            return ReturncompData;
        }else{
            list<sobject> performanceCompReport = new list<sobject>();
            
            if(selectedReportName == 'Performance Comparison Summary Report'){
                list<sobject>ReturncompData = new list<sobject>();
                Decimal countBranchForReport;
                Decimal TotalBranch=0;
                Decimal RecordCount = 0;
                list<string> StoreAllDistList = new list<string>();
                Decimal WholeBranchesOfdist;
                Decimal TotalAllDistBranch = 0;
                //new changes regarding region avg
                Decimal rgnAvg1 =0;
                Decimal rgnAvg2 =0;
                Decimal rgnAvg3=0;
                Decimal rgnAvg4=0;
                Decimal rgnAvg5=0;
                Decimal rgnAvg6=0;
                Decimal rgnAvg7=0;
                Decimal rgnAvg8=0;
                Decimal rgnAvg9=0;
                Decimal rgnAvg10=0;
                Decimal rgnAvg11=0;
                Decimal rgnAvg20=0;
                Decimal rgnAvg21=0;
                Decimal rgnAvg22=0;
                AggregateResult[] groupedResults;
                AggregateResult[] groupedResults2;
                AggregateResult[] groupedResults3;
                AggregateResult[] groupedResults4;
                AggregateResult[] groupedResults5;
                AggregateResult[] groupedResults6;
                AggregateResult[] groupedResults7;
                AggregateResult[] groupedResults8;
                AggregateResult[] groupedResults9;
                AggregateResult[] groupedResults10;
                AggregateResult[] groupedResults11;
                AggregateResult[] groupedResults20;
                AggregateResult[] groupedResults21;
                AggregateResult[] groupedResults22;
                if(regionList.contains('North America')){
                    groupedResults= [Select AVG(CSI_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults2= [Select AVG(CSI_Service_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults3= [Select AVG(Total_Parts_Sold_ReTran_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults4= [Select AVG(TPS_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults5= [Select AVG(Training_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults6= [Select AVG(Turnaround_Time_I_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults7= [Select AVG(Turnaround_Time_M_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults8= [Select AVG(Turnaround_Time_O_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults9= [Select AVG(CSI_Parts_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults10= [Select AVG(Facility_Audit_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults11= [Select AVG(Parts_Ordering_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    groupedResults20= [Select AVG(CSI_Dealer_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                        groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    }
                    else if(FromDateYear <=2023 && ToDateYear >= 2024){
                        groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                        groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    }
                    else{
                        groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth AND isPartOfPRP__c=true and Period__c =: PeriodType];
                    }
                }else{
                    if(SelectedPartnerType == 'Distributor'){
                        groupedResults= [Select AVG(CSI_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults2= [Select AVG(CSI_Service_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults3= [Select AVG(Total_Parts_Sold_ReTran_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults4= [Select AVG(TPS_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults5= [Select AVG(Training_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults6= [Select AVG(Turnaround_Time_I_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults7= [Select AVG(Turnaround_Time_M_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults8= [Select AVG(Turnaround_Time_O_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults9= [Select AVG(CSI_Parts_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults10= [Select AVG(Facility_Audit_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults11= [Select AVG(Parts_Ordering_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        groupedResults20= [Select AVG(CSI_Dealer_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        if(FromDateYear <=2023 && ToDateYear <= 2023){
                            groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        }
                        else if(FromDateYear <=2023 && ToDateYear >= 2024){
                            groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                            groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        }
                        else{
                            groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Distributor Branch'];
                        }
                    }else{
                        groupedResults= [Select AVG(CSI_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults2= [Select AVG(CSI_Service_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults3= [Select AVG(Total_Parts_Sold_ReTran_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults4= [Select AVG(TPS_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults5= [Select AVG(Training_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth  and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults6= [Select AVG(Turnaround_Time_I_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults7= [Select AVG(Turnaround_Time_M_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults8= [Select AVG(Turnaround_Time_O_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults9= [Select AVG(CSI_Parts_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults10= [Select AVG(Facility_Audit_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults11= [Select AVG(Parts_Ordering_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        groupedResults20= [Select AVG(CSI_Dealer_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        if(FromDateYear <=2023 && ToDateYear <= 2023){
                            groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        }
                        else if(FromDateYear <=2023 && ToDateYear >= 2024){
                            groupedResults21= [Select AVG(Service_Dealer_Development_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                            groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        }
                        else{
                            groupedResults22= [Select AVG(ETC_Score__c) from KPI__c where Region__c In:regionList  AND Year__c <=: ToDateYear and Year__c >=:FromDateYear  AND Month__c <=: ToDateMonth and Month__c >=: FromDateMonth and Period__c =: PeriodType and Customer__r.Type ='Direct Dealer' and isPartOfPRP__c=true];
                        }
                    }
                }
                    if(groupedResults[0].get('expr0') !=null){
                  rgnAvg1=Double.valueOf(groupedResults[0].get('expr0'));
 
                }
                if(groupedResults2[0].get('expr0') !=null){
                    rgnAvg2=Double.valueOf(groupedResults2[0].get('expr0'));
                }
                if(groupedResults3[0].get('expr0') !=null){
                    rgnAvg3=Double.valueOf(groupedResults3[0].get('expr0'));
                }
                if(groupedResults4[0].get('expr0') !=null){
                    rgnAvg4=Double.valueOf(groupedResults4[0].get('expr0'));
                }
                if(groupedResults5[0].get('expr0') !=null){
                    rgnAvg5=Double.valueOf(groupedResults5[0].get('expr0'));
                }
                if(groupedResults6[0].get('expr0') !=null){
                    rgnAvg6=Double.valueOf(groupedResults6[0].get('expr0'));
                }
                if(groupedResults7[0].get('expr0') !=null){
                    rgnAvg7=Double.valueOf(groupedResults7[0].get('expr0'));
                }
                if(groupedResults8[0].get('expr0') !=null){
                    rgnAvg8=Double.valueOf(groupedResults8[0].get('expr0'));
                }
                if(groupedResults9[0].get('expr0') !=null){
                    rgnAvg9=Double.valueOf(groupedResults9[0].get('expr0'));
                }
                if(groupedResults10[0].get('expr0') !=null){
                     rgnAvg10=Double.valueOf(groupedResults10[0].get('expr0'));
                }
                if(groupedResults11[0].get('expr0') !=null){
                    rgnAvg11=Double.valueOf(groupedResults11[0].get('expr0'));
                }
                if(groupedResults20[0].get('expr0') !=null){
                    rgnAvg20=Double.valueOf(groupedResults20[0].get('expr0'));
                }
                if(FromDateYear <=2023 && ToDateYear <= 2023){
                    if(groupedResults21[0].get('expr0') !=null){
                   		rgnAvg21=Double.valueOf(groupedResults21[0].get('expr0'));
                	}
                }
                if(FromDateYear >=2024 && ToDateYear >= 2024){
                	if(groupedResults22[0].get('expr0') !=null){
                    	rgnAvg22=Double.valueOf(groupedResults22[0].get('expr0'));
                	}
                }
                if(FromDateYear <=2023 && ToDateYear >= 2024){
                    if(groupedResults21[0].get('expr0') !=null){
                   		rgnAvg21=Double.valueOf(groupedResults21[0].get('expr0'));
                	}
                    if(groupedResults22[0].get('expr0') !=null){
                    	rgnAvg22=Double.valueOf(groupedResults22[0].get('expr0'));
                	}
                }
                map<string,map<string,list<sobject>>> newMap = new map<string,map<string,list<sobject>>>();
                map<string,map<string,list<sobject>>> RegionMap = new map<string,map<string,list<sobject>>>();
                //list<Sobject>StoreDistData = new list<Sobject>();
                for(sobject sob : AllRecord){
                    string ChangeFormat;
                    string StoreDate = string.valueof(sob.get('Month__c'));
                    string StoreYear = string.valueof(sob.get('Year__c'));
                    //DateTime dt = Date.valueOf(StoreDate);
                    //string ChangeFormat;
                    String Month;
                    string TotalMonthYear;
                    if(StoreDate == '1'){
                        Month = 'Jan';
                    }else if(StoreDate== '2'){
                        Month = 'Feb';
                    }else if(StoreDate== '3'){
                        Month = 'Mar';
                    }else if(StoreDate== '4'){
                        Month = 'Apr';
                    }else if(StoreDate== '5'){
                        Month = 'May';
                    }else if(StoreDate== '6'){
                        Month = 'Jun';
                    }else if(StoreDate== '7'){
                        Month = 'Jul';
                    }else if(StoreDate== '8'){
                        Month = 'Aug';
                    }else if(StoreDate== '9'){
                        Month = 'Sep';
                    }else if(StoreDate== '10'){
                        Month = 'Oct';
                    }else if(StoreDate== '11'){
                        Month = 'Nov';
                    }else if(StoreDate== '12'){
                        Month = 'Dec';
                    }
                    ChangeFormat = Month +' '+StoreYear;
                    if(mapOffilterRes.keyset().contains(string.valueof(sob.get('Customer_ParentId__c'))) && monthValue.contains(Integer.valueof(sob.get('Month__c'))) && YearValue.contains(Integer.valueof(sob.get('Year__c'))) && String.valueof(sob.get('Period__c')) == PeriodType){
                        //system.debug('enter line807');
                        //StoreDistData.add(sob);
                        if(newMap.keyset().contains(string.valueof(sob.get('Customer_ParentId__c')))){
                            map<string,list<sobject>> newmap2 = new map<string,list<sobject>>();
                            newmap2 = newMap.get(string.valueof(sob.get('Customer_ParentId__c')));
                            if(newmap2.keyset().contains(ChangeFormat)){
                                list<sobject>storeData = new list<sobject>();
                                storeData = newMap2.get(ChangeFormat);
                                storeData.add(sob);
                                newMap2.put(ChangeFormat,storeData);
                                newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                            }else{
                                list<sobject>storeData = new list<sobject>();
                                storeData.add(sob);
                                newMap2.put(ChangeFormat,storeData);
                                newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                                
                            }
                        }else{
                            map<string,list<sobject>> newmap2 = new map<string,list<sobject>>();
                            list<sobject>storeData2 = new list<sobject>();
                            storeData2.add(sob);
                            newMap2.put(ChangeFormat,storeData2);
                            newMap.put(string.valueof(sob.get('Customer_ParentId__c')),newMap2);
                        }
                        //newMap.put(ChangeFormat,sob);
                    }
                    if(regionList.contains(string.valueof(sob.get('Region__c'))) && String.valueof(sob.get('Period__c')) == PeriodType && monthValue.contains(Integer.valueof(sob.get('Month__c'))) && YearValue.contains(Integer.valueof(sob.get('Year__c')))){
                        if(RegionMap.keyset().contains(string.valueof(sob.get('Region__c')))){ 
                            map<string,list<sobject>>RegionMap2 = RegionMap.get(string.valueof(sob.get('Region__c')));
                            if(RegionMap2.keyset().contains(ChangeFormat)){
                                list<sobject>storeData = new list<sobject>();
                                storeData = RegionMap2.get(ChangeFormat);
                                storeData.add(sob);
                                RegionMap2.put(ChangeFormat,storeData);
                                RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                            }else{
                                list<sobject>storeData = new list<sobject>();
                                storeData.add(sob);
                                RegionMap2.put(ChangeFormat,storeData);
                                RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                            }
                        }else{
                            map<string,list<sobject>>RegionMap2 = new map<string,list<sobject>>();
                            list<sobject>storeData = new list<sobject>();
                            storeData.add(sob);
                            RegionMap2.put(ChangeFormat,storeData);
                            RegionMap.put(string.valueof(sob.get('Region__c')),RegionMap2);
                        }
                    }
                }            //system.debug('newMap: '+newMap);
                
                system.debug('line906: '+RegionMap);
                for(sObject tbl : tableData){
                    if(RegionMap.keyset().contains(string.valueof(tbl.get('Region__c')))){
                        //system.debug('line 863');
                        map<string,list<sobject>>RegionMap2 = RegionMap.get(string.valueof(tbl.get('Region__c')));
                        system.debug('RegionMap2: '+RegionMap2);
                        if(RegionMap2.keyset().contains(string.valueof(tbl.get('Month_String__c')))){
                            //system.debug('line 865');
                            /*Decimal TotalrgnValue1 = 0;
                            Decimal TotalrgnValue2 = 0;
                            Decimal TotalrgnValue3 = 0;
                            Decimal TotalrgnValue4 = 0;
                            Decimal TotalrgnValue5 = 0;
                            Decimal TotalrgnValue6 = 0;
                            Decimal TotalrgnValue7 = 0;
                            Decimal TotalrgnValue8 = 0;
                            Decimal TotalrgnValue9 = 0;
                            Decimal TotalrgnValue10 = 0;
                            Decimal TotalrgnValue11 = 0;
                            Decimal TotalrgnValue20 = 0;
                            Decimal TotalrgnValue21 = 0;*/
                           /*Decimal rgnAvg1;
                            Decimal rgnAvg2;
                            Decimal rgnAvg3;
                            Decimal rgnAvg4;
                            Decimal rgnAvg5;
                            Decimal rgnAvg6;
                            Decimal rgnAvg7;
                            Decimal rgnAvg8;
                            Decimal rgnAvg9;
                            Decimal rgnAvg10;
                            Decimal rgnAvg11;
                            Decimal rgnAvg20;
                            Decimal rgnAvg21;*/
                            
                            list<sobject>totalBranch2 = RegionMap2.get(string.valueof(tbl.get('Month_String__c')));
                            system.debug('StoreRgntData: '+totalBranch2.size());
                            /*for(sobject sob: totalBranch2){
                                if(sob.get('CSI_Score__c') == null){
                                    sob.put('CSI_Score__c',0);
                                }
                                TotalrgnValue9 += Double.valueof(sob.get('CSI_Score__c'));
                                if(sob.get('CSI_Parts_Score__c') == null){
                                    sob.put('CSI_Parts_Score__c',0);
                                } 
                                TotalrgnValue1 += Double.valueof(sob.get('CSI_Parts_Score__c'));
                                if(sob.get('CSI_Service_Score__c') == null){
                                    sob.put('CSI_Service_Score__c',0);
                                } 
                                TotalrgnValue2 += Double.valueof(sob.get('CSI_Service_Score__c'));
                                if(sob.get('Total_Parts_Sold_ReTran_Score__c') == null){
                                    sob.put('Total_Parts_Sold_ReTran_Score__c',0);
                                } 
                                TotalrgnValue3 += Double.valueof(sob.get('Total_Parts_Sold_ReTran_Score__c'));
                                if(sob.get('TPS_Score__c') == null){
                                    sob.put('TPS_Score__c',0);
                                } 
                                TotalrgnValue4 += Double.valueof(sob.get('TPS_Score__c'));
                                if(sob.get('Training_Score__c') == null){
                                    sob.put('Training_Score__c',0);
                                } 
                                TotalrgnValue5 += Double.valueof(sob.get('Training_Score__c'));
                                
                                if(sob.get('Turnaround_Time_I_Score__c') == null){
                                    sob.put('Turnaround_Time_I_Score__c',0);
                                }
                                TotalrgnValue6 += Double.valueof(sob.get('Turnaround_Time_I_Score__c'));
                                if(sob.get('Turnaround_Time_M_Score__c') == null){
                                    sob.put('Turnaround_Time_M_Score__c',0);
                                } 
                                TotalrgnValue7 += Double.valueof(sob.get('Turnaround_Time_M_Score__c'));
                                if(sob.get('Turnaround_Time_O_Score__c') == null){
                                    sob.put('Turnaround_Time_O_Score__c',0);
                                } 
                                TotalrgnValue8 += Double.valueof(sob.get('Turnaround_Time_O_Score__c'));
                                
                                if(sob.get('Facility_Audit_Score__c') == null){
                                    sob.put('Facility_Audit_Score__c',0);
                                } 
                                TotalrgnValue10 += Double.valueof(sob.get('Facility_Audit_Score__c'));
                                
                                if(sob.get('Parts_Ordering_Score__c') == null){
                                    sob.put('Parts_Ordering_Score__c',0);
                                } 
                                TotalrgnValue11 += Double.valueof(sob.get('Parts_Ordering_Score__c'));
                                //TotalValue9 += Double.valueof(sob.get('CSI_Parts__c'));
                                
                                if(sob.get('CSI_Dealer_Score__c') == null){
                                    sob.put('CSI_Dealer_Score__c',0);
                                } 
                                TotalrgnValue20 += Double.valueof(sob.get('CSI_Dealer_Score__c'));
                                
                                if(sob.get('Service_Dealer_Development_Score__c') == null){
                                    sob.put('Service_Dealer_Development_Score__c',0);
                                } 
                                TotalrgnValue21 += Double.valueof(sob.get('Service_Dealer_Development_Score__c'));
                            }*/
                            //system.debug('line 1002: '+TotalrgnValue7);
                            //system.debug('line 1003: '+TotalrgnValue7/totalBranch2.size());
                            /*rgnAvg1 = TotalrgnValue1/totalBranch2.size();
                            rgnAvg2 = TotalrgnValue2/totalBranch2.size();
                            rgnAvg3 = TotalrgnValue3/totalBranch2.size();
                            rgnAvg4 = TotalrgnValue4/totalBranch2.size();
                            rgnAvg5 = TotalrgnValue5/totalBranch2.size();
                            rgnAvg6 = TotalrgnValue6/totalBranch2.size();
                            rgnAvg7 = TotalrgnValue7/totalBranch2.size();
                            rgnAvg8 = TotalrgnValue8/totalBranch2.size();
                            rgnAvg9 = TotalrgnValue9/totalBranch2.size();
                            rgnAvg10 = TotalrgnValue10/totalBranch2.size();
                            rgnAvg11 = TotalrgnValue11/totalBranch2.size();
                            rgnAvg20 = TotalrgnValue20/totalBranch2.size();
                            rgnAvg21 = TotalrgnValue21/totalBranch2.size();*/
                            
                            if(newMap.keyset().contains(string.valueof(tbl.get('Customer_ParentId__c')))){
                                map<string,list<sobject>> newmap2 = newMap.get(string.valueof(tbl.get('Customer_ParentId__c')));
                                if(newMap2.keyset().contains(string.valueof(tbl.get('Month_String__c')))){
                                    Decimal TotalValue1 = 0;
                                    Decimal TotalValue2 = 0;
                                    Decimal TotalValue3 = 0;
                                    Decimal TotalValue4 = 0;
                                    Decimal TotalValue5 = 0;
                                    Decimal TotalValue6 = 0;
                                    Decimal TotalValue7 = 0;
                                    Decimal TotalValue8 = 0;
                                    Decimal TotalValue9 = 0;
                                    Decimal TotalValue10 = 0;
                                    Decimal TotalValue11 = 0;
                                    Decimal TotalValue20 = 0;
                                    Decimal TotalValue21 = 0;
                                    Decimal TotalValue22 = 0;
                                    system.debug('line 1035: '+newmap2);
                                    system.debug('line 1036: '+string.valueof(tbl.get('Month_String__c')));
                                    list<sobject>StoreDistData = newmap2.get(string.valueof(tbl.get('Month_String__c')));
                                    RecordCount = 0;
                                    for(sobject sob: StoreDistData){
                                        if(sob.get('CSI_Score__c') == null){
                                            sob.put('CSI_Score__c',0);
                                        }
                                        if(Integer.valueof(sob.get('CSI_Score__c'))>0){
                                            RecordCount++;
                                        }
                                        TotalValue9 += Double.valueof(sob.get('CSI_Score__c'));
                                        
                                        if(sob.get('CSI_Parts_Score__c') == null){
                                            sob.put('CSI_Parts_Score__c',0);
                                        } 
                                        TotalValue1 += Double.valueof(sob.get('CSI_Parts_Score__c'));
                                        if(sob.get('CSI_Service_Score__c') == null){
                                            sob.put('CSI_Service_Score__c',0);
                                        }
                                        TotalValue2 += Double.valueof(sob.get('CSI_Service_Score__c'));
                                        if(sob.get('Total_Parts_Sold_ReTran_Score__c') == null){
                                            sob.put('Total_Parts_Sold_ReTran_Score__c',0);
                                        }
                                        TotalValue3 += Double.valueof(sob.get('Total_Parts_Sold_ReTran_Score__c'));
                                        if(sob.get('TPS_Score__c') == null){
                                            sob.put('TPS_Score__c',0);
                                        }
                                        TotalValue4 += Double.valueof(sob.get('TPS_Score__c'));
                                        if(sob.get('Training_Score__c') == null){
                                            sob.put('Training_Score__c',0);
                                        }
                                        TotalValue5 += Double.valueof(sob.get('Training_Score__c'));
                                        if(sob.get('Turnaround_Time_I_Score__c') == null){
                                            sob.put('Turnaround_Time_I_Score__c',0);
                                        }
                                        TotalValue6 += Double.valueof(sob.get('Turnaround_Time_I_Score__c'));
                                        if(sob.get('Turnaround_Time_M_Score__c') == null){
                                            sob.put('Turnaround_Time_M_Score__c',0);
                                        }
                                        TotalValue7 += Double.valueof(sob.get('Turnaround_Time_M_Score__c'));
                                        if(sob.get('Turnaround_Time_O_Score__c') == null){
                                            sob.put('Turnaround_Time_O_Score__c',0);
                                        }
                                        TotalValue8 += Double.valueof(sob.get('Turnaround_Time_O_Score__c'));
                                        //TotalValue9 += Double.valueof(sob.get('CSI_Parts__c'));
                                        if(sob.get('Facility_Audit_Score__c') == null){
                                            sob.put('Facility_Audit_Score__c',0);
                                        } 
                                        TotalValue10 += Double.valueof(sob.get('Facility_Audit_Score__c'));
                                        
                                        if(sob.get('Parts_Ordering_Score__c') == null){
                                            sob.put('Parts_Ordering_Score__c',0);
                                        } 
                                        TotalValue11 += Double.valueof(sob.get('Parts_Ordering_Score__c'));
                                        
                                        if(sob.get('CSI_Dealer_Score__c') == null){
                                            sob.put('CSI_Dealer_Score__c',0);
                                        } 
                                        TotalValue20 += Double.valueof(sob.get('CSI_Dealer_Score__c'));
                                        if(FromDateYear <=2023 && ToDateYear <= 2023){
                                            if(sob.get('Service_Dealer_Development_Score__c') == null){
                                                sob.put('Service_Dealer_Development_Score__c',0);
                                            } 
                                            TotalValue21 += Double.valueof(sob.get('Service_Dealer_Development_Score__c'));
                                        }
                                        
                                        if(FromDateYear >=2024 && ToDateYear >= 2024){
                                            if(sob.get('ETC_Score__c') == null){
                                                sob.put('ETC_Score__c',0);
                                            } 
                                            TotalValue22 += Double.valueof(sob.get('ETC_Score__c'));
                                        }
                                        if(FromDateYear <=2023 && ToDateYear >= 2024){
                                            if(sob.get('Service_Dealer_Development_Score__c') == null){
                                                sob.put('Service_Dealer_Development_Score__c',0);
                                            } 
                                            TotalValue21 += Double.valueof(sob.get('Service_Dealer_Development_Score__c'));
                                            
                                            if(sob.get('ETC_Score__c') == null){
                                                sob.put('ETC_Score__c',0);
                                            } 
                                            TotalValue22 += Double.valueof(sob.get('ETC_Score__c'));
                                        }
                                    }
                                    Decimal DistAvg1 = TotalValue1/StoreDistData.size();
                                    Decimal DistAvg2 = TotalValue2/StoreDistData.size();
                                    Decimal DistAvg3 = TotalValue3/StoreDistData.size();
                                    Decimal DistAvg4 = TotalValue4/StoreDistData.size();
                                    Decimal DistAvg5 = TotalValue5/StoreDistData.size();
                                    Decimal DistAvg6 = TotalValue6/StoreDistData.size();
                                    Decimal DistAvg7 = TotalValue7/StoreDistData.size();
                                    Decimal DistAvg8 = TotalValue8/StoreDistData.size();
                                    Decimal DistAvg9 = TotalValue9/RecordCount;
                                    Decimal DistAvg10 = TotalValue10/StoreDistData.size();
                                    Decimal DistAvg11 = TotalValue11/StoreDistData.size();
                                    Decimal DistAvg20 = TotalValue20/StoreDistData.size();
                                    Decimal DistAvg21 = TotalValue21/StoreDistData.size();
                                    Decimal DistAvg22 = TotalValue22/StoreDistData.size();
                                    
                                    sObject cloneRec11 = tbl.clone(false,false,false,false);
                                    cloneRec11.put('Metric_Detail__c', 'Facility Audit');
                                    if(cloneRec11.get('Facility_Audit_Score__c') == null ||cloneRec11.get('Facility_Audit_Score__c') == '' ){
                                        cloneRec11.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec11.put('Branch_Score__c', string.valueof(cloneRec11.get('Facility_Audit_Score__c')));
                                    }
                                    cloneRec11.put('Distributor_Avg__c', DistAvg10.setScale(2,RoundingMode.HALF_UP));
                                    
                                   if(rgnAvg10 != null) cloneRec11.put('Region_Avg__c', string.valueof(rgnAvg10.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec12 = tbl.clone(false,false,false,false);
                                    cloneRec12.put('Metric_Detail__c', 'Parts Ordering');
                                    if(cloneRec12.get('Parts_Ordering_Score__c') == null ||cloneRec12.get('Parts_Ordering_Score__c') == '' ){
                                        cloneRec12.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec12.put('Branch_Score__c', string.valueof(cloneRec12.get('Parts_Ordering_Score__c')));
                                    }
                                    cloneRec12.put('Distributor_Avg__c', DistAvg11.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg11 != null) cloneRec12.put('Region_Avg__c', string.valueof(rgnAvg11.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec10 = tbl.clone(false,false,false,false);
                                    cloneRec10.put('Metric_Detail__c', 'CSI');
                                    if(cloneRec10.get('CSI_Score__c') == null ||cloneRec10.get('CSI_Score__c') == '' ){
                                        cloneRec10.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec10.put('Branch_Score__c', string.valueof(cloneRec10.get('CSI_Score__c')));
                                    }
                                    
                                    cloneRec10.put('Distributor_Avg__c', DistAvg9.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg1 != null) cloneRec10.put('Region_Avg__c', string.valueof(rgnAvg1.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec = tbl.clone(false,false,false,false);
                                    cloneRec.put('Metric_Detail__c', 'CSI Parts');
                                    if(cloneRec.get('CSI_Parts_Score__c') == null ||cloneRec.get('CSI_Parts_Score__c') == '' ){
                                        cloneRec.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec.put('Branch_Score__c', string.valueof(cloneRec.get('CSI_Parts_Score__c')));
                                    }
                                    //cloneRec.put('Branch_Score__c', string.valueof(cloneRec.get('CSI_Parts_Score__c')));
                                    cloneRec.put('Distributor_Avg__c', DistAvg1.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg9 != null) cloneRec.put('Region_Avg__c', string.valueof(rgnAvg9.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec2 = tbl.clone(false,false,false,false);
                                    cloneRec2.put('Metric_Detail__c', 'CSI Service');
                                    if(cloneRec2.get('CSI_Service_Score__c') == null ||cloneRec2.get('CSI_Service_Score__c') == '' ){
                                        cloneRec2.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec2.put('Branch_Score__c', string.valueof(cloneRec2.get('CSI_Service_Score__c')));
                                    }
                                    //cloneRec2.put('Branch_Score__c', string.valueof(cloneRec.get('CSI_Service_Score__c')));
                                    cloneRec2.put('Distributor_Avg__c', DistAvg2.setScale(2,RoundingMode.HALF_UP));
                                    if(rgnAvg2 != null) cloneRec2.put('Region_Avg__c', string.valueof(rgnAvg2.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec4 = tbl.clone(false,false,false,false);
                                    cloneRec4.put('Metric_Detail__c', 'Total Parts ReTran Sold');
                                    if(cloneRec4.get('Total_Parts_Sold_ReTran_Score__c') == null ||cloneRec4.get('Total_Parts_Sold_ReTran_Score__c') == '' ){
                                        cloneRec4.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec4.put('Branch_Score__c', string.valueof(cloneRec4.get('Total_Parts_Sold_ReTran_Score__c')));
                                    }
                                    //cloneRec4.put('Branch_Score__c', string.valueof(cloneRec.get('Total_Parts_Sold_ReTran_Score__c')));
                                    cloneRec4.put('Distributor_Avg__c', DistAvg3.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg3 != null) cloneRec4.put('Region_Avg__c', string.valueof(rgnAvg3.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec5 = tbl.clone(false,false,false,false);
                                    cloneRec5.put('Metric_Detail__c', 'Total Parts Sold');
                                    if(cloneRec5.get('TPS_Score__c') == null ||cloneRec5.get('TPS_Score__c') == '' ){
                                        cloneRec5.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec5.put('Branch_Score__c', string.valueof(cloneRec5.get('TPS_Score__c')));
                                    }
                                    //cloneRec5.put('Branch_Score__c', string.valueof(cloneRec.get('TPS_Score__c')));
                                    cloneRec5.put('Distributor_Avg__c', DistAvg4.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg4 != null) cloneRec5.put('Region_Avg__c', string.valueof(rgnAvg4.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec6 = tbl.clone(false,false,false,false);
                                    cloneRec6.put('Metric_Detail__c', 'Training');
                                    if(cloneRec6.get('Training_Score__c') == null ||cloneRec6.get('Training_Score__c') == '' ){
                                        cloneRec6.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec6.put('Branch_Score__c', string.valueof(cloneRec6.get('Training_Score__c')));
                                    }
                                    //cloneRec6.put('Branch_Score__c', string.valueof(cloneRec.get('Training_Score__c')));
                                    cloneRec6.put('Distributor_Avg__c', DistAvg5.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg5 != null) cloneRec6.put('Region_Avg__c', string.valueof(rgnAvg5.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec7 = tbl.clone(false,false,false,false);
                                    cloneRec7.put('Metric_Detail__c', 'TT - In-Chassis');
                                    if(cloneRec7.get('Turnaround_Time_I_Score__c') == null ||cloneRec7.get('Turnaround_Time_I_Score__c') == '' ){
                                        cloneRec7.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec7.put('Branch_Score__c', string.valueof(cloneRec7.get('Turnaround_Time_I_Score__c')));
                                    }
                                    //cloneRec7.put('Branch_Score__c', string.valueof(cloneRec.get('Turnaround_Time_I_Score__c')));
                                    cloneRec7.put('Distributor_Avg__c', DistAvg6.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg6  != null) cloneRec7.put('Region_Avg__c', string.valueof(rgnAvg6.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec8= tbl.clone(false,false,false,false);
                                    cloneRec8.put('Metric_Detail__c', 'TT - Maintenance');
                                    if(cloneRec8.get('Turnaround_Time_M_Score__c') == null ||cloneRec8.get('Turnaround_Time_M_Score__c') == '' ){
                                        cloneRec8.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec8.put('Branch_Score__c', string.valueof(cloneRec8.get('Turnaround_Time_M_Score__c')));
                                    }
                                    //cloneRec8.put('Branch_Score__c', string.valueof(cloneRec.get('Turnaround_Time_M_Score__c')));
                                    cloneRec8.put('Distributor_Avg__c', DistAvg7.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg7 != null) cloneRec8.put('Region_Avg__c', string.valueof(rgnAvg7.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    sObject cloneRec9 = tbl.clone(false,false,false,false);
                                    cloneRec9.put('Metric_Detail__c', 'TT - Out-of-Chassis');
                                    if(cloneRec9.get('Turnaround_Time_O_Score__c') == null ||cloneRec9.get('Turnaround_Time_O_Score__c') == '' ){
                                        cloneRec9.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec9.put('Branch_Score__c', string.valueof(cloneRec9.get('Turnaround_Time_O_Score__c')));
                                    }
                                    //cloneRec9.put('Branch_Score__c', string.valueof(cloneRec.get('Turnaround_Time_O_Score__c')));
                                    cloneRec9.put('Distributor_Avg__c', DistAvg8.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg8 != null) cloneRec9.put('Region_Avg__c', string.valueof(rgnAvg8.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    // add Annual Dealer Experience and Service Dealer Development Dt.04/13/21
                                       
                                    sObject cloneRec20 = tbl.clone(false,false,false,false);
                                    cloneRec20.put('Metric_Detail__c', 'Annual Dealer Experience');
                                    if(cloneRec20.get('CSI_Dealer_Score__c') == null ||cloneRec20.get('CSI_Dealer_Score__c') == '' ){
                                        cloneRec20.put('Branch_Score__c', '0');
                                    }else{
                                        cloneRec20.put('Branch_Score__c', string.valueof(cloneRec20.get('CSI_Dealer_Score__c')));
                                    }
                                    cloneRec20.put('Distributor_Avg__c', DistAvg20.setScale(2,RoundingMode.HALF_UP));
                                     if(rgnAvg20 != null) cloneRec20.put('Region_Avg__c', string.valueof(rgnAvg20.setScale(2,RoundingMode.HALF_UP)));
                                    
                                    
                                    sObject cloneRec21 = tbl.clone(false,false,false,false);
                                    if(FromDateYear <=2023 && ToDateYear <= 2023){
                                        cloneRec21.put('Metric_Detail__c', 'Service Dealer Development');
                                        if(cloneRec21.get('Service_Dealer_Development_Score__c') == null ||cloneRec21.get('Service_Dealer_Development_Score__c') == '' ){
                                            cloneRec21.put('Branch_Score__c', '0');
                                        }else{
                                            cloneRec21.put('Branch_Score__c', string.valueof(cloneRec21.get('Service_Dealer_Development_Score__c')));
                                        }
                                        cloneRec21.put('Distributor_Avg__c', DistAvg21.setScale(2,RoundingMode.HALF_UP));
                                        if(rgnAvg21 != null) cloneRec21.put('Region_Avg__c', string.valueof(rgnAvg21.setScale(2,RoundingMode.HALF_UP)));
                                    }
                                    
                                    sObject cloneRec22 = tbl.clone(false,false,false,false);
                                    if(FromDateYear >=2024 && ToDateYear >= 2024){
                                        cloneRec22.put('Metric_Detail__c', 'ETC Data');
                                        if(cloneRec22.get('ETC_Score__c') == null ||cloneRec22.get('ETC_Score__c') == '' ){
                                            cloneRec22.put('Branch_Score__c', '0');
                                        }else{
                                            cloneRec22.put('Branch_Score__c', string.valueof(cloneRec22.get('ETC_Score__c')));
                                        }
                                        cloneRec22.put('Distributor_Avg__c', DistAvg22.setScale(2,RoundingMode.HALF_UP));
                                        if(rgnAvg22 != null) cloneRec22.put('Region_Avg__c', string.valueof(rgnAvg22.setScale(2,RoundingMode.HALF_UP)));
                                    }
                                    
                                    if(FromDateYear <=2023 && ToDateYear >= 2024){
                                        cloneRec21.put('Metric_Detail__c', 'Service Dealer Development');
                                        if(cloneRec21.get('Service_Dealer_Development_Score__c') == null ||cloneRec21.get('Service_Dealer_Development_Score__c') == '' ){
                                            cloneRec21.put('Branch_Score__c', '0');
                                        }else{
                                            cloneRec21.put('Branch_Score__c', string.valueof(cloneRec21.get('Service_Dealer_Development_Score__c')));
                                        }
                                        cloneRec21.put('Distributor_Avg__c', DistAvg21.setScale(2,RoundingMode.HALF_UP));
                                        if(rgnAvg21 != null) cloneRec21.put('Region_Avg__c', string.valueof(rgnAvg21.setScale(2,RoundingMode.HALF_UP)));
                                        
                                        
                                        cloneRec22.put('Metric_Detail__c', 'ETC Data');
                                        if(cloneRec22.get('ETC_Score__c') == null ||cloneRec22.get('ETC_Score__c') == '' ){
                                            cloneRec22.put('Branch_Score__c', '0');
                                        }else{
                                            cloneRec22.put('Branch_Score__c', string.valueof(cloneRec22.get('ETC_Score__c')));
                                        }
                                        cloneRec22.put('Distributor_Avg__c', DistAvg22.setScale(2,RoundingMode.HALF_UP));
                                        if(rgnAvg22 != null) cloneRec22.put('Region_Avg__c', string.valueof(rgnAvg22.setScale(2,RoundingMode.HALF_UP)));
                                    }
                                    
                                    if(MetricDetail.contains('CSI_Parts__c')){
                                        ReturncompData.add(cloneRec);
                                    }
                                    if(MetricDetail.contains('CSI_Service__c')){
                                        ReturncompData.add(cloneRec2);
                                    }
                                    if(MetricDetail.contains('Total_Parts_Sold_ReTran__c')){
                                        ReturncompData.add(cloneRec4);
                                    }
                                    //ReturncompData.add(cloneRec3);
                                    if(MetricDetail.contains('TPS__c')){
                                        ReturncompData.add(cloneRec5);
                                    }
                                    if(MetricDetail.contains('Training__c')){
                                        system.debug('check enter 1217');
                                        ReturncompData.add(cloneRec6);
                                    }
                                    if(MetricDetail.contains('Turnaround_Time_I__c')){
                                        ReturncompData.add(cloneRec7);
                                    }
                                    if(MetricDetail.contains('Turnaround_Time_M__c')){
                                        ReturncompData.add(cloneRec8);
                                    }
                                    if(MetricDetail.contains('Turnaround_Time_O__c')){
                                        ReturncompData.add(cloneRec9);
                                    }
                                    if(MetricDetail.contains('CSI__c')){
                                        ReturncompData.add(cloneRec10);
                                    }
                                    if(MetricDetail.contains('Facility_Audit__c')){
                                        ReturncompData.add(cloneRec11);
                                    }
                                    if(MetricDetail.contains('Parts_Ordering__c')){
                                        ReturncompData.add(cloneRec12);
                                    }
                                    
                                    if(MetricDetail.contains('CSI_Dealer__c')){
                                        ReturncompData.add(cloneRec20);
                                    }
                                    
                                    if(MetricDetail.contains('Service_Dealer_Development__c')){
                                        ReturncompData.add(cloneRec21);
                                    }
                                    if(MetricDetail.contains('ETC__c')){
                                        ReturncompData.add(cloneRec22);
                                    }
                                    //system.debug('ReturncompData: '+ReturncompData.size());
                                    //ReturncompData.add(cloneRec);
                                }
                            }
                        }
                    }
                }
                
                return ReturncompData;
            }else{
                //system.debug('tableDataNewAfterFormat: '+tableData);
                return tableData; 
            }
            
        }
    }
    
    
    
    @AuraEnabled
    public static List<pickListWrapper> MetricDetail(){
        list<Metric_Detail__mdt> Metric = new list<Metric_Detail__mdt>([select API_name__c,MasterLabel from Metric_Detail__mdt]);
        List<pickListWrapper> MetricValue = new List<pickListWrapper>();
        for(Metric_Detail__mdt mtr : Metric){
            MetricValue.add(new pickListWrapper(mtr.API_name__c,mtr.MasterLabel));
        }
        return MetricValue;
    }
    @AuraEnabled
    public static List<string> ReportList(){
        list<string>ReportName = new list<string>();
        list<All_Metric_Result_ReportName__mdt> Report = new list<All_Metric_Result_ReportName__mdt>([select id,Report_Name__c from All_Metric_Result_ReportName__mdt]);
        for(All_Metric_Result_ReportName__mdt rpt : Report){
            ReportName.add(rpt.Report_Name__c);
        }
        return ReportName;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> regionList(){
        List<pickListWrapper> pickListValuesList= new List<pickListWrapper>();
        Schema.DescribeFieldResult fieldResult = Account.Sales_RegionA__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new pickListWrapper(pickListVal.getLabel(),pickListVal.getLabel()));
        } 
        System.debug(pickListValuesList);
        return pickListValuesList;
    }
    @AuraEnabled
    public static profilewrapp profileCheck(){
        system.debug('Enter1180');
        Set<Id> IdOfAccounts = new Set<Id>();
        List<Account> account = new List<Account>();
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        List<pickListWrapper> DistributorNames = new List<pickListWrapper>();
        list<pickListWrapper> RegionName = new list<pickListWrapper>();
        string PartnerType;
        
        Id profileId=userinfo.getProfileId(); 
        // String profileName=[Select Id,Name from Profile where Id='00e0r000000M2lZAAS'].Name;
        String profileName=[Select Id,Name from Profile where Id=: profileId].Name;
        
        //CHG44065 Removing the PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               profileName=pmap.get(s);
            }
        }*/
        if(profileName == 'PRP Partner'){
            ID userId = UserInfo.getUserId();
            //User u = [select id, contact.AccountId from User where id = '0050r000001GlO4AAK' LIMIT 1];
            User u = [select id, contact.AccountId from User where id =: userId LIMIT 1];
            List<AccountContactRelation> accRel = new List<AccountContactRelation>([SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :u.ContactId]);
            for(AccountContactRelation ac : accRel){
                IdOfAccounts.add(ac.AccountId);
            }
            account = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c FROM Account WHERE ID IN: IdOfAccounts];
            if(account.size() > 0){
                for(Account acc:account){
                    DistributorNames.add(new pickListWrapper(acc.Id,acc.name+'('+acc.SAP_ID__c+')'));
                    RegionName.add(new pickListWrapper(acc.Sales_RegionA__c,acc.Sales_RegionA__c));
                    PartnerType = account[0].Type;
                }
            }
            /*List<Account> accountList = new List<Account>([Select id,name,Type, AccountSAPField__c  from Account where parentId = :DistributorNames[0].ID]);
for(Account acc : accountList){
AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
} */ 
        }
        system.debug('test1211: '+RegionName);
        system.debug('test1212: '+DistributorNames);
        return new profilewrapp(DistributorNames,RegionName,PartnerType,profileName);
    }
    public Class pickListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        public pickListWrapper(String Idx,String Namex){
            this.Id=Idx;
            this.Name = Namex;         
        }
    }
    
    public Class regionAndFields{
        @AuraEnabled public List<pickListWrapper> fields;
        @AuraEnabled public List<pickListWrapper> RegionNames;
        @AuraEnabled public List<pickListWrapper> defaultFields;
        @AuraEnabled public String objectName;
        @AuraEnabled public List<pickListWrapper> MetricValue;
        
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames, List<pickListWrapper> defaultFields, String objectName,List<pickListWrapper> MetricValue){
            this.fields = fields;
            this.RegionNames = RegionNames;
            this.defaultFields = defaultFields;
            this.objectName = objectName;
            this.MetricValue = MetricValue;
            
        }
    }
    public class profilewrapp{
        @AuraEnabled public List<pickListWrapper> DistributorNames;
        @AuraEnabled public List<pickListWrapper> RegionName;
        @AuraEnabled public String PartnerType;
        @AuraEnabled public String profileName;
        public profilewrapp(List<pickListWrapper> DistributorNames,List<pickListWrapper> RegionName,String PartnerType,String profileName){
            this.DistributorNames = DistributorNames;
            this.RegionName = RegionName;
            this.PartnerType = PartnerType;
            this.profileName = profileName;
        }
    }
    @AuraEnabled
    public static List<pickListWrapper> MetricDetailForDate(Date DateFrm, Date DateTo){
        system.debug('Date from like 1874 : '+DateFrm+' Date to : '+DateTo);
        Integer FromDateYear = DateFrm.Year();
        Integer ToDateYear = DateTo.Year();
        system.debug('Date from like 1874 : '+FromDateYear);
        If(FromDateYear <=2023){
            FromDateYear = 2023;
        }
        else if(FromDateYear >=2024){
            FromDateYear = 2024;
        }
        
        if(ToDateYear <=2023){
            ToDateYear = 2023;
        }
        else if(ToDateYear >=2024){
            ToDateYear = 2024;
        }
        list<Metric_Detail__mdt> Metric = new list<Metric_Detail__mdt>([select API_name__c,MasterLabel from Metric_Detail__mdt where ((year__c =:FromDateYear OR year__c =: null) OR (year__c =:ToDateYear OR year__c =: null))]);
        List<pickListWrapper> MetricValue = new List<pickListWrapper>();
        for(Metric_Detail__mdt mtr : Metric){
            MetricValue.add(new pickListWrapper(mtr.API_name__c,mtr.MasterLabel));
            system.debug(' value : '+mtr.MasterLabel);
        }
        return MetricValue;
    }
}