require "rails_helper"

RSpec.describe "Import tasks" do
  describe "import:service_links" do
    it "imports service links from the CSV file" do
      la = create(:local_authority, slug: "angus")
      create(:service, lgsl_code: 1)
      create(:interaction, lgil_code: 1)
      args = Rake::TaskArguments.new(%i[lgsl_code lgil_code filename], [1, 1, "spec/fixtures/service-links.csv"])

      expect { Rake::Task["import:service_links"].execute(args) }.to output(/\[1\] links imported/).to_stdout

      expect(la.links.first.url).to eq("https://www.example.com/new-service")
    end
  end
end
