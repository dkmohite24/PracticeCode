/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
  This class is used to store result of batch log processing after inserting records. 
  This has been kept intentionally global
* -------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        23-DEC-2020
* @modified
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
global with sharing class ATI_BatchLogResults {
    public Double totalRecordCount;
    public Double successRecordCount;
    public Double failedRecordCount;
    public String failedRecords;
    public Set<Id> successRecordIdsSet;
	public Set<String> successRecordsSet;
    
    public ATI_BatchLogResults() {
        totalRecordCount = 0;
        successRecordCount = 0;
        failedRecordCount = 0;
        failedRecords = '';
    }
}