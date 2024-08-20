RSpec.describe "Bad homepage CSV" do
  it_behaves_like "it is forbidden to non-GDS Editors", "/bad_homepage_url_status.csv"
end
