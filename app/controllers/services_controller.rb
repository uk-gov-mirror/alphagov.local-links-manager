class ServicesController < ApplicationController
  def index
    @services = Service.enabled.order(broken_link_count: :desc)
  end
end
