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

  describe "service:rename" do
    it "should update the label and the slug" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      args = Rake::TaskArguments.new(%i[lgsl_code label slug], [1, "Updated label", "updated-slug"])

      expect { Rake::Task["service:rename"].execute(args) }
        .to change { service.reload.label }.from(service.label).to("Updated label")
        .and change { service.reload.slug }.from(service.slug).to("updated-slug")
    end
  end

  describe "service:destroy" do
    it "should destroy the service" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      service_interaction = create(:service_interaction, service: service)
      create_list(:link, 3, service_interaction: service_interaction)
      args = Rake::TaskArguments.new(%i[lgsl_code], [1])

      expect { Rake::Task["service:destroy"].execute(args) }
        .to change { Service.count }.from(1).to(0)
        .and change { ServiceInteraction.count }.from(1).to(0)
        .and change { Link.count }.from(3).to(0)
    end
  end
end
