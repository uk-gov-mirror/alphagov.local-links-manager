require "local-links-manager/link_resolver"

describe LocalLinksManager::LinkResolver do
  describe "#resolve" do
    context "with interaction" do
      let(:local_authority) { create(:local_authority) }
      let(:service_interaction) { create(:service_interaction) }
      let(:link_resolver) { described_class.new(local_authority, service_interaction.service, service_interaction.interaction) }

      it "returns a link for matching service and interaction" do
        link = create(:link, local_authority: local_authority, service_interaction: service_interaction)

        expect(link_resolver.resolve).to eq(link)
      end

      it "returns nil if no link exists" do
        expect(link_resolver.resolve).to be_nil
      end

      it "returns nil if no service interaction exists" do
        service_interaction.destroy

        expect(link_resolver.resolve).to be_nil
      end
    end

    context "without interaction" do
      let(:local_authority) { create(:local_authority) }
      let(:service) { create(:service) }
      let(:link_resolver) { described_class.new(local_authority, service) }

      context "there are 2 links" do
        let(:interaction_1) { create(:interaction, lgil_code: 1) }
        let(:interaction_2) { create(:interaction, lgil_code: 2) }
        let(:service_interaction_1) { create(:service_interaction, service: service, interaction: interaction_1) }
        let(:service_interaction_2) { create(:service_interaction, service: service, interaction: interaction_2) }
        let!(:link_1) { create(:link, local_authority: local_authority, service_interaction: service_interaction_1) }
        let!(:link_2) { create(:link, local_authority: local_authority, service_interaction: service_interaction_2) }

        it "returns the link with the lower LGIL" do
          expect(link_resolver.resolve).to eq(link_1)
        end

        context "and one of them is for LGIL 8" do
          before do
            interaction_1.update_attributes(lgil_code: 8)
          end

          it "returns the link that is not for LGIL 8" do
            expect(link_resolver.resolve).to eq(link_2)
          end

          it "returns the link that is not for LGIL 8 if its LGIL is higher than 8" do
            interaction_2.update_attributes(lgil_code: 9)

            expect(link_resolver.resolve).to eq(link_2)
          end
        end
      end

      context "there is only one link" do
        let(:service_interaction) { create(:service_interaction, service: service) }
        let!(:link) { create(:link, local_authority: local_authority, service_interaction: service_interaction) }

        it "returns the link" do
          expect(link_resolver.resolve).to eq(link)
        end

        it "returns the link if it is for LGIL 8" do
          link.interaction.update_attributes(lgil_code: 8)

          expect(link_resolver.resolve).to eq(link)
        end
      end

      context "there are no links" do
        it "returns nil" do
          expect(link_resolver.resolve).to be_nil
        end
      end
    end
  end
end
