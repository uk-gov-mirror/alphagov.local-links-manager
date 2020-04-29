require "google/apis/analyticsreporting_v4"

module GoogleAnalytics
  class ClicksRequest
    include Google::Apis::AnalyticsreportingV4

    def initialize
      @event_category = "ga:eventCategory".freeze
      @format = "ga:dimension2".freeze
      @link_url = "ga:eventAction".freeze
      @page_path = "ga:pagePath".freeze
      @total_events = "ga:totalEvents".freeze
      @unique_page_views = "ga:uniquePageviews".freeze
    end

    def build
      GetReportsRequest.new.tap do |reports|
        reports.report_requests = Array.new.push(
          ReportRequest.new.tap do |request|
            request.metrics = metrics
            request.view_id = view_id
            request.dimension_filter_clauses = filters
            request.dimensions = dimensions(page_path, link_url)
            request.date_ranges = last_week
            request.order_bys = order_bys
            request.page_size = 10_000
          end,
        )
      end
    end

  private

    attr_reader :event_category, :format, :link_url, :page_path, :total_events, :unique_page_views

    def last_week
      date_range = DateRange.new
      date_range.start_date = "7daysAgo"
      date_range.end_date = "today"
      [date_range]
    end

    def dimensions(*dimension_names)
      dimension_names.map do |dimension_name|
        Dimension.new.tap do |dimension|
          dimension.name = dimension_name
        end
      end
    end

    def filters
      dimension_filter_clause = DimensionFilterClause.new
      dimension_filter_clause.operator = "AND"

      dimension_filter_clause.filters = [
        filter("local_transaction", format),
        filter("http://www.royalmail.com/find-a-postcode", link_url, true),
        filter("External Link Clicked", event_category),
      ]

      [dimension_filter_clause]
    end

    def filter(value, dimension_name, invert = false)
      DimensionFilter.new.tap do |dimension_filter|
        dimension_filter.expressions = [value]
        dimension_filter.dimension_name = dimension_name
        dimension_filter.operator = "EXACT"
        dimension_filter.not = invert if invert
      end
    end

    def metrics
      [Metric.new(expression: total_events)]
    end

    def order_bys
      order = OrderBy.new
      order.field_name = total_events
      order.sort_order = "DESCENDING"
      [order]
    end

    def view_id
      @view_id ||= ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]
    end
  end
end
