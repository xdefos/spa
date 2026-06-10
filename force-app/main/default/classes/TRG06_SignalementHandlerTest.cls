/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG03_VisitePostAdoptionHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG06_SignalementHandlerTest {
    
    @IsTest
    static void setObjectFieldsTest() {
        Signalement__c a = new Signalement__c();
        a.Name='sd@sdf.com';
        a.Adresse__c='15 rue des Poiriers Gris';
        a.Ville__c='Menucourt';
        a.CodePostal__c='95180';
        a.Geolocation__Latitude__s=44.8019097;
        a.Geolocation__Longitude__s=-0.6488505;
       
        Test.startTest();
            	insert a;
        Test.stopTest();
        
    }
}