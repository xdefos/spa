@IsTest
public with sharing class CMP02_EligibilityDEControllerTest {
    @IsTest
    static void getEligibilityDE() {
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
        insert e;

        Enquete__c e2 = new Enquete__c();
        e2.Adresse__c='15 rue des Poiriers Gris';
        e2.Ville__c='Menucourt';
        e2.CodePostal__c='95180';
        e2.Geolocation__Latitude__s=44.8019097;
        e2.Geolocation__Longitude__s=-0.6488505;
        e2.Statut__c = 'En cours';
        e2.DelegueEnqueteurReferent__c = de.Id;
        e2.SignalementOrigine__c = s.Id;
        System.debug(e2);
        insert e2;
        System.debug(e2);
        Test.setMock(HttpCalloutMock.class, new UTI03_WSMock(200, '{"rows":[{"elements":[{"distance":{"text":"test","value":"120"}},{ "distance":{"text":"test","value":"130"}}]}]}'));

        Test.startTest();
        CMP02_EligibilityDEController.getEligibilityDE(e.Id, 50, 20);
        Test.stopTest();
    }
}