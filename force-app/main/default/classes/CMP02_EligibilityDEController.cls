public with sharing class CMP02_EligibilityDEController {
    private static final Integer MAX_BATCH_SIZE = 25;

    @AuraEnabled
    public static List<Item> getEligibilityDE(Id recordId, Integer maxDistanceDE, Integer maxDistanceE) {
        maxDistanceDE = (maxDistanceDE * 1000);
        maxDistanceE = (maxDistanceE * 1000);

        Enquete__c record = [SELECT Id, Geolocation__Latitude__s, Geolocation__Longitude__s FROM Enquete__c WHERE Id = :recordId LIMIT 1];

        Set<Id> enqueteurIds = new Set<Id>();
        Map<Id, SObject> mapAllRecords = new Map<Id, SObject>();
        Map<Integer, Map<Integer, Id>> mapIdByIndexByBatch = new Map<Integer, Map<Integer, Id>>();
        Map<Id, Integer> mapDistanceById = new Map<Id, Integer>();
        List<List<String>> bulkLocationList = new List<List<String>>();
        bulkLocationList.add(new List<String>());
        Integer currentBulkLot = 0;

        for(DelegueEnqueteur__c de : [SELECT Id, Name, EnquetesEnCours__c, EnquetesAnnuel__c, Geolocation__Latitude__s, Geolocation__Longitude__s, CodePostal__c, Ville__c, Adresse__c FROM DelegueEnqueteur__c WHERE Geolocation__Latitude__s != null AND AncienDE__c = false AND Habilitation_Enquete__c IN ('Référent','Référent formateur')]){
            enqueteurIds.add(de.Id);
            String locations = de.Geolocation__Latitude__s + ',' + de.Geolocation__Longitude__s;

            // TODO: To be refactored
            List<String> locationList = bulkLocationList.get(currentBulkLot);

            if(locationList.size() < MAX_BATCH_SIZE){
                locationList.add(locations);
            }else{
                locationList = new List<String>();
                locationList.add(locations);
                bulkLocationList.add(locationList);
                currentBulkLot++;
            }
            if(mapIdByIndexByBatch.get(currentBulkLot) == null)
            mapIdByIndexByBatch.put(currentBulkLot, new Map<Integer,Id>());

            mapIdByIndexByBatch.get(currentBulkLot).put(locationList.indexOf(locations), de.Id);

            mapAllRecords.put(de.Id, de);
        }

        for(Enquete__c eq : [SELECT Id, Name, Geolocation__Latitude__s, DelegueEnqueteurReferent__c, Geolocation__Longitude__s, CodePostal__c, Ville__c, Adresse__c FROM Enquete__c WHERE Geolocation__Latitude__s != null AND DelegueEnqueteurReferent__c IN :enqueteurIds AND Statut__c = 'En cours' AND Id != :recordId]){
            String locations = eq.Geolocation__Latitude__s + ',' + eq.Geolocation__Longitude__s;
            
            // TODO: To be refactored
            List<String> locationList = bulkLocationList.get(currentBulkLot);
            if(locationList == null)
                locationList = new List<String>();

            if(locationList.size() < MAX_BATCH_SIZE){
                locationList.add(locations);
            }else{
                locationList = new List<String>();
                locationList.add(locations);
                bulkLocationList.add(locationList);
                currentBulkLot++;
            }

            if(mapIdByIndexByBatch.get(currentBulkLot) == null)
            mapIdByIndexByBatch.put(currentBulkLot, new Map<Integer,Id>());

            mapIdByIndexByBatch.get(currentBulkLot).put(locationList.indexOf(locations), eq.Id);

            mapAllRecords.put(eq.Id, eq);
        }

        List<Item> output = new List<Item>();
        Map<Id, Item> mapItemByDEId = new map<Id, Item>();
        Set<Id> deAdded = new Set<Id>(); 

        for(Integer batchNumber=0; batchNumber < bulkLocationList.size(); batchNumber++){
            List<String> locationList = bulkLocationList.get(batchNumber);
            Map<String, String> params = new Map<String, String>();
            params.put('destinations', String.join(locationList, '|'));
            params.put('origins', record.Geolocation__Latitude__s + ',' + record.Geolocation__Longitude__s);
    
            WRP02_DistanceMatrix response = UTI01_LocationCallouts.doQueryDistanceMatrix(params);

            for(WRP02_DistanceMatrix.Row row : response.rows){
                Integer cpt = 0;
                for(WRP02_DistanceMatrix.Element el : row.elements){

                    if(mapIdByIndexByBatch.get(batchNumber) != null && mapIdByIndexByBatch.get(batchNumber).get(cpt) != null){
                        // Get Corresponding SObject
                        Id currentRecordId = mapIdByIndexByBatch.get(batchNumber).get(cpt);
                        String sObjName = currentRecordId.getSObjectType().getDescribe().getName();
                        if(sObjName == 'DelegueEnqueteur__c'){
                            Item i = new Item();
                            i.record = mapAllRecords.get(currentRecordId);
                            i.type = sObjName;
                            i.distance = new TextValue();
                            i.distance.text = el.distance.text;
                            i.distance.value = Integer.valueOf(el.distance.value);
                            mapItemByDEId.put(i.record.Id, i);
                            if(Integer.valueOf(el.distance.value) <= maxDistanceDE){
                                i.weight += (1000 + ((maxDistanceDE/1000) - (i.distance.value / 1000)));
                                output.add(i);
                                deAdded.add(i.record.Id);
                            }
                        }
                        if(sObjName == 'Enquete__c' && Integer.valueOf(el.distance.value) <= maxDistanceE){
                            Item i = new Item();
                            i.record = mapAllRecords.get(currentRecordId);
                            i.type = sObjName;
                            i.distance = new TextValue();
                            i.distance.text = el.distance.text;
                            i.distance.value = Integer.valueOf(el.distance.value);

                            Item deItem = mapItemByDEId.get((Id)i.record.get('DelegueEnqueteurReferent__c'));
                            if(deItem != null){
                                if(deItem.children == null)
                                deItem.children = new List<Item>();

                                deItem.children?.add(i);


                                deItem.weight += 1000;

                                if(!deAdded.contains(deItem.record.Id)){
                                    output.add(deItem);
                                	deAdded.add(deItem.record.Id);
                                }
                            }
                        }
                    }
                    // mapDistanceById.put(, el.distance.value);
                    cpt++;
                }
            }
        }

        output.sort();

        return output;
    }

    public class Item implements Comparable{
        @AuraEnabled
        public SObject record;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public TextValue distance;
        @AuraEnabled
        public Double weight=0;
        @AuraEnabled
        public List<Item> children;

        public Integer compareTo(Object compareTo) {
            Item compareItem = (Item)compareTo;

            Integer returnValue = 0;
            if ((Double)this.weight > (Double)compareItem.weight) {
                returnValue = -1;
            } else if ((Double)this.weight < (Double)compareItem.weight) {
                returnValue = 1;
            }
    
            return returnValue;
        }
    }

    public class TextValue{
        @AuraEnabled
        public String text;
        @AuraEnabled
        public Integer value;
    }

    @AuraEnabled
    public static void sendEmail(Id enqueteId, Id deId){
        try {
            DelegueEnqueteur__c de = [SELECT Id,Name, Email__c FROM DelegueEnqueteur__c WHERE Id = :deId LIMIT 1];
            Contact contact = [SELECT Id,Name FROM Contact WHERE LastName = 'Dummy' LIMIT 1];
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();   
            emailMessage.setSenderDisplayName('SPA'); 
            emailMessage.setUseSignature(false); 
            emailMessage.setBccSender(false); 
            emailMessage.setSaveAsActivity(false);   
            emailMessage.setWhatId(enqueteId); 
            emailMessage.setTreatTargetObjectAsRecipient(false); 
            emailMessage.setTargetObjectId(contact.Id); // WORKAROUND because it's mandatory to use a template
            emailMessage.setToAddresses(new String[]{ de.Email__c }); 
            EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Suggestion_Prise_Enquete'];
            emailMessage.setTemplateID(emailTemplate.Id); 

            Messaging.SingleEmailMessage[] fakeEmails = new List<Messaging.SingleEmailMessage> { emailMessage };  

            // SEND and RollBack Dummy Email (to generate email content)
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(fakeEmails); 
            Database.rollback(sp); 

            // Send Actual email
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : fakeEmails) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                emailMessages.add(emailToSend);
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                emailMessages.add(emailToSend);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
                Commentaire__c com = new Commentaire__c ();
                com.Commentaire__c = '<p>Proposition de prise en charge envoyée à ' + de.Name +'</p>';
                com.Date__c = Date.today();
                com.Enquete__c = enqueteId;
                insert com;
                System.debug('Commentaire inséré : ' + com.Id);
            } else {
                System.debug('The email failed to send: '
                    + results[0].errors[0].message);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}