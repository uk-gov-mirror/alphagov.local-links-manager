require 'rails_helper'
require 'google/apis/analyticsreporting_v4'

describe GoogleAnalytics::AnalyticsService do
  let(:google_client) { double('client') }
  before { allow(subject).to receive(:client).and_return(google_client) }

  describe '#page_views' do
    it 'returns a hash containing the clicks on a service link' do
      google_response = GoogleAnalytics::ClicksResponseFactory.build([
        { base_path: "/living-statue-permit/sandford",
          local_link: "https://sandford-council.gov.uk/no-for-the-greater-good",
          clicks: 5 }
      ])

      allow(google_client).to receive(:batch_get_reports).and_return(google_response)

      response = subject.activity
      expect(response).to eq([
        {
          base_path: "/living-statue-permit/sandford",
          local_link: "https://sandford-council.gov.uk/no-for-the-greater-good",
          clicks: 5
        }
      ])
    end
  end
end
