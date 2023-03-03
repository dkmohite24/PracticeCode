import { LightningElement, track } from 'lwc';
import getAccountData from '@salesforce/apex/lwcPaginationTaskController.getAccountData';
import getContactData from '@salesforce/apex/lwcPaginationTaskController.getContactData';
import updateRecord from '@salesforce/apex/lwcPaginationTaskController.updateRecord';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import updateContacts from '@salesforce/apex/lwcPaginationTaskController.updateContacts';
import conDelete from '@salesforce/apex/lwcPaginationTaskController.conDelete';

import LightningConfirm from "lightning/confirm";
export default class LwcPaginationTask2 extends LightningElement {
    searchKey;
    @track accEditedName;
    @track accEditedPhone;
    @track accEditedIndustry;
    @track accEditedType;
    @track contactsLst;
    @track currentRecordId ;
    @track modalContainer = false;
    @track accRow={};
    @track conRow ={};
    @track accounts;
    @track accEditModel = false; 
    @track conEditModel = false;
    @track conEditedName;
    @track conEditedEmail ;
    @track conEditedTitle;
    @track conEditedPhone;
    @track conrecId;
    
    
    get options(){

        return [
    
            { label: 'Asc', value: 'Asc' },
    
            { label: 'Desc', value: 'Desc' },
    
        ];
    }
    handlePickListChange(event) {

        this.value = event.target.value;
        if(this.value === 'Asc'){
            this.fieldname = 'Name';
            console.log(this.value+'++++this.value');
            let parseData = JSON.parse(JSON.stringify(this.accounts));
       
        let keyValue = (a) => {
            return a[this.fieldname];
        };
 
       let isReverse  = this.value ? 1: -1;
 
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.accounts = parseData;
            
        }
        else if(this.value === 'Desc'){

            console.log(this.value+'++++this.value');  this.fieldname = 'Name';
            console.log(this.value+'++++this.value');
            let parseData = JSON.parse(JSON.stringify(this.accounts));
       
        let keyValue = (a) => {
            return a[this.fieldname];
        };
 
       let isReverse  = this.value ? -1: 1;
 
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.accounts = parseData;

            
        }

        
    }
    conNameChange(event){
        this.conEditedName= event.target.value;
        console.log('this.conEditedName'+this.conEditedName);  
    }
    
