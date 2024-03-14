import { LightningElement,api, track } from 'lwc';
import getFieldSetDetails from '@salesforce/apex/ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess';
import getDiagnosticCodes from '@salesforce/apex/ATI_DiagnosticCode_Controller.getDiagnosticCodes';
import deleteSObjects from '@salesforce/apex/ATI_DiagnosticCode_Controller.deleteSObjects';
import checkObjectDeleteAccess from '@salesforce/apex/ATI_Utils.checkObjectDeleteAccess';
import saveDiagnosticCodes from '@salesforce/apex/ATI_DiagnosticCode_Controller.saveDiagnosticCodes';
import getAllowedClaimStatusMetadata from '@salesforce/apex/ATI_DiagnosticCode_Controller.getAllowedClaimStatusMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserDetails from '@salesforce/apex/ATI_DiagnosticCode_Controller.getUserDetails';
import Id from '@salesforce/user/Id';

export default class ATI_Diagnostic_Code_Comp extends LightningElement {
    @api claimObject;
    @api sobjectApiName ;
    //@api sobjectApiName2 ;
    @track columns;
    @track fields;
    @track data;
    //@track noOfRows;
    @track draftValues = [];
    @track showLoadingSpinner = false;
    @track listOfDiagnosticCodes=[];
    @track error;
	@track isSuppressbottom;
	@track userId = Id;
    @track userData;    
    //have this attribute to track data changed
    //@track draftValues = [];

    _title = 'Error';
    message = '';
    variant = 'error';

	connectedCallback() {
		this.isSuppressbottom = false;
        this.sobjectApiName ='ATI_Diagnostic_Code__c';
        //this.sobjectApiName2 ='WOD_2__Warranty_Code__c';
        this.customMetadataName = 'ATI_DiagnosticCodesFieldSet';
		let status = this.claimObject.WOD_2__Claim_Status__c;
        let allowedStatusesLst = [];
		getUserDetails({userId : this.userId}).then(response => {
            this.userData = response;
        });
        getAllowedClaimStatusMetadata({}).then(response => {
            if(response.data){
                allowedStatusesLst = response.data.split(',');
            }
        });
        var that = this;
        getFieldSetDetails({objectName : this.sobjectApiName, metadataRecordAPIName : this.customMetadataName})
        .then(response => {
            if(response.status){
                let objData = JSON.parse(response.data);
                let fields = [];
                let columns = [];
                let label = this.Label;
                objData.forEach(function(data){
                var obj = new Object();
                obj["fieldName"] = data.fieldpath;
                obj["label"]     = data.label;
                obj["fieldApiName"] = data.fieldpath;
                obj["type"] = data.type;
								obj["required"] = true;
                if(data.type === "REFERENCE"){
                    var lookupObj = {};
                    if(data.parentReferenceList == "WOD_2__Warranty_Code__c"){
                        lookupObj["lookUpConfigurationMetadataName"] = 'ATI_DiagnosticCodes_Lookup';
                        lookupObj["lookupComponentId"] = {fieldName : 'Id'};												
                        lookupObj["placeholder"] = 'Select Diagnostic Codes';
												
                        let extraParams = { "claimId" : that.claimObject.Id, 
                            "invId":that.claimObject.WOD_2__Inventory__c, 
                            "modelId":that.claimObject.WOD_2__Model_Number__c,
                            "buId" : that.claimObject.WOD_2__BusinessCategory__c};
                        lookupObj["extraParams"] = JSON.stringify(extraParams);
												
                    }
                    lookupObj["lookupId"] = {fieldName : obj.fieldName};
                    obj["type"] = 'lookup';
                    obj["typeAttributes"] = lookupObj;
                }
                obj["editable"]  = true;  
				obj["hideDefaultActions"]= true;
										console.log("objjjj"+obj);
                columns.push(obj);
                fields.push(data.fieldpath);
            });

                if(!allowedStatusesLst.includes(status) || (status=='Submitted' && (this.userData.Profile.Name=='ATI Dealer Warranty Approver' || this.userData.Profile.Name=='ATI Distributor and Dealer'))){
                    this.isSuppressbottom = true;
                }else{
                    columns.push({ type: 'button-icon', typeAttributes: { iconName: 'utility:delete', name: 'delete' }, fixedWidth: 50 });
                }
                this.columns = columns;
								this.fields = fields;
                if(this.columns !== undefined){
                    this.getRecordData();    
                }
            }
        })
        .catch(error =>{
        
        });
    }

