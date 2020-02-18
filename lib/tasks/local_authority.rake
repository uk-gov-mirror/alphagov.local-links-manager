namespace :local_authority do
  desc "Redirect one local authority to another."
  task :redirect, %i(from to) => [:environment] do |_, args|
    old_local_authority = LocalAuthority.find_by!(slug: args.from)
    new_local_authority = LocalAuthority.find_by!(slug: args.to)
    old_local_authority.redirect(to: new_local_authority)
  end

  desc "Set local authority homepage URL"
  task :update_homepage, %i(slug new_url) => :environment do |_, args|
    local_authority = LocalAuthority.find_by!(slug: args.slug)
    local_authority.homepage_url = args.new_url
    local_authority.save!
  end
end
