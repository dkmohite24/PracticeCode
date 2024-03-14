/* Class Name: PRPC_ScheduleDataMovementClass
* Created by: Debiprasad
* Updated by : Akanksha Mondal 
* Description :Update the SDM flag to true for Service dealers and the Include_Sales__c flag  to true for D,DDLR,DB -CHG0043240
* Updated by :Susovan - Exlcude Include sales update -CHG0043454
*/
global class PRPC_ScheduleDataMovementClass implements Schedulable {
    global void execute(SchedulableContext sc) {
        try{  
            Set<String> sapIdSet = new Set<String>();
            //Set<String> sapIdSet2 = new Set<String>();
            //Set<String> sapIdMainBranch = new Set<String>();
            Set<Account> AccountstoUpdate = new Set<Account>();
            //get accounts from staging for sdm update
            for(Account_Staging__c acctStage : [SELECT Id, Service_Location_ID__c,Location_Type__c FROM Account_Staging__c WHERE Location_Type__c = 'DLR' and Error_log__c = null AND (Sales_RegionA__c='Eastern' OR Sales_RegionA__c='Western' OR Sales_RegionA__c='Central')]) {
                String tempSAPId = String.join(acctStage.Service_Location_ID__c.split('-'),'').leftPad(10,'0');
                sapIdSet.add(tempSAPId);
            }
            //get accounts for include sales update
            /*for(Account_Staging__c acctStage : [SELECT Id, Service_Location_ID__c,Hidden__c,Location_Type__c FROM Account_Staging__c WHERE ( Location_Type__c = 'DDLR' OR Location_Type__c = 'DB'  OR Location_Type__c = 'D')  and Error_log__c = null]) {
                String tempSAPId = String.join(acctStage.Service_Location_ID__c.split('-'),'').leftPad(10,'0');
                if(tempSAPId.right(5)=='00000' && acctStage.Location_Type__c=='D'){
                 sapIdMainBranch.add(tempSAPId);
                    tempSAPId=tempSAPId.removeEnd('00000');
                }
                sapIdSet2.add(tempSAPId);
            }
           sapIdSet2.addAll(sapIdMainBranch);*/
       
            List<Account> allserviceDealer = new List<Account>();
            //List<Account> allotheraccountsPrp = new List<Account>();
            if(Test.isRunningTest()){
                allserviceDealer = [SELECT Id,SAP_Id__c,Service_Dealer_Development__c, PRP_Participation__c FROM Account WHERE Location_Type__c = 'DLR'];
                //allotheraccountsPrp = [SELECT Id,SAP_Id__c,Service_Dealer_Development__c, PRP_Participation__c,Include_Sales__c FROM Account WHERE Type!='Service Dealer' AND (((SAP_Id__c IN: sapIdSet2 and PRP_Participation__c=FALSE) OR (SAP_Id__c NOT IN: sapIdSet2 and PRP_Participation__c=TRUE))) ];
                
            }else{
                //query to compare all the accounts in the S&SL vs the accounts for which flag is turned on in the org
                allserviceDealer = [SELECT Id,SAP_Id__c,Service_Dealer_Development__c, PRP_Participation__c FROM Account WHERE ((SAP_Id__c IN: sapIdSet and Service_Dealer_Development__c = false) OR (SAP_Id__c NOT IN:sapIdSet AND Service_Dealer_Development__c = TRUE)) ];
                //allotheraccountsPrp = [SELECT Id,SAP_Id__c,Service_Dealer_Development__c, PRP_Participation__c,Include_Sales__c FROM Account WHERE Type!='Service Dealer' AND (Type!='End Customer' OR WOD_2__Warranty_Account_Type__c!='Customer') AND SAP_ID__c!=null AND ((SAP_Id__c IN: sapIdSet2 and  Include_Sales__c=FALSE ) OR (SAP_Id__c NOT IN: sapIdSet2 and Include_Sales__c=TRUE))];       
                
            }
            if(sapIdSet.size() >0 ){
                for(Account acct : allserviceDealer) {
                    if(sapIdSet.contains(acct.SAP_Id__c)) {
                        acct.Service_Dealer_Development__c = true;
                    }
                    else {
                        acct.Service_Dealer_Development__c = false;
                    }
                }
            }
            /*if(sapIdSet2.size() >0 ){
                for(Account acct : allotheraccountsPrp) {
                    system.debug('acct.SAP_Id__c  '+acct.SAP_Id__c);
                    if(sapIdSet2.contains(acct.SAP_Id__c)) {
                        acct.Include_Sales__c=true;
                    }
                    else{
                        acct.Include_Sales__c = false;
                    }
                }  
            }*/  
            //updation of sdm for service dealers
            if(sapIdSet.size() > 0) {
                system.debug('allserviceDealer.size()'+allserviceDealer.size());
                UPDATE allserviceDealer;
            }
            //updation of include sales flag for D,DB and DDLR
            /*if(sapIdSet2.size() > 0) {
                system.debug('allotheraccountsPrp.size()'+allotheraccountsPrp.size());
               UPDATE allotheraccountsPrp;
            }*/
           //metadata updation begins 
           /*List<Exceptions_S_SL__mdt> metaList = [select SAP_ID__c,PRP_Participation__c,Include_Sales__c from Exceptions_S_SL__mdt];
            List<Account> updateMetadataAccounts = new List<Account>();
            Set<String> incSalesflag = new Set<String>();
            for(Exceptions_S_SL__mdt m:metaList){
                if(m.Include_Sales__c==true){
                    incSalesflag.add(m.SAP_ID__c);
                }
            }
            for(Account a:[select id,SAP_ID__c from Account where SAP_ID__c IN:incSalesflag] ){
               if(incSalesflag.contains(a.SAP_ID__c)){
                     a.Include_Sales__c=true;
                }
                updateMetadataAccounts.add(a);
            }
            //updation of metadata accounts
            if(updateMetadataAccounts.size()>0){
                update updateMetadataAccounts;
            }*/
        }
        catch(Exception ex) {
            System.debug('There is no service dealer');
        }
        DataMovementBatch myBatchObject = new DataMovementBatch();
        If(!Test.isRunningTest()){
            Database.executeBatch(myBatchObject,1);
        }else{
            Database.executeBatch(myBatchObject);
        }
    }
}