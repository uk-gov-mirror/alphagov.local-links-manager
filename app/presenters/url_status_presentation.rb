module UrlStatusPresentation
  include ActionView::Helpers::DateHelper

  def status_description
    return "" unless status
    return "Good" if status == "ok"
    if status == "broken"
      "Broken: #{link_errors.keys.first}"
    elsif status == "caution"
      "Note: #{link_warnings.keys.first}"
    else
      status.capitalize
    end
  end

  def status_detailed_description
    (link_errors.map { |_k, v| v } + link_warnings.map { |_k, v| v }).uniq
  end

  def label_status_class
    return nil unless status
    return "label label-success" if status == "ok"
    return "label label-danger" if status == "broken"
    return "label label-warning" if status == "caution"
    "label label-info"
  end

  def last_checked
    if link_last_checked
      "#{time_ago_in_words(link_last_checked)} ago"
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
