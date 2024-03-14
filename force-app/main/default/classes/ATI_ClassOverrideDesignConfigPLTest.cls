/*
    Class Name  :   ATI_ClassOverrideDesignConfigPLTest
    Description :   Test class for ATI_ClassOverrideDesignConfigPickList
*/
@isTest
public class ATI_ClassOverrideDesignConfigPLTest{
    private static testmethod void test(){
        Test.startTest();
        ATI_ClassOverrideDesignConfigPickList classOver = new ATI_ClassOverrideDesignConfigPickList();
        VisualEditor.DataRow defValue = classOver.getDefaultValue();
        System.assertEquals(true,defValue != NULL,'Default value should be set');
        VisualEditor.DynamicPickListRows values = classOver.getValues();
        System.assertEquals(true,values != NULL,'Values should be set');
        Test.stopTest();
    }
}