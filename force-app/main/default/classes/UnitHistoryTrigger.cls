public with sharing class UnitHistoryTrigger {

    public List<Unit_History__c> newUnitHistoryList;
    public Map<Id, Unit_History__c> oldUnitHistoryMap;

    public UnitHistoryTrigger(List<Unit_History__c> newUnitHistoryList, Map<Id, Unit_History__c> oldUnitHistoryMap) {
        this.newUnitHistoryList = newUnitHistoryList;
        this.oldUnitHistoryMap = oldUnitHistoryMap;
        
    }
    
    public void onBeforeUpdate(){

        List <Unit_History__c> filterList = new List <Unit_History__c>();
        for(Unit_History__c  finalList : this.newUnitHistoryList){
            if(finalList.Status__c == 'Answered' && this.oldUnitHistoryMap.get(finalList.id).Status__c == 'Draft'){
                filterList.add(finalList);
        }
    }
    validateAnswer(filterList);
}

public static void validateAnswer (List<Unit_History__c> filterList){

    Map<Id, Unit_History__c> unitHistoryMap = new Map<Id, Unit_History__c>([
            SELECT Id, Unit__r.Points__c, (
                SELECT Id, Option__r.IsCorrect__c
                FROM Question_Answer__r
            )
            FROM Unit_History__c
            WHERE Id IN : filterList
        ]);

        for (Unit_History__c unitHistory: filterList){
            Integer count = 0;
            
            
            for (Question_Answer__c questionAnswer: unitHistoryMap.get(unitHistory.Id).Question_Answer__r){
                Boolean isCorrect = questionAnswer.Option__r.IsCorrect__c;
                if (isCorrect) {
                    count++;
                }
            }
            if(count == unitHistoryMap.get(unitHistory.Id).Question_Answer__r.size()){
                unitHistory.Status__C = 'Success';
                unitHistory.Unit_Completed__c = true;
                if(unitHistory.TriesNumber__c == 1){
                    unitHistory.Points__c = unitHistoryMap.get(unitHistory.id).Unit__r.Points__c;
                }else if(unitHistory.TriesNumber__c == 2){
                    unitHistory.Points__c = unitHistoryMap.get(unitHistory.id).Unit__r.Points__c/2;
                }else{
                    unitHistory.Points__c = unitHistoryMap.get(unitHistory.id).Unit__r.Points__c/4;
                }
            }else{
                unitHistory.Status__C = 'Fail';
            }
        }

}

    
}