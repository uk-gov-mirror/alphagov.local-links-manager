require 'rails_helper'
require 'local-links-manager/export/links_exporter'

describe LocalLinksManager::Export::LinksExporter do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  let(:exporter) { LocalLinksManager::Export::LinksExporter.new }

  describe '#export_links' do
    it "exports the links to CSV format with headings" do
      service = FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
      disabled_service = FactoryGirl.create(:disabled_service, lgsl_code: 666, label: 'Service 666')
      interaction_0 = FactoryGirl.create(:interaction, lgil_code: 0, label: 'Interaction 0')
      interaction_1 = FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_0 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_0)
      service_interaction_1 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_1)
      disabled_service_interaction = FactoryGirl.create(:service_interaction, service: disabled_service, interaction: interaction_0)

      local_authority_1 = FactoryGirl.create(:local_authority, name: 'London', snac: '00AB', gss: '123')
      local_authority_2 = FactoryGirl.create(:local_authority, name: 'Exeter', snac: '00AD', gss: '456')

      FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_0)
      FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1)
      FactoryGirl.create(:link, local_authority: local_authority_2, service_interaction: service_interaction_0)
      FactoryGirl.create(:link, local_authority: local_authority_2, service_interaction: service_interaction_1)
      FactoryGirl.create(:link, local_authority: local_authority_2, service_interaction: disabled_service_interaction)

      csv_file = File.read(fixture_file("exported_links.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end

    it "should use empty string if we don't have a real SNAC code" do
      service = FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
      interaction_1 = FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_1 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_1)

      pretend_ni_authority = FactoryGirl.create(:local_authority, name: 'Belfast', snac: '456', gss: '456')

      FactoryGirl.create(:link, local_authority: pretend_ni_authority, service_interaction: service_interaction_1)

      csv_file = File.read(fixture_file("ni_link.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end
  end
end
