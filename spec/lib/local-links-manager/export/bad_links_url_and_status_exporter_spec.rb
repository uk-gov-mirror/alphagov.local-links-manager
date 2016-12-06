require 'rails_helper'
require 'local-links-manager/export/bad_links_url_and_status_exporter'

describe LocalLinksManager::Export::BadLinksUrlAndStatusExporter do
  let(:exporter) { LocalLinksManager::Export::BadLinksUrlAndStatusExporter }


  describe ".local_authority_bad_homepage_url_and_status_csv" do
    before do
      create(:local_authority, homepage_url: "http://www.hogsmeade.gov.uk", status: "403")
      create(:local_authority, homepage_url: "http://www.godricshollow.gov.uk", status: "Timeout Error")
      create(:local_authority, homepage_url: "http://www.azkaban.gov.uk/", status: "Connection failed")
      create(:local_authority, homepage_url: "http://www.littlehangleton.gov.uk", status: "404")
      create(:local_authority, homepage_url: "http://www.diagonalley.gov.uk", status: "200")
    end

    it "returns the URL and status for each local authority with a non-200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("url,status\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.hogsmeade.gov.uk,403\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.azkaban.gov.uk/,Connection failed\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.littlehangleton.gov.uk,404\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.godricshollow.gov.uk,Timeout Error\n")
    end

    it "does not return the URL and status for a local authority with a 200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).not_to include
      "http://www.diagonalley.gov.uk,200"
    end
  end

  describe ".bad_links_url_and_status_csv" do
    before do
      create(:link, url: "http://www.hogsmeade.gov.uk/apply-to-hogwarts", status: "403")
      create(:link, url: "http://www.godricshollow.gov.uk/report-a-broken-wand", status: "Timeout Error")
      create(:link, url: "http://www.azkaban.gov.uk/magical-waste", status: "Connection failed")
      create(:link, url: "http://www.littlehangleton.gov.uk/broomstick-permits", status: "404")
      create(:link, url: "http://www.diagonalley.gov.uk/report-owl-fouling", status: "200")
    end

    it "returns the URL and status for each non-200 link" do
      expect(exporter.bad_links_url_and_status_csv).to include("url,status\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.littlehangleton.gov.uk/broomstick-permits,404\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.godricshollow.gov.uk/report-a-broken-wand,Timeout Error\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.hogsmeade.gov.uk/apply-to-hogwarts,403\n")
      expect(exporter.bad_links_url_and_status_csv).to include("http://www.azkaban.gov.uk/magical-waste,Connection failed\n")
    end

    it "does not return the URL and status for a 200 link" do
      expect(exporter.bad_links_url_and_status_csv).not_to include
      "http://www.diagonalley.gov.uk/report-owl-fouling,200"
    end
  end
end
