Rails.application.routes.draw do
  root to: 'local_authorities#index'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
