require 'google/apis/analyticsreporting_v4'

module GoogleAnalytics
  class ClicksResponse
    include Google::Apis::AnalyticsreportingV4

    def parse(response)
      report = response.reports.first
      report.data.rows.map do |row|
        {
          base_path: row.dimensions.first,
          local_link: row.dimensions.second,
          clicks: row.metrics.first.values.first.to_i
        }
      end
    end
  end
end
