describe LocalLinksManager::Import::LocalCustodianCodesImporter do
  describe "#import_from_csv" do
    it "extracts local custodian codes from CSVs containing Great Britain Local Authorities" do
      local_authority_1 = create(:local_authority, slug: "leicestershire", local_custodian_code: nil)
      local_authority_2 = create(:local_authority, slug: "surrey-heath", local_custodian_code: nil)
      local_authority_3 = create(:local_authority, slug: "stockton-on-tees", local_custodian_code: nil)
      described_class.new.import_from_csv("spec/lib/local-links-manager/import/fixtures/addressbase-local-custodian-codes-test.csv")

      expect(local_authority_1.reload.local_custodian_code).to eq "2460"
      expect(local_authority_2.reload.local_custodian_code).to eq "3640"
      expect(local_authority_3.reload.local_custodian_code).to eq "738"
    end

    it "extracts local custodian codes from CSVs containing Northern Ireland Local Authorities" do
      local_authority = create(:local_authority, slug: "belfast", local_custodian_code: nil)
      described_class.new.import_from_csv("spec/lib/local-links-manager/import/fixtures/addressbase-local-custodian-code-Northern-Ireland-test.csv")

      expect(local_authority.reload.local_custodian_code).to eq "8132"
    end

    it "extracts local custodian codes from CSVs containing Isle of Man Local Authorities" do
      local_authority = create(:local_authority, slug: "port-erin", local_custodian_code: nil)
      described_class.new.import_from_csv("spec/lib/local-links-manager/import/fixtures/addressbase-local-custodian-code-islands-test.csv")

      expect(local_authority.reload.local_custodian_code).to eq "8358"
    end
  end
end
