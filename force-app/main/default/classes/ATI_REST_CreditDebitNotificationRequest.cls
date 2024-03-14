/*
	Class Name	:	ATI_REST_CreditDebitNotificationRequest
	Description	:	JSON request to apex wrapper for ATI_REST_CreditDebitNotification
*/
public class ATI_REST_CreditDebitNotificationRequest {
    public LisT<CreditDebitNotification> CreditDebitNotification;
    public class CreditDebitNotification {
        public String transactionNumber;
        public String transactionStatus;
        public String transactionDate;
        public String claim;
        public String Comment;
    }
    
    public static ATI_REST_CreditDebitNotificationRequest parse(String json) {
        return (ATI_REST_CreditDebitNotificationRequest) System.JSON.deserialize(json, ATI_REST_CreditDebitNotificationRequest.class);
    }
}