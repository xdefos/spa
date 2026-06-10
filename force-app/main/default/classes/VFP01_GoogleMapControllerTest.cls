/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for VFP01_GoogleMapController
* @group Tests 
*/

@IsTest
public with sharing class VFP01_GoogleMapControllerTest {
    
    @IsTest
    static void paramsTest() {
        ParametreGoogleMap__c p = new ParametreGoogleMap__c();
        p.Name					= 'Toutes les Enquêtes';
        p.AffichageDefaut__c	= true;
        p.RequeteSOQL__c		= 'SELECT Name, Signalement__c, Especes__c FROM Enquete__c';
        p.Icone__c				= 'https://developers.google.com/maps/documentation/javascript/examples/full/images/info-i_maps.png';
        p.ChampsTitre__c		= '{Name}';
        p.ChampsDescription__c	= '{Signalement__c} <BR> {Especes__c}';
        insert p; 

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
        e.SignalementOrigine__c = s.Id;
        insert e;

        Test.startTest();
        		VFP01_GoogleMapController ctrl = new VFP01_GoogleMapController();
            	List<ParametreGoogleMap__c> params = ctrl.params;
            	String paramsJSON = ctrl.paramsJSON;
            	String geolocByParamId = ctrl.geolocByParamId;
        Test.stopTest();
        
    }
}