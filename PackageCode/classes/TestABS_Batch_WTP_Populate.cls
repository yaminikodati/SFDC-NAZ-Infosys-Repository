/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestABS_Batch_WTP_Populate {

    static testMethod void myUnitTest() {

        Id WsRecId = [Select Id, Name from RecordType where name = :label.WholeSaler_RecrdType limit 1].Id;
        Id POCRecId = [Select Id, Name from RecordType where name = :label.POC_RecrdType limit 1].Id;
        Account objAcc= new Account();
        objAcc.Name='TestAccount';
        objAcc.RecordTypeId=WsRecId;
        objAcc.BillingStreet='1455 E 62nd Ave';
        objAcc.BillingCity='Denver';
        objAcc.BillingState='CO';
        objAcc.BillingLatitude=39.810121;
        objAcc.BillingLongitude=-104.970731;       
        objAcc.Phone = '232323454';
        objAcc.BillingCountry = 'USA';
        objAcc.BillingPostalCode='80123';
        objAcc.buzz_retail__lon__c=39.810121;
        objAcc.buzz_retail__lat__c=-104.970731;
        objAcc.WSLR_NBR_US__c='255';
        insert objAcc;
        
        objAcc.Location__Latitude__s = objAcc.BillingLatitude;
        objAcc.Location__Longitude__s = objAcc.BillingLongitude;
        update objAcc;
        
        Account objAcc1= new Account();
        objAcc1.Name='TestAccount1';
        objAcc1.RecordTypeId=POCRecId;
        //objAcc1.ParentId=objAcc.id;
        objAcc1.Wholesaler__c=objAcc.id;
        objAcc1.BillingStreet='1455 E 62nd Ave';
        objAcc1.BillingCity='Denver';
        objAcc1.BillingState='CO';
        objAcc1.BillingLatitude=39.820921;
        objAcc1.BillingLongitude=-104.970531;
        objAcc1.Phone = '232323454';
        objAcc1.BillingCountry = 'USA';
        objAcc1.BillingPostalCode='80123';
        objAcc1.buzz_retail__lon__c=39.810121;
        objAcc1.buzz_retail__lat__c=-104.970731;
        objAcc1.WSLR_NBR_US__c='255';
        insert objAcc1;
        
        objAcc1.Location__Latitude__s = objAcc1.BillingLatitude;
        objAcc1.Location__Longitude__s = objAcc1.BillingLongitude;
        update objAcc1;
        
        Account objAcc2= new Account();
        objAcc2.Name='TestAccount2';
        objAcc2.RecordTypeId=POCRecId;
        objAcc2.Wholesaler__c=objAcc.id;
        objAcc2.BillingStreet='1455 E 62nd Ave';
        objAcc2.BillingCity='Denver';
        objAcc2.BillingState='CO';      
        objAcc2.BillingLatitude=39.830121;
        objAcc2.BillingLongitude=-104.970831;
        objAcc2.Phone = '232323454';
        objAcc2.BillingCountry = 'USA';
        objAcc2.BillingPostalCode='80123';
        objAcc2.buzz_retail__lon__c=39.810121;
        objAcc2.buzz_retail__lat__c=-104.970731;
        objAcc2.WSLR_NBR_US__c='255';
        insert objAcc2;
        
        objAcc2.Location__Latitude__s = objAcc2.BillingLatitude;
        objAcc2.Location__Longitude__s = objAcc2.BillingLongitude;
        update objAcc2;

        
        US_Account_Target_Program__c objAcTrgt6 = new US_Account_Target_Program__c();
        objAcTrgt6.Account__c=objAcc1.id;
        objAcTrgt6.Brand_Category__c = 'FMB';
        objAcTrgt6.Channel__c = 'ONP';
        insert objAcTrgt6;

        US_Account_Target_Program__c objAcTrg6 = new US_Account_Target_Program__c();
        objAcTrg6.Account__c=objAcc2.id;
        objAcTrg6.Brand_Category__c = 'FMB';
        objAcTrg6.Channel__c = 'ONP';
        insert objAcTrg6;

		WSLR_Target_Program__c objWTP = new WSLR_Target_Program__c();
		objWTP.Wholesaler__c=objAcc.id;
		objWTP.Brand_Category__c = 'FMB';
		objWTP.Channel__c = 'ONP';
		insert objWTP; 


		Id batchInstanceId = Database.executeBatch(new ABS_Batch_WTP_Populate ());


       
        
        
    }
}