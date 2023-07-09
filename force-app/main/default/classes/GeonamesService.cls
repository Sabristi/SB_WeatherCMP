global class GeonamesService {
    
    /**
     * Retrieves weather data based on latitude and longitude coordinates.
     * @param lat The latitude coordinate.
     * @param lng The longitude coordinate.
     * @return WeatherObservation object containing weather data.
     */
    @AuraEnabled(cacheable=true)
    global static WeatherObservation getWeatherData(decimal lat, decimal lng) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:APIGeonames/findNearByWeatherJSON?lat=' + lat + '&lng=' + lng + '&username=' + getGeonamesAPIKey());
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        // Parse the response body as JSON
        JSONParser parser = JSON.createParser(res.getBody());

        // Deserialize the JSON response into a Map
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        // Extract the weather observation object from the JSON response
        Object weatherObs = jsonResponse.get('weatherObservation');
        system.debug('weatherObs : ' + weatherObs);
        if (weatherObs != null && weatherObs instanceof Map<String, Object>) {
            
            WeatherObservation weather = new WeatherObservation();
            
            // Cast the weather observation object to a Map
            Map<String, Object> weatherObsMap = (Map<String, Object>)weatherObs;
            
            // Assign weather data to WeatherObservation object properties
            weather.temperature = String.valueOf(weatherObsMap.get('temperature'));
            weather.humidity = String.valueOf(weatherObsMap.get('humidity'));
            weather.windSpeed = String.valueOf(weatherObsMap.get('windSpeed'));
            weather.stationName = (String)weatherObsMap.get('stationName');
            weather.countryCode = (String)weatherObsMap.get('countryCode');
            weather.cloudsCode = (String)weatherObsMap.get('cloudsCode');
            weather.clouds = (String)weatherObsMap.get('clouds');
            weather.weatherCondition = (String)weatherObsMap.get('weatherCondition');
            weather.weatherConditionCode = (String)weatherObsMap.get('weatherConditionCode');
            
            return weather;
        } else {
            return null;
        }
    }
    
    /**
     * Checks if the sun is still present at the specified latitude and longitude coordinates.
     * @param lat The latitude coordinate.
     * @param lng The longitude coordinate.
     * @return localTimeZone object containing sun presence information.
     */
    public static localTimeZone isSunStillPresent(Decimal lat, Decimal lng) {
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:APIGeonames/timezoneJSON?lat=' + lat + '&lng=' + lng + '&username=' + getGeonamesAPIKey());
        request.setMethod('GET');
        
        localTimeZone l_time = new localTimeZone();
        
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String sunriseTime = (String) jsonResponse.get('sunrise');
            String sunsetTime = (String) jsonResponse.get('sunset');
            String currentTime = (String) jsonResponse.get('time');
            
            DateTime sunrise = parseDateTime(sunriseTime);
            DateTime sunset = parseDateTime(sunsetTime);
            DateTime current = parseDateTime(currentTime);
            
            l_time.localTime = currentTime;
            l_time.isSunPresent = current >= sunrise && current <= sunset;
            l_time.countryCode = (String) jsonResponse.get('countryCode');
            
            return l_time;
        } else {
            // Handle API error
            return null;
        }
    }
    
    /**
     * Parses a date-time string into a DateTime object.
     * @param dateTimeStr The date-time string to parse.
     * @return The parsed DateTime object.
     */
    private static DateTime parseDateTime(String dateTimeStr) {
        if (dateTimeStr != null && dateTimeStr.length() >= 16) {
            Integer year = Integer.valueOf(dateTimeStr.substring(0, 4));
            Integer month = Integer.valueOf(dateTimeStr.substring(5, 7));
            Integer day = Integer.valueOf(dateTimeStr.substring(8, 10));
            Integer hour = Integer.valueOf(dateTimeStr.substring(11, 13));
            Integer minute = Integer.valueOf(dateTimeStr.substring(14, 16));
            
            return DateTime.newInstanceGmt(year, month, day, hour, minute, 0);
        }
        
        return null;
    }
    
    /**
     * Retrieves the place name based on latitude and longitude coordinates.
     * @param lat The latitude coordinate.
     * @param lng The longitude coordinate.
     * @return placeName object containing the city name and country code.
     */
    public static placeName getPlaceName(Decimal lat, Decimal lng) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:APIGeonames/findNearbyPostalCodesJSON?lat=' + lat + '&lng=' + lng + '&username=' + getGeonamesAPIKey());
        request.setMethod('GET');
        
        placeName placelocation = new placeName();
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            List<Object> postalCodes = (List<Object>) jsonResponse.get('postalCodes');
            if (postalCodes != null && postalCodes.size() > 0) {
                Map<String, Object> postalCode = (Map<String, Object>) postalCodes[0];
                placelocation.cityName = (String) postalCode.get('placeName');
                placelocation.countryCode = (String) postalCode.get('countryCode');
            } else {
                placelocation.cityName = 'N/A';
                placelocation.countryCode = 'N/A';
            }
        } else {
            System.debug('HTTP request failed with status code: ' + response.getStatusCode());
            placelocation.cityName = 'N/A';
            placelocation.countryCode = 'N/A';
        }
        
        return placelocation;
    }

    
    /**
     * Retrieves the API Key to call GeoNames Services.
     * @return API Key Value.
     */
    public static string getGeonamesAPIKey(){
        APIKey__mdt apikey = APIKey__mdt.getInstance('APIGeonames');
        return apikey.Value__c;
	}
    
    
    /**
     * Represents the weather observation data.
     */
    global class WeatherObservation {
        @AuraEnabled public string temperature {get;set;} 
        @AuraEnabled public string windSpeed {get;set;} 
        @AuraEnabled public string humidity {get;set;} 
        @AuraEnabled public String stationName {get;set;} 
        @AuraEnabled public String countryCode {get;set;} 
        @AuraEnabled public String cloudsCode {get;set;} 
        @AuraEnabled public String clouds {get;set;} 
        @AuraEnabled public String weatherCondition {get;set;} 
        @AuraEnabled public String weatherConditionCode {get;set;} 
        @AuraEnabled public String localTime {get;set;}
        @AuraEnabled public boolean isSunPresent {get;set;}
    }
    
    /**
     * Represents the place name data.
     */
    public class placeName {
        @AuraEnabled public String cityName;
        @AuraEnabled public String countryCode;
    }
    
    /**
     * Represents the local time zone data.
     */
    public class localTimeZone {
        @AuraEnabled public String localTime;
        @AuraEnabled public Boolean isSunPresent;
        @AuraEnabled public String countryCode;
    }
    

    
   
}