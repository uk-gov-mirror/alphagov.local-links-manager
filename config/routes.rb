# http://local-links-manager.dev.gov.uk/local_authorities/aberdeen/services/name/interactions
Rails.application.routes.draw do
  root to: 'local_authorities#index'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources "local_authorities", only: [:index, :edit, :update], param: :slug do
    resources "services", only: [:index], param: :slug do
      resources "interactions", only: [:index], param: :slug do
        resource "links", only: [:edit, :update, :destroy]
      end
    end
  end

  get '/check_homepage_links_status.csv', to: 'links#homepage_links_status_csv'
  get '/check_links_status.csv', to: 'links#links_status_csv'

  get '/api/link', to: 'api#link'

  get '/api/local-authority', to: 'api#local_authority'

  get '/links-export', to: 'links#exported_links'

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
