require "gds_api/test_helpers/link_checker_api"

describe LocalLinksManager::CheckLinks::LinkStatusUpdater, type: :request do
  include GdsApi::TestHelpers::LinkCheckerApi

  subject(:status_updater) { described_class.new }

  def webhook_secret_token
    Rails.application.credentials.link_checker_api_secret_token
  end

  def generate_signature(body)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), webhook_secret_token, body)
  end

  describe "#update" do
    context "with links for enabled Services" do
      before do
        @time = Timecop.freeze("2016-06-21 09:26:56 +0100")
        @payload = link_checker_api_batch_report_hash(
          id: 1,
          links: [
            {
              uri: link1.url,
              checked: @time,
            },
            {
              uri: link2.url,
              status: :broken,
              checked: @time,
              problem_summary: "Not found",
              suggested_fix: "Find the page somewhere else.",
              errors: ["Received 4xx response"],
              warnings: ["Page not available."],
            },
          ],
        )
      end
      let(:local_authority) { create(:local_authority) }
      let!(:link1) { create(:link, local_authority:, url: "http://www.example.com") }
      let!(:link2) { create(:link, local_authority:, url: "http://www.example.com/exampl.html") }

      it "updates the link's status code and link last checked time in the database" do
        post "/link-check-callback", params: @payload.to_json, headers: { "Content-Type": "application/json", "X-LinkCheckerApi-Signature": generate_signature(@payload.to_json) }

        expect(response).to have_http_status(204)

        expect(link1.reload.status).to eq("ok")
        expect(link2.reload.status).to eq("broken")
        expect(link1.reload.link_last_checked).to eq(@time)
        expect(link2.reload.link_errors[0]).to eq("Received 4xx response")
        expect(link2.reload.link_warnings[0]).to eq("Page not available.")
        expect(link2.reload.problem_summary).to eq("Not found")
        expect(link2.reload.suggested_fix).to eq("Find the page somewhere else.")
        expect(local_authority.reload.broken_link_count).to eq(1)
        expect(local_authority.provided_services.last.broken_link_count).to eq(1)
      end
    end

    context "with an invalid signature" do
      let(:local_authority) { create(:local_authority) }
      let!(:link1) { create(:link, local_authority:, url: "http://www.example.com") }

      before do
        @payload = link_checker_api_batch_report_hash(
          id: 1, links: [{ uri: link1.url }],
        )
      end

      before do
        post "/link-check-callback", params: @payload.to_json, headers: { "Content-Type": "application/json", "X-LinkCheckerApi-Signature": "invalid" }
      end

      it "reports a forbidden error" do
        expect(response).to have_http_status(400)
      end
    end
  end
end
