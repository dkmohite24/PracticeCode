import { LightningElement, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
const options = [
    {'label':'India','value':'India'},
    {'label':'USA','value':'USA'},
    {'label':'China','value':'China'},
    {'label':'Rusia','value':'Rusia'}
];
export default class QuickActionLwc extends LightningElement {
    @track options = options;
    boolVariable = false ;
    handleTypeChange(event){
        this.Picklist_Value = event.detail.value; 
       console.log(this.Picklist_Value +'why this kolawary change'); 
       // Do Something.
       if(this.Picklist_Value === 'India'){
        this.boolVariable = true ;
        
        console.log(this.Picklist_Value +'why this kolawary India'); 
        
    }
    else if (this.Picklist_Value === 'USA'){
        this.boolVariable = true ;
        

    }
    else if (this.Picklist_Value=== 'Rusia'){
        this.boolVariable = true ;
        

    }
    
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}