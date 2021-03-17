describe "Service tasks" do
  describe "service:duplicate" do
    it "duplicates the service" do
      old_service = create(:service, :all_tiers, lgsl_code: 1)

      service_interaction1 = create(:service_interaction, service: old_service)
      create_list(:link, 3, service_interaction: service_interaction1)

      service_interaction2 = create(:service_interaction, service: old_service)
      create_list(:link, 3, service_interaction: service_interaction2)

      args = Rake::TaskArguments.new(%i[from_lgsl_code to_lgsl_code], [1, 2])
      Rake::Task["service:duplicate"].execute(args)

      new_service = Service.find_by!(lgsl_code: 2)

      expect(new_service.label).to eq("Transitioning #{old_service.label}")
      expect(new_service.slug).to eq("transitioning-#{old_service.slug}")

      expect(new_service.interactions.count).to eq(old_service.interactions.count)
      expect(new_service.service_interactions.count).to eq(old_service.service_interactions.count)
      expect(new_service.links.count).to eq(old_service.links.count)
    end
  end
end
