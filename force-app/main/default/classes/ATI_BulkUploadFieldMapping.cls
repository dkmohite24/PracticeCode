/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
  This class is used to store custom metadata values
* -------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        (TY) - (23-DEC-2020)
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_BulkUploadFieldMapping {
	public String fieldAPIName;//Field Api Name;
	public String columnName;//Column_Name;
    public String objectAPIName;//Object Api Name
	public Boolean isMandatory;//IsMandatory;
	public String referenceFieldAPIName;//Reference_Field_API_Name;
	public String referenceObjectAPIName;//Reference_Object_API_Name;
    public String referenceBUName; //Reference BU Name;
	public String type; //Field Type
	public String displayName; //Fetch Parent Reference Field API Name From Child
    public String queryFilter; //Query Filter for Reference type

	public ATI_BulkUploadFieldMapping(){
		fieldAPIName = '';
		columnName = '';
        objectAPIName = '';
		isMandatory = false;
		referenceFieldAPIName = '';
		referenceObjectAPIName = '';
        referenceBUName= '';
		type = '';
		displayName = '';
        queryFilter = '';
	}
}