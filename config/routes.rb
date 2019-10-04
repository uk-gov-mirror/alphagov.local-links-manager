Rails.application.routes.draw do
  root to: "links#index"

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  resources "local_authorities", only: %i[index show], param: :local_authority_slug do
    member do
      get "download_links_csv"
      post "upload_links_csv"
    end
  end

  resources "services", only: %i[index show], param: :service_slug

  scope "/local_authorities/:local_authority_slug/services/:service_slug" do
    root to: redirect("/local_authorities/%{local_authority_slug}")
    resource ":interaction_slug", only: %i[edit update destroy], controller: "links", as: "link"
  end

  get "/check_homepage_links_status.csv", to: "links#homepage_links_status_csv"
  get "/check_links_status.csv", to: "links#links_status_csv"

  get "/bad_links_url_status.csv", to: "links#bad_links_url_and_status_csv"

  get "/bad_homepage_url_status.csv", to: "local_authorities#bad_homepage_url_and_status_csv"

  get "/api/link", to: "api#link"

  get "/api/local-authority", to: "api#local_authority"

  post "/link-check-callback", to: "webhooks#link_check_callback", as: :link_checker_webhook

  # Serve the static CSV using NGINX instead of a controller
  get "/links-export", to: redirect("data/links_to_services_provided_by_local_authorities.csv")

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
