class WebhooksController < ApplicationController
  skip_before_action :require_signin_permission!

  def link_check_callback
    LocalLinksManager::CheckLinks::LinkStatusUpdater.new.call(payload)
  end

  def payload
    @payload ||= JSON.parse(request.body.read).deep_symbolize_keys
  end
end
