/**
 * @description       : This service class is used to log errors.
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 09-15-2023
 * @last modified by  : Abhishek Mohapatra
**/
global without sharing class ATI_ErrorLogService {
    public ATI_ErrorLogService() {

    }

    /**
    * @description This method is the interface through which the error logging will be done.
    * @author Abhishek Mohapatra | 07-10-2023 
    * @param err This is a wrapper class variable which will contain the error log record details.
    **/
    public static void logError( errorLogWrapper err){
        if(err.inputType){
            logInboundError(err.input, err.errorMessage, err.className, err.methodName);
        }
        else if(err.outputType){
            logOutboundError(err.output, err.errorMessage, err.className, err.methodName);
        }
    }

    /**
    * @description This method is used to create the Error log record for inbound requests.
    * @author Abhishek Mohapatra | 07-10-2023 
    * @param input This is the input that we received from the external system or salesforce.
    * @param errorMessage The error message captured.
    * @param className The class from where this method is being called.
    * @param methodName The method from which this method is being called.
    **/
    private static void logInboundError(String input, String errorMessage, String className, String methodName){
        ATI_Error_Log__c er = new ATI_Error_Log__c();
        er.ATI_Class_Name__c = className;
        er.ATI_Error_Message__c	= errorMessage;
        er.ATI_Method_Name__c = methodName;
        er.ATI_Input__c = input;
        er.ATI_Status__c = 'Error';

        Insert er;

    }

    /**
    * @description This method is used to create the Error log record for outbound requests.
    * @author Abhishek Mohapatra | 07-10-2023 
    * @param output This is the output that the method was trying to send.
    * @param errorMessage The error message received from the external system.
    * @param className The class from where this method is being called.
    * @param methodName The method from which this method is being called.
    **/
    private static void logOutboundError(String output, String errorMessage, String className, String methodName){
        ATI_Error_Log__c er = new ATI_Error_Log__c();
        er.ATI_Class_Name__c = className;
        er.ATI_Error_Message__c	= errorMessage;
        er.ATI_Method_Name__c = methodName;
        er.ATI_Output__c = output;
        er.ATI_Status__c = 'Error';

        Insert er;

    }


    // This wrapper class is used to pass the error log record details.
    global class errorLogWrapper{
        public String input{get;set;} // Used for inbound APIs; Where the API is triggered from outside of Salesforce.
        public String output{get;set;} // Used for outbound APIs; Where the API is triggered from Salesforce.
        public String errorMessage{get;set;}
        public Boolean inputType{get;set;} // Used for inbound APIs
        public Boolean outputType{get;set;} // Used for outbound APIs
        public String className{get;set;}
        public String methodName{get;set;}

        global errorLogWrapper(){
            this.inputType = false;
            this.outputType = false;

        }
    }
}