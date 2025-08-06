RSpec.describe "Distributed lock" do
  describe "LocalLinksManager::DistributedLock" do
    let(:distributed_lock) { LocalLinksManager::DistributedLock.new("analytics-import") }

    context "#initialize" do
      it "sets the lock_name" do
        expect(distributed_lock.lock_name).to eq("analytics-import")
      end

      it "sets the redis_lock" do
        expect(distributed_lock.redis_lock).to be_a(Redis::Lock)

        expect(distributed_lock.redis_lock.key).to eq("local-links-manager:analytics-import")
      end
    end

    context "#lock" do
      before do
        @lock_obtained = -> { "analytics-import" }
        @lock_not_obtained = -> {}
        allow(Rails.logger).to receive(:debug)
      end

      it "logs it got a lock if obtained successfully" do
        allow(distributed_lock.redis_lock).to receive(:lock).and_return(true)

        distributed_lock.lock(lock_obtained: @lock_obtained, lock_not_obtained: @lock_not_obtained)

        expect(Rails.logger).to have_received(:debug).with("Successfully got a lock. Running...")
      end

      it "logs it failed to get a log if not obtained successfully" do
        allow(distributed_lock.redis_lock).to receive(:lock).and_raise(Redis::Lock::LockNotAcquired, "Lock not acquired")

        distributed_lock.lock(lock_obtained: @lock_obtained, lock_not_obtained: @lock_not_obtained)

        expect(Rails.logger).to have_received(:debug).with("Failed to get lock for analytics-import (Lock not acquired). Another process probably got there first.")
      end
    end

    context "#unlock" do
      it "logs it unlocked the lock if successful" do
        allow(Rails.logger).to receive(:debug)
        allow(distributed_lock.redis_lock).to receive(:unlock).and_return(true)

        distributed_lock.unlock

        expect(Rails.logger).to have_received(:debug).with("Successfully unlocked analytics-import")
      end

      it "logs it failed to unlock if unsuccessful" do
        allow(Rails.logger).to receive(:error)
        allow(distributed_lock.redis_lock).to receive(:unlock).and_raise(StandardError, "Lock not successful")

        distributed_lock.unlock

        expect(Rails.logger).to have_received(:error).with("Failed to unlock analytics-import\nLock not successful")
      end
    end
  end
end
