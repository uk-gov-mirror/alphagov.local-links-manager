require "rails_helper"
require "rake"

RSpec.describe "import:missing_links" do
  before do
    allow(LocalLinksManager::Import::MissingLinks).to receive(:add)
  end

  it "calls LocalLinksManager::Import::MissingLinks.add" do
    Rake::Task["import:missing_links"].invoke
    expect(LocalLinksManager::Import::MissingLinks).to have_received(:add)
  end
end
