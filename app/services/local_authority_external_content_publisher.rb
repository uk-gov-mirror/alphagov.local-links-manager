class LocalAuthorityExternalContentPublisher
  def self.publish(local_authority)
    payload = LocalAuthorityExternalContentPresenter.new(local_authority)
      .present_for_publishing_api

    publishing_api = GdsApi.publishing_api

    publishing_api.put_content(local_authority.content_id, payload)
    publishing_api.publish(local_authority.content_id)
  end

  def self.unpublish(local_authority)
    GdsApi.publishing_api.unpublish(local_authority.content_id, type: "gone")
  end
end
