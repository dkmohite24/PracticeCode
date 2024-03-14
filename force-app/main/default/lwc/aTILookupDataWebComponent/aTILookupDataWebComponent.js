import {
    LightningElement,
    api

} from 'lwc';

export default class ATILookupDataWebComponent extends LightningElement {
    @api object;
    @api fieldName;
    @api alternateFieldList;
    @api alternateFieldValueList = [];
    @api recordDisplayName;
    @api index;
    @api objectList;


    get alternativeFieldSetCondition() {
        if (this.alternateFieldValueList !== undefined && this.alternateFieldValueList.length > 0) {
            return true;
        }
        return false;
    }
    get indexValue() {
        if (this.index !== 0) {
            return this.index;
        }
        return 0;
    }
    connectedCallback() {
        var displayObject = this.object;
        var fieldName = this.fieldName;
        var secondaryFieldList = this.alternateFieldList;
        var alternateFieldValueList = [];
        var displayName = this.getFieldValue(fieldName, displayObject);
        this.recordDisplayName = displayName;


        if (secondaryFieldList !== undefined && secondaryFieldList !== null && secondaryFieldList.length > 0) {
            for (let i = 0; i < secondaryFieldList.length; i++) {
                let secondaryDisplayName = this.getFieldValue(secondaryFieldList[i], displayObject);
                alternateFieldValueList.push(secondaryDisplayName);
            }
        }
        this.alternateFieldValueList = alternateFieldValueList;
    }

    getFieldValue(fieldName, displayObject) {

        if (fieldName.indexOf('.') !== -1) {
            let fieldSplit = fieldName.split('.');
            let fieldValue = displayObject;
            for (let j = 0; j < fieldSplit.length; j++) {
                if (fieldValue[fieldSplit[j]] !== undefined) {
                    fieldValue = fieldValue[fieldSplit[j]]
                } else {
                    fieldValue = undefined;
                    break;
                }
            }
            if (fieldValue) {
                return fieldValue;
            }
            return '';

        }
        return displayObject[fieldName];

    }
    get displayName() {
        //let displayName = this.recordDisplayName;
        return `${this.recordDisplayName}`;
    }
    get secondaryFields() {
        //let secondaryFileds = this.secondaryFieldValues;
        return `${this.alternateFieldValueList}`;
    }
    handleSelect() {
        this.dispatchEvent(
            new CustomEvent('objectlistitemselected'), {
                detail: this.object.Id
            }
        )
    }
    get displayHorizontalLine() {
        let displayLine = this.index !== this.objectList.length - 1 ? true : false;
        return displayLine;
    }

}