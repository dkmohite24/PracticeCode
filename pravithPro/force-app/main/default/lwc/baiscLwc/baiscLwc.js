import { api, LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getAccounts from '@salesforce/apex/getAccountRecordsLwc.getAccounts';
const options = [
    {'label':'India','value':'India'},
    {'label':'USA','value':'USA'},
    {'label':'China','value':'China'},
    {'label':'Rusia','value':'Rusia'}
];
export default class BaiscLwc extends LightningElement {
    @track options = options;
    @api name = 'myName';
    @track Picklist_Value;
    const
    @track phoneNo = '678743872';
    @track error; 
    @track accountList;
    @track columns = [
        { lable : 'Name', fieldName : 'Name' },
        {lable: 'Id', fieldName:'Id'}
        
    ]







    
    title = 'Practice Component';  
    userId = Id ;
    greetings = 'Welcome practice Lwc';
    message = 'this is Lwc with for loop';
    areDetailsVisible = false;
    boolVariable = false ;
    
    @track contacts =[
        {
            id : '8939074309732',
            Name : 'rishabh bhenka '

        },
        
        {
            id : '8939074309732',
            Name : 'rishabh bhenka Lo'
        },
        {
            id : '8939074309732',
            Name : 'rishabh bhenka Loda hai'
        }
    ]
    
    handleChange(event) {
        this.boolVariable = event.target.checked;
        this.areDetailsVisible = event.target.checked;
    }
    @wire(getAccounts) wiredAccounts({data,error}){
        if (data) {
             this.accountList = data;
       
        } else if (error) {
        console.log(error.details.data.message +'why this error2');
        }
   }
   handleTypeChange(event){
     this.Picklist_Value = event.detail.value; 
    console.log(this.Picklist_Value +'why this kolawary change'); 
    // Do Something.
    if(this.Picklist_Value === 'India'){
        this.boolVariable = true ;
        this.title= '1111';
        console.log(this.Picklist_Value +'why this kolawary India'); 
        
    }
    else if (this.Picklist_Value === 'USA'){
        this.boolVariable = true ;
        this.title= '12121212';
        console.log(this.Picklist_Value +'why this kolawary D'); 

    }
    else if (this.Picklist_Value=== 'Rusia'){
        this.boolVariable = true ;
        console.log(this.Picklist_Value +'why this kolawary D'); 
        this.title= '3333';

    }
    

    
    }
    jshandle(){
         
        if (this.boolVariable ===true){
            this.boolVariable = false ;
            this.title= '93939393';
            
        }
        else {
            this.boolVariable = true ;
            this.phoneNo = 'Rishabh';
        }
       
        if(this.areDetailsVisible === true ){
            this.areDetailsVisible = true;
        }else if(this.areDetailsVisible === false ){
            this.areDetailsVisible = true ;
        }
    }
}