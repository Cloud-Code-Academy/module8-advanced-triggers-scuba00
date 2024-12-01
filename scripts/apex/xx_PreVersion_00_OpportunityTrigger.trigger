trigger OpportunityTrigger on Opportunity (before update, before delete) {

    // Before Update Trigger Logic
    // This part will be executed before an Opportunity record is updated in the database
    if(Trigger.isBefore && Trigger.isUpdate && OpportunityTriggerHandler.isActive) {
        // Call the before insert method from the AccountTriggerHandler class
        OpportunityTriggerHandler.beforeUpdate(Trigger.new);
    }


    // Before Delete Trigger Logic
    // This part will be executed before an Opportunity record is deleted in the database
    if(Trigger.isBefore && Trigger.isDelete && OpportunityTriggerHandler.isActive) {
        // Call the after insert method from the AccountTriggerHandler class        
        OpportunityTriggerHandler.beforeDelete(Trigger.old);
    }


}
