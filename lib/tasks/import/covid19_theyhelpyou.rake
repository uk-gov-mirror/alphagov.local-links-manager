namespace :import do
  desc "Imports COVID-19 shielding links from TheyHelpYou"
  task covid19_theyhelpyou: :environment do
    SERVICE_MAPPINGS = {
      # "shielding"    => { lgsl: 1287, lgil: 8 },
      "vulnerable" => { lgsl: 1287, lgil: 8 },
      "volunteering" => { lgsl: 1113, lgil: 8 },
    }.freeze

    SERVICE_MAPPINGS.each do |type, codes|
      if ENV["SERVICE_TYPE"].present? && ENV["SERVICE_TYPE"] != type
        puts "Skipping #{type} as only #{ENV['SERVICE_TYPE']} requested"
        next
      end

      puts "Fetching mappings for type #{type}, LGSL=#{codes[:lgsl]} LGIL=#{codes[:lgil]}"
      service_interaction = ServiceInteraction.find_or_create_by!(
        service: Service.find_by!(lgsl_code: codes[:lgsl]),
        interaction: Interaction.find_by!(lgil_code: codes[:lgil]),
      )

      nation_filter = ENV["NATION"].present? ? "&nation=#{ENV['NATION']}" : ""

      response = Net::HTTP.get_response(URI.parse("https://www.theyhelpyou.co.uk/api/export-local-links-manager?type=#{type}#{nation_filter}"))
      unless response.code_type == Net::HTTPOK
        raise DownloadError, "Error downloading JSON in #{self.class}"
      end

      data = JSON.parse(response.body)
      puts "Got #{data.count} links"

      data.each do |gss, url|
        local_authority = LocalAuthority.find_by(gss: gss)
        unless local_authority
          puts "Could not find local authority GSS=#{gss}"
          next
        end

        link = Link.find_or_initialize_by(
          local_authority: local_authority,
          service_interaction: service_interaction,
        )
        link.url = url
        link.save!
      end
      puts "Done"
    end
  end
end
