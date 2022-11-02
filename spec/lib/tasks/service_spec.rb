describe "Service tasks" do
  describe "service:destroy" do
    it "should destroy the service" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      service_interaction = create(:service_interaction, service:)
      create_list(:link, 3, service_interaction:)
      args = Rake::TaskArguments.new(%i[lgsl_code], [1])

      expect { Rake::Task["service:destroy"].execute(args) }
        .to change { Service.count }.from(1).to(0)
        .and change { ServiceInteraction.count }.from(1).to(0)
        .and change { Link.count }.from(3).to(0)
    end
  end
end
