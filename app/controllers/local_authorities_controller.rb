class LocalAuthoritiesController < ApplicationController
  def index
    @authorities = LocalAuthority.order(broken_link_count: :desc)
    raise RuntimeError.new('Missing Data') if @authorities.empty?
  end

  def edit
    @authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
  end

  def show
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @link_filter = params[:filter]
    @services = @authority.provided_services.order('services.label ASC')
    @links = links_for_authority.group_by { |link| link.service.id }
    @link_count = links_for_authority.count
  end

  def update
    @authority = LocalAuthority.find_by(slug: params[:local_authority_slug])
    @authority.homepage_url = params[:local_authority][:homepage_url].strip
    validate_and_save(@authority)
  end

private

  def links_for_authority
    @_links_for_authority ||= filtered_links
      .includes([:service, :interaction])
      .all
  end

  def filtered_links
    links = @authority.provided_service_links

    case params[:filter]
    when 'broken_links'
      links.currently_broken
    when 'good_links'
      links.good_links
    else
      links
    end
  end

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
