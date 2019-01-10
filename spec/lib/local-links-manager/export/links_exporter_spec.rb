require 'rails_helper'
require 'local-links-manager/export/links_exporter'

describe LocalLinksManager::Export::LinksExporter do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  let(:exporter) { LocalLinksManager::Export::LinksExporter.new }

  describe '#export_links' do
    def test_url(local_authority, interaction)
      base_url = "http://www.example.com"
      "#{base_url}/#{local_authority.gss}/#{interaction.lgil_code}"
    end

    it "exports the links to CSV format with headings" do
      service = create(:service, lgsl_code: 123, label: 'Service 123')
      disabled_service = create(:disabled_service, lgsl_code: 666, label: 'Service 666')
      interaction_0 = create(:interaction, lgil_code: 0, label: 'Interaction 0')
      interaction_1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      interaction_2 = create(:interaction, lgil_code: 2, label: 'Interaction 2')
      service_interaction_0 = create(:service_interaction, service: service, interaction: interaction_0)
      service_interaction_1 = create(:service_interaction, service: service, interaction: interaction_1)
      service_interaction_2 = create(:service_interaction, service: service, interaction: interaction_2)
      disabled_service_interaction = create(:service_interaction, service: disabled_service, interaction: interaction_0)

      local_authority_1 = create(:local_authority, name: 'London', snac: '00AB', gss: '123')
      local_authority_2 = create(:local_authority, name: 'Exeter', snac: '00AD', gss: '456')

      create(:link, local_authority: local_authority_1, service_interaction: service_interaction_0, url: test_url(local_authority_1, interaction_0))
      create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1, url: test_url(local_authority_1, interaction_1))
      create(:link, local_authority: local_authority_2, service_interaction: service_interaction_0, url: test_url(local_authority_2, interaction_0))
      create(:link, local_authority: local_authority_2, service_interaction: service_interaction_1, url: test_url(local_authority_2, interaction_1))
      create(:link, local_authority: local_authority_2, service_interaction: disabled_service_interaction, url: test_url(local_authority_2, disabled_service_interaction))
      create(:missing_link, service_interaction: service_interaction_2)

      csv_file = File.read(fixture_file("exported_links.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end

    it "should use empty string if we don't have a real SNAC code" do
      service = create(:service, lgsl_code: 123, label: 'Service 123')
      interaction_1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_1 = create(:service_interaction, service: service, interaction: interaction_1)

      pretend_ni_authority = create(:local_authority, name: 'Belfast', snac: '456', gss: '456')

      create(:link, local_authority: pretend_ni_authority, service_interaction: service_interaction_1, url: test_url(pretend_ni_authority, interaction_1))

      csv_file = File.read(fixture_file("ni_link.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end
  end

  describe "#export_broken_links" do
    let(:la) { create(:local_authority) }
    let(:service) { create(:service) }
    let(:disabled_service) { create(:disabled_service) }
    let(:interaction_1) { create(:interaction) }
    let(:interaction_2) { create(:interaction) }
    let(:service_interaction_1) { create(:service_interaction, service: service, interaction: interaction_1) }
    let(:service_interaction_2) { create(:service_interaction, service: service, interaction: interaction_2) }
    let(:service_interaction_3) { create(:service_interaction, service: disabled_service, interaction: interaction_1) }
    let(:broken_link) { create(:broken_link, local_authority: la, url: "http://www.diagonalley.gov.uk/broken-link", service_interaction: service_interaction_1) }
    let(:ok_link) { create(:link, local_authority: la, url: "http://www.diagonalley.gov.uk/ok-link", status: "ok", service_interaction: service_interaction_2) }
    let(:disabled_link) { create(:broken_link, local_authority: la, url: "http://www.diagonalley.gov.uk/ok-link", service_interaction: service_interaction_3) }

    it "exports broken links for enabled services for a given local authority to CSV format with headings" do
      broken_link_data = "#{la.name},#{la.snac},#{la.gss},#{service.label}: #{interaction_1.label},#{service.lgsl_code},#{interaction_1.lgil_code},#{broken_link.url}"
      ok_link_data = "#{la.name},#{la.snac},#{la.gss},#{service.label}: #{interaction_2.label},#{service.lgsl_code},#{interaction_2.lgil_code},#{ok_link.url}"
      disabled_link_data = "#{la.name},#{la.snac},#{la.gss},#{disabled_service.label}: #{interaction_1.label},#{disabled_service.lgsl_code},#{interaction_1.lgil_code},#{disabled_link.url}"
      headings = (LocalLinksManager::Export::LinksExporter::HEADINGS + LocalLinksManager::Export::LinksExporter::BROKEN_LINKS_HEADINGS).join(",")
      csv = exporter.export_broken_links(la.id).split("\n")

      expect(csv).to include(broken_link_data)
      expect(csv).not_to include(ok_link_data)
      expect(csv).not_to include(disabled_link_data)
      expect(csv).to include(headings)
    end
  end
end
