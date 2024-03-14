import { LightningElement,track,wire,api } from 'lwc';
    import USER_ID from '@salesforce/user/Id';
    import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
    import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
    import CONTACT_ID from '@salesforce/schema/User.ContactId';
    import getWarrantyCoverages from '@salesforce/apex/ATI_extndWarrantyRegController.getWarrantyCoverages';
    import warrantyRuleException from '@salesforce/apex/ATI_extndWarrantyRegController.warrantyRuleException'; //db
    import getExtendedWarrantyPricing from '@salesforce/apex/ATI_extndWarrantyRegController.getExtendedWarrantyPricing';
    import registerExtWarrantyCoverages from '@salesforce/apex/ATI_extndWarrantyRegController.registerExtWarrantyCoverages';
    import isPartnerUser from '@salesforce/apex/ATI_Utils.isPartnerUser';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { NavigationMixin } from 'lightning/navigation';
    import errorExtendedWR from '@salesforce/label/c.ATI_Error_ExtendedWR';
    import claim_selectDealershipFieldLabel from '@salesforce/label/WOD_2.claim_selectDealershipFieldLabel';
    import claim_searchDealerPlaceholder from '@salesforce/label/WOD_2.claim_searchDealerPlaceholder';
    import Claim_DealerNumberFieldLabel from '@salesforce/label/WOD_2.Claim_DealerNumberFieldLabel';
	import Purchase_Less_Install_Date from '@salesforce/label/c.ATI_Purchase_Less_Install_Date';
    import Agreement_date_Less_Install_Date from '@salesforce/label/c.ATI_Agreement_date_Less_Install_Date';
	import ATI_ETC_Pricing_Error from '@salesforce/label/c.ATI_ETC_Pricing_Error';


    const columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Type', fieldName: 'WOD_2__Type__c', type: 'text' },
        { label: 'Months Covered', fieldName: 'WOD_2__Months_Covered__c', type: 'number' },
        { label: 'Active From', fieldName: 'WOD_2__Active_From__c', type: 'date' },
        { label: 'Active Untill', fieldName: 'WOD_2__Active_Until__c', type: 'date' }
    ];

    const columns1 = [
        { label: 'Policy Name', fieldName: 'policyName',type:'text' },
        { label: 'Base Price', fieldName: 'basePrice',type:'number' },
        { label: 'Handling Fee', fieldName: 'handlingFee', type: 'number', editable : false},
        { label: 'Late Fee', fieldName: 'lateFee', type: 'number', editable: false},
        { label: 'Final Price', fieldName: 'finalPrice', type: 'number' }
    ];

    export default class ExtendedWarrantyRegistrationComp extends NavigationMixin(LightningElement) {
        @track policyDetails=[];
        @track extendedWRpricingDetails=[];
        @track policyIds=[];
        @track dateValue;
        @track seePricingData=false;
        @track seeExtndPolicy=false;
        @track inProgressWR=false;
        @track purchaseDateVal;
        @track ceNumber;
        @track trackingNumber;
        @track poNumber;
        @track selection=[];
        @track showSpinner = false;
		@track warningMsg;
        columns = columns;
        columns1 = columns1;
        lookUpConfigurationMetadataName = 'WOD_2__Claim_Machine_AccountLookup';
        accountId = '';
        extraParams;
        draftValues = [];
        wr = {};
        purchasedCoverageDetails = '';
        extendedCoverageWrapper = {};
        coverageDetails = [];
        dealerNumber = '';
        disableSaveButton;
        @track error;
        @api recordId;
        label = {
            errorExtendedWR,
            claim_searchDealerPlaceholder,
            claim_selectDealershipFieldLabel,
            Claim_DealerNumberFieldLabel,
            Purchase_Less_Install_Date,
            Agreement_date_Less_Install_Date,
			ATI_ETC_Pricing_Error

        };
        @track today;
        @track allValid = true;
        @wire(getRecord, { recordId: USER_ID, fields: [ACCOUNT_ID,CONTACT_ID]})
        user({
            error,
            data
        }) {
            if (data) {
                this.accountId = getFieldValue(data, ACCOUNT_ID);
            }
        }

        connectedCallback() {
            let todayTemp = new Date();
            let dd = String(todayTemp.getDate()).padStart(2, '0');
            let mm = String(todayTemp.getMonth() + 1).padStart(2, '0'); //January is 0!
            let yyyy = todayTemp.getFullYear();

            this.today = yyyy+ '/' +mm + '/' + dd;
            console.log('------',this.today);
            this.extraParams = JSON.stringify({});               

        }

    handleLookupSelected(event) {
        console.log(JSON.parse(JSON.stringify(event.detail.selectedObject)));
        console.debug(JSON.parse(JSON.stringify(event.detail.selectedObject)));
        this.dealerNumber = event.detail.selectedObject.AccountNumber;        
        this.accountId = event.detail.selectedObject.Id;
        if(this.dealerNumber && this.dealerNumber.length != 10){
            this.inProgressWR = true;
            this.error = 'Account is not valid';
        }else if(this.purchaseDateVal != null && this.purchaseDateVal !='' && this.allValid){
            this.fetchCoverageData();
        }
    }

    handleSelectedLookupRemoved(event){
        this.dealerNumber = null;    
        this.accountId = null;
    }


    onCENumberChange(event){
        this.ceNumber = event.target.value;   
    }

    onTrackingNumberChange(event){
        this.trackingNumber = event.target.value;   
    }

    onPONumberChange(event){
        this.poNumber = event.target.value;   
    }


    fetchCoverageData(){
        this.seePricingData = false;
        this.seeExtndPolicy = false;
        this.inProgressWR = false;
        this.showSpinner = true;
        isPartnerUser().then(result =>{
            if(result.data == 'false'){
                let columns = this.columns1;
                columns.forEach(function(column){
                    if(column.fieldName == 'lateFee' || column.fieldName == 'handlingFee'){
                        column.editable = true;
                    }
                });
            }
        });
        let inputParam = {
            invId: this.recordId,
            purchaseDt: this.purchaseDateVal,
            ceNumber:this.ceNumber, 
            trackingNumber:this.trackingNumber, 
            poNumber:this.poNumber, 
            accountId:this.accountId};
        getWarrantyCoverages({wntyCoveragesParam: JSON.stringify(inputParam)}).then(result =>{
            console.debug('Data Received -> ' + result);
            let res = JSON.parse(result);            
            if(res.status){
                this.policyDetails = res.policyDetails;
                this.wr = res.wr;
                this.coverageDetails = res.warrantyCoverages;
                this.seeExtndPolicy= true;
                this.inProgressWR=false;
                this.error = '';
				if(this.label.Purchase_Less_Install_Date == res.errorMsg){
                    this.warningMsg = this.label.Agreement_date_Less_Install_Date;
                } else {
                    this.warningMsg = '';
                }

                console.log('correct place to check+++');
                this.callWarrantyRuleException();
            } else {
                this.error = res.errorMsg;
                this.seeExtndPolicy= false;
                this.seePricingData = false;
                this.inProgressWR= true;
            }
            this.showSpinner = false;
        }).catch(error => {
            console.debug('Error Received -> ' + error);
            this.showSpinner = false;
        });
    }

    callWarrantyRuleException(){
	    console.log('this.wr.Id'+this.wr.Id);

        warrantyRuleException({wrId: this.wr.Id}).then(result =>{    
        console.log('warranty rule res.errorMsg'+result.errormessage); 
        if(result.errormessage != null && result.errormessage != ''){
            this.warningMsg =   result.errormessage;
        }
        
        this.showSpinner = false;
        }).catch(error1 => {
            console.debug('Error Received -> ' + error1);
            this.showSpinner = false;
        });
    }

    handleDateChange(event){
        this.validateComponentFields(event);
        this.purchaseDateVal = event.target.value;
        if(this.accountId == null || this.accountId == '' || this.accountId == undefined){
            this.inProgressWR = true;
            this.error = 'Please select the bussiness partner';
        } else if(this.dealerNumber && this.dealerNumber.length != 10){
            this.inProgressWR = true;
            this.error = 'Account is not valid';
        } else {
            this.fetchCoverageData();

        }        
    }

    validateComponentFields(event){
        this.allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        this.allValid = this.allValid && this.accountId;
    }

    handleRowAction(event){
        this.validateComponentFields(event);
        // eslint-disable-next-line @lwc/lwc/no-async-await
        const selectedRows  = event.detail.selectedRows;
        //this.purchaseDateVal= null;
        this.seePricingData= false;
        this.policyIds=[];
        for (let i = 0; i < selectedRows.length; i++){
            this.policyIds.push(selectedRows[i].Id);
        }
        

        if(this.purchaseDateVal!= null && this.purchaseDateVal!='' && this.allValid){
            this.showSpinner = true;
            getExtendedWarrantyPricing({policyList: this.policyIds, wrId: this.wr.Id}).then(result =>{
                    if(result && result.status){
                        let res = JSON.parse(result.data);
                        this.purchasedCoverageDetails = result.data;
                        this.extendedWRpricingDetails = res.exPricingList;
                        if(res.showLocalCurrency){
                            if(this.columns1.length == 5){
                                let col = { label: 'PRICE IN LOCAL CURRENCY',fieldName: 'finalPriceInLocalCurrency',type:'text' };
                                this.columns1.push(col);
                            }
                        } 
                        if(this.extendedWRpricingDetails.length > 0){
                            this.seePricingData = true;
                            if(result.errormessage != null && result.errormessage != ''){
                                this.warningMsg =   result.errormessage;
                            }
                        } else {
                            this.error= this.label.ATI_ETC_Pricing_Error;;
                            this.seePricingData = false;
                        }
                        
                    }else{
                        this.error= this.label.ATI_ETC_Pricing_Error;;
                        this.seePricingData = false;
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.error = error;
                    this.showSpinner = false;
                });
            }
        
    }

    handleSave(event) {
        const draftValues = event.detail.draftValues;
        console.log('draftValues==11===>',draftValues);
        let ewpDetails = this.extendedWRpricingDetails;
        
        let totalprice = 0;
        for (let i = 0; i < draftValues.length; i++){
            var index = draftValues[i].id1.split('-')[1];
            var result = ewpDetails[index];
            console.log('result------->',JSON.stringify(result));
            if(draftValues[i]['handlingFee'] === "") {
                draftValues[i]['handlingFee'] = 0;
            }
            if(draftValues[i]['lateFee'] === ""){
                draftValues[i]['lateFee'] = 0;
            }
            if(draftValues[i]['lateFee']) draftValues[i]['lateFee'] = parseInt(draftValues[i]['lateFee']);
            if(draftValues[i]['handlingFee']) draftValues[i]['handlingFee'] = parseInt(draftValues[i]['handlingFee']);
            if(Number.isInteger(draftValues[i]['lateFee']) && Number.isInteger(draftValues[i]['handlingFee'])){
                draftValues[i]['finalPrice'] = (result['basePrice'] + draftValues[i]['lateFee'])-draftValues[i]['handlingFee'];
            }
            else if(Number.isInteger(draftValues[i]['lateFee']) && Number.isInteger(result['handlingFee'])){
                draftValues[i]['finalPrice'] = (result['basePrice'] + draftValues[i]['lateFee'])-result['handlingFee'];
            }
            else if(Number.isInteger(draftValues[i]['handlingFee']) && Number.isInteger(result['lateFee'])){
                draftValues[i]['finalPrice'] = (result['basePrice'] +result['lateFee'])-draftValues[i]['handlingFee'];
            }
            totalprice = totalprice+draftValues[i]['finalPrice'];
            
            let updateItem = draftValues[i];
            for (let field in updateItem) {
                if(field != 'id1'){
                    ewpDetails[index][field] = draftValues[i][field];
                }
            }
        }
        console.log('total price-------->',totalprice);
        let purchaseDetails = JSON.parse(this.purchasedCoverageDetails);
        purchaseDetails['exPricingList'] = ewpDetails;
        purchaseDetails['totalPrice'] = totalprice;
        this.purchasedCoverageDetails = JSON.stringify(purchaseDetails);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Extended Warranty Pricing has been successfully updated.',
                variant: 'success'
            })
        );
        // Clear all draft values in the datatable
        this.draftValues = [];
    }

    
    handleClick(event){
        this.disableSaveButton = true;
        this.showSpinner = true;
        this.validateComponentFields(event);
        if(this.policyIds.length >1){
            this.dispatchEvent(
                new ShowToastEvent({
                    message: this.label.errorExtendedWR,
                    variant: 'error'
                })
            );
        }
        else if(this.extendedWRpricingDetails.length >0 && this.allValid){
            if ( this.extendedWRpricingDetails !== undefined && this.extendedWRpricingDetails.length > 0) {
                var wcInputString = {};
                var coverages = [];
                for (var i = 0; i < this.coverageDetails.length; i++) {
                    if(this.policyIds.indexOf(this.coverageDetails[i]["WOD_2__Policy_Definition__c"]) != -1){
                        var coverageObject = {
                            WOD_2__Policy_Definition__c : this.coverageDetails[i]["WOD_2__Policy_Definition__c"],
                            WOD_2__Warranty_Start_Date__c : this.coverageDetails[i]["WOD_2__Warranty_Start_Date__c"],
                            WOD_2__Warranty_End_Date__c : this.coverageDetails[i]["WOD_2__Warranty_End_Date__c"],
                            WOD_2__Warranty_Registration__c : this.coverageDetails[i]["WOD_2__Warranty_Registration__c"],
                            WOD_2__Policy_OffSeason__c : this.coverageDetails[i]["WOD_2__Policy_OffSeason__c"]
                        };
                        coverages.push(coverageObject);
                    }
                }
                wcInputString["coverages"] = coverages;
                wcInputString["warrantyCoverageBeforeSaveOverrideClassName"] = 'WR_WarrantyCoverageBeforeSaveOverride';
                wcInputString["wrRecordIds"] = [this.wr.Id];
                console.debug(wcInputString);
                registerExtWarrantyCoverages({
                    wcInputString : JSON.stringify(wcInputString),
                    wrId :this.wr.Id,
                    purchasedCoverageDetails : this.purchasedCoverageDetails
                }).then(result =>{
                    this.showSpinner = false;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Warranty Registration has been successfully created.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.wr.Id,
                            objectApiName: 'WOD_2__Warranty_Registration__c',
                            actionName: 'view'
                        }
                    });
                }).catch(error =>{
                    this.error = error;
                    this.showSpinner = false;
                    this.disableSaveButton = false;
                });
            } 
        }
    }
}