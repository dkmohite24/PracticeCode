import {LightningElement, track, api} from 'lwc';
import fetchLookUpConfiguration from '@salesforce/apex/WOD_2.BaseController.fetchLookUpConfiguration';
import queryDataForLookupComponent from '@salesforce/apex/WOD_2.BaseController.queryDataForLookupComponent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { lookUpLabelObj } from './aTILookUpWebComponentLabel.js';
import lang from '@salesforce/i18n/lang';

export default class ATILookUpWebComponent extends LightningElement {
    //Invoke the label from the Js File
    Label = lookUpLabelObj()
    //Check if Look up configuration metadata name is given. If metadata record exists, fetch details from metadata else use the user provided values
    //This is the list of record that are shown in the dropdown when a user enters a text.
    @api objectList = [];
    //The API name of the object from which you wish to query.
    @api objectName;
    //@Depricated:The component already filters the record based on the user entered text. But you can add more filters.
    @api queryFilters;
    //The number of records that will be queried. Set this as less as possible for better performance
    @api queryFiltersList;
    //The number of records that will be queried. Set this as less as possible for better performance
    @api limit = 10;
    //Flag to know that searching is in progress.
    @api searching = false;
    //Mention the API name of the fields which will be used to compare when the query runs
    @api comparisonField;
    //Component allows displaying of more than one field. Mention the API field name which will be displayed.
    @api primaryDisplayField;
    //Display the secondary set of fields. Keep it less than two.
    @api secondaryDisplayFields;
    //Value entered by the user, based on which the component initiates the search
    //@api enteredValue;
    //The minimum number of character after which the search should be performed. Keep it to more than 3
    @api minimumCharacter = 3;
    //Attribute used to flag the index of the selected record in the array of the search results
    @track selectedIndex;
    //Flag to initiate the search when the focus is on the field
    @api lookupInputFocused = false;
    //The record selected from the search results
    @api selectedObject;
    //The lightning icon name, that will be displayed in the dropdown. It will be in the form of utility:search
    @api iconName = 'utility:search';
    //Name to be displayed when the record is selected from the search results
    @api selectedObjectDisplayName;
    //placeholder for the user input field
    @api placeholder;
    //Set this to the id of the record that is looked up. Based on this the data will be loaded on further loading of the page.
    @track recordId;
    //This will be set to the value of the selected object.You can access this from your component
    @api value;
    //Set this to true if you want to make the field readonly
    @api readOnly = false;
    //Label of the field
    @api fieldLabel;
    //Set this to true if you want the field to be required.
    @api required;
    @api requiredErrorMessage;
    //Set this to true if you want the throw an error if not a selected value.
    @api validateId = false;
    //Please make sure that this is set to some unique string. This will be sent in the event params whenever a value is selected in the dropdown
    @api lookupComponentId;
    //Message of the error occured during the search
    @api queryErrorMessage;
    //This attribute is set when any error occurs during the search
    @api queryErrorFound = false;
    //Length of the results returned from the search
    @api searchedListLength;
    //if set to true the search will be fired upon focus
    @api allowSearchOnFocus = false;
    //Set this to true if the info text needs to be displayed next to the lookup field label. If set to true, infoText attribute should also be given
    @api showInfoText = false;
    //Helpful information that will displayed next to the lookup label
    @api infoText;
    //Bypassing setLookupId function after loading and selecting value from search list
    @api byPassSetLookupIdForSelecedValue = false;
    //Should send if you override query execution class with custom logic
    @api lookupQueryBuilderConfig;
    //Extra params to overridden class to use in custom logic, send JSON string in key value format
    @api extraParams;
    @api searchType;
    //Order By logic. ASC or DESC
    @api orderByLogic;
    //Order by field. The API name of the field which will be used to sort the values. 
    @api orderByField;

    @api hideInput = false;

    _programmaticFilter = '' // Query filter that is set programatically
    isConfigurationLoadingDone = false; //Attribute to ascertain whether the configuration retrieving is done.
    lang = lang.includes('en') ? '' : '_' + lang;

    //Use this flag to show the list above the control
    @api showListAbove = false;
    //@api data;
    @track responseFromlookUp;
    @track queryBuilderWrapper = {};
    @api queryWithoutShare;
    @track lookupSetCompareField = 'Id';
    @track _userEnteredValue = '';
    @api enteredValue = '';
    @api orderBy = '';
    @api
    isDisable = false;
    @api
    hideSearchIcon = false;
    @track
    timeOutId;
    @track
    currentSelectedIndex;
    @track
    optionSelected = false;
    @track
    configurationMetaDataName;
    @track
    metadataName;
    
    _title = 'Error';
    message = '';
    variant = 'error';
    @track
    uppercaseItemName;

