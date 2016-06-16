module LinksHelper
  def display_link_for(interaction)
    if @links.key? interaction
      link_to nil, @links[interaction]
    else
      'No link'
    end
  end

  def interaction_button_text(interaction)
    @links.key?(interaction) ? 'Edit link' : 'Add link'
  end

  def homepage_button_text(authority)
    authority.homepage_url.blank? ? 'Add link' : 'Edit link'
  end
end
