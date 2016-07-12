public class CreateActivationRequestExtension{
    public final Account parent{get;set;}
    private final String ERR_MSG = 'Record must be submitted to a different user';
    private final String INVALID_USER_ERROR = 'Sorry! You are not authorized to submit request here.';
    public US_Activation_Request__c theActReq {get; set;}
    public String lastError {get; set;}
    public String status{get;set;}
    public Boolean flag{get;set;}
    public Date selectedDate{get;set;}
    public DateTime demo{get;set;}
    public Time selectedTime{get;set;}
    public List<AccountTeamMember> lstActTeamMember;
    set<String> accTeamMembers = new set<String>();
    public CreateActivationRequestExtension(ApexPages.StandardController controller) {
        controller.addFields(new string[] {'OwnerId'});
        parent = (Account) controller.getRecord();
       // selectedDate = 'abc';
        init();
    }
    
    public void init() {
        flag = false;
        theActReq = new US_Activation_Request__c();
        //logic for point 2
        theActReq.Account__c = parent.id;
        lastError = '';
        autoFillAssignedTo();
    }
    public void autoFillAssignedTo() {
        lstActTeamMember = new List<AccountTeamMember>();
        system.debug('parentId:: '+parent.id);
        String assignId = '';
        selectedDate = system.today();
        selectedTime = system.now().time();
        for(AccountTeamMember actTeamMem : [SELECT UserId, TeamMemberRole
                                            FROM AccountTeamMember 
                                            WHERE AccountId =: parent.id
//                                            AND (TeamMemberRole = 'BAM' OR TeamMemberRole = 'TAM')
                                            order by LastModifiedDate desc]) {
          lstActTeamMember.add(actTeamMem);
          accTeamMembers.add(actTeamMem.userId);
          if(assignId == '' && (actTeamMem.TeamMemberRole == 'BAM' || actTeamMem.TeamMemberRole == 'TAM'))    assignId = actTeamMem.userId;
        }
        if(assignId != '')  theActReq.Assigned_To__c = assignId;
    } 
   
    public void createActReq() {
    	system.debug('Flag 1: ' + flag);
        system.debug('selecteddate : ' + selectedDate);
        flag = false;
        status = 'In Progress';
        if(lstActTeamMember.size() > 0 ) {
            if(theActReq.Assigned_To__c == userInfo.getUserId()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ERR_MSG));
            }/*DN - commented out - we want to allow any user with sharing access of write on the account to perform action
              *  else if(!accTeamMembers.contains(userInfo.getUserId())) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, INVALID_USER_ERROR));
            } /*else if(selectedDate == null || selectedTime == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Activation Date and Time'));
            }*/ else {
 //                 theActReq.Assigned_To__c = lstActTeamMember.get(0).UserId;
 system.debug('Flag 2: ' + flag);
                  system.debug('atm:: '+lstActTeamMember.get(0).UserId);
                  system.debug('assignedTo:: '+theActReq.Assigned_To__c);
                  system.debug('.OwnerId:: '+parent.OwnerId);
                  system.debug('theActReq:: '+theActReq);
                  //logic for point 3
                  if(parent.OwnerId != lstActTeamMember.get(0).UserId) {
                    try {
                    	system.debug('Flag 3: ' + flag);
                    	
                    	DateTime tempDate = DateTime.newInstance(selectedDate, selectedTime);
                    	
                    	theActReq.Activation_Date_Time__c = tempDate;
                    	
                      insert theActReq;
                      system.debug('Flag 4: ' + flag);
                      flag = true;
 system.debug('Flag 4: ' + flag);
                      callApprovalProcess(theActReq, lstActTeamMember.get(0).UserId);
                      
                      system.debug('Flag 5: ' + flag);
 //                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Account Request submitted successfully.'));
                      redirect();
 //                     init();
                    }catch(Exception ex) { system.debug('Exception on insert of US_Activation_Request__c'); }
                    
                  }
                  
                }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, INVALID_USER_ERROR));
        }
    }
    
    public PageReference redirect() {
        flag = true;
        system.debug('Flag 6: ' + flag);
/*        PageReference acctPage = new ApexPages.StandardController(parent).view();

        acctPage.setRedirect(true);

        return acctPage;
*/
        return null;
        /*PageReference nextPage = new PageReference('/' + parent.id);
                        // nextPage.setRedirect(true);
                        return nextPage;*/
    }
    private void callApprovalProcess(US_Activation_Request__c activationRequestRecord, Id userId) {
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(activationRequestRecord.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Activation_Request_Approval');
        req1.setSkipEntryCriteria(false);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        system.debug('App Process result:: '+result);
    }
    
    private void createNewActReq() {      
        try {
            //insert theActReq;
            /*
            FeedItem post = new FeedItem();
            post.ParentId = ApexPages.currentPage().getParameters().get('id');
            post.Body = 'created a case';
            post.type = 'LinkPost'; 
            post.LinkUrl = '/' + theAccount.id;
            post.Title = theAccount.Subject;
            insert post;*/
        } catch(System.Exception ex){
            lastError = ex.getMessage();
        }
    }  
}