import { LightningElement, track, api, wire } from 'lwc';
import WarrantyCoverageCheck from '@salesforce/apex/ATI_WarrantyCoverageCheck.WarrantyCoverageCheck';
import EWP_OBJECT from '@salesforce/schema/WOD_2__Inventory__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ATI_PolicySearchHeader from '@salesforce/label/c.ATI_PolicySearchHeader';
import getFieldSetDetails from '@salesforce/apex/ATI_Utils.getFieldsetDetailsByConfigSettingHaveReadAccess';
import ATI_PolicySearchSNPlaceholder from '@salesforce/label/c.ATI_PolicySearchSNPlaceholder';
import ATI_PolicySearchRODPlaceholder from '@salesforce/label/c.ATI_PolicySearchRODPlaceholder';
import ATI_PolicySearchUUPlaceholder from '@salesforce/label/c.ATI_PolicySearchUUPlaceholder';
import ATI_PolicySearchMIHeader from '@salesforce/label/c.ATI_PolicySearchMIHeader';
import ATI_PolicySearchWIHeader from '@salesforce/label/c.ATI_PolicySearchWIHeader';
import ATI_PolicySearchCIHeader from '@salesforce/label/c.ATI_PolicySearchCIHeader';
import ATI_PolicySearchMandatoryError from '@salesforce/label/c.ATI_PolicySearchMandatoryError';
import ATI_WPCheckFS from '@salesforce/label/c.ATI_WPCheckFS';
import LOCALE from '@salesforce/i18n/locale';
import ATI_PolicyUnitUsageError from '@salesforce/label/c.ATI_PolicyUnitUsageError';
//import ATI_PolicySearchCIHeader from '@salesforce/label/c.ATI_PolicySearchCIHeader';


//const invDataColumns = [];

const coverageColumns = [
    { label: 'Coverage Code', fieldName: 'policyName'},
    { label: 'Coverage Type', fieldName: 'policyType'},
    { label: 'Description', fieldName: 'description'},
    { label: 'Active on RO date', fieldName: 'activeOnCurrantDate', type: 'boolean' },
    { label: 'Warranty Start Date', fieldName: 'warrantyStartDate'},
    { label: 'Warranty End Date', fieldName: 'warrantyEndDate'},
    { label: 'Max Unit Usage', fieldName: 'maxUnitUsage'}
];

const campaignColumns = [
    { label: 'Campaign Name', fieldName: 'cmpName' },
    { label: 'Active on current date', fieldName: 'isActive', type: 'boolean' },
    { label: 'Campaign Start Date', fieldName: 'cmpStartDate'},
    { label: 'Campaign End Date', fieldName: 'cmpEndDate'}
];
export default class Ati_CoverageCheck extends LightningElement {
    @api showInvTable =false;
    @api showCoverageTable =false;
    @api showCmpTable =false;
    @track showLoadingSpinner = false;
    @api invData;
    @api cvrgData;
    @api cmpData;
    @track invDataColumns ;
    coverageColumns = coverageColumns;
    campaignColumns = campaignColumns;
    //invDataColumns = invDataColumns;
    label = {
        ATI_PolicySearchHeader,
        ATI_PolicySearchSNPlaceholder,
        ATI_PolicySearchRODPlaceholder,
        ATI_PolicySearchUUPlaceholder,
        ATI_PolicySearchMIHeader,
        ATI_PolicySearchWIHeader,
        ATI_PolicySearchCIHeader,
        ATI_PolicySearchMandatoryError,
        ATI_WPCheckFS,
        ATI_PolicyUnitUsageError
        };
    getFieldValue(path, obj) {
            return path.split('.').reduce(function (prev, curr) {
              return prev ? prev[curr] : null
            }, obj || self)
    };
    
