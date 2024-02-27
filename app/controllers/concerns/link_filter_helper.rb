module LinkFilterHelper
  def set_filter_var
    @filter_var = params[:filter] == "broken_links" ? nil : "broken_links"
  end

  def filtered_links(links)
    case params[:filter]
    when "broken_links"
      links.broken_or_missing
    else
      links
    end
  end
end
