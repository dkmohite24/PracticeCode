/**
 * @description       : This is a handler class for contact trigger
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : Abhishek Mohapatra
**/
public with sharing class ATI_ContactTriggerHandler {
    public ATI_ContactTriggerHandler() {

    }

    /**
    * @description Update related work will be done in this method.
    * @author Abhishek Mohapatra | 07-13-2023 
    * @param conList [new contact list.]
    * @param oldMap [old id, contact map.]
    **/
    public static void forUpdate(List<Contact> conList, Map<Id,Contact> oldMap){
        for(contact con : conList){

            // Logic to verify address change
            if(con.MailingStreet != oldMap.get(con.Id).MailingStreet
                || con.MailingCity != oldMap.get(con.Id).MailingCity
                || con.MailingState != oldMap.get(con.Id).MailingState
                || con.MailingCountry != oldMap.get(con.Id).MailingCountry
                || con.MailingPostalCode != oldMap.get(con.Id).MailingPostalCode){
                    if(!System.isFuture() && !System.isBatch()) {
                        MDPERSONATOR.MD_GlobalAddressWSExt.doOneGlobalAddress((String)con.Id);
                       }
                }
        }
    }
}