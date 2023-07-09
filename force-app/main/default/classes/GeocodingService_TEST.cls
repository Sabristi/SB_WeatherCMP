@IsTest
private class GeocodingService_TEST {

    @IsTest
    static void testGetCoordinates() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"results": [{"geometry": {"location": {"lat": 37.7749, "lng": -122.4194}}}]}', 200));

        // Call the getCoordinates method
        GeocodingService.coordinates coords = GeocodingService.getCoordinates('San Francisco');

        // Verify the result
        System.assertNotEquals(coords, null);
        System.assertEquals(coords.latitude, 37.7749);
        System.assertEquals(coords.longitude, -122.4194);
    }

    @IsTest
    static void testGetCoordinates_NoResults() {
        // Set up mock response without results
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"results": []}', 200));

        // Call the getCoordinates method
        GeocodingService.coordinates coords = GeocodingService.getCoordinates('Nonexistent City');

        // Verify the result
        System.assertEquals(null,coords.latitude);
        System.assertEquals(null,coords.longitude);
    }

    @IsTest
    static void testGetCoordinates_Error() {
        // Set up mock response with error
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"error": "API error"}', 500));

        // Call the getCoordinates method
        GeocodingService.coordinates coords = GeocodingService.getCoordinates('San Francisco');

        // Verify the result
        System.assertEquals(null,coords.latitude);
        System.assertEquals(null,coords.longitude);
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