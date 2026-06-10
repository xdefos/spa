/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG01_EnqueteHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG01_EnqueteHandlerTest {
    
    @IsTest
    static void setEnqueteFieldsTest() {
        DelegueEnqueteur__c de = new DelegueEnqueteur__c();
        de.Adresse__c='15 rue des Poiriers Gris';
        de.Ville__c='Menucourt';
        de.CodePostal__c='95180';
        de.Geolocation__Latitude__s=44.8019097;
        de.Geolocation__Longitude__s=-0.6488505;
        de.Habilitation_Enquete__c = 'Référent';
        insert de;
       
        Signalement__c s = new Signalement__c();
        s.Name='sd@sdf.com';
        s.Adresse__c='15 rue des Poiriers Gris';
        s.Ville__c='Menucourt';
        s.CodePostal__c='95180';
        s.Geolocation__Latitude__s=44.8019097;
        s.Geolocation__Longitude__s=-0.6488505;
        insert s;

        Enquete__c e = new Enquete__c();
        e.Adresse__c='15 rue des Poiriers Gris';
        e.Ville__c='Menucourt';
        e.CodePostal__c='95180';
        e.Geolocation__Latitude__s=44.8019097;
        e.Geolocation__Longitude__s=-0.6488505;
        e.Statut__c = 'En cours';
        e.DelegueEnqueteurReferent__c = de.Id;
        e.SignalementOrigine__c = s.Id;

        

        Test.startTest();
            	insert e;
        Test.stopTest();
        
    }
}