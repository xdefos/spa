/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG02_DelegueEnqueteurHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG02_DelegueEnqueteurHandlerTest {
    
    @IsTest
    static void setGeolocationTest() {
        DelegueEnqueteur__c de = new DelegueEnqueteur__c();
        de.Adresse__c='15 rue des Poiriers Gris';
        de.Ville__c='Menucourt';
        de.CodePostal__c='95180';
        de.Geolocation__Latitude__s=44.8019097;
        de.Geolocation__Longitude__s=-0.6488505;

        Test.startTest();
            	insert de;
        Test.stopTest();
        
    }
}