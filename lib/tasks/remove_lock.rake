require "redis-lock"

desc "Unlock lock"
task :unlock, [] => :environment do |_task, args|
  if args.extras.empty?
    puts "Pass in a lock key. Eg. unlock['check-links']"
  else
    lock = LocalLinksManager::DistributedLock.new(args.extras.first.to_s)
    if lock.locked?
      lock.unlock
      puts "#{args.extras.first} successfully unlocked."
    else
      puts "No lock exists for #{args.extras.first}"
    end
  end
end
