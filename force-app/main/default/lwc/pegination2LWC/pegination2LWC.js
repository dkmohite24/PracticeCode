/* eslint-disable no-unused-vars */
/* eslint-disable radix */
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import getContact from '@salesforce/apex/paginationControllerLWC.getContact';

const chunk = (arr, size) => {
    const chunkedArray = [];
    for (let i = 0; i < arr.length; i++) {
       const last = chunkedArray[chunkedArray.length - 1];
       if(!last || last.length === size){
          chunkedArray.push([arr[i]]);
       }else{
          last.push(arr[i]);
       }
    }
    return chunkedArray;
};

export default class PaginationContactList extends LightningElement 
{
    @api contactList;
    currentPage="1";
    @api contactChunks;
    contactToDisplay;
    totalPages;
    disableNext=false;
    disablePrev=true;
    pageOptions=[];
    size;
    totalRecords;
    pageLimit="10";

    columns = [
        { label: 'First Name', fieldName: 'FirstName', type: 'text' },
        { label: 'Last Name', fieldName: 'LastName', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'text' },
        {
            type: 'action',
            typeAttributes:  { rowActions: [{ label: 'Edit', name: 'edit' },{ label: 'Cancel', name: 'cancel' }] }
        },
    ];

    //get options for the limit dropdown
    get pageLimitOptions() {
        var pageLimitList = [
            { label: '10', value: '10' },
            { label: '15', value: '15' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
        ];
        return pageLimitList;
    }

    connectedCallback()
    {
        getContact()
        .then(res=>{
            this.contactList = res;
            this.setPagination(10);
        })
        .catch(err=>{
            console.log(err);
        })
    }

    setPagination(size)
    {
        if(this.contactList.length > 0)
        {
            this.disableNext=false;
            this.disablePrev=true;
            this.size=size;
            this.currentPage="1";
            this.totalRecords=this.contactList.length;
            this.contactChunks=chunk(this.contactList, this.size);
            this.contactToDisplay=this.contactChunks[0];
            this.totalPages=this.contactChunks.length;
            var pageOptObj={};
            for(var i=1; i<= this.totalPages; i++)
            {
                pageOptObj={};
                pageOptObj.label=i.toString();
                pageOptObj.value=i.toString();
                this.pageOptions.push(pageOptObj);
            }
            this.calculatePageText();
        }
    }

    calculatePageText()
    {
        var end=(parseInt(this.currentPage) * this.size) > this.totalRecords ? this.totalRecords : (parseInt(this.currentPage) * this.size);
        this.pageParam=((parseInt(this.currentPage) * this.size) - (this.size-1))+' to '+end;
    }

    handleNext()
    {
        this.currentPage=(parseInt(this.currentPage)+1).toString();

        if(parseInt(this.currentPage) >= this.totalPages)
        {
            this.currentPage=this.totalPages.toString();
            this.disableNext=true;
            this.disablePrev=false;
        }
        else
        {
            this.disableNext=false;
            this.disablePrev=false;
        }

        this.contactToDisplay=this.contactChunks[parseInt(this.currentPage)-1];
        this.calculatePageText();
    }

    handlePrev()
    {
        this.currentPage=(parseInt(this.currentPage)-1).toString();

        if(parseInt(this.currentPage) <= "1")
        {
            this.currentPage="1";
            this.disableNext=false;
            this.disablePrev=true;
        }
        else
        {
            this.disableNext=false;
            this.disablePrev=false;
        }

        this.contactToDisplay=this.contactChunks[parseInt(this.currentPage)-1];
        this.calculatePageText();
    }

    handlePageChange(event)
    {
        this.currentPage=event.target.value;
        this.contactToDisplay=this.contactChunks[parseInt(this.currentPage)-1];
        if(parseInt(this.currentPage) <= "1")
        {
            this.disableNext=false;
            this.disablePrev=true;
        }
        else if(parseInt(this.currentPage) >= this.totalPages)
        {
            this.disableNext=true;
            this.disablePrev=false;
        }
        else
        {
            this.disableNext=false;
            this.disablePrev=false;
        }
        this.calculatePageText();
    }

    handleFirst()
    {
        this.currentPage="1";
        this.disableNext=false;
        this.disablePrev=true;
        this.contactToDisplay=this.contactChunks[parseInt(this.currentPage)-1];
        this.calculatePageText();
    }

    handleLast()
    {
        this.currentPage=this.totalPages.toString();
        this.disableNext=true;
        this.disablePrev=false;
        this.contactToDisplay=this.contactChunks[parseInt(this.currentPage)-1];
        this.calculatePageText();
    }

    handleLimitChange(event) {
        this.pageLimit = event.detail.value;
        this.selectedPage='1';
        this.size = parseInt(this.pageLimit)
        this.setPagination(this.size); //invoking the pagination logic
        //this.calculatePageText();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                //this.showRowDetails(row);
                break;
            case 'cancel':
                //this.showRowDetails(row);
                break;
            default:
        }
    }
}