public class ModuleHistoryTrigger {
    
    private Map<Id, User> userMap;
	
    public void onAfterUpsert(List<Module_History__c> moduleHistories) {    
        this.setUsers();
        this.clean();
        this.sumTotalPointPerModule(moduleHistories);      
        update userMap.values();       
    }
    
    private void setUsers() {
        userMap = new Map<Id, User>([
            SELECT Id, Total_Points__c
            FROM User
        ]);
    }
    
    private void clean() {
        for(User currentUser: userMap.values()) {
            currentUser.Total_Points__c = 0;
        }
    }
    
    private void sumTotalPointPerModule(List<Module_History__c> moduleHistories) {
        for(Module_History__c moduleHistory:  moduleHistories) {
            Id userId = moduleHistory.User__c;
            User currentUser = userMap.get(userId);
            currentUser.Total_Points__c += moduleHistory.Total_Points__c;
            userMap.put(userId, currentUser);  
        }
    }
    
    
}