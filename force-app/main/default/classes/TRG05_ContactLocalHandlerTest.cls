/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG03_VisitePostAdoptionHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG05_ContactLocalHandlerTest {
    
    @IsTest
    static void setObjectFieldsTest() {
        
        Acteur__c a = new Acteur__c();
        a.Name = 'acteurName';
        insert a;
        
        ContactLocal__c cl = new ContactLocal__c();
        cl.Name='testName';
        cl.Ville__c = 'Paris';
        cl.Acteur__c = a.Id;
        
       
        Test.startTest();
            	insert cl;
        Test.stopTest();
        
    }
}