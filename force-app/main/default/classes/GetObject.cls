public class GetObject {
    public static Void Objedatamethod (){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Set<String> standardObjects = new Set<String>();
        Set<String> customObjects = new Set<String>();
        //For Custom And Standard Object
        for(Schema.SObjectType d : gd.values())
        {
            Schema.DescribeSObjectResult ds = d.getDescribe();
            if(!ds.isCreateable())
                continue;
            if(ds.isCustom() == false && ds.getRecordTypeInfos().size() > 0)
                standardObjects.add(ds.getName());
            else if(ds.isCustom())
                customObjects.add(ds.getName());
        }
        List<String> sortedNames = new List<String>(customObjects);
        sortedNames.sort();
        System.debug('Standard object: ' + standardObjects.size());
        System.debug('Standard object: ' + customObjects.size());
        for(String name : sortedNames)
            System.debug('Custom object: ' + name);
        sortedNames = new List<String>(standardObjects);
        sortedNames.sort();
        System.debug('Standard object: ' + sortedNames.size());
        for(String name : sortedNames)
            System.debug('Standard object: ' + name);
        
    }
}