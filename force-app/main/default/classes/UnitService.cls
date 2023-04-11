public with sharing class UnitService {

    @AuraEnabled
    public static Boolean registerUnitHistory(Id unitId, String jsonAnswer){
    
        Savepoint savePoint = Database.setSavepoint();
        Boolean verify = false;

        try {
            Unit__c unit = [
                SELECT  Module__c, 
                ( SELECT Id,  
                TriesNumber__c 
                FROM Unit_Responses__r 
                WHERE Module_History__r.User__c = :UserInfo.getUserId()                 
                ORDER BY TriesNumber__c 
                DESC LIMIT 1),               
                (SELECT Id, 
                Name 
                FROM Questions__r)
                FROM Unit__c
                WHERE Id = :unitId
                LIMIT 1
               ];   
    
    Module_History__c searchRecord;
    try{
        searchRecord = [
            SELECT Id
            FROM Module_History__c
            WHERE Module__c =: unit.Module__c AND 
            User__c =: UserInfo.getUserId() AND 
            Status__c = 'In Progress'
        ];
    }catch (Exception e){
        searchRecord = new Module_History__c(
            User__c = UserInfo.getUserId(),
            Module__c = unit.Module__c,
            Status__c = 'In Progress');
        insert searchRecord;
    }

    Unit_History__c unitHistory = new Unit_History__c(
        Unit__c = unitId,
        Module_History__c = SearchRecord.Id,
        Status__c = 'Draft'
    );
    unitHistory.TriesNumber__c = !unit.Unit_Responses__r.isEmpty()
        ? unit.Unit_Responses__r[0].TriesNumber__c + 1
        : 1;
        
        insert unitHistory;
    
        Map<Id, Id> answerMap = (Map<Id, Id>) JSON.deserialize(
            jsonAnswer,
            Map<Id, Id>.class
          );

    List<Question_Answer__c> questionAnswers = new List<Question_Answer__c>();

    for (Question__c question: unit.Questions__r) {
    if (answerMap.containsKey(question.Id)) {
        Question_Answer__c questionAnswer = new Question_Answer__c(
        Question__c = question.Id,
        Unit_History__c = unitHistory.Id,
        Option__c = answerMap.get(question.Id)
        );
        questionAnswers.add(questionAnswer);
    }else{
        Database.rollback(savepoint);
        //throw new CustomException('The question ' + question.Name + ' is required');
    }
}

insert questionAnswers;
unitHistory.Status__c = 'Answered';
update unitHistory;
verify = true;
} catch (Exception e) {
    Database.rollback(savepoint);
    throw e;
  }
  return verify;
}








    /*
    //private final static String CURRENT_USER = UserInfo.getUserId(); 
    private static Unit__c unit;
    private static Module_History__c moduleHistory;
    private static Unit_History__c unitHistory;
    
    private static Savepoint savePoint;

    public class CustomException extends Exception {}

    public UnitService() {
    }

    @AuraEnabled
    public static Boolean registerUnitHistory(Id unitId, String jsonAnswer){
        //savePoint = Database.setSavepoint();
        try {
            queryUnit(unitId);
            createModuleHistory();
            createUnitHistory(unitId);
            upsertQuestionAnswers(jsonAnswer);
        } catch (DmlException dmlException) {
            //Database.rollback(savepoint);
        }
        //return unitHistory.Unit_Completed__c;
        return false;
    }

    
    private static void queryUnit(Id unitId){
        unit = [
            SELECT Module__c, (
                SELECT Id, Name
                FROM Questions__r
            ),(
                SELECT Id, Tries__c
                FROM Unit_Responses__r
                WHERE Module_History__r.User__c =: UserInfo.getUserId()
                ORDER BY Tries__c DESC
                LIMIT 1
            )
            FROM Unit__c
            WHERE Id =: unitId
            LIMIT 1
        ];
    }

    
    private static void createModuleHistory() {
        moduleHistory = [
            SELECT Id
            FROM Module_History__c
            WHERE Module__c =: unit.Module__c AND 
                    User__c =: UserInfo.getUserId() AND 
                    Status__c = 'In Progress'
            LIMIT 1
        ];

        if (moduleHistory == null) {
            moduleHistory = new Module_History__c();
            moduleHistory.User__c = UserInfo.getUserId();
            moduleHistory.Module__c = unit.Module__c;
            moduleHistory.Status__c = 'In Progress';
            //CAMBIO
            insert moduleHistory;
        }
        System.debug('moduleHistory' + moduleHistory);

        
    }

    
    private static void createUnitHistory(Id unitId){
        unitHistory = new Unit_History__c(
            Unit__c = unitId,
            Module_History__c = moduleHistory.Id,
            Status__c = 'Draft'            
        );
        System.debug('unitId' + unitId + ' ' + unitHistory.Unit__c);

        if (!unit.Unit_Responses__r.isEmpty()) {
            unitHistory.TriesNumber__c = unit.Unit_Responses__r[0].TriesNumber__c + 1;
        } else {
            unitHistory.TriesNumber__c = 1;
        }

        insert unitHistory;
    }

    
    private static void upsertQuestionAnswers(String jsonAnswer) {
        Map<Id,Id> answerMap = parseJSON(jsonAnswer);
        List<Question_Answer__c> questionAnswers = new List<Question_Answer__c>();

        for (Question__c question: unit.Questions__r) {
            if (answerMap.containsKey(question.Id)) {
                Question_Answer__c questionAnswer = new Question_Answer__c();
                questionAnswer.Question__c = question.Id;
                questionAnswer.Unit_History__c = unitHistory.Id;
                questionAnswer.Option__c = answerMap.get(question.Id);
                questionAnswers.add(questionAnswer);
            } else {
                Database.rollback(savepoint);
                throw new CustomException('The question ' + question.Name + ' is required');
            }
        }

        insert questionAnswers;
        unitHistory.Status__c = 'Answered';
        update unitHistory;
    }

    
    private static Map<Id,Id> parseJSON(String jsonAnswer){
        return (Map<Id,Id>) JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);
    }
    
    */

    public class UnitWrapper{
        @AuraEnabled
        public Unit__c unit;
        @AuraEnabled
        public List<Question__c> questions;
        
        public UnitWrapper(Unit__c unit, List<Question__c> questions){
            this.unit = unit;
            this.questions = questions;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static UnitWrapper getUnit(Id unitId){
        Unit__c unit = [SELECT Id, Name, Time_Estimate__c, Points__c FROM Unit__c WHERE Id =: unitId ];
        
        List<Question__c> questions = [SELECT Id, Name, Content__c,(SELECT Id, Name, Description__c, IsCorrect__c FROM Options__r)
                                      FROM Question__c
                                      WHERE Unit__c =: unitId
                                      ];
        
        return new UnitWrapper(unit, questions);
    }

}