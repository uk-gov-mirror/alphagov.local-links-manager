require "gds_api/link_checker_api"

class WebhooksController < ApplicationController
  skip_before_action :require_signin_permission!

  def link_check_callback
    LocalLinksManager::CheckLinks::LinkStatusUpdater.new.call(
      GdsApi::LinkCheckerApi::BatchReport.new(
        params.to_unsafe_hash
      )
    )
  end
end
