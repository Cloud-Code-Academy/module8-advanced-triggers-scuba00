public with sharing class TriggerControl {

    public static Boolean executeTriggers = null;

    static {
        System.debug('Static block is executed.');
        initialize();
    }

    public static void initialize() {
        /*
            Using the getInstance method in the Custom Metadata Type's __mdt SObject.
            This method allows you to get a specific custom metadata record by its Developer Name. 
            The control to determine whether or not All Triggers are executed or not executed is defined in the Custome Metadata Types in Setup.
            Label: Org-Specific Setting         API Name:  Org_Specific_Setting__mdt
            click on <Manage Records>  
            Edit the record with label: Run All Triggers 
            There is a check box: Execute_Triggers_Indicator
            If the check box is unchecked, executeTriggers will be set to false.
                No triggers will be executed
            If the check box is checked, executeTriggers will be set to true.
                All triggers will be executed
            Every method used in the context of the triggers, must contain the proper if statement
            as in the following example of code:

        public override void beforeInsert() {

            if(TriggerControl.executeTriggers == false){
                return;
            }

            AccountHelper.defaultShippingAddress(this.newAcctMap.values());
        }

        */

        Org_Specific_Setting__mdt orgSettingExecuteTriggers = Org_Specific_Setting__mdt.getInstance('Run_All_Triggers');

        //Check the value of Execute_Triggers_Indicator__c
        if(orgSettingExecuteTriggers != null
        && orgSettingExecuteTriggers.Execute_Triggers_Indicator__c){
            // Execute Triggers
            executeTriggers = true;
        } else {
            // Do not execute Triggers
            executeTriggers = false;
        }
   }

}