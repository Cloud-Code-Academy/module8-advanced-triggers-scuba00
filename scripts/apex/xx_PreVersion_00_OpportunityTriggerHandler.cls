public with sharing class OpportunityTriggerHandler {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    public static Boolean isActive = true;

    public static void beforeUpdate(List<Opportunity> opportunities) {
        // Check for Contact read and create permissions
        if (!Schema.sObjectType.Contact.isAccessible()) {
                throw new OtherException('Current user does not have permission to read or create Contact records.');
        }

        Set<Id> accountIdSet = new Set<Id>();

        for(Opportunity opp : opportunities){
            if(opp.Amount <= 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
            
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

        for(Opportunity opportunityRecord : opportunities){
            opportunityRecord.Primary_Contact__c = accountToContactMap.get(opportunityRecord.AccountId);
        }
    }

    public static void beforeDelete(List<Opportunity> opportunities) {
        // Check for Account read and create permissions
        if (!Schema.sObjectType.Account.isAccessible()) {
                throw new OtherException('Current user does not have permission to read Account records.');
        }

        // Step01: Collect Account Ids
        Set<Id> accountIdSet = new Set<Id>();
        System.debug('accountIdSet: ' + accountIdSet);

            for(Opportunity opp : opportunities){
                if(opp.AccountId != null){
                    accountIdSet.add(opp.AccountId);
                }
            }

        // Step02: Query Account records
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [Select Id, Name, Industry from Account where Id IN :accountIdSet]
        );
        System.debug('accountMap:' + accountMap);

        // Step03: Process each Opportunity
        for(Opportunity opp : opportunities) {
            if(opp.AccountId != null
                && accountMap.containsKey(opp.AccountId)){
                Account relatedAccount = accountMap.get(opp.AccountId);
                String accountIndustry = relatedAccount.Industry;
                // Prevent delete if the industry is Banking and opportunity is closed won
                System.debug('=====> accountIndustry: ' + accountIndustry);
                System.debug('=====> opp.StageName: ' + opp.StageName);
                if(accountIndustry == 'Banking'
                    && opp.StageName == 'Closed Won'){
                    opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }

}
