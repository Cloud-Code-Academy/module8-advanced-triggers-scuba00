// This is a simple trigger that responds to the 'before update' operation on Account records.
trigger AccountTrigger on Account (before update) {

    // operationType is an enum that tells us which operation caused this trigger to fire. 
    // In this case, we're dealing with a 'before update' operation.
    System.debug('Operation type: ' + Trigger.operationType);
    
    // size tells us how many records initiated the trigger.
    // It's like counting the number of adventurers in our party! 
    System.debug('Number of records: ' + Trigger.size);

    // newMap is a magical map that contains all the records that caused the trigger to fire, 
    // with their new field values. The map's keys are the records' IDs, and the values are the records themselves.
    System.debug('New values: ' + Trigger.newMap);

    // oldMap is the counterpart to newMap. It contains all the records that caused the trigger to fire, 
    // with their old field values, before any changes that made the trigger fire.
    System.debug('Old values: ' + Trigger.oldMap);
}

// Now let's look at a more complex example, where we use newMap and oldMap to prevent certain updates.

trigger AccountTrigger on Account (before update) {
    for(Account newAccount : Trigger.new) {
        Account oldAccount = Trigger.oldMap.get(newAccount.Id);

        // Let's say we want to prevent the Account Name from being changed. We can use oldMap and newMap to do this.
        if(newAccount.Name != oldAccount.Name) {
            newAccount.Name.addError('You cannot change the Account Name.');
        }
    }
}

trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Let's use a switch on the operationType to handle different trigger operations
    switch on Trigger.operationType {
        when AFTER_INSERT {
            System.debug('This is an after insert operation. Number of records inserted: ' + Trigger.size);
            // put your after insert logic here
        }
        when AFTER_UPDATE {
            System.debug('This is an after update operation. Number of records updated: ' + Trigger.size);
            // put your after update logic here
        }
        when AFTER_DELETE {
            System.debug('This is an after delete operation. Number of records deleted: ' + Trigger.size);
            // put your after delete logic here
        }
        when AFTER_UNDELETE {
            System.debug('This is an after undelete operation. Number of records undeleted: ' + Trigger.size);
            // put your after undelete logic here
        }
        when BEFORE_INSERT {
            System.debug('This is a before insert operation. Number of records to be inserted: ' + Trigger.size);
            // put your before insert logic here
        }
        when BEFORE_UPDATE {
            System.debug('This is a before update operation. Number of records to be updated: ' + Trigger.size);
            // put your before update logic here
        }
        when BEFORE_DELETE {
            System.debug('This is a before delete operation. Number of records to be deleted: ' + Trigger.size);
            // put your before delete logic here
        }
    }
}