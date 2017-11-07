# Authorisation for Google Analytics custom import

1. Generate a service account (see [Google Documentation](https://developers.google.com/api-client-library/ruby/auth/service-accounts)) 
and store the JSON file provided somewhere safe.
2. Go to the Google Analytics domain where you are trying to set up the custom import. In our case it was `www.gov.uk`.
3. If a custom import has not been set up already, create one using the following settings: 
- Data Set type: Content data
- Import behavior: Processing time
- Data set details: Name - External Link Status, Selected views: consult a GA analyst to choose the correct views for this. 
- Data set schema: 
    - Key: 
        - Name: "External Link Click"
        - ID: 'ga:dimension36'
    - Imported Data:
        - Name: "External Link Click Status"
        - ID: 'ga:dimension37'
    - Overwrite Hit Data: 'No'
4. Next go to Admin -> User Management in Google Analytics, under your domain and grant the service account you setup in step 1 edit access: `https://www.googleapis.com/auth/analytics.edit`.
5. The app assumes the following environment variables are set and made available to it: 
- `GOOGLE_CLIENT_EMAIL` (this is extracted from the JSON file containing the credentials for your service account, in step 1)
- `GOOGLE_PRIVATE_KEY` (this is extracted from the JSON file containing the credentials for your service account, in step 1)
- `GOOGLE_EXPORT_ACCOUNT_ID` (this is obtained from the GA account domain you are trying to upload to. We use the account id for `www.gov.uk`)
- `GOOGLE_EXPORT_TRACKER_ID` (this is the web property UA string associated with the upload. Ex: `UA-XXXXXXXXX-X`)
- `GOOGLE_EXPORT_CUSTOM_DATA_IMPORT_SOURCE_ID` (this is obtained from the custom data import setup in GA. Ex: `abcdeFGHijk12_AB12cd`)

In development mode you can add these to your `local_env.yml` file and they will be turned into environment variables for you. In deployed environments we manage these through govuk-puppet and govuk-secrets.

6. After the authentication is set up, you can run the rake task `export:google_analytics:bad_links` to make your first upload to Google Analytics. 
It should show up in the Custom Import you set up on step 3. 
Be advised that the data being uploaded to Google Analytics will affect the data that already exists there. 
Please use with care and only upload empty docs when testing, like so: 

```
data = "ga:dimension36,ga:dimension37
'',''
"
```
