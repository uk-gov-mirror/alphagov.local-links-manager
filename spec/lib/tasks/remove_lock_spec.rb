RSpec.describe "Remove Redis lock" do
  describe "unlock" do
    before do
      Rake::Task["unlock"].reenable
    end

    context "when there are no arguments passed" do
      it "outputs a helpful message" do
        expect { Rake::Task["unlock"].invoke }.to output("Pass in a lock key. Eg. unlock['check-links']\n").to_stdout
      end
    end

    context "when lock key is passed as an argument" do
      it "outputs a message if the lock is successfully unlocked" do
        distributed_lock = LocalLinksManager::DistributedLock.new("analytics-import")

        distributed_lock.lock(lock_obtained: -> { "analytics-import" }, lock_not_obtained: -> {})

        expect { Rake::Task["unlock"].invoke("analytics-import") }.to output("analytics-import successfully unlocked.\n").to_stdout
      end

      it "outputs a message if the lock does not exist" do
        expect { Rake::Task["unlock"].invoke("analytics-import") }.to output("No lock exists for analytics-import\n").to_stdout
      end
    end
  end
end
