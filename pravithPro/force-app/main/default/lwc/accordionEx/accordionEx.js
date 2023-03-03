import {LightningElement,wire,track} from 'lwc';
import getAccounts from '@salesforce/apex/getAccountRecordsLwc.getAccounts';
export default class AccordionEx extends LightningElement {
@track multiple = true;
@track accounts ;
@wire(getAccounts) 
wiredAccountss({
    error,
    data
}) {
    if (data) {
        this.accounts = data;
        console.log(data+'noice');
        console.log(JSON.stringify(data, null, '\t'));
        
        data.forEach(function (item, key) {
            console.log(key);  
            console.log(item); 
        });
        
    } else if (error) {
        this.error = error;
        console.log('noice'); 
    }
}

}