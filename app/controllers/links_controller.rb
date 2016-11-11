require 'local-links-manager/export/link_status_exporter'

class LinksController < ApplicationController
  before_action :load_dependencies

  def homepage_links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.homepage_links_status_csv
    send_data data, filename: "homepage_links_status.csv"
  end

  def links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.links_status_csv
    send_data data, filename: "links_status.csv"
  end

  def edit; end

  def update
    @link.url = params[:link][:url].strip

    if @link.save
      @link.local_authority.update_broken_link_count
      @link.service.update_broken_link_count
      redirect
    else
      flash.now[:danger] = "Please enter a valid link."
      render :edit
    end
  end

  def destroy
    if @link.destroy
      redirect('deleted')
    else
      flash.now[:danger] = "Could not delete link."
      render :edit
    end
  end

private

  def load_dependencies
    @local_authority = LocalAuthorityPresenter.new(LocalAuthority.find_by(slug: params[:local_authority_slug]))
    @interaction = Interaction.find_by(slug: params[:interaction_slug])
    @service = Service.find_by(slug: params[:service_slug])
    @link = Link.retrieve(params)
  end

  def redirect(action = 'saved')
    flash[:success] = "Link has been #{action}."
    flash[:lgil] = @interaction.lgil_code
    redirect_to interactions_path(local_authority_slug: params[:local_authority_slug], service_slug: params[:service_slug])
  end
end