    async getRecordData(){
        let noOfRows= 5;
        let element = {};
        let addData = [];
        this.showLoadingSpinner = true;
        getDiagnosticCodes({objectName : this.sobjectApiName, fields : 'Warranty_Code__c', claimId: this.claimObject.Id })
				.then(result => {
            if(result.status){
                var data = JSON.parse(result.data);
								var columns = this.columns;
                let recordData = [];
                for(var i=0; i<data.length; i++){
                    element = {};
										for(var j=0; j<columns.length-1 ;j++){
												element[columns[j].fieldName] = data[i][columns[j].fieldApiName];												
                    }
										
                    element["key"] = i;   
                    element["Id"]  = data[i].Id;
                    recordData.push(element);
                }
                this.data = recordData;
                this.showLoadingSpinner = false;
                let lengthVal= noOfRows-this.data.length;

                if(this.data.length<noOfRows && this.data.length!==0){
                    for(var i=0;i<lengthVal;i++){
                        element = {};
                        for(var j=0; j<columns.length; j++){
                            
														if(columns[j].fieldName !== undefined){  
																element[columns[j].fieldName] = undefined;
																
                            }
                        }
                        element["key"] = this.data.length;
                        element["Id"] = 'row-'+this.data.length;
                        this.data = [...this.data,element];
												
                    }
                   
                }
                //console.log('result->>> '+JSON.stringify(recordData));
								
            }
            if(this.data === undefined || this.data.length===0){
                addData = [];
                let columns = this.columns;
                for(var i=0; i<noOfRows; i++){
                    element = {};
                    for(var j=0; j<columns.length ;j++){
                        if(columns[j].fieldName !== undefined){
                            element[columns[j].fieldName] = undefined;
                        }
                    }
                    element["key"] = i;
                    element["Id"] = 'row-'+i;
                    addData.push(element);
                    this.data = [...addData];
                    
                }
               //console.log('this.data>>>>> '+JSON.stringify(this.data));
            }
						
            this.showLoadingSpinner = false;
        })
        .catch(error =>{
            
        });
    }



    addRow(){
        let addData = [...this.data];
        let element = {};
        if(this.data.length<30){
            for(var j=0; j<this.columns.length ;j++){
                element[this.columns[j].fieldName] = undefined;
            }
            element["key"] = this.data.length;
            element["Id"] = 'row-'+this.data.length;
            addData.push(element);
            this.data = [...addData];
						
        }else{
            const evt = new ShowToastEvent({
                title: this._title,
                message: "Maximum limit is 30",
                variant: this.variant
            });
            this.showLoadingSpinner = false;
            this.dispatchEvent(evt);

        }
    }

