require 'rails_helper'
require 'local-links-manager/import/links_importer'

describe LocalLinksManager::Import::LinksImporter, csv_importer: true do
  describe '#import_records' do
    let(:csv_downloader) { instance_double CsvDownloader }
    subject { described_class.new(csv_downloader) }

    context 'when links download is successful' do
      it 'imports links' do
        service = FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
        interaction_0 = FactoryGirl.create(:interaction, lgil_code: 0, label: 'Interaction 0')
        interaction_1 = FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')
        FactoryGirl.create(:service_interaction, service: service, interaction: interaction_0)
        FactoryGirl.create(:service_interaction, service: service, interaction: interaction_1)
        local_authority_1 = FactoryGirl.create(:local_authority, name: 'london', snac: '00AB', gss: '123')
        local_authority_2 = FactoryGirl.create(:local_authority, name: 'exeter', snac: '00AD', gss: '456')

        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '00AD',
            url: 'http://www.example.com/123/0/apply',
          },
          {
            lgil_code: '1',
            lgsl_code: '123',
            snac: '00AB',
            url: 'http://www.example.com/123/1/exemption',
          }
        ]

        stub_csv_rows(csv_rows)

        subject.import_records

        expect(Link.count).to eq(2)
        expect(local_authority_1.links.count).to eq(1)
        expect(local_authority_1.links.first.url).to eq 'http://www.example.com/123/1/exemption'

        expect(local_authority_2.links.count).to eq(1)
        expect(local_authority_2.links.first.url).to eq 'http://www.example.com/123/0/apply'

        expect(subject.modified_record_count).to eq 2
      end

      it 'does not create new links for rows in the csv without a matching LocalAuthority instance' do
        service = FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
        interaction = FactoryGirl.create(:interaction, lgil_code: 0, label: 'Interaction 0')
        FactoryGirl.create(:service_interaction, service: service, interaction: interaction)

        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '00AB',
            url: 'http://www.example.com/123/0/apply',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(Link.exists?(url: 'http://www.example.com/123/0/apply')).to be_falsey
        expect(subject.missing_record_count).to eq 1
      end

      it 'does not create new links for rows in the csv without a matching ServiceInteraction instance' do
        FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
        FactoryGirl.create(:interaction, lgil_code: 0, label: 'Interaction 0')
        FactoryGirl.create(:local_authority, snac: '00AB', gss: '123')

        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '00AB',
            url: 'http://www.example.com/123/0/apply',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(Link.exists?(url: 'http://www.example.com/123/0/apply')).to be_falsey
        expect(subject.missing_record_count).to eq 1
      end

      it 'overwrites existing links' do
        service = FactoryGirl.create(:service, lgsl_code: 123, label: 'Service 123')
        interaction = FactoryGirl.create(:interaction, lgil_code: 0, label: 'Interaction 0')
        service_interaction = FactoryGirl.create(:service_interaction, service: service, interaction: interaction)
        local_authority = FactoryGirl.create(:local_authority, snac: '00AB', gss: '123')
        link = FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction, url: 'http://example.com/to-be-changed')

        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '00AB',
            url: 'http://www.example.com/this-is-now-different',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(link.reload.url).to eq 'http://www.example.com/this-is-now-different'
      end

      it 'ignores rows where the snac field is blank' do
        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '',
            url: 'http://www.example.com/123/0/apply',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(subject.ignored_rows_count).to eq 1
      end

      it 'ignores rows where the url field is an x' do
        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '00AB',
            url: 'x',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(subject.ignored_rows_count).to eq 1
      end

      it 'ignores rows where the snac field is an old NI SNAC (starts with 95)' do
        csv_rows = [
          {
            lgil_code: '0',
            lgsl_code: '123',
            snac: '95A',
            url: 'http://www.example.com/123/0/apply',
          },
        ]
        stub_csv_rows(csv_rows)

        subject.import_records

        expect(subject.ignored_rows_count).to eq 1
      end
    end

    context 'when links download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        subject.import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        subject.import_records
      end
    end
  end
end
