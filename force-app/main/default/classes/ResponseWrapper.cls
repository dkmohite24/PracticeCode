/* Name: ResponseWrapper
Description : Wrapper Class for baseController return type
Author : Tavant (MKS)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MKS)    21/02/2018          INITIAL DEVELOPMENT
*/
public with sharing class ResponseWrapper {
	@AuraEnabled
	public String data;
	@AuraEnabled
	public Boolean status; // success-0/fail-1
	@AuraEnabled
	public String errormessage;

	public ResponseWrapper(){

	}

	public ResponseWrapper(String data, Boolean status, string errormessage) {
		this.data = data;
		this.status = status;
		this.errormessage = errormessage;
	}
}