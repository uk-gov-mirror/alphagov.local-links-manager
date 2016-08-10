class LinksController < ApplicationController
  before_action :load_dependencies

  def homepage_links_status_csv
    data = LinkCheckCSVPresenter.homepage_links_status_csv
    filename = "homepage_link_status.csv"
    send_data data, filename: filename
  end

  def links_status_csv
    data = LinkCheckCSVPresenter.links_status_csv
    filename = "link_status.csv"
    send_data data, filename: filename
  end

  def exported_links
    send_file 'public/data/links_to_services_provided_by_local_authorities.csv', type: 'text/csv'
  end

  def edit; end

  def update
    @link.url = params[:link][:url].strip

    if @link.save
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
    redirect_to local_authority_service_interactions_path(service_slug: params[:service_slug])
  end
end
