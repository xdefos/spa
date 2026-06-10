/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for CMP01_GoogleMapController
* @group Tests 
*/

@IsTest
public with sharing class CMP02_SendEmailToDEControllerTest {
    
    @IsTest
    static void getEmailsDETest() {
        DelegueEnqueteur__c de = new DelegueEnqueteur__c();
        de.Email__c = 'Test@test.com';
        de.Adresse__c='15 rue des Poiriers Gris';
        de.Ville__c='Menucourt';
        de.CodePostal__c='95180';
        insert de;

        Test.startTest();
            	CMP02_SendEmailToDEController.getEmailsDE();
        Test.stopTest();
        
    }
}