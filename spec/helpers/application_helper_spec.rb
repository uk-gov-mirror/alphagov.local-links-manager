describe ApplicationHelper do
  describe "#singular_or_plural" do
    it 'returns "singular" when the number is 1' do
      expect(helper.singular_or_plural(1)).to eq("singular")
    end

    it 'returns "plural" when the number is not 1' do
      expect(helper.singular_or_plural(2)).to eq("plural")
      expect(helper.singular_or_plural(0)).to eq("plural")
    end
  end
end
