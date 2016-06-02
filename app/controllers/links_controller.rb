class LinksController < ApplicationController
  def edit
    load_dependencies
    @link = Link.get_link(params)
  end

  def update
    @link = Link.get_link(params)
    @link.url = params[:link][:url]
    validate_and_save(@link)
  end

  def create
    @link = Link.new
    @link.local_authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @link.service_interaction = ServiceInteraction.find_by(
      service: Service.find_by(slug: params[:service_slug]),
      interaction: Interaction.find_by(slug: params[:interaction_slug])
    )
    @link.url = params[:link][:url]

    validate_and_save(@link)
  end

private

  def validate_and_save(link)
    load_dependencies
    if link.save
      flash[:success] = "Link has been saved."
      flash[:lgil] = @interaction.lgil_code
      redirect_to local_authority_service_interactions_path(service_slug: params[:service_slug])
    else
      flash.now[:danger] = "Please enter a valid link."
      render :edit
    end
  end

  def load_dependencies
    @local_authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @interaction = Interaction.find_by(slug: params[:interaction_slug])
    @service = Service.find_by(slug: params[:service_slug])
  end
end
