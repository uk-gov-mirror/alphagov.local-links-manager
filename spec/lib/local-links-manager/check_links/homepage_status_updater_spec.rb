require 'rails_helper'
require 'local-links-manager/check_links/homepage_status_updater'

describe LocalLinksManager::CheckLinks::HomepageStatusUpdater do
  let(:link_checker) { double :link_checker }
  let!(:local_authority_1) { FactoryGirl.create(:local_authority) }
  let!(:local_authority_2) {
    FactoryGirl.create(:local_authority,
      name: 'Lewisham Council',
      homepage_url: 'http://www.lewisham.gov.uk')
  }
  let!(:local_authority_3) { FactoryGirl.create(:local_authority, homepage_url: nil )}
  subject(:status_updater) { described_class.new(link_checker) }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  describe '#update' do
    it 'updates the link\'s status and link last checked time in the database' do
      allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)
      status_updater.update

      expect(local_authority_1.reload.status).to eq('200')
      expect(local_authority_2.reload.link_last_checked).to eq(@time)
    end

    it 'does not update the status and link last checked time of a Local Authority that has a blank homepage url' do
      allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)
      status_updater.update
      
      expect(local_authority_3.reload.status).to be_nil
      expect(local_authority_3.reload.link_last_checked).to be_nil
    end
  end
end
