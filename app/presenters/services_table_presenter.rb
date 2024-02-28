class ServicesTablePresenter
  def initialize(services, view_context)
    @services = services
    @view_context = view_context
  end

  def rows
    @services.map do |service|
      govuk_links = ServiceInteraction.where(service:).map do |si|
        si.govuk_title ? @view_context.link_to(si.govuk_title, "#{Plek.website_root}/#{si.govuk_slug}", class: "govuk-link") : nil
      end

      [
        { text: service.links.sum { |l| l.analytics.to_i }, format: "numeric" },
        { text: @view_context.link_to(service.label, @view_context.service_path(service, filter: "broken_links"), class: "govuk-link") },
        { text: govuk_links.compact.any? ? govuk_links.compact.join("<br />").html_safe : "Not used on GOV.UK" },
        { text: service.lgsl_code },
        { text: service.broken_link_count, format: "numeric" },
      ]
    end
  end

  def headers
    [
      {
        text: "Visits this week",
        format: "numeric",
      },
      {
        text: "Service Name",
      },
      {
        text: "GOV.UK Pages",
      },
      {
        text: "LGSL Code",
      },
      {
        text: "Broken Links",
        format: "numeric",
      },
    ]
  end
end
