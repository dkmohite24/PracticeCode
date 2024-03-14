//Description:Test Class for StringConversion Class

@IsTest
public class TurnAroundTimeMappingBatchTestClass {
       @IsTest
    public static void Method1(){
		String m1='2021-06-01T19:00:00.000 9898';
        test.startTest();
      StringConversion.SplitMethod(m1);
        test.stopTest();  
    }
    @IsTest
     public static void Method2(){
		String m2='2021-06-22';
        test.startTest();
      StringConversion.SplitMethod4(m2);
        test.stopTest();  
    }
    @IsTest
    public static void Method3(){
		String m3='00.000';
        test.startTest();
      StringConversion.SplitMethod3(m3);
        test.stopTest();  
    }
     @IsTest
     public static void Method4(){
		String m4='2021-06-22';
        test.startTest();
      StringConversion.SplitMethod2(m4);
        test.stopTest();  
    }
  
    
    

}