/**
 * (c) 2020 Tavant Technology.
 * -------------------------------------------------------------------------------------------------
     This class is used to run query with sharing
 * --------------------------------------------------------------------------------------------------
 * @description    Class is used to run SOQL Queries with sharing based on sharing criteria
 * @author         
 * @version        1.0
 * @created        
 * @modified
 * --------------------------------------------------------------------------------------------------
 * @changes
 * -------------------------------------------------------------------------------------------------
 */
public with sharing class ATI_QueryRunWithSharing {
    
    /** 
  	* @param       string
  	* @return      List<sObject>
  	* @description Returns sObject List
	*/
	public static List<sObject> runQuery(String query) {
	return Database.query(query);  
	}
    
    /** 
  	* @param       string,string 
  	* @return      List<sObject>
  	* @description Returns sObject List
  	*/
	public static List<sObject> runQueryIdString(String query, String idString) {
		return Database.query(query);  
	}
}