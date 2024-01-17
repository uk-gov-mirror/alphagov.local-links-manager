describe LocalLinksManager::Import::ServiceInteractionsImporter, :csv_importer do
  describe "#import_records" do
    let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }

    context "when service interactions download is successful" do
      let!(:service0) { create(:service, lgsl_code: 1614, label: "Bursary Fund Service") }
      let!(:service1) { create(:service, lgsl_code: 13, label: "Abandoned shopping trolleys") }

      let!(:interaction0) { create(:interaction, lgil_code: 0, label: "Find out about") }
      let!(:interaction1) { create(:interaction, lgil_code: 30, label: "Contact") }

      let(:csv_rows) do
        [
          { lgsl_code: "1614", lgil_code: "0" },
          { lgsl_code: "13", lgil_code: "30" },
          { lgsl_code: "13", lgil_code: "0" },
          { lgsl_code: "1614", lgil_code: "30" },
        ]
      end

      let(:csv_rows_with_missing_entries) do
        [
          { lgsl_code: "1614", lgil_code: nil },
          { lgsl_code: nil, lgil_code: "0" },
        ]
      end

      let(:csv_rows_with_missing_associated_entries) do
        [
          { lgsl_code: "13", lgil_code: "999" },
          { lgsl_code: "999", lgil_code: "30" },
        ]
      end

      it "imports service interactions" do
        stub_csv_rows(csv_rows)

        expect(LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records).to be_successful

        expect(ServiceInteraction.count).to eq(4)

        service_interaction = ServiceInteraction.last
        expect(service_interaction.service_id).to eq(service0.id)
        expect(service_interaction.interaction_id).to eq(interaction1.id)
      end

      it "raises error and logs a warning when Identifier or Mapped Identifier is empty" do
        stub_csv_rows(csv_rows_with_missing_entries)

        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Service identifier/)
        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Interaction identifier/)

        response = LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/could not be created due to missing Service identifier/)
        expect(response.errors).to include(/could not be created due to missing Interaction identifier/)

        expect(ServiceInteraction.count).to eq(0)
      end

      it "raises error and logs a warning when an associated Service or Interaction is missing" do
        stub_csv_rows(csv_rows_with_missing_associated_entries)

        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Service/)
        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Interaction/)

        response = LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/could not be created due to missing Service/)
        expect(response.errors).to include(/could not be created due to missing Interaction/)

        expect(ServiceInteraction.count).to eq(0)
      end
    end

    context "when service interactions download is not successful" do
      it "logs the error on failed download" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with(/Error downloading CSV/)

        response = LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error downloading CSV/)
      end
    end

    context "when CSV data is malformed" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with(/Malformed CSV error/)

        response = LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Malformed CSV error/)
      end
    end

    context "when runtime error is raised" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(RuntimeError, "RuntimeError")

        expect(Rails.logger).to receive(:error).with(/Error RuntimeError/)

        response = LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error RuntimeError/)
      end
    end

    context "check imported data" do
      let(:import_comparer) { LocalLinksManager::Import::ImportComparer.new }
      let(:importer) { LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader, import_comparer) }

      context "when a service interaction is no longer in the CSV" do
        it "returns a failure message and does not delete anything" do
          service1614 = create(:service, lgsl_code: 1614, label: "Bursary Fund Service")

          interaction0 = create(:interaction, lgil_code: 0, label: "Find out about")
          interaction30 = create(:interaction, lgil_code: 30, label: "Contact")

          create(:service_interaction, service: service1614, interaction: interaction0)
          create(:service_interaction, service: service1614, interaction: interaction30)

          csv_rows = [
            { lgsl_code: "1614", lgil_code: "0" },
          ]
          stub_csv_rows(csv_rows)

          response = importer.import_records
          expect(response).not_to be_successful
          expect(response.errors).to include("1 ServiceInteraction is no longer in the import source.\n1614_30\n")

          expect(ServiceInteraction.count).to eq(2)
        end
      end

      context "when no service interactions are missing from the CSV" do
        it "reports a successful import" do
          service1614 = create(:service, lgsl_code: 1614, label: "Bursary Fund Service")

          interaction0 = create(:interaction, lgil_code: 0, label: "Find out about")
          interaction30 = create(:interaction, lgil_code: 30, label: "Contact")

          create(:service_interaction, service: service1614, interaction: interaction0)
          create(:service_interaction, service: service1614, interaction: interaction30)

          csv_rows = [
            { lgsl_code: "1614", lgil_code: "0" },
            { lgsl_code: "1614", lgil_code: "30" },
          ]
          stub_csv_rows(csv_rows)

          expect(importer.import_records).to be_successful
        end
      end
    end
  end
end
