// 
// (c) 2016 Appirio, Inc.
//
// Controller class for HE_ClientSideGoogleLocationAPI VF Page
//
// 08 June 2016     Gagandeep Kaur     Original - T-508006 : Controller Class For HE_ClientSideGoogleLocationAPI VF Page
// 09 June 2016    Gagandeep Kaur                 T-510044 : Create Toggle for display of 'All Accounts' vs 'My Accounts'
//
public class HE_ClientSideGoogleLocationAPI {
    
    public List<SelectOption> DistanceOptions {get;set;}
    public List<SelectOption> DistUnitOptions {get;set;}
    
    public String selectedDist {get;set;}
    public String selectedDistUnit {get;set;}
    
    public string latitude {get;set;}
    public string longitude {get;set;}
    
    public List<AccountWrapper> accountWrapperList {get;set;}
    
    public HE_ClientSideGoogleLocationAPI () {
        String distances = '0.5,1,2,5,10,15,20,25,50,100,500';
        string units = 'Miles:mi,Kilometers:km';
        accountWrapperList = new List<AccountWrapper>();
        DistanceOptions = populateList(distances) ;
        DistUnitOptions = populateList(units);
        selectedDist = '1';
        selectedDistUnit = 'mi';
        system.debug('selectedDist' + selectedDist + 'selectedDistUnit' + selectedDistUnit);
    }
    
    private List<SelectOption> populateList(String csValues) {
        List<SelectOption> options = new List<SelectOption>();
        for(String str : csValues.split(',')) {
            string label ='';
            string value = '';
            if(str.indexOf(':') > -1) {
                label =  str.split(':')[0];
                value = str.split(':')[1];
            } else {
                label = value = str ;
            }
            options.add(new SelectOption(value,label));
        }
        return options ;
    }
    
