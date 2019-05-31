namespace :local_authority do
  desc "Redirect one local authority to another."
  task :redirect, %i(from to) => [:environment] do |_, args|
    old_local_authority = LocalAuthority.find_by!(slug: args.from)
    new_local_authority = LocalAuthority.find_by!(slug: args.to)
    old_local_authority.redirect(to: new_local_authority)
  end
end
