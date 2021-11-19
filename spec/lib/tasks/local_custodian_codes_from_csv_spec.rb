describe "Import local custodian codes task" do
  describe "import:local_custodian_codes" do
    it "should update local_custodian_code field for LocalAuthority with correct code" do
      args = Rake::TaskArguments.new(%i[filename], ["spec/lib/local-links-manager/import/fixtures/addressbase-local-custodian-codes-test.csv"])
      local_authority = create(:local_authority, slug: "leicestershire", local_custodian_code: nil)
      expect { Rake::Task["import:local_custodian_codes"].execute(args) }
        .to change { local_authority.reload.local_custodian_code }.from(nil).to("2460")
    end
  end
end
