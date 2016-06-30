require 'rails_helper'
require 'local-links-manager/check_links/homepage_status_updater'

describe LocalLinksManager::CheckLinks::HomepageStatusUpdater do
  let(:link_checker) { double :link_checker, check_links: { local_authority_1.homepage_url => ['200', @time], local_authority_2.homepage_url  => ['200', @time] } }
  let(:local_authority_1) { FactoryGirl.create(:local_authority) }
  let(:local_authority_2) {
    FactoryGirl.create(:local_authority,
      gss: 'S12000042',
      name: 'Lewisham Council',
      snac: '00QD',
      tier: 'unitary',
      homepage_url: 'http://www.lewisham.gov.uk')
  }
  subject(:status_updater) { described_class.new(link_checker) }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  describe '#update' do
    it 'updates the link\'s status code and link last checked time in the database' do
      status_updater.update

      expect(local_authority_1.reload.status).to eq('200')
      expect(local_authority_2.reload.link_last_checked).to eq(@time)
    end
  end
end
