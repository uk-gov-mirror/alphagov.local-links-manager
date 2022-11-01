class ServiceLinkPresenter < SimpleDelegator
  include UrlStatusPresentation
  attr_reader :view_context, :first

  def initialize(link, view_context:, first:)
    super(link)
    @view_context = view_context
    @first = first
  end

  delegate :label, to: :interaction, prefix: true

  delegate :lgsl_code, to: :service

  delegate :label, to: :service, prefix: true

  delegate :slug, to: :service, prefix: true

  delegate :govuk_title, to: :service_interaction

  def row_data
    {
      local_authority_id: local_authority.id,
      service_id: service.id,
      interaction_id: interaction.id,
      url:,
    }
  end

  def edit_path
    view_context.edit_link_path(
      local_authority,
      service,
      interaction,
    )
  end
end
