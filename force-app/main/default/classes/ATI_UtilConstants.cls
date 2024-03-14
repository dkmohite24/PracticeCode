/* Name: ATI_UtilConstants
Description : Util Constant Class 
Author : Tavant (Punam)
History :
VERSION     AUTHOR                 DATE               DETAIL                                    UserStory/Req#
1.0 -       Tavant (Punam)     03/03/2020          INITIAL DEVELOPMENT
*/

public with sharing class ATI_UtilConstants {
    public static String draft='Draft';
    public static String rejected='Rejected';
    public static String inProgress='In Progress';
    public static String pendWP='Pending Warranty Processor Approval';
    public static String pendApp='Pending Approval';
    public static String pending='Pending';
    public static String paid='Paid';
    public static String approved='Approved';
    public static String cancelled='Cancelled';
    public static String denied='Denied';
    public static String inActive='InActive';
    public static String registered='Registered';
    public static String deRegistered='De-Registered';
    public static String pendingPayment='Pending Payment';
    public static String cancelApproved='Cancel Approved';
    public static String regNumValidation ='Registration Number is missing or not valid';
    public static String serialNumValidation = 'Serial Number is mising.';
    public static String submitIndValidation = 'Submitter Indicator is missing or not valid.';
    public static String statusCodeValidation = 'Either Status Code or Description is mising.';
    public static String regDateValidation = 'Registration Date is greater than the current date.';
    public static String etcCancelValidation = 'ETC Cancelled, reason explained on ETC registration';
    public static String etcDeniedValidation = 'ETC Denied, reason explained on ETC Registration.';
    public static String vehInfoObject='ATI_VIN_Transmission_Mapper__c';
    public static String finLineItemObject='WOD_2__Financial_Line_Item__c';
    public static String insufficientVehInfoAccess='Insufficient Vehicle Information Read Access-->> ';
    public static String insufficientFinLineItemAccess='Insufficient Financial Line Item Read Access-->> ';
    public static String i203Username='Username';
    public static String i203Password='Password';
    public static String i203BASIC='BASIC ';
    public static String i203Method='POST';
    public static String i203Auth='Authorization';
    public static String i203Exception='Error-';
    public static String httpHeaderClientIdValue='b2039ed5294046ae95f6557284977c66';
    public static String httpHeaderClientSecretValue='86f378aa91D24FC6bE4dc4E533c8A220';
    public static String httpHeaderClientId='client_id';
    public static String httpHeaderClientSecret='client_secret';
    public static String httpHeaderReqId='X-Request-ID';
    //public static String httpHeaderReqValue='13';
    
    
    public static String tliStatus='Waiting for Payment Confirmation';
    public static String transactMemoHstry='WOD_2__Transaction_Memo_History__c';
    
    

}