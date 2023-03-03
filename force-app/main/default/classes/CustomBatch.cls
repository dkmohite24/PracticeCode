public class CustomBatch implements Database.Batchable<String> {

   private List<String> jsonStrings;

   public CustomBatch(List<String> jsonStrings) {
       this.jsonStrings = jsonStrings;
   }

   public List<String> start(Database.BatchableContext info) { 
       return jsonStrings; 
   }

   public void execute(Database.BatchableContext info, List<String> scope) { 
       Integer i = 0;
       for(String a : scope){ 
           System.debug(loggingLevel.Error, '*** json_' + i + ': ' + a); 
           i++;
       } 
   }

   public void finish(Database.BatchableContext info) {     
   } 
}