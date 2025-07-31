require "rails_helper"
require "rake"

RSpec.describe "import:missing_links" do
  let(:importer) { instance_double(LocalLinksManager::Import::MissingLinks) }

  before do
    allow(LocalLinksManager::Import::MissingLinks).to receive(:new).and_return(importer)
  end

  it "calls LocalLinksManager::Import::MissingLinks.add" do
    expect(importer).to receive(:add_missing_links)

    Rake::Task["import:missing_links"].invoke
  end
end
