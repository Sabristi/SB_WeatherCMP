@IsTest
public class WeatherReportController_TEST {
    
    @IsTest
    public static void testGetLastWeatherReport_RecordPage() {
        // Test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        // Set up test context
        Test.startTest();

            // Call the method being tested
            String result = WeatherReportController.getLastWeatherReport('RecordPage', testAccount.Id, 'lastWeatherReportSent__c');
            
            // Perform assertions
            System.assertEquals('None', result, 'Unexpected result');

        Test.stopTest();
    }
    
    @IsTest
    public static void testGetLastWeatherReport_HomePage() {
        // Set up test context
        Test.startTest();

            // Call the method being tested
            String result = WeatherReportController.getLastWeatherReport('HomePage', null, null);
            
            // Perform assertions
            System.assertEquals('None', result, 'Unexpected result');

        Test.stopTest();
    }
    
    @IsTest
    public static void testSendWeatherReportEmailFromAccWithoutContacts() {
        // Test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        // Set up test context
        Test.startTest();

            // Call the method being tested
            WeatherReportController.sendingReportWrapper result = WeatherReportController.sendWeatherReportEmail(new Map<Object, Object>(), testAccount.Id, 'lastWeatherReportSent__c');
            
            // Perform assertions
            System.assertEquals('No contacts related to this Account.', result.ret, 'Unexpected result');
            System.assertEquals(true, result.isError, 'Unexpected result');

        Test.stopTest();
    }
    
    @IsTest
    public static void testGenerateEmailBody() {
        // Test data
        Map<Object, Object> weatherData = new Map<Object, Object>();
        weatherData.put('city', 'Test City');
        weatherData.put('countryCode', 'US');
        weatherData.put('localTime', '2023-07-09 12:00:00');
        weatherData.put('temperature', 25.5);
        weatherData.put('weatherdescription', 'Sunny');
        weatherData.put('windspeed', 10.5);
        weatherData.put('humidity', 50);
        
        // Call the method being tested
        String result = WeatherReportController.generateEmailBody(weatherData);
        
        // Perform assertions
        String expectedBody = 'Weather Report:\n\n';
        expectedBody += 'City: Test City\n';
        expectedBody += 'Country Code: US\n';
        expectedBody += 'Local Time: 2023-07-09 12:00:00\n';
        expectedBody += 'Temperature: 25.5°C\n';
        expectedBody += 'Weather Description: Sunny\n';
        expectedBody += 'Wind Speed: 10.5 m/s \n';
        expectedBody += 'Humidity: 50 % \n';
        System.assertEquals(expectedBody, result, 'Unexpected result');
    }
    
    @IsTest
    public static void testSendWeatherReportEmailFromAccWithContacts() {
        // Test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testcontact@example.com';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        // Set up test context
        Test.startTest();

            // Call the method being tested
            WeatherReportController.sendingReportWrapper result = WeatherReportController.sendWeatherReportEmail(new Map<Object, Object>(), testAccount.Id, 'lastWeatherReportSent__c');
            
            // Perform assertions
            System.assertEquals('01/01/2000 00:00', result.ret, 'Unexpected result');
            System.assertEquals(false, result.isError, 'Unexpected result');

        Test.stopTest();
    }
    
    @IsTest
    public static void testSendWeatherReportEmailToOrgUsers() {
        // Test data
        List<User> testOrgUsers = new List<User>();
        
        testOrgUsers.add(createUser('SB', 'TEST1', 'sbtest1@example.com'));
        testOrgUsers.add(createUser('SB', 'TEST2', 'sbtest2@example.com'));

        insert testOrgUsers;
        
        // Set up test context
        Test.startTest();

            // Call the method being tested
            WeatherReportController.sendingReportWrapper result = WeatherReportController.sendWeatherReportEmail(new Map<Object, Object>(), null, null);
            
            // Perform assertions
            System.assertEquals('01/01/2000 00:00', result.ret, 'Unexpected result');
            System.assertEquals(false, result.isError, 'Unexpected result');

        Test.stopTest();
    }
    
    
    public static User createUser(String firstName, String lastName, String email) {
        User newUser = new User();
        newUser.FirstName = firstName;
        newUser.LastName = lastName;
        newUser.Email = email;
        newUser.Username = email;
        newUser.Alias = firstName.substring(0, 1) + lastName.substring(0, 1);
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.ProfileId = UserInfo.getProfileId();
        newUser.LanguageLocaleKey = 'en_US';
        newUser.IsActive = true;
        
        return newUser;
    }
    
}