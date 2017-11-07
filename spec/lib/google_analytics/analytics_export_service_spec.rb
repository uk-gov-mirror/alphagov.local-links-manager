require 'rails_helper'
require 'google/apis/analytics_v3'
require 'googleauth'

describe GoogleAnalytics::AnalyticsExportService do
  let(:service) { Google::Apis::AnalyticsV3::AnalyticsService.new }
  let(:authorizer) { Google::Auth::ServiceAccountCredentials.new }
  let(:data) { "ga:dimension36,ga:dimension37\n'www.google.com','OK'\n" }
  let(:scope) { 'https://www.googleapis.com/auth/analytics.edit' }

  before do
    ENV['GOOGLE_CLIENT_EMAIL'] = 'email@email.com'
    ENV['GOOGLE_PRIVATE_KEY'] = '123456'
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
  end

  describe '#build' do
    it 'returns an authorized GA Service' do
      subject.build

      expect(subject.service.authorization).to eq(authorizer)
    end
  end

  describe '#export_bad_links' do
    let(:upload_response) { GoogleAnalytics::UploadResponseFactory.build }
    let(:upload_response) {
      double(Google::Apis::AnalyticsV3::Upload,
                                    account_id: '1234',
                                    custom_data_source_id: 'abcdefg',
                                    id: 'AbCd-1234',
                                    kind: 'analytics#upload',
                                    status: 'PENDING')
    }

    it 'returns a confirmation that the data has been received' do
      subject.build

      allow(subject.service).to receive(:upload_data).and_return(upload_response)

      expect(subject.export_bad_links(data)).to eq(upload_response)
    end
  end
end
