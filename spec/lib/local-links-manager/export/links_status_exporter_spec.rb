require "local_links_manager/export/link_status_exporter"

describe LocalLinksManager::Export::LinkStatusExporter do
  let(:exporter) { LocalLinksManager::Export::LinkStatusExporter }

  describe ".homepage_links_status_csv" do
    before do
      11.times { create(:local_authority, status: "broken", problem_summary: "Invalid URI") }
      10.times { create(:local_authority, status: "broken", problem_summary: "Timeout Error") }
      24.times { create(:local_authority, status: "broken", problem_summary: "Connection failed") }
      31.times { create(:local_authority, status: "broken", problem_summary: "200") }
      2.times  { create(:local_authority, status: "broken", problem_summary: "404") }
    end

    it "returns aggregate results of homepage links checks" do
      expect(exporter.homepage_links_status_csv).to include("problem_summary,count,status\n")
      expect(exporter.homepage_links_status_csv).to include("Invalid URI,11,broken\n")
      expect(exporter.homepage_links_status_csv).to include("Timeout Error,10,broken\n")
      expect(exporter.homepage_links_status_csv).to include("Connection failed,24,broken\n")
      expect(exporter.homepage_links_status_csv).to include("200,31,broken\n")
      expect(exporter.homepage_links_status_csv).to include("404,2,broken\n")
    end
  end

  describe ".links_status_csv" do
    it "returns aggregate results of links checks" do
      7.times { create(:link, status: nil) }
      6.times { create(:link, status: "broken", problem_summary: "Invalid URI") }
      2.times { create(:link, status: "broken", problem_summary: "Connection failed") }
      1.times { create(:link, status: "broken", problem_summary: "500") }
      1.times { create(:link, status: "broken", problem_summary: "400") }
      4.times { create(:link, status: "broken", problem_summary: "200") }
      6.times { create(:link, status: "broken", problem_summary: "Too many redirects") }
      5.times { create(:link, status: "broken", problem_summary: "503") }
      8.times { create(:link, status: "broken", problem_summary: "Timeout Error") }
      3.times { create(:link, status: "broken", problem_summary: "410") }
      9.times { create(:link, status: "broken", problem_summary: "401") }
      2.times { create(:link, status: "broken", problem_summary: "404") }
      2.times { create(:link, status: "broken", problem_summary: "403") }
      1.times { create(:link, status: "broken", problem_summary: "SSL Error") }

      expect(exporter.links_status_csv).to include("problem_summary,count,status\n")
      expect(exporter.links_status_csv).to include("nil,7,nil\n")
      expect(exporter.links_status_csv).to include("Invalid URI,6,broken\n")
      expect(exporter.links_status_csv).to include("Connection failed,2,broken\n")
      expect(exporter.links_status_csv).to include("500,1,broken\n")
      expect(exporter.links_status_csv).to include("400,1,broken\n")
      expect(exporter.links_status_csv).to include("200,4,broken\n")
      expect(exporter.links_status_csv).to include("Too many redirects,6,broken\n")
      expect(exporter.links_status_csv).to include("503,5,broken\n")
      expect(exporter.links_status_csv).to include("Timeout Error,8,broken\n")
      expect(exporter.links_status_csv).to include("410,3,broken\n")
      expect(exporter.links_status_csv).to include("401,9,broken\n")
      expect(exporter.links_status_csv).to include("404,2,broken\n")
      expect(exporter.links_status_csv).to include("403,2,broken\n")
      expect(exporter.links_status_csv).to include("SSL Error,1,broken\n")
    end
  end
end
