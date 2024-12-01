public with sharing class OpportunityTriggerHandler extends TriggerHandler {

//####################################################

    // need to make the OpportunityTriggerHandler.cls file.
    //
    // need to combine the following Opportunity trigger files into OpportunityTriggerHandler.cls file:
    //      Hold_OpportunityTrigger.trigger
    //      xx_Hold_AnotherOpportunityTrigger
    //      xx_PreVersion_00_OpportunityTrigger.trigger
    //      xx_PreVersion_00_OpportunityTriggerHandler.cls
    //
    //      Make an OpportunityHelper.cls as needed

//####################################################

    private List<Opportunity> newOppList;
    private List<Opportunity> oldOppList;
    private Map<Id,Opportunity> newOppMap;

    public OpportunityTriggerHandler() {
        this.newOppList = (List<Opportunity>) Trigger.new;
        this.oldOppList = (List<Opportunity>) Trigger.old;
        this.newOppMap = (Map<Id,Opportunity>) Trigger.newMap;
    }

    public override void beforeInsert(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! beforeInsert xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        OpportunityHelper.setDefaultType(this.newOppList);
    }

    public override void afterInsert(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! afterInsert xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        OpportunityHelper.createNewTask(this.newOppList);
    }

    public override void beforeUpdate() {
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! beforeUpdate xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        OpportunityHelper.checkOpportunityAmount(this.newOppList);

        OpportunityHelper.setPrimaryContact(this.newOppList);

        OpportunityHelper.appendStagenameChanges(this.newOppList);

    }

/*    
    public override void afterUpdate(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! afterUpdate xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }
        
    }
*/

    public override void beforeDelete(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! beforeDelete xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        OpportunityHelper.validateDeleteCriteria(oldOppList);

    }

/*    
    public override void afterDelete(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! afterDelete xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }
        
    }
*/

    public override void afterUndelete(){
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! afterUndelete xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        OpportunityHelper.assignPrimaryContact(newOppList);

    }

}