    conTitleChange(event){
        this.conEditedTitle= event.target.value;
        console.log('this.conEditedTitle'+this.conEditedTitle);
    }
    conPhoneChange(event){
        console.log('this.conEditedPhone'+this.conEditedPhone);
        this.conEditedPhone= event.target.value;
    }
    conEmailChange(event){
        console.log('this.conEditedEmail'+this.conEditedEmail);
        this.conEditedEmail= event.target.value;
    }
    conEditOpen(){
        this.conEditModel=true;
        
    }
    conEditClose(){ 
        this.conEditModel=false;
    }
    conRowAction(event){
        this.conrecId =  event.detail.row.Id;
       const contactRow = event.detail.row;
       this.conRow=contactRow; 
       this.modalContainer = false;
       window.console.log('this.conRow'+JSON.stringify(this.conRow)); 
        const actionName = event.detail.action.name;  
        if ( actionName === 'Edit' ){  
        
            
            console.log('insdeEditeBotton'); 
            this.conEditModel=true;
            
  
        } else if ( actionName === 'Delete') {  
            this.handleConfirmClick();
            console.log('insdeEditeBottonview'); 
        }          
  
    }  
  
    
    conSave(){  
        console.log("insideConSave");
        updateContacts({
            conId: this.conrecId , 
            conLastName: this.conEditedName,
            conEmail: this.conEditedEmail, 
            conTitle: this.conEditedTitle,
            conPhone: this.conEditedPhone
                        })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if(this.message !== undefined || this.message !== null ) {

                console.log('inside msg con'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact created',
                        variant: 'success',
                    }),
                    
                );
                refreshApex(this.accounts);
                this.conEditModel=false;
                

            }
            console.log(JSON.stringify(result));
            console.log("result", this.message);
        })
        
    }
    async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to delete this?",
            variant: "default", // headerless
            label: "Delete a record"
        });
    
        //Confirm has been closed
    
        //result is true if OK was clicked
        if (result) {
            this.contactDelete();
            //go ahead and delete
        } else {
            //do something else 
        }
    }
    contactDelete(){
        conDelete({
            conId: this.conrecId
        })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if(this.message !== undefined || this.message !== null ) {
                console.log('inside msg con Delete'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact Deleted',
                        variant: 'success',
                    }),
                    
                );
                this.conEditModel=false;
                

            }
            console.log(JSON.stringify(result));
            console.log("result", this.message);
        })
        
        
    }

    accNameChange(event){
        this.accEditedName= event.target.value;
         
        console.log('this.accEditedName'+this.accEditedName);
    }
    
    accPhoneChange(event){
        this.accEditedPhone= event.target.value;
        console.log('this.AccPhone'+this.accEditedPhone);
    }
    accIndustryChange(event){
        console.log('this.accEditedIndustry'+this.accEditedIndustry);
        this.accEditedIndustry= event.target.value;
    }
    accTypeChange(event){
        console.log('this.accEditedType'+this.accEditedType);
        this.accEditedType= event.target.value;
    }

    accsave(){ 
        console.log('this.accEditedName'+this.accEditedName);
        if(this.accEditedName !== "undefined" || this.accEditedName !== null ||
        this.accEditedPhone !== "undefined" || this.accEditedPhone !== null ||
        this.accEditedIndustry !== "undefined" || this.accEditedIndustry !== null ||
        this.accEditedType !== "undefined" || this.accEditedType !== null
        ){
            console.log('this.accEditedPhone'+this.accEditedPhone);
        updateRecord({accId: this.currentRecordId , accChangeName: this.accEditedName,
            accChangePhone: this.accEditedPhone, accChangeType: this.accEditedType,
                     accchangeIndustry: this.accEditedIndustry
                        })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if(this.message !== undefined || this.message !== null ) {
                console.log('inside msg'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account created',
                        variant: 'success',
                    }),
                    
                );
                this.accEditModel=false;
                

            }
            console.log(JSON.stringify(result));
            console.log("result", this.message);
        })
        .catch( error=>{
            this.accounts = error;
        });
        }

    }
    accEditOpen(){
        this.accEditModel=true;
        this.modalContainer=false;
    }
    accEditClose(){
        this.accEditModel=false;
    }
    closeModalAction(){
        this.modalContainer=false;
    }
    handleRowAction(event){
        this.currentRecordId = event.detail?.row?.Id;

        const dataRow = event.detail.row;
        window.console.log('dataRow@@' + JSON.stringify(dataRow));
        this.accRow=dataRow;
        window.console.log('contactRow## ' + dataRow);
        
        this.modalContainer=true;
        getContactData({
            accId:this.currentRecordId
        })
        .then(result => {
            console.log('SUCCESS');
            this.contactsLst = result ;
            
        })
        .catch((error) => {
            this.errorMessage=error;
			console.log('unable to update the record due to'+JSON.stringify(this.errorMessage));
        });
    }

    //This funcation will fetch the Account Name on basis of searchkey
    SearchAccountHandler(event){
        //call Apex method.
        this.searchKey = event.target.value;
        getAccountData({textkey: this.searchKey})
        .then(result => {
                this.accounts = result;
        })
        .catch( error=>{
            this.accounts = error;
        });

    }
    cols = [
        {label:'Account Name', fieldName:'Name' , type:'text'} ,
        {
            label: 'View',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'action:preview',
                title: 'Preview',
                variant: 'border-filled',
                alternativeText: 'View'
            }
          }
              
    ]
    cols2 = [
    
        {label:'Contact Name', fieldName:'LastName' , type:'text'} ,
        {label:'Phone', fieldName:'Phone' , type:'Phone'} ,
        {label:'Email', fieldName:'Email' , type:'text'},
        { type: "button", typeAttributes: {  
            label: 'Edit',  
            name: 'Edit',  
            title: 'Edit',  
            disabled: false,  
            value: 'Edit',  
            iconPosition: 'left'  
        } },  
        { type: "button", typeAttributes: {  
            label: 'Delete',  
            name: 'Delete',  
            title: 'Delete',  
            disabled: false,  
            value: 'Delete',  
            iconPosition: 'Delete'  
        } } 
              
    ]
}