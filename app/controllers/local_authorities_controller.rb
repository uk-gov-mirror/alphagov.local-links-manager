class LocalAuthoritiesController < ApplicationController
  include LinkFilterHelper
  include LinkImporterUtils

  def index
    @show_retired = params[:retired] == "true"

    @authorities = if @show_retired
                     LocalAuthority.order(broken_link_count: :desc)
                   else
                     LocalAuthority.active.order(broken_link_count: :desc)
                   end

    raise "Missing Data" if @authorities.empty?

    @breadcrumbs = index_breadcrumbs
  end

  def show
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by!(slug: params[:local_authority_slug]))
    @link_filter = params[:filter]
    @services = @authority.provided_services.order("services.label ASC")
    @links = links_for_authority.group_by { |link| link.service.id }
    @link_count = links_for_authority.count
    @breadcrumbs = local_authority_breadcrumbs(@authority)
  end

  def edit_url
    @authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
  end

  def update
    authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    authority.update!(homepage_url: params[:homepage_url])

    redirect_to local_authority_path(authority)
  end

  def download_links_csv
    @authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    authority_name = @authority.name.parameterize.underscore
    data = LocalLinksManager::Export::LocalAuthorityLinksExporter.new.export_links(@authority.id, params)
    send_data data, filename: "#{authority_name}_links.csv"
  end

  def upload_links_csv
    authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    attempt_import(:local_authority, authority)
    redirect_to local_authority_path(authority)
  end

  def bad_homepage_url_and_status_csv
    data = LocalLinksManager::Export::BadLinksUrlAndStatusExporter.local_authority_bad_homepage_url_and_status_csv
    send_data data, filename: "bad_homepage_url_status.csv"
  end

private

  def index_breadcrumbs
    [{ title: "Home", url: root_path }, { title: "Councils", url: local_authorities_path }]
  end

  def local_authority_breadcrumbs(local_authority)
    index_breadcrumbs + [{ title: local_authority.name, url: local_authority_path(local_authority) }]
  end

  def links_for_authority
    @links_for_authority ||= filtered_links(@authority.provided_service_links)
      .includes(%i[service interaction])
      .all
  end
end
