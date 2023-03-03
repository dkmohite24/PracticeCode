/*
Name          :    paginationforcontactscontroller
Author        :    Anavclouds (Dhananjay Mohite)
Date          :    7th April 21
Description   :    This class is created to set up pagination for contacts object.

 */



public with sharing class Pagination_minnew {
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public boolean test = false;
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                if(test == false){
                size = 10;
                }
                string queryString = 'SELECT id,name,title,CreatedById,Email,Createddate,Owner.name FROM Contact order by Createddate DESC';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                test = true;
            }
            return setCon;
        }set;		
    }
     
    Public List<contact> getContacts(){
        List<Contact> accList = new List<Contact>();
        for(Contact a : (List<Contact>)setCon.getRecords())
            accList.add(a);
        return accList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getContacts();
        setCon.setPageNumber(1);
        return null;
    }
    public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('10','10'));
            options.add(new SelectOption('20','20'));
            options.add(new SelectOption('30','30'));
              options.add(new SelectOption('40','40'));
            return options;
        }
}