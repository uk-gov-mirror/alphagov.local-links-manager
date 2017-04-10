require "gds_api/link_checker_api"
require "local-links-manager/check_links/link_status_updater"

class WebhooksController < ApplicationController
  skip_before_action :require_signin_permission!
  skip_before_action :verify_authenticity_token

  def link_check_callback
    LocalLinksManager::CheckLinks::LinkStatusUpdater.new.call(
      GdsApi::LinkCheckerApi::BatchReport.new(
        params.to_unsafe_hash
      )
    )
  end
end
