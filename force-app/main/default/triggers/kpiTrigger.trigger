trigger kpiTrigger on KPI__c (After Insert, After Update, Before Update) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(KPI__c kpi : Trigger.new){
        kpi.Historuy__c = '';
            if(kpi.CSI_Parts__c != Trigger.oldMap.get(kpi.Id).CSI_Parts__c) {
                kpi.Historuy__c += 'CSI Parts: '+ Trigger.oldMap.get(kpi.Id).CSI_Parts__c;
            }
            if(kpi.CSI_Parts_Score__c!= Trigger.oldMap.get(kpi.Id).CSI_Parts_Score__c) {
                kpi.Historuy__c += 'CSI Parts Score: '+ Trigger.oldMap.get(kpi.Id).CSI_Parts_Score__c;
            }
            if(kpi.CSI_Service__c!= Trigger.oldMap.get(kpi.Id).CSI_Service__c) {
                kpi.Historuy__c += 'CSI Service: '+ Trigger.oldMap.get(kpi.Id).CSI_Service__c;
            }
            if(kpi.CSI_Service_Score__c!= Trigger.oldMap.get(kpi.Id).CSI_Service_Score__c) {
                kpi.Historuy__c += 'CSI Service Score: '+ Trigger.oldMap.get(kpi.Id).CSI_Service_Score__c;
            }
        }
    }
    if(Trigger.isAfter) {
        //kpiHelper.afterHelper(Trigger.new);
    }

}