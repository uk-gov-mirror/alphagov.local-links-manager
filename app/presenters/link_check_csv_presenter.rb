require 'csv'

class LinkCheckCSVPresenter
  def self.homepage_links_status_csv
    CSV.generate do |csv|
      csv << %w(status count)
      LocalAuthority.group(:status).count.each do |key, value|
        csv << [key || "nil", value]
      end
    end
  end

  def self.links_status_csv
    CSV.generate do |csv|
      csv << %w(status count)
      Link.enabled_links.group(:status).count.each do |key, value|
        csv << [key || "nil", value]
      end
    end
  end
end
