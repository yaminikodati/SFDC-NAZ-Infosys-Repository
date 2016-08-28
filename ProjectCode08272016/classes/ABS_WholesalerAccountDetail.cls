/*Apex class:ABS_WholesalerAccountDetail 
Description:This class is developed to display wholesalers records and the related 
Poc's records on the ABS_WholesalerAccountDetail Page
This Controller is used in ABS_WholesalerAccountDetail Page
Created By :Deepthi Toranala
Created Date:5/30/2016
Modified Date:
Modified By:
*/
public class ABS_WholesalerAccountDetail {
    public user currentuser;// holds the current user 
    public decimal alat;//holds the navigation lat 
    public decimal along;//holds the navigation lat 
    public list<Account> AccountList;// hold the list of wholesaler records
    public double lat = null;// holds the current user lat 
    public double lon = null; //holds the current user long
    public list<Account> relatesPOCAccounts {get;set;}// holds list of POC account records
    public list<wrapperList> lstWrap{get;set;} // Wraper object holds the map data
    public Account mainAccount{get;set;} // hold wholesaler record
    public decimal geolat{get;set;} // wholesaler lat value
    public decimal geolong{get;set;} // wholesaler long value 
    public map<string,AccountTargetWrapper> mapAccWrap{get;set;}
    public string ChkMapKey{get;set;}//Hold Map string to compare on vf page
    public String JsonMap{get;set;}// holds the json for map pointers
    public string JsonPointerColor{get;set;}//holds the Json Pointer Color
    public list<Account> myRetailers{get;set;}//holds Accounts of with poc recordtype where logged in user is an account Team member
    public map<id,string> mapPinColor{get;set;}
    
    // constrcutor
    public ABS_WholesalerAccountDetail()
    {
        system.debug('test');
        ControllerHelper();
    }
    
    // constructor Helper class
    Public Void ControllerHelper()
    {
        currentuser=new User();// intialize
        lat=0;
        lon=0;
        relatesPOCAccounts = new list<Account>();// intialize
        // query to the get logged in user's latitude and longtitude.
        currentuser=[Select Id,Name,Email,Latitude,Longitude from User where Id=:userinfo.getuserId()];
        // Assign the lat and long values
        if(currentuser != null)
        {
            if(currentuser.Latitude != null)
            {
                lat=currentuser.Latitude;
                lon=currentuser.Longitude;
            }
        }
    }
    
    // Call the Map Helper method.
    public PageReference myActionInController()
    {
        mapHelper();
        return null ;
    }

