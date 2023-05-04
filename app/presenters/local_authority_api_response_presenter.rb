class LocalAuthorityApiResponsePresenter
  def initialize(authority)
    @authority = authority
  end

  def present
    local_authority_json = {
      "local_authorities" => [
        present_local_authority(@authority),
      ],
    }
    if parent
      local_authority_json["local_authorities"] << present_local_authority(parent)
    end

    local_authority_json
  end

private

  def present_local_authority(local_authority)
    LocalAuthorityHashPresenter.new(local_authority).to_h
  end

  def parent
    @parent ||= @authority.parent_local_authority
  end
end
