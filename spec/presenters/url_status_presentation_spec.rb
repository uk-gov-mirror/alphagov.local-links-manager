require "rails_helper"

RSpec.describe UrlStatusPresentation do
  let(:dummy_class) do
    Class.new do
      include UrlStatusPresentation

      attr_accessor :status, :problem_summary, :link_errors, :link_warnings, :link_last_checked, :url, :interaction

      def initialize
        @link_errors = []
        @link_warnings = []
        @interaction = OpenStruct.new(lgil_code: "123")
      end
    end
  end

  subject { dummy_class.new }

  describe "#status_description" do
    context "when status is nil" do
      it 'returns "Not checked"' do
        expect(subject.status_description).to eq "Not checked"
      end
    end

    context 'when status is "pending"' do
      before { subject.status = "pending" }

      it 'returns "Pending"' do
        expect(subject.status_description).to eq "Pending"
      end
    end

    context "when status 'some_other_status'" do
      before { subject.status = "some_other_status" }

      it "returns the problem_summary" do
        expect(subject.status_description).to eq nil
      end
    end
  end
end
