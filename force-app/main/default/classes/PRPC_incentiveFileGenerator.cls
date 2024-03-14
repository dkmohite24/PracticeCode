public class PRPC_incentiveFileGenerator {
    public static String createFile(List<Incentive__c> newIncentives){
        System.debug('Calling CreateFile Method');
        String finalOutput='';
        Date dateToday = Date.today();
        String sMonth = String.valueof(dateToday.month());
        String sDay = String.valueof(dateToday.day());
        if(sMonth.length()==1){
            sMonth = '0' + sMonth; 
        }
        if(sDay.length()==1){
            sDay = '0' + sDay;
        }
        DateTime dt=System.now();
		String dtStr=dt.format('HHmm');
        String sysDateOfFileCreat = String.valueof(dateToday.year()) + sMonth + sDay ;
        String sysDateOfFileCreatMin = sysDateOfFileCreat.substring(3, sysDateOfFileCreat.length());
        sysDateOfFileCreat = sysDateOfFileCreat.substring(2, sysDateOfFileCreat.length());
        DateTime now = System.now();
        Integer count =0;
        finalOutPut = 'ISA*00*          *00*          *ZZ*PAYFORPERF     *01*132572843      *'+sysDateOfFileCreat+'*'+dtStr+'*U*00400*'+sysDateOfFileCreatMin+dtStr+'*0*P*:@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'GS*FT*PAYFORPERF*132572843*'+'21'+sysDateOfFileCreat+'*'+dtStr+'*'+sysDateOfFileCreatMin+dtStr+'*X*004010@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'ST*996*0001@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'BGF*UNI@';
        finalOutput = finalOutput +'\r\n';
        List<Incentive__c> accList = new List<Incentive__c>();
        
        Integer month = Date.today().Month();
        Integer year = Date.today().Year();
        accList = [SELECT id, IncentiveAcc__r.parent.SAP_ID__C,IncentiveAcc__r.SAP_ID__C , TRPS_Amount__c,SAP_ID__c,Month__c,Year__c,Incentive_Amount__c FROM Incentive__c WHERE Id in :newIncentives];
        
        System.debug(accList);
        Map<String,String> mapForEachParentAcc = new Map<String,String>();
        String lineCount ;
        for(Incentive__c tmp : accList){
            Decimal temp = tmp.Incentive_Amount__c;
            Integer numOfSpace = String.valueOf(temp.setScale(0)).length();
            if(tmp.IncentiveAcc__r.parent.SAP_ID__C!=null){
                String modifiedString = '';
                if(mapForEachParentAcc.containsKey(tmp.IncentiveAcc__r.parent.SAP_ID__C)){
                    String existingLine = mapForEachParentAcc.get(tmp.IncentiveAcc__r.parent.SAP_ID__C); 
                    if(numOfSpace == 1){
                      modifiedString = '       @';
                    }
                    if(numOfSpace == 2){
                      modifiedString = '      @';
                    }
                    if(numOfSpace == 3){
                      modifiedString = '     @';
                    }
                    if(numOfSpace == 4){
                      modifiedString = '    @';
                    }
                    if(numOfSpace == 5){
                      modifiedString = '   @';
                    }
                    if(numOfSpace == 6){
                      modifiedString = '  @';
                    }
                    if(count == 0){
                    existingLine = existingLine+'@'+'\r\n'+'K3*E1EDP05'+' '+(tmp.Incentive_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PP  @';
                    }
                    else{
                    existingLine = existingLine+'\r\n'+'K3*E1EDP05'+' '+(tmp.Incentive_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PP  @';
                    }
                    System.debug('Existing Line '+ existingLine);
                    if(tmp.TRPS_Amount__c != null){
                        if(count == 0){
                        existingLine = existingLine+'@'+'\r\n'+'K3*E1EDP05'+' '+(tmp.TRPS_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PS @';
                        }
                        else{
                        existingLine = existingLine+'@'+'\r\n'+'K3*E1EDP05'+' '+(tmp.TRPS_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PS @';
                        }
                    }
                    mapForEachParentAcc.put(tmp.IncentiveAcc__r.parent.SAP_ID__C,existingLine);
                }
                else{
                    if(numOfSpace == 1){
                      modifiedString = '       @';
                    }
                    if(numOfSpace == 2){
                      modifiedString = '      @';
                    }
                    if(numOfSpace == 3){
                      modifiedString = '     @';
                    }
                    if(numOfSpace == 4){
                      modifiedString = '    @';
                    }
                    if(numOfSpace == 5){
                      modifiedString = '   @';
                    }
                    if(numOfSpace == 6){
                      modifiedString = '  @';
                    }
                    String newLine;
                    if(count == 0){
                     newLine = '@'+'\r\n' +'K3*E1EDP05'+' '+(tmp.Incentive_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PP  @';
                    }
                    else{
                     newLine = '@'+'\r\n' +'K3*E1EDP05'+' '+(tmp.Incentive_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PP  @';
                    }
                    if(tmp.TRPS_Amount__c != null){
                        if(count == 0){
                         newLine = newLine+'@'+'\r\n'+'K3*E1EDP05'+' '+(tmp.TRPS_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PS  @';
                        }
                        else{
                         newLine = newLine+'@'+'\r\n'+'K3*E1EDP05'+' '+(tmp.TRPS_Amount__c).setScale(0)+modifiedString+'\r\n'+'K3*E1EDPA1'+' '+tmp.IncentiveAcc__r.SAP_ID__C+'@'+'\r\n'+'K3*E1EDP19 PS  @';
                        }
                    }
                    mapForEachParentAcc.put(tmp.IncentiveAcc__r.parent.SAP_ID__C,newLine);
                }    
            }
            count++;
        }
        System.debug(mapForEachParentAcc);
        for(String key : mapForEachParentAcc.keySet()){
            finalOutput = finalOutput +'K3*EDI_DC40'+key+mapForEachParentAcc.get(key);
            finalOutput = finalOutput+'\r\n';
        }
        List<String> splittingByLine = finalOutput.split('\r\n');
        System.debug('Size Of splittingByLine :'+splittingByLine.size());
        lineCount = String.valueOf(splittingByLine.size()-1);
        finalOutput = finalOutput + 'SE*'+lineCount+'       *0001@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput +'GE*1*'+sysDateOfFileCreatMin+dtStr+'@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput +'IEA*1*'+sysDateOfFileCreatMin+dtStr+'@';
        System.debug('FinalOutput'+finalOutput);
        String yourFiles = finalOutput;
        String strUrlUTF8;
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'testing.txt';
        conVer.Title = 'I154_Incentive FileTestingTrialLast'+System.today().format(); // Display name of the files
        strUrlUTF8 = EncodingUtil.urlDecode(yourFiles, 'UTF-8').replace('+', ' ');
        Blob myBlob = Blob.valueof(strUrlUTF8);  
        conVer.VersionData= myBlob;
        insert conVer;
        sendBatchCompleteNotification('Incentive Calculation Completion');
        return 'SUCCESS';
    }
    // FOR EMAIL NOTIFICATION
    public static void sendBatchCompleteNotification(String templateName){
        try{
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(UserInfo.getUserId()); 
            message.setSenderDisplayName('PRP Team'); 
            message.setReplyTo('no-reply@allisontransmissionenterprise.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = :templateName];
            message.setTemplateID(emailTemplate.Id);         
            //message.toAddresses = allToaddress;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        catch(Exception e){
                System.debug('The email failed to send: ' + e.getMessage());
        }
    }
}