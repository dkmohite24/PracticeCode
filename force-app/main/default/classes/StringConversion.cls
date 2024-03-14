public class StringConversion {
    public static string SplitMethod(String str){
            String claimfield  = str;
        String finallist=' ';
        if(claimfield!=NULL){
            
            list<String> splitlist = claimfield.split('\\ ');
            list<String> splitlist2 =splitlist[0].split('\\-');
            list<String> splitlist3= new list<String>();
            for(String s:splitlist2){
                splitlist3.add(splitlist2[1]);
                }
            map<String,String> datemap =new map<String,String>();
            for(String s1:splitlist3)
            {
                datemap.put('01','JAN');
                datemap.put('02','FEB');
                datemap.put('03','MAR');
                datemap.put('04','APR');
                datemap.put('05','MAY');
                datemap.put('06','JUN');
                datemap.put('07','JUL');
                datemap.put('08','AUG');
                datemap.put('09','SEP');
                datemap.put('10','OCT');
                datemap.put('11','NOV');
                datemap.put('12','DEC');
            }
             finallist= splitlist2[2] + datemap.get(splitlist2[1]) + splitlist2[0]+':'+splitlist[1];
        }
        	return finallist;
        }
            
    
   public static string SplitMethod2(String str){
        String claimfield  = str;
            list<String> splitlist = claimfield.split('\\-');
        	list<String> splitlist2= new list<String>();
            for(String s:splitlist){
                splitlist2.add(splitlist[1]);
                }
         map<String,String> datemap =new map<String,String>();
            for(String s1:splitlist2)
            {
                datemap.put('01','JAN');
                datemap.put('02','FEB');
                datemap.put('03','MAR');
                datemap.put('04','APR');
                datemap.put('05','MAY');
                datemap.put('06','JUN');
                datemap.put('07','JUL');
                datemap.put('08','AUG');
                datemap.put('09','SEP');
                datemap.put('10','OCT');
                datemap.put('11','NOV');
                datemap.put('12','DEC');
                    }
        string finallist2= splitlist[2]+datemap.get(splitlist[1])+splitlist[0];
        return finallist2;     
    }
    													 
     public static string SplitMethod3(String str){    
        String claimfield  = str;
         list<String> splitlist = claimfield.split('\\.');
         string finalstring= splitlist[0];
         return finalstring;

         
     }

     public static string SplitMethod4(String str){
        String claimfield  = str;
            list<String> splitlist = claimfield.split('\\-');
        	list<String> splitlist2= new list<String>();
            for(String s:splitlist){
                splitlist2.add(splitlist[1]);
                }
         map<String,String> datemap =new map<String,String>();
            for(String s1:splitlist2)
            {
                datemap.put('01','Jan');
                datemap.put('02','Feb');
                datemap.put('03','Mar');
                datemap.put('04','Apr');
                datemap.put('05','May');
                datemap.put('06','Jun');
                datemap.put('07','Jul');
                datemap.put('08','Aug');
                datemap.put('09','Sep');
                datemap.put('10','Oct');
                datemap.put('11','Nov');
                datemap.put('12','Dec');
                    }
        string finallist2= splitlist[2]+'-'+datemap.get(splitlist[1])+'-'+splitlist[0].right(2);
        return finallist2;     
    }
    

}