![BannerSBWeather](https://github.com/Sabristi/SB_WeatherCMP/blob/main/media/BannerSBWeather.jpg?raw=true)

## Introduction

The Weather Observation Component provides a convenient way to retrieve and display weather information in real-time within the Salesforce platform, both as a standalone component on the homepage and as an integrated feature in the Account layout. The ability to send weather reports and track their delivery adds value to the solution. 

![Screenshot2](https://github.com/Sabristi/SB_WeatherCMP/blob/main/media/Weather3.PNG?raw=true)

## Deployment Kit

To deploy SB_WeatherCMP to your Salesforce org, you can use Salesforce's official deployment tools like Salesforce CLI or the Salesforce Extensions for Visual Studio Code. Here's a general overview of the process:

1. Set up Salesforce CLI:
Install Salesforce CLI by following the instructions for your operating system: https://developer.salesforce.com/tools/sfdxcli
Open a terminal or command prompt and verify the installation by running ```sfdx --version```.
Connect to your Salesforce org:

2. Run ```sfdx force:auth:web:login -a <alias>``` in the terminal. If you're in a Sandbox environment, run ```sfdx force:auth:web:login -r https://test.salesforce.com -a <alias>```
<alias> refers to an alias or name that you can assign to a Salesforce org during the authentication process.
Follow the authentication process to log in to your Salesforce org and authorize the CLI.

4. Clone the Git repository:
Use the git clone command to clone the Git repository to your local machine.
```git clone https://github.com/Sabristi/SB_WeatherCMP.git```

5. Navigate to the repository's directory:
In the terminal, using the cd command change your working directory to the cloned repository folder, then to the manifest folder whene the package.xml is located. ```cd SB_WeatherCMP/manifest```

6. Use the sfdx force:source:deploy command to deploy the package to your Salesforce org. Deploy using the package manifest file (package.xml), by adding the --manifest option with the force:source:deploy command.
```sfdx force:source:deploy --manifest package.xml -u <Salesforce username>```

7. Monitor the deployment process:
The deployment process may take few seconds. Salesforce CLI will provide real-time feedback on the progress and results of the deployment.

## LWC Set Up
### Home Page
![HomePage setup](https://github.com/Sabristi/SB_WeatherCMP/blob/main/media/Weather4.jpg?raw=true)
+ Attribute ```UserTracking``` to display by default the wheather using the current user location.
  
### Account Record Page
![AccountRecordPage setup](https://github.com/Sabristi/SB_WeatherCMP/blob/main/media/Weather5.jpg?raw=true)
+ Attribute ```locationfield``` to define in which field the City information is stored in order to display by default the weather where the customer is located.
+ Attribute ```lastSendingReportField``` to define in which Account field should be stored the Date Time of the last sending report in order to track it.  
