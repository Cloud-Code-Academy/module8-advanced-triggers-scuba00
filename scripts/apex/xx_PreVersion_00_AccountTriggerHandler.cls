public with sharing class AccountTriggerHandler {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    public static Boolean isActive = true;

    public static void beforeInsert(List<Account> accounts) {
            for(Account acc : accounts){
                // Here you can add your custom logic
                // For example, let's ensure the Account Name is not null
                if(acc.Type == null){
                    acc.Type = 'Prospect';
                }
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

    public static void afterInsert(List<Account> accounts) {

        // Check for Contact read and create permissions
        if (!Schema.sObjectType.Contact.isAccessible() 
            || !Schema.sObjectType.Contact.isCreateable()) {
                throw new OtherException('Current user does not have permission to read or create Contact records.');
        }
        List<Contact> contactsToInsert = new List<Contact>();

        for(Account acc : accounts){
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