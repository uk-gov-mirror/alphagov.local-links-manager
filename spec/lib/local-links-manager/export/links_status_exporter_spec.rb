require 'rails_helper'
require 'local-links-manager/export/link_status_exporter'

describe LocalLinksManager::Export::LinkStatusExporter do
  let(:exporter) { LocalLinksManager::Export::LinkStatusExporter }

  describe ".homepage_links_status_csv" do
    it "returns aggregate results of homepage links checks" do
      allow(LocalAuthority).to receive_message_chain("group.count").and_return("Invalid URI" => 11, "Timeout Error" => 10, "Connection failed" => 24, "200" => 371, "404" => 2)

      expect(exporter.homepage_links_status_csv).to eq("status,count\nInvalid URI,11\nTimeout Error,10\nConnection failed,24\n200,371\n404,2\n")
    end
  end

  describe ".links_status_csv" do
    it "returns aggregate results of links checks" do
      allow(Link).to receive_message_chain("enabled_links.group.count").and_return(nil => 7155, "Invalid URI" => 61, "Connection failed" => 628, "500" => 167, "400" => 1, "200" => 72246, "Too many redirects" => 6, "503" => 1, "Timeout Error" => 159, "410" => 78, "401" => 6, "404" => 1814, "403" => 30, "SSL Error" => 110)

      expect(exporter.links_status_csv).to eq("status,count\nnil,7155\nInvalid URI,61\nConnection failed,628\n500,167\n400,1\n200,72246\nToo many redirects,6\n503,1\nTimeout Error,159\n410,78\n401,6\n404,1814\n403,30\nSSL Error,110\n")
    end
  end
end
