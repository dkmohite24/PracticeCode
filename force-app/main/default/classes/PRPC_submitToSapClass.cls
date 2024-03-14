public class PRPC_submitToSapClass {
    private static List<Incentive__c> accList = new List<Incentive__c>();
    public static String submitToSAPFile(String YearReq, String MonthReq){
        CredentialsForIntegration__mdt cred = [SELECT UserName__c,Password__c,EndPoint_URL__c FROM CredentialsForIntegration__mdt LIMIT 1];
        String username = cred.UserName__c; 
        String password = cred.Password__c;  
        String endpoint = cred.EndPoint_URL__c;
        //Add basic authentication header to the callout
        Blob headerValue = Blob.valueOf(username + ':' + password); 
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
        String newlyGeneratedIncentives = generateIncentiveFile(YearReq,MonthReq);
        System.debug('newlyGeneratedIncentives'+newlyGeneratedIncentives);
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST'); 
        req.setEndpoint(endpoint); 
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('Authorization', authHeader);
        req.setBody(newlyGeneratedIncentives);
        HttpResponse response = http.send(req); 
        System.debug('Sending file response-'+response.getStatus());
        if(true){ 
           for(Incentive__c inc : accList){
                inc.Sent_To_SAP_Date__c = Date.today();
            }
            update accList;
        }
        return response.getStatus();
    }
    public static String generateIncentiveFile(String YearReqForGen, String MonthReqForGen){
        Decimal YearReqForGenDec = Decimal.valueOf(YearReqForGen);
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
        String lineCount ;
        finalOutPut = 'ISA*00*          *00*          *ZZ*PAYFORPERF     *01*132572843      *'+sysDateOfFileCreat+'*'+dtStr+'*U*00400*'+sysDateOfFileCreatMin+dtStr+'*0*P*:@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'GS*FT*PAYFORPERF*132572843*'+'21'+sysDateOfFileCreat+'*'+dtStr+'*'+sysDateOfFileCreatMin+dtStr+'*X*004010@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'ST*996*0001@';
        finalOutput = finalOutput +'\r\n';
        finalOutput = finalOutput + 'BGF*UNI@';
        finalOutput = finalOutput +'\r\n';
        
        Integer month = Date.today().Month();
        Integer year = Date.today().Year();
        accList = [SELECT id, IncentiveAcc__r.parent.SAP_ID__C,IncentiveAcc__r.SAP_ID__C , TRPS_Amount__c,SAP_ID__c,Month__c,Year__c,Incentive_Amount__c,Sent_To_SAP_Date__c FROM Incentive__c WHERE Year__c = :YearReqForGenDec AND Month__c = :MonthReqForGen];
        
        System.debug(accList);
        Map<String,String> mapForEachParentAcc = new Map<String,String>();
        Integer count = 0;
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
        return finalOutput;
    }
}