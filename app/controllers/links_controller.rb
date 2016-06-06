class LinksController < ApplicationController
  before_action :load_dependencies

  def edit; end

  def update
    @link.url = params[:link][:url]

    if @link.save
      redirect
    else
      flash.now[:failed_action] = "Please enter a valid link."
      render :edit
    end
  end

  def destroy
    if @link.destroy
      redirect('deleted')
    else
      flash.now[:failed_action] = "Could not delete link."
      render :edit
    end
  end

private

  def load_dependencies
    @local_authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @interaction = Interaction.find_by(slug: params[:interaction_slug])
    @service = Service.find_by(slug: params[:service_slug])
    @link = Link.retrieve(params)
  end

  def redirect(action = 'saved')
    flash[:success_action] = "Link has been #{action}."
    flash[:lgil] = @interaction.lgil_code
    redirect_to local_authority_service_interactions_path(service_slug: params[:service_slug])
  end
end
