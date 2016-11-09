class LocalAuthoritiesController < ApplicationController
  def index
    @authorities = LocalAuthority.all.order(broken_link_count: :desc)
  end

  def edit
    @authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
  end

  def show
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @services = @authority.provided_services.order(lgsl_code: :asc)
  end

  def update
    @authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @authority.homepage_url = params[:local_authority][:homepage_url].strip
    validate_and_save(@authority)
  end

private

  def validate_and_save(authority)
    if authority.save
      flash[:success] = "Homepage link has been saved."
      redirect_to local_authority_path(local_authority_slug: params[:local_authority_slug])
    else
      flash.now[:danger] = "Please enter a valid link."
      render :edit
    end
  end
end
