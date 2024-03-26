RSpec.describe LocalAuthorityExternalContentPublisher do
  before do
    WebMock.reset!
    @authority = build(:local_authority, content_id: SecureRandom.uuid)
    stub_publishing_api_subject_published(@authority)
    stub_publishing_api_for_subject(@authority)
    @authority.save!
    WebMock.reset!
  end

  describe "#publish" do
    before do
      @stubs = stub_publishing_api_for_subject(@authority)
    end

    context "with a published local authority link" do
      it "calls the publishing api to update and publish" do
        stub_publishing_api_subject_published(@authority)
        described_class.new(@authority).publish
        expect(@stubs.first).to have_been_requested.once
        expect(@stubs.last).to have_been_requested
      end
    end
  end

  describe "#unpublish" do
    before do
      @stub = stub_unpublish_for_subject(@authority)
    end

    context "with a published local authority link" do
      it "calls the publishing api to unpublish" do
        stub_publishing_api_subject_published(@authority)
        described_class.new(@authority).unpublish
        expect(@stub).to have_been_requested.once
      end
    end

    context "with a non-published local authority link" do
      it "does nothing" do
        stub_publishing_api_subject_unpublished(@authority)
        described_class.new(@authority).unpublish
        expect(@stub).not_to have_been_requested
      end
    end

    context "with a missing local authority link" do
      it "does nothing" do
        stub_publishing_api_subject_missing(@authority)
        described_class.new(@authority).unpublish
        expect(@stub).not_to have_been_requested
      end
    end
  end
end
