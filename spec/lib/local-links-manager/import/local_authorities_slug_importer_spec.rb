require 'rails_helper'
require 'local-links-manager/import/local_authorities_slug_importer'

describe LocalLinksManager::Import::LocalAuthoritiesSlugImporter do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  def stub_slug_json_request(data)
    stub_request(:any, "https://raw.githubusercontent.com/alphagov/frontend/master/lib/data/authorities.json").
      to_return(body: data,
      status: 200,
      headers: { 'Content-Length' => data.length })
  end

  describe "import_slugs" do
    it "should import the slugs from the json file" do
      FactoryGirl.create(:local_authority,
        name: "Aberdeenshire Council",
        snac: "00QB",
        gss: "S12000034",
        slug: nil)
      FactoryGirl.create(:local_authority,
        name: "Fife Council",
        snac: "00QR",
        gss: "S12000015",
        slug: nil)
      FactoryGirl.create(:local_authority,
        name: "Aberdeenshire City Council",
        snac: "00QA",
        gss: "S12000033",
        slug: nil)

      json_stub =
        '{
          "aberdeenshire": {
            "name": "Aberdeenshire Council",
            "ons": "00QB",
            "gss": "S12000034"
          },
          "fife": {
            "name": "Fife Council",
            "ons": "00QR",
            "gss": "S12000015"
          },
          "aberdeen": {
            "name": "Aberdeen City Council",
            "ons": "00QA",
            "gss": "S12000033"
          }
        }'
      stub_slug_json_request(json_stub)

      la_before = LocalAuthority.find_by(gss: 'S12000033')
      expect(la_before.slug).to eq(nil)

      LocalLinksManager::Import::LocalAuthoritiesSlugImporter.import_slugs

      la_after = LocalAuthority.find_by(gss: 'S12000033')
      expect(la_after.slug).to eq("aberdeen")
    end

    it "should skip empty gss codes" do
      FactoryGirl.create(:local_authority,
        name: "Fife Council",
        snac: "00QR",
        gss: "S12000015",
        slug: "fife")
      FactoryGirl.create(:local_authority,
        name: "Aberdeenshire City Council",
        snac: "00QA",
        gss: "S12000033",
        slug: "aberdeen")

      frontend_json_stub =
        '{
          "used-to-be-aberdeen": {
            "name": "Aberdeen City Council",
            "ons": "00QA",
            "gss": ""
          },
          "used-to-be-fife": {
            "name": "Fife Council",
            "ons": "00QR"
          }
        }'

      stub_slug_json_request(frontend_json_stub)

      LocalLinksManager::Import::LocalAuthoritiesSlugImporter.import_slugs

      la_after = LocalAuthority.find_by(snac: '00QA')
      expect(la_after.slug).to eq("aberdeen")

      la_after = LocalAuthority.find_by(snac: '00QR')
      expect(la_after.slug).to eq("fife")
    end
  end
end
