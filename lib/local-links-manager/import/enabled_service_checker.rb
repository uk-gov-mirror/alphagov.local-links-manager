require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class EnabledServiceChecker
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv"

      def self.enable
        new.enable_services
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL))
        @csv_downloader = csv_downloader
      end

      def enable_services
        @csv_downloader.each_row do |row|
          set_enabled_service(row)
        end
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} enabling in #{self.class}\n#{e.backtrace.join("\n")}"
      end

    private

      def set_enabled_service(row)
        service = Service.find_by(lgsl_code: row["LGSL"])
        if service.nil?
          Rails.logger.warn("'#{row['LGSL']}' is not an imported Service")
        else
          service.enabled = true
          Rails.logger.info("'#{row['LGSL']}' enabled")
          service.save!
        end
      end
    end
  end
end
