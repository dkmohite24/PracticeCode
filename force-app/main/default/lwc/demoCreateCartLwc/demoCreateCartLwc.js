import { LightningElement, track, wire } from 'lwc';
import retrieveProuduct from '@salesforce/apex/demoCreateCartController.retrieveProuduct';
const columns = [
    { label: 'Product Code', fieldName: 'ProductCode' },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Brand', fieldName: 'Brand__c'},
    { label: 'Description', fieldName: 'Product_Description__c' }, 
    {lable:'Family',fieldName:'Family'},
];
const DELAY = 1;
export default class DemoCreateCartLwc extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @track searchString = '100';
    @track initialRecords;
    @track selectedRows = [];
    
    @wire(retrieveProuduct)
    wiredProduct({ error, data }) {
        if (data) {
            console.log(data);
            this.data = data;
            console.log('data'+this.data);
            this.initialRecords = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    handleSearch(event){
         this.searchString = event.target.value;
         console.log('searchString'+ this.searchString);
     
  }

    
    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();

        this.data.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });

            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }

        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.selectedRows = [...selectedItemsSet];
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));
    }






}