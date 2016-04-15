require 'rails_helper'
require 'local-links-manager/import/local_authorities_importer'

describe LocalLinksManager::Import::LocalAuthoritiesImporter do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  def stub_mapit_request(data)
    stub_request(:any, mapit_url).
      to_return(body: data,
      status: 200,
      headers: { 'Content-Length' => data.length })
  end

  describe 'import of local authorities from MapIt' do
    let(:source_mapit_data) { File.read(fixture_file('mapit.json')) }
    let(:mapit_data) { JSON.parse(source_mapit_data) }
    let(:mapit_base_url) { "#{Plek.find('mapit')}/" }
    let(:mapit_url) { "#{mapit_base_url}areas/COI,CTY,DIS,LBO,LGD,MTD,UTA.json" }

    before(:each) do
      stub_mapit_request(source_mapit_data)
      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit
    end

    it 'imports MapIt formatted json' do
      expect(LocalAuthority.count).to eq(8)

      la = LocalAuthority.find_by(gss: 'S12000033')

      expect(la.name).to eq("Aberdeen City Council")
      expect(la.snac).to eq("00QA")
      expect(la.tier).to eq("unitary")
    end

    it 'updates name, SNAC and tier fields only' do
      updated_name_type_and_ons = '{
        "9999": {
          "parent_area": null,
          "generation_high": 1,
          "all_names": {},
          "id": 9999,
          "codes": {
              "ons": "XXXX",
              "gss": "S12000033",
              "unit_id": "30421"
          },
          "name": "A Different Council",
          "country": "S",
          "type_name": "Unitary Authority",
          "generation_low": 1,
          "country_name": "Scotland",
          "type": "DIS"
        }
      }'

      stub_mapit_request(updated_name_type_and_ons)

      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit

      expect(LocalAuthority.count).to eq(8)

      la = LocalAuthority.find_by(gss: 'S12000033')

      expect(la.name).to eq("A Different Council")
      expect(la.snac).to eq("XXXX")
      expect(la.tier).to eq("district")
    end

    it 'skips updating if GSS or SNAC code is blank' do
      updated_name_type_and_ons = '{
        "2120": {
          "parent_area": null,
          "generation_high": 1,
          "all_names": {},
          "id": 9999,
          "codes": {
              "ons": "",
              "gss": "S12000033",
              "unit_id": "30421"
          },
          "name": "A Different Council",
          "country": "S",
          "type_name": "Unitary Authority",
          "generation_low": 1,
          "country_name": "Scotland",
          "type": "UTA"
        },
        "2118": {
          "parent_area": null,
          "generation_high": 1,
          "all_names": {},
          "id": 2118,
          "codes": {
              "ons": "00QB",
              "gss": "",
              "unit_id": "30111"
          },
          "name": "Another Council",
          "country": "S",
          "type_name": "Unitary Authority",
          "generation_low": 1,
          "country_name": "Scotland",
          "type": "UTA"
        }
      }'

      stub_mapit_request(updated_name_type_and_ons)

      LocalLinksManager::Import::LocalAuthoritiesImporter.import_from_mapit

      expect(LocalAuthority.count).to eq(8)

      la = LocalAuthority.find_by(gss: 'S12000033')
      expect(la.name).to eq("Aberdeen City Council")

      la2 = LocalAuthority.find_by(snac: '00QB')
      expect(la2.name).to eq("Aberdeenshire Council")
    end
  end
end
