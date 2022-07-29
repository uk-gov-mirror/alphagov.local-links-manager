describe "local-authorities.csv" do
  let(:path_to_csv) { File.expand_path("../../data/local-authorities.csv", File.dirname(__FILE__)) }
  let(:expected_structure) do
    {
      id: {
        matcher: /^\d+$/,
        optional: false,
      },
      gss: {
        matcher: /^[A-Z]\d+$/,
        optional: false,
      },
      snac: {
        matcher: /^[0-9]+{2}([A-Z+]{2})?|[EN][0-9]+{8}$/, # Seems to vary, e.g. `47`, `19UJ`, `E06000062`
        optional: false,
      },
      local_custodian_code: {
        matcher: /^\d+{3,4}$/,
        optional: false,
      },
      tier_id: {
        matcher: /^[1-3]$/,
        optional: false,
      },
      parent_local_authority_id: {
        matcher: /^\d+$/,
        optional: true,
      },
      slug: {
        matcher: /^[a-z-]+$/,
        optional: false,
      },
      country_name: {
        matcher: /^England|Scotland|Wales|Northern Ireland+$/,
        optional: false,
      },
      homepage_url: {
        matcher: /^https?:\/\/.+$/,
        optional: false,
      },
      name: {
        matcher: /^[a-zA-Z ,&-]+$/,
        optional: false,
      },
    }
  end

  it "contains a consistent number of 'columns' in each row" do
    rows = CSV.read(path_to_csv)
    column_counts = rows.map(&:count).uniq

    expect(column_counts.count).to eq(1), "Inconsistent CSV: every row should have same number of columns. Detected the following column counts: #{column_counts}. Is there an extra comma somewhere?"
  end

  it "has headings in the right order" do
    rows = CSV.read(path_to_csv)
    expected_headings = expected_structure.keys.map(&:to_s)

    expect(rows.first).to eq(expected_headings)
  end

  it "has rows that follow the right structure" do
    rows = CSV.read(path_to_csv)
    data_rows = rows.drop(1)

    expect(data_rows).to all(have_valid_structure)
  end
end

RSpec::Matchers.define :have_valid_structure do
  match do |row|
    options = expected_structure.values
    row.each_with_index do |value, index|
      if value.nil?
        if options[index][:optional]
          next
        else
          return false # datapoint was `nil` when it shouldn't be
        end
      end
      return false unless value.match(options[index][:matcher])
    end
  end

  failure_message do |row|
    "row #{row} did not match expected structure"
  end
end
