describe ApplicationHelper do
  describe "#namespaced_cache_key" do
    let(:cacheable_record) { double(:record, cache_key: "123") }
    let(:string) { double(:string, to_s: "789") }
    let(:result) do
      helper.namespaced_cache_key(
        cacheable_record,
        string,
        cacheable_record,
        string,
      )
    end

    it "returns a string comprised of the cache-keys of the params" do
      expect(result).to include "123/789/123/789"
    end
  end
end
