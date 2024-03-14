public class ATI_QueueableUtilTestQueableClass implements Queueable{
	Integer i;
    public ATI_QueueableUtilTestQueableClass(Integer i){
       this.i = i; 
    }
    
    public void execute(QueueableContext context){
        i++;
    }
}