module StubCSVRows
  def stub_csv_rows(rows)
    receive_each_row_and_yield = rows
      .to_enum
      .each
      .with_object(receive(:each_row)) { |row, matcher|
        matcher.and_yield(row)
      }
    allow(csv_downloader).to receive_each_row_and_yield
  end
end

RSpec.configuration.include StubCSVRows, :csv_importer
