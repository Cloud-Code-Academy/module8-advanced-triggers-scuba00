/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}    

    public static void setTypeProspect(List<Account> newAcctList){
        for (Account acc : newAcctList){
            if (acc.Type == null || acc.Type == '') {
                acc.Type = 'Prospect';
            }
        }
    }

    public static void addressCopy(List<Account> newAcctList){

        for(Account acc : newAcctList){
            
            // check if shipping address is null
            Boolean isShippingAddressNullOrBlank = 
                (acc.ShippingStreet == null || acc.ShippingStreet.trim() == '')
            &&  (acc.ShippingCity == null || acc.ShippingCity.trim() == '') 
            &&  (acc.ShippingState == null || acc.ShippingState.trim() == '') 
            &&  (acc.ShippingPostalCode == null || acc.ShippingPostalCode.trim() == '') 
            &&  (acc.ShippingCountry == null || acc.ShippingCountry.trim() == '');

            if(!isShippingAddressNullOrBlank){
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }

        }

    }

    public static void setRating(List<Account> newAcctList){

        for(Account acc : newAcctList){
        // check if phone, website and fax all have values
            Boolean isAccountRatingHotNullOrBlank = 
                (acc.Phone == null || acc.Phone.trim() == '')
            &&  (acc.Website == null || acc.Website.trim() == '')
            &&  (acc.Fax == null || acc.Fax.trim() == '');

            if(!isAccountRatingHotNullOrBlank){
                acc.Rating = 'Hot';
            }
        }

    }

    public static void defaultContact (List<Account> newAcctList) {
        // Check for Contact read and create permissions
        if (!Schema.sObjectType.Contact.isAccessible() 
            || !Schema.sObjectType.Contact.isCreateable()) {
                throw new OtherException('Current user does not have permission to read or create Contact records.');
        }

        List<Contact> contactsToInsert = new List<Contact>();

        for(Account acc : newAcctList){
            Contact newContact = new Contact();
            newContact.LastName = 'DefaultContact';
            newContact.Email = 'default@email.com';
            newContact.AccountId = acc.Id;
            contactsToInsert.add(newContact);
        }

        if(!contactsToInsert.isEmpty()){
            try {
                insert contactsToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting contacts: ' + e.getMessage());
            }
        }        

    }

}
