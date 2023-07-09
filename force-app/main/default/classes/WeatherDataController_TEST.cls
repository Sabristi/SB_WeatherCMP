@IsTest
private class WeatherDataController_TEST {
    @IsTest
    static void testGetWeatherInfo() {

        // Call the getWeatherInfo method
        Map<String, Object> weatherInfo = WeatherDataController.getWeatherInfo('Marrakech', null, null);
        
        // Verify the result
        System.assertNotEquals(weatherInfo, null);
        System.assertEquals(weatherInfo.get('city'), 'Marrakech');
        System.assertEquals(weatherInfo.get('countryCode'), 'MA');
        System.assertEquals(weatherInfo.get('temperature'), 25);
        System.assertEquals(weatherInfo.get('humidity'), '70');
        System.assertEquals(weatherInfo.get('windspeed'), 10);
        System.assertEquals(weatherInfo.get('weatherCondition'), 'Rain');
    }
    
    @IsTest
    static void testGetWeatherInfo_NoData() {
        // Set up mock response for GeocodingService without coordinates
        Test.setMock(HttpCalloutMock.class, new MockGeocodingServiceResponse());

        // Call the getWeatherInfo method without city or coordinates
        Map<String, Object> weatherData = WeatherDataController.getWeatherInfo(null, null, null);

        // Verify the result for no weather data available
        System.assertEquals(weatherData, null);
    }

    @IsTest
    static void testGetCityFromAccount() {
        // Create an Account record for testing
        Account acc = new Account(Name = 'Test Account', BillingCity = 'San Francisco');
        insert acc;

        // Call the getCityFromAccount method
        String city = WeatherDataController.getCityFromAccount(acc.Id, 'Account.BillingCity');

        // Verify the result
        System.assertEquals(city, 'San Francisco');
    }

    // Mock HTTP response generator class for GeocodingService
    private class MockGeocodingServiceResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"results": [{"geometry": {"location": {"lat": 37.7749, "lng": -122.4194}}}]}');
            return res;
        }
    }


    

}