    // Method which populates the data for displaying map
    Public void mapHelper()
    {
        set<id> relatedIds = new set<id>();
        geolat=decimal.valueof(Apexpages.currentPage().getParameters().get('firstParam'));
        geolong=decimal.valueof(Apexpages.currentPage().getParameters().get('secondParam'));
        system.debug(geolat);
        system.debug(geolong);
        ControllerHelper();
        // assigning geo locations
        if(geolat !=null && geolong !=null && (geolat !=0 && geolong !=0))
        {
            alat=geolat;
            along=geolong;
        }else 
        {
            alat=lat;
            along=lon;
        }
        system.debug(alat+along);
        AccountList = new list<Account>(); 
        // query to retrive wholesaler account record      
        if(alat !=null && along!= null)
        {
           AccountList =[SELECT Id,Name,BillingLongitude,BillingLatitude,BillingStreet,BillingState,WSLR_NBR_US__c,
                         Phone,BillingCity,BillingCountry,BillingPostalCode,buzz_retail__lon__c,buzz_retail__lat__c
                         FROM Account WHERE recordtype.Name = 'Wholesaler' And (BillingLatitude!= null And BillingLatitude!= 0) 
                         and DISTANCE(Location__c, GEOLOCATION(:alat,:along), 'mi') < 1000 
                         ORDER BY DISTANCE(Location__c, GEOLOCATION(:alat,:along), 'mi') ASC LIMIT 1];
                                  
        }
        lstWrap = new  list<wrapperList>(); // intialize
        if(AccountList.size() > 0 )
        {
            mainAccount= new Account();// intialize
            if(AccountList.get(0)!= null ) 
            {
                 mainAccount=AccountList.get(0);
            }
            system.debug('mainAccount==='+mainAccount);
            
        }
        //reteriving the related POC records
        relatesPOCAccounts.clear();
        if(mainAccount != null)
        {
             relatesPOCAccounts=[SELECT Id,Name,BillingLongitude,BillingPostalCode,RTL_SEG_NM_US__c,WSLR_NBR_US__c,CORP_ON_OFF_PREMIS_CD_US__c,
                                  BillingLatitude,BillingStreet,BillingState,Phone,BillingCity,BillingCountry,buzz_retail__lon__c,buzz_retail__lat__c
                                  FROM Account WHERE Wholesaler__c = :mainAccount.id And (BillingLatitude!= null or BillingLatitude!= 0) AND recordtype.Name = 'POC' 
                                  and Account_Targets_Count__c >0 and DISTANCE(Location__c, GEOLOCATION(:alat,:along), 'mi') < 1000 
                                  ORDER BY DISTANCE(Location__c, GEOLOCATION(:alat,:along), 'mi') ASC LIMIT 20 ]; 
                                    
        }
        system.debug(relatesPOCAccounts+'relatesPOCAccounts');
        if(relatesPOCAccounts.size() >0)
        {
              for(Account rAcc:relatesPOCAccounts)
              {
                  relatedIds.add(rAcc.id);
              }
        }
        // buliding up the map data
        if(mainAccount != null)
        {
              wrapperList locationWrapperrec = new wrapperList(mainAccount.BillingLatitude,mainAccount.BillingLongitude,mainAccount.Name.replace('\'','\\\''),mainAccount.Billingstate,mainAccount.Billingcity,mainAccount.Billingstreet,mainAccount.Billingcountry,mainAccount.BillingPostalCode,'blue-dot.png',true,'https://naz--nazsapapp1.cs16.my.salesforce.com/'+mainAccount.id,mainAccount.id);
              lstWrap.add(locationWrapperrec);
              system.debug(lstWrap+'lstWrap');
        }
        
        // buliding up the map data
        if(relatesPOCAccounts.size()>0)
        {
              for(integer i=0;i<relatesPOCAccounts.size();i++)
              {
                  wrapperList locationWrapperrec = new wrapperList(relatesPOCAccounts[i].BillingLatitude,relatesPOCAccounts[i].BillingLongitude,relatesPOCAccounts[i].Name.replace('\'','\\\''),'','','','','','green-dot.png',false,'/apex/ABS_PocAccountDetaiLPage?id='+relatesPOCAccounts[i].id,relatesPOCAccounts[i].id);
                  lstWrap.add(locationWrapperrec );
                  system.debug(lstWrap+'lstWrap');
              }
        }
        // Mapping of accTarget
        list<US_Account_Target_Program__c> accTarget =[select Achieved_Targets__c,Count_of_SKUs__c,Program_Target_Level__c,Account__c,Brand_Category__c from US_Account_Target_Program__c where Account__c In :relatedIds and Brand_Category__c  IN('CORE','HE','High End','ALNR','DRFT','FMB')];
        map<id,list<US_Account_Target_Program__c>> mapUsTarget = new map<id,list<US_Account_Target_Program__c>>();
        // Creating Map for  US_Account_Target_Program__c
        if(accTarget.size() > 0) 
        {         
              for(US_Account_Target_Program__c us:accTarget )
              {
                  if(mapUsTarget.containsKey(us.Account__c)) 
                  {
                      List<US_Account_Target_Program__c> accProgram= mapUsTarget.get(us.Account__c);
                      accProgram.add(us);
                      mapUsTarget.put(us.Account__c, accProgram);
                  }else {
                      mapUsTarget.put(us.Account__c, new List<US_Account_Target_Program__c> {us});
                  }
              }
          }
          mapAccWrap = new  map<string,AccountTargetWrapper>();// initialize
          // building up sap score functionality
          if(mapUsTarget.size() >0)
          {
              for(id recId:mapUsTarget.keyset())
              {
                  List<US_Account_Target_Program__c> lstAccProgram = new List<US_Account_Target_Program__c>();
                  if(!mapUsTarget.isEmpty() && mapUsTarget.get(recId) != null)
                  {
                      lstAccProgram =mapUsTarget.get(recId);
                      if(!lstAccProgram.isEmpty() && lstAccProgram.size()>0)
                      {
                          string core='';
                          string highEnd='';
                          string fmb='';
                          string ALNR='';
                          string DRFT='';
                          boolean iscore=false;
                          boolean isALNR=false;
                          id accountId;
                          string colorCore;
                          string colorHighEnd;
                          string colorFmb;
                          string colorALNR;
                          string colorDRFT;
                          string pgmCore;
                          string pgmHighEnd;
                          string pgmFmb;
                          string pgmALNR;
                          string pgmDRFT;
                          for(US_Account_Target_Program__c objAccProgram:lstAccProgram)
                          {
                              if(objAccProgram.Brand_Category__c=='CORE')
                              {
                                 core=objAccProgram.Achieved_Targets__c+'/'+objAccProgram.Count_of_SKUs__c;
                                 accountId=objAccProgram.Account__c;
                                 iscore=true;
                                 isALNR=false;
                                 colorCore=accountColor(integer.valueof(objAccProgram.Achieved_Targets__c),integer.valueof(objAccProgram.Program_Target_Level__c));
                                 pgmCore=string.valueof(objAccProgram.Program_Target_Level__c);
                              
                              }
                              if(objAccProgram.Brand_Category__c=='HE' || objAccProgram.Brand_Category__c=='High End')
                              {
                                  highEnd=objAccProgram.Achieved_Targets__c+'/'+objAccProgram.Count_of_SKUs__c;
                                  accountId=objAccProgram.Account__c;
                                  iscore=true;
                                  isALNR=false;
                                  colorHighEnd=accountColor(integer.valueof(objAccProgram.Achieved_Targets__c),integer.valueof(objAccProgram.Program_Target_Level__c));
                                  pgmHighEnd=string.valueof(objAccProgram.Program_Target_Level__c);
                              
                              }
                              if(objAccProgram.Brand_Category__c=='FMB')
                              {
                                  fmb=objAccProgram.Achieved_Targets__c+'/'+objAccProgram.Count_of_SKUs__c;
                                  accountId=objAccProgram.Account__c;
                                  iscore=true;
                                  isALNR=false;
                                  colorFmb=accountColor(integer.valueof(objAccProgram.Achieved_Targets__c),integer.valueof(objAccProgram.Program_Target_Level__c));
                                  pgmFmb=string.valueof(objAccProgram.Program_Target_Level__c);
                              
                              }
                              if(objAccProgram.Brand_Category__c=='ALNR')
                              {
                                  ALNR=objAccProgram.Achieved_Targets__c+'/'+objAccProgram.Count_of_SKUs__c;
                                  isALNR=true;
                                  iscore=false;
                                  colorALNR=accountColor(integer.valueof(objAccProgram.Achieved_Targets__c),integer.valueof(objAccProgram.Program_Target_Level__c));
                                  pgmALNR=string.valueof(objAccProgram.Program_Target_Level__c);
                              
                              }
                              if(objAccProgram.Brand_Category__c=='DRFT')
                              {
                                  DRFT=objAccProgram.Achieved_Targets__c+'/'+objAccProgram.Count_of_SKUs__c;
                                  accountId=objAccProgram.Account__c;
                                  iscore=false;
                                  isALNR=true;
                                  colorDRFT=accountColor(integer.valueof(objAccProgram.Achieved_Targets__c),integer.valueof(objAccProgram.Program_Target_Level__c));
                                  pgmDRFT=string.valueof(objAccProgram.Program_Target_Level__c);
                              }
                            
                          }
                          if((iscore || isALNR) && lstAccProgram.size()>0 )
                          {
                              AccountTargetWrapper objTraWrap = new AccountTargetWrapper();
                              if(iscore)
                              {
                                    if(highEnd==''){
                                        objTraWrap.HighEnd ='0/0';
                                        objTraWrap.colorHighEnd='Redcircle';
                                        objTraWrap.pgmHighEnd='0';
                                    }else{
                                        objTraWrap.HighEnd=highEnd;
                                        objTraWrap.colorHighEnd=colorHighEnd;
                                        objTraWrap.pgmHighEnd=pgmHighEnd;
                                    }
                                    if(FMB==''){
                                        objTraWrap.FMB ='0/0';
                                        objTraWrap.colorFmb='Redcircle';
                                        objTraWrap.pgmFmb='0';
                                    }else{
                                        objTraWrap.FMB=FMB;
                                        objTraWrap.colorFmb=colorFmb;
                                         objTraWrap.pgmFmb=pgmFmb;
                                    }
                                    if(Core==''){
                                        objTraWrap.Core ='0/0';
                                        objTraWrap.colorCore='Redcircle';
                                        objTraWrap.pgmCore='0';
                                    }else{
                                        objTraWrap.Core=Core;
                                        objTraWrap.colorCore=colorCore;
                                        objTraWrap.pgmCore=pgmCore;

                                    }
                              }
                              if(isALNR)
                              {
                                    if(DRFT==''){
                                        objTraWrap.DRFT='0/0';
                                        objTraWrap.colorDRFT='Redcircle';
                                        objTraWrap.pgmDRFT='0';
                                    }else{
                                        objTraWrap.DRFT=DRFT;
                                        objTraWrap.colorDRFT=colorDRFT;
                                        objTraWrap.pgmDRFT=pgmDRFT;
                                    }
                                    if(ALNR=='')    {
                                        objTraWrap.ALNR='0/0';
                                         objTraWrap.colorALNR='Redcircle';
                                         objTraWrap.pgmALNR='0';
                                    }else{
                                        objTraWrap.ALNR=ALNR;
                                        objTraWrap.colorALNR=colorALNR;
                                        objTraWrap.pgmALNR=pgmALNR;
                                    }
                              }
                              objTraWrap.isCore =iscore;
                              objTraWrap.id=recId;
                              objTraWrap.isALNR =isALNR;
                              mapAccWrap.put(recId,objTraWrap);
                              lstAccProgram.clear();
                          }
                      } 
                  } 
              }
          }
          // converting mapkey into string
          ChkMapKey = '';
          if(mapAccWrap.size() > 0)
          {
              for(string strKey : mapAccWrap.keyset()){
                   ChkMapKey+=strKey;
              }
          }
          // Converting the map key into jsonstring
          JsonMap=JSON.serialize(mapAccWrap);
          myRetailer();
          mapPinColor = new map<id,string>();
          for(AccountTargetWrapper accWrap:mapAccWrap.values())
    	  {
    	  	system.debug(accWrap);
    	  	string pinColor='';
    	  	if(accWrap.isCore==true){
    	  		if(accWrap.colorCore=='Greencircle' &&  accWrap.colorFmb=='Greencircle' && accWrap.colorHighEnd=='Greencircle' )
    	  		{
    	  			pinColor='green-dot.png';
    	  			
    	  		}else if(accWrap.colorCore=='Redcircle' &&  accWrap.colorFmb=='Redcircle' && accWrap.colorHighEnd=='Redcircle')
    	  		{
    	  			pinColor='red-dot.png';
    	  		}else{
    	  			pinColor='yellow-dot.png';
    	  		}
    	  		mapPinColor.put(accWrap.id,pinColor);
    	  	}else if(accWrap.isALNR==true)
    	  	{
    	  		if(accWrap.colorDRFT=='Greencircle' &&  accWrap.colorALNR=='Greencircle')
    	  		{
    	  			pinColor='green-dot.png';
    	  			
    	  		}else if(accWrap.colorDRFT=='Redcircle' &&  accWrap.colorALNR=='Redcircle')
    	  		{
    	  			pinColor='red-dot.png';
    	  		}else
    	  		{
    	  			pinColor='yellow-dot.png';
    	  		}
    	  		mapPinColor.put(accWrap.id,pinColor);
    	  	}
    	  	
    	  }
    	  JsonPointerColor=JSON.serialize(mapPinColor);
    }
    public string accountColor(Integer Achieved_Targets,Integer Program_Target_Level)
    {
         string color='';
         if(Achieved_Targets >=  Program_Target_Level)
         {
            color='Greencircle';
         }else if((Achieved_Targets > 0 ) &&  (Achieved_Targets  < Program_Target_Level))
         {
            color='Yellowcircle';
         }else if(Achieved_Targets == 0)
         {
            color='Redcircle';
         }
         return color;
    }
    public void myRetailer()
    {
    	myRetailers= new list<Account>();     
        List<AccountTeamMember> accMembers = new List<AccountTeamMember>();
        Set<Id> accountIds = new Set<Id>();
		if(mainAccount != null)   
		{
			accMembers = [SELECT Id,AccountId FROM AccountTeamMember WHERE  UserId = :userinfo.getuserId() 
	                      and AccountTeamMember.Account.Type = 'POC' and 
	                      AccountTeamMember.Account.Wholesaler__c=:mainAccount.id];
		}
        system.debug(accMembers);
        if(!accMembers.isEmpty())
        {
            for(AccountTeamMember member : accMembers) 
            {
                accountIds.add(member.AccountId);
            }
        }
        if(!accountIds.isEmpty())
        {
        	if(lat != 0 && lon != 0 )
            myRetailers = [SELECT Id,Name,BillingLongitude,BillingPostalCode,RTL_SEG_NM_US__c,WSLR_NBR_US__c,CORP_ON_OFF_PREMIS_CD_US__c,
                           BillingLatitude,BillingStreet,BillingState,Phone,BillingCity,BillingCountry,buzz_retail__lon__c,buzz_retail__lat__c
                           FROM Account WHERE Wholesaler__c=:mainAccount.id and Id IN :accountIds And (BillingLatitude!= null And BillingLatitude!= 0) 
                           and DISTANCE(Location__c, GEOLOCATION(:lat,:lon), 'mi') < 1000  ORDER BY DISTANCE(Location__c, GEOLOCATION(:lat,:lon), 'mi') ASC limit 20];
        }
    }
    
   
   // Wrapper class to build up map data 
    public class wrapperList
    {
       public decimal lat{get;set;}
       public decimal lng{get;set;}
       public string name{get;set;}
       public string address1{get;set;}
       public string address2{get;set;}
       public string address3{get;set;}
       public string address4{get;set;}
       public string postalCode{get;set;}
       public string colormap{get;set;}
       public boolean isMain{get;set;}
       public string url{get;set;}
       public string recordId{get;set;}
       
