class LocalAuthorityHashPresenter
  def initialize(authority)
    @authority = authority
  end

  def to_h
    hash = {
      "name" => @authority.name,
      "homepage_url" => @authority.homepage_url,
      "country_name" => @authority.country_name,
      "tier" => @authority.tier,
      "slug" => @authority.slug,
      "gss" => @authority.gss,
    }
    hash["snac"] = @authority.snac if @authority.snac
    hash
  end
end
