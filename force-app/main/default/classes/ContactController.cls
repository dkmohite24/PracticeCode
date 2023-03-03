public with sharing class ContactController {

    public Contact c { get; set; }

    public List<Contact> samepage { get; set; }
    
    public ContactController(){
       c=new Contact();
    }

    public PageReference save() {
          
      samepage= [select id,FirstName,LastName,Email,Birthdate from Contact where id=:c.id];
      
        return null;
    }


   }