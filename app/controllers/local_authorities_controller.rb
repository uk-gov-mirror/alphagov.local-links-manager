class LocalAuthoritiesController < ApplicationController
  def index
    @authorities = LocalAuthority.all.order(name: :asc)
  end
end
