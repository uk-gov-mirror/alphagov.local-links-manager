require 'rails_helper'
require 'local-links-manager/import/import_comparer'

describe ImportComparer do
  let(:destination_records) { (1..8).map { |num| RaceCompetitor.new(num) } }
  subject(:ImportComparer) { described_class.new("racer") }

  context 'when records that are in the destination are missing from the source' do
    let(:incomplete_source_records) { (1..5).map { |num| RaceCompetitor.new(num) } }

    it 'detects them and alerts Icinga' do
      expect(Services).to receive(:icinga_check).with(
        "Import racers into Local Links Manager",
        false,
        "3 racers are no longer in the import source.\n6\n7\n8\n")

      incomplete_source_records.each do |racer|
        subject.add_source_record(racer.number)
      end

      subject.check_missing_records(destination_records, &:number)
    end
  end

  context 'when all destination records are still present in the source' do
    let(:complete_source_records) { (1..9).map { |num| RaceCompetitor.new(num) } }

    it 'tells Icinga that everything is fine!' do
      expect(Services).to receive(:icinga_check).with(
        "Import racers into Local Links Manager",
        true,
        "Success")

      complete_source_records.each do |racer|
        subject.add_source_record(racer.number)
      end

      subject.check_missing_records(destination_records, &:number)
    end
  end
end

class RaceCompetitor
  attr_accessor :number

  def initialize(race_number)
    @number = race_number
  end
end
