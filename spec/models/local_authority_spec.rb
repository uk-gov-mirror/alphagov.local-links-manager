require 'rails_helper'

RSpec.describe LocalAuthority, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:gss) }
    it { should validate_presence_of(:snac) }
    it { should validate_presence_of(:tier) }

    it { should validate_uniqueness_of(:gss) }
    it { should validate_uniqueness_of(:snac) }

    describe 'homepage_url' do
      it { should allow_value('http://foo.com').for(:homepage_url) }
      it { should allow_value('https://foo.com/path/file.html').for(:homepage_url) }

      it { should_not allow_value('foo.com').for(:homepage_url) }
    end

    describe 'tier' do
      %w(county district unitary).each do |tier|
        it { should allow_value(tier).for(:tier) }
      end

      it { should_not allow_value(nil).for(:tier) }
      it { should_not allow_value('country').for(:tier) }
    end
  end
end
