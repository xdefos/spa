/**
* @author Xavier Defossez
* @date 2019-10-01
* @description Test Class for TRG03_VisitePostAdoptionHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG04_AnimalHandlerTest {
    
    @IsTest
    static void setObjectFieldsTest() {
        Animal__c a = new Animal__c();
        a.Name='testName';
        a.Espece__c='Chien';
        a.DateCession__c=date.today();
       
        Test.startTest();
            	insert a;
        Test.stopTest();
        
    }
}