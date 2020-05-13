require "google/apis/analytics_v3"
require "googleauth"

describe GoogleAnalytics::AnalyticsExportService do
  let(:service) { Google::Apis::AnalyticsV3::AnalyticsService.new }
  let(:authorizer) { Google::Auth::ServiceAccountCredentials.new }
  let(:data) { "ga:dimension36,ga:dimension37\n'www.google.com','OK'\n" }
  let(:scope) { "https://www.googleapis.com/auth/analytics.edit" }
  let(:upload_response) do
    double(Google::Apis::AnalyticsV3::Upload,
           account_id: "1234",
           custom_data_source_id: "abcdefg",
           id: "AbCd-1234",
           kind: "analytics#upload",
           status: "PENDING")
  end

  let(:uploaded_item) do
    double(Google::Apis::AnalyticsV3::Upload,
           account_id: "1234",
           custom_data_source_id: "abcdefg",
           id: "AbCd-1234",
           kind: "analytics#upload",
           status: "COMPLETED")
  end
  let(:uploaded_item2) do
    double(Google::Apis::AnalyticsV3::Upload,
           account_id: "1234",
           custom_data_source_id: "abcdefg",
           errors: ["Column headers missing for the input file."],
           id: "AbCd-1234",
           kind: "analytics#upload",
           status: "FAILED",
           upload_time: "Thu, 11 Jan 2018 12:36:35 +0000")
  end

  let(:upload_list) do
    double(Google::Apis::AnalyticsV3::Upload,
           items: [uploaded_item, uploaded_item2],
           items_per_page: 1000,
           kind: "analytics#uploads",
           start_index: 1,
           total_results: 3)
  end

  before do
    ENV["GOOGLE_CLIENT_EMAIL"] = "email@email.com"
    ENV["GOOGLE_PRIVATE_KEY"] = "123456"
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
  end

  describe "#build" do
    it "returns an authorized GA Service" do
      subject.build

      expect(subject.service.authorization).to eq(authorizer)
    end
  end

  describe "#export_bad_links" do
    it "returns a confirmation that the data has been received" do
      subject.build

      allow(subject.service).to receive(:upload_data).and_return(upload_response)
      allow(subject.service).to receive(:list_uploads).and_return(upload_list)

      expect(subject.export_bad_links(data)).to eq(upload_response)
    end
  end

  describe "#delete_previous_uploads" do
    let(:uploaded_item3) do
      double(Google::Apis::AnalyticsV3::Upload,
             account_id: "1234",
             custom_data_source_id: "abcdefg",
             errors: ["Column headers missing for the input file."],
             id: "AbCd-1234",
             kind: "analytics#upload",
             status: "FAILED",
             upload_time: "Thu, 13 Jan 2018 12:36:35 +0000")
    end

    let(:upload_list2) do
      double(Google::Apis::AnalyticsV3::Upload,
             items: [uploaded_item, uploaded_item2, uploaded_item3],
             items_per_page: 1000,
             kind: "analytics#uploads",
             start_index: 1,
             total_results: 3)
    end

    before do
      subject.build
      allow(subject.service).to receive(:list_uploads).and_return(upload_list)
      allow(subject.service).to receive(:delete_upload_data).and_return("")
    end

    it "doesn't delete any files if 2 files are uploaded to GA if no minimum file limit is provided" do
      expect(subject.delete_previous_uploads).to eq("Need more than 2 to start deleting")
    end

    it "doesn't delete any files if 3 files are uploaded to GA and the minimum file limit provided is 3" do
      allow(subject.service).to receive(:list_uploads).and_return(upload_list2)
      expect(subject.delete_previous_uploads(3)).to eq("Need more than 3 to start deleting")
    end

    it "deletes if the number of files is more than the default we expect to leave untouched in GA" do
      allow(subject.service).to receive(:list_uploads).and_return(upload_list2)

      expect(subject.delete_previous_uploads).to eq("Successfully deleted")
    end
  end
end
