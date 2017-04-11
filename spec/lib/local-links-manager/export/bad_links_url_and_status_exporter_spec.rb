require 'rails_helper'
require 'local-links-manager/export/bad_links_url_and_status_exporter'

describe LocalLinksManager::Export::BadLinksUrlAndStatusExporter do
  let(:exporter) { LocalLinksManager::Export::BadLinksUrlAndStatusExporter }
  let(:errors) do
    {
      "404 error (page not found)" => "Received 404 response from the server."
    }
  end
  let(:warnings) do
    {
      "Unusual response" => "Speak to your technical team. Received 204 response from the server."
    }
  end


  describe ".local_authority_bad_homepage_url_and_status_csv" do
    before do
      create(:local_authority, homepage_url: "http://www.hogsmeade.gov.uk", status: "broken", link_errors: errors)
      create(:local_authority, homepage_url: "http://www.littlehangleton.gov.uk", status: "caution", link_warnings: warnings)
      create(:local_authority, homepage_url: "http://www.diagonalley.gov.uk", status: "ok")
    end

    it "returns the URL and errors and warnings for each local authority with a non-200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("url,link_errors,link_warnings\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.hogsmeade.gov.uk,404 error (page not found),\"\"\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.littlehangleton.gov.uk,\"\",Unusual response\n")
    end

    it "does not return the URL and errors and warnings for a local authority with a 200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).not_to include
      "http://www.diagonalley.gov.uk,\"\",\"\"\n"
    end
  end

  describe ".bad_links_url_and_status_csv" do
    before do
      create(:link, url: "http://www.hogsmeade.gov.uk/apply-to-hogwarts", status: "broken", link_errors: errors)
      create(:link, url: "http://www.littlehangleton.gov.uk/broomstick-permits", status: "caution", link_warnings: warnings)
      create(:link, url: "http://www.diagonalley.gov.uk/report-owl-fouling", status: "ok")
    end

    it "returns the URL and errors and warnings for each non-200 link" do
      expect(exporter.bad_links_url_and_status_csv).to include("url,link_errors,link_warnings\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.hogsmeade.gov.uk/apply-to-hogwarts,404 error (page not found),\"\"\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.littlehangleton.gov.uk/broomstick-permits,\"\",Unusual response\n")
    end

    it "does not return the URL and errors and warnings for a 200 link" do
      expect(exporter.bad_links_url_and_status_csv).not_to include
      "http://www.diagonalley.gov.uk/report-owl-fouling,\"\",\"\"\n"
    end
  end
end
