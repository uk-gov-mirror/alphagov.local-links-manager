class Link < ApplicationRecord
  before_update :set_link_check_results_on_updated_link, if: :url_changed?
  before_create :set_link_check_results_on_new_link

  belongs_to :local_authority, touch: true
  belongs_to :service_interaction, touch: true

  has_one :service, through: :service_interaction
  has_one :interaction, through: :service_interaction

  validates :local_authority, :service_interaction, presence: true
  validates :service_interaction_id, uniqueness: { scope: :local_authority_id }
  validates :url, non_blank_url: true

  scope :for_service, ->(service) {
    includes(service_interaction: %i[service interaction])
      .references(:service_interactions)
      .where(service_interactions: { service_id: service })
  }

  scope :with_url, -> { where.not(url: nil) }
  scope :without_url, -> { where(url: nil) }

  scope :missing, -> { where(status: "missing") }
  scope :currently_broken, -> { where(status: "broken") }
  scope :broken_or_missing, -> { currently_broken.or(missing) }

  scope :last_checked_before, ->(last_checked) {
    where("link_last_checked IS NULL OR link_last_checked < ?", last_checked)
  }

  validates :status, inclusion: { in: %w(ok broken caution missing pending) }, allow_nil: true

  def self.enabled_links
    self.joins(:service).where(services: { enabled: true })
  end

  def self.retrieve(params)
    self.joins(:local_authority, :service, :interaction).find_by(
      local_authorities: { slug: params[:local_authority_slug] },
      services: { slug: params[:service_slug] },
      interactions: { slug: params[:interaction_slug] }
    ) || build(params)
  end

  def self.find_by_service_and_interaction(service, interaction)
    self.with_url.joins(:service, :interaction).find_by(
      services: { id: service.id },
      interactions: { id: interaction.id }
    )
  end

  def self.find_by_base_path(base_path)
    govuk_slug, local_authority_slug = base_path[1..-1].split("/")

    self.joins(:local_authority, :service_interaction)
      .find_by(local_authorities: { slug: local_authority_slug },
       service_interactions: { govuk_slug: govuk_slug })
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

  def make_missing
    self.url = nil
    save
  end

private

  def link_with_matching_url
    existing_link || existing_homepage
  end

  def existing_link
    @existing_link ||= Link.where(url: self.url).first
  end

  def existing_homepage
    @existing_homepage ||= LocalAuthority.where(homepage_url: self.url).first
  end

  def set_link_check_results_on_updated_link
    if self.url == nil
      self.update_columns(
        status: "missing",
        link_last_checked: nil,
        link_errors: [],
        link_warnings: [],
        problem_summary: nil,
        suggested_fix: nil,
      )
    elsif link_with_matching_url
      set_link_check_results(link_with_matching_url)
    else
      self.update_columns(
        status: nil,
        link_last_checked: nil,
        link_errors: [],
        link_warnings: [],
        problem_summary: nil,
        suggested_fix: nil,
      )
    end
  end

  def set_link_check_results_on_new_link
    set_link_check_results(link_with_matching_url) if link_with_matching_url
  end

  def set_link_check_results(link)
    self.status = link.status
    self.link_errors = link.link_errors
    self.link_warnings = link.link_warnings
    self.link_last_checked = link.link_last_checked
  end
end