    searchPolicy(event) {
        console.log('searchPolicy Called')
        this.showCmpTable = false;
        this.showInvTable = false;
        this.showCoverageTable = false;
        this.invData = [];

        //this.outputText = this.template.querySelector('lightning-input').value;
        var inp=this.template.querySelectorAll("lightning-input");
        var sn ='';
        var rod =null;
        var uu = null;
        inp.forEach(function(element){
            if(element.name=="serialNumber"){
                sn=element.value;
            }
               
            else if(element.name=="roDate"){
                rod=element.value;
            }
              

            else if(element.name=="unitUsage"){
                uu=element.value;
            }
                 console.log('sn : '+sn)
                  console.log('rod : '+rod)
                console.log('uu : '+uu)

        },this);

        if(rod == '' || uu == ''){
            const evt = new ShowToastEvent({
                title: this._title,
                message: this.label.ATI_PolicySearchMandatoryError,
                variant: 'error'
            });

            this.dispatchEvent(evt);
        }else if(uu<1){
            const evt = new ShowToastEvent({
                title: this._title,
                message: this.label.ATI_PolicyUnitUsageError,//this.label.ATI_PolicySearchMandatoryError,
                variant: 'error'
            });

            this.dispatchEvent(evt);

        }
        
        else{
        //var sn = this.template.querySelector('lightning-input').value;
        this.showLoadingSpinner = true;
        console.log(' showLoadingSpinner');

        console.log('label.ATI_WPCheckFS : '+this.label.ATI_WPCheckFS);
        console.log('EWP_OBJECT.objectApiName '+EWP_OBJECT.objectApiName);


        var FieldNameMap = new Map();
        getFieldSetDetails({objectName : EWP_OBJECT.objectApiName, metadataRecordAPIName : this.label.ATI_WPCheckFS})
        .then(response => {
            console.log(' >> response >> : '+JSON.stringify(response))
        if(response.status){
        let objData = JSON.parse(response.data);
        console.log('objData : '+JSON.stringify(objData))
        let fields = [];
        let columns = [];
        let label = this.Label;
        
       /* objData.forEach(function(data){
            var obj = new Object();
            if(data.fieldpath.includes('.')){
                
                var field1 = data.fieldpath.split('.',2)[0]+data.fieldpath.split('.',2)[1];
                FieldNameMap.set(data.fieldpath,field1);

            obj["fieldName"] = field1;//data.fieldpath;
            }
            obj["label"]     = data.label;
            obj["type"] = data.type;
						columns.push(obj);
        });*/


        for(let data of objData){
            var obj = new Object();
            if(data.fieldpath.includes('.')){
                
                var field1 = data.fieldpath.split('.',2)[0]+data.fieldpath.split('.',2)[1];
                FieldNameMap.set(data.fieldpath,field1);
                 obj["fieldName"] = field1;//data.fieldpath;
            }else{
                obj["fieldName"] = data.fieldpath;
            }
            if(data.label == 'Product Name'){
                obj["label"]     = 'Standard Model';		
            }else if(data.label == 'Warranty Code Name'){
                obj["label"]     =  'Vocation Code';		
            } else {
                obj["label"]     = data.label;		
            }
			obj["type"] = data.type;
            columns.push(obj);
        }


				this.invDataColumns = columns;
				console.log('invDataColumns>>>>> '+JSON.stringify(this.invDataColumns));
        }
    }) 

        
        WarrantyCoverageCheck({invSN : sn, rodate :rod , unitUsage :uu })
        .then(result => {
            console.log('result>>>> '+JSON.stringify(result));
            //console.log('em>>>> '+result.errormessage);
           
            if(result.status){
                //console.log('result 2>>>> '+JSON.stringify(result));
                var data = JSON.parse(result.data);
                
                //Modified By Anjali to change Date format(mm/dd/yyyy) for Warranty information	
                var i;
                if(data.cvrgData !=null && data.cvrgData.length>0){
                for (i = 0; i < data.cvrgData.length; i++) {	
                    var wntyStartdate = new Date(data.cvrgData[i].warrantyStartDate);	
                    var wntyEnddate = new Date(data.cvrgData[i].warrantyEndDate);	
                    if(data.cvrgData[i].warrantyStartDate != null)	
                    data.cvrgData[i].warrantyStartDate = wntyStartdate.getMonth() + 1 + '/' + wntyStartdate.getDate() + '/' + wntyStartdate.getFullYear();	
                    if(data.cvrgData[i].warrantyEndDate != null)	
                    data.cvrgData[i].warrantyEndDate = wntyEnddate.getMonth() + 1  + '/' + wntyEnddate.getDate() + '/' + wntyEnddate.getFullYear();	
                }}	
                //End of Modification
                
                this.cvrgData = data.cvrgData;
                //console.log('cvrgData >>> '+JSON.stringify(data.cmpData));
                
                //Modified By Anjali to change Date format(mm/dd/yyyy) for Campaign information	
                if(data.cmpData !=null && data.cmpData.length>0){
                for (i = 0; i < data.cmpData.length; i++) {	
                    var cmpgnStartdate = new Date(data.cmpData[i].cmpStartDate);	
                    var cmpgEnddate = new Date(data.cmpData[i].cmpEndDate);	
                    if(data.cmpData[i].cmpStartDate != null)	
                    data.cmpData[i].cmpStartDate = cmpgnStartdate.getMonth() + 1 + '/' + cmpgnStartdate.getDate() + '/' + cmpgnStartdate.getFullYear();	
                    if(data.cmpData[i].cmpEndDate != null)	
                    data.cmpData[i].cmpEndDate = cmpgEnddate.getMonth() + 1  + '/' + cmpgEnddate.getDate() + '/' + cmpgEnddate.getFullYear();	
                }}
                //End of Modification
                
                this.cmpData = data.cmpData;
                
                let campaignDinvDataList = [];
                //console.log('data.inv >>> '+JSON.stringify(data.inv));
                


               /* this.invDataColumns.forEach(function(invColumn){
                    var value = this.getFieldValue(invColumn, data.inv);
                    
                    campaignDinvDataList.push(value);

                    //console.log(invColumn.fieldName);
                    if(invColumn.fieldName.includes('.')){
                        var objName = invColumn.fieldName.split('.',2)[0];
                        console.log('>>>objName : '+objName);
                        var fieldName = invColumn.fieldName.split('.',2)[1];
                        console.log('>>>fieldName : '+fieldName);
                        
                        
                        
                        //WOD_2__Item__r
                    } 
                });*/


                campaignDinvDataList.push(data.inv); 
                //console.log('>>>campaignDinvDataList : '+campaignDinvDataList);
                //console.log('>>>FieldNameMap After '+JSON.stringify(FieldNameMap));
                for(let inv of campaignDinvDataList ){
                    for(let key of FieldNameMap.keys()){
                        //console.log('>>>key '+JSON.stringify(key));
                        //console.log('>>>[FieldNameMap.get(key)] '+JSON.stringify(FieldNameMap.get(key)));
                        //console.log('>>>inv[key] '+JSON.stringify(inv));
                        
                         inv[FieldNameMap.get(key)] = inv[key.split('.')[0]][key.split('.')[1]];
                    }

                }
                //console.log('>>>campaignDinvDataList After: '+JSON.stringify(campaignDinvDataList));

                //Modified By Anjali to change Date format(mm/dd/yyyy) for Machine information	
                if(campaignDinvDataList !=null && campaignDinvDataList.length>0){
                for (i = 0; i < campaignDinvDataList.length; i++) {	
                    //var inServiceDate = new Date(campaignDinvDataList[i].WOD_2__Install_Date__c);	
                    var dateArry;
                    if(campaignDinvDataList[i].WOD_2__Install_Date__c != null){
						dateArry = campaignDinvDataList[i].WOD_2__Install_Date__c.split('-');
						campaignDinvDataList[i].WOD_2__Install_Date__c=dateArry[1]  + '/' + dateArry[2] + '/' + dateArry[0];	
						//campaignDinvDataList[i].WOD_2__Install_Date__c=inServiceDate.getMonth() + 1 + '/' + inServiceDate.getDate() + '/' + inServiceDate.getFullYear();
                    }
                }}
                //End of Modification	

                this.invData = campaignDinvDataList;
                //this.showInvTable = true;
                if((data.cvrgData== null || data.cvrgData.length ==0) && (data.cmpData == null || data.cmpData.length==0)){
                    const evt = new ShowToastEvent({
                        title: this._title,
                        message: 'No policy found for this serial number',//this.label.ATI_PolicySearchMandatoryError,
                        variant: 'error'
                    });
        
                    this.dispatchEvent(evt);
                }
                if(data.cvrgData!= null && data.cvrgData.length >0){
                    this.showCoverageTable = true;
                    this.showInvTable = true;
                }
                if(data.cmpData != null && data.cmpData.length >0){
                    this.showCmpTable = true;
                    this.showInvTable = true;
                }
                
            }
            if(result.errormessage != ''){
                const evt = new ShowToastEvent({
                    title: this._title,
                    message: result.errormessage,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
            }
            if(this.data === undefined){
                let addData = [];
                let element = {};
                let columns = this.columns;
                element["key"] = 0;
                element["Id"] = 'row-0';
                addData.push(element);
                this.data = [...addData];
                //console.log('this.data>>>>> '+JSON.stringify(this.data));
            }
            this.showLoadingSpinner = false;
        })
        .catch(error =>{
            console.log('error getrecordData>>>> '+JSON.stringify(error));
            let message;
            if (error.hasOwnProperty('body')) {
                message = error.body.message;
            }else if(error.hasOwnProperty('message')){
                message = error.message;
            }else{
                message = error.errormessage;
            }
            const evt = new ShowToastEvent({
                title: this._title,
                message: message,
                variant: this.variant
            });
            this.error = error;
            this.showLoadingSpinner = false;
            this.dispatchEvent(evt);  
        });
    }
    }
    // Navigation to lightning component
    /*navigateToLightningComponent() {
        this[NavigationMixin.Navigate]({
            "type": "standard__component",
            "attributes": {
                //Here customLabelExampleAura is name of lightning aura component
                //This aura component should implement lightning:isUrlAddressable
                "componentName": "WOD_2__Claim_QuickActionComponent"
            }
        });
    } */

    

}