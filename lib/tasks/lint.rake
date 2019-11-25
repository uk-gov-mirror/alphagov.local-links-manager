desc "Run govuk-lint with similar params to CI"
task "lint" do
  sh "bundle exec rubocop --parallel --format clang app spec lib"
  sh "bundle exec govuk-lint-sass app/assets/stylesheets"
end
