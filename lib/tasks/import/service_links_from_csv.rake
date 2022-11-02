require "csv"

namespace :import do
  desc "Imports service links from CSV file"
  task :service_links, %i[lgsl_code lgil_code filename] => :environment do |_, args|
    service_interaction = ServiceInteraction.find_or_create_by!(
      service: Service.find_by!(lgsl_code: args.lgsl_code),
      interaction: Interaction.find_by!(lgil_code: args.lgil_code),
    )

    csv = CSV.read(args.filename, { headers: true, encoding: "bom|utf-8" })

    puts "Importing [#{csv.count}] links"
    imported = 0

    csv.each do |row|
      slug = row["slug"]&.strip
      url = row["url"]&.strip

      local_authority = LocalAuthority.find_by(slug:)

      local_link = Link.find_or_initialize_by(
        local_authority:,
        service_interaction:,
      )

      local_link.url = url
      local_link.save!

      imported += 1
    end

    puts "[#{imported}] links imported"
  end
end
