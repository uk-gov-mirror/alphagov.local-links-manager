class UpdateLeicestershireStreetPartiesPermission < ActiveRecord::Migration[7.0]
  def up
    service = Service.find_by(slug: "street-parties-permission")

    local_authorities = LocalAuthority.where(parent_local_authority: LocalAuthority.find_by(slug: "leicestershire"))

    local_authorities.each do |la|
      Link.where(local_authority_id: la.id, service_interaction_id: service.service_interaction_ids).destroy_all
    end
  end
end
