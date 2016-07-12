// 
// (c) 2016 Appirio, Inc.
//
// Handler Class for HE_UserTrigger
//
// 07 May 2016     Gagandeep Kaur         Original : T-503075 : Auto-join Chatter Group where Information includes the Wholesaler Number
//
public class HE_UserTriggerHandler {
    //Future has been used to avoid Mix DML Errors
    @future
    public static void addToChatterGroup(list<Id> userIds){
        List<User> users=[SELECT id, 
                                 Username, 
                                  Wholesaler_Number__c, 
                                 isActive
                                 
                          FROM   User 
                          WHERE id in :userIds];
//        system.debug(users.get(0).Wholesaler_Number__c);
        List<CollaborationGroup> chatterGroupList = new List<CollaborationGroup>();
        chatterGroupList = [SELECT id, InformationTitle 
                              FROM   CollaborationGroup 
                              Order By Name];
         system.debug('chatterGroupList ' + chatterGroupList);
         List<CollaborationGroupMember> groupMemberList = new List<CollaborationGroupMember>();                     
        for(User us: users){
            if(us.Wholesaler_Number__c != null) {
                for(CollaborationGroup chatterGroup: chatterGroupList) {
                    if(!string.isBlank(chatterGroup.InformationTitle) && chatterGroup.InformationTitle.contains('WSLR'+us.Wholesaler_Number__c)) {
                        system.debug('Entered in contains.');
                        CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId=chatterGroup.Id, MemberId = us.Id);
                        groupMemberList.add(member);
                    }
                }
            }
        }
        
        

        if(!groupMemberList.isEmpty()){
        system.debug('size' + groupMemberList.size());
            try{
                insert groupMemberList;      
            }
            catch(Exception e){
            }
        }
    }
}