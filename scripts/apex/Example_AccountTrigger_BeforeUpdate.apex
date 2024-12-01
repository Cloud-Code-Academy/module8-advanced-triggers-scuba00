trigger AccountTrigger on Account (before update) {
    // This is our logicless trigger. It doesn't contain any business logic, just a call to our handler class.
    AccountTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
}

// This is the handler class where most of the business logic will reside
public class AccountTriggerHandler {
    // This set will store the IDs of the Accounts that have already been processed
    private static Set<Id> processedAccounts = new Set<Id>();

    // This is the method that the trigger will call
    public static void handleBeforeUpdate(List<Account> newAccounts, Map<Id, Account> oldMap) {
        for (Account a : newAccounts) {
            // Check if we've already processed this Account in this transaction
            if (processedAccounts.contains(a.Id)) {
                // We've already processed this Account, so we skip it to avoid recursion
                continue;
            }

            // If we haven't processed this Account yet, we add its Id to our set of processed Accounts
            processedAccounts.add(a.Id);

            // Here is where you'd put your business logic. For the purposes of this example, we'll just update the Account's Description
            a.Description = 'Updated by our trigger at ' + Datetime.now();
        }
    }
}