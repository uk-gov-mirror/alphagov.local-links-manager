class LocalAuthorityPresenter < SimpleDelegator
  include UrlStatusPresentation

  def homepage_status
    homepage_url.blank? ? "No link" : status_description
  end

  def homepage_link_last_checked
    homepage_url.blank? ? "" : last_checked
  end

  def authority_status
    return "inactive" unless active?
    return "active, but being retired" if active_end_date

    "active"
  end

  def should_display_end_notes?
    return true unless active?
    return true if active? && active_end_date

    false
  end

  def active_end_date_title
    active? ? "Date authority is due to become inactive" : "Date authority became inactive"
  end
end
