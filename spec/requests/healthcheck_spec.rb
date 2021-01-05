RSpec.describe "healthcheck path", type: :request do
  before do
    get "/healthcheck"
  end

  it "returns a 200 HTTP status" do
    expect(response).to have_http_status(:ok)
  end

  it "returns postgres connection status" do
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("database_connectivity")
  end

  it "returns redis connections status" do
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("redis_connectivity")
  end
end
