public class CMP01_GoogleMapController {
    // private static final Map<String, String> colorBySObject = new Map<String, String>{
    //     'DelegueEnqueteur__c' => '#FF0000',
    //     'Enquete__c' => '#00FF00'
    // };

    @AuraEnabled(cacheable=true)
    public static List<Location> getMarker(Id sObjectId) {

        List<Location> loc = new List<Location>();
        String sObjName = sObjectId.getSObjectType().getDescribe().getName();

        String fullQuery = 'SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s, ';
        fullQuery += 'Adresse__c, CodePostal__c, Ville__c ';
        fullQuery += 'FROM ' + sObjName + ' WHERE Id = \'' + sObjectId+ '\'';

        System.debug('*** fullQuery: ' + fullQuery);

        for(sObject o: Database.query(fullQuery)) {

            Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();
            GeoLocation geoInfo = new GeoLocation();
            geoInfo.Latitude = (Double)fieldsToValue.get('Geolocation__Latitude__s');
            geoInfo.Longitude = (Double)fieldsToValue.get('Geolocation__Longitude__s');
            
            // if (fieldsToValue.containsKey('Adresse__c'))
            //     geoInfo.Street = string.valueOf(fieldsToValue.get('Adresse__c'));
            // if (fieldsToValue.containsKey('CodePostal__c'))
            //     geoInfo.PostalCode = string.valueOf(fieldsToValue.get('CodePostal__c'));
            // if (fieldsToValue.containsKey('Ville__c'))
            //     geoInfo.City = string.valueOf(fieldsToValue.get('Ville__c'));
            // geoInfo.Country = 'France';
            

            Location locDetail = new Location();
            locDetail.title = string.valueOf(fieldsToValue.get('Name'));
            //locDetail.description = string.valueOf(fieldsToValue.get(p.ChampsDescription__c));
            locDetail.location = geoInfo;
            
            loc.add(locDetail);
        }
        return loc ;
    }

    @AuraEnabled(cacheable=true)
    public static List<Location> getMarkers(List<Id> recordIds) {
        System.debug(recordIds);
        Map<String, Set<Id>> mapSetIdsBySObject = new Map<String, Set<Id>>();
        for(Id recordId : recordIds){
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(!mapSetIdsBySObject.containsKey(sObjName)){
                mapSetIdsBySObject.put(sObjName, new Set<Id>());
            }
            mapSetIdsBySObject.get(sObjName).add(recordId);
        }
        System.debug('mapSetIdsBySObject:'+mapSetIdsBySObject);

        List<Location> loc = new List<Location>();

        if(mapSetIdsBySObject.containsKey('DelegueEnqueteur__c')){
            Set<Id> DEIds = mapSetIdsBySObject.get('DelegueEnqueteur__c');
            String fullQueryDE = 'SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s, ';
            fullQueryDE += 'Adresse__c, CodePostal__c, Ville__c ';
            fullQueryDE += 'FROM DelegueEnqueteur__c WHERE Id IN :DEIds';
    
            System.debug('*** fullQuery: ' + fullQueryDE);
    
            for(sObject o: Database.query(fullQueryDE)) {
                Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();
                GeoLocation geoInfo = new GeoLocation();
                geoInfo.Latitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Latitude__s')));
                geoInfo.Longitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Longitude__s')));
                
                // if (fieldsToValue.containsKey('Adresse__c'))
                //     geoInfo.Street = string.valueOf(fieldsToValue.get('Adresse__c'));
                // if (fieldsToValue.containsKey('CodePostal__c'))
                //     geoInfo.PostalCode = string.valueOf(fieldsToValue.get('CodePostal__c'));
                // if (fieldsToValue.containsKey('Ville__c'))
                //     geoInfo.City = string.valueOf(fieldsToValue.get('Ville__c'));
                // geoInfo.Country = 'France';
    
                Location locDetail = new Location();
                locDetail.title = string.valueOf(fieldsToValue.get('Name'));
                //locDetail.description = string.valueOf(fieldsToValue.get(p.ChampsDescription__c));
                locDetail.location = geoInfo;
                locDetail.sObjectName = 'DelegueEnqueteur__c';
                
                loc.add(locDetail);
            }
        }
        
        if(mapSetIdsBySObject.containsKey('Enquete__c')){
            Set<Id> EIds = mapSetIdsBySObject.get('Enquete__c');
            String fullQueryEnquetes = 'SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s, ';
            fullQueryEnquetes += 'Adresse__c, CodePostal__c, Ville__c ';
            fullQueryEnquetes += 'FROM Enquete__c WHERE Id IN :EIds';
    
            System.debug('*** fullQuery: ' + fullQueryEnquetes);
    
            for(sObject o: Database.query(fullQueryEnquetes)) {
                System.debug('o : ' + o);
                Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();
                System.debug('fieldsToValue : ' + fieldsToValue);
                GeoLocation geoInfo = new GeoLocation();
                if (fieldsToValue.containsKey('Geolocation__Latitude__s'))
                    geoInfo.Latitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Latitude__s')));
                if (fieldsToValue.containsKey('Geolocation__Longitude__s'))
                    geoInfo.Longitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Longitude__s')));
                
                // if (fieldsToValue.containsKey('Adresse__c'))
                //     geoInfo.Street = string.valueOf(fieldsToValue.get('Adresse__c'));
                // if (fieldsToValue.containsKey('CodePostal__c'))
                //     geoInfo.PostalCode = string.valueOf(fieldsToValue.get('CodePostal__c'));
                // if (fieldsToValue.containsKey('Ville__c'))
                //     geoInfo.City = string.valueOf(fieldsToValue.get('Ville__c'));
                // geoInfo.Country = 'France';
    
                Location locDetail = new Location();
                locDetail.title = string.valueOf(fieldsToValue.get('Name'));
                //locDetail.description = string.valueOf(fieldsToValue.get(p.ChampsDescription__c));
                locDetail.location = geoInfo;
                locDetail.sObjectName = 'Enquete__c';
                
                loc.add(locDetail);
            }
        }

        return loc ;
    }

    public class Location{
        @AuraEnabled 
        public String icon{get;set;} 
        @AuraEnabled 
        public String title{get;set;} 
        @AuraEnabled
        public String description{get;set;} 
        @AuraEnabled 
        public GeoLocation location{get;set;} 
        @AuraEnabled 
        public String sObjectName{get;set;} 
    }
    public class GeoLocation{
        @AuraEnabled 
        public Double Latitude{get;set;}
        @AuraEnabled 
        public Double Longitude{get;set;}
        @AuraEnabled 
        public String Street{get;set;}
        @AuraEnabled 
        public String PostalCode{get;set;}
        @AuraEnabled 
        public String City{get;set;}
        @AuraEnabled 
        public String State{get;set;}
        @AuraEnabled 
        public String Country{get;set;}
    }
}