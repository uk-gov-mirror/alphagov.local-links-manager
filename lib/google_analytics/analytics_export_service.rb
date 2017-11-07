require 'google/apis/analytics_v3'
require 'googleauth'

module GoogleAnalytics
  class AnalyticsExportService
    include Google::Apis::AnalyticsV3
    include Google::Auth

    attr_accessor :service

    SCOPES = ['https://www.googleapis.com/auth/analytics.edit'].freeze

    def build
      @service = AnalyticsService.new
      @service.authorization = GoogleAnalyticsExportCredentials.authorization(SCOPES)
      @service
    end

    def export_bad_links(data)
      begin
        response = ''
        Tempfile.create('bad_links.csv', Dir.pwd) do |file|
          file.write(data)
          response = service.upload_data(ENV['GOOGLE_EXPORT_ACCOUNT_ID'],
                                         ENV['GOOGLE_EXPORT_CUSTOM_DATA_IMPORT_SOURCE_ID'],
                                         ENV['GOOGLE_EXPORT_TRACKER_ID'],
                                         fields: "accountId,customDataSourceId,errors,id,kind,status,uploadTime",
                                         upload_source: file.path,
                                         content_type: 'application/octet-stream')
        end
      end
      response
    end
  end
end
