class InteractionPresenter < SimpleDelegator
  def initialize(interaction, presented_link = nil)
    @link = presented_link
    super(interaction)
  end

  def link_url
    @link.url if @link
  end

  def link_status
    @link ? @link.status_description : "No link"
  end

  def link_last_checked
    @link ? @link.last_checked : ""
  end

  def button_text
    @link ? 'Edit link' : 'Add link'
  end

  def label_status_class
    @link ? @link.label_status_class : ""
  end
end
