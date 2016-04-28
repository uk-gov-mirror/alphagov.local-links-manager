require 'gds_api/mapit'

module Services
  def self.mapit
    @mapit ||= GdsApi::Mapit.new(
      Plek.new.find('mapit'),
      disable_cache: Rails.env.test?
      )
  end
end
