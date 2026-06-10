/**
* @author Xavier Defossez
* @date 2019-12-07
* @description  Handler class for Enquete trigger methods
* @group Trigger Handler
*/

public with sharing class TRG01_EnqueteHandler {

    /*******************************************************************************************************
    * @description  Set Geolocation for Enquete
    * @author Xavier Defossez
    * @param List<Enquete__c>, Map<id,Enquete__c>
    * @return void
    */
    
     public static void setEnqueteFields(List<Enquete__c> enquetes, Map<Id,Enquete__c> oldEnquetes) {
    
        Integer offset = 1; //for bulk incremented in for loop
        Decimal numberForThisMonth = Integer.valueOf(system.now().format('YY')) * 100000 + Integer.valueOf(system.now().format('MM')) * 1000;
        Decimal numberForNewYear = Integer.valueOf(system.now().format('YY')) * 100000;

        List<Enquete__c> lastEnqs = [SELECT Id, Number__c FROM Enquete__c WHERE Number__c > :numberForNewYear ORDER BY Number__c DESC]; 
        Integer lastNumber =lastEnqs.isEmpty() ? 0 : Integer.valueOf(String.valueOf(lastEnqs[0].Number__c).right(3));
        
        for(Enquete__c e: enquetes) {
            e.Number__c= numberForThisMonth + lastNumber + offset;
            e.Name = '330-' + system.now().format('YY') + '-' + system.now().format('MM') + '-' + String.valueOf(e.Number__c).right(3);
            offset ++;
        }
    }
}