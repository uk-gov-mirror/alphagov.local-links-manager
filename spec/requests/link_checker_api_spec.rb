require 'rails_helper'
require 'local-links-manager/check_links/link_status_updater'
require "gds_api/test_helpers/link_checker_api"

describe LocalLinksManager::CheckLinks::LinkStatusUpdater, type: :request do
  include GdsApi::TestHelpers::LinkCheckerApi

  subject(:status_updater) { described_class.new }


  describe "#update" do
    context "with links for enabled Services" do
      before do
        @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
      end
      let(:local_authority) { FactoryGirl.create(:local_authority) }
      let!(:link_1) { FactoryGirl.create(:link, local_authority: local_authority, url: "http://www.example.com") }
      let!(:link_2) { FactoryGirl.create(:link, local_authority: local_authority, url: "http://www.example.com/exampl.html") }

      it "updates the link's status code and link last checked time in the database" do
        payload = link_checker_api_batch_report_hash(
          id: 1,
          links: [
            {
              uri: link_1.url,
              checked: @time
            },
            {
              uri: link_2.url,
              status: :broken,
              checked: @time,
              errors: {
                http_client_error: "Received 4xx response"
              },
              warnings: {
                http_non_200: "Page not available."
              },
            }
          ]
        )

        post "/link-check-callback", params: payload.to_json, headers: { "Content-Type": "application/json" }

        expect(link_1.reload.status).to eq("ok")
        expect(link_2.reload.status).to eq("broken")
        expect(link_1.reload.link_last_checked).to eq(@time)
        expect(link_2.reload.link_errors).to eq({
          "http_client_error" => "Received 4xx response"
        })
        expect(link_2.reload.link_warnings).to eq({
          "http_non_200" => "Page not available."
        })
        expect(local_authority.reload.broken_link_count).to eq(1)
        expect(local_authority.provided_services.last.broken_link_count).to eq(1)
      end
    end
  end
end
