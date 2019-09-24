module GoogleAnalytics
  class ClicksResponseFactory
    def self.build(responses)
      Google::Apis::AnalyticsreportingV4::GetReportsResponse.new(
        reports: [
          Google::Apis::AnalyticsreportingV4::Report.new(
            data: Google::Apis::AnalyticsreportingV4::ReportData.new(
              rows:
                responses.map do |response|
                  Google::Apis::AnalyticsreportingV4::ReportRow.new(
                    dimensions: [
                      response.fetch(:base_path),
                      response.fetch(:local_link),
                    ],
                    metrics: [
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          response.fetch(:clicks),
                        ],
                      ),
                    ],
                  )
                end,
            ),
          ),
        ],
      )
    end
  end
end