    @RemoteAction
    public static List<Account> getNearbyAccounts(Decimal latitude, Decimal longitude, String dist, String unit) {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :userInfo.getUserId()].Profile.Name;
        String q = '';
        if(profileName == 'System Administrator') {
            q = 'select Id, Name, Phone, BillingLatitude, BillingLongitude, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry from Account ';
            q += 'where BillingLatitude != null AND BillingLongitude != null and  DISTANCE(BillingAddress, GEOLOCATION( ';  //like \'%TORONTO\'
            q += String.valueOf(latitude) + ', ' + String.valueOf(longitude);
            q += ' ), \''+unit+'\') <'+Integer.valueOf(dist);
        } else {
            list<UserRole> roles = [SELECT Id From UserRole WHERE ParentRoleId IN (SELECT UserRoleId FROM User WHERE Id = :userInfo.getUserId())];
            set<Id> roleIds = new set<Id>();
            for(UserRole usr : roles) {
                roleIds.add(usr.Id);
            }
            list<User> userList = [SELECT Id FROM User WHERE Id = :userInfo.getUserId() OR UserRoleId IN : roleIds];
            q = 'select Id, Name, Phone, BillingLatitude, BillingLongitude, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry from Account ';
            q += 'where Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId IN :userList) AND ';
            q += ' BillingLatitude != null AND BillingLongitude != null and  DISTANCE(BillingAddress, GEOLOCATION( ';   //like \'%TORONTO\'
            q += String.valueOf(latitude) + ', ' + String.valueOf(longitude);
            q += ' ), \''+unit+'\') <'+Integer.valueOf(dist);
        } 
        system.debug(q);
        list<Account> accList = Database.query(q);
        system.debug(accList); 
        return accList;    
    }
    
    public void fetchNearByAccounts() {
        list<Account> nearByRecords = new list<Account>();
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :userInfo.getUserId()].Profile.Name;
        String q = '';
        system.debug('==========lat '+latitude+'===========lon '+longitude+'========== dist'+selectedDist+'=========unit '+selectedDistUnit);
        if(profileName == 'System Administrator') {
            q = 'select Id, Name, Phone, BillingLatitude, BillingLongitude,BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry from Account ';
            q += 'where BillingLatitude != null AND BillingLongitude != null and  DISTANCE(BillingAddress, GEOLOCATION( ';  //like \'%TORONTO\'
            q += String.valueOf(latitude) + ', ' + String.valueOf(longitude);
            q += ' ), \''+selectedDistUnit+'\') <'+Integer.valueOf(selectedDist);
        } else {
            list<UserRole> roles = [SELECT Id From UserRole WHERE ParentRoleId IN (SELECT UserRoleId FROM User WHERE Id = :userInfo.getUserId())];
            set<Id> roleIds = new set<Id>();
            for(UserRole usr : roles) {
                roleIds.add(usr.Id);
            }
            list<User> userList = [SELECT Id FROM User WHERE Id = :userInfo.getUserId() OR UserRoleId IN : roleIds];
            q = 'select Id, Name, Phone, BillingLatitude, BillingLongitude,BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry from Account ';
            q += 'where Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId IN :userList) AND ';
            q += ' BillingLatitude != null AND BillingLongitude != null and  DISTANCE(BillingAddress, GEOLOCATION( ';   //like \'%TORONTO\'
            q += String.valueOf(latitude) + ', ' + String.valueOf(longitude);
            q += ' ), \''+selectedDistUnit+'\') <'+Integer.valueOf(selectedDist);
        }
            
        system.debug(q);
        nearByRecords = Database.query(q);
        createWrapperList(nearByRecords) ;
    }
    
    private void createWrapperList(List<Account> accList) {
        accountWrapperList = new List<AccountWrapper>();
        Decimal latDoub = Decimal.valueOf(latitude);
        Decimal lonDoub = Decimal.valueOf(longitude);
        string unitCal = 'N';
        if(selectedDistUnit == 'km') unitCal = 'K';
        for(Account acc : accList) {
            decimal distance = getDistance(latDoub,lonDoub,acc.BillingLatitude,acc.BillingLongitude,unitCal);
            AccountWrapper accW = new AccountWrapper(acc,distance);
            accountWrapperList.add(accW);
        }
        system.debug('=========accountWrapperList========'+accountWrapperList);
        system.debug('selectedDist' + selectedDist + 'selectedDistUnit' + selectedDistUnit);
    }
    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*
    @ leadLat : First point's Latitude
    @ leadLon : First point's Longitude
    @ divLat : Second point's Latitude
    @ divLon : Second point's Longitude
    @ Unit : Whether Kilometer,Miles etc. 
    @ This function takes five arguments and return distance between two points
        in provided Unit format.
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    public static decimal getDistance(decimal leadLat, decimal leadLon, decimal divLat, decimal divLon, string unit) {
      
        decimal theta = leadLon - divLon;
        decimal dist = Math.sin(deg2rad(leadLat)) * Math.sin(deg2rad(divLat)) + Math.cos(deg2rad(leadLat)) * Math.cos(deg2rad(divLat)) * Math.cos(deg2rad(theta));
        dist = Math.acos(dist);
        dist = rad2deg(dist);
        dist = dist * 60 * 1.1515;
        if (unit == 'K') {
            dist = dist * 1.609344;
        } else if (unit == 'N') {
            dist = dist * 0.8684;
        }
        system.debug('=========dist======='+dist);    
        return (dist);
    }
    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    @ deg : cordinates in degree
    @  This function converts decimal degrees to radians            
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    private static decimal deg2rad(decimal deg) {
      return (deg * 3.14159 / 180.0);
    }

    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    @ deg : cordinates in radians
    @ This function converts radians to decimal degrees             
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    private static decimal rad2deg(decimal rad) {
      return (rad * 180.0 / 3.14159);
    }   
    public class AccountWrapper {
    
        public Account account {get;set;}
        public decimal distance {get;set;}
        
        public AccountWrapper(Account acc,decimal dist) {
            account = acc ;
            distance = dist ;
        }
    }
}