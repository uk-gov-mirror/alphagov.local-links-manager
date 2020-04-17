describe LinkApiResponsePresenter do
  describe "#present" do
    let(:authority) { build(:district_council) }
    subject(:presenter) { described_class.new(authority, link) }

    def presented_local_authority(authority)
      {
        "local_authority" => {
          "name" => authority.name,
          "snac" => authority.snac,
          "tier" => authority.tier,
          "homepage_url" => authority.homepage_url,
        },
      }
    end

    def presented_link(link)
      {
        "local_interaction" => {
          "lgsl_code" => link.service.lgsl_code,
          "lgil_code" => link.interaction.lgil_code,
          "url" => link.url,
        },
      }
    end

    context "link is present" do
      let(:link) { create(:link, local_authority: authority) }
      let(:expected_response) { presented_local_authority(authority).merge(presented_link(link)) }

      it "returns combined details for the local authority and local interaction" do
        expect(presenter.present).to eq(expected_response)
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
