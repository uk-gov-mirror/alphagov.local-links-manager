class LocalAuthorityExternalContentPublisher
  attr_reader :local_authority, :publishing_api

  def initialize(local_authority)
    @local_authority = local_authority
    @publishing_api = GdsApi.publishing_api
  end

  def publish
    payload = LocalAuthorityExternalContentPresenter.new(local_authority)
      .present_for_publishing_api

    publishing_api.put_content(content_id, payload)
    publishing_api.publish(content_id)
  end

  def unpublish
    return unless published?

    publishing_api.unpublish(content_id, type: "gone")
  end

private

  def content_id
    local_authority.content_id
  end

  def published?
    content = publishing_api.get_live_content(content_id)
    content.to_hash["publication_state"] == "published"
  rescue GdsApi::HTTPNotFound
    # Not present, so definitely not published
    false
  end
end
