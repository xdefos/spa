public with sharing class CMP02_SendEmailToDEController {

	@AuraEnabled
    public static String getEmailsDE() {

    	String emails ='';
    	for(DelegueEnqueteur__c de: [SELECT Email__c FROM DelegueEnqueteur__c WHERE AncienDE__c = false]) {
    		if (de.Email__c != null)
    			emails += de.Email__c + '; ';
    	}
    	return emails;
    }
}