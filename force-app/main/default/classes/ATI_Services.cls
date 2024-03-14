/**
 * @description       : General Services class used in other classes for handling various operations.
 * @author            : Abhishek Mohapatra
 * @group             :
 * @last modified on  : 11-01-2023
 * @last modified by  : Abhishek Mohapatra
 **/
public with sharing class ATI_Services {
  /**
   * @description This method is called from PRPC_BranchCount (account trigger) to verify the address change on account record.
   * @author Abhishek Mohapatra | 07-13-2023
   * @param newAccList [new Account List]
   * @param oldMap [old Account Map]
   **/
  public static void accountAddressValidate(
    List<Account> newAccList,
    Map<Id, Account> oldMap
  ) {
    for (Account ac : newAccList) {
        system.debug('Entering for loop');
      // Logic to verify address change
      if (
          
        ac.BillingStreet != oldMap.get(ac.Id).BillingStreet ||
        ac.BillingCity != oldMap.get(ac.Id).BillingCity ||
        ac.BillingState != oldMap.get(ac.Id).BillingState ||
        ac.BillingCountry != oldMap.get(ac.Id).BillingCountry ||
        ac.BillingPostalCode != oldMap.get(ac.Id).BillingPostalCode
      ) {
          system.debug('Entering if block'+ac);
        if (!System.isFuture() && !System.isBatch()) {
            system.debug('Entering if block'+(String) ac.Id);
          MDPERSONATOR.MD_GlobalAddressWSExt.doOneGlobalAddress((String) ac.Id);
        }
      }
    }
  }
  /**
   * @description This method is called from PRPC_BranchCount (account trigger) to verify the address added on new account record.
   * @author Abhishek Mohapatra | 07-13-2023
   * @param newAccList [new Account List]
   **/
  public static void accountAddressValidate(List<Account> newAccList) {
    for (Account ac : newAccList) {
      if (
        !String.isBlank(ac.BillingStreet) ||
        !String.isBlank(ac.BillingCity) ||
        !String.isBlank(ac.BillingState) ||
        !String.isBlank(ac.BillingCountry) ||
        !String.isBlank(ac.BillingPostalCode)
      ) {
        if (!System.isFuture() && !System.isBatch()) {
          MDPERSONATOR.MD_GlobalAddressWSExt.doOneGlobalAddress((String) ac.Id);
        }
      }
    }
  }
}