import LookUpNoObjectLabel from '@salesforce/label/WOD_2.LookUpNoObjectLabel';
import requiredErrorMessage from '@salesforce/label/WOD_2.requiredErrorMessage';
import LimitError from '@salesforce/label/WOD_2.LimitError';
import AT_Genric_Error from '@salesforce/label/WOD_2.AT_Genric_Error';
import Record_Empty from '@salesforce/label/WOD_2.Record_Empty'


const lookUpLabelObj = () => {
    return {
        LookUpNoObjectLabel: LookUpNoObjectLabel,
        requiredErrorMessage: requiredErrorMessage,
        LimitError: LimitError,
        AT_Genric_Error: AT_Genric_Error,
        Record_Empty: Record_Empty
    }
}

export {
    lookUpLabelObj
};