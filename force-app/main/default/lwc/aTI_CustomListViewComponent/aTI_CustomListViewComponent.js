import { LightningElement, track, wire, api } from 'lwc';
import getListViewDataOnLoad from '@salesforce/apex/ATI_CustomListViewController.getListViewDataOnLoad';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getListViewOnChange from '@salesforce/apex/ATI_CustomListViewController.getListViewOnChange';
import noRecordsFoundMsg from '@salesforce/label/c.ATI_No_records_found';
import urlBase from '@salesforce/label/c.ATI_Portal_Base';
 
export default class ATI_CustomListViewComponent extends LightningElement {
    @api objectName ='WOD_2__Inventory__c';
    @track currentFilter = '';
    @track isExpanded = false;
    @track isLoaded = false;
    @track tableColumns = [];
    @track tableData = [];
    @track listViews = [];
    @track customLstViewsMdtLst = [];
    rowLimit =100;
    rowOffSet=0;
    @track isInfiniteLoading = true;
    sortedBy='recordLink';
    sortDirection = 'asc';
    @track sortingInProgress = false;
    @track searchKey = '';

    label = {
        noRecordsFoundMsg,
        urlBase
    };

    connectedCallback() {
        getListViewDataOnLoad({objectName : this.objectName})
            .then(response => {                                                     
                if(response.status){
                    let data = JSON.parse(response.data);
                    this.loadDataFromResponse(data); 
                    this.tableColumns = data.lstDataTableColumns;
                    this.tableData = data.lstDataTableData;
                    this.listViews = data.listViewNamesLst;
                    this.currentFilter = data.listViewNamesLst[0].value;
                    this.customLstViewsMdtLst = data.customLstViewsMdtLst;
                    this.showLoadingSpinner = true;
                    this.isLoaded = true;
                    if(data.lstDataTableData.length == 0){
                        const evt = new ShowToastEvent({
                            title: this.label.noRecordsFoundMsg,
                            message: '',
                            variant: 'info'
                        });
                        this.dispatchEvent(evt);
                    }
                }else{
                    
                }
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'Error'
                });
                this.error = error;
                this.dispatchEvent(evt);
            });
    }

    loadDataFromResponse(data){
        console.log('urlBase-------->'+urlBase);
        data.lstDataTableData.forEach(record => { 
            data.lstDataTableColumns.forEach(column => {  
                let fieldPath = '';
                column['sortable']=true;
                if((column['type'] == 'reference' || column['type'] == 'url') && column['fieldName'] != 'recordLink'){
                    if(column['fieldName'].lastIndexOf('__c') != -1){
                        fieldPath = column['fieldName'].substring(0, column['fieldName'].lastIndexOf('__c'))+'__r';
                    }else{
                        fieldPath = column['fieldName'].substring(0, column['fieldName'].lastIndexOf('Id'));
                    }
                    let tempStr = fieldPath+'.Name';
                    column['type']='url';
                    column['typeAttributes'] ={label: {fieldName: tempStr},target: '_top'}     
                    if(record[fieldPath]) record[tempStr] = record[fieldPath]['Name'];
                    if(record[column['fieldName']]){
                        record[column['fieldName']] = '/'+urlBase+'/s/detail/' + record[column['fieldName']];
                    }
                }else if(column['fieldName'] == 'Name' || column['fieldName'] == 'recordLink'){
                    column['fieldName']='recordLink'; 
                    column['type']='url'; 
                    column['typeAttributes'] ={label: {fieldName: 'Name'},target: '_top'}
                    record.recordLink = '/'+urlBase+'/s/detail/' + record['Id'];
                    if(this.objectName == 'WOD_2__Claim__c'){
                        record.recordLink = '/'+urlBase+'/s/claim/' + record['Id'];
                    }else if(this.objectName == 'WOD_2__Inventory__c'){
                        record.recordLink = '/'+urlBase+'/s/inventory/' + record['Id'];
                    }
                }
            });
        });
    }
 
    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open'
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
        }
    }

    handleListViewChange(event){
        this.isInfiniteLoading=true;
        this.rowOffSet = 0;
        this.isLoaded = false;
        if(!this.sortingInProgress){
            let filter = event.target.dataset.filter; 
            this.currentFilter = filter;
            this.isExpanded = !this.isExpanded;
        }
        let metadataRecLst = this.customLstViewsMdtLst.filter(mdtRec => {
            return mdtRec.MasterLabel == this.currentFilter;
        });
        getListViewOnChange({objectName : this.objectName,metadataRecord : JSON.stringify(metadataRecLst[0]),
                             offSet : this.rowOffSet,limitSize: this.rowLimit, existingIdsSet: '',
                             sortedBy : this.sortedBy,sortDirection : this.sortDirection,searchKey : this.searchKey})
            .then(response => {
                if(response.status){
                    let data = JSON.parse(response.data);
                    this.loadDataFromResponse(data);
                    this.tableColumns = data.lstDataTableColumns;
                    this.tableData = data.lstDataTableData;
                    this.showLoadingSpinner = true;
                    this.isLoaded = true;
                    this.sortingInProgress = false;
                    if(data.lstDataTableData.length == 0){
                        const evt = new ShowToastEvent({
                            title: this.label.noRecordsFoundMsg,
                            message: '',
                            variant: 'info'
                        });
                        this.dispatchEvent(evt);
                    }
                }else{
                    
                }
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'Error'
                });
                this.error = error;
                this.dispatchEvent(evt);
            });
    }

    loadMoreData(event) {
        const currentData = this.tableData;
        let idsSet = [];
        currentData.forEach(element => {
            idsSet.push(element.Id);
        });
        const { target } = event;
        target.isLoading = true;
        let metadataRecLst = this.customLstViewsMdtLst.filter(mdtRec => { 
            return mdtRec.MasterLabel == this.currentFilter;
        });
        
        this.rowOffSet = this.rowOffSet + this.rowLimit;
        getListViewOnChange({objectName : this.objectName,metadataRecord : JSON.stringify(metadataRecLst[0]),
                             offSet : this.rowOffSet,limitSize: this.rowLimit, existingIdsSet: JSON.stringify(idsSet),
                             sortedBy : this.sortedBy,sortDirection : this.sortDirection})
            .then(response => {                                                     
                if(response.status){
                    let data = JSON.parse(response.data);
                    if(data.lstDataTableData.length == 0){
                        this.isInfiniteLoading = false;
                    }else{
                        this.loadDataFromResponse(data); 
                        //this.tableColumns = data.lstDataTableColumns;
                        let latestData = currentData.concat(data.lstDataTableData);
                        this.tableData = latestData;
                    }
                    this.showLoadingSpinner = true;
                    this.isLoaded = true;
                }else{           
                    
                }
            }).then(()=> {
                target.isLoading = false;
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'Error'
                });
                this.error = error;
                this.dispatchEvent(evt);
            })   
    }

    onHandleSort(event){
        const { fieldName: sortedBy, sortDirection } = event.detail;
        
        let sortDir = this.sortDirection;
        if(sortDir == 'asc'){
            sortDir = 'desc'
        }else{
            sortDir = 'asc'
        }
        this.sortDirection = sortDir;
        this.sortedBy = sortedBy;
        this.sortingInProgress = true;
        this.handleListViewChange(event);
    }
 
    handleClickExtend() {
        this.isExpanded = !this.isExpanded;
    }

    handleKeyChange( event ) {
        this.searchKey = event.target.value;
    }

    keyCheck( component,event ) {
        if (component.which == 13){
            this.sortingInProgress = true;
            this.handleListViewChange(event);
        }
    }
}