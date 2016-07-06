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
  subject(:status_updater) { described_class.new(link_checker) }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  describe '#update' do
    it 'updates the link\'s status code and link last checked time in the database' do
      allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)
      status_updater.update

      expect(local_authority_1.reload.status).to eq('200')
      expect(local_authority_2.reload.link_last_checked).to eq(@time)
    end
  end
end
