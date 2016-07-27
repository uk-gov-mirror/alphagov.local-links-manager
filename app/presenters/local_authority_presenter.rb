class LocalAuthorityPresenter < SimpleDelegator
  include UrlStatusPresentation

  def homepage_button_text
    homepage_url.blank? ? 'Add link' : 'Edit link'
  end

  def homepage_status
    homepage_url.blank? ? 'No link' : status_description
  end
end
