module LinkImporterUtils
  def clear_errors_from_links_importer(links_importer)
    if links_importer.errors.count == links_importer.total_rows
      "Errors on all lines. Ensure a New URL column exists, with all rows either blank or a valid URL"
    elsif links_importer.errors.count > 50
      errors = links_importer.errors.first(50).map { |e| line_number_from_error(e) }
      ["#{links_importer.errors.count} Errors detected. Please ensure a valid entry in the New URL column for lines (showing first 50):"] + errors
    else
      errors = links_importer.errors.map { |e| line_number_from_error(e) }
      ["#{links_importer.errors.count} Errors detected. Please ensure a valid entry in the New URL column for lines:"] + errors
    end
  end

  def line_number_from_error(error)
    match_element = /\ALine (\d+): invalid URL/.match(error)
    match_element[1]
  end

  def attempt_import(type, object)
    if params[:csv]
      links_importer = LocalLinksManager::Import::Links.new(type:, object:)
      update_count = links_importer.import_links(params[:csv].read)
      if links_importer.errors.any?
        flash[:danger] = clear_errors_from_links_importer(links_importer)
      elsif update_count.zero?
        flash[:warning] = "No records updated. (If you were expecting updates, check the format of the uploaded file)"
      else
        flash[:success] = "#{update_count} #{'link has'.pluralize(update_count)} been updated"
      end
    else
      flash[:danger] = "A CSV file must be provided."
    end
  end
end
