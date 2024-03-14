/*
 * Updated By : Susovan Mondal
 * Description : It will check from January month to the previous month in the same year, whether the files were uploaded or not and based on that Overall file 
 * 				submission records are created or updated.It will also true for all the DB that are PRP participating if we receive the data for the 
 * 				distributor in the respective month for Functional Component data.
 */

global class PRPC_overallFileSubmissionBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'SELECT Id, ParentId, PRP_Participation__c, Name FROM Account WHERE ( type =\'Distributor Branch\' OR type =\'Direct Dealer\' ) ';//add distributor branch condition
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Overall_File_Submission__c> fileLst = New List<Overall_File_Submission__c>();
        String AccId = scope[0].Id;
        String AccParentId = scope[0].ParentId;
        Boolean PRPPart = scope[0].PRP_Participation__c;
        system.debug('AccountParent : '+AccParentId);
        Date dt = System.today(); //current date
        Integer month = dt.Month(); //get month
        Integer year = dt.Year(); //get year
        
        if(month == 1) {
            month = 12;
            year = year - 1;
        }
        else month = month - 1;
        
        Map<Integer,Overall_File_Submission__c> existingFiles = new Map<Integer,Overall_File_Submission__c>();
        For(Overall_File_Submission__c overallFile:[SELECT Id,Month__c,Distributor_Branch__c FROM Overall_File_Submission__c WHERE Distributor_Branch__c =: AccId AND Month__c <=: month AND Year__c =: year]){
            existingFiles.put(Integer.valueOf(overallFile.Month__c),overallFile);
            System.debug('Showing the value : '+Integer.valueOf(overallFile.Month__c)+' fgh '+overallFile.Month__c);
        }
        System.debug('Showing : '+existingFiles.get(1));
        
        
        boolean isTPS = false;
        boolean isRET = false;
        boolean isTraining = false;
        boolean isSurvey = false;
        boolean isPartsOrdering = false;
        boolean isFunctionalComp = false;
        boolean isFacilityAudit = false;
        boolean isTAT =false;
        boolean isTATAware = false;
        boolean isEndCustomer = false;
        boolean isETC = false;
        
        For(Integer monthCheck = 1;monthCheck<=month;monthCheck++){
            
            //system.debug('line number 25' +fetchRecords.get(monthCheck));
            isTAT = TATDistExists(AccId,monthCheck,year);
            isTATAware = TATAwareExists(AccId,monthCheck,year);
            isTPS = TPSCheck(AccId,monthCheck,year);
            isRET = TPSRetCheck(AccId,monthCheck,year);
            isTraining = TrainingCheck(AccId,monthCheck,year);
            isSurvey = surveyCheck(AccId,monthCheck,year);
            isPartsOrdering = partsOrderCheck(AccId,monthCheck,year);
            isFunctionalComp = FunctionalCheck(AccParentId,monthCheck,year,PRPPart);
            isFacilityAudit = FacilityAuditCheck(AccId,monthCheck,year);
            isEndCustomer = EndCustomerCheck(AccId,monthCheck,year);
            isETC = isETCCheck(AccId,monthCheck,year);
            
            Overall_File_Submission__c fileSubmission = new Overall_File_Submission__c();
            fileSubmission.TPS__c = isTPS;
            fileSubmission.Total_Parts_Sold_ReTran__c = isRET;
            fileSubmission.Turnaround_Time__c = isTAT;
            fileSubmission.Turnaround_Time_Aware__c = isTATAware;
            fileSubmission.Training__c = isTraining;
            fileSubmission.Survey__c = isSurvey;
            fileSubmission.Parts_Ordering__c = isPartsOrdering;
            If(monthCheck == month){
                fileSubmission.Functional_Comp__c = isFunctionalComp;
            }
            fileSubmission.Facility_Audit__c = isFacilityAudit;
            fileSubmission.End_Customer_Data__c = isEndCustomer;
            fileSubmission.ETC_Data__c = isETC;
            fileSubmission.Distributor_Branch__c = AccId;
            fileSubmission.Month__c = monthCheck;
            fileSubmission.Year__c = year;
            
            if(existingFiles.containsKey(monthCheck)){
                System.debug('monthCheck : '+monthCheck);
                If(existingFiles.get(monthCheck).Distributor_Branch__c == AccId){
                    System.debug('monthCheck 1 : '+monthCheck);
                    fileSubmission.Id = existingFiles.get(monthCheck).Id;
                    system.debug('line number 80' +existingFiles.get(monthCheck).Id);
                }
            }
            fileLst.add(fileSubmission);
        }
        upsert fileLst;
        
    }  
    
    global void finish( Database.BatchableContext BC ) {
    }
    
    global boolean TATDistExists(String accId, Integer monthCheck, Integer year){
        For(TAT_Data__c tmp:[SELECT Month__c,Year__c,Source_Type__c FROM TAT_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Source_Type__c =: 'Distributor' and Dealer_Id__c =:accId Limit 1]){
            if(tmp.Source_Type__c=='Distributor' && tmp.Month__c == monthCheck){
                return true;
            } 
        }
        return false;
    }
    global boolean TATAwareExists(String accId, Integer monthCheck, Integer year){
        For(TAT_Data__c tmp:[SELECT Month__c,Year__c,Source_Type__c FROM TAT_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Source_Type__c =: 'AWARE' and Dealer_Id__c =:accId Limit 1]){
            if(tmp.Source_Type__c=='AWARE' && tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean TPSCheck(String accId, Integer monthCheck, Integer year){
        For(TPS_Data__c tmp:[SELECT Month__c,Year__c,Parts_Sold_Type__c, Customer__c from TPS_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Parts_Sold_Type__c !=: 'RET' and Customer__c =:accId Limit 1]){
            if(tmp.Parts_Sold_Type__c!='RET' && tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean TPSRetCheck(String accId, Integer monthCheck, Integer year){
        For(TPS_Data__c tmp:[SELECT Month__c,Year__c,Parts_Sold_Type__c, Customer__c from TPS_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Parts_Sold_Type__c =: 'RET' and Customer__c =:accId Limit 1]){
            if(tmp.Parts_Sold_Type__c=='RET' && tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean TrainingCheck(String accId, Integer monthCheck, Integer year){
        For(Training_Data__c  tmp:[SELECT Month__c,Year__c FROM Training_Data__c  WHERE Month__c =: monthCheck AND Year__c =: year and Customer__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean surveyCheck(String accId, Integer monthCheck, Integer year){
        For(Survey_Data__c tmp:[SELECT Month__c,Year__c FROM Survey_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Customer_Dealer_Id__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean partsOrderCheck(String accId, Integer monthCheck, Integer year){
        For(Parts_Ordering__c tmp:[SELECT Month__c,Year__c FROM Parts_Ordering__c WHERE Month__c =: monthCheck AND Year__c =: year AND Ship_To__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean FunctionalCheck(String AccParentId, Integer monthCheck, Integer year, Boolean PRPPart){
        For(Functional_Comp_Data__c tmp:[SELECT Month__c,Year__c FROM Functional_Comp_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Customer__c =:AccParentId Limit 1]){
            if(tmp.Month__c == monthCheck && PRPPart == True){
                return true;
            }
        }
        return false;
    }
    global boolean FacilityAuditCheck(String accId, Integer monthCheck, Integer year){
        For(PRPCO_Facility_Audit__c tmp:[SELECT Month__c,Year__c FROM PRPCO_Facility_Audit__c WHERE Month__c =: monthCheck AND Year__c =: year AND Location__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean EndCustomerCheck(String accId, Integer monthCheck, Integer year){
        For(End_Customer__c tmp:[SELECT Month__c,Year__c FROM End_Customer__c WHERE Month__c =: monthCheck AND Year__c =: year AND Customer__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    global boolean isETCCheck(String accId, Integer monthCheck, Integer year){
        For(ETC_Data__c tmp:[SELECT Month__c,Year__c FROM ETC_Data__c WHERE Month__c =: monthCheck AND Year__c =: year AND Customer__c =:accId Limit 1]){
            if(tmp.Month__c == monthCheck){
                return true;
            }
        }
        return false;
    }
    
}