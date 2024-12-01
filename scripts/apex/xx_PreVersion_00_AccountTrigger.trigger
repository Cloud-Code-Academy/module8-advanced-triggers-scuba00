trigger AccountTrigger on Account (before insert, after insert) {

    // Before Insert Trigger Logic
    // This part will be executed before a new Account record is inserted into the database
    if(Trigger.isBefore && Trigger.isInsert && AccountTriggerHandler.isActive) {
        // Call the before insert method from the AccountTriggerHandler class
        AccountTriggerHandler.beforeInsert(Trigger.new);
    }

    // After Insert Trigger Logic
    // This part will be executed after a new Account record is inserted into the database
    if(Trigger.isAfter && Trigger.isInsert && AccountTriggerHandler.isActive) {
        // Call the after insert method from the AccountTriggerHandler class        
        AccountTriggerHandler.afterInsert(Trigger.new);
    }

}