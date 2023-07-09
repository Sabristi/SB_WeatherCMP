public class GeocodingService {
    
    // Method to retrieve coordinates for a given city name
    public static coordinates getCoordinates(String cityName) {
        // Encode the city name for the URL
        String encodedCityName = EncodingUtil.urlEncode(cityName, 'UTF-8');

        // Create HTTP objects for making the request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:APIGoogle/maps/api/geocode/json?address=' + encodedCityName + '&key=AIzaSyA5m4WPSEQo9jlW8FN13AZj8Nzgj85UgmY');
        request.setMethod('GET');
        
        // Create coordinates object to store latitude and longitude
        coordinates geoloc = new coordinates();
        
        // Send the HTTP request
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            // Parsing the response JSON
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            

            if (jsonResponse.containsKey('results')) {
                List<Object> results = (List<Object>) jsonResponse.get('results');
                if (!results.isEmpty()) {
                    Map<String, Object> firstResult = (Map<String, Object>) results[0];
                    Map<String, Object> geometry = (Map<String, Object>) firstResult.get('geometry');
                    Map<String, Object> location = (Map<String, Object>) geometry.get('location');
                    
                    // Extracting latitude and longitude from the response
                    geoloc.latitude = (Decimal) location.get('lat');
                    geoloc.longitude = (Decimal) location.get('lng');
                    
                    System.debug('Latitude: ' + geoloc.latitude);
                    System.debug('Longitude: ' + geoloc.longitude);
                    
                } else {
                    System.debug('No results found for the city.');
                }
            }
        } else {
            System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
        }
        
        // Return the coordinates object
        return geoloc;
    }
    
    // Inner class to hold the coordinates
    public class coordinates {
        @AuraEnabled public Decimal latitude;
        @AuraEnabled public Decimal longitude;
    }
}