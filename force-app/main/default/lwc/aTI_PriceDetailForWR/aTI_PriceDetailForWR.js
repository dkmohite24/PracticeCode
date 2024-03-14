import { LightningElement, wire, api,track } from 'lwc';
import getTransactionLineItems from '@salesforce/apex/ATI_PriceDetailForWRController.getTransactionLineItems';
import getUserInfo from '@salesforce/apex/ATI_PriceDetailForWRController.getUserDetails';
import updateTransactionLineItems from '@salesforce/apex/ATI_PriceDetailForWRController.updateTransactionLineItems';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HANDLING_FEE_FIELD from '@salesforce/schema/WOD_2__Transaction_Memo_History_Line_Item__c.ATI_Handling_Fee__c';
import LATE_FEE_FIELD from '@salesforce/schema/WOD_2__Transaction_Memo_History_Line_Item__c.ATI_Late_Fee__c';
import TOTAL_AMOUNT_FIELD from '@salesforce/schema/WOD_2__Transaction_Memo_History_Line_Item__c.WOD_2__Total_Amount__c';
import UNIT_AMOUNT_FIELD from '@salesforce/schema/WOD_2__Transaction_Memo_History_Line_Item__c.WOD_2__Unit_Amount__c';
import ID_FIELD from '@salesforce/schema/WOD_2__Transaction_Memo_History_Line_Item__c.Id';
import USER_ID from '@salesforce/user/Id';
import Name from '@salesforce/label/c.ATI_Name';
import Unit_Amount from '@salesforce/label/c.ATI_Unit_Amount';
import Handling_Fee from '@salesforce/label/c.ATI_Handling_Fee';
import Late_Fee from '@salesforce/label/c.ATI_Late_Fee';
import Total_Amount from '@salesforce/label/c.ATI_Total_Amount';
import successTitle from '@salesforce/label/c.ATI_Success';
import successMsg from '@salesforce/label/c.ATI_Line_Items_Updated_SuccessFully';
import errorMsg from '@salesforce/label/c.Claim_GenericErrorMessage';
import errorTitle from '@salesforce/label/c.ATI_Error_in_fetching_Data';

const COLS = [
    { label: Name, fieldName: 'Name', editable: false },
    { label: Unit_Amount, fieldName: 'WOD_2__Unit_Amount__c', editable: false },
    { label: Handling_Fee, fieldName: 'ATI_Handling_Fee__c', editable: false },
    { label: Late_Fee, fieldName: 'ATI_Late_Fee__c', editable: false },
    { label: Total_Amount, fieldName: 'WOD_2__Total_Amount__c', editable: false }
];
export default class ATI_PriceDetailForWR extends LightningElement {
    @api recordId;
    columns = COLS;
    draftValues = [];

    @wire(getTransactionLineItems, { wrObjId: '$recordId' })
    transactionHistLIs;

    label = {
        successTitle,
        successMsg,
        errorMsg,
        errorTitle
    };

    //@wire(getUserInfo, { userId: USER_ID })  // call Apex method and pass User id
    //userData;

    connectedCallback() {
        getUserInfo({'userId': USER_ID}).then(response => { 
            response = JSON.parse(JSON.stringify(response));
            console.log('response--------->',response);
            if(response.Profile.Name.trim()=='System Administrator' || response.Profile.Name.trim()=='ATI Warranty Claim Processor'){
                this.columns.forEach(col =>{
                    if(col['fieldName']=='ATI_Handling_Fee__c' || col['fieldName']=='ATI_Late_Fee__c'){
                        col['editable'] = true;
                    }
                });
            }
            console.log('columns-------->',this.columns);
        }).catch(error => {
            console.log('error-------->',error);
        });
    }

    getOriginalValue(lineItemId){
        var result = this.transactionHistLIs.data.filter(lineItemObj => {
            return lineItemObj.Id === lineItemId;
        });
    }
    
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        updatedFields.forEach(record =>{
            var result = this.transactionHistLIs.data.filter(lineItemObj => {
                return lineItemObj.Id === record.Id;
            });
            if(record['ATI_Handling_Fee__c'] === "") {
                record['ATI_Handling_Fee__c'] = 0;
            }
            if(record['ATI_Late_Fee__c'] === ""){
                record['ATI_Late_Fee__c'] = 0;
            }
            if(record['ATI_Late_Fee__c']) record['ATI_Late_Fee__c'] = parseInt(record['ATI_Late_Fee__c']);
            if(record['ATI_Handling_Fee__c']) record['ATI_Handling_Fee__c'] = parseInt(record['ATI_Handling_Fee__c']);
            if(Number.isInteger(result[0]['WOD_2__Unit_Amount__c']) && Number.isInteger(record['ATI_Late_Fee__c']) 
                && Number.isInteger(record['ATI_Handling_Fee__c'])){
                record['WOD_2__Total_Amount__c'] = (result[0]['WOD_2__Unit_Amount__c'] + record['ATI_Late_Fee__c'])-record['ATI_Handling_Fee__c'];
            }
            else if(Number.isInteger(result[0]['WOD_2__Unit_Amount__c']) && Number.isInteger(record['ATI_Late_Fee__c']) 
                && Number.isInteger(result[0]['ATI_Handling_Fee__c'])){
                record['WOD_2__Total_Amount__c'] = (result[0]['WOD_2__Unit_Amount__c'] + record['ATI_Late_Fee__c'])-result[0]['ATI_Handling_Fee__c'];
            }
            else if(Number.isInteger(result[0]['WOD_2__Unit_Amount__c']) && Number.isInteger(record['ATI_Handling_Fee__c']) 
                && Number.isInteger(result[0]['ATI_Late_Fee__c'])){
                record['WOD_2__Total_Amount__c'] = (result[0]['WOD_2__Unit_Amount__c'] +result[0]['ATI_Late_Fee__c'])-record['ATI_Handling_Fee__c'];
            }
        });
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

        await updateTransactionLineItems({data: updatedFields})
            .then(result => {
                console.log(JSON.stringify("Apex update result: "+ result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.successTitle,
                        message: this.label.successMsg,
                        variant: 'success'
                    })
                );

            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);

            // Display fresh data in the datatable
            refreshApex(this.transactionHistLIs).then(() => {
                // Clear all draft values in the datatable
                this.draftValues = [];
            });
        }).catch(error => {
            console.log('error----->',error)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.errorTitle,
                    message: this.label.errorMsg,
                    variant: 'error'
                })
            );
        });
    }
}