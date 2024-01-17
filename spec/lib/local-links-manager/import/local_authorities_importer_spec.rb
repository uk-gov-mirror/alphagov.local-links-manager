describe LocalLinksManager::Import::LocalAuthoritiesImporter do
  def fixture_file(file)
    File.expand_path("fixtures/#{file}", File.dirname(__FILE__))
  end

  describe "import of local authorities from CSV" do
    let(:csv_fixture_file) { fixture_file("local-authorities.csv") }
    let(:source_data) { CSV.read(csv_fixture_file) }
    let(:headers) do
      %w[id gss snac local_custodian_code tier_id parent_local_authority_id slug country_name homepage_url name]
    end

    describe "importing local authorities without connecting parents" do
      context "successful CSV import" do
        it "reports a successful import" do
          expect(described_class.import_from_csv(csv_fixture_file)).to be_successful
        end

        it "imports local authorities" do
          described_class.import_from_csv(csv_fixture_file)
          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: "S12000033")

          expect(la.name).to eq("Aberdeen City Council")
          expect(la.snac).to eq("00QA")
          expect(la.tier).to eq("unitary")
          expect(la.slug).to eq("aberdeen-city-council")
          expect(la.country_name).to eq("Scotland")
        end

        it "updates name, SNAC, slug and tier fields" do
          described_class.import_from_csv(csv_fixture_file)
          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["9999", "S12000033", "XXXX", 9000, 2, nil, "another-slug", "Scotland", "http://www.something", "A Different Council"],
          ])
          described_class.import_from_csv(csv_fixture_file)

          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: "S12000033")

          expect(la.name).to eq("A Different Council")
          expect(la.snac).to eq("XXXX")
          expect(la.slug).to eq("another-slug")
          expect(la.tier).to eq("district")
          expect(la.country_name).to eq("Scotland")
        end

        it "skips updating if GSS or SNAC code is blank" do
          described_class.import_from_csv(csv_fixture_file)
          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["2120", "S12000033", nil, 9000, 3, nil, "different-council-slug", "Scotland", "http://www.something", "A Different Council"],
            ["2118", nil, "00QB", 9000, 3, nil, "another-council-slug", "Scotland", "http://www.something", "Another Council"],
          ])
          described_class.import_from_csv(csv_fixture_file)

          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: "S12000033")
          expect(la.name).to eq("Aberdeen City Council")

          la2 = LocalAuthority.find_by(snac: "00QB")
          expect(la2.name).to eq("Aberdeenshire Council")
        end
      end

      context "check imported data" do
        before do
          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["2120", "S12000033", "00QA", 9000, 3, nil, "aberdeen-city-council", "Scotland", "http://www.something", "Aberdeen City Council"],
          ])
        end

        context "when there are no local authorities missing from the import" do
          it "returns success response" do
            create(:local_authority, gss: "S12000033")

            expect(described_class.new.authorities_from_csv(csv_fixture_file)).to be_successful
          end
        end

        context "when a local authority is no longer in the import" do
          before do
            create(:local_authority, gss: "S12000033")
            create(:local_authority, gss: "S12000034")
            create(:local_authority, gss: "S12000035")
          end

          it "returns response with error about missing local authority" do
            response = described_class.new.authorities_from_csv(csv_fixture_file)
            expect(response).to_not be_successful
            expect(response.errors).to include(/2 LocalAuthorities are no longer in the import source/)
          end

          it "does not delete anything" do
            described_class.new.authorities_from_csv(csv_fixture_file)
            expect(LocalAuthority.count).to eq(3)
          end
        end
      end
    end

    describe "importing of local authorities with connecting parents" do
      let(:importer) { described_class.new }

      context "for local authorities with parents" do
        let(:parent_local_authority) { LocalAuthority.find_by(slug: "buckinghamshire-county-council") }

        before do
          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["1724", "E10000002", "11", 9000, 1, nil, "buckinghamshire-county-council", "England", "http://www.something", "Buckinghamshire County Council"],
            ["1999", "E07000999", "11UB", 9001, 2, 1724, "aylesbury-district-council", "England", "http://www.something-else", "Aylesbury District Council"],
          ])
        end

        it "reports a successful import" do
          expect(importer.authorities_from_csv(csv_fixture_file)).to be_successful
        end

        it "imports the local authorities and their relationships" do
          importer.authorities_from_csv(csv_fixture_file)

          expect(LocalAuthority.count).to eq(2)

          la = LocalAuthority.find_by(slug: "aylesbury-district-council")

          expect(la.name).to eq("Aylesbury District Council")
          expect(la.snac).to eq("11UB")
          expect(la.tier).to eq("district")
          expect(la.slug).to eq("aylesbury-district-council")
          expect(la.country_name).to eq("England")
          expect(la.parent_local_authority_id).to eq(parent_local_authority.id)
        end
      end

      context "when a child local authority is an orphan" do
        before do
          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["2120", "S12000033", "00QA", 9000, 3, 1234, "aberdeen-city-council", "Scotland", "http://www.aberdeen", "Aberdeen City Council"],
          ])
        end

        it "does not trigger a success message" do
          response = importer.authorities_from_csv(csv_fixture_file)

          expect(response).to_not be_successful
          expect(response.errors).to include("1 LocalAuthority is orphaned.\naberdeen-city-council\n")
        end
      end

      context "when there are orphaned and missing local authorities" do
        it "shows both errors in the response" do
          create(:local_authority, gss: "S12000033", slug: "aberdeen-city-council")
          create(:local_authority, gss: "S12000034", slug: "gotham-city-council")
          create(:local_authority, gss: "S12000035", slug: "metropolis-city-council")

          allow(CSV).to receive(:read).with(csv_fixture_file).and_return([
            headers,
            ["2120", "S12000033", "00QA", 9000, 3, 1234, "aberdeen-city-council", "Scotland", "http://www.aberdeen", "Aberdeen City Council"],
          ])

          response = importer.authorities_from_csv(csv_fixture_file)

          expect(response).to_not be_successful
          expect(response.errors).to include("1 LocalAuthority is orphaned.\naberdeen-city-council\n")
          expect(response.errors).to include("2 LocalAuthorities are no longer in the import source.\ngotham-city-council\nmetropolis-city-council\n")
        end
      end
    end
  end
end
