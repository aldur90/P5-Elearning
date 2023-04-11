public class TrailWrapper {

    @AuraEnabled
    public Trail__c trail {get; set;}
    @AuraEnabled
    public List<Module__c> modules {get; set;}
    @AuraEnabled
    public Set<Id> passedModuleIds {get; set;}
    @AuraEnabled
    public Set<Id> passedUnitIds {get; set;}
    @AuraEnabled
    public Integer progressTrail {get; set;}

    //private Id trailId;

    public TrailWrapper(Trail__c trail, List<Module__c> modules, Set<Id> passedModuleIds, Set<Id> passedUnitIds) {
        this.trail = trail;
        this.modules = modules;
        this.passedModuleIds = passedModuleIds;
        this.passedUnitIds = passedUnitIds;
    }

    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId){
    TrailWrapper trailWrap = new TrailWrapper([
                                                  SELECT Name, 
                                                  Description__c, 
                                                  Points__c,
                                                  Time_Estimated__c
                                                  FROM Trail__c 
                                                  WHERE Id =: trailId
                                                  
                                                  ],
         getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));
        
        return trailWrap;
    }
    
    private static List<Module__c> getModules(Id trailId){
    	Set<Id> moduleIds = new Set<Id>();

        List<TrailModule__c> trailModules = [
            SELECT Module__c
            FROM TrailModule__c
            WHERE Trail__c =: trailId
        ];

        for (trailModule__c trailModule: trailModules){
            moduleIds.add(trailModule.Module__c);
        }

        return [SELECT Name,Total_Time_Estimate__c, Points__c, (SELECT Name, Points__c, Time_Estimate__c FROM Units__r) FROM Module__c WHERE Id in : moduleIds];
    }
    
    private static Set<Id> getModuleIdsCompleted(Id trailId){
    	List<Module_History__c> moduleHistories = [
            										SELECT Module__c
            										FROM Module_History__c
            										WHERE Status__c = 'Completed' AND 
                									Module__c in : getModules(trailId) AND
                									User__c =: UserInfo.getUserId()
        											];

        Set<Id> completedModuleIds = new Set<Id>();
        for (Module_History__c moduleHistory : moduleHistories) {
            completedModuleIds.add(moduleHistory.Module__c);
        }
        return completedModuleIds;
    }
    
    
    private static Set<Id> getUnitIdsCompleted(Id trailId){
    	List<Unit_History__c> unitHistories = [
        										SELECT Unit__c
        										FROM Unit_History__c
        										WHERE Unit_Completed__c = true AND 
        										Unit__r.Module__c in : getModules(trailId) AND
        										Module_History__r.User__c =: UserInfo.getUserId()
        										];
		Set<Id> completedUnitIds = new Set<Id>();
        for (Unit_History__c unitHistory : unitHistories) {
        completedUnitIds.add(unitHistory.Unit__c);
        }
        
        return completedUnitIds;
    }
    
    
}