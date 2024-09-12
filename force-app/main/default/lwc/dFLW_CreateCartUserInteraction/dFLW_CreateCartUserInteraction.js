import { LightningElement, api, track, wire } from 'lwc';
import getAddproductsList from '@salesforce/apex/dflw_AddEditProductsController.getAddproductsList';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';


// eslint-disable-next-line @lwc/lwc/no-leading-uppercase-api-name
export default class dflw_AddEditProducts extends LightningElement {
//@api SelectedProductrecords = [];

@track promoOptions = [
    { label: 'None', value: 'None' },
    { label: 'Defective/replacement', value: 'PROMO10' },
    { label: 'Wrong/missing part', value: 'PROMO20' }
];

@track fieldColumns = [
    {
        label:'Action',
        type:"button-icon",
        typeAttributes:{
        name:'Delete',
        title:'Delete',
        iconName:'utility:delete',
        iconClass:'slds-icon-text-error'
   }
    },
{ label: 'Name', fieldName: 'Name' },
{ label: 'Description', fieldName: 'Product_Description__c'},

{
    label: 'Quantity',
    fieldName: 'Quantity',
    type: 'number',
    editable: true,
    default:  1,
    cellAttributes: {
        
        alignment: 'left',
        class: 'slds-truncate'
    }
},
{ label: 'Unit price', fieldName: 'Unit_price__c'},
{
    label: 'Promo code', fieldName: 'Promo code', type: 'picklistColumn', editable: true, typeAttributes: {
        placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
        value: { fieldName: 'Type' }
}
}

];
@track Quantity=1;
@track showTables = false;
SelectedProductrecords2=[];
@track data = [];
@track pickListOptions;
@track temp = [];
@track deleteID;

@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;
@wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: TYPE_FIELD
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
            this.pickListOptions = JSON.parse(JSON.stringify( this.pickListOptions ));
            console.log('this.pickListOptions**'+this.pickListOptions);
        } else if (error) {
            console.log(error);
        }
    }

deleteHandle(event){

    const recId1 =event.currentTarget.dataset.id;
    console.log('event'+event);
    console.log(event.currentTarget);
    console.log('deleteID **'+this.deleteID);
    // eslint-disable-next-line no-alert
    alert('deleteID'+recId1);

}

callRowAction(event) {
    const recId = event.detail.row.Id;
    //alert('deleteID'+recId);
    const actionName = event.detail.action.name;
    if (actionName === 'Delete') {
       // this.handleDeleteRow(recId);
       console.log(recId+'**'+actionName);
    }

}



handleButtonClick(){
    this.showTables = !this.showTables;
}

@api
    get SelectedProductrecords() {
        console.log('OUTPUT : 1');
        return this.SelectedProductrecords2;
    }
    set SelectedProductrecords(value) {
                
                console.log(this.temp.length);
                let data = value;
                data.forEach(e => {
                    console.log(e);
                    console.log(JSON.stringify(e));
                    console.log(e.Name);
                    console.log(this.temp.findIndex(i => i.Id == e.Id));
                    if(this.temp.findIndex(i => i.Id == e.Id) == -1){
                    this.temp.push(e);
                    }
                });
                console.log(this.temp.length);
                console.log(this.temp);
                this.SelectedProductrecords2 = this.temp;
                this.SelectedProductrecords2 = JSON.parse(JSON.stringify(this.SelectedProductrecords2));
                console.log('this.SelectedProductrecords2** temp'+JSON.stringify(this.SelectedProductrecords2));
                
               
  }
   





}