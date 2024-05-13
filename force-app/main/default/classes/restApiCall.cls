@RestResource(urlMapping='/v1/Account/*')
global class restApiCall {
    
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