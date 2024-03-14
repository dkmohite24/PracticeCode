public class PRPC_transacErrorClass {
    @AuraEnabled
    public static List<String> setReport(){
        List<String> reportNames = new List<String>();
        reportNames.add('None');
        reportNames.add('TPS Error');    
        reportNames.add('TT Error Data - Aware');    
        reportNames.add('TT Error Data - Dist'); 
        return reportNames;
    }
}