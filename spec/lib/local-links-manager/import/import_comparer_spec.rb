require "local-links-manager/import/import_comparer"

describe LocalLinksManager::Import::ImportComparer do
  let(:destination_records) { (1..8).map { |num| RaceCompetitor.new(num) } }
  subject(:ImportComparer) { described_class.new }

  context "when records that are in the destination are missing from the source" do
    let(:incomplete_source_records) { (1..5).map { |num| RaceCompetitor.new(num) } }

    it "detects and returns them" do
      incomplete_source_records.each do |racer|
        subject.add_source_record(racer.number)
      end

      detected = subject.check_missing_records(destination_records, &:number)
      expect(detected).to match_array([6, 7, 8])
    end
  end

  context "when all destination records are still present in the source" do
    let(:complete_source_records) { (1..9).map { |num| RaceCompetitor.new(num) } }

    it "returns an empty array" do
      complete_source_records.each do |racer|
        subject.add_source_record(racer.number)
      end

      expect(subject.check_missing_records(destination_records, &:number)).to be_empty
    end
  end
end

class RaceCompetitor
  attr_accessor :number

  def initialize(race_number)
    @number = race_number
  end
end
