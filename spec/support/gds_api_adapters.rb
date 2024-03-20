require "gds_api/test_helpers/publishing_api"

module LocalAuthoritiesExternalContentHelpers
  include GdsApi::TestHelpers::PublishingApi

  def stub_publishing_api_for_external_content
    stub_any_publishing_api_put_content
    stub_any_publishing_api_unpublish
    stub_any_publishing_api_publish
  end

  def stub_publishing_api_for_subject(local_authority, body_merge: {})
    body = LocalAuthorityExternalContentPresenter.new(local_authority).present_for_publishing_api
    stub_publishing_api_put_content_links_and_publish(body.merge(body_merge), local_authority.content_id, { update_type: nil })
  end

  def stub_unpublish_for_subject(local_authority)
    stub_publishing_api_unpublish(local_authority.content_id, { body: { type: "gone" } })
  end
end
RSpec.configuration.include LocalAuthoritiesExternalContentHelpers
