class LocalAuthoritiesController < ApplicationController
  include Sortable

  def index
    @authorities = LocalAuthority.all.order(sort_order)
  end

  def edit
    @authority = LocalAuthority.find_by(slug: params[:slug])
  end

  def update
    @authority = LocalAuthority.find_by(slug: params[:slug])
    @authority.homepage_url = params[:local_authority][:homepage_url].strip
    validate_and_save(@authority)
  end

private

  def validate_and_save(authority)
    if authority.save
      flash[:success] = "Homepage link has been saved."
      redirect_to local_authority_services_path(local_authority_slug: params[:slug])
    else
      flash.now[:danger] = "Please enter a valid link."
      render :edit
    end
  end

  def sort_order
    order = params[:sort_order] || default_sort_order
    sort_order_options.select { |k, _v| k == order.to_sym }
  end

  def default_sort_order
    :broken_link_count
  end

  def sort_order_options
    {
      broken_link_count: :desc,
      name: :asc
    }
  end
end
