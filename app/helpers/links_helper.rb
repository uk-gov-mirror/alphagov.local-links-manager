module LinksHelper
  def display_link_for(interaction)
    if @links.key? interaction
      link_to nil, @links[interaction][:url]
    end
  end

  def display_link_status_for(interaction)
    @links.key?(interaction) ? @links[interaction][:status] : "No link"
  end

  def display_link_last_checked_time(interaction)
    @links[interaction][:last_checked] if @links.key?(interaction)
  end

  def set_label_status_class(interaction)
    @links[interaction][:label_status] if @links.key?(interaction)
  end

  def status_for(link)
    status_description(link.status) if link && link.status
  end

  def last_checked(link)
    if link && link.link_last_checked
      "Checked #{time_ago_in_words(link.link_last_checked)} ago"
    elsif link
      "Link not checked"
    end
  end

  def status_description(status)
    return "Good" if status == '200'
    return "Broken Link #{status}" if status.start_with?('4')
    return "Server Error #{status}" if status.start_with?('5')
    status
  end

  def label_status(link)
    if link && link.status
      return "label label-success" if link.status == '200'
      return "label label-danger" if link.status.start_with?('4') || link.status.start_with?('5')
      return "" if link.status == 'Timeout Error'
      "label label-danger"
    end
  end

  def interaction_button_text(interaction)
    @links.key?(interaction) ? 'Edit link' : 'Add link'
  end

  def homepage_button_text(authority)
    authority.homepage_url.blank? ? 'Add link' : 'Edit link'
  end
end
