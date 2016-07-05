require 'redis-lock'

module LocalLinksManager
  class DistributedLock
    LIFETIME = (60 * 60) # seconds

    def initialize(lock_name)
      @lock_name = lock_name
    end

    def lock
      Services.redis.lock("local-links-manager:#{Rails.env}:#{@lock_name}", life: LIFETIME) do
        Rails.logger.debug('Successfully got a lock. Running...')
        yield if block_given?
      end
    rescue Redis::Lock::LockNotAcquired => e
      Rails.logger.debug("Failed to get lock for #{@lock_name} (#{e.message}). Another process probably got there first.")
    end
  end
end
