require "rails_helper"

RSpec.describe NonBlankUrlValidator do
  let(:validatable_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :url

      validates :url, non_blank_url: true
    end
  end

  subject { validatable_class.new }

  context "when url is valid" do
    it "is valid" do
      subject.url = "http://example.com"
      expect(subject).to be_valid
    end
  end

  context "when url is invalid" do
    it "is not valid" do
      subject.url = "invalid_url"
      expect(subject).not_to be_valid
      expect(subject.errors[:url]).to include("(invalid_url) is not a URL")
    end
  end

  context "when url is blank" do
    it "is valid" do
      subject.url = ""
      expect(subject).to be_valid
    end
  end

  context "when url causes an Addressable::URI::InvalidURIError" do
    it "is not valid" do
      subject.url = "http://"
      expect(subject).not_to be_valid
      expect(subject.errors[:url]).to include("(http://) is not a URL")
    end
  end
end
