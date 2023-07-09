import { LightningElement, track, api, wire } from 'lwc';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getWeatherInfo from '@salesforce/apex/WeatherDataController.getWeatherInfo';
import getCityValue from '@salesforce/apex/WeatherDataController.getCityFromAccount';
import sendWeatherReportEmail from '@salesforce/apex/WeatherReportController.sendWeatherReportEmail';
import getLastWeatherReport from '@salesforce/apex/WeatherReportController.getLastWeatherReport';
import imgResources from "@salesforce/resourceUrl/weatherConditions";
import { CurrentPageReference } from 'lightning/navigation';

export default class WeatherComponent extends LightningElement {
    // Wiring the CurrentPageReference
    @wire(CurrentPageReference) pageRef;

    // Resource URL for weather images
    @track weatherIMG = imgResources + '/weather/64x64/';
    @track weatherSRC;
    @track countryCodeSRC;

    // Public properties
    @api userTracking = false;
    @api recordId;
    @api locationField = '';
    @api lastSendingReportField = '';

    // Tracked variables
    @track city = '';
    @track latitude = '';
    @track longitude = '';
    @track isCitySelected = true;
    @track weatherData;
    @track sendingReport;
    @track error;
    @track badgelabel;
    @track badgestate;



    handleSectionToggle(event){
        console.log(event.detail.openSections);
    }


    // Default radio group value
    value = 'city_s';
    // Options for the radio group
    get options() {
        return [
            { label: 'City', value: 'city_s' },
            { label: 'Coordinates', value: 'coordinates_s' },
        ];
    }
    // Tracking field values for conditional rendering
    @track cityFieldValue = true;
    @track coordinatesFieldValue = false;


    // Handler for radio group change
    handleRadioChange(event) {
        const selectedOption = event.detail.value;
        //alert('selectedOption ' + selectedOption);
        if (selectedOption == 'city_s'){
            this.cityFieldValue = true;
        }
        else{
            this.cityFieldValue = false;
        }
        if (selectedOption == 'coordinates_s'){
            this.coordinatesFieldValue = true;
        }else{
            this.coordinatesFieldValue = false;
        }
    }

    // Callback function executed after the component is connected to the DOM
    connectedCallback() {

        // Adding event listeners to input fields
        this.template.addEventListener('rendered', () => {
            const cityInput = this.template.querySelector('lightning-input[data-id="cityInput"]');
            const latitudeInput = this.template.querySelector('lightning-input[data-id="latitudeInput"]');
            const longitudeInput = this.template.querySelector('lightning-input[data-id="longitudeInput"]');

            if (cityInput && latitudeInput && longitudeInput) {
                cityInput.addEventListener('keydown', this.handleKeyDown.bind(this));
                latitudeInput.addEventListener('keydown', this.handleKeyDown.bind(this));
                longitudeInput.addEventListener('keydown', this.handleKeyDown.bind(this));
            }
        });

        if (this.userTracking) {
            this.fetchUserPosition();
        } else if (this.locationField) {
            this.fetchWeatherByCityDefault();
        }


        if (this.isHomePage) {
            // Call Apex method to get the last weather report for the homepage
            getLastWeatherReport({ context: 'HomePage',recordId: null, lastSendingReportField: null })
                .then((result) => {
                    // Handle success response
                    this.badgelabel = 'Last report sent : ' + result;
                    this.badgestate = 'slds-badge';
                })
                .catch((error) => {
                    // Handle error response
                    console.error('Error :', error);
                });
        } else if (this.isRecordPage) {
            // Call Apex method to get the last weather report for the record page
            getLastWeatherReport({ context: 'RecordPage',recordId: this.recordId,lastSendingReportField : this.lastSendingReportField })
                .then((result) => {
                    // Handle success response
                    this.badgelabel = 'Last report sent : ' + result;
                    this.badgestate = 'slds-badge';
                })
                .catch((error) => {
                    // Handle error response
                    console.error('Error :', error);
                });
        }
    }

