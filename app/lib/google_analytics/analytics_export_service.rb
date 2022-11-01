require "google/apis/analytics_v3"
require "googleauth"

module GoogleAnalytics
  class AnalyticsExportService
    include Google::Apis::AnalyticsV3
    include Google::Auth

    attr_accessor :service

    SCOPES = ["https://www.googleapis.com/auth/analytics.edit"].freeze

    def build
      @service = AnalyticsService.new
      @service.authorization = GoogleAnalyticsExportCredentials.authorization(SCOPES)
      @service
    end

    def export_bad_links(data)
      delete_previous_uploads
      response = ""
      Tempfile.create("bad_links.csv", Dir.pwd) do |file|
        file.write(data)
        response = service.upload_data(
          ENV["GOOGLE_EXPORT_ACCOUNT_ID"],
          ENV["GOOGLE_EXPORT_CUSTOM_DATA_IMPORT_SOURCE_ID"],
          ENV["GOOGLE_EXPORT_TRACKER_ID"],
          fields: "accountId,customDataSourceId,errors,id,kind,status,uploadTime",
          upload_source: file.path,
          content_type: "application/octet-stream",
        )
      end
      Rails.logger.info "A new file has been uploaded for #{Time.zone.today}"

      response
    end

    def delete_previous_uploads(min_number_to_not_delete = 2)
      upload_list = service.list_uploads(
        ENV["GOOGLE_EXPORT_ACCOUNT_ID"],
        ENV["GOOGLE_EXPORT_CUSTOM_DATA_IMPORT_SOURCE_ID"],
        ENV["GOOGLE_EXPORT_TRACKER_ID"],
      )

      number_of_items = upload_list.items.count
      return "Need more than #{min_number_to_not_delete} to start deleting" if number_of_items <= min_number_to_not_delete

      custom_data_import_uids = upload_list.items.last(number_of_items - min_number_to_not_delete).map(&:id)

      delete_upload_data_request_object = Google::Apis::AnalyticsV3::DeleteUploadDataRequest.new(custom_data_import_uids:)

      response = @service.delete_upload_data(
        ENV["GOOGLE_EXPORT_ACCOUNT_ID"],
        ENV["GOOGLE_EXPORT_CUSTOM_DATA_IMPORT_SOURCE_ID"],
        ENV["GOOGLE_EXPORT_TRACKER_ID"],
        delete_upload_data_request_object,
      )

      Rails.logger.info "Previous uploaded files are now deleted. We've kept the last #{min_number_to_not_delete}."
      response == "" ? "Successfully deleted" : response
    end
  end
end
