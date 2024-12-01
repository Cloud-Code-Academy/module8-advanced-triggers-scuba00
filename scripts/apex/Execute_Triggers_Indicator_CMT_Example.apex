/*
    Custom Metadata Type
    Singular Label: Org-Specific_Setting        API Name: Org_Specific_Seting__mdt
    Custom Field
    Field Label: Execute_Triggers_Indicator     API Name: Execute_Triggers_Indicator__c
    Custom Metadata Record Name (Field Name: DeveloperName)
    Label: Run_All_Triggers
*/

/*     Using SOQL to obtain value from Custom Metadata Type
Org_Specific_Setting__mdt orgSettingExecuteTriggers = [
    SELECT
    	Execute_Triggers_Indicator__c 
    FROM
    	Org_Specific_Setting__mdt
    WHERE
    	DeveloperName = 'Run_All_Triggers'
    LIMIT
    	1
];
*/

/*
    Using the getInstance method in the Custom Metadata Type's __mdt SObject.
    This method allows you to get a specific custom metadata record by its Developer Name. 
*/
Org_Specific_Setting__mdt orgSettingExecuteTriggers = Org_Specific_Setting__mdt.getInstance('Run_All_Triggers');

//Check the value of Execute_Triggers_Indicator__c
if(orgSettingExecuteTriggers != null
   && orgSettingExecuteTriggers.Execute_Triggers_Indicator__c){
       // Execute Triggers
       System.debug('Execute_Triggers_Indicator__c is enabled/true.');
} else {
    	// Do not execute Triggers
		System.debug('Execute_Triggers_Indicator__c is disabled/false.');
       }