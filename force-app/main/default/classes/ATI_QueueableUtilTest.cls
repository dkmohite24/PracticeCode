/**************************************************************************************
 Name            : ATI_QueueableUtil 
 Date            : March 25 , 2021 
 Description   	 : Test Class for ATI_QueueableUtil
***************************************************************************************/
@isTest
public class ATI_QueueableUtilTest {
    @IsTest
    public static void testQueueable(){
        Integer i = 0;
        ATI_QueueableUtil.enqueueJob(new ATI_QueueableUtilTestQueableClass(i));
    }
}