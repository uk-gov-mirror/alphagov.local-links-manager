class ImportComparer
  def initialize(import_type)
    @import_type = import_type
    @records_in_source = Set.new
    @missing = Set.new
  end

  def add_source_record(record_key)
    @records_in_source.add(record_key)
  end

  def check_missing_records(saved_records)
    saved_records.each do |record|
      record_key = yield(record)
      unless @records_in_source.include? record_key
        @missing.add(record_key)
      end
    end

    notify_record_status
  end

private

  def notify_record_status
    @service_desc = "Import #{@import_type.pluralize} into Local Links Manager"

    if @missing.empty?
      confirm_records_are_present
    else
      alert_missing_records
    end
  end

  def confirm_records_are_present
    Services.icinga_check(@service_desc, true, "Success")
  end

  def alert_missing_records
    Services.icinga_check(@service_desc, false, error_message(@missing))
  end

  def error_message(missing)
    suffix = "no longer in the import source."
    if missing.count == 1
      "1 #{@import_type} is #{suffix}"
    else
      "#{missing.count} #{@import_type.pluralize} are #{suffix}\n#{list_missing(missing)}\n"
    end
  end

  def list_missing(missing)
    missing.to_a.sort.join("\n")
  end
end
