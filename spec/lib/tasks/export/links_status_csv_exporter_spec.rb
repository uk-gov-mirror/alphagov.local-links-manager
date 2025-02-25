require "rails_helper"

RSpec.describe "Export tasks" do
  describe "export:links:status" do
    it "should write the links to S3" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      local_authority = create(:local_authority)
      service_interaction = create(:service_interaction, service: service)
      link = create(:link, service_interaction: service_interaction, local_authority: local_authority)

      expected_body = <<~EXPECTED_BODY_TEXT
        Link,Local Authority,Service,Status,Problem Summary
        #{link.url},#{local_authority.name},#{service.label},#{link.status},#{link.problem_summary}
      EXPECTED_BODY_TEXT

      s3 = double
      allow(Aws::S3::Client).to receive(:new).and_return(s3)
      expect(s3).to receive(:put_object).with({
        body: expected_body,
        bucket: nil,
        key: "data/local-links-manager/links_with_local_authority_service.csv",
      })

      Rake::Task["export:links:status"].execute
    end
  end
end
