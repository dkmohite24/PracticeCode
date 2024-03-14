import { LightningElement, track, wire, api } from 'lwc';
import getClaimLineItems from '@salesforce/apex/ATI_ExportToExcel.getClaimLineItems';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ExportDataAsCsvOrXls extends LightningElement {
    @api recordId;
    @api reactiveValue;
    hasClaimLineItems = false;
    showExportMessage = false;
    showCancelButton = false;
 
 
   
    @track chaimLineItemData = {}
   
    columnHeader = ['Name', 'ETC', 'Serial Number' , 'Product Name' , 'Price' , 'Duplicate Claim' ,  'VIN' , 'Ship Date' , 'In Service Date' , 'Actual Submission Date' ]
 
    @wire(getClaimLineItems,{claimHeaderId :'$recordId'})
    wiredData({ error, data }) {
        if (data) {
            console.log('Data', data);
            this.chaimLineItemData = data;
            this.hasClaimLineItems = data.length > 0;
            this.showExportMessage = this.hasClaimLineItems;
            this.showCancelButton = this.hasClaimLineItems;
 
        } else if (error) {
            console.error('Error:', error);
        }
    }
 
 
    exportClaimLineItemtData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';  
        doc += 'th {';
        doc += '    font-weight: bold;'; // Apply bold font to table headers
        doc += '}';      
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'          
        });
        doc += '</tr>';
        // Add the data rows
        this.chaimLineItemData.forEach(record => {
            doc += '<tr>';
            doc += '<td>' + record.Name + '</td>';
            doc += '<td>' + record.ETC__c + '</td>';
            doc += '<td>' + record.Serial_Number__c + '</td>';
            if(record.Product__c){
                doc += '<td>' + record.Product__r.Name+ '</td>';
            }
            else{
                doc += '<td>' + 'No product'+ '</td>';
            }
            
            doc += '<td>' + record.Price__c + '</td>';
            doc += '<td>' + record.Duplicate_Claim__c + '</td>';
            doc += '<td>' + record.VIN__c + '</td>';
            doc += '<td>' + record.Ship_Date__c + '</td>';
            doc += '<td>' + record.In_Service_Date__c + '</td>';
            // Add Actual Submission Date field
            doc += '<td>' + record.Claim__r.ATI_Actual_Submission_Date__c + '</td>';
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'ClaimLineItems_Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
   
}