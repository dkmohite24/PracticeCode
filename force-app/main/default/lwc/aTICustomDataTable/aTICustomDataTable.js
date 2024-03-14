import LightningDatatable from 'lightning/datatable';
import LookupTemplate from './lookup-template.html';

export default class ATICustomDataTable extends LightningDatatable {
    static customTypes = {
        lookup: {
            template: LookupTemplate,
            typeAttributes: ['lookUpConfigurationMetadataName', 'lookupId','lookupComponentId', 'label', 'placeholder', 'extraParams']
        }
    };
}