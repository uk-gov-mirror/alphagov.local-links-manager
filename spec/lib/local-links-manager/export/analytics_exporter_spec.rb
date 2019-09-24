require "google/apis/analytics_v3"
require "googleauth"
require "local-links-manager/export/analytics_exporter"
require "local-links-manager/export/bad_links_url_and_status_exporter"

describe LocalLinksManager::Export::AnalyticsExporter do
  let(:authorizer) { Google::Auth::ServiceAccountCredentials.new }
  let(:csv_file) { File.read(File.expand_path("fixtures/bad_links_url_status.csv", File.dirname(__FILE__))) }

  before do
    ENV["GOOGLE_CLIENT_EMAIL"] = "email@email.com"
    ENV["GOOGLE_PRIVATE_KEY"] = "123456"

    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)

    create(:broken_link, url: "http://www.carmarthenshire.gov.uk/Cymraeg/addysg/childrens-services/Pages/fostering.aspx", problem_summary: "Page not found")
    create(:broken_link, url: "http://www.warwickshire.gov.uk/azrecycling", problem_summary: "Website unavailable")
    create(:broken_link, url: "http://www.southoxon.gov.uk/dogwardens", problem_summary: "Page requires login")
    create(:broken_link, url: "https://portal.southtyneside.info/eservices/frmHomepage.aspx?FunctionId=79&ignore=0", problem_summary: "Security Error")
  end

  describe "#initialize" do
    it "returns an authorized GA service" do
      expect(subject.client.service.authorization).to eq(authorizer)
    end
  end

  describe "#bad_links_data" do
    it "exports the links to CSV format with headings" do
      expect(subject.bad_links_data.split("\n")).to match_array(csv_file.split("\n"))
    end
  end

  describe "#export_bad_links" do
    let(:upload_response) {
      double(Google::Apis::AnalyticsV3::Upload,
             account_id: "1234",
             custom_data_source_id: "abcdefg",
             id: "AbCd-1234",
             kind: "analytics#upload",
             status: "PENDING")
    }

    let(:uploaded_item) {
      double(Google::Apis::AnalyticsV3::Upload,
             account_id: "1234",
             custom_data_source_id: "abcdefg",
             id: "AbCd-1234",
             kind: "analytics#upload",
             status: "COMPLETED")
    }
    let(:uploaded_item2) {
      double(Google::Apis::AnalyticsV3::Upload,
             account_id: "1234",
             custom_data_source_id: "abcdefg",
             errors: ["Column headers missing for the input file."],
             id: "AbCd-1234",
             kind: "analytics#upload",
             status: "FAILED",
             upload_time: "Thu, 11 Jan 2018 12:36:35 +0000")
    }

    let(:upload_list) {
      double(Google::Apis::AnalyticsV3::Upload,
             items: [uploaded_item, uploaded_item2],
             items_per_page: 1000,
             kind: "analytics#uploads",
             start_index: 1,
             total_results: 3)
    }

    it "it uploads the CSV file to GA" do
      allow(subject.client.service).to receive(:upload_data).and_return(upload_response)
      allow(subject.client.service).to receive(:list_uploads).and_return(upload_list)

      expect(subject.export_bad_links).to eq(upload_response)
    end
  end
end
