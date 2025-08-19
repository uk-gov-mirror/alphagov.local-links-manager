RSpec.describe "Import all local authorities and service interactions" do
  describe "import:all" do
    before do
      Rake::Task["import:all"].reenable
      Rake::Task["import:local_authorities:import_all"].reenable
      Rake::Task["import:service_interactions:import_all"].reenable
    end

    it "calls the import rake tasks" do
      expect(Rake::Task["import:local_authorities:import_all"]).to receive(:invoke)
      expect(Rake::Task["import:service_interactions:import_all"]).to receive(:invoke)

      Rake::Task["import:all"].invoke
    end
  end
end
