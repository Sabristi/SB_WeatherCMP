@IsTest
private class GeonamesService_TEST {

    @IsTest
    static void testGetWeatherData() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"weatherObservation": {"temperature": "25", "humidity": "70", "windSpeed": "10", "stationName": "Test Station", "countryCode": "US", "cloudsCode": "CL", "clouds": "Cloudy", "weatherCondition": "Rain", "weatherConditionCode": "RA", "localTime": "2023-07-08 12:00:00"}}', 200));

        // Call the getWeatherData method
        GeonamesService.WeatherObservation weather = GeonamesService.getWeatherData(37.7749, -122.4194);

        // Verify the result
        System.assertNotEquals(weather, null);
        System.assertEquals(weather.temperature, '25');
        System.assertEquals(weather.humidity, '70');
        System.assertEquals(weather.windSpeed, '10');
        System.assertEquals(weather.stationName, 'Test Station');
        System.assertEquals(weather.countryCode, 'US');
        System.assertEquals(weather.cloudsCode, 'CL');
        System.assertEquals(weather.clouds, 'Cloudy');
        System.assertEquals(weather.weatherCondition, 'Rain');
        System.assertEquals(weather.weatherConditionCode, 'RA');
    }

    @IsTest
    static void testGetWeatherData_NoWeatherObservation() {
        // Set up mock response without weather observation
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"otherField": "Test"}'));

        // Call the getWeatherData method
        GeonamesService.WeatherObservation weather = GeonamesService.getWeatherData(37.7749, -122.4194);

        // Verify the result
        System.assertEquals(weather, null);
    }

    @IsTest
    static void testIsSunStillPresent() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"sunrise": "2023-07-08 06:00:00", "sunset": "2023-07-08 18:00:00", "time": "2023-07-08 12:00:00", "countryCode": "US"}'));

        // Call the isSunStillPresent method
        GeonamesService.localTimeZone timeZone = GeonamesService.isSunStillPresent(37.7749, -122.4194);

        // Verify the result
        System.assertNotEquals(timeZone, null);
        System.assertEquals(timeZone.localTime, '2023-07-08 12:00:00');
        System.assertEquals(timeZone.isSunPresent, true);
        System.assertEquals(timeZone.countryCode, 'US');
    }

    @IsTest
    static void testIsSunStillPresent_Error() {
        // Set up mock response with error
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"error": "API error"}', 500));

        // Call the isSunStillPresent method
        GeonamesService.localTimeZone timeZone = GeonamesService.isSunStillPresent(37.7749, -122.4194);

        // Verify the result
        System.assertEquals(timeZone, null);
    }

    @IsTest
    static void testGetPlaceName() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"postalCodes": [{"placeName": "Marrakech", "countryCode": "MA"}]}', 200));

        // Call the getPlaceName method
        GeonamesService.placeName place = GeonamesService.getPlaceName(31.63, -8.00);

        // Verify the result
        System.assertNotEquals(place, null);
        System.assertEquals('Marrakech',place.cityName);
        System.assertEquals('MA',place.countryCode);
    }

    @IsTest
    static void testGetPlaceName_Error() {
        // Set up mock response with error
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"error": "API error"}', 500));

        // Call the getPlaceName method
        GeonamesService.placeName place = GeonamesService.getPlaceName(37.7749, -122.4194);

        // Verify the result
        System.assertNotEquals(place, null);
        System.assertEquals(place.cityName, 'N/A');
        System.assertEquals(place.countryCode, 'N/A');
    }

    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;

        public MockHttpResponseGenerator(String responseBody) {
            this.responseBody = responseBody;
            this.statusCode = 200;
        }

        public MockHttpResponseGenerator(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            return res;
        }
    }
}