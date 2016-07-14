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

  describe "import_urls" do
    let(:csv_downloader) { instance_double CsvDownloader }

    it "should import the homepage URLs from the csv file" do
      FactoryGirl.create(:local_authority, snac: "45UB", homepage_url: nil)

      csv_file = File.read(fixture_file("local_contacts_sample.csv"))

      stub_csv_rows(CSV.parse(csv_file, headers: true))

      la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
      la_url_importer.import_records

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
      la_url_importer.import_records

      la_adur = LocalAuthority.find_by(snac: "45UB")
      expect(la_adur.homepage_url).to eq("http://www.adur.gov.uk")

      la_allerdale = LocalAuthority.find_by(snac: "16UB")
      expect(la_allerdale.homepage_url).to eq("https://www.allerdale.gov.uk")
    end

    context "when any homepage URLs are blank or empty after an import" do
      it "should alert Icinga" do
        FactoryGirl.create(:local_authority, name: 'adur', snac: "45UB")
        FactoryGirl.create(:local_authority, name: 'allerdale', snac: "16UB")

        csv_stub = "Name,Home page URL,Contact page URL,SNAC Code,Address Line 1,Address Line 2,Town,City,County,Postcode,Telephone Number 1 Description,Telephone Number 1,Telephone Number 2 Description,Telephone Number 2,Telephone Number 3 Description,Telephone Number 3,Fax,Main Contact Email,Opening Hours
                    Adur District Council,,,45UB,,,,,,,,,,,,,,,
                    Allerdale Borough Council,https://www.allerdale.gov.uk,,16UB,,,,,,,,,,,,,,,"

        stub_csv_rows(CSV.parse(csv_stub, headers: true))

        la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
        la_url_importer.import_records

        expect(LocalLinksManager::Import::LocalAuthoritiesURLImporter).to receive(:alert_missing_urls)

        LocalLinksManager::Import::LocalAuthoritiesURLImporter.alert_empty_urls("Check for blank homepage urls in local-links-manager")
      end
    end

    context "when all homepage URLs are populated after an import" do
      it "should tell Icinga that everything is OK" do
        FactoryGirl.create(:local_authority, name: 'allerdale', snac: "16UB")

        csv_stub = "Name,Home page URL,Contact page URL,SNAC Code,Address Line 1,Address Line 2,Town,City,County,Postcode,Telephone Number 1 Description,Telephone Number 1,Telephone Number 2 Description,Telephone Number 2,Telephone Number 3 Description,Telephone Number 3,Fax,Main Contact Email,Opening Hours
                    Allerdale Borough Council,https://www.allerdale.gov.uk,,16UB,,,,,,,,,,,,,,,"

        stub_csv_rows(CSV.parse(csv_stub, headers: true))

        la_url_importer = LocalLinksManager::Import::LocalAuthoritiesURLImporter.new(csv_downloader)
        la_url_importer.import_records

        expect(LocalLinksManager::Import::LocalAuthoritiesURLImporter).to receive(:confirm_no_missing_urls)

        LocalLinksManager::Import::LocalAuthoritiesURLImporter.alert_empty_urls("Check for blank homepage urls in local-links-manager")
      end
    end
  end
end
