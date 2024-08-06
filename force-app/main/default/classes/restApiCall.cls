@RestResource(urlMapping='/v1/Account/*')
global class restApiCall {
    /*
        WorkBench
        /services/apexrest/v1/Account/0012w00000rGLB8AAO
        PostMan URL
        https://dkmohite24-dev-ed.my.salesforce.com/services/apexrest/v1/Account/0012w00000rGLB8AAO


    */

    @HttpPost
    global static Account insertAcc(String accName,String accPhone,String accNumber){
        
        Account newAcc = new Account(name = accName,Phone =accPhone,AccountNumber=accNumber);
        insert newAcc;
        return newAcc;

    }
    
     @HttpGet
    global static accwrapper accInfo(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String AccNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account getAccList =[select id, name from account where Id =: AccNumber];
        List<Case> getCaseList = [select id from case where accountId =: AccNumber];
        List<contact> getConList =[select id , LastName from Contact where AccountId =:AccNumber];
        accwrapper accInfoWrapper = new accwrapper();
        accInfoWrapper.accRec = getAccList;
        accInfoWrapper.conRecList =getConList;
         accInfoWrapper.caseRecList= getCaseList;
        return accInfoWrapper;
    }
    global class accwrapper{
        global account accRec;
        global list<contact> conRecList;
        global list<Case> caseRecList;
    }


    
    

}