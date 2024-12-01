public with sharing class OpportunityHelper {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}    

    public static void checkOpportunityAmount(List<Opportunity> newOppList){

        for(Opportunity opp : newOppList){
            if(opp.Amount <= 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    
    }

    public static void setPrimaryContact(List<Opportunity> newOppList){

        // Check for Contact read and create permissions
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new OtherException('Current user does not have permission to read or create Contact records.');
        }

        Set<Id> accountIdSet = new Set<Id>();

        for(Opportunity opp : newOppList){
            
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }

        }

        List<Contact> contactList = [
            SELECT
                Id,
                AccountId,
                Name
            FROM
                Contact
            WHERE
                AccountId IN :accountIdSet
                AND Title = 'CEO'
        ];

        Map<Id, Id> accountToContactMap = new Map<Id,Id>();

        for(Contact contactRecord : contactList){
            accountToContactMap.put(contactRecord.AccountId, contactRecord.Id);
        }

        for(Opportunity opportunityRecord : newOppList){
            if (opportunityRecord.Primary_Contact__c == null) {
                opportunityRecord.Primary_Contact__c = accountToContactMap.get(opportunityRecord.AccountId);
            }
        }
 
    }

    public static void validateDeleteCriteria(List<Opportunity> oldOppList){

        // Check for Account read and create permissions
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new OtherException('Current user does not have permission to read Account records.');
        }

        // Step01: Collect Account Ids
        Set<Id> accountIdSet = new Set<Id>();

        for(Opportunity opp : oldOppList){
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }
        }

        // Step02: Query Account records
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [Select Id, Name, Industry from Account where Id IN :accountIdSet]
        );

        // Step03: Process each Opportunity
        for(Opportunity opp : oldOppList) {
            if(opp.AccountId != null
                && accountMap.containsKey(opp.AccountId)){
                Account relatedAccount = accountMap.get(opp.AccountId);
                String accountIndustry = relatedAccount.Industry;
                // Prevent delete if the industry is Banking and opportunity is closed won
                if(accountIndustry == 'Banking'
                    && opp.StageName == 'Closed Won'){
                    opp.addError('Cannot delete closed opportunity for a banking account that is won');
                } else if (opp.IsClosed){
                    opp.addError('Cannot delete closed opportunity');
                }
            }
        }

    }

    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    private static void notifyOwnersOpportunityDeleted(List<Opportunity> newOppList) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
/*
        for (Opportunity opp : newOppList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
*/            
    }

    /*
    assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */    

public static void assignPrimaryContact(List<Opportunity> newOppList) {

    // Collect IDs of opportunities needing a primary contact assignment
    List<Opportunity> oppToUpdate = new List<Opportunity>();

    // Find "VP Sales" contacts for the accounts associated with these opportunities
    List<Contact> vpSalesContacts = [
        SELECT Id, AccountId
        FROM Contact
        WHERE Title = 'VP Sales'
        //WHERE Title LIKE '%VP Sales%' AND AccountId IN :oppMap.keySet()
    ];

    List<Contact> allContacts = [
        SELECT Id, AccountId, Name, Title
        FROM Contact

        //WHERE Title LIKE '%VP Sales%' AND AccountId IN :oppMap.keySet()
    ];

    // Filter opportunities without a primary contact and not deleted
    for (Opportunity opp : newOppList) {
        if (opp.Primary_Contact__c == null && !opp.IsDeleted) {

            // Clone the existing record to maintain original data and avoid modifying the original list directly
            Opportunity updatedOpp = opp.clone(true, true, false); 
            
            updatedOpp.Primary_Contact__c = vpSalesContacts.get(0).Id;  // Set the Primary_Contact__c field

            oppToUpdate.add(updatedOpp);  // Add the modified clone to the oppToUpdate list

        }

    }

    // Optional: Perform the update if needed
    try {
        update oppToUpdate;
        System.debug('Opportunities updated successfully: ' + oppToUpdate.size());
    } catch (DmlException e) {
        System.debug('Error updating Opportunities: ' + e.getMessage());
    }

}

/*
    setDefaultType:
    - Assigns a Type for new Opportunities.
    - Only updates the Opportunities that doesn't have an assigned Type.
    */  
    public static void setDefaultType(List<Opportunity> newOppList) {

        // Set default Type for new Opportunities
        for(Opportunity opp : newOppList) {
            if (opp.Type == null){
                    opp.Type = 'New Customer';
            }        
        }
    }

    /*
    createNewTask:
    - Create a new Task for newly inserted Opportunities
    */  
    public static void createNewTask(List<Opportunity> newOppList) {
        // Check for Task read and create permissions
        if (!Schema.sObjectType.Task.isAccessible()
            && !Schema.sObjectType.Task.isCreateable()) {
            throw new OtherException('Current user does not have permission to read and create Task records.');
        }

        List<Task> newTaskList = new List<Task>();

        for (Opportunity opp : newOppList){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            newTaskList.add(tsk);
        }
        
        insert newTaskList;

    }

    /*
    appendStageChanges:
    - Append Stage changes in Opportunity Description
    */  
    public static void appendStagenameChanges(List<Opportunity> newOppList) {
        // Check for Opportunity read and update permissions
        if (!Schema.sObjectType.Opportunity.isAccessible()
            && !Schema.sObjectType.Opportunity.isUpdateable()) {
            throw new OtherException('Current user does not have permission to read and update Opportunity records.');
        }

        List<Opportunity> updateOppList = new List<Opportunity>();

        for (Opportunity opp : newOppList){

            if (opp.StageName != null){

                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
                updateOppList.add(opp);

            }
        }
    }

}