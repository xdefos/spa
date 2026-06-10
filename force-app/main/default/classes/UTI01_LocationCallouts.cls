/**
* @author Xavier Defossez
* @date 2019-12-07
* @description  Util class for query Google Gecode API
* @group Trigger Handler
*/

public with sharing class UTI01_LocationCallouts {

    public static void setObjectFields(List<SObject> sobjects, Map<id,SObject> oldSObjects, String obj) {
        for(SObject o: sobjects) {
            
            //redressement pour VPA
            if (obj=='VisitePostAdoption__c') {
				if (String.valueOf(o.get('Name')) != null)
                	o.put('Name', String.valueOf(o.get('Name')).toUpperCase());
                if (String.valueOf(o.get('NomAnimal__c')) != null)
                    o.put('NomAnimal__c', nameFormat(String.valueOf(o.get('NomAnimal__c'))));
            }

            //redressement pour Animal
            if (obj=='Animal__c') {
                o.put('Name', nameFormat(String.valueOf(o.get('Name'))));
            }
            
            //redressement pour Enquete
            if (obj=='Enquete__c'|| obj=='Signalement__c') {
                o.put('ListeEspeces__c', nameFormat(String.valueOf(o.get('Especes__c'))));
            }

			//redressement pour Enquete
            if (obj=='Signalement__c') {
				if (String.valueOf(o.get('Ville_Signalant__c')) != null)
                	o.put('Ville_Signalant__c',String.valueOf(o.get('Ville_Signalant__c')).toUpperCase());
            }

            //redressement pour Ville
            if (obj=='VisitePostAdoption__c' || obj=='Enquete__c' || obj=='DelegueEnqueteur__c' || obj=='ContactLocal__c' || obj=='Signalement__c' )
                if (String.valueOf(o.get('Ville__c')) != null)
                    o.put('Ville__c',String.valueOf(o.get('Ville__c')).toUpperCase());
        }
    }

    public static String nameFormat(String name) {
        String result = '';

        if (name != null && name != '') {
            for (String iter : name.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1)
                        result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()).toLowerCase() + ' ';                    
                    else 
                        result += iter.substring(0,1).toUpperCase() + ' ';
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }

	public static void setGeolocation(List<SObject> sobjects, Map<id,SObject> oldSObjects) {

    	List<SObject> oToUpdate = new List<SObject>();

    	for(SObject o: sobjects) {
    		if (oldSObjects == null) {
    			if (String.valueOf(o.get('CodePostal__c')) != null && String.valueOf(o.get('Ville__c')) != null)
    				oToUpdate.add(o);
    		} else {
    			if (String.valueOf(o.get('CodePostal__c')) == null || String.valueOf(o.get('Ville__c')) == null) {
    				o.put('Geolocation__Latitude__s',null);
					o.put('Geolocation__Longitude__s',null);
    			} else {
    				if (Boolean.valueOf(o.get('GeolocationCalcul__c'))
    					|| (String.valueOf(o.get('Adresse__c')) != String.valueOf(oldSObjects.get(o.Id).get('Adresse__c'))
                            || String.valueOf(o.get('Ville__c')) != String.valueOf(oldSObjects.get(o.Id).get('Ville__c'))
                            || String.valueOf(o.get('CodePostal__c')) != String.valueOf(oldSObjects.get(o.Id).get('CodePostal__c')))) {

    						o.put('GeolocationCalcul__c',false);
							oToUpdate.add(o);	
    				}
    			}
			}
		}
    	
    	if (!oToUpdate.isEmpty() && !System.isFuture() && oToUpdate.size()<=50) 
    		for(SObject o: oToUpdate) {
    			UTI01_LocationCallouts.doQueryGeocode(JSON.serialize(o));
    		} 
    }
    
    /*******************************************************************************************************
    * @description  Set Geolocation for Enquete
    * @author Xavier Defossez
    * @param List<Enquete__c>, Map<id,Enquete__c>
    * @return void
    */
    @future (callout=true)
	public static void doQueryGeocode (String record){
		String geocodingKey = Label.GoogleAPIKey;
		SObject o = (SObject)JSON.deserialize(record, SObject.class);

		// create a string for the address to pass to Google Geocoding API
        String geoAddress = String.valueOf(o.get('Adresse__c')) 
        						+ ', ' + String.valueOf(o.get('Ville__c')) 
        						+ ', ' +'France, ' 
        						+ String.valueOf(o.get('CodePostal__c'));
		geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');

		// build and make the callout to the Geocoding API
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+geoAddress + '&key=' + geocodingKey+ '&sensor=false');
		request.setMethod('GET');
		request.setTimeout(60000);

		double latitude =  0;
		double longitude = 0;

		if (!Test.isRunningTest()) {
			HttpResponse response = http.send(request);
			WRP01_Geocode geocode = (WRP01_Geocode)JSON.deserialize(response.getBody(), WRP01_Geocode.class);
			latitude = geocode.results[0].geometry.location.lat;
			longitude = geocode.results[0].geometry.location.lng;

			// update co-ordinates on address if we get them back
			if(latitude != null) {
				o.put('Geolocation__Latitude__s', latitude);
				o.put('Geolocation__Longitude__s', longitude);
				update o;
			}
		} 		
	}

	/*******************************************************************************************************
    * @description  Set DistanceMatrix for Enquete
    * @author Gil Avignon
    * @param String params
    * @return void
    */
	public static WRP02_DistanceMatrix doQueryDistanceMatrix (Map<String,String> urlParams){
		String geocodingKey = Label.GoogleAPIKey;
		// Map<String,String> urlParams = (Map<String,String>)JSON.deserialize(params, Map<String,String>.class);
		urlParams.put('key',geocodingKey);

		String endpoint = 'https://maps.googleapis.com/maps/api/distancematrix/json';

		// Manage URLEncoded Parameters
        if(urlParams != null){
            List<String> query = new List<String>();
            for(string key : urlParams.keySet()) {
                query.add(key + '=' + EncodingUtil.urlEncode(urlParams.get(key), 'UTF-8'));
            }
            if(!query.isEmpty()){
                endpoint += '?' + string.join(query, '&');
            }
        }

		System.debug(endpoint);

		// build and make the callout to the Geocoding API
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		request.setTimeout(60000);

		double latitude =  0;
		double longitude = 0;

		// if (!Test.isRunningTest()) {
			HttpResponse response = http.send(request);
			System.debug('#response:' + response.getBody());
			WRP02_DistanceMatrix distanceResponse = (WRP02_DistanceMatrix)JSON.deserialize(response.getBody(), WRP02_DistanceMatrix.class);

			return distanceResponse;
		// } 		
	}
}