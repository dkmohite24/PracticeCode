/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
  This class is used to store custom meta data result
* -------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        23-DEC-2020
* @modified
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_BulkUploadConfiguration {
	public String classOverrideName;
	public String objectApiNameStr;
	public String processType;
	public String communityName;

	public ATI_BulkUploadConfiguration(){
		classOverrideName = '';
		objectApiNameStr = '';
		processType = '';
		communityName = '';
	}
}