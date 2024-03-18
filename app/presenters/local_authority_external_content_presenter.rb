class LocalAuthorityExternalContentPresenter
  def initialize(local_authority)
    @local_authority = local_authority
  end

  def present_for_publishing_api
    {
      description: "Website of #{@local_authority.name}",
      details: {
        url: @local_authority.homepage_url,
      },
      document_type: "external_content",
      publishing_app: "local-links-manager",
      schema_name: "external_content",
      title: @local_authority.name,
      update_type: "minor",
    }
  end
end
