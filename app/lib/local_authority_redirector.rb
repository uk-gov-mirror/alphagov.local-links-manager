class LocalAuthorityRedirector
  def initialize(from:, to:)
    @old_local_authority = from
    @new_local_authority = to
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    validate_local_authorities
    publish_redirects
  end

  private_class_method :new

private

  attr_reader :old_local_authority, :new_local_authority

  def validate_local_authorities
    unless old_local_authority.services.to_set.subset?(new_local_authority.services.to_set)
      raise "#{old_local_authority.name} has some services that #{new_local_authority.name} does not"
    end
  end

  def publish_redirects
    local_authority_redirects(old_local_authority)
      .each { |redirect| publish_redirect(redirect) }
  end

  def local_authority_redirects(local_authority)
    local_authority.services.flat_map { |service| service_redirects(service) }
  end

  def service_redirects(service)
    service.service_interactions.map(&:govuk_slug).compact.map do |interaction_slug|
      ["/#{interaction_slug}/#{old_local_authority.slug}", "/#{interaction_slug}/#{new_local_authority.slug}"]
    end
  end

  def publishing_api_redirect_payload(redirect)
    {
      "base_path" => redirect.first,
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "local-links-manager",
      "update_type" => "major",
      "redirects" => [
        {
          "path" => redirect.first,
          "type" => "exact",
          "segments_mode" => "ignore",
          "destination" => redirect.second,
        },
      ],
    }
  end

  def publish_redirect(redirect)
    logger.info "#{redirect.first} -> #{redirect.second}"
    content_id = SecureRandom.uuid
    payload = publishing_api_redirect_payload(redirect)
    GdsApi.publishing_api.put_content(content_id, payload)
    GdsApi.publishing_api.publish(content_id)
  end
end
