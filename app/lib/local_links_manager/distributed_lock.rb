require "redis-lock"

module LocalLinksManager
  class DistributedLock
    attr_accessor :lock_name, :redis_lock

    APP = "local-links-manager".freeze
    LIFETIME = (60 * 60) # seconds

    def initialize(lock_name)
      @lock_name = lock_name
      @redis_lock = Redis::Lock.new(Redis.current, "#{APP}:#{lock_name}", owner: APP, life: LIFETIME)
    end

    def lock(lock_obtained:, lock_not_obtained:)
      redis_lock.lock
      Rails.logger.debug("Successfully got a lock. Running...")
      lock_obtained.call
    rescue Redis::Lock::LockNotAcquired => e
      Rails.logger.debug("Failed to get lock for #{lock_name} (#{e.message}). Another process probably got there first.")
      lock_not_obtained.call
    end

    def unlock
      redis_lock.unlock
      Rails.logger.debug("Successfully unlocked #{lock_name}")
    rescue StandardError => e
      Rails.logger.error("Failed to unlock #{lock_name}\n#{e.message}")
    end

    delegate :locked?, to: :redis_lock
  end
end
