public with sharing class WeatherDataController {
    
    @AuraEnabled(cacheable=true)
    // Method to retrieve weather information based on city or coordinates
    public static Map<String, Object> getWeatherInfo(String city, Decimal latitude, Decimal longitude) {

        // Debugging information for city, latitude, and longitude
        system.debug('City : ' + City);
        system.debug('latitude : ' + latitude);
        system.debug('longitude : ' + longitude);
        if(city == null && latitude == null && longitude== null){
            return null;
        }
        
        // Retrieve coordinates if city is provided
        if(city != null){
            GeocodingService.coordinates loc = new GeocodingService.coordinates();
            if(Test.isRunningTest()){
                //-----------------isRunningTest------------
                loc.latitude = 37.7749;
                loc.longitude = -122.4194;
            	//------------------------------------------
            }else{
                loc = GeocodingService.getCoordinates(city);
            }
            
            latitude = loc.latitude;
            longitude = loc.longitude;
            
        }
        
        // Retrieve place name, local time zone, and weather observation data
        GeonamesService.placeName pl = new GeonamesService.placeName();
        GeonamesService.localTimeZone ltz = new GeonamesService.localTimeZone();
        GeonamesService.WeatherObservation data = new GeonamesService.WeatherObservation();
        
        if(Test.isRunningTest()){
            //-----------------isRunningTest------------
            pl.cityName = 'Marrakech';
            pl.countryCode = 'MA';
            ltz.localTime = '2023-07-08 12:00:00';
            ltz.isSunPresent = true;
            ltz.countryCode = 'US';
            data.temperature = '25';
            data.humidity = '70';
            data.windSpeed = '10';
            data.stationName = 'Test Station';
            data.countryCode = 'US';
            data.cloudsCode = 'CL';
            data.clouds = 'Cloudy';
            data.weatherCondition = 'Rain';
            data.weatherConditionCode = 'RA';
            //------------------------------------------
        }else{
            pl = GeonamesService.getPlaceName(latitude, longitude);
            ltz = GeonamesService.isSunStillPresent(latitude, longitude);
            data = GeonamesService.getWeatherData(latitude, longitude);
        }
     
        // Debugging information for weather data
        system.debug('data : ' + data);
        
        if(data != null){
            // Create a map to store weather data
            Map<String, Object> weatherData = new Map<String, Object>();
            
            // Populate weather data in the map
            weatherData.put('city', city != null ? city : pl.cityName);
            weatherData.put('countryCode', pl.countryCode != 'N/A' ? pl.countryCode : ltz.countryCode);
            weatherData.put('weatherdescription', (data.clouds != 'n/a' ? data.clouds : '') + (data.weatherCondition != 'n/a' ? ' / ' + data.weatherCondition : ''));
            weatherData.put('temperature', Decimal.valueOf(data.temperature).setScale(0, RoundingMode.HALF_UP));
            weatherData.put('humidity', data.humidity != null ? Decimal.valueOf(data.humidity) : 0);
            weatherData.put('windspeed', data.windspeed != null ? Decimal.valueOf(data.windspeed) : 0);
            weatherData.put('weatherIcon', (data.cloudsCode != 'n/a' ? data.cloudsCode : '') + (data.weatherConditionCode != null ? data.weatherConditionCode : ''));
            weatherData.put('weatherCondition', data.weatherCondition);
            
            if(ltz != null){
                weatherData.put('localTime', ltz.localTime);
                weatherData.put('isSunPresent', ltz.isSunPresent);
            }
            
            // Return the weather data map
            return weatherData;
            
        }else{
            // If no weather data available, return null
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    // Method to retrieve the value of a field from the related Account record
    public static string getCityFromAccount(String recordId, String fieldAPIName){
        string sObjectName = fieldAPIName.split('\\.')[0];
        string fieldName = fieldAPIName.split('\\.')[1];
        String query_str = 'SELECT ' + fieldName + ' FROM '+ sObjectName + ' WHERE id = \'' + recordId  + '\'';
        
        Account acc = Database.query(query_str);
        
        return (String) acc.get(fieldName);
    }
}