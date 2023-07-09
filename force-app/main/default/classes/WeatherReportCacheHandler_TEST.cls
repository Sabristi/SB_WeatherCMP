@IsTest
private class WeatherReportCacheHandler_TEST {
    @IsTest
    static void testPutAndGetSendingDate() {
        WeatherReportCacheHandler cacheHandler = new WeatherReportCacheHandler();
        
        // Set the sending date in the cache
        String sendingDate = '2023-07-08';
        cacheHandler.putSendingDate(sendingDate);
        
        // Retrieve the sending date from the cache
        String retrievedSendingDate = cacheHandler.getLastSendingDate();
        
        // Verify the retrieved sending date
        System.assertEquals(retrievedSendingDate, sendingDate);
    }
    
    @IsTest
    static void testGetLastSendingDateWithNoValue() {
        WeatherReportCacheHandler cacheHandler = new WeatherReportCacheHandler();
        
        // Retrieve the sending date from the cache when no value is set
        String retrievedSendingDate = cacheHandler.getLastSendingDate();
        
        // Verify the retrieved sending date is 'None'
        System.assertEquals(retrievedSendingDate, 'None');
    }
}