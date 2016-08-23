global class ABS_Batch_WTP_Populate implements database.Batchable<sobject>{

    /***
    Start method for Querying all the opportunities and return to execute method
    ***/


    public ABS_Batch_WTP_Populate (){

    }

    global database.Querylocator start(database.batchablecontext bc){
      
        string squery ='select id, Account__c, Account__r.Wholesaler__r.id, Brand_Category__c, Channel__c, Wholesaler_Number__c, WSLR_Target_Program__c';
        squery+=' from US_Account_Target_Program__c WHERE WSLR_Target_Program__c  = null order by Account__r.Wholesaler__r.id'; 

        
       if(Test.isRunningTest())
         squery= squery+ ' LIMIT 10';   
       //else
         //squery= squery + ' LIMIT 100';   

     
       system.debug('squery = ' + squery);
        return database.getQuerylocator(squery);
    }


    //Execute method to process all 
    global void execute(database.batchablecontext bc,list<US_Account_Target_Program__c> lstATPs){
        system.debug('lstATPs.size() = ' + lstATPs.size());
        set<id> setWslrs = new set<id>();
        for(US_Account_Target_Program__c iP :lstATPs){
            system.debug('iP.Account__r.Wholesaler__c = ' + iP.Account__r.Wholesaler__c);
            setWslrs.add(iP.Account__r.Wholesaler__c);
        }
        //get the wslr targets for these wslrs
        list<WSLR_Target_Program__c> lstWTPs =[SELECT id, Wholesaler__r.id,Brand_Category__c, Channel__c from WSLR_Target_Program__c where Wholesaler__c in :setWslrs]; 

        //boolean bFound = false;
        for(US_Account_Target_Program__c iATP :lstATPs){
            //bFound = false;
            system.debug('ATP');
            for(WSLR_Target_Program__c iWTP :lstWTPs ){
                system.debug('WTP');
                String BCtranslate = iWTP.Brand_Category__c;
                if(iWTP.Channel__c == 'ONP' && iWTP.Brand_Category__c == 'CORE'){
                    BCtranslate = 'DRFT';
                }
                if (iWTP.Wholesaler__r.id == iATP.Account__r.Wholesaler__r.id &&  BCtranslate == iATP.Brand_Category__c && iWTP.Channel__c== iATP.Channel__c ){
                    iATP.WSLR_Target_Program__c = iWTP.id;
                    system.debug('WTP FOUND');
                    Break;                
                }
            }
        }

        system.debug('update lstATPs');
        update lstATPs;
    }
    
    global void finish(database.batchablecontext bc){}
    
}