    handleEnteredValueChange(changeEvent) {
        this.enteredValue = changeEvent.target.value;
        this.searchSalesforceRecords(changeEvent);
    }

   
    @api
    get lookupId() {
        return this.recordId;
    }

    set lookupId(value) {
        var ref = this;
        this.recordId = value;
        let lookupVal = this.recordId;
        var selectedObject;
        
        console.log('value',value);
        if(value != undefined && value != '') {
            this.optionSelected = true;
        }
        console.log('this.optionSelected',this.optionSelected);
        if (lookupVal === undefined || lookupVal === '' || lookupVal === null && this.objectName != null) {
            selectedObject = JSON.stringify(ref.selectedObject);
            ref.selectedObject = undefined;
            ref.selectedObjectDisplayName = '';
            ref.value = undefined;
            ref.lookupInputFocused = false;
            if (lookupVal === '' || lookupVal === undefined) {
                const selectedLookupRemoved = new CustomEvent('selectedlookupremoved', {
                    selectedObject: this.selectedObject,
                    lookupComponentId: this.lookupComponentId
                });
                // Fire the custom event
                this.dispatchEvent(selectedLookupRemoved);

            } else if ((lookupVal === null) && (this.objectList.length === 0)) {
                this.setLookupId();
            }
        }else if(this.objectName !== null && this.objectName !== undefined){
            this.setLookupId();
        }

    }
    //LookUpConfiguration Metadata name to get the metadata
    @api
    get lookUpConfigurationMetadataName() {
        return this.configurationMetaDataName;
    }
    set lookUpConfigurationMetadataName(value) {
        if (this.metadataName === value || this.metadataName === undefined || this.metadataName === '') {
            this.clearAttributes();
            this.metadataName = value;
            this.configurationMetaDataName = this.callLookUpConfiguration();
            this.getConfigurationMetadata();
        } else {
            this.handleLookUp();
            this.clearAttributes();
            this.objectList = [];
            this.searchedListLength = 0;
            this.metadataName = value;
            this.configurationMetaDataName = this.callLookUpConfiguration();
            this.getConfigurationMetadata();
        }
    }
    
    get listClasses(){
        let classesStr = "";
        if(this.metadataName == 'ATI_DiagnosticCodes_Lookup'){
            classesStr = "slds-listbox slds-listbox_vertical max-heightstyle";
        }else{
            classesStr = "slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid two-hundredheight-style";
        }
        return classesStr
        + (this.showListAbove?
        " show-list-above": "");
    }
    get placeholderValue() {
        if (this.placeholder === undefined || this.placeholder === '') {
            return 'Searching...';
        }
        return this.placeholder;

    }
    get showlookuprecdetail(){
        return (this.SecondaryDisplayFields && this.optionSelected && this.recordId && this.objectName);
    }
    get styleOfSelectedObject() {
        if ((this.selectedObjectDisplayName === undefined) || (this.selectedObjectDisplayName === '')) {
            return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_right';
        }
        return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_right displaynone-style'
    }

    get selectedIndexCheck() {
        if (this.selectedIndex === this.index) {
            return 'slds-listbox__item slds-has-focus highlightDark';
        }
        return 'slds-listbox__item slds-has-focus';
    }

    @api
    get valueEnteredByTheUser() {
        return this.enteredValue;
    }
    set valueEnteredByTheUser(value) {
        this.enteredValue = value;
    }

