trigger AccountTrigger on Account (after update) {
    // Let's create a Set to hold our Account Ids from the Trigger.new context variable
    Set<Id> accountIds = new Set<Id>();
    for (Account acc : Trigger.new) {
        accountIds.add(acc.Id);
    }

    // Now, let's perform a SOQL query to fetch all Opportunities related to these Accounts
    // We are querying in bulk - not for individual Accounts
    List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId IN :accountIds];

    // Log the number of Opportunities fetched for debugging purposes
    System.debug('Number of Opportunities fetched: ' + opps.size());
    
    // Here, we can perform operations on the fetched Opportunities
    // Always remember to handle lists or sets of records, not individual records
    for (Opportunity opp : opps) {
        // Perform operations on each Opportunity
        // For example, let's just log the Opportunity names for now
        System.debug('Opportunity Name: ' + opp.Name);
    }
}