require 'action_view'
require 'action_view/helpers'

class InteractionsController < ApplicationController
  include LinksHelper
  include ActionView::Helpers::DateHelper

  def index
    @authority = LocalAuthority.find_by_slug!(params[:local_authority_slug])
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = @service.interactions
    @local_authority_links_for_service = @authority.links.for_service(@service)
    @links = links_for_interactions.to_h
  end

  def links_for_interactions
    @local_authority_links_for_service.map do |link|
      [
        link.interaction,
        {
          url: link.url,
          status: status_for(link),
          last_checked: last_checked(link),
          label_status: label_status(link)
        }
      ]
    end
  end
end
