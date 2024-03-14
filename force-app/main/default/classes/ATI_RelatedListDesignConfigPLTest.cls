/*
    Class Name  :   ATI_RelatedListDesignConfigPLTest
    Description :   Test class for ATI_RelatedListDesignConfigPickList
*/
@isTest
private class ATI_RelatedListDesignConfigPLTest {
    public static TestMethod void testRelatdListDesignMethod(){
        ATI_RelatedListDesignConfigPickList  rldCP = new ATI_RelatedListDesignConfigPickList();
        VisualEditor.DataRow defValue = rldCP.getDefaultValue();
        System.assertEquals(true,defValue != NULL,'Default value should be set');
        VisualEditor.DynamicPickListRows values = rldCP.getValues();
        System.assertEquals(true,values != NULL,'Values should be set');
    }
}