class LinksController < ApplicationController

  def edit
    @link = Link.get_link(params)
    if @link.nil?
      @link = Link.new
      @link.url = 'n/a'
    end
  end
end
