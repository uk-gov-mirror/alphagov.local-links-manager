require "gds_api/test_helpers/publishing_api"

module LocalAuthoritiesExternalContentHelpers
  include GdsApi::TestHelpers::PublishingApi

  def stub_publishing_api_for_external_content
    stub_any_publishing_api_put_content
    stub_any_publishing_api_unpublish
    stub_any_publishing_api_publish
    stub_request(:get, %r{\A#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}})
      .to_return(status: 404, headers: { "Content-Type" => "application/json; charset=utf-8" })
  end

  def stub_publishing_api_for_subject(local_authority, body_merge: {})
    body = LocalAuthorityExternalContentPresenter.new(local_authority).present_for_publishing_api
    stub_publishing_api_put_content_links_and_publish(body.merge(body_merge), local_authority.content_id, { update_type: nil })
  end

  def stub_unpublish_for_subject(local_authority)
    stub_publishing_api_unpublish(local_authority.content_id, { body: { type: "gone" } })
  end

  def stub_publishing_api_subject_published(local_authority)
    stub_publishing_api_has_item({
      content_id: local_authority.content_id,
      publication_state: "published",
    })
  end

  def stub_publishing_api_subject_unpublished(local_authority)
    stub_publishing_api_has_item({
      content_id: local_authority.content_id,
      publication_state: "unpublished",
    })
  end

  def stub_publishing_api_subject_missing(local_authority)
    stub_publishing_api_does_not_have_item(local_authority.content_id)
  end
end
RSpec.configuration.include LocalAuthoritiesExternalContentHelpers