    // Fetches the user's current position
    fetchUserPosition() {
        // Get the user's current position
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;

                    // Call fetchWeatherByCoordinates by default
                    this.fetchWeatherByCoordinates();
                },
                (error) => {
                    console.error('Error retrieving current position:', error);
                }
            );
        } else {
            console.error('Geolocation is not supported by this browser.');
        }
    }


    // Fetches weather data using the default city value from a record field
    fetchWeatherByCityDefault() {
        if (!this.locationField) {
            return;
        }

        getCityValue({ recordId: this.recordId , fieldAPIName: this.locationField })
            .then(result => {
                this.city = result;
                this.error = null;

                if (this.city) {
                    this.fetchWeatherByCity();
                }

            })
            .catch(error => {
                this.city = null;
                this.error = error.message || 'Unknown error';
                console.error('Error retrieving weather information:', error);
            });

    }

    // Handler for city change event
    handleCityChange(event) {
        this.city = event.target.value;
    }

    // Handler for latitude change event
    handleLatitudeChange(event) {
        this.latitude = event.target.value;
    }

    // Handler for longitude change event
    handleLongitudeChange(event) {
        this.longitude = event.target.value;
    }


    // Fetches weather data based on user input (city or coordinates)
    fetchWeatherData() {
        if (this.cityFieldValue) {
            this.fetchWeatherByCity();
        } else {
            this.fetchWeatherByCoordinates();
        }
    }

    // Fetches weather data by city name
    fetchWeatherByCity() {

        this.error = null;
        this.classError = '';

        if (!this.city) {
            this.error = 'Please enter a City Name.';
            this.classError = 'slds-form-element slds-has-error';
            return;
        }

        getWeatherInfo({ city: this.city })
            .then(result => {
                this.weatherData = result;
                if(this.weatherData != null){
                    let str = this.weatherData.countryCode;
                    this.countryCodeSRC = 'https://flagcdn.com/w20/' + str.toLowerCase() + '.png';
                    this.error = null;
                    this.setWeatherIconBackground(this.weatherData.isSunPresent);
                    this.weatherSRC = this.weatherIMG + this.dayORnight + '/' + this.weatherData.weatherIcon + '.png';
                }else{
                    this.error = 'City Not Found. Please contact the administrator.';
                    this.classError = 'slds-form-element slds-has-error';
                }
            })
            .catch(error => {
                this.weatherData = null;
                this.error = error.message || 'Unknown error';
                console.error('Error retrieving weather information:', error);
                this.error = 'Error retrieving weather information. Please contact the administrator.';
                this.classError = 'slds-form-element slds-has-error';
            });
    }

    // Fetches weather data by lat,lng
    fetchWeatherByCoordinates() {

        this.error = null;
        this.classError = '';

        if (!this.latitude || !this.longitude) {
            this.error = 'Please enter the Latitude and Longitude.';
            this.classError = 'slds-form-element slds-has-error';
            return;
        }

        getWeatherInfo({ latitude: this.latitude, longitude: this.longitude })
            .then(result => {
                this.weatherData = result;

                if(this.weatherData != null){
                    let str = this.weatherData.countryCode;
                    this.countryCodeSRC = 'https://flagcdn.com/w20/' + str.toLowerCase() + '.png';
                    this.error = null;
                    this.setWeatherIconBackground(this.weatherData.isSunPresent);
                    this.weatherSRC = this.weatherIMG + this.dayORnight + '/' + this.weatherData.weatherIcon + '.png';
                }else{
                    this.error = 'No Place Found in this area.';
                    this.classError = 'slds-form-element slds-has-error';
                    return;
                }
                console.log('Weather Data:', this.weatherData);
            })
            .catch(error => {
                this.weatherData = null;
                this.error = 'Error retrieving weather information. Please contact the administrator';
                this.classError = 'slds-form-element slds-has-error';
                console.error('Error retrieving weather information:', error);
            });
    }

    // Sets the background color and weather icon based on the availability of weather data
    setWeatherIconBackground(isSun) {
        console.log('SUN : ', isSun);
      if (isSun) {
        this.weatherIconBackground = 'skyblue'; // Set the background color to skyblue when weather data is available
        this.dayORnight = 'day';
      } else {
        this.weatherIconBackground = 'midnightblue'; // Set a different background color when there is no weather data
        this.dayORnight = 'night';
      }
      console.log('this.dayORnight : ', this.dayORnight);
    }

    // Checks if the current page is the home page
    get isHomePage() {
        return this.pageRef && this.pageRef.type === 'standard__namedPage';
    }

    // Checks if the current page is a record page
    get isRecordPage() {
        return this.pageRef && this.pageRef.type === 'standard__recordPage';
    }

    // Computes the CSS class for the weather icon based on the background color
    get getWeatherIconClass() {
      return `weather-icon ${this.weatherIconBackground}`;
    }

    // Sends the weather report via email
    sendWeatherReport() {
        // Call Apex method to send email
        sendWeatherReportEmail({ weatherData: this.weatherData, recordId: this.recordId, lastSendingReportField: this.lastSendingReportField})
            .then((result) => {
                // Handle success response
                console.log('Email sent successfully');
                this.updateBadgeLabel(result); // Update the badge label with the response (date and time)
            })
            .catch((error) => {
                // Handle error response
                console.error('Error sending email:', error);
            });
    }

    // Updates the badge label based on the sending report result
    updateBadgeLabel(sendingReport) {

        this.sendingReport = sendingReport;
        if (this.sendingReport.isError) {
            this.badgelabel = this.sendingReport.ret;
            this.badgestate = 'slds-badge slds-theme_error';
        }else{
            this.badgelabel = 'Report sent successfully at ' + this.sendingReport.ret;
            this.badgestate = 'slds-badge slds-theme_success';
        }
    }

    // Handles keydown event on input fields to fetch weather data when Enter key is pressed
    handleKeyDown(event) {
        if (event.keyCode === 13) {
            this.fetchWeatherData();
        }
    }
}