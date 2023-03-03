public class RemoveNUmberfrom {
    public static void getnumbermethod(){
        
        String before = '123AbCgoya1Me';
        String alpha = '';
        String numeric = '';
        
        List<String> chars = before.split('|');
        for (String s : chars)
        {
            if (s.isAlpha())
            {
                alpha += s;
            }
            else
            {
                numeric += s;
            }
        }
        
        system.debug(alpha);
        system.debug(numeric);
        
        
        
        
        
        
        
        
        String field1 = 'Test123';
        String field2 = field1.replaceAll('[^0-9]', '');
        
        field1 = field1.replaceAll('[0-9]', '');
        
        system.debug(field1);
        system.debug(field2);
    }
    
}