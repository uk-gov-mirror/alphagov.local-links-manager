class LocalAuthorityPresenter < SimpleDelegator
  include UrlStatusPresentation

  def homepage_button_text
    homepage_url.blank? ? 'Add link' : 'Edit link'
  end
end
