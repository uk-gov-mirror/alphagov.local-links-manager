RSpec.describe "Link Status CSV" do
  it_behaves_like "it is forbidden to non-GDS Editors", "/check_homepage_links_status.csv"
  it_behaves_like "it is forbidden to non-GDS Editors", "/check_links_status.csv"
  it_behaves_like "it is forbidden to non-GDS Editors", "/bad_links_url_status.csv"
end
