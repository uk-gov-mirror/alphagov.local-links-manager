module UrlStatusPresentation
  include ActionView::Helpers::DateHelper

  def status_description
    return "" unless status
    return "Good" if status == '200'
    return "Broken Link #{status}" if status.start_with?('4')
    return "Server Error #{status}" if status.start_with?('5')
    status
  end

  def label_status_class
    return nil unless status
    return nil if status == 'Timeout Error'
    return "label label-success" if status == '200'
    "label label-danger"
  end

  def last_checked
    if link_last_checked
      "Checked #{time_ago_in_words(link_last_checked)} ago"
    else
      "Link not checked"
    end
  end

  def updated?
    view_context.flash[:updated].present? &&
      view_context.flash[:updated]['url'] == url &&
      view_context.flash[:updated]['lgil'] == interaction.lgil_code
  end
end
