trigger ModuleHistories on Module_History__c (after insert, after update) {
	
    if(Trigger.isInsert && Trigger.isUpdate) {
        new ModuleHistoryTrigger().onAfterUpsert(Trigger.new);       
    }
}