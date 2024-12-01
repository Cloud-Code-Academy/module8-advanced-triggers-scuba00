public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAcctList;

    public AccountTriggerHandler() {
        this.newAcctList = (List<Account>) Trigger.new;
    }

    public override void beforeInsert() {
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! beforeInsert xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        AccountHelper.setTypeProspect(this.newAcctList);

        AccountHelper.addressCopy(this.newAcctList);

        AccountHelper.setRating(this.newAcctList);

    }

    public override void afterInsert() {
        if(TriggerControl.executeTriggers == false){
            System.debug('Triggers are off! afterInsert  xx==>> Execute_Triggers_Indicator__c is disabled/false.');
            return;
        }

        AccountHelper.defaultContact(this.newAcctList);
    }

}