    selectCurrentResult(event) {
        event.currentTarget.childNodes[0].setAttribute('class', 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-has-focus');
    }
    unselectCurrentIndex(event) {
        event.currentTarget.childNodes[0].setAttribute('class', 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta');
    }
    get hideColorOnMouseLeave() {
        return 'background-color: #F5F5F5;';
    }
    get hideSearchIconCondition() {
        if (!this.hideSearchIcon) {
            return true;
        }
        return false;
    }

    get iconNameCondition() {
        if (this.iconName !== undefined && this.iconName !== '') {
            return 'slds-media__figure';
        }
        return 'slds-media__figure displaynone-style';
    }

    get seachLengthCondtion() {
        if (this.index !== this.searchedListLength - 1) {
            return 'hrStyle'
        }
        return '';

    }


    get requiredErrorMessageCheck() {
        if (this.selectedObject === undefined && this.lookupInputFocused === false && this.required === true) {
            return 'slds-form-element__help displayblock-style';
        }
        return 'slds-form-element__help displaynone-style';
    }



    get validateIdErrorMessageCheck() {
        if (this.selectedObject === undefined && this.lookupInputFocused === false && this.required === false && this.validateId === true && this.enteredValue !== undefined && this.enteredValue !== '' && this.enteredValue.length > 0) {
            return 'slds-form-element__help displayblock-style';
        }
        return 'slds-form-element__help displaynone-style'
    }

    get checkWhenSearchLengthEnteredZero() {
        if (this.searchedListLength === 0 && this.enteredValue !== undefined && this.enteredValue !== '' && this.enteredValue.length > 0 && this.lookupInputFocused) {
            return true;
        }
        return false;
    }
    get enteredValueCheck() {
        if ((this.enteredValue !== undefined && this.enteredValue !== '') && (this.enteredValue.length < this.minimumCharacter)) {
            return 'test';
        }
        return 'displaynone-style';
    }
    get searchingCheck() {
        if (!this.searching && !this.queryErrorFound) {
            return 'slds-media__body';
        }
        return 'slds-media__body displaynone-style';
    }

    get searchingCheckForSpinner() {
        if (!this.searching) {
            return 'slds-media__body displaynone-style';
        }
        return 'slds-media__body';
    }
    get queryErrorFoundCheck() {
        if (this.queryErrorFound) {
            return 'slds-media__body';
        }
        return 'slds-media__body displaynone-style';
    }
    
    @api
    get queryFilter(){
        return this._programmaticFilter
    }
    
    set queryFilter(value){//If configurtion retrieval is still in progress then do not set the query filter
        //Save it in _programmaticFilter attribute. 
        this._programmaticFilter = value;
        if(this.isConfigurationLoadingDone){
            let existingQueryFilter = this.queryFilters;
            if(existingQueryFilter != null && existingQueryFilter != '' && existingQueryFilter != undefined){
                existingQueryFilter+= ' '+value;
            } else {
                existingQueryFilter = value;
            }
            this.queryFilters = existingQueryFilter;
        }
    }

    get getSldsCondtionForError() {
        if ((this.selectedObject === undefined && this.lookupInputFocused === false && this.required === true) ||
            (this.selectedObject === undefined && this.lookupInputFocused === false && this.required === false && this.validateId === true && this.enteredValue !== undefined && this.enteredValue !== '' && this.enteredValue.length > 0)) {
            return 'slds-form-element__control slds-has-error';
        }
        return 'slds-form-element__control';
    }
    //Remove the selected option
    @api
    removeSelectedOption() {
        this.optionSelected = false;
        this.selectedObject = undefined;
        this.selectedObjectDisplayName = '';
        this.value = undefined;
        this.lookupInputFocused = false;
        this.recordId = '';
        const selectedLookupRemoved = new CustomEvent('selectedlookupremoved', {
            selectedObject: this.selectedObject,
            lookupComponentId: this.lookupComponentId
        });
        // Fire the custom event
        this.dispatchEvent(selectedLookupRemoved);
    }


    //Clear all the attributes
    clearAttributes() {
        this.objectName = '';
        this.comparisonField = ['Name'];
        this.minimumCharacter = 3;
        this.searchType = 'LIKE';
        this.requiredErrorMessage = '';
        this.secondaryDisplayFields = '';
        this.queryWithoutShare = false;
        this.lookupQueryBuilderConfig = '';
        this.required = false;
        this.queryFilters = '';
        this.iconName = 'utility:search';
        this.primaryDisplayField = ['Name'];
        this.isConfigurationLoadingDone = false;
    }



    onBlur() {
        var ref = this;
        ref.lookupInputFocused = false;
    }

    inputInFocus() { //if 'allowSearchOnFocus' attribute is set
        var ref = this;
        this.selfclick = true;
        ref.lookupInputFocused = true;
        if (ref.allowSearchOnFocus) {
            ref.searchSalesforceRecords();
        }
    }

    @api
    externalsearch(event, enteredVal){
        this.enteredValue = enteredVal;
        if(enteredVal){
            this.lookupInputFocused = true;
            this.searchSalesforceRecords(event);
        }
        else
            this.lookupInputFocused = false;                
    }

    async searchSalesforceRecords(event) {
        var ref = this;
        let entereTextToSearch = ref.enteredValue;
        let userEnteredValue = ref.enteredValue ? ref.enteredValue : '';
        userEnteredValue = userEnteredValue.trim(); //remove trailing spaces
        let sObjectType = ref.objectName;
        let fields = ref.fields;
        let conditions = ref.queryFilters;
        let limit = ref.limit;
        let comparisonField = ref.comparisonField;
        let primaryDisplayField = ref.primaryDisplayField;
        let minimumCharacter = ref.minimumCharacter;
        //let keyCode = event.keyCode; //Key Code is deprecated thats why introduce Key Name.
        let keyName = event?event.key:'';
        let objectList = ref.objectList;
        let selectedObjectIndex = ref.selectedIndex;
        let objectListTemp = [];
        let customSearchData = ref.customSearchData;

        try {
            //switch (keyCode) {
            switch (keyName) {
                //up key
                //case 38:
                case 'ArrowUp':
                    if (objectList.length > 0) {
                        let previousValue = ref.selectedIndex;
                        if (selectedObjectIndex !== undefined && selectedObjectIndex - 1 >= 0) {
                            selectedObjectIndex--;
                            ref.selectedIndex = selectedObjectIndex;
                        } else if ((selectedObjectIndex !== undefined && selectedObjectIndex - 1 < 0) || selectedObjectIndex === undefined) {
                            selectedObjectIndex = objectList.length - 1;
                            ref.selectedIndex = selectedObjectIndex;
                        }
                        if (previousValue != undefined)
                            this.template.querySelectorAll("ul > li")[previousValue].setAttribute('style', 'background-color:white;');
                        this.template.querySelectorAll("ul > li")[ref.selectedIndex].setAttribute('style', 'background-color:lightgray;');
                    }
                    break;
                //down key
                // case 40:
                case 'ArrowDown':
                    if (objectList.length > 0) {
                        let previousValue = ref.selectedIndex;
                        if (selectedObjectIndex !== undefined && selectedObjectIndex + 1 < objectList.length) {
                            selectedObjectIndex++;
                            ref.selectedIndex = selectedObjectIndex;
                        } else if ((selectedObjectIndex !== undefined && selectedObjectIndex + 1 === objectList.length) || selectedObjectIndex === undefined) {
                            selectedObjectIndex = 0;
                            ref.selectedIndex = selectedObjectIndex;
                        }
                        if (previousValue !== undefined)
                            this.template.querySelectorAll("ul > li")[previousValue].setAttribute('style', 'background-color:white;');
                        this.template.querySelectorAll("ul > li")[ref.selectedIndex].setAttribute('style', 'background-color:lightgray;');
                    }
                    break;
                //escape key
                // case 27:
                case 'Escape':
                    ref.enteredValue = '';
                    ref.objectList = [];
                    ref.searchedListLength = 0;
                    break;
                //enterKey
                //case 13:
                case 'Enter':
                    ref.onValueselect();
                    break;

                //Right Key:
                // case 39:
                case 'ArrowRight':
                    //don't to anything
                    break;
                //Left Key
                //case 37:
                case 'ArrowLeft':
                    //don't to anything
                    break;
                //CapsLock Key
                //case 20:
                case 'CapsLock':
                    //don't to anything
                    break;
                //End
                //case 35:
                case 'End':
                    //don't to anything
                    break;
                //home
                //case 36:
                case 'Home':
                    //don't to anything
                    break;
                //any other character entered.
                default:
                    ref.selectedObject = undefined;
                    ref.selectedObjectDisplayName = '';
                    ref.queryErrorMessage = '';
                    ref.queryErrorFound = false;
                    try {
                        if (userEnteredValue.length >= minimumCharacter && fields != null && fields!== undefined) {
                            ref.searching = true;
                            ref.searchedListLength = 0;
                            //--Hide 'More' button
                            ref.queryBuilderWrapper.fieldsToQuery = fields;
                            ref.queryBuilderWrapper.fromObject = sObjectType;
                            ref.queryBuilderWrapper.userEnteredValue = userEnteredValue;
                            ref.queryBuilderWrapper.recordLimit = parseInt(limit, 10);                           
                            ref.queryBuilderWrapper.orderBy = ref.orderBy !== '' ? ref.orderBy : '';
                            ref.queryBuilderWrapper.extraParams = ref.extraParams;
                            ref.queryBuilderWrapper.conditions = ref.queryFiltersList !== undefined ? JSON.stringify(ref.queryFiltersList) : '[]';
                            ref.queryBuilderWrapper.searchType = ref.searchType;
                            ref.queryBuilderWrapper.comparisonFields = comparisonField;
                            //ref.queryBuilderWrapper.whereClause = ''
                            ref.queryBuilderWrapper.lookUpConfigurationName = ref.metadataName;
                            ref.queryBuilderWrapper.orderByLogic = ref.orderByLogic; 
                            ref.queryBuilderWrapper.orderByField =ref.orderByField;
                            //--Call server to query records
                            let lookUpdata = await ref.callQueryDataLookUpComponent()
                            let queryResult;
                            if (lookUpdata.status === true && entereTextToSearch === ref.enteredValue) {
                                queryResult = JSON.parse(lookUpdata.data);
                                console.log(queryResult);                               
                                if (queryResult !== undefined && queryResult.length > 0) {                                   
                                    if (queryResult.length > limit) {
                                        queryResult.splice(-1); //--Since we queried limit+1 records
                                    }
                                    let newObjectList = [];
                                    for (let i = 0; i < queryResult.length; i++) {
                                        let eachObject = queryResult[i];
                                        eachObject['isLastIndex'] = (i === queryResult.length - 1) ? true : false;
                                        newObjectList.push(eachObject);
                                    }
                                    ref.objectList = JSON.parse(JSON.stringify(newObjectList));
                                    //ref.objectList = queryResult;
                                    ref.searchedListLength = queryResult.length;
                                    ref.selectedIndex = undefined;
                                    ref.searching = false;
                                    ref.lookupInputFocused = true;
                                } else if (queryResult.status !== undefined && !queryResult.status) {
                                    return Promise.reject({
                                        error: queryResult,
                                        stage: 2
                                    });
                                }
                                else if (entereTextToSearch === ref.enteredValue) {
                                    ref.objectList = [];
                                    ref.searchedListLength = 0;
                                    ref.selectedIndex = undefined;
                                    ref.searching = false;
                                }
                            }


                        } else {
                            ref.objectList = [];
                            ref.searchedListLength = 0;
                            ref.selectedIndex = undefined;
                            ref.searching = false;
                        }

                    } catch (error) {                       
                        const evt = new ShowToastEvent({
                            title: this._title,
                            message: error.message,
                            variant: this.variant
                        });
                        this.dispatchEvent(evt);
                    }
            }
        } catch (error) {           
            const evt = new ShowToastEvent({
                title: this._title,
                message: error.message,
                variant: this.variant
            });
            this.dispatchEvent(evt);
        }

    }

    get fieldlabelNullCheck() {
        var ref = this;
        if (ref.fieldLabel !== '' && ref.fieldLabel !== undefined) {
            return true;
        }
        return false;
    }

    get requiredCondition() {
        var ref = this;
        return ref.required ? true : false;
    }
    get sldsCondtionForError() {
        var ref = this;
        if ((ref.selectedObject === undefined && ref.lookupInputFocused === false && ref.required === true) || ((ref.selectedObject === undefined) && (ref.lookupInputFocused === false) && (ref.required === false) && (ref.validateId === true) && (ref.enteredValue === undefined) && (ref.enteredValue !== '') && (ref.enteredValue >= 0))) {
            return 'slds-form-element__control slds-has-error';
        }
        return 'slds-form-element__control';
    }
    get sldsConditionFordisplayName() {
        var ref = this;
        if ((ref.selectedObjectDisplayName === undefined) || (ref.selectedObjectDisplayName === '')) {
            return '';
        }
        return 'display:none;';
    }

    get hideSearchIconConditionStyle() {
        var ref = this;
        if (ref.hideSearchIcon) {
            return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_right';
        }
        return 'slds-combobox__form-element slds-input-has-icon slds-input-has-icon_left-right';

    }
    get selectedObjectDisplayNameCondition() {
        var ref = this;
        if (ref.selectedObjectDisplayName !== undefined && ref.selectedObjectDisplayName !== '') {
            return 'padding:2px;';
        }
        return 'display:none;';

    }
    get checkSearchListlength() {
        if (this.searchedListLength > 0 && this.lookupInputFocused) {
            return true;
        }
        return false;
    }
    async callLookUpConfiguration() {
        let ref = this;
        let result = await fetchLookUpConfiguration({
            lookUpConfigurationName: ref.metadataName
        }).catch(function (error) {
            const evt = new ShowToastEvent({
                title: this._title,
                message: error.message,
                variant: this.variant
            });
            this.dispatchEvent(evt);
        });
        return result;
    }
    handleLookUp() {
        this.enteredValue = '';
    }

    async callQueryDataLookUpComponent() {
        var result = await queryDataForLookupComponent({
            queryBuilderWrapperObject: this.queryBuilderWrapper,
            classOverrideSetting: this.lookupQueryBuilderConfig,
            queryWithoutShare: this.queryWithoutShare
        }).catch(function (error) {           
            const evt = new ShowToastEvent({
                title: this._title,
                message: error.message,
                variant: this.variant
            });
            this.dispatchEvent(evt);
        });      
        return result;
    }

    onValueselect() {
        var reference = this;

        var primaryDisplayField = reference.primaryDisplayField;
        var objectList = reference.objectList;
        var selectedObjectIndex = reference.selectedIndex;
        var fieldSplit;
        var fieldValue;
        reference.byPassSetLookupIdForSelecedValue = true;
        if (selectedObjectIndex !== undefined) {
            reference.selectedObject = objectList[selectedObjectIndex];
            reference.recordId = objectList[selectedObjectIndex].Id;
            reference.value = objectList[selectedObjectIndex];
            reference.objectList = [];
            reference.searchedListLength = 0;
            reference.enteredValue = '';
            reference.lookupInputFocused = false;
            if (primaryDisplayField.indexOf('.') !== -1) {
                fieldSplit = primaryDisplayField.split('.');
                fieldValue = objectList[selectedObjectIndex];
                for (let j = 0; j < fieldSplit.length; j++) {
                    if (fieldValue[fieldSplit[j]] !== undefined) {
                        fieldValue = fieldValue[fieldSplit[j]]
                    } else {
                        fieldValue = undefined;
                        break;
                    }
                }
                if (fieldValue)
                    reference.selectedObjectDisplayName = fieldValue;

                else
                    reference.selectedObjectDisplayName = '';
            } else {
                reference.selectedObjectDisplayName = objectList[selectedObjectIndex][primaryDisplayField];
            }
            this.optionSelected = true;
            const lookupselected = new CustomEvent('lookupselected', {
                detail: {
                    selectedObject: reference.selectedObject,
                    lookupComponentId: reference.lookupComponentId
                },bubbles: true, composed: true
            });
            // Fire the custom event
            this.dispatchEvent(lookupselected);
        }
    }

    async setLookupId() {
        var reference = this;
        var recordId = reference.recordId;
        var sObjectType = reference.objectName;
        var fields = reference.fields;
        var conditions = reference.queryFilters;
        var queryResult;
        var dataFromLookUpQuery;
        try {
            reference.isOneMoreKeyEntered = true;
            reference.queryErrorMessage = '';
            reference.queryErrorFound = false;

            if (recordId !== undefined && recordId !== '' && recordId !== null && fields != null && fields !== undefined) {
                reference.queryBuilderWrapper.fieldsToQuery = fields;
                reference.queryBuilderWrapper.comparisonFields = [];
                reference.queryBuilderWrapper.fromObject = sObjectType;
                //reference.queryBuilderWrapper.whereClause = " " + reference.lookupSetCompareField + "='" + recordId + "' ";
                reference.queryBuilderWrapper.recordLimit = parseInt('1', 10);
                let conditionList =  [{
                    "fieldName" : reference.lookupSetCompareField,
                    "value" : recordId,
                    "operator" : "eq",
                    "valueType" : "string",
                    "searchType" : "EXACT"
                  }];
                reference.queryBuilderWrapper.conditions = JSON.stringify(conditionList);
                //reference.queryBuilderWrapper.orderBy = reference.orderBy !== '' ? reference.orderBy : '';
                reference.queryBuilderWrapper.extraParams = reference.extraParams;
                reference.queryBuilderWrapper.lookUpConfigurationName = reference.metadataName;
                reference.queryBuilderWrapper.orderByLogic = reference.orderByLogic; 
                reference.queryBuilderWrapper.orderByField =reference.orderByField;
                if (conditions !== undefined && conditions !== '') {
                    //reference.queryBuilderWrapper.whereClause = reference.queryBuilderWrapper.whereClause + conditions;
                }
                //once Query Is read call the funtion for fetching the records. 
                dataFromLookUpQuery = await this.callQueryDataLookUpComponent();

                if (dataFromLookUpQuery.status) {
                    queryResult = JSON.parse(dataFromLookUpQuery.data);

                    if (queryResult !== undefined && queryResult.length > 0) {
                        let objectList = [];
                        for (let i = 0; i < queryResult.length; i++) {
                            let eachObject = queryResult[i];
                            eachObject['isLastIndex'] = (i === queryResult.length - 1) ? true : false;
                            objectList.push(eachObject);
                        }
                        reference.objectList = JSON.parse(JSON.stringify(objectList));
                        reference.searchedListLength = queryResult.length;
                        reference.selectedIndex = 0;
                        reference.searching = false;
                        //reference.objectList = [];
                        reference.onValueselect();
                    } else {
                        reference.queryErrorMessage = queryResult.error;
                        reference.queryErrorFound = true;
                        reference.objectList = [];
                        reference.searchedListLength = 0;
                        reference.selectedIndex = undefined;
                        reference.searching = false;
                    }
                } else {
                    throw new Error(reference.queryOfLookUpComponent);
                }
            }
        } catch (error) {
            const evt = new ShowToastEvent({
                title: this._title,
                message: error.message,
                variant: this.variant
            });
            this.dispatchEvent(evt);
        }
    }


    // Expose the labels to use in the template.
    async getConfigurationMetadata() {
        //Check for the lookUpConfigurationMetadataName and fetch the metadata.
        this.lookupInputFocused = true;
        let nameSpace = 'WOD_2__';
        let configObject = {};
        let ref = this;
        let dataFromLookUp;
        //This shall fetch the LookUpMetadataName and build the query for fetching the necessary records. 
        try {
            if (ref.configurationMetaDataName !== '' && ref.configurationMetaDataName !== undefined && ref.configurationMetaDataName !== null) {
                dataFromLookUp = await this.callLookUpConfiguration();
                if (dataFromLookUp.status) {
                    let responseMap = JSON.parse(dataFromLookUp.data);
                    let translationSettingMap = responseMap.hasOwnProperty('translationSetting') ? JSON.parse(responseMap.translationSetting) : null;
                    configObject = responseMap.hasOwnProperty('lookupConfig') ? JSON.parse(responseMap.lookupConfig) : null;
                    //configObject = JSON.parse(dataFromLookUp.data); //Set the properties retrieved from configuration
                    if (configObject.hasOwnProperty(nameSpace + 'Object_Name__c') && (configObject[nameSpace + 'Object_Name__c'] !== null || configObject[nameSpace + 'Object_Name__c'] !== undefined || configObject[nameSpace + 'Object_Name__c'] !== '')) {
                        ref.objectName = configObject[nameSpace + 'Object_Name__c'];
                        if (configObject.hasOwnProperty(nameSpace + 'Comparison_Fields__c') && configObject[nameSpace + 'Comparison_Fields__c'] != null) {
                            ref.comparisonField = configObject[nameSpace + 'Comparison_Fields__c'].split(',');
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Fields__c') && configObject[nameSpace + 'Fields__c'] !== null) {
                            ref.fields = configObject[nameSpace + 'Fields__c'].split(',');
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Limit__c') && configObject[nameSpace + 'Limit__c'] !== null) {
                            ref.limit = configObject[nameSpace + 'Limit__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Minimum_Character__c') && configObject[nameSpace + 'Minimum_Character__c'] !== null) {
                            ref.minimumCharacter = configObject[nameSpace + 'Minimum_Character__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Primary_Display_Fields__c') && configObject[nameSpace + 'Primary_Display_Fields__c'] !== null) {
                            ref.primaryDisplayField = configObject[nameSpace + 'Primary_Display_Fields__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Search_Type__c') && configObject[nameSpace + 'Search_Type__c'] !== null) {
                            ref.searchType = configObject[nameSpace + 'Search_Type__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'requiredErrorMessage__c') && configObject[nameSpace + 'requiredErrorMessage__c'] !== null) {
                            //ref.requiredErrorMessage = configObject[nameSpace + 'requiredErrorMessage__c'];
                            ref.requiredErrorMessage = !!translationSettingMap && translationSettingMap.hasOwnProperty(this.metadataName) && translationSettingMap[this.metadataName].hasOwnProperty(nameSpace + 'requiredErrorMessage__c') && !!translationSettingMap[this.metadataName][nameSpace + 'requiredErrorMessage__c'].hasOwnProperty([nameSpace + 'Value'+ this.lang +'__c']) ? translationSettingMap[this.metadataName][nameSpace + 'requiredErrorMessage__c'][nameSpace + 'Value'+ this.lang +'__c'] :
                                                            !!translationSettingMap && translationSettingMap.hasOwnProperty(this.metadataName) && translationSettingMap[this.metadataName].hasOwnProperty(nameSpace + 'requiredErrorMessage__c') && !!translationSettingMap[this.metadataName][nameSpace + 'requiredErrorMessage__c'].hasOwnProperty([nameSpace + 'Value__c']) ? translationSettingMap[this.metadataName][nameSpace + 'requiredErrorMessage__c'][nameSpace + 'Value__c'] : this.Label.TranslationErrorMsg;
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Secondary_Display_Fields__c') && configObject[nameSpace + 'Secondary_Display_Fields__c'] !== null) {
                            ref.SecondaryDisplayFields = configObject[nameSpace + 'Secondary_Display_Fields__c'].split(',');
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Query_Without_Share__c') && configObject[nameSpace + 'Query_Without_Share__c'] !== null) {
                            ref.queryWithoutShare = configObject[nameSpace + 'Query_Without_Share__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'LookUpInterfaceOverrideClassName__c') && configObject[nameSpace + 'LookUpInterfaceOverrideClassName__c'] !== null) {
                            ref.lookupQueryBuilderConfig = configObject[nameSpace + 'LookUpInterfaceOverrideClassName__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Required__c') && configObject[nameSpace + 'Required__c'] != null) {
                            ref.required = configObject[nameSpace + 'Required__c'];
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Query_Filter_JSON_Array__c') && configObject[nameSpace + 'Query_Filter_JSON_Array__c'] !== null) {
                            ref.queryFiltersList = JSON.parse(configObject[nameSpace + 'Query_Filter_JSON_Array__c']) ;//Concatenate programmatic filter                           
                        } else {
                            //ref.queryFilters = this._programmaticFilter;
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'SearchIcon__c') && configObject[nameSpace + 'SearchIcon__c'] !== null) {
                            ref.iconName = configObject[nameSpace + 'SearchIcon__c'];  
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Order_By_Field__c') && configObject[nameSpace + 'Order_By_Field__c'] !== null) {
                            ref.orderByField = configObject[nameSpace + 'Order_By_Field__c'];  
                        }
                        if (configObject.hasOwnProperty(nameSpace + 'Order_By_Logic__c') && configObject[nameSpace + 'Order_By_Logic__c'] !== null) {
                            ref.orderByLogic = configObject[nameSpace + 'Order_By_Logic__c'];  
                        }
                        // Set Look Up Id
                        ref.setLookupId();  

                    } else {
                        if (ref.objectName === null || ref.objectName === undefined || ref.objectName === '') { //Check if object api name is given, if not throw error
                            throw new Error(ref.LabelLookUpNoObjectLabel);
                        }
                        if (ref.required === true && ref.requiredErrorMessage === null || ref.requiredErrorMessage === undefined || ref.requiredErrorMessage === '') {
                            throw new Error(ref.Label.requiredErrorMessage); //Check if requiredError message is set when the field is required
                        }
                        if (ref.limit !== null && ref.limit > 10000) { //Check if limit is above 10000
                            throw new Error(ref.Label.LimitError);
                        }
                        ref.setLookupId();
                    }
                } else {
                    throw new Error(ref.Label.LookUpNoObjectLabel);
                }
            }
        } catch (error) {
            let message;
            if (error.hasOwnProperty('message')) {
                message = error.message;
            } else {
                message = error.errormessage;
            }
            const evt = new ShowToastEvent({
                title: this._title,
                message: message,
                variant: this.variant
            });
            this.dispatchEvent(evt);
        } finally{
            this.isConfigurationLoadingDone = true;
        }

    }
    listenerfunc;
    selfclick = false;
    connectedCallback() {
        this.getConfigurationMetadata();
        this.listenerfunc = (event) => {
            if (this.selfclick) {
                this.selfclick = false;
                return;
            }
            if (this.lookupInputFocused)
                this.lookupInputFocused = false;
        }
        window.addEventListener('click', this.listenerfunc);
    }
    disconnectedCallback() {
        window.removeEventListener('click', this.listenerfunc);
    }
    get comboHeaderStyle() {
        let style = 'slds-combobox_container';
        if (this.optionSelected) {
            style += ' slds-has-selection';
        }
        return style;
    }

    get innerComboHeaderStyle() {
        let style = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        if (this.optionSelected) {
            style = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        }
        return style;
    }



    onRowSelectHandler(event) {
        this.selfclick = true;
        this.optionSelected = true;
        let ref = this;
        ref.selectedIndex = event.currentTarget.dataset.index;
        let primaryDisplayField = ref.primaryDisplayField;
        let objectList = ref.objectList;
        ref.selectedIndex = event.currentTarget.dataset.index;
        let selectedObjectIndex = ref.selectedIndex;
        ref.byPassSetLookupIdForSelecedValue = true;
        if (selectedObjectIndex !== undefined) {
            ref.selectedObject = objectList[selectedObjectIndex];
            ref.value = objectList[selectedObjectIndex];
            ref.recordId = objectList[selectedObjectIndex].Id;
            ref.objectList = [];
            ref.searchedListLength = 0;
            ref.enteredValue = '';
            ref.lookupInputFocused = false;
            if (primaryDisplayField.indexOf('.') !== -1) {
                let fieldSplit = primaryDisplayField.split('.');
                let fieldValue = objectList[selectedObjectIndex];
                for (let j = 0; j < fieldSplit.length; j++) {
                    if (fieldValue[fieldSplit[j]] !== undefined) {
                        fieldValue = fieldValue[fieldSplit[j]]
                    } else {
                        fieldValue = undefined;
                        break;
                    }
                }
                if (fieldValue) {
                    ref.selectedObjectDisplayName = fieldValue;
                } else {
                    ref.selectedObjectDisplayName = '';
                }
            } else {
                ref.selectedObjectDisplayName = objectList[selectedObjectIndex][primaryDisplayField];
            }

            const lookupselectedEvent = new CustomEvent('lookupselected', {
                detail: {
                    selectedObject: ref.selectedObject,
                    lookupComponentId: ref.lookupComponentId
                },bubbles: true, composed: true
            });
            // Fire the custom event
            this.dispatchEvent(lookupselectedEvent);
        }
    }
}