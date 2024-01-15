class LocalAuthoritiesController < ApplicationController
  include LinkFilterHelper

  def index
    @authorities = LocalAuthority.order(broken_link_count: :desc)
    raise "Missing Data" if @authorities.empty?
  end

  def show
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by!(slug: params[:local_authority_slug]))
    @link_filter = params[:filter]
    @services = @authority.provided_services.order("services.label ASC")
    @links = links_for_authority.group_by { |link| link.service.id }
    @link_count = links_for_authority.count
  end

  def update
    authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    authority.update!(homepage_url: params[:authority][:homepage_url])

    redirect_to local_authority_path(authority)
  end

  def download_links_csv
    @authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    authority_name = @authority.name.parameterize.underscore
    data = LocalLinksManager::Export::LinksExporter.new.export_links(@authority.id, params)
    send_data data, filename: "#{authority_name}_links.csv"
  end

  def upload_links_csv
    authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])

    if params[:csv]
      links_importer = LocalLinksManager::Import::Links.new(authority)
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

    redirect_to local_authority_path(authority)
  end

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

  def bad_homepage_url_and_status_csv
    data = LocalLinksManager::Export::BadLinksUrlAndStatusExporter.local_authority_bad_homepage_url_and_status_csv
    send_data data, filename: "bad_homepage_url_status.csv"
  end

private

  def links_for_authority
    @links_for_authority ||= filtered_links(@authority.provided_service_links)
      .includes(%i[service interaction])
      .all
  end
end
