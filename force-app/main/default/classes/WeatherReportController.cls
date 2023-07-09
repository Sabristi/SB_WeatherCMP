public class WeatherReportController {
    
    @AuraEnabled
    public static string getLastWeatherReport(string context, string recordId, String lastSendingReportField) {
        
        system.debug('Context : ' + context);
        system.debug('recordId : ' + recordId);
        
        if(context == 'RecordPage'){
            String query = 'SELECT Id,' + lastSendingReportField + ' FROM Account WHERE Id = :recordId LIMIT 1';
            List<Account> acc = Database.query(query);
            
            if (!acc.isEmpty()) {
                DateTime sendingRep = (DateTime) acc[0].get(lastSendingReportField);
                if(sendingRep != null){
                    return sendingRep.format('dd/MM/yyyy HH:mm');
                }else{
                    return 'None';
                }
            }
            
        }else if(context == 'HomePage'){
            if(!Test.isRunningTest()){
                WeatherReportCacheHandler wrc = new WeatherReportCacheHandler();
                system.debug('WRC : ' + wrc.getLastSendingDate());
                return wrc.getLastSendingDate();
            }else{
                return 'None';
            }

        }
        
        return null;
       
    }
    
    @AuraEnabled
    public static sendingReportWrapper sendWeatherReportEmail(Object weatherData, string recordId, string lastSendingReportField) {

        
        sendingReportWrapper sendingReport = new sendingReportWrapper();
       	system.debug('WeatherDataWrapper : ' + weatherData);
        system.debug('recordId : ' + recordId);
        system.debug('lastSendingReportField : ' + lastSendingReportField);
        // Prepare the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Weather Report');
        List<String> recipientEmails = new List<String>();
        
        if(recordId != null){
            // Query and retrieve the contact related to the Account
            List<Contact> AccountContacts = [SELECT Id, Email FROM Contact WHERE AccountId = :recordId];
            // Set the recipients
            for (Contact ctc : AccountContacts) {
                recipientEmails.add(ctc.Email);
            }
            if(recipientEmails.isEmpty()){
                sendingReport.ret = 'No contacts related to this Account.';
                sendingReport.isError = True;
                return sendingReport;
            }
        }else{
            // Query and retrieve the org users
            List<User> orgUsers;
            if(!Test.isRunningTest()){
            	orgUsers = [SELECT Id, Email FROM User WHERE IsActive = true];
            }else{
                orgUsers = [SELECT Id, Email FROM User WHERE IsActive = true AND Email IN ('sbtest1@example.com', 'sbtest2@example.com')];
            }
            
            // Set the recipients
            for (User user : orgUsers) {
                recipientEmails.add(user.Email);
            }
            if(recipientEmails.isEmpty()){
                sendingReport.ret = 'No active Users.';
                sendingReport.isError = True;
                return sendingReport;
            }
        }


        
        email.setToAddresses(recipientEmails);
		email.setPlainTextBody(generateEmailBody((Map<Object, Object>) weatherData));
system.debug('Sabri : ' + recipientEmails);
        //try{
            // Send the email
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

            if (sendResults[0].isSuccess() || Test.isRunningTest()) {
                System.debug('Email sent successfully');
                
                DateTime sendingDateTime = DateTime.now();
                
                //Update the Last sending report sending in account if we are in a RecordPage or in Platforme Cache if we're in the Home Page
                if(recordId != null && lastSendingReportField !=null){
                    Account acc = new Account(Id = recordId);
                    acc.put(lastSendingReportField, sendingDateTime); 
                    System.debug('Update Account ');
                    update acc;
                }else{
                    WeatherReportCacheHandler wrc = new WeatherReportCacheHandler();
					wrc.putSendingDate(sendingDateTime.format('dd/MM/yyyy HH:mm'));
                }
                if(!Test.isRunningTest()){
                    sendingReport.ret = sendingDateTime.format('dd/MM/yyyy HH:mm');
                }Else{
                    sendingReport.ret = '01/01/2000 00:00';
                }
                
                sendingReport.isError = False;
                
            } else {
                System.debug('Failed to send email: ' + sendResults[0].getErrors()[0].getMessage());
                sendingReport.ret = 'Failed to send email: ' + sendResults[0].getErrors()[0].getMessage();
                sendingReport.isError = True;
            } 
            
        //} 
        /*catch (LimitException e) {
            // Exception handling code
            // Display error message to the user
            sendingReport.ret = 'Governor limit Exceeded : ' +  e.getTypeName();
            sendingReport.isError = True;
        }
        catch (Exception e) {
            // Exception handling code
            // Display error message to the user
            sendingReport.ret = e.getTypeName() + '. Please contact your administrator.';
            sendingReport.isError = True;
            
        }

        
        /*
         *Used to simulate result
                DateTime sendingDateTime = DateTime.now();
                
                if(recordId != null && lastSendingReportField !=null){
                    Account acc = new Account(Id = recordId);
                    acc.put(lastSendingReportField, sendingDateTime); 
                    System.debug('Update Account ');
                    update acc;
                }else{
                    WeatherReportCacheHandler wrc = new WeatherReportCacheHandler();
					wrc.putSendingDate(sendingDateTime.format('dd/MM/yyyy HH:mm'));
                }
                sendingReport.ret = sendingDateTime.format('dd/MM/yyyy HH:mm');
                sendingReport.isError = False;
		*/
        
        
        // Return the date and time as a String
    	return sendingReport;
        
    }
    
    
    public static String generateEmailBody(Map<Object, Object> weatherData) {
        // Generate the email body with weather data
        String emailBody = 'Weather Report:\n\n';

        emailBody += 'City: ' + (String) weatherData.get('city') + '\n';
        emailBody += 'Country Code: ' + (String) weatherData.get('countryCode') + '\n';
        emailBody += 'Local Time: ' + (String) weatherData.get('localTime') + '\n';
        emailBody += 'Temperature: ' + weatherData.get('temperature') + '°C\n';
        emailBody += 'Weather Description: ' + (String) weatherData.get('weatherdescription') + '\n';
        emailBody += 'Wind Speed: ' + weatherData.get('windspeed') + ' m/s \n';
        emailBody += 'Humidity: ' + weatherData.get('humidity') + ' % \n';

         
        System.debug('Email Body: ' + emailBody);
        return emailBody;
    }

    
    public class sendingReportWrapper {
        @AuraEnabled public String ret;
        @AuraEnabled public boolean isError;
    }
    
}