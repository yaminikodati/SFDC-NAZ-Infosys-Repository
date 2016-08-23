@isTest
private class TestAB_UpdateLocationTrigger {

    static testMethod void testMe() {
        Account objAcc= new Account();
        objAcc.Name='TestAccount';
        //objAcc.RecordTypeId=WsRecId;
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
        
        objAcc.BillingLatitude=39.830121;
        objAcc.BillingLongitude=-104.950731;
        update objAcc;
    }
}