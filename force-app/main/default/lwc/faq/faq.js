import { LightningElement, track, wire, api } from 'lwc';
import getCustomObjectData from '@salesforce/apex/fetchFaqObjects.getCustomObjectData';
import getRatingPicklistValues from '@salesforce/apex/fetchFaqObjects.getPicklistValues';

export default class Faq extends LightningElement {
    @track getCustomObjectData;
    @track activeSection;
    @track currentPage = 1;
    @track itemsPerPage = 7;
    @track searchQuery;
    @track searchPick;
    @api faqValue = 'English';

    handlePicklistChange(event) {
        this.faqValue = event.target.value;
        this.fetchPicklistData();
    }

    @wire(getRatingPicklistValues, {})
    wiredRatingPicklistValues({ error, data }) {
        if (data) {
            this.languageOptions = data.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        else if (error) {
            console.error(error);
        }
    }
    connectedCallback() {
        this.fetchCustomObjectData();
       
    }

    fetchCustomObjectData() {
        getCustomObjectData({ searchQuery: this.searchQuery, searchPick: this.faqValue })
            .then(result => {
                this.getCustomObjectData = result;
                this.activeSection = result[0]?.Section__c;
            })
            .catch(error => {
                console.error('Error fetching FAQ data', error);
            });
    }
    fetchPicklistData() {
        getCustomObjectData({ searchPick: this.faqValue, searchQuery: this.searchQuery })
            .then(result => {
                this.getCustomObjectData = result;
                this.activeSection = result[0]?.Section__c;
            })
            .catch(error => {
                console.error('Error fetching FAQ data', error);
            });
    }

    handleSearch(event) {
        this.searchQuery = event.target.value;
        this.fetchCustomObjectData();
    }

    get displayedCustomObjectData() {
        if (!this.getCustomObjectData) {
            return [];
        }

        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;
        return this.getCustomObjectData.slice(startIndex, endIndex);
    }

    get totalPages() {
        return Math.ceil((this.getCustomObjectData?.length || 0) / this.itemsPerPage);
    }

    handleSectionToggle(event) {
        this.activeSection = event.detail.openSections[0];
    }

    handlePageChange(event) {
        this.currentPage = event.detail.selectedPage;
    }

}