       public wrapperList(decimal lat,decimal lng, string name,string address1,string address2,string address3,string address4,string postalCode,string colormap,boolean isMain,string url,string recordId)
       {
           this.lat=lat;
           this.lng=lng;
           this.name=name;
           this.address1 =address1;
           this.address2 =address2;
           this.address3 =address3;
           this.address4 =address4;
           this.postalCode=postalCode; 
           this.colormap=colormap;
           this.isMain=isMain;
           this.url=url;
           this.recordId=recordId;
       }
    }
    
    // Sap score wrapper class.
    public class AccountTargetWrapper
    {
       public boolean isCore {get;set;}
       public boolean isALNR {get;set;}
       public string  id {get;set;}
       public string Core {get;set;}
       public string HighEnd {get;set;}
       public string FMB {get;set;}
       public string ALNR{get;set;}
       public string DRFT{get;set;}
       public string colorCore{get;set;}
       public string colorHighEnd{get;set;}
       public string colorFmb{get;set;}
       public string colorALNR{get;set;}
       public string colorDRFT{get;set;}
       public string pgmCore{get;set;}
       public string pgmHighEnd{get;set;}
       public string pgmFmb{get;set;}
       public string pgmALNR{get;set;}
       public string pgmDRFT{get;set;}
    }
    
}