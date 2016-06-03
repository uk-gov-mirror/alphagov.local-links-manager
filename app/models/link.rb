class Link < ActiveRecord::Base
  belongs_to :local_authority
  belongs_to :service_interaction

  has_one :service, through: :service_interaction
  has_one :interaction, through: :service_interaction

  validates :local_authority, :service_interaction, presence: true
  validates :service_interaction_id, uniqueness: { scope: :local_authority_id }
  validates :url, presence: true, non_blank_url: true

  scope :for_service, ->(service) {
    includes(service_interaction: [:service, :interaction])
      .references(:service_interactions)
      .where(service_interactions: { service_id: service })
  }

  def self.retrieve(params)
    self.joins(:local_authority, :service, :interaction).find_by(
      local_authorities: { slug: params[:local_authority_slug] },
      services: { slug: params[:service_slug] },
      interactions: { slug: params[:interaction_slug] }
    ) || build(params)
  end

  def self.build(params)
    Link.new(
      local_authority: LocalAuthority.find_by(slug: params[:local_authority_slug]),
      service_interaction: ServiceInteraction.find_by(
        service: Service.find_by(slug: params[:service_slug]),
        interaction: Interaction.find_by(slug: params[:interaction_slug]),
      )
    )
  end

  def display_url
    url || 'No link'
  end
end
