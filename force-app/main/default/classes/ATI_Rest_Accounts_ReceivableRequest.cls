/* Name: ATI_Rest_Accounts_ReceivableRequest
Description : This class is used for creating JSON request body for http request.
Author : Tavant(Punam)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(Punam)        12/03/2021       INITIAL DEVELOPMENT                              
*/
public class ATI_Rest_Accounts_ReceivableRequest {
    public List<ClaimInformation> memo;
	public class ClaimInformation {
		public String documentRef='';	//M4887438
		public String claimType='';	//01
		public String businessCategoryUnit='';	//US
		public String financialPartnerCode='';	//0000001019
		public String accountGroup='';	//01
		public String repairingOutlet='';	//0101900275
		public String poNumber='';	//
		public String model='';	//4500RDS
		public String serialNumber='';	//6610548265
		public String plantCode='';	//1391
		public String transactionId='';	//M4887438
		public String transactionType='';	//Claim
		public String memoType='';	//Credit
		public String vin='';	//1XPCD40X1LD641398
		public String week='';	//202039
		public String totalAmount='';	//1233.03
        //public String transactionDate;
		public List<TransactionLineItems> transactionLineItems= new List<TransactionLineItems>();
	}
	public class TransactionLineItems {
		public String lineNumber='';	//1
		public String name='';	//29503382
		public String type='';	//Parts Expense
		public String productCode='';	//
		public String hierarchy='';	//063PARTS
		public String dollarType='';	//H
		public String quantity='';	//1
		public String unitPrice='';	//2.15
		public String lineAmount='';	//2.15
	}
	public static ATI_Rest_Accounts_ReceivableRequest parse(String json){
		return (ATI_Rest_Accounts_ReceivableRequest) System.JSON.deserialize(json, ATI_Rest_Accounts_ReceivableRequest.class);
	}

}