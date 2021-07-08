GovukAdminTemplate.configure do |c|
  c.app_title = "Local Links Manager"
  c.show_flash = false
  c.show_signout = true
end

GovukAdminTemplate.environment_label = ENV.fetch("GOVUK_ENVIRONMENT_NAME", "development").titleize
GovukAdminTemplate.environment_style = ENV["GOVUK_ENVIRONMENT_NAME"] == "production" ? "production" : "preview"