    handleCancel(event) {
        //this.draftValues = [];
    }

    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'delete':
                this.deleteSObjRow(row);
                break;
            default:
        }
    }

    deleteSObjRow(deleteRow) {
        let newData = JSON.parse(JSON.stringify(this.data));
        let deleteSobject;
        //newData = newData.filter(rows => rows.key !== deleteRow.key);
        //if(deleteRow.Id.includes('-')){
            checkObjectDeleteAccess({objectName : this.sobjectApiName})
            .then(response => {
                if(response.status){
                    this.showLoadingSpinner = true;
                    if(newData.length> 0){
                        for(var i=0;i<newData.length;i++){
                            if(deleteRow.Id===newData[i].Id){
                            deleteSobject=newData[i].Warranty_Code__c; //7th Jan
                            }
                        }
                        newData = newData.filter(rows => rows.key !== deleteRow.key);
                        if(deleteSobject!= null){
                            deleteSObjects({recordId : deleteSobject})
                            .then(result => {
                            if(result.status){

                                for(var index=0; index<newData.length; index++){
                                    newData[index].key = index;
                                }
                                this.data = newData;
                                this.showLoadingSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Record Deleted successfully',
                                        variant: 'success',
                                    }),
                                );
                                if(this.data.length === 0){
                                    this.draftValues = [];
                                }
                            }
                            this.showLoadingSpinner = false;
                            })
                            .catch(error =>{
                            let message;
                            if (error.hasOwnProperty('body')) {
                                message = error.body.message;
                            }else if(error.hasOwnProperty('message')){
                                message = error.message;
                            }else{
                                message = error.errormessage;
                            }
                            const evt = new ShowToastEvent({
                                title: this._title,
                                message: message,
                                variant: this.variant
                            });
                            this.error = error;
                            this.showLoadingSpinner = false;
                            this.dispatchEvent(evt);
                            });
                        }else{
                            for(var index=0; index<newData.length; index++){
                                newData[index].key = index;
                            }
                            this.data = newData;
                        }
                    }

                }
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: this._title,
                    message: error.message,
                    variant: this.variant
                });
                this.error = error;
                this.dispatchEvent(evt);
            });
        //}else{
            /*for(var index=0; index<newData.length; index++){
                newData[index].key = index;
            }
            this.data = newData;
            if(this.data.length === 0){
                this.draftValues = [];
            }*/
        //}
    }

    handleLookupSelected(event) {
        event.stopPropagation();
        let updatedItem;
        if(event.detail.selectedObject.attributes.type === 'WOD_2__Warranty_Code__c'){
            updatedItem =  {'Id':event.detail.lookupComponentId,'Warranty_Code__c':event.detail.selectedObject.Id}; //7th Jan
        }
        this.listOfDiagnosticCodes.push(updatedItem);
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);

    }

    updateDataValues(updateItem) {
        let copyData = [... this.data];
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
        //console.log('data>>>>>> '+JSON.stringify(this.data));
    }
     //handler to handle cell changes & update values in draft values
     handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
        
     }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
        
				console.log('draftValues==='+this.draftValues);
    }

    handleSave(event){
        //this.saveDiagnosticCodes(this.listOfDiagnosticCodes);
        var columns = this.columns;
        var invalidData = [];
        var data = this.data;
        var newData=[];
        this.showLoadingSpinner = true;
        var draftValues = this.draftValues;
        for(var i=0;i<data.length;i++){
            if((data[i].hasOwnProperty('Warranty_Code__c') && data[i]['Warranty_Code__c'] === '') || (data[i].Id.includes('-') && (!data[i].hasOwnProperty('Warranty_Code__c')))){ //7th Jan
                //invalidData.push(data[i]);
            }else{
                newData.push(data[i]);
            }
        }
        //console.log('invalidata>>>>>>>> '+JSON.stringify(invalidData));
        this.showLoadingSpinner = false;
        var recordData = [];
        if(newData.length <= 0){
            recordData = [];
            this.saveDiagnosticCodes(recordData);
        }else{
            for(var i=0;i<newData.length;i++){
                if(newData[i].Warranty_Code__c!= null){
                    recordData.push(newData[i].Warranty_Code__c); //7th jan
                }
            }
            console.log('recordData>>>>> '+JSON.stringify(recordData));
            this.saveDiagnosticCodes(recordData);
        }
    }

    saveDiagnosticCodes(listOfDiagnosticCodes){
        saveDiagnosticCodes({diagnosticCodes : listOfDiagnosticCodes,claimId: this.claimObject.Id})
            .then(response => {
                if(response.status){
                    this.showLoadingSpinner = true;
                    const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Saved Successfully',
                    variant: 'success'
                });
                //this.getRecordData();
                this.draftValues = [];
                this.dispatchEvent(evt);
                this.showLoadingSpinner = false;
                
                }else{
                    const evt = new ShowToastEvent({
                        title: this._title,
                        message: response.errormessage,
                        variant: this.variant
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: this._title,
                    message: error.message,
                    variant: this.variant
                });
                this.error = error;
                this.dispatchEvent(evt);
            });
    }

    handleSelectedLookupRemoved(event){
        let deletedRecordIndex;
        for(var index=0; index<this.data.length; index++){
            if(event.detail.lookupComponentId===this.data[index].Id){
                deletedRecordIndex= index;
            }
        }
        this.updateDraftValues(this.data[deletedRecordIndex]);
        //this.data.splice(deletedRecordIndex, 1);
        this.data[deletedRecordIndex].Warranty_Code__c=''; //7th Jan
        //this.listOfDiagnosticCodes.splice(deletedRecordIndex, 1);
        
    }

}