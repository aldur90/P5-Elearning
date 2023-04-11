trigger UnitsHistory on Unit_History__c (before update) {
    
    UnitHistoryTrigger unitHistoryTrigger = new UnitHistoryTrigger(Trigger.new, Trigger.oldMap);
    unitHistoryTrigger.onBeforeUpdate();

    /*
    if (Trigger.isBefore && Trigger.isUpdate) {
        UnitHistoryTrigger unitHistoryTrigger = new UnitHistoryTrigger(Trigger.new, Trigger.oldMap);
        unitHistoryTrigger.onBeforeUpdate();
    }*/

}