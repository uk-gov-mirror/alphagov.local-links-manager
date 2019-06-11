module GoogleAnalytics
  describe ClicksResponse do
    let(:response) do
      GoogleAnalytics::ClicksResponseFactory.build([
        {
          base_path: "/pay-unicycle-registration/clownsville",
          local_link: "https://clownsville.gov.uk/crusty-jugglers",
          clicks: 400
        },
        {
          base_path: "/tiny-bicycle-riding-lessons/boffo-town",
          local_link: "https://boffo-town-council.gov.uk/wheeled-transport",
          clicks: 500
        }
      ])
    end

    it "returns the number of clicks for a local authority interaction" do
      page_views = ClicksResponse.new.parse(response)
      expected_response = [
        {
          base_path: "/pay-unicycle-registration/clownsville",
          local_link: "https://clownsville.gov.uk/crusty-jugglers",
          clicks: 400
        },
        {
          base_path: "/tiny-bicycle-riding-lessons/boffo-town",
          local_link: "https://boffo-town-council.gov.uk/wheeled-transport",
          clicks: 500
        }
      ]

      expect(page_views).to eq(expected_response)
    end
  end
end
