import {api, wire, track, LightningElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class LookupRecordDetail extends LightningElement {
    @api recordId;
    @track record;
    @track _objectName;
    @track objectfields = [];
    @api get objectName(){
        return this._objectName;
    }
    set objectName(val){
        this._objectName = val;
        this.updatefields();
    }
    @track _fields;
    @api get fields(){
        return this._fields;
        
    } 
    set fields(val){
        this._fields = val;
        this.updatefields();
    }
    updatefields(){
        if(this.fields && this.objectName)
            this.objectfields = this.fields.map(field => (this.objectName + '.' + field));        
    }
    @track displayvalue = '';
    error;
    @wire(getRecord, { recordId: '$recordId', fields: '$objectfields' })
    wiredRecord({ error, data }) {
        if (data) {
            let displayvalues = [];
            this.record = data.fields;
            if(this.record){                
                let values = Object.values(this.record);            
                for(let i=0;i<values.length;i++){
                    if(values[i] && values[i].value){
                        displayvalues.push(values[i].value); 
                    }
                }
            }            
            this.displayvalue = displayvalues.join(' • ');
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
            this.displayvalue = '';
        }
    };
}