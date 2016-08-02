require 'rails_helper'
require 'local-links-manager/import/local_authorities_url_importer'

describe LocalLinksManager::Import::LocalAuthoritiesURLImporter, :csv_importer do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  def stub_slug_csv_request(data)
    stub_request(:any, "http://local.direct.gov.uk/Data/local_authority_contact_details.csv").
      to_return(body: data,
      status: 200,
      headers: { 'Content-Length' => data.length })
  end

  describe "#import_urls" do
    let(:csv_downloader) { instance_double CsvDownloader }

    context 'when homepage url download is successful' do
      it "should import the homepage URLs from the csv file" do
        FactoryGirl.create(:local_authority, snac: "45UB", homepage_url: nil)

        csv_file = File.read(fixture_file("local_contacts_sample.csv"))

        stub_csv_rows(CSV.parse(csv_file, headers: true))

        la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
        expect(la_url_importer.import_records).to be_successful

        la_adur = LocalAuthority.find_by(snac: "45UB")

        expect(la_adur.homepage_url).to eq("http://www.adur.gov.uk")
      end

      it "should ensure that URLs start with 'http' or 'https'" do
        FactoryGirl.create(:local_authority, name: 'london', snac: "45UB")
        FactoryGirl.create(:local_authority, name: 'exeter', snac: "16UB")

        csv_stub = "Name,Home page URL,Contact page URL,SNAC Code,Address Line 1,Address Line 2,Town,City,County,Postcode,Telephone Number 1 Description,Telephone Number 1,Telephone Number 2 Description,Telephone Number 2,Telephone Number 3 Description,Telephone Number 3,Fax,Main Contact Email,Opening Hours
                    Adur District Council,www.adur.gov.uk,,45UB,,,,,,,,,,,,,,,
                    Allerdale Borough Council,https://www.allerdale.gov.uk,,16UB,,,,,,,,,,,,,,,"

        stub_csv_rows(CSV.parse(csv_stub, headers: true))

        la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
        expect(la_url_importer.import_records).to be_successful

        la_adur = LocalAuthority.find_by(snac: "45UB")
        expect(la_adur.homepage_url).to eq("http://www.adur.gov.uk")

        la_allerdale = LocalAuthority.find_by(snac: "16UB")
        expect(la_allerdale.homepage_url).to eq("https://www.allerdale.gov.uk")
      end
    end

    context 'when services download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        response = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include('Error downloading CSV')
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        response = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include('Malformed CSV error')
      end
    end

    context 'when runtime error is raised' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(RuntimeError, "RuntimeError")

        expect(Rails.logger).to receive(:error).with(/Error RuntimeError/)

        response = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error RuntimeError/)
      end
    end

    context 'check imported data' do
      context "when any homepage URLs are blank or empty after an import" do
        it "should return response with gss codes of missing homepage urls" do
          FactoryGirl.create(:local_authority, name: 'adur', snac: "45UB", gss: "1234")
          FactoryGirl.create(:local_authority, name: 'allerdale', snac: "16UB", gss: "9876")

          csv_stub = "Name,Home page URL,Contact page URL,SNAC Code,Address Line 1,Address Line 2,Town,City,County,Postcode,Telephone Number 1 Description,Telephone Number 1,Telephone Number 2 Description,Telephone Number 2,Telephone Number 3 Description,Telephone Number 3,Fax,Main Contact Email,Opening Hours
                      Adur District Council,,,45UB,,,,,,,,,,,,,,,
                      Allerdale Borough Council,https://www.allerdale.gov.uk,,16UB,,,,,,,,,,,,,,,"

          stub_csv_rows(CSV.parse(csv_stub, headers: true))

          la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
          response = la_url_importer.import_records
          expect(response).to_not be_successful
          expect(response.errors).to include("Missing homepage url for gss:\n1234")
        end
      end
    end
  end
end
