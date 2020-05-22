require "local-links-manager/link_resolver"

describe LocalLinksManager::LinkResolver do
  describe "#resolve" do
    let(:local_authority) { create(:local_authority) }

    context "with interaction" do
      let(:service_interaction) { create(:service_interaction) }
      subject(:link_resolver) { described_class.new(local_authority, service_interaction.service, service_interaction.interaction) }

      it "returns a link for matching service and interaction" do
        link = create(:link, local_authority: local_authority, service_interaction: service_interaction)

        expect(link_resolver.resolve).to eq(link)
      end

      context "with a parent" do
        let(:parent) { create(:district_council) }
        before { local_authority.parent_local_authority = parent }

        it "returns a link for matching parent service and interaction" do
          link = create(:link, local_authority: parent, service_interaction: service_interaction)

          expect(link_resolver.resolve).to eq(link)
        end

        it "returns nil if matching parent has no valid tier for the service" do
          service_interaction.service.delete_and_create_tiers("county/unitary")
          create(:link, local_authority: parent, service_interaction: service_interaction)

          expect(link_resolver.resolve).to be_nil
        end
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
      let(:service) { create(:service) }
      subject(:link_resolver) { described_class.new(local_authority, service) }

      context "there are 2 links" do
        let(:interaction1) { create(:interaction, lgil_code: 1) }
        let(:interaction2) { create(:interaction, lgil_code: 2) }
        let(:service_interaction1) { create(:service_interaction, service: service, interaction: interaction1) }
        let(:service_interaction2) { create(:service_interaction, service: service, interaction: interaction2) }
        let!(:link1) { create(:link, local_authority: local_authority, service_interaction: service_interaction1) }
        let!(:link2) { create(:link, local_authority: local_authority, service_interaction: service_interaction2) }

        it "returns the link with the lower LGIL" do
          expect(link_resolver.resolve).to eq(link1)
        end

        context "and one of them is for LGIL 8" do
          before do
            interaction1.update(lgil_code: 8)
          end

          it "returns the link that is not for LGIL 8" do
            expect(link_resolver.resolve).to eq(link2)
          end

          it "returns the link that is not for LGIL 8 if its LGIL is higher than 8" do
            interaction2.update(lgil_code: 9)

            expect(link_resolver.resolve).to eq(link2)
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
          link.interaction.update(lgil_code: 8)

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
