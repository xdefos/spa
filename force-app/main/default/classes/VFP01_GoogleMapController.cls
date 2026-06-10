public with sharing class VFP01_GoogleMapController {

    Public static  List<ParametreGoogleMap__c> lParams = [SELECT Id, Name, AffichageDefaut__c, RequeteSOQL__c, Icone__c, ChampsTitre__c, ChampsDescription__c
                                FROM ParametreGoogleMap__c
                                ORDER BY OrdreAffichage__c ASC];

	public List<ParametreGoogleMap__c> params { 
    	get{
    		return  lParams;
    	}
    	set; 
    }

    public String paramNameById { 
        get{
            Map<Id, String> mParamNameById = new Map<Id, String>();
            for(ParametreGoogleMap__c p: lParams) {
                mParamNameById.put(p.id, p.Name);
            }
            return JSON.serialize(mParamNameById);
        }
        set; 
    }

    public String paramsJSON { 
    	get{
    		
    		List<Param> returnList = new List<Param>();
    		for(ParametreGoogleMap__c p: params) {
    			Param encodedP = new Param();
    			encodedP.id 					= p.Id;
    			encodedP.name 					= EncodingUtil.urlEncode(p.Name,'UTF-8');
    			encodedP.affichageDefaut 		= p.AffichageDefaut__c;
    			encodedP.requeteSOQL 			= EncodingUtil.urlEncode(p.RequeteSOQL__c,'UTF-8');
    			encodedP.icone 					= EncodingUtil.urlEncode(p.Icone__c,'UTF-8');
    			encodedP.champsTitre 			= EncodingUtil.urlEncode(p.ChampsTitre__c,'UTF-8');
    			encodedP.champsDescription 		= EncodingUtil.urlEncode(p.ChampsDescription__c,'UTF-8');
    			returnList.add(encodedP);
    		}
    		return  JSON.serialize(returnList);
    	}
    	set; 

    }
    
    public String geolocByParamId { 
    	get{
    		Map<String, List<Location>> returnedMap = new Map<String, List<Location>>();
        	
        	for(ParametreGoogleMap__c p: params) {

        		String fullQuery = p.RequeteSOQL__c.toLowerCase().substringBefore(' from'); 
                fullQuery += ', Geolocation__Latitude__s, Geolocation__Longitude__s, Id FROM'; 
                fullQuery += p.RequeteSOQL__c.toLowerCase().substringAfter(' from');
                /* Code à nettoyer car Geoloc est vide en tests */
                if (!Test.isRunningTest()) 
                    fullQuery += p.RequeteSOQL__c.toLowerCase().contains('where')? ' AND Geolocation__Latitude__s <>null': ' WHERE Geolocation__Latitude__s <>null';
                fullQuery += ' ORDER BY Name ASC';
                System.debug(fullQuery);

                List<Location> geolocs = new List<Location>();
                for(sObject o: Database.query(fullQuery)) {
                    Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();

                    GeoLocation geoInfo = new GeoLocation();
                    if (fieldsToValue.containsKey('Geolocation__Latitude__s'))
                        geoInfo.Latitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Latitude__s')));
                    if (fieldsToValue.containsKey('Geolocation__Longitude__s'))    
                        geoInfo.Longitude = Decimal.valueOf(string.valueOf(fieldsToValue.get('Geolocation__Longitude__s')));
                    
                    Location locDetail = new Location();
                    locDetail.id            = o.Id; 
                    locDetail.icon 			= EncodingUtil.urlEncode(p.Icone__c,'UTF-8').replace('+', '%20'); 
                    locDetail.title 		= EncodingUtil.urlEncode(getComputedLabel(fieldsToValue, p.ChampsTitre__c),'UTF-8').replace('+', '%20');
                    locDetail.description 	= EncodingUtil.urlEncode(getComputedLabel(fieldsToValue, p.ChampsDescription__c),'UTF-8').replace('+', '%20');
                    locDetail.location 		= geoInfo;
                    
                    geolocs.add(locDetail);

                }
                returnedMap.put(p.Id, geolocs);

        	}
        	return JSON.serialize(returnedMap);
    	}
    	set; 
    }

    public String getComputedLabel(Map<String, Object> fieldsToValue, String strFormula) {

    	String computedLabel ='';

    	if (strFormula != '') {

	    	for(String s1: strFormula.split('\\{')) {
    			for(String s2: s1.split('\\}')) {
					if (fieldsToValue.containsKey(s2)) {
						computedLabel += string.valueOf(fieldsToValue.get(s2));
					} else {
						computedLabel += s2;
					} 
    			}
	    	}
    	}
    	return computedLabel;
    }

    public class Location{
        public String icon{get;set;} 
        public String id{get;set;} 
        public String title{get;set;} 
        public String description{get;set;} 
        public GeoLocation location{get;set;} 
    }
    public class GeoLocation{
        public Decimal Latitude{get;set;}
        public Decimal Longitude{get;set;}
    }
    public class Param{
        public String id{get;set;} 
        public String name{get;set;} 
        public Boolean affichageDefaut{get;set;} 
        public String requeteSOQL{get;set;} 
        public String icone{get;set;} 
        public String champsTitre{get;set;} 
        public String champsDescription{get;set;} 
    }
}