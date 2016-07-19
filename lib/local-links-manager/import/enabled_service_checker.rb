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
        @supported_lgsl_codes = Set.new

        @csv_downloader.each_row { |row| @supported_lgsl_codes.add(row["LGSL"]) }

        Service.all.each { |service| set_enabled_state(service) }

        check_for_missing_services

        log_result
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} enabling in #{self.class}\n#{e.backtrace.join("\n")}"
      end

    private

      def set_enabled_state(service)
        enabled = @supported_lgsl_codes.include? service.lgsl_code.to_s
        service.enabled = enabled
        Rails.logger.info("'#{service.lgsl_code}' enabled = #{enabled}")
        service.save!
      end

      def check_for_missing_services
        @supported_lgsl_codes.each do |lgsl|
          if Service.find_by(lgsl_code: lgsl).nil?
            warn_missing(lgsl)
          end
        end
      end

      def warn_missing(lgsl)
        Rails.logger.warn("'#{lgsl}' is not an imported Service")
      end

      def log_result
        total_services_count = Service.all.count
        enabled_services_count = Service.where(enabled: true).count
        supported_lgsl_codes_count = @supported_lgsl_codes.count

        Rails.logger.info("Enabled #{enabled_services_count} of #{total_services_count} services")

        unless supported_lgsl_codes_count == enabled_services_count
          Rails.logger.warn "Could not enable all services in the CSV "\
            "(#{enabled_services_count} enabled, but there are "\
            "#{supported_lgsl_codes_count} services in the list)"
        end
      end
    end
  end
end
