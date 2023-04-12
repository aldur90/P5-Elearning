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
        
    }
}

insert questionAnswers;
unitHistory.Status__c = 'Answered';
update unitHistory;

Unit_History__c unitHist = [
    SELECT Unit_Completed__c
    FROM Unit_History__c
    WHERE Id =: unitHistory.Id
];

verify = unitHist.Unit_Completed__c;

} catch (Exception e) {
    Database.rollback(savepoint);
    throw e;
  }
  return verify;
  
}

public class UnitWrapper{
        @AuraEnabled
        public Unit__c unit;
        @AuraEnabled
        public List<Question__c> questions;
        @AuraEnabled
        public Boolean completed;
        
        public UnitWrapper(Unit__c unit, List<Question__c> questions, Boolean completed){
            this.unit = unit;
            this.questions = questions;
            this.completed = completed;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static UnitWrapper getUnit(Id unitId){
        Unit__c unit = [SELECT Id, Name, Time_Estimate__c, Points__c,
                        ( SELECT Unit_Completed__c,  
                        TriesNumber__c 
                        FROM Unit_Responses__r 
                        WHERE Module_History__r.User__c = :UserInfo.getUserId() 
                        AND Unit__c =: unitId                 
                        ORDER BY TriesNumber__c 
                        DESC LIMIT 1)
                        FROM Unit__c 
                        WHERE Id =: unitId ];

        Boolean completed = false;               

        Unit__c unitAux = new Unit__c(Id = unit.Id, Name = unit.Name, 
                                    Time_Estimate__c = unit.Time_Estimate__c, 
                                    Points__c = unit.Points__c                             

                                    );
        if(!unit.Unit_Responses__r.isEmpty()){
            if(unit.Unit_Responses__r[0].Unit_Completed__c){
                completed = true;
            }     
        }
        
        List<Question__c> questions = [SELECT Id, Name, Content__c,(SELECT Id, Name, Description__c, IsCorrect__c FROM Options__r)
                                      FROM Question__c
                                      WHERE Unit__c =: unitId
                                      ];
        
        return new UnitWrapper(unitAux, questions, completed);
    }

}

 
                