class LinksController < ApplicationController
  def edit
    @local_authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @service = Service.find_by(slug: params[:service_slug])
    @interaction = Interaction.find_by(slug: params[:interaction_slug])

    @link = Link.get_link(params)
    if @link.nil?
      @link = Link.new
      @link.url = 'n/a'
    end
  end

  def update
    link = Link.get_link(params)
    link.url = params[:link][:url]
    validate_and_save(link)
  end

  def create
    link = Link.new
    link.local_authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    link.service = Service.find_by(slug: params[:service_slug])
    link.interaction = Interaction.find_by(slug: params[:interaction_slug])
    link.service_interaction = ServiceInteraction.find_by(service: link.service, interaction: link.interaction)
    link.url = params[:link][:url]

    validate_and_save(link)
  end

private

  def validate_and_save(link)
    if link.valid?
      link.save!
      flash[:success] = "Link has been saved."
      redirect_to local_authority_service_interactions_path(service_slug: params[:service_slug])
    else
      flash[:danger] = "Please enter a valid link."
      redirect_to action: "edit"
    end
  end
end
