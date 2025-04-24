describe LinkApiResponsePresenter do
  describe "#present" do
    let(:authority) { build(:district_council) }
    subject(:presenter) { described_class.new(authority, link) }

    def presented_local_authority(authority)
      {
        "local_authority" => {
          "name" => authority.name,
          "snac" => authority.snac,
          "gss" => authority.gss,
          "tier" => authority.tier,
          "homepage_url" => authority.homepage_url,
          "country_name" => authority.country_name,
          "slug" => authority.slug,
        },
      }
    end

    def presented_link(link)
      {
        "local_interaction" => {
          "lgsl_code" => link.service.lgsl_code,
          "lgil_code" => link.interaction.lgil_code,
          "status" => link.status,
          "title" => link.title,
          "url" => link.url,
        },
      }
    end

    context "link is present and doesn't belong to the local authority" do
      let(:link) { create(:link) }
      let(:expected_response) { presented_local_authority(link.local_authority).merge(presented_link(link)) }

      it "returns combined details for the link's local authority and local interaction" do
        expect(presenter.present).to eq(expected_response)
      end
    end

    context "link is present and belongs to local authority" do
      let(:link) { create(:link, local_authority: authority) }
      let(:expected_response) { presented_local_authority(authority).merge(presented_link(link)) }

      it "returns combined details for the local authority and link's local interaction" do
        expect(presenter.present).to eq(expected_response)
      end

      context "and link includes a title" do
        let(:link) { create(:link, local_authority: authority, title: "Link Title") }
        let(:expected_response) { presented_local_authority(authority).merge(presented_link(link)) }

        it "returns combined details for the local authority and link's local interaction" do
          expect(presenter.present).to eq(expected_response)
        end
      end
    end

    context "no link is present" do
      let(:link) { nil }
      let(:expected_response) { presented_local_authority(authority) }

      it "returns details for just the local authority" do
        expect(presenter.present).to eq(expected_response)
      end
    end
  end
end
