require 'local-links-manager/export/link_status_exporter'

class LinksController < ApplicationController
  before_action :load_dependencies

  def edit
    flash[:back] = request.env['HTTP_REFERER']
    if flash[:link_url]
      @link.url = flash[:link_url]
      @link.validate
    end
  end

  def update
    @link.url = link_url

    if @link.save
      @link.local_authority.update_broken_link_count
      @link.service.update_broken_link_count
      redirect
    else
      flash[:danger] = "Please enter a valid link."
      flash[:back] = flash[:back]
      redirect_back
    end
  end

  def destroy
    if @link.destroy
      redirect('deleted')
    else
      flash.now[:danger] = "Could not delete link."
      flash[:back] = flash[:back]
      flash[:danger] = "Could not delete link."
      redirect_back
    end
  end

  def homepage_links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.homepage_links_status_csv
    send_data data, filename: "homepage_links_status.csv"
  end

  def links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.links_status_csv
    send_data data, filename: "links_status.csv"
  end

private

  def load_dependencies
    @local_authority = LocalAuthorityPresenter.new(LocalAuthority.find_by(slug: params[:local_authority_slug]))
    @interaction = Interaction.find_by(slug: params[:interaction_slug])
    @service = Service.find_by(slug: params[:service_slug])
    @link = Link.retrieve(params)
  end

  def set_back_url_before_post_request
    flash[:back] = flash[:back] || request.env['HTTP_REFERER']
  end

  def link_url
    params[:link][:url].strip
  end

  def redirect_back
    flash[:link_url] = link_url
    redirect_to edit_link_path(@local_authority, @service, @interaction)
  end

  def redirect(action = 'saved')
    flash[:success] = "Link has been #{action}."
    flash[:lgil] = @interaction.lgil_code
    redirect_to local_authority_with_service_path(local_authority_slug: params[:local_authority_slug], service_slug: params[:service_slug])
  end
end
