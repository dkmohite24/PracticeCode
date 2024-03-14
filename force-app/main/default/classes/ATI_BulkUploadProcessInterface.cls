/**
* (c) 2020 Tavant Technology.
* -------------------------------------------------------------------------------------------------
  This interface will be implemented any class in the subcriber's org if they want to over the way 
  the data will be processed in the classs.
* -------------------------------------------------------------------------------------------------
* @author         
* @version        1.0
* @created        
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
global interface ATI_BulkUploadProcessInterface{

     ATI_BatchLogResults parseData(List<map<String,Object>> mapBulkUploadData, String strParentId);
}