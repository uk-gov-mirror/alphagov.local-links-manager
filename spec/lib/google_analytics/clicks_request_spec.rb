require 'rails_helper'

module GoogleAnalytics
  describe ClicksRequest do
    before do
      @google_analytics_govuk_view_id = ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]
      ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"] = "12345678"
    end

    after do
      ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"] = @google_analytics_govuk_view_id
    end

    context "Get number of page views from the Google Analytics Reporting API" do
      let(:page_views_request) do
        {
          report_requests: [
            {
              metrics: [
                {
                  expression: "ga:totalEvents"
                }
              ],
              view_id: "12345678",
              dimension_filter_clauses: [
                {
                  operator: "AND",
                  filters: [
                    {
                      expressions: %w[local_transaction],
                      dimension_name: "ga:dimension2",
                      operator: "EXACT"
                    },
                    {
                      expressions: ["http://www.royalmail.com/find-a-postcode"],
                      dimension_name: "ga:eventAction",
                      operator: "EXACT",
                      not: true,
                    },
                    {
                      expressions: ["External Link Clicked"],
                      dimension_name: "ga:eventCategory",
                      operator: "EXACT"
                    }
                  ]
                }
              ],
              dimensions: [
                { name: "ga:pagePath" },
                { name: "ga:eventAction" },
              ],
              date_ranges: [
                {
                  start_date: "7daysAgo",
                  end_date: "today",
                }
              ],
              order_bys: [
                {
                  field_name: "ga:totalEvents",
                  sort_order: "DESCENDING"
                }
              ],
              page_size: 10000
            }
          ]
        }.deep_stringify_keys!
      end

      it "builds the request body" do
        request = ClicksRequest.new.build

        expect(request.as_json).to include(page_views_request)
      end
    end
  end
end
