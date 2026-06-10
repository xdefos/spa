/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG03_VisitePostAdoptionHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG03_VisitePostAdoptionHandlerTest {
    
    @IsTest
    static void setGeolocationTest() {
        VisitePostAdoption__c vpa = new VisitePostAdoption__c();
        vpa.Name='testName';
        vpa.Adresse__c='15 rue des Poiriers Gris';
        vpa.Ville__c='Menucourt';
        vpa.CodePostal__c='95180';
        vpa.Identifiant__c=12345;
        vpa.Geolocation__Latitude__s=44.8019097;
        vpa.Geolocation__Longitude__s=-0.6488505;

        Test.startTest();
            	insert vpa;
        Test.stopTest();
        
    }
}