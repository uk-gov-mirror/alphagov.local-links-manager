require 'rails_helper'
require 'local-links-manager/export/bad_links_url_and_status_exporter'

describe LocalLinksManager::Export::BadLinksUrlAndStatusExporter do
  let(:exporter) { LocalLinksManager::Export::BadLinksUrlAndStatusExporter }
  let(:error_problem_summary) { "Received 404 response from the server." }
  let(:warning_problem_summary) { "Received 204 response from the server." }

  describe ".local_authority_bad_homepage_url_and_status_csv" do
    before do
      create(:local_authority, homepage_url: "http://www.hogsmeade.gov.uk", status: "broken", problem_summary: error_problem_summary)
      create(:local_authority, homepage_url: "http://www.littlehangleton.gov.uk", status: "caution", problem_summary: warning_problem_summary)
      create(:local_authority, homepage_url: "http://www.diagonalley.gov.uk", status: "ok")
    end

    it "returns the URL and errors for each local authority with a non-200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("url,status\n")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).to include("http://www.hogsmeade.gov.uk,Received 404 response from the server.\n")
    end

    it "does not return the URL and errors and warnings for a local authority with a 200 homepage" do
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).not_to include("http://www.diagonalley.gov.uk")
      expect(exporter.local_authority_bad_homepage_url_and_status_csv).not_to include("http://www.littlehangleton.gov.uk")
    end
  end

  describe ".bad_links_url_and_status_csv" do
    before do
      create(:link, url: "http://www.hogsmeade.gov.uk/apply-to-hogwarts", status: "broken", problem_summary: error_problem_summary)
      create(:link, url: "http://www.littlehangleton.gov.uk/broomstick-permits", status: "caution", problem_summary: warning_problem_summary)
      create(:link, url: "http://www.diagonalley.gov.uk/report-owl-fouling", status: "ok")
    end

    describe "with regular headings" do
      it "returns the URL and errors and warnings for each non-200 link" do
        expect(exporter.bad_links_url_and_status_csv).to include("url,status\n")
        expect(exporter.bad_links_url_and_status_csv).to include("http://www.hogsmeade.gov.uk/apply-to-hogwarts,Received 404 response from the server.\n")
      end

      it "does not return the URL and status for a 200 link" do
        expect(exporter.bad_links_url_and_status_csv).not_to include("http://www.diagonalley.gov.uk/report-owl-fouling")
        expect(exporter.bad_links_url_and_status_csv).not_to include("http://www.littlehangleton.gov.uk/broomstick-permits")
      end
    end

    describe "with Google Analytics headings" do
      it "returns the URL and errors and warnings for each non-200 link" do
        expect(exporter.bad_links_url_and_status_csv(with_ga_headings: true)).to include("ga:dimension36,ga:dimension37\n")
        expect(exporter.bad_links_url_and_status_csv(with_ga_headings: true)).to include("http://www.hogsmeade.gov.uk/apply-to-hogwarts,Received 404 response from the server.\n")
      end

      it "does not return the URL and status for a 200 link" do
        expect(exporter.bad_links_url_and_status_csv(with_ga_headings: true)).not_to include("http://www.diagonalley.gov.uk/report-owl-fouling")
        expect(exporter.bad_links_url_and_status_csv(with_ga_headings: true)).not_to include("http://www.littlehangleton.gov.uk/broomstick-permits")
      end
    end
  end
end
