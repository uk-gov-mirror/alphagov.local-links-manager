require "csv"
namespace :import do
  desc "Imports COVID-19 shielding links from MHCLG's Google Sheet"
  task covid19_mhclg: :environment do
    SERVICE_MAPPINGS = {
      "Single Vulnerable People URL" => { lgsl: 1287, lgil: 8 },
      # "volunteering" => { lgsl: 1113, lgil: 8 },
    }.freeze

    DOC_ID = "10U5nHFusxMPAh93aleuPYpE-l8ZOJGOjClQemoeIx5A".freeze
    SHEET_ID = "543314380".freeze
    CSV_URL = URI.parse("https://docs.google.com/spreadsheets/d/#{DOC_ID}/export?gid=#{SHEET_ID}&format=csv&id=#{DOC_ID}")

    response = Net::HTTP.get_response(CSV_URL)
    unless response.code_type == Net::HTTPOK
      raise "Error downloading CSV in #{self.class}"
    end

    csv = CSV.parse(response.body, headers: true)

    # Sanity check
    raise "Missing 'GSS' column" if csv["GSS"].compact.empty?

    SERVICE_MAPPINGS.keys.each do |k|
      raise "Missing '#{csv[k]}' column" if csv[k].compact.empty?
    end

    SERVICE_MAPPINGS.each do |type, codes|
      service_interaction = ServiceInteraction.find_or_create_by!(
        service: Service.find_by!(lgsl_code: codes[:lgsl]),
        interaction: Interaction.find_by!(lgil_code: codes[:lgil]),
      )

      csv.each do |row|
        url = row[type]&.strip
        next if url.blank?

        begin
          URI.parse(url)
        rescue URI::InvalidURIError
          puts "Invalid URL '#{url}' for area #{row['GSS']}, skipping"
          next
        end

        local_authority = LocalAuthority.find_by(gss: row["GSS"])
        unless local_authority
          puts "Could not find local authority GSS=#{row['GSS']}"
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
